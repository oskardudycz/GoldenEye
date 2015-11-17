
-----------------------------------------------------------------------------------
CREATE PROCEDURE [Tmp].[ChangeTableStructure]
(
	@TableName nvarchar(300),
	@ColumnName nvarchar(300),
	@ColumnType varchar(100)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query nvarchar(MAX)
	
	SET @Query = '
		IF [THB].[ColumnExists] (''_' + @TableName + ''', ''' + @ColumnName + ''') = 0
		BEGIN
			ALTER TABLE [_' + @TableName + ']
			ADD [' + @ColumnName + '] ' + @ColumnType + ' NULL
		END'
	
	--PRINT @Query
	EXECUTE sp_executesql @Query;
	
END

