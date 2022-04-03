CREATE FUNCTION [track].[BatchSize]
(
	@ObjectId			INT,
	@MemoryThreshold	FLOAT	= 0.85,
	@TargetRatio		FLOAT	= 1.0
)
RETURNS BIGINT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE	@BatchSize	BIGINT;

	DECLARE	@RowCount	BIGINT;
	DECLARE	@Ratio		FLOAT;

	SELECT
		@RowCount	= MAX([p].[rows]),
		@Ratio		= ROUND(
						((@TargetRatio * [s].[committed_target_kb]) + ((1.0 - @TargetRatio) * [s].[committed_kb])) / 8.0 /
						SUM([a].[total_pages])
						, 3)
	FROM
		sys.sql_expression_dependencies		[d]
	INNER JOIN
		sys.objects							[r]
			ON	([d].[referencing_id]	=	[r].[object_id])
			AND	([r].[type]				=	'P')
	INNER JOIN
		sys.objects							[o]
			ON	([d].[referenced_id]	=	[o].[object_id])
			AND	([o].[is_ms_shipped]	=	0)
	INNER JOIN
		sys.indexes							[i]
			ON	([o].[object_id]		=	[i].[object_id])
			AND	([i].[is_primary_key]	=	1)
	INNER JOIN
		sys.partitions						[p]
			ON	([i].[object_id]		=	[p].[object_id])
			AND	([i].[index_id]			=	[p].[index_id])
	INNER JOIN
		sys.allocation_units				[a]
			ON	([p].[partition_id]		=	[a].[container_id])
	CROSS JOIN
		sys.dm_os_sys_info					[s]
	WHERE
			([d].[referencing_id]	=	@ObjectId)
		AND	NOT (
				([o].[name]			= LEFT([r].[name], LEN([o].[name])))
			AND	([o].[schema_id]	= [r].[schema_id])
			)
	GROUP BY
		[s].[committed_kb],
		[s].[committed_target_kb];

	SET	@BatchSize = CEILING(@Rowcount * 
			CASE WHEN ((@Ratio - 1.0) > (1.0 - @MemoryThreshold))
			THEN	1.0
			ELSE	CASE WHEN (@Ratio < @MemoryThreshold)
						THEN @Ratio
						ELSE @MemoryThreshold
						END
			END)

	RETURN	@BatchSize;

END;