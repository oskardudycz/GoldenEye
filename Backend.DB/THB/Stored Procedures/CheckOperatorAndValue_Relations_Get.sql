-- =============================================
-- Author:		DK
-- Create date: 2012-03-28
-- Last modified on: 2012-08-13
-- Description:	Przygotowanie tekstu dla pojedynczego wyrazenia (operatora i wartosci) dla frazy WHERE
-- =============================================
CREATE PROCEDURE [THB].[CheckOperatorAndValue_Relations_Get]
(
	@AttributeValue nvarchar(255) = NULL,
	@AttributeTypeId int,
	@Operator nvarchar(25),
	@Value nvarchar(255),
	@Result nvarchar(300) OUTPUT
)
AS
BEGIN
	DECLARE @IsOperatorForDigit smallint = 0, -- 0 - operator dla tekstu, 1 - operator dla cyfr, -1 - do analizy przez rzutowanie
			@OperatorSQL varchar(20) = NULL,
			@ValueIsDigit bit = 0,
			@ValueAsInt int = 0,
			@CastRequired bit,
			@CastType varchar(30),			
			@TypCechySQL nvarchar(50)
			
	
	--zamiana wartosci _ na [_] dozwolonej w zapytaniach stringowych
	SET @Value = REPLACE(@Value, '_', '[_]');
	SET @Value = REPLACE(@Value, '%', '[%]');
		
	--zamiana tekstu operatora na operator SQLowy
	SET @OperatorSQL = (SELECT	
		CASE @Operator
			WHEN 'IsEqualTo' THEN '='
			WHEN 'IsNotEqualTo' THEN '<>'
			WHEN 'IsGreaterThan' THEN '>'
			WHEN 'IsGreaterThanOrEqualTo' THEN '>='
			WHEN 'IsLessThan' THEN '<'
			WHEN 'IsLessThanOrEqualTo' THEN '<='
			WHEN 'IsNull' THEN 'IS NULL'
		END
		)
	
	--pobranie typu cechy o podanym ID
	SELECT @TypCechySQL = NazwaSQL FROM Cecha_Typy ct
	JOIN Cechy c ON (c.TypId = ct.Id)
	WHERE c.Cecha_ID = @AttributeTypeId

	SET @CastType = CASE LOWER(@TypCechySQL)
		WHEN 'bit' THEN 'bit'
		WHEN 'int' THEN 'int'
		WHEN 'float' THEN 'float'
		WHEN 'decimal(18,5)' THEN 'decimal(18,5)'
		WHEN 'date' THEN 'date'
		WHEN 'datetime' THEN 'datetime'
		WHEN 'timestamp' THEN 'timestamp'
		WHEN 'time' THEN 'time'
		WHEN 'nvarchar(100)' THEN 'nvarchar(100)'
		WHEN 'char(6)' THEN 'char(6)'
		WHEN 'varbinary(max)' THEN 'varbinary(max)'
		WHEN 'geometry' THEN 'geometry'
		WHEN 'varchar(255)' THEN 'varchar(255)'
	END
	
	IF @CastType LIKE 'varchar%' OR @CastType LIKE 'nvarchar%' OR @CastType LIKE 'char%' OR @CastType LIKE 'nchar%'  
	BEGIN
		SET @CastRequired = 0;
		SET @ValueIsDigit = 0;
	END
	ELSE
	BEGIN
		SET @CastRequired = 1;
		
		IF @CastType LIKE 'date%' OR @CastType LIKE 'time%'
			SET @ValueIsDigit = 0;
		ELSE
			SET @ValueIsDigit = 1;
	END
	
	SET @Result = ' (CechaId = ' + CAST(@AttributeTypeId AS varchar);
	
	--jesli rozpoznano operator SQL w podstawowych
	IF @OperatorSQL IS NOT NULL
	BEGIN
	
		IF @Operator = 'IsNull'
		BEGIN
			SET @Result += ' Value' + @OperatorSQL + ')';
		END
		ELSE
		BEGIN
		
			IF @CastRequired = 1
			BEGIN
				IF @CastType = 'datetime' OR @CastType = 'date'
					SET @Result += ' AND ISDATE(Value) = 1 AND CONVERT(datetime, Value) ' + @OperatorSQL + ' ''' + @Value + ')''';
				ELSE
				BEGIN
					IF LOWER(@CastType) = 'int'
					BEGIN
						SET @Result += ' AND ISNUMERIC(Value) = 1 AND CONVERT(' + @CastType + ', CONVERT(decimal(13,0), Value)) ' + @OperatorSQL + ' ' + @Value + ')'; 
					END
					ELSE
						SET @Result += ' AND ISNUMERIC(Value) = 1 AND CONVERT(' + @CastType + ',  Value) ' + @OperatorSQL + ' ' + @Value + ')'; 
				END				
			END
			ELSE
			BEGIN
				SET @Result += ' AND Value ' + @OperatorSQL + ' ''' + @Value + ''')';
			END
		END
			--SUBSTRING(CAST(Value AS varchar), 1, LEN(Value) - 1))
			--(SELECT C.value(''text()[1]'', ''' + @CastType + ''') FROM SparseValue.nodes(''/*'') AS t(C))
			--CONVERT(' + @CastType + ',  Value) ' + @OperatorSQL + ' ' + @Value + ')';
	END
	ELSE
	BEGIN
		--jesli operator wymaga wywolania funkcji SQL
		IF @Operator = 'Contains'
			SET @Result += ' AND Value LIKE ''%' + @Value + '%'')';
		ELSE IF @Operator = 'DoesNotContain'
			SET @Result += ' AND Value NOT LIKE ''%' + @Value + '%'')';
		ELSE IF @Operator = 'EndsWith'
			SET @Result += ' AND Value LIKE ''%' + @Value + ''')';
		ELSE IF @Operator = 'StartsWith'
			SET @Result += ' AND Value LIKE ''' + @Value + '%'')';
		ELSE IF @Operator = 'IsContainedIn'
			SET @Result += ' AND ' + @Value + ' LIKE ''%' + @AttributeValue + '%'')';
		ELSE IF @Operator = 'IsNotContainedIn'
			SET @Result = ' AND ' + @Value + ' NOT LIKE ''%' + @AttributeValue + '%'')';
	END

END
