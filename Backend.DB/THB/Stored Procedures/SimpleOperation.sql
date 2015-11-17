-- =============================================
-- Author:		DK
-- Create date: 2012-10-15
-- Last modified on: 2012-12-11
-- Description:	Przygotowuj xmla dla wlasciwej metody wyliczajacej

-- XML wejsciowy w postaci:

	--<Request UserId="1" AppDate="2012-01-01T11:34:33" >
	--	<Scalar Lp="1" Value="2"/>
	--	<Relation Lp="2" Id="5" AttributeId="5"/>
	--</Request>

-- XM wyjsciowy w postaci:

--<?xml version="1.0" encoding="utf-8"?>
--<Response ResponseType="SimpleOperation_Div" AppDate="2012-01-01">
--	<Result>
--		<Value>6</Value>
--	</Result>
--</Response>

-- =============================================
CREATE PROCEDURE [THB].[SimpleOperation]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(MAX) = '',
		@statusS int,
		@StatusW int,
		@StatusP int,
		@AppDate datetime,
		@DataProgramu datetime,
		@MaUprawnienia bit,
		@BranchId int,
		@RequestType nvarchar(50) = 'SimpleOperation',
		@UserId int,
		@ERRMSG nvarchar(MAX),
		@xml_data xml,
		@xmlOk bit,
		@Operation varchar(1),
		@CalculationPhrase nvarchar(MAX) = '',
		
		-- zmienne na wartosci parametrow
		@Arg1Id int,
		@Arg1TypeId int,
		@Arg1AttributeTypeId int,
		@Arg1AttributeValue varchar(20),
		@Arg1Type varchar(20),
		@Arg2Id int,
		@Arg2TypeId int,
		@Arg2AttributeTypeId int,
		@Arg2AttributeValue varchar(20),
		@Arg2Type varchar(20),
		@CalculationValue varchar(20),
		@ResultValue varchar(20),
		@InputDataIsCorrect bit = 0
		
		SET @ERRMSG = '';
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_SimpleOperation', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN
		
			BEGIN TRY
		
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
		
			--wyciaganie danych z XMLa
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@UserId = C.value('./@UserId', 'int')
					,@BranchId = C.value('./@BranchId', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)

			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
		
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			EXEC [THB].[CheckUserPermission]
				@Operation = N'GET',
				@UserId = @UserId,
				@BranchId = @BranchId,
				@Result = @MaUprawnienia OUTPUT
			
			IF @MaUprawnienia = 1
			BEGIN
						
				--odczytywanie danych argumentow dla operacji arytmetycznych
				SELECT	@Arg1Id = C.value('./@Id', 'int')
						,@Arg1TypeId = C.value('./@TypeId', 'int')
						,@Arg1AttributeTypeId = C.value('./@AttributeTypeId', 'int')
						,@Arg1AttributeValue = C.value('./@Value', 'varchar(20)')
						,@Arg1Type = c.value('local-name(.)', 'varchar(20)')
				FROM @xml_data.nodes('/Request/*') T(C)
				WHERE C.value('./@Lp', 'int') = 1
				
				SELECT	@Arg2Id = C.value('./@Id', 'int')
						,@Arg2TypeId = C.value('./@TypeId', 'int')
						,@Arg2AttributeTypeId = C.value('./@AttributeTypeId', 'int')
						,@Arg2AttributeValue = C.value('./@Value', 'varchar(20)')
						,@Arg2Type = c.value('local-name(.)', 'varchar(20)')
				FROM @xml_data.nodes('/Request/*') T(C)
				WHERE C.value('./@Lp', 'int') = 2

				--ustalenie operacji na podstawie typu wywolania
				IF @RequestType = 'SimpleOperation_Sum'
					SET @Operation = '+';
				ELSE IF @RequestType = 'SimpleOperation_Sub'
					SET @Operation = '-';
				ELSE IF @RequestType = 'SimpleOperation_Mul'
					SET @Operation = '*';
				ELSE IF @RequestType = 'SimpleOperation_Div'
					SET @Operation = '/';
			
				--weryfikacja czy podano poprawnie obie dane wejsciowe
				IF (@Arg1Id IS NOT NULL OR (@Arg1AttributeValue IS NOT NULL AND LEN(@Arg1AttributeValue) > 0)) AND 
					(@Arg2Id IS NOT NULL OR (@Arg2AttributeValue IS NOT NULL AND LEN(@Arg2AttributeValue) > 0))
				BEGIN
					
					SET @Query = 'SELECT @ResultValue = (';
					
					EXEC [THB].[SimpleOperation_GetArgumentValue]
						@Id = @Arg1Id,
						@TypeId = @Arg1TypeId,
						@AttributeTypeId = @Arg1AttributeTypeId,
						@AttributeValue = @Arg1AttributeValue,
						@Type = @Arg1Type,
						@StatusS = @StatusS,
						@StatusW = @StatusW,
						@StatusP = @StatusP,
						@AppDate = @AppDate,
						@UserId = @UserId,
						@BranchId = @BranchId,
						@Value = @CalculationValue OUTPUT
					
					SET @Query += @CalculationValue + ' ' + @Operation + ' ';
					SET @CalculationValue = NULL;
				
					EXEC [THB].[SimpleOperation_GetArgumentValue]
						@Id = @Arg2Id,
						@TypeId = @Arg2TypeId,
						@AttributeTypeId = @Arg2AttributeTypeId,
						@AttributeValue = @Arg2AttributeValue,
						@Type = @Arg2Type,
						@StatusS = @StatusS,
						@StatusW = @StatusW,
						@StatusP = @StatusP,
						@AppDate = @AppDate,
						@UserId = @UserId,
						@BranchId = @BranchId,
						@Value = @CalculationValue OUTPUT
					
					--zabezpieczenie przed dzieleniem przez 0
					IF @Operation = '/' AND @CalculationValue = '0'
						SET @CalculationValue = 1;
						
					SET @Query += @CalculationValue + ')';
					
					--wywolanie obliczen
					
					EXECUTE sp_executesql @Query, N'@ResultValue varchar(20) OUTPUT', @ResultValue = @ResultValue OUTPUT

					SELECT @ResultValue = CAST(CAST(@ResultValue AS decimal(12,5)) AS varchar(20));
					
					PRINT @Query + ': = ' + @ResultValue				
--SELECT @ResultValue AS Wynik	
				END
				ELSE
					SET @ERRMSG = 'Niepoprawne parametry wejściowe dla procedury.';

			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UserId, @Val2 = @RequestType, @Wiadomosc = @ERRMSG OUTPUT	
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
	
	--przygotowanie XMLa zwrotnego	
	--SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?>';
	
	SET @XMLDataOut = '<Response ResponseType="' + @RequestType + '"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG IS NULL OR @ERRMSG = ''
	BEGIN
		SET @XMLDataOut += '<Result><Value>' + @ResultValue + '</Value></Result>';
	END
	ELSE		
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>';

	SET @XMLDataOut += '</Response>';

END
