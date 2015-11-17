-- =============================================
-- Author:		DK
-- Create date: 2012-07-24
-- Last modified on: 2012-09-26
-- Description:	Wylicza ilosc danych zwiazanych z konkretna cecha dla podanej struktury, dla podanych cech (zbieranej C2 i wagowej C3).
-- Wykonuje algorytm A2.

-- Przykladowy plik wejsciowy XML:
	--<?xml version="1.0"?>
	--<Request AppDate="2012-02-09T12:45:22" StructureId="23" RequestType="Algorithm_CalculationOfWater" UserId="1" BranchId="1"
	--StartDate="2012-05-05" EndDate="2012-05-09">
	--	<ObjectRef Id="12" TypeId="54" />
	--	<AlgorithmAttribute AttributeTypeId="7" VirtualTypeId="0" />
	--<AlgorithmAttribute AttributeTypeId="3" VirtualTypeId="2" />
	--</Request>
	
-- Przykladowy plik wyjsciowy XML:
	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Algorithm_CalculationOfWater" AppDate="2012-02-09">
	--	<Result>
	--		<Value>
	--			<Calculation UnitId="2" UnitTypeId="34" Value="12.34" />
	--			<Calculation UnitId="3" UnitTypeId="34" Value="50.45" />
	--			<Calculation UnitId="4" UnitTypeId="34" Value="89.20" />
	--		</Value>
	--	</Result>
	--</Response>
	
-- =============================================
CREATE PROCEDURE [THB].[Algorithm_Redistibution]
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
		@DataStart date,
		@DataEnd date, 
		@UzytkownikID int,
		@IdCechaC1 int, -- cecha zbierana
		@IdCechaC3 int, -- cecha wagowa
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@ResultValue xml,
		@ResultString nvarchar(MAX),
		@RootObiektId int,
		@RootTypObiektuId int,
		@CechyDoPobrania varchar(300),
		@Success bit = 1,	
		@ERRMSG nvarchar(MAX),
		@VirtualTypeCechaJednostkowa smallint = 0,
		@CechaZbieranaTmpId int

	BEGIN TRY
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Algorithm_CalculationOfWater', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
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
		
			SELECT TOP 1 @IdCechaC3  = C.value('./@AttributeTypeId', 'int')
			FROM @xml_data.nodes('/Request/AlgorithmAttribute') T(C)
			WHERE C.value('./@VirtualTypeId', 'int') = 2;
		
			IF @RequestType = 'Algorithm_Redistibution'
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
						@IdCechaC3 = @IdCechaC3,
						@CheckCechaC3 = 1,
						@DataStart = @DataStart,
						@DataEnd = @DataEnd, 
						@ERRMSG = @ERRMSG OUTPUT,
						@Success = @Success OUTPUT
						
					IF @Success = 1
					BEGIN
					
						BEGIN TRAN CALC_REDIST
								
						-- utworzenie danych sesji, przygotowanie modelu z danymi w tabelach tymczasowych
						INSERT INTO dbo.[SesjeObliczen] (NazwaObliczen, DataObliczen, UserId)
						VALUES (@RequestType, GETDATE(), @UzytkownikID);
						
						SET @SesjaId = IDENT_CURRENT('SesjeObliczen')
						SET @CechyDoPobrania = CAST(@IdCechaC1 AS varchar) + ', ' + CAST(ISNULL(@IdCechaC3, 0) AS varchar)
						
						EXEC [THB].[PrepareModel]
							@SessionId = @SesjaId,
							@AttributeValues = @CechyDoPobrania,  --'303, 304, 305, 306, 307, 308',
							@StructureId = @IdStruktury,
							--@AttributeC1Id = @IdCechaC1,
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
							PRINT 'model OK'																											
							
							--wywolanie algorytmu A2
							EXEC [THB].[CalculationA2]
								@SesjaId = @SesjaId,
								@O1ObiektId = @RootObiektId,
								@O1TypObiektuId = @RootTypObiektuId,
								@UzytkownikID = @UzytkownikID,
								@AttributeC2Id = @IdCechaC1,
								@AttributeC3Id = @IdCechaC3, 
								@DivideMethod = N'M1a', 
								@ERRMSG = @ERRMSG OUTPUT,
								@Success = @Success OUTPUT
								
							--przygotowanie danych do odpowiedzi jsli wszystko sie udalo
							IF @Success = 1
							BEGIN
								
								SELECT @CechaZbieranaTmpId = Id
								FROM Alg_Cechy
								WHERE CechaId = @IdCechaC1 AND SesjaId = @SesjaId
								
								SET @ResultValue = (
												SELECT ao.[ObiektId] AS "@UnitId"
												,ao.[TypObiektuId] AS "@UnitTypeId"
												,ISNULL((SELECT C.value('text()[1]', 'nvarchar(100)') FROM aoc.ColumnsSet.nodes('/*') AS t(c)), 0) AS "@Value"
												FROM Alg_Obiekty ao
												JOIN Alg_ObiektyCechy aoc ON (ao.Id = aoc.ObiektId)
												WHERE ao.SesjaId = @SesjaId AND aoc.SesjaId = @SesjaId AND aoc.CechaId = @CechaZbieranaTmpId 
												AND aoc.VirtualTypeId = @VirtualTypeCechaJednostkowa
												FOR XML PATH('Calculation')
												)
							END
							ELSE
							BEGIN
								SET @ResultValue = NULL;
							END	
						
							--przepisanie wartosci wyliczen z tabel roboczych do bazy danych
							--EXEC [THB].[RewriteAttributeValuesFromTempToObjects]
							--	@SesjaId = @SesjaId,
							--	@UzytkownikID = @UzytkownikID,
							--	@ERRMSG = @ERRMSG OUTPUT
						END
							
						COMMIT TRAN CALC_REDIST
					END			
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Algorithm_Redistibution', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Algorithm_Redistibution', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN CALC_REDIST
		END
	END CATCH
	
	SET @ResultString = CAST(@ResultValue AS nvarchar(MAX));
	
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Algorithm_Redistibution"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += '<Result><Value>' + ISNULL(@ResultString, 'Brak danych') + '</Value></Result>';
	ELSE
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>';
	
	SET @XMLDataOut += '</Response>'; 

END
