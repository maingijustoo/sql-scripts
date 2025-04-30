USE PensionsDB;
GO
EXEC sp_add_job @job_name = 'MonthlyPensionDisbursement';

EXEC sp_add_jobstep @job_name = 'MonthlyPensionDisbursement', 
                    @step_name = 'Process Payments', 
                    @command = 'EXEC ProcessPensionPayments', 
                    @database_name = 'pensionsDB';



--sedning reminder emails and reports
EXEC sp_add_job @job_name = 'SendReminderEmails';
EXEC sp_add_jobstep @job_name = 'SendReminderEmails', @step_name = 'SendEmailsStep',
                    @subsystem = 'TSQL', @command = 'EXEC dbo.SendReminderEmailsProcedure';
EXEC sp_add_schedule @schedule_name = 'DailySchedule', @freq_type = 4, @freq_interval = 1;  -- Daily job

