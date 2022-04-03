CREATE FUNCTION [track].[ProcedureAttributes]
(
	@ExecuteThreshold	INT	=	3
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[t].[object_id],

		[t].[SchemaName],
		[t].[ObjectName],
			[QualifiedName]	= QUOTENAME([t].[SchemaName]) + N'.' + QUOTENAME([t].[ObjectName]),

			[IsWrapper]		= CONVERT(BIT, CASE WHEN ([track].[StringOccuranceCount]('EXEC', [t].[SqlDef]) > @ExecuteThreshold)
								THEN 1
								ELSE 0
								END),

			[IsDelete]		= CONVERT(BIT, CASE WHEN ([t].[SqlDef] LIKE '%DELETE%FROM%')
								THEN 1
								ELSE 0
								END)
	FROM (
		SELECT
			[p].[object_id],
				[SchemaName]	= [s].[name],
				[ObjectName]	= [p].[name],
				[SqlDef]		= OBJECT_DEFINITION([p].[object_id])
		FROM
			sys.schemas						[s]
		INNER JOIN
			sys.procedures					[p]
				ON	([s].[schema_id]	=	[p].[schema_id])
		) [t]
);