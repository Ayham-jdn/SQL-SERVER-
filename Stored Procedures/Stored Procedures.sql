USE StackOverflow2010;
GO

----------------------------------------
-- Question 1: Get Recent Badges
----------------------------------------
CREATE OR ALTER PROCEDURE sp_GetRecentBadges
    @DaysBack INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @var DATETIME = DATEADD(DAY, -@DaysBack,'2010-12-31'); 
    -- Replace '2010-12-31' with GETDATE() for recent dates

    SELECT 
        b.Id AS BadgeId,
        b.Name AS BName,
        b.Date AS Earned,
        u.Id AS UserId,
        u.DisplayName AS Username
    FROM Badges b
    LEFT JOIN Users u ON b.UserId = u.Id
    WHERE b.Date >= @var
    ORDER BY b.Date DESC;
END;
GO

-- Test
EXEC sp_GetRecentBadges 7;

----------------------------------------
-- Question 2: User Summary
----------------------------------------
CREATE OR ALTER PROCEDURE sp_GetUserSummary
    @UserId INT,
    @TotalPosts INT OUTPUT,
    @TotalBadges INT OUTPUT,
    @AvrScore DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        @TotalPosts = COUNT(*), 
        @AvrScore = ISNULL(AVG(Score),0)
    FROM Posts 
    WHERE OwnerUserId = @UserId;

    SELECT @TotalBadges = COUNT(*)
    FROM Badges 
    WHERE UserId = @UserId;
END;
GO

-- Test
DECLARE @post INT, @avr DECIMAL(10,2), @badges INT;
EXEC sp_GetUserSummary 1, @post OUTPUT, @avr OUTPUT, @badges OUTPUT;
SELECT @post AS TotalPosts, @avr AS AvrScore, @badges AS TotalBadges;

----------------------------------------
-- Question 3: Search Posts
----------------------------------------
CREATE OR ALTER PROCEDURE sp_SearchPosts
    @keyword NVARCHAR(20), 
    @minScore INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Posts
    WHERE Title LIKE '%' + @keyword + '%'
      AND Score >= @minScore
    ORDER BY Score DESC;
END;
GO

-- Test
EXEC sp_SearchPosts @keyword = 'sql', @minScore = 2000;

----------------------------------------
-- Question 4: Get User or Error
----------------------------------------
CREATE OR ALTER PROCEDURE sp_GetUserOrError
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT *
        FROM Users 
        WHERE Id = @UserId;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('User with Id %d does not exist', 16, 1, @UserId);
        END
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Message;
    END CATCH
END;
GO

-- Test
EXEC sp_GetUserOrError 2000;

----------------------------------------
-- Question 5: Analyze User Activity
----------------------------------------
CREATE OR ALTER PROCEDURE sp_AnalyzeUserActivity
    @UserId INT, 
    @ActivityScore INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Reputation INT, @PostCount INT;

    SELECT @Reputation = Reputation
    FROM Users
    WHERE Id = @UserId;

    SELECT @PostCount = COUNT(*)
    FROM Posts
    WHERE OwnerUserId = @UserId;

    IF @PostCount = 0
    BEGIN
        PRINT 'No posts for user ' + CAST(@UserId AS VARCHAR(10));
        SET @ActivityScore = 0;
        RETURN;
    END

    SET @ActivityScore = @Reputation + (@PostCount * 10);

    SELECT TOP 5
        u.Id AS UserId,
        u.DisplayName AS UserName,
        p.Title
    FROM Posts p
    RIGHT JOIN Users u ON p.OwnerUserId = u.Id
    WHERE p.OwnerUserId = @UserId
    ORDER BY p.Score DESC;
END;
GO

-- Test
DECLARE @Score INT;
EXEC sp_AnalyzeUserActivity 10, @ActivityScore = @Score OUTPUT;
SELECT @Score AS ActivityScore;

----------------------------------------
-- Question 6: Get Reputation In/Out
----------------------------------------
CREATE OR ALTER PROCEDURE sp_GetReputationInOut
    @Parameter INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @Parameter = Reputation
    FROM Users
    WHERE Id = @Parameter;
END;
GO

-- Test
DECLARE @UserId INT = 5;
EXEC sp_GetReputationInOut @Parameter = @UserId OUTPUT;
SELECT @UserId AS Reputation;

----------------------------------------
-- Question 7: Update Post Score
----------------------------------------
CREATE OR ALTER PROCEDURE sp_UpdatePostScore
    @PostId INT,
    @NewScore INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM Posts WHERE Id = @PostId)
            THROW 50001, 'Post not found', 1;

        UPDATE Posts
        SET Score = @NewScore
        WHERE Id = @PostId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- Test
EXEC sp_UpdatePostScore @PostId = 10, @NewScore = 50;

----------------------------------------
-- Question 8: Top Users by Reputation
----------------------------------------
CREATE OR ALTER PROCEDURE sp_GetTopUsersByReputation
    @TopN INT, 
    @MinValue INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
        Id,
        DisplayName,
        Reputation
    FROM Users
    WHERE Reputation >= @MinValue
    ORDER BY Reputation DESC;
END;
GO

-- Archive Table
CREATE TABLE IF NOT EXISTS TopUsersArchive
(
    ArchiveId INT IDENTITY PRIMARY KEY,
    UserId INT,
    DisplayName NVARCHAR(100),
    Reputation INT,
    ArchivedAt DATETIME DEFAULT GETDATE()
);

-- Insert into Archive
INSERT INTO TopUsersArchive (UserId, DisplayName, Reputation)
EXEC sp_GetTopUsersByReputation @TopN = 5, @MinValue = 1000;

SELECT * FROM TopUsersArchive;

----------------------------------------
-- Question 9: Insert User Log
----------------------------------------
CREATE TABLE IF NOT EXISTS UserLog
(
    Id INT IDENTITY PRIMARY KEY,
    UserId INT,
    Action NVARCHAR(100),
    Details NVARCHAR(400),
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE OR ALTER PROCEDURE sp_InsertUserLog
    @UserId INT,
    @Action NVARCHAR(100),
    @Details NVARCHAR(400),
    @LogId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO UserLog(UserId, Action, Details)
    VALUES (@UserId, @Action, @Details);

    SET @LogId = SCOPE_IDENTITY();
END;
GO

-- Test
DECLARE @NewLogId INT;
EXEC sp_InsertUserLog @UserId = 1, @Action ='Login', @Details = 'User logged in', @LogId = @NewLogId OUTPUT;
SELECT @NewLogId AS LogId;

----------------------------------------
-- Question 10: Update User Reputation
----------------------------------------
CREATE OR ALTER PROCEDURE sp_UpdateUserReputation
    @UserId INT, 
    @UpdatedReputation INT, 
    @RowsEff INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF @UpdatedReputation < 0
            THROW 50003, 'Reputation cannot be negative.', 1;

        IF NOT EXISTS (SELECT 1 FROM Users WHERE Id = @UserId)
            THROW 50001, 'User not found', 1;

        UPDATE Users
        SET Reputation = @UpdatedReputation,
            LastAccessDate = GETDATE()
        WHERE Id = @UserId;

        SET @RowsEff = @@ROWCOUNT;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET @RowsEff = 0;
        THROW;
    END CATCH
END;
GO

-- Test
DECLARE @Count INT;
EXEC sp_UpdateUserReputation @UserId = 5, @UpdatedReputation = 100, @RowsEff = @Count OUTPUT;
SELECT @Count AS RowsAffected;

----------------------------------------
-- Question 11: Delete Low Score Posts
----------------------------------------
CREATE OR ALTER PROCEDURE sp_DeleteLowScorePosts
    @Value INT, 
    @RowsDeleted INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        DELETE FROM Posts
        WHERE Score <= @Value;

        SET @RowsDeleted = @@ROWCOUNT;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        SET @RowsDeleted = 0;
    END CATCH
END;
GO

-- Test
DECLARE @Var INT;
EXEC sp_DeleteLowScorePosts @Value = 2000, @RowsDeleted = @Var OUTPUT;
SELECT @Var AS RowsDeleted;

----------------------------------------
-- Question 12: Bulk Insert Badges
----------------------------------------
CREATE OR ALTER PROCEDURE sp_BulkInsertBadges
    @UserId INT, 
    @BadgeCount INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;

    WHILE @i < @BadgeCount
    BEGIN
        INSERT INTO Badges(UserId, Date)
        VALUES (@UserId, GETDATE());

        SET @i = @i + 1;
    END
END;
GO

-- Test
EXEC sp_BulkInsertBadges 1, 3;

----------------------------------------
-- Question 13: Generate User Report
----------------------------------------
CREATE OR ALTER PROCEDURE sp_UserStatistics
    @UserId INT,
    @TotalPosts INT OUTPUT,
    @AvrScore DECIMAL(10,2) OUTPUT,
    @UserRep INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        @TotalPosts = COUNT(p.Id),
        @AvrScore = ISNULL(AVG(p.Score),0),
        @UserRep = MAX(u.Reputation)
    FROM Users u
    LEFT JOIN Posts p ON p.OwnerUserId = u.Id
    WHERE u.Id = @UserId;
END;
GO

CREATE OR ALTER PROCEDURE sp_GenerateUserReport
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalPosts INT, @AvrScore DECIMAL(10,2), @UserRep INT;

    EXEC sp_UserStatistics 
        @UserId = @UserId,
        @TotalPosts = @TotalPosts OUTPUT,
        @AvrScore = @AvrScore OUTPUT,
        @UserRep = @UserRep OUTPUT;

    SELECT
        Id,
        DisplayName AS UserName,
        @TotalPosts AS TotalPosts,
        @AvrScore AS AvgScore,
        @UserRep AS UserReputation,
        CASE
            WHEN @UserRep < 1000 THEN 'Beginner'
            WHEN @UserRep BETWEEN 1000 AND 5000 THEN 'Intermediate'
            ELSE 'Expert'
        END AS UserLevel
    FROM Users
    WHERE Id = @UserId;
END;
GO

-- Test
EXEC sp_GenerateUserReport 2;
