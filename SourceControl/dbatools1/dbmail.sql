EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'AccountRetryAttempts', @parameter_value=N'1', @description=N'Number of retry attempts for a mail server'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'AccountRetryDelay', @parameter_value=N'60', @description=N'Delay between each retry attempt to mail server'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'DatabaseMailExeMinimumLifeTime', @parameter_value=N'600', @description=N'Minimum process lifetime in seconds'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'DefaultAttachmentEncoding', @parameter_value=N'MIME', @description=N'Default attachment encoding'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'LoggingLevel', @parameter_value=N'2', @description=N'Database Mail logging level: normal - 1, extended - 2 (default), verbose - 3'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'MaxFileSize', @parameter_value=N'1000000', @description=N'Default maximum file size'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'ProhibitedExtensions', @parameter_value=N'exe,dll,vbs,js', @description=N'Extensions not allowed in outgoing mails'
GO

EXEC msdb.dbo.sysmail_add_account_sp @account_name=N'The DBA Team', 
		@email_address=N'dbadistro@ad.local', 
		@display_name=N'The DBA Team'
GO

EXEC msdb.dbo.sysmail_add_profile_sp @profile_name=N'The DBA Team'
GO

EXEC msdb.dbo.sysmail_add_profileaccount_sp @profile_name=N'The DBA Team', @account_name=N'The DBA Team', @sequence_number=1
GO

EXEC msdb.dbo.sysmail_add_principalprofile_sp @principal_name=N'guest', @profile_name=N'The DBA Team', @is_default=1
GO

EXEC msdb.dbo.sysmail_update_account_sp @account_name=N'The DBA Team', @description=N'', @email_address=N'dbadistro@ad.local', @display_name=N'The DBA Team', @replyto_address=N'', @mailserver_name=N'smtp.ad.local', @mailserver_type=N'SMTP', @port=25, @username=N'', @password=N'', @use_default_credentials=0, @enable_ssl=0
GO

