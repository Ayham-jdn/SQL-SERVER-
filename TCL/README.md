# SQL Transaction Practice

This repository contains examples of **SQL transactions** using `BEGIN TRAN`, `COMMIT`, `ROLLBACK`, `TRY/CATCH`, `SAVEPOINT`, and stored procedures. It also includes a trigger for auditing.

## Tables
- `AccountBalance(accountId INT, balance DECIMAL(18,2))`
- `AuditTrail(TableName VARCHAR, Operation VARCHAR, RecordId INT, OldValue VARCHAR, NewValue VARCHAR)`

## Key Topics Covered
1. Simple transfers (withdraw/deposit)
2. Rollback example
3. Conditional transfer based on balance
4. Error handling with TRY/CATCH
5. Partial rollback using SAVEPOINT
6. Nested transactions and @@TRANCOUNT
7. Stored procedure for transfers
8. Trigger for auditing updates
9. Business rule enforcement (limits on withdrawals)

## Notes
- Always check balance before withdrawal.
- Use transactions to ensure atomic operations.
- Use triggers to maintain audit logs automatically.

