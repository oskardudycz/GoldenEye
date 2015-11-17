CREATE PROCEDURE dbo.Database_Identity_Reseed
AS
BEGIN
DECLARE @TableName sysname = N''
DECLARE @ColumnName sysname = N''
DECLARE @NewSeed bigint = 0
DECLARE @SQL nvarchar(4000) = N''
 
-- find all non-system tables and load into a cursor
DECLARE IdentityTables CURSOR FAST_FORWARD
FOR
    SELECT  TableName = N'['+c.TABLE_SCHEMA+']'+ + N'.[' + t.TABLE_NAME+']'
          , c.COLUMN_NAME
    FROM    INFORMATION_SCHEMA.COLUMNS AS c
            INNER JOIN INFORMATION_SCHEMA.TABLES AS t ON t.TABLE_NAME = c.TABLE_NAME
                                                         AND t.TABLE_SCHEMA = c.TABLE_SCHEMA
    WHERE   COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') = 1
            AND t.TABLE_TYPE = 'Base Table'
 
OPEN IdentityTables
 
FETCH NEXT FROM IdentityTables INTO @TableName, @ColumnName
WHILE @@FETCH_STATUS = 0 
    BEGIN
	-- find the max value of the identity column in the table, use 1 if there are no rows
        PRINT '*********** Start for the table '  +@TableName + ' and column: '+@ColumnName
		
		
		SET @SQL = N'SELECT @NewSeed_out = ISNULL(MAX([' + @ColumnName + ']), 0) FROM ' + @TableName
		PRINT @SQL
        EXECUTE sys.sp_executesql @SQL, N'@NewSeed_out bigint OUTPUT', @NewSeed_out = @NewSeed OUTPUT
 
	-- reseed the identity with the max value found in the previous step, SQL Server will automatically pick up at the next value
        SET @SQL = N'DBCC CHECKIDENT(''' + @TableName + ''', RESEED, ' + CAST(@NewSeed AS varchar(25)) + ')'
        PRINT @SQL
        EXECUTE (@SQL)

		PRINT '*********** End for the table '  +@TableName + ' and column: '+@ColumnName
        FETCH NEXT FROM IdentityTables INTO @TableName, @ColumnName
    END
 
DEALLOCATE IdentityTables
END
