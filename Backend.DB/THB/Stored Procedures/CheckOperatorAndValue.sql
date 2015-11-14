-- =============================================
-- Author:		DK
-- Create date: 2012-03-09
-- Description:	Przygotowanie tekstu dla pojedynczego wyrazenia (operatora i wartosci) dla frazy WHERE
-- =============================================
CREATE PROCEDURE [THB].[CheckOperatorAndValue]
(
	@PropertyName nvarchar(255),
	@Operator nvarchar(25),
	@Value nvarchar(255),
	@Alias varchar(10) = NULL,
	@Result nvarchar(300) OUTPUT
)
AS
BEGIN
	DECLARE @IsOperatorForDigit smallint = 0, -- 0 - operator dla tekstu, 1 - operator dla cyft, -1 - do analizy przez rzutowanie
			@OperatorSQL varchar(20) = NULL,
			@ValueIsDigit bit = 0,
			@LastModified bit = 0
		
	--zamiana tekstu operatora na operator SQLowy
	SET @OperatorSQL = (SELECT	
		CASE @Operator
			WHEN 'IsEqualTo' THEN '='
			WHEN 'IsNotEqualTo' THEN '<>'
			WHEN 'IsGreaterThan' THEN '>'
			WHEN 'IsGreaterThanOrEqualTo' THEN '>='
			WHEN 'IsLessThan' THEN '<'
			WHEN 'IsLessThanOrEqualTo' THEN '<='
		END
		)
		
	--jesli podano = lub <> to sprawdzenie czy dotyczy to tekstu czy liczby	
	--BEGIN TRY
	--	SET @ValueAsInt = CAST(@Value AS int);
	--	SET @ValueIsDigit = 1;
	--END TRY
	--BEGIN CATCH
	--	SET @ValueIsDigit = 0;
	--END CATCH
	SET @ValueIsDigit = (SELECT ISNUMERIC(@Value))
	
	SET @PropertyName = THB.ChangePropertyNameFromENToPL(@PropertyName);
	
	--zamiana wartosci _ na [_] dozwolonej w zapytaniach stringowych
	SET @Value = REPLACE(@Value, '_', '[_]');
	SET @Value = REPLACE(@Value, '%', '[%]');
	
	--ew podmiana nazwy propertisa jesli trzeba
	IF @PropertyName = 'Id'
		SET @PropertyName = 'ISNULL(IdArch, Id)';
	
	IF @PropertyName = 'LastModifiedOn'
		SET @LastModified = 1;
	
	--jesli rozpoznano operator SQL w podstawowych
	IF @OperatorSQL IS NOT NULL
	BEGIN
		IF @Alias IS NULL
		BEGIN		
			IF @LastModified = 1
				SET @Result = ' (' + @PropertyName + ' ' + @OperatorSQL + ' ';
			ELSE
				SET @Result = ' ' + @PropertyName + ' ' + @OperatorSQL + ' ';
		END
		ELSE 
			SET @Result = ' ' + @Alias + '.' + @PropertyName + ' ' + @OperatorSQL + ' ';
		
		IF @ValueIsDigit = 0
			SET @Result += '''';
			
		SET @Result += @Value;
		
		IF @ValueIsDigit = 0
			SET @Result += '''';
			
		IF @LastModified = 1
		BEGIN
			SET @Result += ' OR (LastModifiedOn IS NULL AND CreatedOn ' + @OperatorSQL + ' ''' + @Value + ''' ))'
		END
	END
	ELSE
	BEGIN
		--jesli operator wymaga wywolania funkcji SQL
		IF @Operator = 'Contains'
			SET @Result = ' ' + @PropertyName + ' LIKE ''%' + @Value + '%''';
		ELSE IF @Operator = 'DoesNotContain'
			SET @Result = ' ' + @PropertyName + ' NOT LIKE ''%' + @Value + '%''';
		ELSE IF @Operator = 'EndsWith'
			SET @Result = ' ' + @PropertyName + ' LIKE ''%' + @Value + '''';
		ELSE IF @Operator = 'StartsWith'
			SET @Result = ' ' + @PropertyName + ' LIKE ''' + @Value + '%''';
		ELSE IF @Operator = 'IsContainedIn'
			SET @Result = ' ' + @Value + ' LIKE ''%' + @PropertyName + '%''';
		ELSE IF @Operator = 'IsNotContainedIn'
			SET @Result = ' ' + @Value + ' NOT LIKE ''%' + @PropertyName + '%''';
	END

END
