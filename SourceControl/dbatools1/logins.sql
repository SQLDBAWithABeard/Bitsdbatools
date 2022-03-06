
USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'app1') CREATE LOGIN [app1] WITH PASSWORD = ####### HASHED, SID = 0x63F51E14DBA20942AF361A3300193A7B, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [app1]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'appAdmin') CREATE LOGIN [appAdmin] WITH PASSWORD = ####### HASHED, SID = 0x9243AF88BBE7B74EB83607393A9BB427, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [appAdmin]  AS [sa]
GO

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
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'distributor_admin') CREATE LOGIN [distributor_admin] WITH PASSWORD = ####### HASHED, SID = 0x6EFAF247DFA6824EA9BA9B3ACC5949E6, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [distributor_admin]
GO

USE master

GO
Grant CONNECT SQL TO [distributor_admin]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'PubsAdmin') CREATE LOGIN [PubsAdmin] WITH PASSWORD = ####### HASHED, SID = 0x14047F8A803493488BAC69F730C6BC6E, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [PubsAdmin]  AS [sa]
GO

USE [pubs]

GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'PubsAdmin')
CREATE USER [PubsAdmin] FOR LOGIN [PubsAdmin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [PubsAdmin]
GO
Grant CONNECT TO [PubsAdmin]  AS [dbo]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'sqladmin') CREATE LOGIN [sqladmin] WITH PASSWORD = ####### HASHED, SID = 0x21A63BA3525821498FDED3037F96A293, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [sqladmin]
GO

USE master

GO
Grant CONNECT SQL TO [sqladmin]  AS [sa]
GO

USE [Validation]

GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dbo')
CREATE USER [dbo] FOR LOGIN [sqladmin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [dbo]
GO
Grant CONNECT TO [sqladmin]  AS [dbo]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'storageuser') CREATE LOGIN [storageuser] WITH PASSWORD = ####### HASHED, SID = 0xEA947BDFB542FC4B816012ADE47D1651, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [storageuser]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'testlogin') CREATE LOGIN [testlogin] WITH PASSWORD = ####### HASHED, SID = 0x7612E56A4CAB2C468A7D24736564C6F7, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [Dansk]
GO

USE master

GO
Grant CONNECT SQL TO [testlogin]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'TestOrphan1') CREATE LOGIN [TestOrphan1] WITH PASSWORD = ####### HASHED, SID = 0xF1BACB136DD3764C9CE200E49041A0C2, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [TestOrphan1]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'TestOrphan2') CREATE LOGIN [TestOrphan2] WITH PASSWORD = ####### HASHED, SID = 0x299C2102F657B4458F75653CB19A54A3, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [TestOrphan2]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'testuser2') CREATE LOGIN [testuser2] WITH PASSWORD = ####### HASHED, SID = 0xF959ADF337EF1149977812AD7969837C, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
ALTER LOGIN [testuser2] DISABLE
GO
DENY CONNECT SQL TO [testuser2]
GO
ALTER SERVER ROLE [setupadmin] ADD MEMBER [testuser2]
GO

USE master

GO
Deny CONNECT SQL TO [testuser2]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'webuser') CREATE LOGIN [webuser] WITH PASSWORD = ####### HASHED, SID = 0x199A7A25579A3E4193A59299130DB683, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [webuser]
GO
ALTER SERVER ROLE [processadmin] ADD MEMBER [webuser]
GO

USE master

GO
Grant CONNECT SQL TO [webuser]  AS [sa]
GO
