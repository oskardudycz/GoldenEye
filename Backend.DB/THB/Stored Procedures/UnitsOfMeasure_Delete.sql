-- =============================================
-- Author:		DK
-- Create date: 2012-03-16
-- Last modified on: 2013-03-20
-- Description:	Usuwa wpis z tabeli JednostkiMiary o podanych Id.
-- Usuwane (modyfikowane) sa takze wiersze w tabelach powiazanych z usuwanym typem cechy.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="UnitsOfMeasure_Delete" UserId="1" AppDate="2012-02-09T12:45:22" IsSoftDelete="false" 
	--	xsi:noNamespaceSchemaLocation="10.1.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="UnitOfMeasure" />
	--	<Ref Id="2" EntityType="UnitOfMeasure" />
	--	<Ref Id="3" EntityType="UnitOfMeasure" />
	--	<Ref Id="4" EntityType="UnitOfMeasure" />
	--	<Ref Id="5" EntityType="UnitOfMeasure" />
	--	<Ref Id="6" EntityType="UnitOfMeasure" />
	--	<Ref Id="7" EntityType="UnitOfMeasure" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="UnitsOfMeasure_Delete" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="8.1.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
		--	<Value>true</Value>
		--LUB
		--	<Error ErrorMessage="ble vble"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitsOfMeasure_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255) = '',
		@xmlOk bit = 0,
		@xml_data xml,
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@TypObiektu nvarchar(256),
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@MoznaUsuwacNaTwardo bit = 0,
		@JednostkaMiaryId int,
		@ZablokowanyDoEdycji bit

	BEGIN TRY
		
		--usuniecie tabel tymczasowych		
		IF OBJECT_ID('tempdb..#JednostkiMiary') IS NOT NULL
			DROP TABLE #JednostkiMiary
			
		IF OBJECT_ID('tempdb..#CechyDlaJednostek') IS NOT NULL
			DROP TABLE #CechyDlaJednostek
		
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
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow cech do usuniecia
			SELECT C.value('./@Id', 'int') AS ID
			INTO #JednostkiMiary
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'UnitOfMeasure'
			
			SELECT c.Cecha_ID AS Id, c.JednostkaMiary AS JednostkaMiary
			INTO #CechyDlaJednostek
			FROM dbo.Cechy c
			WHERE c.JednostkaMiary IN (SELECT Id FROM #JednostkiMiary)
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			--SELECT * FROM #JednostkiMiary
			
			IF @RequestType = 'UnitsOfMeasure_Delete'
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
				
					--pobranie warunkow usuniecia danych w trybie miekkim i twardym
					SET @DeleteHardCondition = THB.GetHardDeleteCondition();
					SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();
					
					--sprawdzenie czy podano do usuniecia ceche zablokowana do edycji					
					IF EXISTS (SELECT Id FROM dbo.JednostkiMiary WHERE IsBlocked = 1 AND Id IN (SELECT ID FROM #JednostkiMiary))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć zamrożonej jednostki miary.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
					
					--jesli mozna usuwac to usuwamy jednostki miary
					IF @ZablokowanyDoEdycji = 0
					BEGIN
					
						BEGIN TRAN UoM_DELETE
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curJednostki') > 0 
						BEGIN
							 CLOSE curJednostki
							 DEALLOCATE curJednostki
						END
								
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE curJednostki CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #JednostkiMiary
						OPEN curJednostki
						FETCH NEXT FROM curJednostki INTO @JednostkaMiaryId
						WHILE @@FETCH_STATUS = 0
						BEGIN
					
							--sprawdzenie czy mozemy usuwac na twardo
							SET @Query = '
								IF EXISTS (SELECT Id FROM dbo.JednostkiMiary WHERE Id = ' + CAST(@JednostkaMiaryId AS varchar) + @DeleteHardCondition + ')
									SET @MoznaUsuwacNaTwardo = 1;
								ELSE
									SET @MoznaUsuwacNaTwardo = 0;'
									
							EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT	
									
							--jesli sa powiazane jakies cechy z usuwanym typem jednostki to usuwa tez dane cech
							IF (SELECT COUNT(1) FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId) > 0
							BEGIN
						
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local', 'curJednDelete') > 0 
								BEGIN
									 CLOSE curJednDelete
									 DEALLOCATE curJednDelete
								END
									
								--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
								DECLARE curJednDelete CURSOR LOCAL FOR 
									SELECT DISTINCT Nazwa FROM TypObiektu WHERE IdArch IS NULL
								OPEN curJednDelete
								FETCH NEXT FROM curJednDelete INTO @TypObiektu
								WHILE @@FETCH_STATUS = 0
								BEGIN		
									IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
									BEGIN									
										--trwale usuwanie danych z bazy
										SET @Query = ' 
										IF OBJECT_ID (N''[_' + @TypObiektu + '_Cechy_Hist]'', N''U'') IS NOT NULL
										BEGIN
											DELETE FROM [dbo].[_' + @TypObiektu + '_Cechy_Hist] 
											WHERE CechaID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = ' + CAST(@JednostkaMiaryId AS varchar) + ');
										END
									
										IF OBJECT_ID (N''[_' + @TypObiektu + '_Relacje_Hist]'', N''U'') IS NOT NULL
										BEGIN	
											DELETE FROM [dbo].[_' + @TypObiektu + '_Relacje_Hist] 
											WHERE CechaID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = ' + CAST(@JednostkaMiaryId AS varchar) + ');
										END';
									END
									ELSE
									BEGIN
										--ustawienie odpowiednich flag
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
											WHERE CechaID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = ' + CAST(@JednostkaMiaryId AS varchar) + ');
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
											WHERE CechaID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = ' + CAST(@JednostkaMiaryId AS varchar) + ');
										END'
									END
						
									--usuniecie danych z kazdej tabeli typu obiektu
									--PRINT @Query;
									EXEC(@Query);
									
									FETCH NEXT FROM curJednDelete INTO @TypObiektu
								END
								CLOSE curJednDelete
								DEALLOCATE curJednDelete	
							END
				
							--usuwanie pozostalych danych w zaleznosci od trybu usuwania
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN
								--jesli sa powiazane jakies cechy z usuwanym typem jednostki to usuwa tez dane cech
								IF (SELECT COUNT(1) FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId) > 0
								BEGIN
									DELETE FROM dbo.[TypObiektu_Cechy]
									WHERE Cecha_ID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId);
								
									DELETE FROM dbo.[TypRelacji_Cechy]
									WHERE Cecha_ID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId);
								
									DELETE FROM dbo.[Relacja_Cecha_Hist]
									WHERE CechaID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId);
									
									DELETE FROM [Branze_Cechy]
									WHERE CechaId IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId); 
									
									DELETE FROM [Cechy]
									WHERE Cecha_ID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId);
								END
							
								DELETE FROM [JednostkiMiary_Przeliczniki]
								WHERE IdFrom = @JednostkaMiaryId OR IdTo = @JednostkaMiaryId;
								
								DELETE FROM [JednostkiMiary]
								WHERE Id = @JednostkaMiaryId OR IdArch = @JednostkaMiaryId;
								
							END
							ELSE --IF @UsuwanieMiekkie = 3
							BEGIN
								--jesli sa powiazane jakies cechy z usuwanym typem jednostki to usuwa tez dane cech
								IF (SELECT COUNT(1) FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId) > 0
								BEGIN
									UPDATE dbo.[TypObiektu_Cechy] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = @UzytkownikID,
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE Cecha_ID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId);
							
									UPDATE dbo.[TypRelacji_Cechy] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = @UzytkownikID,
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE Cecha_ID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId);
										
									UPDATE dbo.[Relacja_Cecha_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = @UzytkownikID,
									ValidTo = @DataUsunieciaApp, 
									DeletedFrom = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia 
									WHERE CechaID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId);
									
									UPDATE [Branze_Cechy] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = @UzytkownikID,
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE CechaId IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId); 
										
									UPDATE [Cechy] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = @UzytkownikID,
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
									WHERE Cecha_ID IN (SELECT ID FROM #CechyDlaJednostek WHERE JednostkaMiary = @JednostkaMiaryId);
								END
							
								UPDATE [JednostkiMiary_Przeliczniki] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND (IdFrom = @JednostkaMiaryId OR IdTo = @JednostkaMiaryId);
								
								UPDATE [JednostkiMiary] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND (Id = @JednostkaMiaryId OR IdArch = @JednostkaMiaryId);
							END
							
							IF @@ROWCOUNT > 0
								SET @Usunieto = 1;
							
							FETCH NEXT FROM curJednostki INTO @JednostkaMiaryId
						END
						CLOSE curJednostki;
						DEALLOCATE curJednostki;
						
					COMMIT TRAN UoM_DELETE
				END
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitsOfMeasure_Delete', @Wiadomosc = @ERRMSG OUTPUT
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitsOfMeasure_Delete', @Wiadomosc = @ERRMSG OUTPUT
	END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN UoM_DELETE
		END
	END CATCH
	
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitsOfMeasure_Delete"';
	
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
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>'
	END
	
	SET @XMLDataOut += '</Response>';
	
	--usuniecie tabel tymczasowych		
	IF OBJECT_ID('tempdb..#JednostkiMiary') IS NOT NULL
		DROP TABLE #JednostkiMiary
		
	IF OBJECT_ID('tempdb..#CechyDlaJednostek') IS NOT NULL
		DROP TABLE #CechyDlaJednostek
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
