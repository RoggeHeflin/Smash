CREATE TABLE [track].[ApplicationLogErrors]
(
	[ApplicationLogId]				INT					NOT	NULL	CONSTRAINT [FK_ApplicationLogErrors_Application]				FOREIGN KEY ([ApplicationLogId]) REFERENCES [track].[ApplicationLogBegin]([ApplicationLogId]),

	--[ErrorNumber]					INT					NOT	NULL,
	--[ErrorSeverity]					INT					NOT	NULL,
	--[ErrorState]					INT					NOT	NULL,
	--[ErrorProcedure]				NVARCHAR(128)		NOT	NULL,	CONSTRAINT [CL_ApplicationLogErrors_ErrorProcedure]			CHECK([ErrorProcedure] <> ''),
	--[ErrorLine]						INT					NOT	NULL,
	[ErrorMessage]					NVARCHAR(MAX)		NOT	NULL,	CONSTRAINT [CL_ApplicationLogErrors_ErrorMessage]				CHECK([ErrorMessage] <> N''),

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT [DF_ApplicationLogErrors_txInserted]					DEFAULT(SYSDATETIMEOFFSET()),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT [DF_ApplicationLogErrors_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,
	
	CONSTRAINT [PK_ApplicationLogErrors]	PRIMARY KEY CLUSTERED([ApplicationLogId] ASC)
);