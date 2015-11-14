  CREATE FUNCTION [THB].[ColumnExists](@TableName varchar(300), @ColumnName nvarchar(300))
Returns Bit
As 
Begin

	DECLARE @exists bit
  
	IF EXISTS (SELECT * FROM Information_SCHEMA.columns WHERE Table_name = @TableName and column_name = @ColumnName)
		SET @exists = 1;
	ELSE
		SET @exists = 0;

	RETURN @exists;
End