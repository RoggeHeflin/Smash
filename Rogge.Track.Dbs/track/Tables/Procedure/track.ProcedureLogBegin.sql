CREATE TABLE [track].[ProcedureLogBegin]
(
	[ProcedureLogId]				INT					NOT	NULL	IDENTITY(1, 1) NOT FOR REPLICATION,

	[schema_id]						INT					NOT	NULL,
	[object_id]						INT					NOT	NULL,

	[SchemaName]					NVARCHAR(128)		NOT	NULL	CONSTRAINT [CL_ProcedureLogBegin_SchemaName]				CHECK([SchemaName] <> N''),
	[ObjectName]					NVARCHAR(128)		NOT	NULL	CONSTRAINT [CL_ProcedureLogBegin_ObjectName]				CHECK([ObjectName] <> N''),
	[QualifiedName]					AS QUOTENAME([SchemaName]) + N'.' + QUOTENAME([ObjectName])
									PERSISTED			NOT	NULL,

	[SPID]							SMALLINT			NOT	NULL,
	[NestLevel]						INT					NOT	NULL,
	[TransactionCount]				INT					NOT	NULL,

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_ProcedureLogBegin_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSid]					VARBINARY(85)		NOT	NULL	CONSTRAINT [DF_ProcedureLogBegin_txInsertedSid]				DEFAULT(SUSER_SID()),
	[txInsertedUserOriginal]		NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ProcedureLogBegin_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedUserExecute]			NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ProcedureLogBegin_txInsertedUserExecute]		DEFAULT(SUSER_SNAME()),
	[txInsertedHost]				NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ProcedureLogBegin_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApplication]			NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ProcedureLogBegin_txInsertedApplication]		DEFAULT(APP_NAME()),
	[txInsertedProcedure]			NVARCHAR(517)			NULL	CONSTRAINT [DF_ProcedureLogBegin_txInsertedProcedure]		DEFAULT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID))),

	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_ProcedureLogBegin_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_ProcedureLogBegin]	PRIMARY KEY CLUSTERED([ProcedureLogId]	ASC)
);