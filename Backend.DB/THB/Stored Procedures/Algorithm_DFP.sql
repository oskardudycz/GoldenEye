-- =============================================
-- Author:		DK
-- Create date: 2012-08-13
-- Last modified on: 2012-09-26
-- Description:	Wyszukuje najkrótszą ścieżkę pomiędzy 2 obiektami w danej strukturze.

-- Przykladowy plik wejsciowy XML:
	--<?xml version="1.0" encoding="UTF-8"?>
	--<Request AppDate="2012-02-09T11:45:33" StructureId="23" RequestType="Algorithm_DFP" UserId="1" BranchId="1" Date="2012-05-05">
	--	<FirstObject Id="12" TypeId="54" />
	--  <LastObject Id="12" TypeId="56" />
	--</Request>
	
-- Przykladowy plik wyjsciowy XML:
	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Algorithm_DFP" AppDate="2012-02-09">
	--	<Result>
	--		<Value>
				--<PathStep Lp="1" RelationId="3903" />
				--<PathStep Lp="2" RelationId="3929" />
				--<PathStep Lp="3" RelationId="3918" />
	--		</Value>
	--	</Result>
	--</Response>
-- =============================================
CREATE PROCEDURE [THB].[Algorithm_DFP]
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
		@RequestType nvarchar(100),
		@SesjaId int = 0,
		@IdStruktury int,
		@Data date,
		@UzytkownikID int,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@ResultValue xml,
		@ResultString nvarchar(500) = '',
		@FirstObiektId int,
		@FirstTypObiektuId int,
		@LastObiektId int,
		@LastTypObiektuId int,
		@Success bit = 1,	
		@ERRMSG nvarchar(MAX)

	BEGIN TRY
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Algorithm_DFP', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
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
					,@Data = C.value('./@Date', 'date')
			FROM @xml_data.nodes('/Request') T(C);
			
			--odczytanie danych obiektow: startowego i koncowego
			SELECT	@FirstObiektId  = C.value('./@Id', 'int')
					,@FirstTypObiektuId = C.value('./@TypeId', 'int')
			FROM @xml_data.nodes('/Request/FirstObject') T(C);
			
			SELECT	@LastObiektId  = C.value('./@Id', 'int')
					,@LastTypObiektuId = C.value('./@TypeId', 'int')
			FROM @xml_data.nodes('/Request/LastObject') T(C);
					
			IF @RequestType = 'Algorithm_DFP'
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
						@CheckCechaC1 = 0,
						--@IdCechaC1 = @IdCechaC1,
						@DataStart = @Data,
						@DataEnd = @Data, 
						@ERRMSG = @ERRMSG OUTPUT,
						@Success = @Success OUTPUT
					
					IF @Success = 1
					BEGIN
							
						--sprawdzenie czy obiekt poczatkowy jest rozny od obiektu koncowego
						IF ((@FirstObiektId = @LastObiektId) AND (@FirstTypObiektuId = @LastTypObiektuId))
						BEGIN
							SET @ERRMSG = 'Nieprawidłowe dane uruchomieniowe (obiekt początkowy i końcowy jest identyczny).';
							SET @Success = 0;
						END
						ELSE
						BEGIN
						
							--utworzenie danych sesji, przygotowanie modelu z danymi w tabelach tymczasowych
							INSERT INTO dbo.[SesjeObliczen] (NazwaObliczen, DataObliczen, UserId)
							VALUES (@RequestType, GETDATE(), @UzytkownikID);
							
							SET @SesjaId = IDENT_CURRENT('SesjeObliczen')
							
							EXEC [THB].[PrepareModel]
								@SessionId = @SesjaId,
								@StructureId = @IdStruktury,
								--@AttributeValues = @CechyDoPobrania,  --'303, 304, 305, 306, 307, 308',
								--@AttributeC1Id = @IdCechaC1,
								--@ObiektO1Id = @RootObiektId,
								--@TypObiektuO1Id = @RootTypObiektuId,
								@GetObjectAttributes = 0,
								@StartDate = @Data,
								@EndDate = @Data,
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
								BEGIN TRAN CALC_DFP
								
								PRINT 'model OK'						
								
								--wywolanie algorytmu A1 - sumujacego
								EXEC [THB].[CalculationDFP]
									@SessionId = @SesjaId,
									@UserId = @UzytkownikID,
									@LObiektId = @FirstObiektId,
									@LTypObiektuId = @FirstTypObiektuId,
									@RObiektId = @LastObiektId,
									@RTypObiektuId = @LastTypObiektuId,
									@Path = @ResultValue OUTPUT,
									@Success = @Success OUTPUT,
									@ERRMSG = @ERRMSG OUTPUT																						
							
								COMMIT TRAN CALC_DFP
							END
						END
					END				

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Algorithm_DFP', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Algorithm_DFP', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN CALC_DFP
		END
	END CATCH
	
	SET @ResultString =  CAST(@ResultValue AS nvarchar(MAX));

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Algorithm_DFP"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += '<Result><Value>' + ISNULL(@ResultString, 'Brak danych') + '</Value></Result>';
	ELSE
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>';
	
	SET @XMLDataOut += '</Response>'; 

END
