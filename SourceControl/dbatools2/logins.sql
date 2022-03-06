
USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'BUILTIN\Administrators') CREATE LOGIN [BUILTIN\Administrators] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [BUILTIN\Administrators]
GO

USE master

GO
Grant CONNECT SQL TO [BUILTIN\Administrators]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'sqladmin') CREATE LOGIN [sqladmin] WITH PASSWORD = ####### HASHED, SID = 0x21A63BA3525821498FDED3037F96A293, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [sqladmin]
GO

USE msdb

GO
EXEC msdb.dbo.sp_update_job @job_name=N'IamBroke', @owner_login_name=N'sqladmin'
GO

USE master

GO
Grant CONNECT SQL TO [sqladmin]  AS [sa]
GO
