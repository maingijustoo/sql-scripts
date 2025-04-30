--form& PROCEDURE  for members--
CREATE PROCEDURE AddNewMember
    @FullName VARCHAR(100),
    @DateOfBirth DATE,
    @ContactNumber VARCHAR(20),
    @Email VARCHAR(100),
    @Address VARCHAR(255),
    @NSSFCardNumber VARCHAR(50),
    @KRAPIN VARCHAR(50),
    @EmploymentStatus VARCHAR(20),
    @EmployerID INT = NULL
AS
BEGIN
    INSERT INTO Members (FullName, DateOfBirth, ContactNumber, Email, Address, NSSFCardNumber, KRAPIN, EmploymentStatus, EmployerID)
    VALUES (@FullName, @DateOfBirth, @ContactNumber, @Email, @Address, @NSSFCardNumber, @KRAPIN, @EmploymentStatus, @EmployerID);
END

--PROCEDURE record new contirbution--

CREATE PROCEDURE AddContribution
    @MemberID INT,
    @EmployerID INT = NULL,
    @ContributionDate DATE,
    @Amount DECIMAL(10,2),
    @PaymentMethod VARCHAR(50)
AS
BEGIN
    INSERT INTO Contributions (MemberID, EmployerID, ContributionDate, Amount, PaymentMethod)
    VALUES (@MemberID, @EmployerID, @ContributionDate, @Amount, @PaymentMethod);
END

--record contribution--

CREATE PROCEDURE AddContribution
    @MemberID INT,
    @EmployerID INT = NULL,
    @ContributionDate DATE,
    @Amount DECIMAL(10,2),
    @PaymentMethod VARCHAR(50)
AS
BEGIN
    INSERT INTO Contributions (MemberID, EmployerID, ContributionDate, Amount, PaymentMethod)
    VALUES (@MemberID, @EmployerID, @ContributionDate, @Amount, @PaymentMethod);
END

--record payment to members--

--user reports
--total contirb by employers
SELECT 
    E.EmployerName, 
    SUM(C.Amount) AS TotalContributions
FROM 
    Contributions C
JOIN 
    Employers E ON C.EmployerID = E.EmployerID
GROUP BY 
    E.EmployerName;

--members contribution summary

SELECT 
    M.FullName,
    COUNT(C.ContributionID) AS TotalContributionsMade,
    SUM(C.Amount) AS TotalAmountContributed
FROM 
    Members M
LEFT JOIN 
    Contributions C ON M.MemberID = C.MemberID
GROUP BY 
    M.FullName;

--members with no contributions

SELECT FullName
FROM Members
WHERE MemberID NOT IN (SELECT DISTINCT MemberID FROM Contributions);


--payments history for requested member

SELECT 
    M.FullName,
    P.PaymentDate,
    P.Amount,
    P.PaymentType,
    P.ProcessedBy
FROM 
    Payments P
JOIN 
    Members M ON P.MemberID = M.MemberID
WHERE 
    M.FullName = 'Alice Mwangi';

--dependents per member
SELECT 
    M.FullName,
    D.DependentName,
    D.Relationship,
    D.DateOfBirth
FROM 
    Dependents D
JOIN 
    Members M ON D.MemberID = M.MemberID;

--contributions aand oaymemnts overview
SELECT 
    M.FullName,
    SUM(C.Amount) AS TotalContributed,
    SUM(P.Amount) AS TotalPaidOut
FROM 
    Members M
LEFT JOIN Contributions C ON M.MemberID = C.MemberID
LEFT JOIN Payments P ON M.MemberID = P.MemberID
GROUP BY 
    M.FullName;

--DATA FLOW& JOINING testing employers summerry
SELECT 
    E.EmployerName,
    SUM(C.Amount) AS TotalEmployerContributions
FROM Employers E
LEFT JOIN Contributions C ON E.EmployerID = C.EmployerID
GROUP BY E.EmployerName;

--DATA FLOW& JOININGtest to list all members with tot contrib
SELECT 
    M.MemberID,
    M.FullName,
    SUM(C.Amount) AS TotalContributions
FROM Members M
LEFT JOIN Contributions C ON M.MemberID = C.MemberID
GROUP BY M.MemberID, M.FullName;

--TRIGGER validate contibution is not zero
CREATE TRIGGER CheckContributionAmount
ON Contributions
BEFORE INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Amount <= 0)
    BEGIN
        RAISERROR ('Contribution amount must be greater than zero.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;


--TRIGGER log new payment automaticlly
CREATE TRIGGER LogPayment
ON Payments
AFTER INSERT
AS
BEGIN
    PRINT 'New payment has been processed.';
END;
