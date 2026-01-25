# SQL Server Security & Triggers Practice

This repository contains SQL Server practice scripts focusing on:

- Triggers (Enable / Disable / Audit)
- SQL Server Security (Login, User, Role, Permissions)
- System catalog views (`sys.triggers`)

## Database
- **Database name:** testDB

## Covered Topics

### 1. Trigger Management
- Enable and disable triggers
- Check trigger status using system views

### 2. Security & Permissions
- Create SQL Login and Database User
- Create database roles
- GRANT, REVOKE, and DENY permissions
- Assign users to roles

### 3. Audit Trigger
- Audit INSERT, UPDATE, DELETE operations
- Track old and new values
- Store username and timestamp

### 4. System Views
- Query all triggers with their status and type

## Tables Used
- `Users`
- `Posts`
- `Comments`
- `CommentsAudit`

## Notes
- `DENY` overrides permissions granted through roles
- Schema-level permissions (`SCHEMA::dbo`) are used for scalability
- Triggers use `inserted` and `deleted` pseudo-tables
