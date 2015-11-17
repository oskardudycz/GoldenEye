-- =============================================
-- Author:		DK
-- Description:	Pobiera Id branz do ktorych uzytkownik ma uprawnienia/dostep.
-- =============================================
CREATE PROCEDURE [THB].[PrepareTableAttributeValues]
(
	@DataType varchar(100),
	@DataValue nvarchar(MAX),
	@StringValue nvarchar(MAX) OUTPUT,
	@XmlValue nvarchar(500) OUTPUT
)
AS
BEGIN
	SET @DataType = LOWER(@DataType);

	IF @DataType = 'int'
	BEGIN
		SET @StringValue = 'NULL';
		SET @XmlValue = '''<ValInt>' + @DataValue + '</ValInt>''';
	END
	ELSE IF @DataType = 'bit'
	BEGIN
		SET @StringValue = 'NULL';
		SET @XmlValue = '''<ValBit>' + @DataValue + '</ValBit>''';
	END
	ELSE IF @DataType = 'float'
	BEGIN
		SET @StringValue = 'NULL';
		SET @XmlValue = '''<ValFloat>' + @DataValue + '</ValFloat>''';
	END
	ELSE IF @DataType = 'datetime'
	BEGIN
		SET @StringValue = 'NULL';
		SET @XmlValue = '''<ValDatetime>' + @DataValue + '</ValDatetime>''';
	END
	ELSE IF @DataType = 'date'
	BEGIN
		SET @StringValue = 'NULL';
		SET @XmlValue = '''<ValDate>' + @DataValue + '</ValDate>''';
	END
	ELSE IF @DataType = 'time'
	BEGIN
		SET @StringValue = 'NULL';
		SET @XmlValue = '''<ValTime>' + @DataValue + '</ValTime>''';
	END
	ELSE IF @DataType LIKE 'decimal%'
	BEGIN
		SET @StringValue = 'NULL';
		SET @XmlValue = '''<ValDecimal>' + @DataValue + '</ValDecimal>''';
	END
	ELSE IF @DataType LIKE '%char%'
	BEGIN
		SET @StringValue = @DataValue; 
		SET @XmlValue = 'NULL';
	END


END