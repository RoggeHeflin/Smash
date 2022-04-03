CREATE TABLE [track].[ProcedureLogIntermediate]
(
	[ProcedureLogIntermediateId]	INT					NOT	NULL	IDENTITY(1, 1) NOT FOR REPLICATION,

	[ProcedureLogId]				INT					NOT	NULL	CONSTRAINT [FK_ProcedureLogIntermediate_Procedure]					FOREIGN KEY ([ProcedureLogId]) REFERENCES [track].[ProcedureLogBegin]([ProcedureLogId]),

	[ProcedureLineNumber]			INT					NOT	NULL,
	[ProcedureMessage]				VARCHAR(256)		NOT	NULL,

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_ProcedureLogIntermediate_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedProcedure]			NVARCHAR(517)			NULL	CONSTRAINT [DF_ProcedureLogIntermediate_txInsertedProcedure]	DEFAULT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID))),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_ProcedureLogIntermediate_txRowReplication]		DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_ProcedureLogIntermediate]	PRIMARY KEY CLUSTERED([ProcedureLogId] ASC, [ProcedureLogIntermediateId] ASC)
);