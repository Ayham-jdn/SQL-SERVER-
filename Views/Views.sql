/*
==================================================
 File Name   : views.sql
 Author      : Ayham Jddaini
 Database    : StackOverflow2010

 Description :
   Collection of SQL Server views demonstrating
   common and advanced usage patterns.

 Topics Covered:
   - Basic views
   - Joined views
   - Aggregate views
   - Indexed views
   - Partitioned views
   - Updatable views
   - CHECK OPTION
==================================================
*/

USE StackOverflow2010;
GO

-- 1. Basic View

CREATE OR ALTER VIEW vw_BasicUserInfo
AS
SELECT
    DisplayName,
    Reputation,
    Location,
    CreationDate
FROM Users;
GO

-- 2. Joined View (Posts + Users)

CREATE OR ALTER VIEW vw_PostsWithAuthors
AS
SELECT
    p.Title       AS PostTitle,
    p.Score       AS PostScore,
    u.DisplayName AS AuthorName,
    u.Reputation  AS AuthorReputation
FROM Posts p
INNER JOIN Users u
    ON p.OwnerUserId = u.Id;
GO

-- 3. Aggregate View (Comments per Post)

CREATE OR ALTER VIEW vw_PostCommentStats
AS
SELECT
    PostId,
    COUNT(*)        AS TotalCommentCount,
    SUM(Score)      AS TotalCommentScore,
    AVG(Score)      AS AverageCommentScore
FROM Comments
GROUP BY PostId;
GO

-- 4. Indexed View (User Activity)

CREATE OR ALTER VIEW dbo.vw_UserActivityIndexed
WITH SCHEMABINDING
AS
SELECT
    u.Id            AS UserId,
    u.DisplayName,
    u.Reputation,
    COUNT_BIG(p.Id) AS TotalPostsCount
FROM dbo.Users u
LEFT JOIN dbo.Posts p
    ON u.Id = p.OwnerUserId
GROUP BY
    u.Id,
    u.DisplayName,
    u.Reputation;
GO

CREATE UNIQUE CLUSTERED INDEX IX_vw_UserActivityIndexed_UserId
ON dbo.vw_UserActivityIndexed (UserId);
GO

-- 5. Partitioned View (Logical Segmentation)

CREATE OR ALTER VIEW vw_UsersPartitioned
AS
SELECT
    Id,
    DisplayName,
    Reputation,
    Location,
    CreationDate,
    'HIGH' AS ReputationLevel
FROM Users
WHERE Reputation > 5000

UNION ALL

SELECT
    Id,
    DisplayName,
    Reputation,
    Location,
    CreationDate,
    'LOW' AS ReputationLevel
FROM Users
WHERE Reputation <= 5000;
GO

-- 6. Updatable View

CREATE OR ALTER VIEW vw_EditableUsers
AS
SELECT
    Id AS UserId,
    DisplayName,
    Location
FROM Users;
GO

-- 7. View with CHECK OPTION

CREATE OR ALTER VIEW vw_QualityPosts
AS
SELECT
    Id,
    Title,
    Score,
    ViewCount,
    CreationDate
FROM Posts
WHERE Score >= 20
WITH CHECK OPTION;
GO

-- 8. Business Logic View (Categorization)

CREATE OR ALTER VIEW vw_PostsByCategory
AS
SELECT
    Id    AS PostId,
    Title,
    Score,
    CASE
        WHEN Score >= 100 THEN 'Excellent'
        WHEN Score BETWEEN 50 AND 99 THEN 'Good'
        WHEN Score BETWEEN 10 AND 49 THEN 'Average'
        ELSE 'Low'
    END AS Category
FROM Posts;
GO
