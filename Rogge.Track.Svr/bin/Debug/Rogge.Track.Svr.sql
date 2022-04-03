﻿/*
Deployment script for Rogge.Track.Svr

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar SSISDB "SSISDB"
:setvar DatabaseName "Rogge.Track.Svr"
:setvar DefaultFilePrefix "Rogge.Track.Svr"
:setvar DefaultDataPath "D:\Data SQL Server\Data\"
:setvar DefaultLogPath "D:\Data SQL Server\Log\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
ALTER DATABASE [$(DatabaseName)]
    SET SINGLE_USER 
    WITH ROLLBACK IMMEDIATE
GO
PRINT N'Altering View [track].[SsisCatalogErrors]...';


GO
ALTER VIEW [track].[SsisCatalogErrors]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]			= CHECKSUM(@@SERVERNAME),
	[e].[execution_id],
	[m].[operation_message_id],

		[Instance]				= @@SERVERNAME,
		[InstanceHost]			= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]			= @@SERVICENAME,

		[ServerName]			= [e].[server_name],
		[MachineName]			= [e].[machine_name],

		[FolderName]			= [e].[folder_name],
		[ProjectName]			= [e].[project_name],
		[PackageName]			= REPLACE([e].[package_name], N'.dtsx', N''),

		[UserExecuted]			= [e].[executed_as_name],
		[UserOriginal]			= [e].[caller_name],
		[RunTimeBit]			= CASE [e].[use32bitruntime]
									WHEN 0 THEN 64
									WHEN 1 THEN	32
									END,

		[ObjectType]			= CASE [e].[object_type]
									WHEN   20 THEN 'Project'
									WHEN   30 THEN 'Package'
									END,

		[ExecutionStatus]		= CASE [e].[status]
									WHEN	1 THEN 'Created'
									WHEN	2 THEN 'Running'
									WHEN	3 THEN 'Canceled'
									WHEN	4 THEN 'Failed'
									WHEN	5 THEN 'Pending'
									WHEN	6 THEN 'Ended Unexpectedly'
									WHEN	7 THEN 'Succeeded'
									WHEN	8 THEN 'Stopping'
									WHEN	9 THEN 'Completed'
									END,

		[OperationType]			= CASE [e].[operation_type]
									WHEN	1 THEN 'Integration Services Initialization'
									WHEN	2 THEN 'Retention Window'
									WHEN	3 THEN 'Max Project Version'
									WHEN  101 THEN 'Deploy Project'
									WHEN  106 THEN 'Restore Project'
									WHEN  200 THEN 'Create and Start Execution'
									WHEN  202 THEN 'Stop Operation'
									WHEN  300 THEN 'Validate Project'
									WHEN  301 THEN 'Validate Package'
									WHEN 1000 THEN 'Configure Catalog'
									END,

		[PackageBegin]			= CONVERT(DATETIME2,	[e].[start_time]),
		[PackageBeginDate]		= CONVERT(DATE,			[e].[start_time]),
		[PackageBeginTime]		= CONVERT(TIME,			[e].[start_time]),
		[PackageBeginZone]		= [e].[start_time],

		[MessageSource]			= CASE [m].[message_source_type]
									WHEN   10 THEN 'Entry APIs'
									WHEN   20 THEN 'External Process'
									WHEN   30 THEN 'Package-level Object'
									WHEN   40 THEN 'Control Flow'
									WHEN   50 THEN 'Control Flow Container'
									WHEN   60 THEN 'Data Flow'
									END,

		[MessageType]			= CASE [m].[message_type]
									WHEN   -1 THEN 'Unknown'
									WHEN  120 THEN 'Error'
									WHEN  110 THEN 'Warning'
									WHEN   70 THEN 'Information'
									WHEN   10 THEN 'Pre-validate'
									WHEN   20 THEN 'Post-validate'
									WHEN   30 THEN 'Pre-execute'
									WHEN   40 THEN 'Post-execute'
									WHEN   60 THEN 'Progress'
									WHEN   50 THEN 'Status Change'
									WHEN  100 THEN 'Query Cancel'
									WHEN  130 THEN 'Task Failed'
									WHEN   90 THEN 'Diagnostic'
									WHEN  200 THEN 'Custom'
									WHEN  140 THEN 'Diagnostic Ex'
									WHEN  400 THEN 'NonDiagnostic'
									WHEN   80 THEN 'Variable Value Changed'
									END,

		[MessageMsg]			= CONVERT(DATETIME2,	[m].[message_time]),
		[MessageMsgDate]		= CONVERT(DATE,			[m].[message_time]),
		[MessageMsgTime]		= CONVERT(TIME,			[m].[message_time]),
		[MessageMsgZone]		= [m].[message_time],

		[Message]				= [m].[message]

FROM
	[$(SSISDB)].[catalog].[operation_messages]	[m]
INNER JOIN
	[$(SSISDB)].[catalog].[executions]			[e]
		ON	([m].[operation_id]				=	[e].[execution_id])
WHERE
	([m].[message_type]	IN (110, 120, 130));
GO
ALTER DATABASE [$(DatabaseName)]
    SET MULTI_USER 
    WITH ROLLBACK IMMEDIATE;


GO
PRINT N'Update complete.';


GO
