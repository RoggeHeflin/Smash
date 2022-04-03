CREATE VIEW [track].[BatchLog]
WITH SCHEMABINDING, VIEW_METADATA
AS
SELECT
	[b].[BatchLogId],

		[database_id]				= DB_ID(),

		[Instance]					= @@SERVERNAME,
		[InstanceHost]				= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]				= @@SERVICENAME,

		[DatabaseName]				= DB_NAME(),
	[b].[SchemaName],
	[b].[TableName],
	[b].[SourceData],

		[ApplicationUserOriginal]	= [b].[txInsertedUserOriginal],
		[ApplicationUserExecute]	= [b].[txInsertedUserExecute],
		[ApplicationHost]			= [b].[txInsertedHost],
		[ApplicationApplication]	= [b].[txInsertedApplication],

	[e].[RowCount],
	
		[UpdateBeg]					= CONVERT(DATETIME2,	[e].[UpdateBeg]),
		[UpdateBegDate]				= CONVERT(DATE,			[e].[UpdateBeg]),
		[UpdateBegTime]				= CONVERT(TIME,			[e].[UpdateBeg]),
		[UpdateBegZone]				= [e].[UpdateBeg],

		[UpdateEnd]					= CONVERT(DATETIME2,	[e].[UpdateEnd]),
		[UpdateEndDate]				= CONVERT(DATE,			[e].[UpdateEnd]),
		[UpdateEndTime]				= CONVERT(TIME,			[e].[UpdateEnd]),
		[UpdateEndZone]				= [e].[UpdateEnd],

	[e].[SourceNotes],

		[Duration]					= STUFF(CONVERT(VARCHAR(20),	CONVERT(DATETIME, [e].[txInserted])	- CONVERT(DATETIME, [b].[txInserted]), 114), 1, 2,
											DATEDIFF(HOUR, 0,		CONVERT(DATETIME, [e].[txInserted])	- CONVERT(DATETIME, [b].[txInserted]))),

		[DurationDays]				= DATEDIFF(SECOND, [b].[txInserted], [e].[txInserted]) / 86400.0,
		[DurationMinutes]			= DATEDIFF(SECOND, [b].[txInserted], [e].[txInserted]) / 60.0,
		[DurationSeconds]			= DATEDIFF(SECOND, [b].[txInserted], [e].[txInserted])

FROM
	[track].[BatchLogBegin]			[b]
LEFT OUTER JOIN
	[track].[BatchLogEnd]			[e]
		ON	([b].[BatchLogId]	=	[e].[BatchLogId]);