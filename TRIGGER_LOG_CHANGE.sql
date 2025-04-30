USE pensionsDB
GO

CREATE TRIGGER trg_AuditContributions
ON Contributions
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'Contribution record has been modified.';
END;


--auto paymemnt procesciing trigger
CREATE TRIGGER AutoProcessPayment
ON Payments
AFTER INSERT
AS
BEGIN
    UPDATE Payments 
    SET Status = 'Processed' 
    WHERE PaymentID IN (SELECT PaymentID FROM inserted);
END;

--data intergrity trigger it ensures contribution rel=mains clean
CREATE TRIGGER trg_after_contribution_delete
ON Contributions
FOR DELETE
AS
BEGIN
    -- Code to handle cascading actions
    DELETE FROM RelatedTable WHERE contribution_id IN (SELECT id FROM deleted);
END;

--autodetect when a contribution is made
CREATE PROCEDURE AutoDeductContributions AS
BEGIN
    INSERT INTO Contributions (MemberID, EmployerID, ContributionDate, Amount, PaymentMethod)
    SELECT MemberID, EmployerID, GETDATE(), 5000, 'Employer Remittance'
    FROM Members WHERE EmploymentStatus = 'Employed';
END;

