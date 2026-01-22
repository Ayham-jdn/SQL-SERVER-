# StackOverflow2010 SQL Triggers

## Overview
This repository contains SQL Server triggers for the `StackOverflow2010` database. The triggers manage auditing, validation, soft deletes, and statistics for key tables: `Posts`, `Comments`, `Users`, `Badges`.

## Features

### Posts
- `trg_afterInsert_posts`: logs every new post creation into `CreatedPostLog`
- `trg_insteadUpdate_posts`: prevents updating the `Id` column and logs attempts
- `trg_poststatics_posts`: maintains summary statistics (`TotalPosts`, `TotalScore`, `AverageScore`) in `PostStatistics`
- `trg_deletePostPrevent_posts`: prevents deletion of posts with Score > 100 and logs attempts

### Users
- `trg_afterUpdate_users`: logs changes in `Reputation` to `UserTrakLog`

### Views
- `trg_inteadInsert_vwNewUsers`: prevents inserting rows with NULL or empty `DisplayName`

### Comments
- `trg_indteadDelete_comments`: implements soft delete with `IsDeleted` flag and logs actions

### Badges
- `trg_badges`: logs INSERT, UPDATE, DELETE operations on `Badges` table

### Database DDL
- `trg_ddlOperation`: audits CREATE/ALTER/DROP table operations in `DDLAuditLog`

## Setup
1. Create all supporting tables first (`CreatedPostLog`, `UserTrakLog`, `DeletedPosts`, `PostStatistics`, `DDLAuditLog`)
2. Create all triggers using the SQL scripts in their respective folders
3. Test triggers with sample INSERT/UPDATE/DELETE statements
