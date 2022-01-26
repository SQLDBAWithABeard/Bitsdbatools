-- We can write adn run T-SQL Scripts
Select Name from sys.sysdatabases
-- Now we press CTRL + SHIFT + E 

SELECT 
j.Name,
SUSER_SNAME(owner_sid) AS Owner,
jh.run_date
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobhistory jh 
ON jh.job_id = j.job_id AND jh.step_id = 0 

