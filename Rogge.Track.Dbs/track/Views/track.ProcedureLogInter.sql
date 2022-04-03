CREATE VIEW [track].[ProcedureLogInter]
WITH SCHEMABINDING, VIEW_METADATA
AS
SELECT
	[b].[ProcedureLogId],

		[database_id]				= DB_ID(),
	[b].[schema_id],
	[b].[object_id],

		[Instance]					= @@SERVERNAME,
		[InstanceHost]				= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]				= @@SERVICENAME,

		[DatabaseName]				= DB_NAME(),
	[b].[SchemaName],
	[b].[ObjectName],
	[b].[QualifiedName],

		[ProcedureSPID]				= [b].[SPID],
		[ProcedureNestLevel]		= [b].[NestLevel],
		[ProcedureTranCount]		= [b].[TransactionCount],

		[ApplicationUserOriginal]	= [b].[txInsertedUserOriginal],
		[ApplicationUserExecute]	= [b].[txInsertedUserExecute],
		[ProcedureHost]				= [b].[txInsertedHost],
		[ProcedureApplication]		= [b].[txInsertedApplication],

		[ProcedureBeg]				= [b].[txInserted],

		[SegmentEnd]				= [i].[txInserted],

		[DurationMinutes]			= DATEDIFF(SECOND,
										LAG([i].[txInserted], 1, [b].[txInserted]) OVER(PARTITION BY [b].[ProcedureLogId] ORDER BY [i].[txInserted], [i].[ProcedureLogIntermediateId]),
										[i].[txInserted]
										) / 60.0,
		[DurationSeconds]			= DATEDIFF(SECOND,
										LAG([i].[txInserted], 1, [b].[txInserted]) OVER(PARTITION BY [b].[ProcedureLogId] ORDER BY [i].[txInserted], [i].[ProcedureLogIntermediateId]),
										[i].[txInserted]
										),

	[i].[ProcedureLineNumber],
	[i].[ProcedureMessage]

FROM
	[track].[ProcedureLogBegin]			[b]
LEFT OUTER JOIN
	[track].[ProcedureLogIntermediate]	[i]
		ON	([b].[ProcedureLogId]	=	[i].[ProcedureLogId]);