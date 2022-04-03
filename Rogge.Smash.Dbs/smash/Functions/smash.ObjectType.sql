CREATE FUNCTION [smash].[ObjectType]
(
	@Type	VARCHAR(2)
)
RETURNS VARCHAR(40)
WITH SCHEMABINDING
AS
BEGIN

	DECLARE @Return	VARCHAR(40)

	SET @Return = CASE @Type
		WHEN 'AF'	THEN 'Function: Aggregate CLR'
		WHEN 'C'	THEN 'Constraint: Check'
		WHEN 'D'	THEN 'Constraint: Default'
		WHEN 'F'	THEN 'Constraint: Key: Foreign'

		WHEN 'FN'	THEN 'Function: SQL Scalar'
		WHEN 'FS'	THEN 'Function: CLR Assembly Scalar'
		WHEN 'FT'	THEN 'Function: CLR Assembly Table-valued'
		WHEN 'IF'	THEN 'Function: SQL Inline Table-valued'

		WHEN 'IT'	THEN 'Table: Internal'
		WHEN 'P'	THEN 'Stored Procedure: SQL'
		WHEN 'PC'	THEN 'Stored Procedure: CLR'

		WHEN 'PG'	THEN 'Plan Guide'
		WHEN 'PK'	THEN 'Constraint: Key: Primary'
		WHEN 'R'	THEN 'Rule (old-style, stand-alone)'
		WHEN 'RF'	THEN 'Replication-filter-procedure'
		WHEN 'S'	THEN 'Table: System Base'
		WHEN 'SN'	THEN 'Synonym'
		WHEN 'SO'	THEN 'Sequence Object'
		WHEN 'U'	THEN 'Table: User Defined'
		WHEN 'V'	THEN 'View'
		WHEN 'EC'	THEN 'Constraint: Edge'

		-- 'Applies to: SQL Server 2012 (11.x) and later.'
		WHEN 'SQ'	THEN 'Service Queue'
		WHEN 'TA'	THEN 'Trigger: Assembly (CLR) DML'
		WHEN 'TF'	THEN 'Function: SQL Table-valued'
		WHEN 'TR'	THEN 'Trigger: SQL DML'
		WHEN 'TT'	THEN 'Table Type'
		WHEN 'UQ'	THEN 'Constraint: Unique'
		WHEN 'X'	THEN 'Stored Procedure: Extended'

		-- 'Applies to: SQL Server 2016 (13.x) and later, Azure SQL Database, Azure Synapse Analytics (SQL Data Warehouse), Parallel Data Warehouse.'
		WHEN 'ET'	THEN 'Table: External'
		END

	RETURN @Return;

END;