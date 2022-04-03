CREATE TABLE [track].[ApplicationLogEnd]
(
	[ApplicationLogId]				INT					NOT	NULL	CONSTRAINT [FK_ApplicationLogEnd_Application]				FOREIGN KEY ([ApplicationLogId]) REFERENCES [track].[ApplicationLogBegin]([ApplicationLogId]),

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_ApplicationLogEnd_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_ApplicationLogEnd_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_ApplicationLogEnd]	PRIMARY KEY CLUSTERED([ApplicationLogId]	ASC)
);