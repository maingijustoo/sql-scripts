USE pensionsDB;
GO

SELECT FullName, EmploymentStatus, COALESCE(EmployerName, 'N/A') AS Employer
FROM Members 
LEFT JOIN Employers ON Members.EmployerID = Employers.EmployerID;

SELECT Employers.EmployerName, SUM(Contributions.Amount) AS TotalContributions
FROM Contributions
JOIN Employers ON Contributions.EmployerID = Employers.EmployerID
GROUP BY Employers.EmployerName;

SELECT FullName
FROM Members 
WHERE MemberID NOT IN (SELECT DISTINCT MemberID FROM Contributions);

SELECT M.FullName, P.PaymentDate, P.Amount, P.PaymentType
FROM Payments P
JOIN Members M ON P.MemberID = M.MemberID
WHERE M.FullName = 'Alice Mwangi';

