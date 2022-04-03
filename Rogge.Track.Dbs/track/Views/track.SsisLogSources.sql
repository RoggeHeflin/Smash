CREATE VIEW [track].[SsisLogSource]
WITH SCHEMABINDING, VIEW_METADATA
AS
SELECT
		[Instance]			= @@SERVERNAME,
		[InstanceHost]		= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]		= @@SERVICENAME,

		[LogDetailId]		= MIN([SsisLogDetailId]),

		[Package]			= [t].[txInsertedApp],
		[PackageName]		= CASE WHEN ([t].[txInsertedApp] LIKE N'%(%)')
								THEN LEFT([t].[txInsertedApp], CHARINDEX(' (', [t].[txInsertedApp]) - 1)
								ELSE [t].[txInsertedApp]
								END,
		[PackageVersion]	= CASE WHEN ([t].[txInsertedApp] LIKE N'%(%)')
								THEN REPLACE(RIGHT([t].[txInsertedApp], LEN([t].[txInsertedApp]) - CHARINDEX(' (', [t].[txInsertedApp]) - 1), ')', '')
								ELSE CONVERT(VARCHAR, NULL)
								END,

		[SourceName]		= [t].[Source],

		[SourceBeg]			= MIN([t].[EventBeg]),
		[SourceBegDate]		= CONVERT(DATE,	MIN([t].[EventBeg])),
		[SourceBegTime]		= CONVERT(TIME, MIN([t].[EventBeg])),

		[SourceEnd]			= MAX([t].[EventEnd]),
		[SourceEndDate]		= CONVERT(DATE, MAX([t].[EventEnd])),
		[SourceEndTime]		= CONVERT(TIME, MAX([t].[EventEnd])),

		[Duration]					= STUFF(CONVERT(VARCHAR(20), CONVERT(DATETIME, MAX([t].[EventEnd])) - CONVERT(DATETIME, MIN([t].[EventBeg])), 114), 1, 2,
											DATEDIFF(HOUR, 0,	 CONVERT(DATETIME, MAX([t].[EventEnd])) - CONVERT(DATETIME, MIN([t].[EventBeg])))),

		[DurationDays]		= DATEDIFF(SECOND, MIN([t].[EventBeg]), MAX([t].[EventBeg])) / 86400.0,
		[DurationMinutes]	= DATEDIFF(SECOND, MIN([t].[EventBeg]), MAX([t].[EventBeg])) / 60.0,
		[DurationSeconds]	= DATEDIFF(SECOND, MIN([t].[EventBeg]), MAX([t].[EventBeg])),

		[Errors]			= COUNT(CASE WHEN ([t].[Event]	= 'OnError')		THEN 1 END),
		[Warnings]			= COUNT(CASE WHEN ([t].[Event]	= 'OnWarning')		THEN 1 END),
		[Information]		= COUNT(CASE WHEN ([t].[Event]	= 'OnInformation')	THEN 1 END),
		[TasksFailed]		= COUNT(CASE WHEN ([t].[Event]	= 'OnTaskFailed')	THEN 1 END),

		[SourceEvents]		= COUNT(*),

	[t].[Computer],
	[t].[Operator],
	[t].[ExecutionId],

	[t].[txInsertedSid],
	[t].[txInsertedUserOriginal],
	[t].[txInsertedUserExecute],
	[t].[txInsertedHost],
	[t].[txInsertedApp]
FROM
	[track].[SsisLogDetail]	[t]
GROUP BY
	[t].[Source],
	[t].[Computer],
	[t].[Operator],
	[t].[ExecutionId],
	[t].[txInsertedSid],
	[t].[txInsertedUserOriginal],
	[t].[txInsertedUserExecute],
	[t].[txInsertedHost],
	[t].[txInsertedApp];