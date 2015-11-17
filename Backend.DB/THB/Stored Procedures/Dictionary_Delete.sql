-- =============================================
-- Author:		DK
-- Create date: 2012-03-15
-- Last modified on: 2013-04-04
-- Description:	Usuwa wpis z tabeli Slowniki o podanym Id.
-- Usuwane (modyfikowane) sa takze wiersze w tabelach powiazanych z usuwanym slownikiem.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="Dictionary_Delete" UserId="1" AppDate="2012-02-09T11:34:11" IsSoftDelete="false" 
	--	xsi:noNamespaceSchemaLocation="9.3.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="4" EntityType="Dictionary" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="Dictionary_Delete"" AppDate="2012-02-09" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Error ErrorMessage="ble vble"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Dictionary_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@TypObiektu nvarchar(256),
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255),
		@xmlOk bit = 0,
		@xml_data xml,
		@Id int,
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@NazwaSlownika nvarchar(500),
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@UsunietoNaTwardo bit = 0,
		@ZablokowanyDoEdycji bit = 0

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych			
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
			
		IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
			DROP TABLE #Cechy
		
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
			
			CREATE TABLE #Cechy (ID int);
					
			--wyciaganie daty i typu zadania
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
					,@BranzaId = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id slownikow do usuniecia
			SELECT C.value('./@Id', 'int') AS ID 
			INTO #DoUsuniecia
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(30)') = 'Dictionary'			
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie			
			--SELECT * FROM #DoUsuniecia;
			--SELECT * FROM #Cechy;
			
			IF @RequestType = 'Dictionary_Delete'
			BEGIN				
				
				-- pobranie daty usuniecia na podstawie przekazanego AppDate
				SELECT @DataUsunieciaApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'DELETE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					--sprawdzenie czy podano do usuniecia slownik zablokowany do edycji					
					IF EXISTS (SELECT Id FROM dbo.Slowniki WHERE IsBlocked = 1 AND Id IN (SELECT ID FROM #DoUsuniecia))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć zamrożonego słownika.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
				
					IF @ZablokowanyDoEdycji = 0
					BEGIN
					
						--pobranie cech słownikowych, ktore tez maja byc usuniete razem ze slownikiem
						INSERT INTO #Cechy (ID)
						SELECT Cecha_ID AS ID
						FROM dbo.[Cechy]
						WHERE CzySlownik = 1 AND TypId IN (SELECT ID FROM #DoUsuniecia);					
						
						BEGIN TRAN T1_Dictionary_Delete
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curDictionary_Delete') > 0 
						BEGIN
							 CLOSE curDictionary_Delete
							 DEALLOCATE curDictionary_Delete
						END
					
						--pobranie warunkow usuniecia danych w trybie miekkim i twardym
						SET @DeleteHardCondition = THB.GetHardDeleteCondition();
						SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();
								
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE curDictionary_Delete CURSOR LOCAL FOR 
							SELECT Nazwa FROM TypObiektu WHERE IdArch IS NULL
						OPEN curDictionary_Delete
						FETCH NEXT FROM curDictionary_Delete INTO @TypObiektu
						WHILE @@FETCH_STATUS = 0
						BEGIN		
							IF @UsuwanieMiekkie = 0
							BEGIN									
								--trwale usuwanie danych z bazy
								SET @Query += ' 
								IF OBJECT_ID (N''"[_' + @TypObiektu + '_Cechy_Hist]"'', N''U'') IS NOT NULL
								BEGIN
									DELETE FROM [dbo].[_' + @TypObiektu + '_Cechy_Hist] 
									WHERE CechaID IN (SELECT ID FROM #Cechy)' + @DeleteHardCondition + '
									
									--usuwanie na miekko reszty danych ktore nie zostaly usuniete na twardo ze wzgledu na statusW
									UPDATE [dbo].[_' + @TypObiektu + '_Cechy_Hist] SET
										IsValid = 0,
										IsDeleted = 1,
										DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
										DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
										ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
										RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE CechaID IN (SELECT ID FROM #Cechy) AND IsDeleted = 0' + @DeleteSoftCondition + ';								
								END';
							END
							ELSE
							BEGIN
								--ustawienie odpowiednich flag w usuwaniu na miekko, bez dodatkowych warunkow
								SET @Query += '
								IF OBJECT_ID (N''"[_' + @TypObiektu + '_Cechy_Hist]"'', N''U'') IS NOT NULL
								BEGIN 
									UPDATE [dbo].[_' + @TypObiektu + '_Cechy_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE CechaID IN (SELECT ID FROM #Cechy);
								END'
							END
							
							FETCH NEXT FROM curDictionary_Delete INTO @TypObiektu
						END
						CLOSE curDictionary_Delete
						DEALLOCATE curDictionary_Delete			

						--usuniecie danych z kazdej tabeli typu obiektu
						--PRINT @Query;
						EXEC sp_executesql @Query						
				
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','cur2') > 0 
						BEGIN
							 CLOSE cur2
							 DEALLOCATE cur2
						END
								
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE cur2 CURSOR LOCAL FOR 
							SELECT Id FROM #DoUsuniecia
						OPEN cur2
						FETCH NEXT FROM cur2 INTO @Id
						WHILE @@FETCH_STATUS =0
						BEGIN	
							--pobranie nazwy slownika
							SELECT @NazwaSlownika = Nazwa
							FROM dbo.Slowniki
							WHERE Id = @Id;
							
							--usuwanie danych na twardo	
							IF @UsuwanieMiekkie = 0
							BEGIN									
								SET @Query = '							
									DELETE FROM [TypRelacji_Cechy]
									WHERE Cecha_ID IN (SELECT ID FROM #Cechy)' + @DeleteHardCondition + ';
									
									DELETE FROM [TypObiektu_Cechy]
									WHERE Cecha_ID IN (SELECT ID FROM #Cechy)' + @DeleteHardCondition + ';
									
									DELETE FROM [Relacja_Cecha_Hist]
									WHERE CechaID IN (SELECT ID FROM #Cechy)' + @DeleteHardCondition + ';
									
									DELETE FROM dbo.[Branze_Cechy]
									WHERE CechaId IN (SELECT ID FROM #Cechy)' + @DeleteHardCondition + ';
									
									DELETE FROM dbo.[Cechy]
									WHERE Cecha_ID IN (SELECT ID FROM #Cechy)' + @DeleteHardCondition + ';
									
									DELETE FROM dbo.Slowniki
									WHERE (Id = @Id OR IdArch = @Id)' + @DeleteHardCondition + ';
									
									IF @@ROWCOUNT > 0
										SET @UsunietoNaTwardo = 1;
									ELSE
										SET @UsunietoNaTwardo = 0'
								
									--PRINT @Query;
									EXEC sp_executesql @Query, N'@Id int, @UsunietoNaTwardo bit OUTPUT', @Id = @Id, @UsunietoNaTwardo = @UsunietoNaTwardo OUTPUT
									
								IF @UsunietoNaTwardo = 1
									SET @Usunieto = 1;
								
								--ustawienie odpowiednich flag w usuwaniu na miekko danych ktorych nie mozna bylo usunac na twardo	
								SET @Query = '								
									UPDATE [TypRelacji_Cechy] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE Cecha_ID IN (SELECT ID FROM #Cechy) AND IsDeleted = 0' + @DeleteSoftCondition + ';
									
									UPDATE [TypObiektu_Cechy] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE Cecha_ID IN (SELECT ID FROM #Cechy) AND IsDeleted = 0' + @DeleteSoftCondition + ';
							
									UPDATE [Relacja_Cecha_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE CechaID IN (SELECT ID FROM #Cechy) AND IsDeleted = 0' + @DeleteSoftCondition + ';
									
									UPDATE dbo.[Branze_Cechy] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE CechaId IN (SELECT ID FROM #Cechy) AND IsDeleted = 0' + @DeleteSoftCondition + ';
									
									UPDATE dbo.[Cechy] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE Cecha_ID IN (SELECT ID FROM #Cechy) AND IsDeleted = 0' + @DeleteSoftCondition + ';'
								
								SET @Query += '
									IF OBJECT_ID (N''[_Slownik_' + @NazwaSlownika + ']'', N''U'') IS NOT NULL
									BEGIN
										UPDATE dbo.[_Slownik_' + @NazwaSlownika + '] SET
										IsValid = 0,
										IsDeleted = 1,
										DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
										DeletedFrom = @DataUsunieciaApp,
										ValidTo = @DataUsunieciaApp,
										RealDeletedFrom = @DataUsuniecia
										WHERE IsValid = 1 AND IsDeleted = 0' + @DeleteSoftCondition + '
									END							
								
									UPDATE dbo.Slowniki SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE IsDeleted = 0 AND (Id = @Id OR IdArch = @Id)' + @DeleteSoftCondition + '
								
									IF @@ROWCOUNT > 0
										SET @Usunieto = 1;'
								
								--PRINT @Query;
								EXEC sp_executesql @Query, N'@Id int, @DataUsunieciaApp datetime, @DataUsuniecia datetime, @Usunieto bit OUTPUT', 
									@Id = @Id, @DataUsunieciaApp = @DataUsunieciaApp, @DataUsuniecia = @DataUsuniecia, @Usunieto = @Usunieto OUTPUT								
								
								--usunieto dane na miekko wiec zmieniamy nazwy tabel
								IF @UsunietoNaTwardo = 0
								BEGIN
									EXEC [THB].[ChangeDictionaryTableName]
										@DictionaryName = @NazwaSlownika,
										@DeletedFrom = @DataUsunieciaApp
								END								
								
							END
							ELSE  --usuwanie danych na miekko
							BEGIN
								
								--ustawienie odpowiednich flag						
								UPDATE [TypRelacji_Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE Cecha_ID IN (SELECT ID FROM #Cechy) AND IsDeleted = 0;
								
								UPDATE [TypObiektu_Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE Cecha_ID IN (SELECT ID FROM #Cechy) AND IsDeleted = 0;
							
								UPDATE [Relacja_Cecha_Hist] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE CechaID IN (SELECT ID FROM #Cechy) AND IsDeleted = 0;
								
								UPDATE dbo.[Branze_Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE CechaId IN (SELECT ID FROM #Cechy) AND IsDeleted = 0;
								
								UPDATE dbo.[Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE Cecha_ID IN (SELECT ID FROM #Cechy) AND IsDeleted = 0;
							
								SET @Query = '
								IF OBJECT_ID (N''[_Slownik_' + @NazwaSlownika + ']'', N''U'') IS NOT NULL
								BEGIN
									UPDATE dbo.[_Slownik_' + @NazwaSlownika + '] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE IsValid = 1 AND IsDeleted = 0
								END'
								
								EXEC sp_executesql @Query
								
								UPDATE dbo.Slowniki SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND (Id = @Id OR IdArch = @Id)
								
								IF @@ROWCOUNT > 0
									SET @Usunieto = 1;
							
								--zmiana nazwy tabeli usunietego slownika
								EXEC [THB].[ChangeDictionaryTableName]
									@DictionaryName = @NazwaSlownika,
									@DeletedFrom = @DataUsunieciaApp
												
							END				
							
							FETCH NEXT FROM cur2 INTO @Id						
						END
						CLOSE cur2
						DEALLOCATE cur2
						
						COMMIT TRAN T1_Dictionary_Delete
					END
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Dictionary_Delete', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Dictionary_Delete', @Wiadomosc = @ERRMSG OUTPUT
		END
				
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_Dictionary_Delete
		END
	END CATCH
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Dictionary_Delete"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';

	SET @XMLDataOut += '>';

	IF @ERRMSG IS NULL OR @ERRMSG = ''
	BEGIN
		IF @Usunieto = 1
			SET @XMLDataOut += '<Result><Value>true</Value></Result>';
		ELSE
			SET @XMLDataOut += '<Result><Value/></Result>';
	END
	ELSE
	BEGIN			
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>'; 
	END
	
	SET @XMLDataOut += '</Response>';
	
	--usuniecie tabel tymczasowych			
	IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
		DROP TABLE #DoUsuniecia
		
	IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
		DROP TABLE #Cechy
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 
	
END
