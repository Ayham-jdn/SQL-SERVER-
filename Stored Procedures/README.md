# StackOverflow SQL Stored Procedures

This folder contains a set of **SQL Server Stored Procedures** created for the StackOverflow database.  
The procedures cover common operations such as retrieving user statistics, analyzing activity, managing posts, badges, and generating reports.

All procedures are designed with **modular structure**, **error handling**, and **output parameters** where appropriate.  

---

## Table of Contents

1. [sp_GetRecentBadges](#sp_getrecentbadges) – Retrieves badges earned by users in the last N days.  
2. [sp_GetUserSummary](#sp_getusersummary) – Returns total posts, total badges, and average score for a user.  
3. [sp_SearchPosts](#sp_searchposts) – Searches posts by keyword and minimum score.  
4. [sp_GetUserOrError](#sp_getuserorerror) – Returns user details or throws an error if not found.  
5. [sp_AnalyzeUserActivity](#sp_analyzeuseractivity) – Calculates activity score and returns top 5 posts.  
6. [sp_GetReputationInOut](#sp_getreputationinout) – Uses a single input/output parameter to get a user’s reputation.  
7. [sp_UpdatePostScore](#sp_updatepostscore) – Updates the score of a post with transaction handling.  
8. [sp_GetTopUsersByReputation](#sp_gettopusersbyreputation) – Retrieves top N users above a minimum reputation.  
9. [sp_InsertUserLog](#sp_insertuserlog) – Inserts a log entry for user actions and returns the log ID.  
10. [sp_UpdateUserReputation](#sp_updateuserreputation) – Updates a user’s reputation safely and returns rows affected.  
11. [sp_DeleteLowScorePosts](#sp_deletelowscoreposts) – Deletes all posts with a score below a specified value.  
12. [sp_BulkInsertBadges](#sp_bulkinsertbadges) – Inserts multiple badges for a user in a single operation.  
13. [sp_GenerateUserReport](#sp_generateuserreport) – Generates a complete user report combining profile and statistics.

---

## Highlights

- **Error Handling**: Most procedures use `TRY...CATCH` and transaction handling to ensure safe operations.  
- **Output Parameters**: Many procedures return computed values using `OUTPUT` parameters.  
- **Top N & Aggregates**: Procedures use SQL aggregates (`COUNT`, `AVG`, `MAX`) and `TOP N` queries.  
- **Formatted Reports**: `sp_GenerateUserReport` combines user data and statistics with calculated user levels.

---

## Example Usage

### 13. Generate User Report
```sql
EXEC sp_GenerateUserReport 2;


