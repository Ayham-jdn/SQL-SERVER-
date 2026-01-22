USE StackOverflow2010;
GO

/*************************************************************
 *                      TABLES SETUP
 *************************************************************/

-- Log for created posts
CREATE TABLE IF NOT EXISTS CreatedPostLog (
    ChangeID INT IDENTITY(1,1) PRIMARY KEY,
    TableName VARCHAR(50),
    ActionType VARCHAR(20),
    UserID INT,
    NewData NVARCHAR(255),
    ChangeDate DATETIME DEFAULT GETDATE()
);

-- Log for user reputation changes
CREATE TABLE IF NOT EXISTS UserTrakLog (
    ChangeID INT IDENTITY(1,1) PRIMARY KEY,
    TableName VARCHAR(50),
    ActionType VARCHAR(50),
    UserID INT,
    OldReputation INT,
    NewReputation INT,
    UpdatedTime DATETIME DEFAULT GETDATE()
);

-- Log deleted posts (soft delete archive)
CREATE TABLE IF NOT EXISTS DeletedPosts (
    DeletedPostID INT IDENTITY(1,1) PRIMARY KEY,
    TableName VARCHAR(50),
    UserID INT,
    Body NVARCHAR(MAX),
    Score INT,
    Title NVARCHAR(255),
    CreationDate DATETIME,
    DeletedDate DATETIME DEFAULT GETDATE()
);

-- Post statistics
CREATE TABLE IF NOT EXISTS PostStatistics (
    UserID INT PRIMARY KEY,
    TotalPosts INT NOT NULL DEFAULT 0,
    TotalScore INT NOT NULL DEFAULT 0,
    AverageScore DECIMAL(10,2) NOT NULL DEFAULT 0
);

--  DDL audit log
CREATE TABLE IF NOT EXISTS DDLAuditLog (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    EventType VARCHAR(100),
    EventDate DATETIME DEFAULT GETDATE(),
    LoginName VARCHAR(100),
    TsqlCommand NVARCHAR(MAX),
    DatabaseName VARCHAR(100)
);

-- User action log (generic)
CREATE TABLE IF NOT EXISTS UserLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    Action VARCHAR(50),
    Details NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE()
);
