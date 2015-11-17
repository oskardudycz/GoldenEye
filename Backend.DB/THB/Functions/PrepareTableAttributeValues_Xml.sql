
CREATE FUNCTION [THB].[PrepareTableAttributeValues_Xml](
	@DataType varchar(100),
	@DataValue nvarchar(MAX))
RETURNS nvarchar(MAX)
AS 
BEGIN
	DECLARE @Result nvarchar(MAX);
	
	SET @DataType = LOWER(@DataType);
	
	IF @DataType = 'int'
	BEGIN
		IF @DataValue IS NOT NULL
			SET @Result = '''<ValInt>' + @DataValue + '</ValInt>''';
		ELSE
			SET @Result = '''<ValInt/>''';
	END
	ELSE IF @DataType = 'bit'
	BEGIN
		IF @DataValue IS NOT NULL
			SET @Result = '''<ValBit>' + @DataValue + '</ValBit>''';
		ELSE
			SET @Result = '''<ValBit/>''';
	END
	ELSE IF @DataType = 'float'
	BEGIN
		IF @DataValue IS NOT NULL
			SET @Result = '''<ValFloat>' + @DataValue + '</ValFloat>''';
		ELSE
			SET @Result = '''<ValFloat/>''';
	END
	ELSE IF @DataType = 'datetime'
	BEGIN
		IF @DataValue IS NOT NULL
			SET @Result = '''<ValDatetime>' + @DataValue + '</ValDatetime>''';
		ELSE
			SET @Result = '''<ValDatetime/>''';
	END
	ELSE IF @DataType = 'date'
	BEGIN
		IF @DataValue IS NOT NULL
			SET @Result = '''<ValDate>' + @DataValue + '</ValDate>''';
		ELSE
			SET @Result = '''<ValDate/>''';
	END
	ELSE IF @DataType = 'time'
	BEGIN
		IF @DataValue IS NOT NULL
			SET @Result = '''<ValTime>' + @DataValue + '</ValTime>''';
		ELSE
			SET @Result = '''<ValTime/>''';
	END
	ELSE IF @DataType LIKE 'decimal%'
	BEGIN
		IF @DataValue IS NOT NULL
			SET @Result = '''<ValDecimal>' + @DataValue + '</ValDecimal>''';
		ELSE
			SET @Result = '''<ValDecimal/>''';
	END
	
	RETURN @Result;
END