CREATE TABLE [track].[ApplicationLogOrphans]
(
	[ApplicationLogId]				INT					NOT	NULL	CONSTRAINT [FK_ApplicationLogOrphans_Application]				FOREIGN KEY ([ApplicationLogId]) REFERENCES [track].[ApplicationLogBegin]([ApplicationLogId]),

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_ApplicationLogOrphans_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSid]					VARBINARY(85)		NOT	NULL	CONSTRAINT [DF_ApplicationLogOrphans_txInsertedSid]				DEFAULT(SUSER_SID()),
	[txInsertedUserOriginal]		NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ApplicationLogOrphans_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedUserExecute]			NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ApplicationLogOrphans_txInsertedUserExecute]		DEFAULT(SUSER_SNAME()),
	[txInsertedHost]				NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ApplicationLogOrphans_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApplication]			NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ApplicationLogOrphans_txInsertedApplication]		DEFAULT(APP_NAME()),

	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_ApplicationLogOrphans_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_ApplicationLogOrphans]		PRIMARY KEY CLUSTERED([ApplicationLogId] ASC)
);