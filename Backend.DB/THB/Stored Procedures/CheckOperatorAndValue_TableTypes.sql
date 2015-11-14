-- =============================================
-- Author:		DK
-- Create date: 2013-04-21
-- Last modified on: 2013-06-04
-- Description:	Przygotowanie tekstu dla pojedynczego wyrazenia (operatora i wartosci) dla frazy WHERE
-- =============================================
CREATE PROCEDURE [THB].[CheckOperatorAndValue_TableTypes]
(
	@AttributeTypeId int,
	@AttributeTypeName nvarchar(500),
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
	
	SET @AttributeTypeName = REPLACE(@AttributeTypeName, '[', '');
	SET @AttributeTypeName = REPLACE(@AttributeTypeName, ']', '');
	SET @AttributeTypeName = '[' + @AttributeTypeName + ']';
	
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
	
	SET @Result = '('; --' (CechaId = ' + CAST(@AttributeTypeId AS varchar);
	
	--jesli rozpoznano operator SQL w podstawowych
	IF @OperatorSQL IS NOT NULL
	BEGIN	
		
		IF @Operator = 'IsNull'
		BEGIN
			SET @Result += ' ' + @AttributeTypeName + ' ' + @OperatorSQL + ')';
		END
		ELSE
		BEGIN
			IF @CastRequired = 1
			BEGIN
				IF @CastType = 'datetime' OR @CastType = 'date'
					SET @Result += ' ISDATE(' + @AttributeTypeName + ') = 1 AND CONVERT(datetime, ' + @AttributeTypeName + ') ' + @OperatorSQL + ' ''' + @Value + ''')';
				ELSE
				BEGIN
					IF LOWER(@CastType) = 'int'
					BEGIN
						--SET @Result += ' ISNUMERIC(' + @AttributeTypeName + ') = 1 AND CONVERT(' + @CastType + ', CONVERT(decimal(13,0), ' + @AttributeTypeName + ')) ' + @OperatorSQL + ' ' + @Value + ')'; 
						SET @Result +=  @AttributeTypeName + ' ' + @OperatorSQL + ' ' + @Value + ')'; 
					END
					ELSE
						SET @Result += ' CONVERT(' + @CastType + ',  ' + @AttributeTypeName + ') ' + @OperatorSQL + ' ' + @Value + ')'; 
				END				
			END
			ELSE
			BEGIN
				SET @Result += ' ' + @AttributeTypeName + ' ' + @OperatorSQL + ' ''' + @Value + ''')';
			END
		END
	END
	ELSE
	BEGIN
		--jesli operator wymaga wywolania funkcji SQL
		IF @Operator = 'Contains'
			SET @Result += ' ' + @AttributeTypeName + ' LIKE ''%' + @Value + '%'')';
		ELSE IF @Operator = 'DoesNotContain'
			SET @Result += ' ' + @AttributeTypeName + ' NOT LIKE ''%' + @Value + '%'')';
		ELSE IF @Operator = 'EndsWith'
			SET @Result += ' ' + @AttributeTypeName + ' LIKE ''%' + @Value + ''')';
		ELSE IF @Operator = 'StartsWith'
			SET @Result += ' ' + @AttributeTypeName + ' LIKE ''' + @Value + '%'')';
		ELSE IF @Operator = 'IsContainedIn'
			SET @Result += ' ' + @Value + ' LIKE ''%' + @AttributeTypeName + '%'')';  --@AttributeValue
		ELSE IF @Operator = 'IsNotContainedIn'
			SET @Result = ' ' + @Value + ' NOT LIKE ''%' + @AttributeTypeName + '%'')';
	END

END
