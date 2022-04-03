CREATE FUNCTION [smash].[DoesIndexExist]
(
	@Schema		NVARCHAR(128),
	@Table		NVARCHAR(128),
	@Index		NVARCHAR(128)
)
RETURNS INT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE	@Exists		INT;

	SELECT TOP (1)
		@Exists = 1
	FROM
		sys.schemas						[s]	WITH (NOLOCK)
	INNER JOIN
		sys.tables						[t]	WITH (NOLOCK)
			ON	([s].[schema_id]	=	[t].[schema_id])
	INNER JOIN
		sys.indexes						[i]	WITH (NOLOCK)
			ON	([t].[object_id]	=	[i].[object_id])
	WHERE
			([s].[name]	= @Schema)
		AND	([t].[name]	= @Table)
		AND	([i].[name]	= @Index);

	RETURN COALESCE(@Exists, 0);

END;