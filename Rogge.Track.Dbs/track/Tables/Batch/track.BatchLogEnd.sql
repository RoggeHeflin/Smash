CREATE TABLE [track].[BatchLogEnd]
(
	[BatchLogId]					INT					NOT	NULL	CONSTRAINT [FK_BatchLogEnd_Batch]					FOREIGN KEY ([BatchLogId]) REFERENCES [track].[BatchLogBegin]([BatchLogId]),

	[UpdateBeg]						DATETIMEOFFSET(7)	NOT	NULL,
	[UpdateEnd]						DATETIMEOFFSET(7)		NULL,

	[RowCount]						INT					NOT	NULL,
	[SourceNotes]					VARCHAR(MAX)		NOT	NULL,

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_BatchLogEnd_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_BatchLogEnd_txRowReplication]		DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_BatchLogEnd]		PRIMARY KEY CLUSTERED([BatchLogId]	ASC)
);