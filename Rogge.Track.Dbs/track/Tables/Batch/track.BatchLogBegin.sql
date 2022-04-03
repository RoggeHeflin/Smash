CREATE TABLE [track].[BatchLogBegin]
(
	[BatchLogId]					INT					NOT	NULL	IDENTITY(1, 1) NOT FOR REPLICATION,

	[SchemaName]					NVARCHAR(128)		NOT	NULL,
	[TableName]						NVARCHAR(128)		NOT	NULL,
	[QualifiedName]					AS QUOTENAME([SchemaName]) + N'.' + QUOTENAME([TableName])
									PERSISTED			NOT	NULL,

	[SourceData]					NVARCHAR(128)		NOT	NULL,

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_BatchLogBegin_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSid]					VARBINARY(85)		NOT	NULL	CONSTRAINT [DF_BatchLogBegin_txInsertedSid]				DEFAULT(SUSER_SID()),
	[txInsertedUserOriginal]		NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_BatchLogBegin_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedUserExecute]			NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_BatchLogBegin_txInsertedUserExecute]		DEFAULT(SUSER_SNAME()),
	[txInsertedHost]				NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_BatchLogBegin_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApplication]			NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_BatchLogBegin_txInsertedApplication]		DEFAULT(APP_NAME()),
	[txInsertedProcedure]			NVARCHAR(517)			NULL	CONSTRAINT [DF_BatchLogBegin_txInsertedProcedure]		DEFAULT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID))),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_BatchLogBegin_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_BatchLogBegin]	PRIMARY KEY CLUSTERED([BatchLogId]	ASC)
);