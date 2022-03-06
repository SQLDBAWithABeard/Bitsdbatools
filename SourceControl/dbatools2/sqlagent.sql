EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'MULTI-SERVER', @name=N'[Uncategorized (Multi-Server)]'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Engine Tuning Advisor'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Full-Text'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Jobs from MSX'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Log Shipping'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-Alert Response'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-Checkup'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-Distribution'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-Distribution Cleanup'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-History Cleanup'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-LogReader'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-Merge'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-QueueReader'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-Snapshot'
GO

EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'REPL-Subscription Cleanup'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'CollectorSchedule_Every_10min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220112, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'83e99796-6d0a-4402-bb61-1ca6c6602a95'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'CollectorSchedule_Every_15min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220112, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0faf8b50-5e8b-401f-b472-84016a6d6bf7'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'CollectorSchedule_Every_30min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220112, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'f5d1d0b4-5ada-438d-84ad-11fda7a85295'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'CollectorSchedule_Every_5min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220112, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'03f8fd7a-3b50-4e44-b2bf-6e0aedc59b55'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'CollectorSchedule_Every_60min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=60, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220112, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'052bb876-4225-4b4c-a1ee-00cdb93c1634'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'CollectorSchedule_Every_6h', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=6, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220112, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'89d0974d-2560-4f71-9405-d8647a410217'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'RunAsSQLAgentServiceStartSchedule', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220112, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'70359230-9aea-4547-9f8e-be2ef32bebb3'
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'IamBroke', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sqladmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step One', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Select * from MissingTable', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

