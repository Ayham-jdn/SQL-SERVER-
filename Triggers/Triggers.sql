
/*************************************************************
 *                      POSTS TRIGGERS
 *************************************************************/

--  After Insert ? log new posts
CREATE OR ALTER TRIGGER trg_afterInsert_posts
ON Posts
AFTER INSERT
AS
BEGIN
    INSERT INTO CreatedPostLog (TableName, ActionType, UserID, NewData, ChangeDate)
    SELECT 'Posts', 'INSERT', i.OwnerUserID, i.Title, GETDATE()
    FROM inserted i;
END;

--  Instead Of Update ? prevent ID update
CREATE OR ALTER TRIGGER trg_insteadUpdate_posts
ON Posts
INSTEAD OF UPDATE
AS
BEGIN
    -- Block updating Id
    IF UPDATE(Id)
    BEGIN
        INSERT INTO UserLog(UserID, Action, Details, CreatedAt)
        SELECT u.Id, 'Update', 'Attempted to change Post ID: ' + CAST(i.Id AS NVARCHAR(10)), GETDATE()
        FROM inserted i
        LEFT JOIN Users u ON i.OwnerUserID = u.Id;

        RAISERROR('Updating the Id column is not allowed.', 16, 1);
        RETURN;
    END

    -- Update allowed columns (Title example)
    UPDATE p
    SET p.Title = i.Title,
        p.LastEditDate = GETDATE()
    FROM Posts p
    INNER JOIN inserted i ON p.Id = i.Id;
END;

-- After Update/Insert/Delete ? maintain PostStatistics
CREATE OR ALTER TRIGGER trg_poststatics_posts
ON Posts
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    MERGE PostStatistics ps
    USING (
        SELECT OwnerUserID AS UserID,
               COUNT(*) AS TotalPosts,
               SUM(Score) AS TotalScore,
               AVG(CAST(Score AS DECIMAL(10,2))) AS AverageScore
        FROM Posts
        GROUP BY OwnerUserID
    ) src
    ON ps.UserID = src.UserID
    WHEN MATCHED THEN
        UPDATE SET TotalPosts = src.TotalPosts,
                   TotalScore = src.TotalScore,
                   AverageScore = src.AverageScore
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (UserID, TotalPosts, TotalScore, AverageScore)
        VALUES (src.UserID, src.TotalPosts, src.TotalScore, src.AverageScore);
END;

--  Instead Of Delete ? prevent posts with Score > 100
CREATE OR ALTER TRIGGER trg_deletePostPrevent_posts
ON Posts
INSTEAD OF DELETE
AS
BEGIN
    -- Log blocked deletions
    INSERT INTO UserLog(UserID, Action, Details, CreatedAt)
    SELECT OwnerUserID, 'Delete Blocked', 'Attempted to delete Post ID=' + CAST(Id AS NVARCHAR(10)), GETDATE()
    FROM deleted
    WHERE Score > 100;

    -- Delete posts with Score <= 100
    DELETE p
    FROM Posts p
    INNER JOIN deleted d ON p.Id = d.Id
    WHERE p.Score <= 100;
END;

/*************************************************************
 *                      USERS TRIGGER
 *************************************************************/

-- Track Reputation changes
CREATE OR ALTER TRIGGER trg_afterUpdate_users
ON Users
AFTER UPDATE
AS
BEGIN
    INSERT INTO UserTrakLog (TableName, ActionType, UserID, OldReputation, NewReputation)
    SELECT 'Users', 'UPDATE', i.Id, d.Reputation, i.Reputation
    FROM inserted i
    INNER JOIN deleted d ON i.Id = d.Id
    WHERE i.Reputation <> d.Reputation;
END;

/*************************************************************
 *                      COMMENTS TRIGGER
 *************************************************************/

-- Soft delete
ALTER TABLE Comments
ADD IsDeleted BIT DEFAULT 0,
    DeletedDate DATETIME NULL;

CREATE OR ALTER TRIGGER trg_indteadDelete_comments
ON Comments
INSTEAD OF DELETE
AS
BEGIN
    UPDATE Comments
    SET IsDeleted = 1,
        DeletedDate = GETDATE()
    WHERE Id IN (SELECT Id FROM deleted);

    INSERT INTO UserLog (UserID, Action, Details, CreatedAt)
    SELECT d.UserID, 'Delete', u.DisplayName + ' deleted comment ID=' + CAST(d.Id AS NVARCHAR(10)), GETDATE()
    FROM deleted d
    INNER JOIN Users u ON d.UserID = u.Id;
END;

/*************************************************************
 *                      VIEWS TRIGGER
 *************************************************************/

-- Prevent empty DisplayName on vw_NewUsers
CREATE OR ALTER VIEW vw_NewUsers AS
SELECT DisplayName, Reputation, Location, CreationDate FROM Users;

CREATE OR ALTER TRIGGER trg_inteadInsert_vwNewUsers
ON vw_NewUsers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DisplayName IS NULL OR DisplayName = '')
    BEGIN
        RAISERROR('DisplayName cannot be NULL or empty.', 16, 1);
        RETURN;
    END

    INSERT INTO Users (DisplayName, Reputation, Location, CreationDate)
    SELECT DisplayName, Reputation, Location, CreationDate
    FROM inserted;
END;

/*************************************************************
 *                      BADGES TRIGGER
 *************************************************************/

CREATE OR ALTER TRIGGER trg_badges
ON Badges
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- INSERT
    INSERT INTO CreatedPostLog (TableName, ActionType, UserID, NewData, ChangeDate)
    SELECT 'Badges', 'INSERT', i.UserID, i.Name, GETDATE()
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM deleted d WHERE d.Id = i.Id);

    -- DELETE
    INSERT INTO CreatedPostLog (TableName, ActionType, UserID, NewData, ChangeDate)
    SELECT 'Badges', 'DELETE', d.UserID, d.Name, GETDATE()
    FROM deleted d
    WHERE NOT EXISTS (SELECT 1 FROM inserted i WHERE i.Id = d.Id);

    -- UPDATE
    INSERT INTO CreatedPostLog (TableName, ActionType, UserID, NewData, ChangeDate)
    SELECT 'Badges', 'UPDATE', i.UserID, i.Name, GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON i.Id = d.Id;
END;

/*************************************************************
 *                      DDL AUDIT TRIGGER
 *************************************************************/

CREATE OR ALTER TRIGGER trg_ddlOperation
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    INSERT INTO DDLAuditLog(EventType, LoginName, TsqlCommand, DatabaseName)
    VALUES (
        EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        SYSTEM_USER,
        EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)'),
        DB_NAME()
    );

    -- Optional rollback for DROP_TABLE only
    IF EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)') = 'DROP_TABLE'
        ROLLBACK;
END;
