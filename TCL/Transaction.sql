USE testDB;
GO

----------------------------------------
--  1: Simple Transfer $500
----------------------------------------
SELECT accountId, balance FROM AccountBalance WHERE accountId IN (101,102);

BEGIN TRAN TRANSFER;
    UPDATE AccountBalance SET balance -= 500 WHERE accountId = 101;
    UPDATE AccountBalance SET balance += 500 WHERE accountId = 102;
COMMIT TRAN;

SELECT accountId, balance FROM AccountBalance WHERE accountId IN (101,102);

----------------------------------------
--  2: Rollback Example
----------------------------------------
SELECT accountId, balance FROM AccountBalance WHERE accountId IN (101,102);

BEGIN TRAN TRANSFER;
    UPDATE AccountBalance SET balance -= 1000 WHERE accountId = 101;
    UPDATE AccountBalance SET balance += 1000 WHERE accountId = 102;
ROLLBACK TRAN;

SELECT accountId, balance FROM AccountBalance WHERE accountId IN (101,102);

----------------------------------------
--  3: Conditional Transfer
----------------------------------------
BEGIN TRAN;
DECLARE @CurrentBalance DECIMAL(18,2);
SELECT @CurrentBalance = balance FROM AccountBalance WHERE accountId = 101;

IF @CurrentBalance >= 2000
BEGIN
    UPDATE AccountBalance SET balance -= 2000 WHERE accountId = 101;
    UPDATE AccountBalance SET balance += 2000 WHERE accountId = 102;
    PRINT 'Transfer successful';
    COMMIT TRAN;
END
ELSE
BEGIN
    PRINT 'Transaction failed: insufficient balance';
    ROLLBACK TRAN;
END

----------------------------------------
--  4: Try/Catch Error Handling
----------------------------------------
BEGIN TRY
    BEGIN TRAN
        UPDATE AccountBalance SET balance -= 1000 WHERE accountId = 101;
        UPDATE AccountBalance SET balance += 1000 WHERE accountId = 102;
    COMMIT
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

----------------------------------------
--  5: Partial Rollback with Savepoints
----------------------------------------
BEGIN TRAN;
BEGIN TRY
    UPDATE AccountBalance SET balance -= 500 WHERE accountId = 101;
    SAVE TRAN savepoint1;

    UPDATE AccountBalance SET balance += 500 WHERE accountId = 102;
    SAVE TRAN savepoint2;
END TRY
BEGIN CATCH
    ROLLBACK TRAN savepoint1;
    UPDATE AccountBalance SET balance += 500 WHERE accountId = 103;
END CATCH
COMMIT TRAN;

----------------------------------------
--  6: Nested Transactions and @@TRANCOUNT
----------------------------------------
PRINT 'Before any transaction: @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR);

BEGIN TRAN; -- OUTER
    PRINT 'After OuterTran: @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR);
    UPDATE AccountBalance SET balance -= 100 WHERE accountId = 101;

    BEGIN TRAN; -- INNER
        PRINT 'After InnerTran: @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR);
        UPDATE AccountBalance SET balance += 100 WHERE accountId = 101;
    COMMIT; -- INNER
    PRINT 'After Inner Commit: @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR);

COMMIT; -- OUTER
PRINT 'After Outer Commit: @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR);

----------------------------------------
--  7: Stored Procedure for Transfer
----------------------------------------
CREATE OR ALTER PROC sp_transfer 
    @FAcc INT, 
    @TAcc INT, 
    @Amount DECIMAL(18,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;
        IF @Amount <= 0 THROW 50001, 'Invalid amount', 1;

        IF NOT EXISTS (SELECT 1 FROM AccountBalance WHERE accountId = @FAcc)
            THROW 50002, 'FromAccount does not exist', 1;
        IF NOT EXISTS (SELECT 1 FROM AccountBalance WHERE accountId = @TAcc)
            THROW 50003, 'ToAccount does not exist', 1;

        DECLARE @FBalance DECIMAL(18,2);
        SELECT @FBalance = balance FROM AccountBalance WHERE accountId = @FAcc;

        IF @Amount > @FBalance
            THROW 50004, 'Insufficient balance', 1;

        UPDATE AccountBalance SET balance -= @Amount WHERE accountId = @FAcc;
        UPDATE AccountBalance SET balance += @Amount WHERE accountId = @TAcc;

        COMMIT TRAN;
        PRINT 'Transfer successful!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END;

EXEC sp_transfer @FAcc = 101, @TAcc = 102, @Amount = 2300;

----------------------------------------
-- 8: Trigger for Auditing
----------------------------------------
CREATE OR ALTER TRIGGER trg_Audit_AccountBalance
ON AccountBalance
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (TableName, Operation, RecordId, OldValue, NewValue)
    SELECT
        'AccountBalance',
        'Transfer',
        i.accountId,
        CAST(d.balance AS VARCHAR(500)),
        CAST(i.balance AS VARCHAR(500))
    FROM inserted i
    INNER JOIN deleted d ON i.accountId = d.accountId;
END;
