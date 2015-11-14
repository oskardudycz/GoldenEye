-- =============================================
-- Author:		DK
-- Create date: 2012-07-24
-- Last modified on: 2012-09-26
-- Description:	Wylicza ilosc danych zwiazanych z konkretna cecha dla podanej struktury, dla podanych cech (zbieranej C2).

-- Przykladowy plik wejsciowy XML:
	--<?xml version="1.0" encoding="UTF-8"?>
	--<Request AppDate="2012-02-09T12:34:22" StructureId="23" RequestType="Algorithm_Sum" UserId="1" BranchId="1"
	--StartDate="2012-05-05" EndDate="2012-05-09">
	--	<ObjectRef Id="12" TypeId="54" />
	--	<AlgorithmAttribute AttributeTypeId="22" VirtualTypeId="0" />
	--</Request>
	
-- Przykladowy plik wyjsciowy XML:
	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Algorithm_CalculationOfWater" AppDate="2012-02-09" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="A1.Response.xsd">
	--	<Result>
	--		<Value>100</Value>
	--	</Result>
	--</Response>
-- =============================================
CREATE PROCEDURE [THB].[Algorithm_Sum]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu date,
		@xmlOk bit,
		@xml_data xml,
		@BranzaId int,
		@MaUprawnienia bit = 1,
		@Tmp_Error nvarchar(MAX) = '',
		@RequestType nvarchar(100),
		@SesjaId int = 0,
		@IdStruktury int,
		@DataStart date,
		@DataEnd date, 
		@UzytkownikID int,
		@IdCechaC1 int, -- cecha zbierana
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@ResultValue xml,
		@ResultString nvarchar(500) = '',
		@RootObiektId int,
		@RootTypObiektuId int,
		@CechyDoPobrania varchar(300),
		@Success bit = 1,	
		@ERRMSG nvarchar(MAX)

	BEGIN TRY
	
		SET @Tmp_Error = NULL;
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Algorithm_Sum', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);	
		
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@IdStruktury = C.value('./@StructureId', 'int')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
					,@DataStart = C.value('./@StartDate', 'date')
					,@DataEnd = C.value('./@EndDate', 'date')
			FROM @xml_data.nodes('/Request') T(C);
			
			SELECT	@RootObiektId  = C.value('./@Id', 'int')
					,@RootTypObiektuId = C.value('./@TypeId', 'int')
			FROM @xml_data.nodes('/Request/ObjectRef') T(C);
			
			--pobranie Id cech bioracych udzial w wyliczeniach
			SELECT	TOP 1 @IdCechaC1  = C.value('./@AttributeTypeId', 'int')
			FROM @xml_data.nodes('/Request/AlgorithmAttribute') T(C)
			WHERE C.value('./@VirtualTypeId', 'int') = 0 OR C.value('./@VirtualTypeId', 'int') = 1;
		
			IF @RequestType = 'Algorithm_Sum'
			BEGIN
		
				SET @ERRMSG = NULL;
				SET @Success = 1;
					
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'GET',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN					
					
					-- weryfikacja parametrow wejsciowych, np z danymi w bazie
					EXEC [THB].[CheckAlgorithmParameters]
						@BranzaId = @BranzaId,
						@IdStruktury = @IdStruktury,
						@IdCechaC1 = @IdCechaC1,
						@DataStart = @DataStart,
						@DataEnd = @DataEnd, 
						@ERRMSG = @ERRMSG OUTPUT,
						@Success = @Success OUTPUT
					
					IF @Success = 1
					BEGIN
							
						--utworzenie danych sesji, przygotowanie modelu z danymi w tabelach tymczasowych
						INSERT INTO dbo.[SesjeObliczen] (NazwaObliczen, DataObliczen, UserId)
						VALUES (@RequestType, GETDATE(), @UzytkownikID);
						
						SET @SesjaId = IDENT_CURRENT('SesjeObliczen')
						SET @CechyDoPobrania = CAST(@IdCechaC1 AS varchar);
						
						EXEC [THB].[PrepareModel]
							@SessionId = @SesjaId,
							@AttributeValues = @CechyDoPobrania,  --'303, 304, 305, 306, 307, 308',
							@StructureId = @IdStruktury,
						--	@AttributeC1Id = @IdCechaC1,
							@ObiektO1Id = @RootObiektId,
							@TypObiektuO1Id = @RootTypObiektuId,
							@StartDate = @DataStart,
							@EndDate = @DataEnd,
							@StatusS = @StatusS,
							@StatusP = @StatusP,
							@StatusW = @StatusW,
							@Success = @Success OUTPUT,
							@ERRMSG = @ERRMSG OUTPUT
						
						--jesli nie udalo sie stworzyc modelu struktury to zwroc blad
						IF @Success = 0
						BEGIN
							SET @ERRMSG = 'Błąd podczas tworzenia modelu struktury. ' + @ERRMSG;				
						END					
						ELSE
						BEGIN
							BEGIN TRAN CALC_A1
							
							PRINT 'model OK'						
							
							--wywolanie algorytmu A1 - sumujacego
							EXEC [THB].[CalculationA1]
								@SessionId = @SesjaId,
								@UserId = @UzytkownikID,
								@AttributeC1Id = @IdCechaC1,
								@O1ObiektId = @RootObiektId,
								@O1TypObiektuId = @RootTypObiektuId,
								@ResultValue = @ResultValue OUTPUT,
								@Success = @Success OUTPUT,
								@ERRMSG = @ERRMSG OUTPUT																						
				
								--przepisanie wartosci wyliczen z tabel roboczych do bazy danych
								--EXEC [THB].[RewriteAttributeValuesFromTempToObjects]
								--	@SesjaId = @SesjaId,
								--	@UzytkownikID = @UzytkownikID,
								--	@ERRMSG = @ERRMSG OUTPUT
						
							COMMIT TRAN CALC_A1
						END
					END				

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Algorithm_Sum', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Algorithm_Sum', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN CALC_A1
		END
	END CATCH
	
	SET @ResultString = (SELECT C.value('text()[1]', 'nvarchar(100)') FROM @ResultValue.nodes('/*') AS t(c));
	
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Algorithm_Sum"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += '<Result><Value>' + ISNULL(@ResultString, 'Brak danych') + '</Value></Result>';
	ELSE
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>';
	
	SET @XMLDataOut += '</Response>'; 

END
