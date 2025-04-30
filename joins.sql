--members and emloyers
SELECT FullName, EmploymentStatus, COALESCE(EmployerName, 'N/A') AS Employer
FROM Members 
LEFT JOIN Employers ON Members.EmployerID = Employers.EmployerID;

--employers contributions summary
SELECT Employers.EmployerName, SUM(Contributions.Amount) AS TotalContributions
FROM Contributions
JOIN Employers ON Contributions.EmployerID = Employers.EmployerID
GROUP BY Employers.EmployerName;

--memebrs lacking contirbutions
SELECT FullName
FROM Members 
WHERE MemberID NOT IN (SELECT DISTINCT MemberID FROM Contributions);

