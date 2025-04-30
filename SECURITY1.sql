CREATE LOGIN ReadOnlyUser WITH PASSWORD = 'LIPUAGHAT';
CREATE USER ReadOnlyUser FOR LOGIN ReadOnlyUser;
GRANT SELECT ON Members TO ReadOnlyUser;
GRANT SELECT ON Contributions TO ReadOnlyUser;


--auditing
CREATE TRIGGER LogChanges
ON Members
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO AuditLog (TableName, ActionType, ChangeDate) 
    VALUES ('Members', EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'), GETDATE());
END;

-- Create a master key 
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ilovebigtirriiies';

-- symmetric key for encrypting sensitive data
CREATE SYMMETRIC KEY KRA_PIN_KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY PASSWORD = 'ilovebigtirriiies';


-- Encrypt the KRA PIN for not already inserted deta
OPEN SYMMETRIC KEY KRA_PIN_KEY DECRYPTION BY PASSWORD = 'ilovebigtirriiies';

INSERT INTO Members (fullname, email, krapin)
VALUES ('John Doe', 'johndoe@example.com', 
        EncryptByKey(Key_GUID('KRA_PIN_KEY'), '1234567890')); -- Encrypt the KRA PIN

CLOSE SYMMETRIC KEY KRA_PIN_KEY;



--decryption for login
-- Decrypt KRA PIN during login attempt
OPEN SYMMETRIC KEY KRA_PIN_KEY DECRYPTION BY PASSWORD = 'ilovebigtirriiies';

DECLARE @DecryptedKraPin VARCHAR(255);

SELECT @DecryptedKraPin = CONVERT(VARCHAR, DecryptByKey(krapin))
FROM Members
WHERE email = 'johndoe@example.com';

CLOSE SYMMETRIC KEY KRA_PIN_KEY;

-- Compare decrypted KRA PIN with the provided one (e.g., via application logic)
IF @DecryptedKraPin = '1234567890'
BEGIN
    PRINT 'Login successful';
END
ELSE
BEGIN
    PRINT 'Invalid KRA PIN';
END
DROP SYMMETRIC KEY KRA_PIN_KEY; --dropping key when unessecarry



-- Enable audit logging checking logiing in attempts
EXEC sp_configure 'login audit level', 2; -- Level 2: Log all failed login attempts
RECONFIGURE;
