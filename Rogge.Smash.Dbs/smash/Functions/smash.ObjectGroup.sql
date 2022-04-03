CREATE FUNCTION [smash].[ObjectGroup]
(
	@Type	VARCHAR(2)
)
RETURNS VARCHAR(40)
WITH SCHEMABINDING
AS
BEGIN

	DECLARE @Return	VARCHAR(40)

	SET @Return = CASE @Type
		WHEN 'AF'	THEN 'Function'
		WHEN 'C'	THEN 'Constraint'
		WHEN 'D'	THEN 'Constraint'
		WHEN 'F'	THEN 'Key: Foreign'

		WHEN 'FN'	THEN 'Function'
		WHEN 'FS'	THEN 'Function'
		WHEN 'FT'	THEN 'Function'
		WHEN 'IF'	THEN 'Function'

		WHEN 'IT'	THEN 'Table'
		WHEN 'P'	THEN 'Stored Procedure'
		WHEN 'PC'	THEN 'Stored Procedure'

		WHEN 'PG'	THEN 'Plan guide'
		WHEN 'PK'	THEN 'Key: Primary'
		WHEN 'R'	THEN 'Rule (old-style, stand-alone)'
		WHEN 'RF'	THEN 'Replication-filter-procedure'
		WHEN 'S'	THEN 'Table'
		WHEN 'SN'	THEN 'Synonym'
		WHEN 'SO'	THEN 'Sequence Object'
		WHEN 'U'	THEN 'Table'
		WHEN 'V'	THEN 'View'
		WHEN 'EC'	THEN 'Constraint'

		-- 'Applies to: SQL Server 2012 (11.x) and later.'
		WHEN 'SQ'	THEN 'Service Queue'
		WHEN 'TA'	THEN 'Trigger'
		WHEN 'TF'	THEN 'Function'
		WHEN 'TR'	THEN 'Trigger'
		WHEN 'TT'	THEN 'Table Type'
		WHEN 'UQ'	THEN 'Constraint'
		WHEN 'X'	THEN 'Stored Procedure'

		-- 'Applies to: SQL Server 2016 (13.x) and later, Azure SQL Database, Azure Synapse Analytics (SQL Data Warehouse), Parallel Data Warehouse.'
		WHEN 'ET'	THEN 'Table'
		END

	RETURN @Return;

END;