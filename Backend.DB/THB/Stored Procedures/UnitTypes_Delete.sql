-- =============================================
-- Author:		DK
-- Create date: 2012-03-13
-- Last modified on: 2013-02-15
-- Description:	Usuwa wpis z tabeli TypObiektu o podanych Id.
-- Usuwane (modyfikowane) sa takze wiersze w tabelach powiazanych z usuwanym typem obiektu.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="UnitTypes_Delete" UserId="1" AppDate="2012-02-09T11:11:09" IsSoftDelete="false">
	--	<Ref Id="1" EntityType="ObjectType" />
	--	<Ref Id="2" EntityType="ObjectType" />
	--	<Ref Id="3" EntityType="ObjectType" />
	--	<Ref Id="4" EntityType="ObjectType" />
	--	<Ref Id="5" EntityType="ObjectType" />
	--	<Ref Id="6" EntityType="ObjectType" />
	--	<Ref Id="7" EntityType="ObjectType" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="UnitTypes_Delete" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="8.1.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Error ErrorMessage="tresc bledu"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitTypes_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Id int,
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255),
		@xmlOk bit = 0,
		@xml_data xml,
		@MaUprawnienia bit = 0,
		@Usunieto bit = 0,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@ZablokowanyDoEdycji bit = 0,
		@NazwaTypuObiektu nvarchar(300),
		@Query nvarchar(MAX) = '',
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@UsunietoNaTwardo bit = 0

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
			
		IF OBJECT_ID('tempdb..#ObiektyAlgorytmy') IS NOT NULL
			DROP TABLE #ObiektyAlgorytmy
			
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#TypyStrukturyObiektId') IS NOT NULL
			DROP TABLE #TypyStrukturyObiektId;	
			
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#StrukturyObiekt') IS NOT NULL
			DROP TABLE #StrukturyObiekt;	
		
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
				
			--wyciaganie daty i typu zadania
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow cech do usuniecia
			SELECT C.value('./@Id', 'int') AS ID
			INTO #DoUsuniecia
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(30)') = 'UnitType'
			
			--SELECT * FROM #DoUsuniecia				
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			
			IF @RequestType = 'UnitTypes_Delete'
			BEGIN														
				
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @DataUsunieciaApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'DELETE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
					
					--sprawdzenie czy podano do usuniecia typ obiektu zablokowany do edycji					
					IF EXISTS (SELECT TypObiekt_ID FROM dbo.TypObiektu WHERE IsBlocked = 1 AND TypObiekt_ID IN (SELECT ID FROM #DoUsuniecia))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć zamrożonego typu obiektu.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
					
					IF @ZablokowanyDoEdycji = 0
					BEGIN
						
						--pobranie warunkow usuniecia danych w trybie miekkim i twardym
						SET @DeleteHardCondition = THB.GetHardDeleteCondition();
						SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();
						
						BEGIN TRANSACTION UT_DELETE
						
						--pobranie id typow struktury obiektu by mozna bylo usunac dane z tabeli Struktura_Obiekt
						SELECT Id, TypObiektuIdRoot AS TypObiektuId 
						INTO #TypyStrukturyObiektId 
						FROM [TypStruktury_Obiekt]
						WHERE TypObiektuIdRoot IN (SELECT ID FROM #DoUsuniecia);
						
						--pobranie struktur dla podanych typow struktur
						SELECT so.Id, tso.TypObiektuIdRoot AS TypObiektuId
						INTO #StrukturyObiekt
						FROM [Struktura_Obiekt] so
						JOIN [TypStruktury_Obiekt] tso ON (so.TypStruktury_Obiekt_Id = tso.Id)						
						WHERE so.TypStruktury_Obiekt_Id IN (SELECT ID FROM #TypyStrukturyObiektId);
						
						--pobranie Id obiektow w tabelach z algorytmami dla danego typu obiektu
						SELECT Id, TypObiektuId
						INTO #ObiektyAlgorytmy
						FROM [Alg_Obiekty]
						WHERE TypObiektuId IN (SELECT ID FROM #DoUsuniecia);
									
						--SELECT * FROM #TypyStrukturyObiektId;
						--SELECT * FROM #DoUsuniecia;
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curUT_Delete') > 0 
						BEGIN
							 CLOSE curUT_Delete
							 DEALLOCATE curUT_Delete
						END
						
						--petla po wszystkich typach obiektu do usuniecia						
						DECLARE curUT_Delete CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #DoUsuniecia
						OPEN curUT_Delete
						FETCH NEXT FROM curUT_Delete INTO @Id
						WHILE @@FETCH_STATUS = 0
						BEGIN	
							--pobranie nazwy typu obiektu
							SELECT @NazwaTypuObiektu = Nazwa
							FROM dbo.TypObiektu
							WHERE TypObiekt_Id = @Id;		
											
							--usuwanie pozostalych danych w zaleznosci od trybu usuwania
							IF @UsuwanieMiekkie = 0
							BEGIN
								--trwale usuwanie danych z powiazanych tabel
								SET @Query = '					
									DELETE FROM [Struktura]
									WHERE StrukturaObiektId IN (SELECT Id FROM #StrukturyObiekt WHERE TypObiektuId = @Id)' + @DeleteHardCondition + ';
									
									DELETE FROM [Relacje]
									WHERE TypStruktury_Obiekt_Id IN (SELECT Id FROM #TypyStrukturyObiektId WHERE TypObiektuId = @Id)' + @DeleteHardCondition + ';	 
									
									DELETE FROM [TypStruktury]
									WHERE TypObiektuId_L = @Id OR TypObiektuId_R = @Id OR TypStruktury_Obiekt_Id IN (SELECT ID FROM #TypyStrukturyObiektId WHERE TypObiektuId = @Id)' + @DeleteHardCondition + ';
									
									DELETE FROM [Struktura_Obiekt] 
									WHERE TypStruktury_Obiekt_ID IN (SELECT Id FROM #TypyStrukturyObiektId WHERE TypObiektuId = @Id)' + @DeleteHardCondition + ';
									
									DELETE FROM [TypObiektu_Cechy]
									WHERE TypObiektu_ID = @Id' + @DeleteHardCondition + ';
									
									DELETE FROM [TypStruktury_Obiekt]
									WHERE TypObiektuIdRoot = @Id' + @DeleteHardCondition + ';
									
									DELETE FROM [Alg_ObiektyCechy]
									WHERE ObiektId IN (SELECT Id FROM #ObiektyAlgorytmy WHERE TypObiektuId = @Id);
									
									DELETE FROM [Alg_ObiektyRelacje]
									WHERE ObiektId_L IN (SELECT Id FROM #ObiektyAlgorytmy WHERE TypObiektuId = @Id) OR ObiektId_R IN (SELECT Id FROM #ObiektyAlgorytmy WHERE TypObiektuId = @Id);
									
									DELETE FROM [Alg_Obiekty]
									WHERE Id IN (SELECT Id FROM #ObiektyAlgorytmy WHERE TypObiektuId = @Id);
					
									DELETE FROM [TypObiektu]
									WHERE (TypObiekt_ID = @Id OR IdArch = @Id)' + @DeleteHardCondition + ';
									
									IF @@ROWCOUNT > 0
										SET @UsunietoNaTwardo = 1;
									ELSE
										SET @UsunietoNaTwardo = 0'
								
								--PRINT @Query
								EXEC sp_executesql @Query, N'@Id int, @UsunietoNaTwardo bit OUTPUT', @Id = @Id, @UsunietoNaTwardo = @UsunietoNaTwardo OUTPUT
								
								IF @UsunietoNaTwardo = 1
									SET @Usunieto = 1;
									
								--ustawienie odpowiednich flag w usuwaniu na miekko danych ktorych nie mozna bylo usunac na twardo	
								SET @Query = '		
									UPDATE [Struktura] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedFrom = @DataUsunieciaApp,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE IsDeleted = 0 AND StrukturaObiektId IN (SELECT Id FROM #StrukturyObiekt WHERE TypObiektuId = @Id)' + @DeleteSoftCondition + ';
									
									UPDATE [Relacje] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedFrom = @DataUsunieciaApp,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE IsDeleted = 0 AND TypStruktury_Obiekt_Id IN (SELECT Id FROM #TypyStrukturyObiektId WHERE TypObiektuId = @Id)' + @DeleteSoftCondition + ';
							
									UPDATE [TypStruktury] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedFrom = @DataUsunieciaApp,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE IsDeleted = 0 AND (TypObiektuId_L = @Id OR TypObiektuId_R = @Id OR TypStruktury_Obiekt_Id IN (SELECT ID FROM #TypyStrukturyObiektId WHERE TypObiektuId = @Id))' + @DeleteSoftCondition + ';
									
									UPDATE [Struktura_Obiekt] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedFrom = @DataUsunieciaApp,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE IsDeleted = 0 AND TypStruktury_Obiekt_ID IN (SELECT Id FROM #TypyStrukturyObiektId WHERE TypObiektuId = @Id)' + @DeleteSoftCondition + ';'
								
								SET @Query += '
									UPDATE [TypObiektu_Cechy] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedFrom = @DataUsunieciaApp,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE IsDeleted = 0 AND TypObiektu_ID = @Id' + @DeleteSoftCondition + ';
									
									UPDATE [TypStruktury_Obiekt] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedFrom = @DataUsunieciaApp,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE IsDeleted = 0 AND TypObiektuIdRoot = @Id' + @DeleteSoftCondition + ';
						
									DELETE FROM [Alg_ObiektyCechy]
									WHERE ObiektId IN (SELECT Id FROM #ObiektyAlgorytmy);
									
									DELETE FROM [Alg_ObiektyRelacje]
									WHERE ObiektId_L IN (SELECT Id FROM #ObiektyAlgorytmy WHERE TypObiektuId = @Id) OR ObiektId_R IN (SELECT Id FROM #ObiektyAlgorytmy WHERE TypObiektuId = @Id);
									
									DELETE FROM [Alg_Obiekty]
									WHERE Id IN (SELECT Id FROM #ObiektyAlgorytmy WHERE TypObiektuId = @Id);'
									
								SET @Query += '	
									IF OBJECT_ID (N''[_' + @NazwaTypuObiektu + ']'', N''U'') IS NOT NULL
									BEGIN
										UPDATE dbo.[_' + @NazwaTypuObiektu + '] SET
										IsValid = 0,
										IsDeleted = 1,
										DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
										DeletedFrom = @DataUsunieciaApp,
										ValidTo = @DataUsunieciaApp,
										RealDeletedFrom = @DataUsuniecia
										WHERE IsValid = 1 AND IsDeleted = 0' + @DeleteSoftCondition + '
									END	
									
									IF OBJECT_ID (N''[_' + @NazwaTypuObiektu + '_Cechy_Hist]'', N''U'') IS NOT NULL
									BEGIN
										UPDATE dbo.[_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
										IsValid = 0,
										IsDeleted = 1,
										DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
										DeletedFrom = @DataUsunieciaApp,
										ValidTo = @DataUsunieciaApp,
										RealDeletedFrom = @DataUsuniecia
										WHERE IsValid = 1 AND IsDeleted = 0' + @DeleteSoftCondition + '
									END	
							
									UPDATE [TypObiektu] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedFrom = @DataUsunieciaApp,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE IsDeleted = 0 AND (TypObiekt_ID = @Id OR IdArch = @Id)' + @DeleteSoftCondition + '
									
									IF @@ROWCOUNT > 0
										SET @Usunieto = 1;';
										
								--PRINT @Query;
								EXEC sp_executesql @Query, N'@Id int, @DataUsunieciaApp datetime, @DataUsuniecia datetime, @Usunieto bit OUTPUT', 
									@Id = @Id, @DataUsunieciaApp = @DataUsunieciaApp, @DataUsuniecia = @DataUsuniecia, @Usunieto = @Usunieto OUTPUT								
								
								--usunieto dane na miekko wiec zmieniamy nazwy tabel
								IF @UsunietoNaTwardo = 0
								BEGIN
									EXEC [THB].[ChangeDictionaryTableName]
										@DictionaryName = @NazwaTypuObiektu,
										@DeletedFrom = @DataUsunieciaApp
								END		
							END
							ELSE
							BEGIN	
								--miekkie usuwanie danych, ustawenie odpowiednich flag										
								UPDATE [Struktura] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikID,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND StrukturaObiektId IN (SELECT Id FROM #StrukturyObiekt);
								
								UPDATE [Relacje] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikID,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND TypStruktury_Obiekt_Id IN (SELECT Id FROM #TypyStrukturyObiektId);
							
								UPDATE [TypStruktury] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikID,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND (TypObiektuId_L IN (SELECT ID FROM #DoUsuniecia) OR TypObiektuId_R IN (SELECT ID FROM #DoUsuniecia) OR TypStruktury_Obiekt_Id IN (SELECT ID FROM #TypyStrukturyObiektId));
								
								UPDATE [Struktura_Obiekt] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikID,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND TypStruktury_Obiekt_ID IN (SELECT Id FROM #TypyStrukturyObiektId);
							
								UPDATE [TypObiektu_Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikID,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND TypObiektu_ID IN (SELECT ID FROM #DoUsuniecia);
							
								UPDATE [TypStruktury_Obiekt] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikID,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND TypObiektuIdRoot IN (SELECT ID FROM #DoUsuniecia);
							
								DELETE FROM [Alg_ObiektyCechy]
								WHERE ObiektId IN (SELECT Id FROM #ObiektyAlgorytmy);
								
								DELETE FROM [Alg_ObiektyRelacje]
								WHERE ObiektId_L IN (SELECT Id FROM #ObiektyAlgorytmy) OR ObiektId_R IN (SELECT Id FROM #ObiektyAlgorytmy);
								
								DELETE FROM [Alg_Obiekty]
								WHERE Id IN (SELECT Id FROM #ObiektyAlgorytmy);
								
								SET @Query += '	
									IF OBJECT_ID (N''[_' + @NazwaTypuObiektu + ']'', N''U'') IS NOT NULL
									BEGIN
										UPDATE dbo.[_' + @NazwaTypuObiektu + '] SET
										IsValid = 0,
										IsDeleted = 1,
										DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
										DeletedFrom = @DataUsunieciaApp,
										ValidTo = @DataUsunieciaApp,
										RealDeletedFrom = @DataUsuniecia
										WHERE IsValid = 1 AND IsDeleted = 0' + @DeleteSoftCondition + '
									END	
									
									IF OBJECT_ID (N''[_' + @NazwaTypuObiektu + '_Cechy_Hist]'', N''U'') IS NOT NULL
									BEGIN
										UPDATE dbo.[_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
										IsValid = 0,
										IsDeleted = 1,
										DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
										DeletedFrom = @DataUsunieciaApp,
										ValidTo = @DataUsunieciaApp,
										RealDeletedFrom = @DataUsuniecia
										WHERE IsValid = 1 AND IsDeleted = 0' + @DeleteSoftCondition + '
									END'
									
								--PRINT @Query;
								EXEC sp_executesql @Query, N'@DataUsunieciaApp datetime, @DataUsuniecia datetime', 
									@DataUsunieciaApp = @DataUsunieciaApp, @DataUsuniecia = @DataUsuniecia	
					
								UPDATE [TypObiektu] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikID,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND (TypObiekt_ID = @Id OR IdArch = @Id);
								
								IF @@ROWCOUNT > 0
									SET @Usunieto = 1;
								
								--zmiana nazw tabel, trigerow i kluczy usuwanego typu obiektu na miekko
								EXEC [THB].[ChangeUnitTypeTableName]
									@UnitTypeName = @NazwaTypuObiektu,
									@DeletedFrom = @DataUsunieciaApp			
		
							END
							
							FETCH NEXT FROM curUT_Delete INTO @Id
						END
						CLOSE curUT_Delete;
						DEALLOCATE curUT_Delete;
							
						COMMIT TRAN UT_DELETE
					END
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT
		END
				
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION UT_DELETE
			END
		END CATCH
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitTypes_Delete"';
		
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
			SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>';
		
		SET @XMLDataOut += '</Response>';
		
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
			
		IF OBJECT_ID('tempdb..#ObiektyAlgorytmy') IS NOT NULL
			DROP TABLE #ObiektyAlgorytmy
			
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#TypyStrukturyObiektId') IS NOT NULL
			DROP TABLE #TypyStrukturyObiektId;	
			
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#StrukturyObiekt') IS NOT NULL
			DROP TABLE #StrukturyObiekt;
			
		--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
