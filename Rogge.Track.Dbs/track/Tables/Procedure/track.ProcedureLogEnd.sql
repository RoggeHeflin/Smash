CREATE TABLE [track].[ProcedureLogEnd]
(
	[ProcedureLogId]				INT					NOT	NULL	CONSTRAINT [FK_ProcedureLogEnd_Procedure]				FOREIGN KEY ([ProcedureLogId]) REFERENCES [track].[ProcedureLogBegin]([ProcedureLogId]),

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_ProcedureLogEnd_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_ProcedureLogEnd_txRowReplication]		DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_ProcedureLogEnd]	PRIMARY KEY CLUSTERED([ProcedureLogId] ASC)
);