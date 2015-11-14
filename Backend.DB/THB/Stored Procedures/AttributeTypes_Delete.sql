-- =============================================
-- Author:		DK
-- Create date: 2012-03-13
-- Last modified on: 2013-02-18
-- Description:	Usuwa cechy (wraz z danymi powiazanymi) o podanych ID.

-- XML wejsciowy w postaci:

	--<Request RequestType="AttributeTypes_Delete" UserId="1" AppDate="2012-08-09T12:48:23" IsSoftDelete="false">
	--	<Ref Id="1" EntityType="AttributeType" />
	--	<Ref Id="2" EntityType="AttributeType" />
	--	<Ref Id="3" EntityType="AttributeType" />
	--	<Ref Id="4" EntityType="AttributeType" />
	--	<Ref Id="5" EntityType="AttributeType" />
	--	<Ref Id="6" EntityType="AttributeType" />
	--	<Ref Id="7" EntityType="AttributeType" />
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="AttributeTypes_Delete" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="7.1.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Error ErrorMessage="ble vble"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[AttributeTypes_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@UzytkownikID int,
		@RequestType nvarchar(100) = '',
		@UsuwanieMiekkie bit = 1,
		@xmlOk bit = 0,
		@xml_data xml,
		@BranzaID int,
		@ERRMSG nvarchar(255),
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@TypObiektu nvarchar(500),
		@Query nvarchar(MAX) = '',
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@ZablokowanyDoEdycji bit = 0,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@CechaId int

	BEGIN TRY

		SET @ERRMSG = '';
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_Delete', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT 
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--usuwanie tabel tymczasowych, jesli istnieja
			IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
				DROP TABLE #DoUsuniecia
				
			CREATE TABLE #DoUsuniecia(ID int);
			
			--wyciaganie daty i typu zadania
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
			FROM @xml_data.nodes('/Request') T(C)
			
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			EXEC [THB].[CheckUserPermission]
				@Operation = N'DELETE',
				@UserId = @UzytkownikID,
				@BranchId = @BranzaId,
				@Result = @MaUprawnienia OUTPUT
			
			IF @MaUprawnienia = 1
			BEGIN
			
				--pobranie id elementow do usuniecia
				INSERT INTO #DoUsuniecia(ID)
				SELECT C.value('./@Id', 'int')
				FROM @xml_data.nodes('/Request/Ref') T(C)
				
				--SELECT * FROM #DoUsuniecia
				--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
				
				IF @RequestType = 'AttributeTypes_Delete'
				BEGIN
					
					--pobranie warunkow usuniecia danych w trybie miekkim i twardym
					SET @DeleteHardCondition = THB.GetHardDeleteCondition();
					SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();
					
					--sprawdzenie czy podano do usuniecia ceche zablokowana do edycji					
					IF EXISTS (SELECT Cecha_ID FROM dbo.Cechy WHERE IsBlocked = 1 AND Cecha_ID IN (SELECT ID FROM #DoUsuniecia))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć zamrożonego typu cechy.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
				
					IF @ZablokowanyDoEdycji = 0
					BEGIN				
										
						BEGIN TRAN T1_AT_Delete
				
						-- pobranie daty modyfikacji na podstawie przekazanego AppDate
						SELECT @DataUsunieciaApp = THB.PrepareAppDate(@DataProgramu);
						
						-- usuwanie rekordow pozwiazanych z usuwanymi cechami dla kazdego z obiektow
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','cur') > 0 
						BEGIN
							 CLOSE cur
							 DEALLOCATE cur
						END
							
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE cur CURSOR LOCAL FOR 
							SELECT DISTINCT Nazwa FROM TypObiektu WHERE IdArch IS NULL
						OPEN cur
						FETCH NEXT FROM cur INTO @TypObiektu
						WHILE @@FETCH_STATUS = 0
						BEGIN		
							IF @UsuwanieMiekkie = 0
							BEGIN									
								--trwale usuwanie danych z bazy
								SET @Query = ' 
								IF OBJECT_ID (N''[_' + @TypObiektu + '_Cechy_Hist]'', N''U'') IS NOT NULL
								BEGIN
									DELETE FROM [dbo].[_' + @TypObiektu + '_Cechy_Hist] 
									WHERE CechaID IN (SELECT ID FROM #DoUsuniecia)' + @DeleteHardCondition + ';
									
									UPDATE [dbo].[_' + @TypObiektu + '_Cechy_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE IsDeleted = 0 AND CechaID IN (SELECT ID FROM #DoUsuniecia)' + @DeleteSoftCondition + ';
								END
								
								IF OBJECT_ID (N''[_' + @TypObiektu + '_Relacje_Hist]'', N''U'') IS NOT NULL
								BEGIN	
									DELETE FROM [dbo].[_' + @TypObiektu + '_Relacje_Hist] 
									WHERE CechaID IN (SELECT ID FROM #DoUsuniecia);
									
									UPDATE [dbo].[_' + @TypObiektu + '_Relacje_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsuniecia AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE IsDeleted = 0 AND CechaID IN (SELECT ID FROM #DoUsuniecia)' + @DeleteSoftCondition + ';
								END';
							END
							ELSE
							BEGIN
								--ustawienie odpowiednich flag dla usuwania miekkiego
								SET @Query = ' 
								IF OBJECT_ID (N''[_' + @TypObiektu + '_Cechy_Hist]'', N''U'') IS NOT NULL
								BEGIN
									UPDATE [dbo].[_' + @TypObiektu + '_Cechy_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE IsDeleted = 0 AND CechaID IN (SELECT ID FROM #DoUsuniecia);
								END
								
								IF OBJECT_ID (N''[_' + @TypObiektu + '_Relacje_Hist]'', N''U'') IS NOT NULL
								BEGIN
									UPDATE [dbo].[_' + @TypObiektu + '_Relacje_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsuniecia AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE IsDeleted = 0 AND CechaID IN (SELECT ID FROM #DoUsuniecia);
								END'
							END
						
							--usuniecie danych z kazdej tabeli typu obiektu
							--PRINT @Query;
							EXEC sp_executesql @Query;
							
							FETCH NEXT FROM cur INTO @TypObiektu
						END
						CLOSE cur
						DEALLOCATE cur
						
						IF Cursor_Status('local','curCechy') > 0 
						BEGIN
							 CLOSE curCechy
							 DEALLOCATE curCechy
						END
							
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE curCechy CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #DoUsuniecia
						OPEN curCechy
						FETCH NEXT FROM curCechy INTO @CechaId
						WHILE @@FETCH_STATUS = 0
						BEGIN					
						
							--rozny tryb usuwania danych zalezny od flagi
							IF @UsuwanieMiekkie = 0
							BEGIN
								--sprawdzamy czy istnieje cecha spelniajaca warunek usuniecia na twardo, jak tak to usuwamy na twardo wszystkie powiazane dane
								SET @Query = '
									IF EXISTS (SELECT Cecha_Id FROM dbo.Cechy WHERE Cecha_ID = @CechaId' + @DeleteHardCondition + ')
									BEGIN
										DELETE FROM dbo.[TypObiektu_Cechy]
										WHERE Cecha_ID = @CechaId
										
										DELETE FROM dbo.[TypRelacji_Cechy]
										WHERE Cecha_ID = @CechaId
										
										DELETE FROM dbo.[Relacja_Cecha_Hist]
										WHERE CechaID = @CechaId
										
										DELETE FROM dbo.[Branze_Cechy]
										WHERE CechaId = @CechaId
										
										DELETE FROM dbo.[Cechy]
										WHERE (Cecha_ID = @CechaId OR IdArch = @CechaId);										
									END
									ELSE
									BEGIN'
								
								SET @Query += '
										UPDATE dbo.[TypObiektu_Cechy] SET
											IsValid = 0,
											IsDeleted = 1,
											DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
											DeletedFrom = @DataUsunieciaApp,
											ValidTo = @DataUsunieciaApp,
											RealDeletedFrom = @DataUsuniecia
										WHERE IsDeleted = 0 AND Cecha_ID = @CechaId' + @DeleteSoftCondition + ';
										
										UPDATE dbo.[TypRelacji_Cechy] SET
											IsValid = 0,
											IsDeleted = 1,
											DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
											DeletedFrom = @DataUsunieciaApp,
											ValidTo = @DataUsunieciaApp,
											RealDeletedFrom = @DataUsuniecia
										WHERE IsDeleted = 0 AND Cecha_ID = @CechaId' + @DeleteSoftCondition + ';
										
										UPDATE dbo.[Relacja_Cecha_Hist] SET
											IsValid = 0,
											IsDeleted = 1,
											DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
											ValidTo = @DataUsunieciaApp, 
											DeletedFrom = @DataUsunieciaApp,
											RealDeletedFrom = @DataUsuniecia
										WHERE IsDeleted = 0 AND CechaID = @CechaId' + @DeleteSoftCondition + ';
										
										UPDATE dbo.[Branze_Cechy] SET
											IsValid = 0,
											IsDeleted = 1,
											DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
											ValidTo = @DataUsunieciaApp, 
											DeletedFrom = @DataUsunieciaApp,
											RealDeletedFrom = @DataUsuniecia
										WHERE IsDeleted = 0 AND CechaID = @CechaId' + @DeleteSoftCondition + ';
										
										UPDATE dbo.[Cechy] SET
											IsValid = 0,
											IsDeleted = 1,
											DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
											DeletedFrom = @DataUsunieciaApp,
											ValidTo = @DataUsunieciaApp,
											RealDeletedFrom = @DataUsuniecia  
										WHERE IsDeleted = 0 AND (Cecha_ID = @CechaId OR IdArch = @CechaId)' + @DeleteSoftCondition + ';
											
									END
									
									IF @@ROWCOUNT > 0
										SET @Usunieto = 1;'
									
									--PRINT @Query;
									EXEC sp_executesql @Query, N'@DataUsunieciaApp datetime, @CechaId int, @DataUsuniecia datetime, @Usunieto bit OUTPUT', 
										@DataUsunieciaApp = @DataUsunieciaApp, @CechaId = @CechaId, @DataUsuniecia = @DataUsuniecia, @Usunieto = @Usunieto OUTPUT
								
							END
							ELSE
							BEGIN
								UPDATE dbo.[TypObiektu_Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND Cecha_ID = @CechaId;
								
								UPDATE dbo.[TypRelacji_Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND Cecha_ID = @CechaId;
							
								UPDATE dbo.[Relacja_Cecha_Hist] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								ValidTo = @DataUsunieciaApp, 
								DeletedFrom = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND CechaID = @CechaId;
							
								UPDATE dbo.[Branze_Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								ValidTo = @DataUsunieciaApp, 
								DeletedFrom = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND CechaID = @CechaId;
								
								UPDATE dbo.[Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia  
								WHERE IsDeleted = 0 AND (Cecha_ID = @CechaId OR IdArch = @CechaId);
								
								IF @@ROWCOUNT > 0
									SET @Usunieto = 1;
							END
							
							FETCH NEXT FROM curCechy INTO @CechaId							
						END
						CLOSE curCechy;
						DEALLOCATE curCechy;
							
						COMMIT TRAN T1_AT_Delete
					END
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'AttributeTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'AttributeTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT
		END			
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();

			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN T1_AT_Delete
			END
		END CATCH 
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="AttributeTypes_Delete"';
		
		IF @DataProgramu IS NOT NULL
			SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';

		SET @XMLDataOut += '>'

		IF @ERRMSG IS NULL OR @ERRMSG = ''
		BEGIN
			IF @Usunieto = 1
				SET @XMLDataOut += '<Result><Value>true</Value></Result>';
			ELSE
				SET @XMLDataOut += '<Result><Value/></Result>';
		END
		ELSE		
			SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>'; 
		
		SET @XMLDataOut += '</Response>';
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 
		
END
