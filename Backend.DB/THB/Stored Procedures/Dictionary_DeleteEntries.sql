-- =============================================
-- Author:		DK
-- Create date: 2012-05-16
-- Last modified on: 2013-04-04
-- Description:	Usuwa wskazane elementy konkretnego slownika

-- Przyjmuje XML wejsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Request RequestType="Dictionary_DeleteEntries" IsSoftDelete="true" UserId="1" AppDate="2012-02-09T13:45:22">
	--	<Ref Id="15" EntityType="Dictionary">
	--		<Ref Id="1" EntityType="DictionaryEntry"/>
	--		<Ref Id="2" EntityType="DictionaryEntry"/>
	--		<Ref Id="3" EntityType="DictionaryEntry"/>
	--		<Ref Id="4" EntityType="DictionaryEntry"/>
	--		<Ref Id="5" EntityType="DictionaryEntry"/>
	--	</Ref>
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="Dictionary_Delete"" AppDate="2012-02-09" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Error ErrorMessage="ble vble"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Dictionary_DeleteEntries]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@NazwaSlownika nvarchar(256),
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
		@IdSlownika int,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100) = '',
		@DeleteSoftCondition varchar(100) = '',
		@UsunietoNaTwardo bit = 0,
		@ZablokowanyDoEdycji bit = 0

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych			
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
			
		CREATE TABLE #DoUsuniecia(SlownikId int, ElementId int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_DeleteEntries', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
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
			
			--pobranie id typow cech do usuniecia
			INSERT INTO #DoUsuniecia (SlownikId, ElementId)
			SELECT C.value('../@Id', 'int')
			, C.value('./@Id', 'int') 
			FROM @xml_data.nodes('/Request/Ref/Ref') T(C)
			WHERE C.value('../@EntityType', 'nvarchar(30)') = 'Dictionary' AND C.value('./@EntityType', 'nvarchar(30)') = 'DictionaryEntry'		
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie			
			--SELECT * FROM #DoUsuniecia;
	
			IF @RequestType = 'Dictionary_DeleteEntries'
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
					IF EXISTS (SELECT Id FROM dbo.Slowniki WHERE IsBlocked = 1 AND Id IN (SELECT SlownikId FROM #DoUsuniecia))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć wpisu z zamrożonego słownika.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
				
					IF @ZablokowanyDoEdycji = 0
					BEGIN
				
						--pobranie warunkow usuniecia danych w trybie miekkim i twardym
						SET @DeleteHardCondition = THB.GetHardDeleteCondition();
						SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();
					
						BEGIN TRAN T1_Dictionary_DeleteEntries
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','cur') > 0 
						BEGIN
							 CLOSE cur
							 DEALLOCATE cur
						END
							
						DECLARE cur CURSOR LOCAL FOR 
							SELECT DISTINCT SlownikId FROM #DoUsuniecia
						OPEN cur
						FETCH NEXT FROM cur INTO @IdSlownika
						WHILE @@FETCH_STATUS = 0
						BEGIN		
							
							SELECT @NazwaSlownika = Nazwa
							FROM dbo.Slowniki
							WHERE Id = @IdSlownika
							
							IF @UsuwanieMiekkie = 0
							BEGIN									
								--trwale usuwanie danych z bazy
								SET @Query += ' 
								IF OBJECT_ID (N''[_Slownik_' + @NazwaSlownika + ']'', N''U'') IS NOT NULL
								BEGIN
									DELETE FROM [dbo].[_Slownik_' + @NazwaSlownika + '] 
									WHERE Id IN (SELECT ElementId FROM #DoUsuniecia WHERE SlownikId = ' + CAST(@IdSlownika AS varchar) + ')' + @DeleteHardCondition + ';
									
									IF @@ROWCOUNT > 0
										SET @Usunieto = 1;
									
									UPDATE [dbo].[_Slownik_' + @NazwaSlownika + '] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE Id IN (SELECT ElementId FROM #DoUsuniecia WHERE SlownikId = ' + CAST(@IdSlownika AS varchar) + ') AND IsValid = 1 AND IsDeleted = 0' + @DeleteSoftCondition + '
								END';
							END
							ELSE
							BEGIN
								--ustawienie odpowiednich flag
								SET @Query += '
								IF OBJECT_ID (N''[_Slownik_' + @NazwaSlownika + ']'', N''U'') IS NOT NULL
								BEGIN 
									UPDATE [dbo].[_Slownik_' + @NazwaSlownika + '] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE Id IN (SELECT ElementId FROM #DoUsuniecia WHERE SlownikId = ' + CAST(@IdSlownika AS varchar) + ') AND IsValid = 1 AND IsDeleted = 0;
								END'
							END
							
							FETCH NEXT FROM cur INTO @IdSlownika
						END
						CLOSE cur
						DEALLOCATE cur			

						--usuniecie danych z kazdej tabeli typu obiektu
						--PRINT @Query;
						EXEC sp_executesql @Query, N'@Usunieto bit OUTPUT', @Usunieto = @Usunieto OUTPUT						

						IF @@ROWCOUNT > 0
							SET @Usunieto = 1;
											
						COMMIT TRAN T1_Dictionary_DeleteEntries
					END
	
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Dictionary_DeleteEntries', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Dictionary_DeleteEntries', @Wiadomosc = @ERRMSG OUTPUT
		END
				
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_Dictionary_DeleteEntries
		END
	END CATCH
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Dictionary_DeleteEntries"';
	
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
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
