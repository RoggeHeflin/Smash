CREATE TABLE [track].[ApplicationLogBegin]
(
	[ApplicationLogId]				INT					NOT	NULL	IDENTITY(1, 1) NOT FOR REPLICATION,

	[ClassName]						VARCHAR(128)		NOT	NULL,
	[FunctionName]					VARCHAR(128)		NOT	NULL,

	[ApplicationVersion]			VARCHAR(128)		NOT	NULL,
	[ApplicationPlatform]			VARCHAR(128)		NOT	NULL,

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_ApplicationLogBegin_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSid]					VARBINARY(85)		NOT	NULL	CONSTRAINT [DF_ApplicationLogBegin_txInsertedSid]			DEFAULT(SUSER_SID()),
	[txInsertedUserOriginal]		NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ApplicationLogBegin_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedUserExecute]			NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ApplicationLogBegin_txInsertedUserExecute]	DEFAULT(SUSER_SNAME()),
	[txInsertedHost]				NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ApplicationLogBegin_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApplication]			NVARCHAR(128)		NOT	NULL	CONSTRAINT [DF_ApplicationLogBegin_txInsertedApplication]	DEFAULT(APP_NAME()),

	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_ApplicationLogBegin_txRowReplication]		DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_ApplicationLogBegin]	PRIMARY KEY CLUSTERED([ApplicationLogId]	ASC)
);