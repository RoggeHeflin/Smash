CREATE TABLE [track].[ProcedureLogOrphans]
(
	[ProcedureLogId]				INT					NOT	NULL	CONSTRAINT [FK_ProcedureLogOrphans_Procedure]				FOREIGN KEY ([ProcedureLogId]) REFERENCES [track].[ProcedureLogBegin]([ProcedureLogId]),

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_ProcedureLogOrphans_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSid]					VARBINARY(85)		NOT	NULL	CONSTRAINT [DF_ProcedureLogOrphans_txInsertedSid]			DEFAULT(SUSER_SID()),
	[txInsertedUserOriginal]		NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ProcedureLogOrphans_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedUserExecute]			NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ProcedureLogOrphans_txInsertedUserExecute]	DEFAULT(SUSER_SNAME()),
	[txInsertedHost]				NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ProcedureLogOrphans_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApplication]			NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ProcedureLogOrphans_txInsertedApplication]	DEFAULT(APP_NAME()),
	[txInsertedProcedure]			NVARCHAR(517)			NULL	CONSTRAINT [DF_ProcedureLogOrphans_txInsertedProcedure]		DEFAULT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID))),

	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_ProcedureLogOrphans_txRowReplication]		DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_ProcedureLogOrphans]		PRIMARY KEY CLUSTERED([ProcedureLogId] ASC)
);