﻿CREATE VIEW [track].[ProcedureLog]
WITH VIEW_METADATA
AS
SELECT
	[b].[ProcedureLogId],

		[database_id]				= DB_ID(),
	[b].[schema_id],
	[b].[object_id],

		[ServerName]				= @@SERVERNAME,
		[DatabaseName]				= DB_NAME(),
	[b].[SchemaName],
	[b].[ObjectName],
	[b].[QualifiedName],

	[b].[SPID],
	[b].[NestLevel],
	[b].[TransactionCount],

		[ProcedureUserOriginal]		= [b].[txInsertedUserOriginal],
		[ProcedureUserExecute]		= [b].[txInsertedUserExecute],
		[ProcedureHost]				= [b].[txInsertedHost],
		[ProcedureApplication]		= [b].[txInsertedApplication],

		[ProcedureStatus]			= CASE
										WHEN ([e].[txInserted]	IS NOT NULL)	THEN 'Succeeded'
										WHEN ([r].[txInserted]	IS NOT NULL)	THEN 'Failed'
										WHEN ([o].[txInserted]	IS NOT NULL)	THEN 'Ended Unexpectedly'
										ELSE 'Running'
										END,

		[ProcedureBegin]			= CONVERT(DATETIME2,	[b].[txInserted]),
		[ProcedureBeginDate]		= CONVERT(DATE,			[b].[txInserted]),
		[ProcedureBeginTime]		= CONVERT(TIME,			[b].[txInserted]),
		[ProcedureBeginZone]		= [b].[txInserted],

		[ProcedureEnd]				= CONVERT(DATETIME2,	[e].[txInserted]),
		[ProcedureEndDate]			= CONVERT(DATE,			[e].[txInserted]),
		[ProcedureEndTime]			= CONVERT(TIME,			[e].[txInserted]),
		[ProcedureEndZone]			= [e].[txInserted],

		[ProcedureError]			= CONVERT(DATETIME2,	[r].[txInserted]),
		[ProcedureErrorDate]		= CONVERT(DATE,			[r].[txInserted]),
		[ProcedureErrorTime]		= CONVERT(TIME,			[r].[txInserted]),
		[ProcedureErrorZone]		= [r].[txInserted],

		[ProcedureOrphaned]			= CONVERT(DATETIME2,	[o].[txInserted]),
		[ProcedureOrphanedDate]		= CONVERT(DATE,			[o].[txInserted]),
		[ProcedureOrphanedTime]		= CONVERT(TIME,			[o].[txInserted]),
		[ProcedureOrphanedZone]		= [o].[txInserted],

		[Duration]					= STUFF(CONVERT(VARCHAR(20), CONVERT(DATETIME, COALESCE([e].[txInserted], [r].[txInserted])) - CONVERT(DATETIME, [b].[txInserted]), 114), 1, 2,
											DATEDIFF(HOUR, 0,	 CONVERT(DATETIME, COALESCE([e].[txInserted], [r].[txInserted])) - CONVERT(DATETIME, [b].[txInserted]))),

		[DurationDays]				= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted], IIF([o].[txInserted] IS NULL, SYSDATETIMEOFFSET(), NULL))) / 86400.0,
		[DurationMinutes]			= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted], IIF([o].[txInserted] IS NULL, SYSDATETIMEOFFSET(), NULL))) / 60.0,
		[DurationSeconds]			= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted], IIF([o].[txInserted] IS NULL, SYSDATETIMEOFFSET(), NULL))),

	[r].[ErrorNumber],
	[r].[ErrorSeverity],
	[r].[ErrorState],
	[r].[ErrorProcedure],
	[r].[ErrorLine],
	[r].[ErrorMessage],

		[IsWrapper]					= CONVERT(BIT, COALESCE([a].[IsWrapper], 0)),
		[IsDelete]					= CONVERT(BIT, COALESCE([a].[IsDelete], 0))

FROM
	[track].[ProcedureLogBegin]			[b]
LEFT OUTER JOIN
	[track].[ProcedureLogEnd]			[e]
		ON	([b].[ProcedureLogId]	=	[e].[ProcedureLogId])
LEFT OUTER JOIN
	[track].[ProcedureLogErrors]		[r]
		ON	([b].[ProcedureLogId]	=	[r].[ProcedureLogId])
LEFT OUTER JOIN
	[track].[ProcedureLogOrphans]		[o]
		ON	([b].[ProcedureLogId]	=	[o].[ProcedureLogId])
LEFT OUTER JOIN
	[track].[ProcedureAttributes](3)	[a]
		ON	([b].[object_id]		=	[a].[object_id]);