📂 Indexes

This folder contains SQL Server indexing examples designed to improve query performance.

Indexes here are query-driven, meaning each index is created to support a specific query pattern.

📄 posts_indexes.sql
Contains indexes related to the Posts table:

✔ Basic Nonclustered Index
Improves filtering and sorting on Score

✔ Filtered Covering Index
Targets high-score posts only
Reduces index size
Eliminates key lookups

🧩 Concepts Covered
Nonclustered Index
Filtered Index
Covering Index
Index Seek vs Table Scan