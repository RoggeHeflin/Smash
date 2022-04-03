CREATE TABLE [track].[ProcedureLogErrors]
(
	[ProcedureLogId]				INT					NOT	NULL	CONSTRAINT [FK_ProcedureLogErrors_Procedure]				FOREIGN KEY ([ProcedureLogId]) REFERENCES [track].[ProcedureLogBegin]([ProcedureLogId]),

	[ErrorNumber]					INT					NOT	NULL,
	[ErrorSeverity]					INT					NOT	NULL,
	[ErrorState]					INT					NOT	NULL,
	[ErrorProcedure]				NVARCHAR(128)		NOT	NULL,	CONSTRAINT [CL_ProcedureLogErrors_ErrorProcedure]			CHECK([ErrorProcedure] <> N''),
	[ErrorLine]						INT					NOT	NULL,
	[ErrorMessage]					NVARCHAR(MAX)		NOT	NULL,	CONSTRAINT [CL_ProcedureLogErrors_ErrorMessage]				CHECK([ErrorMessage] <> N''),

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_ProcedureLogErrors_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_ProcedureLogErrors_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_ProcedureLogErrors]	PRIMARY KEY CLUSTERED([ProcedureLogId] ASC)
);