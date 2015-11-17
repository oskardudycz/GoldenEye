-- =============================================
-- Author:		DK
-- Create date: 2012-11-16
-- Last modified on: 2012-11-19
-- Description:	Wylicza wynik dla podane funkcji i jej parametrów
-- =============================================
CREATE PROCEDURE [THB].[CalculateFunction]
(
	@XmlArg xml,
	@UserId int,
	@AppDate datetime,
	@StatusS int,
	@StatusP int,
	@StatusW int,
	@BranchId int,
	@ResultValue varchar(50) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ERRMSG nvarchar(MAX),
		@Lp int = 0,
		@Query nvarchar(MAX),
		@FunctionName varchar(50),
		@XmlTmp xml,
		@ParameterValue varchar(50),
		@ParameterName varchar(50),
		@FunctionValue varchar(50),
		@ArgId int,
		@ArgTypeId int,
		@ArgAttributeTypeId int,
		@ArgAttributeValue varchar(20),
		@ArgType varchar(20),
		@Counter int = 1
	
		--utworenie tabeli jesli nie istnieje			
		IF OBJECT_ID('tempdb..#ParametryFunkcji') IS NULL
			CREATE TABLE #ParametryFunkcji (Nazwa nvarchar(50), Parameter xml); 
			
--		BEGIN TRY

		--pobranie nazwy funkcji
		SELECT @FunctionName = c.value('./@Name', 'varchar(50)'),
				@Lp = c.value('./@Lp', 'int')
		FROM @XmlArg.nodes('/Function') AS t(c)

		--pobranie parametrow funkcji
		INSERT #ParametryFunkcji (Nazwa, Parameter)
		SELECT	c.value('./@Name', 'varchar(50)'),
				c.query('.')
		FROM @XmlArg.nodes('/Function/*') AS t(c)

--SELECT * FROM #ParametryFunkcji
		
		--sprawdzenie czy wywolanie funkcji z parametrami
		IF (SELECT COUNT (1) FROM #ParametryFunkcji) > 0
		BEGIN
			SET @Query = 'EXEC @FunctionValue = [THB].[' + @FunctionName + ']'
			
			--dodawanie parametrow do funkcji
			DECLARE curParameters CURSOR LOCAL FOR 
				SELECT Nazwa, Parameter FROM #ParametryFunkcji
			OPEN curParameters
			FETCH NEXT FROM curParameters INTO @ParameterName, @XmlTmp
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				SELECT @ArgAttributeValue = NULL, @ArgId = NULL, @ArgTypeId = NULL, @ArgAttributeTypeId = NULL,
					@ArgType = NULL, @ParameterValue = NULL;
				
				--odczytywanie danych argumentow dla operacji arytmetycznych
				SELECT	@ArgId = C.value('./@Id', 'int')
						,@ArgTypeId = C.value('./@TypeId', 'int')
						,@ArgAttributeTypeId = C.value('./@AttributeTypeId', 'int')
						,@ArgAttributeValue = C.value('./@Value', 'varchar(20)')
						,@ArgType = c.value('local-name(.)', 'varchar(20)')
				FROM @XmlTmp.nodes('/FunctionParameter/*') T(C)				

				IF @ArgType <> 'Scalar'
				BEGIN	
					EXEC [THB].[SimpleOperation_GetArgumentValue]
							@Id = @ArgId,
							@TypeId = @ArgTypeId,
							@AttributeTypeId = @ArgAttributeTypeId,
							@AttributeValue = @ArgAttributeValue,
							@Type = @ArgType,
							@StatusS = @StatusS,
							@StatusW = @StatusW,
							@StatusP = @StatusP,
							@AppDate = @AppDate,
							@UserId = @UserId,
							@BranchId = @BranchId,
							@Value = @ParameterValue OUTPUT
				END
				ELSE
					SET @ParameterValue = @ArgAttributeValue
				
				IF @Counter = 1
				BEGIN
				SET @Query += '
					@' + @ParameterName + ' = ' + @ParameterValue;					
				END
				ELSE
				BEGIN
					SET @Query += '
					,@' + @ParameterName + ' = ' + @ParameterValue;
				END
					
				SET @Counter = @Counter + 1;
				
				FETCH NEXT FROM curParameters INTO @ParameterName, @XmlTmp
			END
			CLOSE curParameters;
			DEALLOCATE curParameters;
		END
		ELSE
		BEGIN
			SET @Query = 'SELECT @FunctionValue = [THB].[' + @FunctionName + ']()'
		END
		
		PRINT @Query;
		EXECUTE sp_executesql @Query, N'@FunctionValue varchar(50) OUTPUT', @FunctionValue = @FunctionValue OUTPUT

--SELECT @FunctionValue AS WynikFunkcji	

		-- zwrocenie wyniku obliczeni funkcji		
		--SET @ResultValue = CAST('<SimpleValue Lp="' + CAST(@Lp AS varchar) + '"><Scalar Value="' + @FunctionValue + '"/></SimpleValue>' AS xml);
		SET @ResultValue = @FunctionValue

--SELECT @ResultValue
		--END TRY
		--BEGIN CATCH
		--	SET @ERRMSG = @@ERROR;
		--	SET @ERRMSG += ' ';
		--	SET @ERRMSG += ERROR_MESSAGE();
		--END CATCH

END
