USE testDB;
GO

------------------------------------  1
DISABLE TRIGGER trg_Posts_LogInsert ON dbo.Posts;
ENABLE TRIGGER trg_Posts_LogInsert ON dbo.Posts;

SELECT 
    name AS TriggerName,
    CASE is_disabled 
        WHEN 0 THEN 'Enabled'
        WHEN 1 THEN 'Disabled'
    END AS TriggerStatus
FROM sys.triggers
WHERE name = 'trg_Posts_LogInsert';

------------------------------------  2
CREATE LOGIN TestUserLoginv 
WITH PASSWORD = 'P@ssword123';

CREATE USER TestUser 
FOR LOGIN TestUserLoginv;

CREATE ROLE db_readOnly;

GRANT SELECT ON dbo.Users TO db_readOnly;

ALTER ROLE db_readOnly ADD MEMBER TestUser;

------------------------------------  3
CREATE ROLE DataAnalysts;

GRANT SELECT ON SCHEMA::dbo TO DataAnalysts;
GRANT EXECUTE ON SCHEMA::dbo TO DataAnalysts;

ALTER ROLE DataAnalysts ADD MEMBER TestUser;

------------------------------------  4
REVOKE INSERT, UPDATE 
ON dbo.Posts 
FROM DataEntry;

------------------------------------  5
DENY DELETE 
ON dbo.Users 
TO TestUser;

------------------------------------  6
CREATE OR ALTER TRIGGER trg_Comments_Audit
ON dbo.Comments
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.CommentsAudit
    (
        CommentId,
        OperationType,
        OldValue,
        NewValue,
        ChangedBy,
        ChangedAt
    )
    SELECT
        COALESCE(i.CommentId, d.CommentId),
        CASE
            WHEN i.CommentId IS NOT NULL AND d.CommentId IS NULL THEN 'INSERT'
            WHEN i.CommentId IS NOT NULL AND d.CommentId IS NOT NULL THEN 'UPDATE'
            WHEN i.CommentId IS NULL AND d.CommentId IS NOT NULL THEN 'DELETE'
        END,
        CAST(d.CommentText AS NVARCHAR(MAX)),
        CAST(i.CommentText AS NVARCHAR(MAX)),
        SUSER_SNAME(),
        GETDATE()
    FROM inserted i
    FULL OUTER JOIN deleted d
        ON i.CommentId = d.CommentId;
END;

------------------------------------  7
SELECT
    tr.name AS TriggerName,
    OBJECT_NAME(tr.parent_id) AS TableName,
    CASE tr.is_disabled
        WHEN 0 THEN 'Enabled'
        WHEN 1 THEN 'Disabled'
    END AS TriggerStatus,
    tr.type_desc AS TriggerType
FROM sys.triggers tr
ORDER BY TableName;
