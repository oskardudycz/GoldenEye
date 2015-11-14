
CREATE FUNCTION [THB].[PrepareTableAttributeValues_String](
	@DataType varchar(100),
	@DataValue nvarchar(MAX))
RETURNS nvarchar(MAX)
AS 
BEGIN
	DECLARE @Result nvarchar(MAX);
	
	SET @DataType = LOWER(@DataType);
	
	IF @DataType LIKE '%char%'
	BEGIN
		SET @Result = @DataValue; 
	END
	ELSE
	BEGIN
		SET @Result = NULL;
	END
	
	RETURN @Result;
END