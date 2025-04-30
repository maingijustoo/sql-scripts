CREATE VIEW MemberContributionSummary AS
SELECT 
    M.MemberID,
    M.FullName,
    COALESCE(SUM(C.Amount), 0) AS TotalContributed
FROM 
    Members M
LEFT JOIN 
    Contributions C ON M.MemberID = C.MemberID
GROUP BY 
    M.MemberID, M.FullName;
