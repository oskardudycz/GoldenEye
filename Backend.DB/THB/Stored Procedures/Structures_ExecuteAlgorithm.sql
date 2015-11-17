-- =============================================
-- Author:		DK
-- Create date: 2012-03-23
-- Last modified on: --
-- Description:	Pobiera dane z tabeli Struktura_Obiekt dla danego typu struktury z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="Structures_ExecuteAlgorithm" StructureId="50" UserId="1"  StatusW="2" AppDate="2012-02-09T08:34:23">
	--</Request>
	
-- XML wyjsciowy w postaci:

--<?xml version="1.0" encoding="utf-8"?>
--<Response ResponseType="Structures_ExecuteAlgorithm" AppDate="2012-01-01">
--	<Result>
--		<Value>6</Value>
--	</Result>
--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Structures_ExecuteAlgorithm]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(MAX) = '',
		@Result nvarchar(MAX),
		@Request nvarchar(MAX),
		@AlgorithmXml xml,
		@StructureId int,
		@AppDate datetime,
		@DataProgramu datetime,
		@xmlOk bit,
		@ERRMSG nvarchar(MAX),
		@RequestType nvarchar(100),
		@MaUprawnienia bit,
		@BranzaId int,
		@UserId int,
		@StatusS int,
		@StatusP int,
		@StatusW int,
		@xml_data xml
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Structures_ExecuteAlgorithm', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
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
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@StructureId = C.value('./@StructureId', 'int')
					,@UserId = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)
		
			IF @RequestType = 'Structures_ExecuteAlgorithm'
			BEGIN
			
				-- pobranie daty na podstawie przekazanego AppDate
				SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'GET',
					@UserId = @UserId,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					--pobranie algorytmu dla struktury
					SELECT @AlgorithmXml = Algorytm
					FROM dbo.Struktura_Algorytmy
					WHERE StrukturaId = @StructureId
					
					IF @AlgorithmXml IS NULL
					BEGIN
						SET @ERRMSG = 'Błąd. Nie znaleziono definicji algorytmu dla struktury o podanym Id (' + CAST(@StructureId AS varchar) + ').';
					END
					ELSE
					BEGIN
					
						--przygotowanie XMLa dla procedury liczacej
						SELECT @Request =  CAST(
						(SELECT @UserId AS "@UserId", 
							@AppDate AS "@AppDate",
							'CompositeArithmeticOperation' AS "@RequestType",
							@AlgorithmXml
						 FOR XML PATH('Request'), TYPE) AS nvarchar(MAX))						
					
						--wywolanie procedury liczacej						
						EXEC [THB].[CompositeArithmeticOperation]
							@XMLDataIn = @Request,
							@XMLDataOut = @Result OUTPUT
						
						--zmiana XMLa wyjsciowego na poprawny dla funkjc wywolujacej
						SET @AlgorithmXml = CAST(REPLACE(@Result, '<?xml version="1.0" encoding="utf-8"?>', '') AS xml);
						--SET @AlgorithmXml.modify('replace value of (/Response/@ResponseType)[1] with ''Structures_ExecuteAlgorithm''')
						
						SELECT @Result = CAST(C.query('.') AS nvarchar(MAX))
						FROM @AlgorithmXml.nodes('/Response/*') T(C)
						
						
						--SET @Result = CAST(@AlgorithmXml AS nvarchar(MAX));
					
					END
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UserId, @Val2 = N'Structures_ExecuteAlgorithm', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Structures_ExecuteAlgorithm', @Wiadomosc = @ERRMSG OUTPUT 		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Structures_ExecuteAlgorithm"' 
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"'
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += @Result; 
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
