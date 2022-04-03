CREATE VIEW [track].[ApplicationLog]
WITH SCHEMABINDING, VIEW_METADATA
AS
SELECT
	[b].[ApplicationLogId],

		[database_id]				= DB_ID(),

		[Instance]					= @@SERVERNAME,
		[InstanceHost]				= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]				= @@SERVICENAME,

		[DatabaseName]				= DB_NAME(),

	[b].[ClassName],
	[b].[FunctionName],

	[b].[ApplicationVersion],
	[b].[ApplicationPlatform],

		[ApplicationUserOriginal]	= [b].[txInsertedUserOriginal],
		[ApplicationUserExecute]	= [b].[txInsertedUserExecute],
		[ApplicationHost]			= [b].[txInsertedHost],
		[ApplicationApplication]	= [b].[txInsertedApplication],

		[ApplicationBegin]			= CONVERT(DATETIME2,	[b].[txInserted]),
		[ApplicationBeginDate]		= CONVERT(DATE,			[b].[txInserted]),
		[ApplicationBeginTime]		= CONVERT(TIME,			[b].[txInserted]),
		[ApplicationBeginZone]		= [b].[txInserted],

		[ApplicationEnd]			= CONVERT(DATETIME2,	[e].[txInserted]),
		[ApplicationEndDate]		= CONVERT(DATE,			[e].[txInserted]),
		[ApplicationEndTime]		= CONVERT(TIME,			[e].[txInserted]),
		[ApplicationEndZone]		= [e].[txInserted],
		
		[ApplicationError]			= CONVERT(DATETIME2,	[r].[txInserted]),
		[ApplicationErrorDate]		= CONVERT(DATE,			[r].[txInserted]),
		[ApplicationErrorTime]		= CONVERT(TIME,			[r].[txInserted]),
		[ApplicationErrorZone]		= [r].[txInserted],
		
		[Duration]					= STUFF(CONVERT(VARCHAR(20), CONVERT(DATETIME, COALESCE([e].[txInserted], [r].[txInserted])) - CONVERT(DATETIME, [b].[txInserted]), 114), 1, 2, 
											DATEDIFF(HOUR, 0,	 CONVERT(DATETIME, COALESCE([e].[txInserted], [r].[txInserted])) - CONVERT(DATETIME, [b].[txInserted]))),

		[DurationDays]				= DATEDIFF(MINUTE, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted])) / 86400.0,
		[DurationMinutes]			= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted])) / 60.0,
		[DurationSeconds]			= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted])),

	[r].[ErrorMessage]

FROM
	[track].[ApplicationLogBegin]		[b]
LEFT OUTER JOIN
	[track].[ApplicationLogEnd]			[e]
		ON	([b].[ApplicationLogId]	=	[e].[ApplicationLogId])
LEFT OUTER JOIN
	[track].[ApplicationLogErrors]		[r]
		ON	([b].[ApplicationLogId]	=	[r].[ApplicationLogId])
LEFT OUTER JOIN
	[track].[ApplicationLogOrphans]		[o]
		ON	([b].[ApplicationLogId]	=	[o].[ApplicationLogId]);