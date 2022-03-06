EXEC master.dbo.sp_addmessage @msgnum=60000, @lang=N'us_english', 
		@severity=16, 
		@msgtext=N'The item named %s already exists in %s.', 
		@with_log=false
GO

