-- =============================================
-- Author:		DK
-- Create date: 2012-03-20
-- Last modified on: 2013-02-19
-- Description:	Usuwa wpis z tabeli TypRelacji o podanych Id.
-- Usuwane (modyfikowane) sa takze wiersze w tabelach powiazanych z usuwanym typem relacji.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="RelationTypes_Delete" UserId="1" StatusS="" StatusP="" StatusW="" AppDate="2012-02-09T11:45:21" IsSoftDelete="false">
	--	<Ref Id="1" EntityType="RelationType" />
	--	<Ref Id="2" EntityType="RelationType" />
	--	<Ref Id="3" EntityType="RelationType" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="RelationTypes_Delete" AppDate="2012-02-09">
	--	<Result>
		--	<Value>true</Value>
		--LUB
		--	<Error ErrorMessage="blad"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[RelationTypes_Delete]
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
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@TypRelacjiId int,
		@MoznaUsuwacNaTwardo bit = 0,
		@ZablokowanyDoEdycji bit = 0

	BEGIN TRY
		
		--usuniecie tabel tymczasowych		
		IF OBJECT_ID('tempdb..#TypyRelacji') IS NOT NULL
			DROP TABLE #TypyRelacji
			
		IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
			DROP TABLE #Relacje
		
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
			SELECT @DataProgramu = C.value('./@AppDate', 'nvarchar(20)')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow relacji do usuniecia
			SELECT C.value('./@Id', 'int') AS ID
			INTO #TypyRelacji
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'RelationType'			
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			--SELECT * FROM #TypyRelacji
			
			IF @RequestType = 'RelationTypes_Delete'
			BEGIN
			
				-- pobranie daty usuniecia na podstawie przekazanego AppDate
				SELECT @DataUsunieciaApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji delete
				EXEC [THB].[CheckUserPermission]
					@Operation = N'DELETE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
			
				IF @MaUprawnienia = 1
				BEGIN
				
					--sprawdzenie czy podano do usuniecia typ relacji zablokowany do edycji					
					IF EXISTS (SELECT TypRelacji_ID FROM dbo.TypRelacji WHERE IsBlocked = 1 AND TypRelacji_ID IN (SELECT ID FROM #TypyRelacji))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć zamrożonego typu relacji.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
			
					IF @ZablokowanyDoEdycji = 0
					BEGIN					
					
						--pobranie warunkow usuniecia danych w trybie miekkim i twardym
						SET @DeleteHardCondition = THB.GetHardDeleteCondition();
						SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();				
									
						--pobranie Id relacji powiazanch z danym typem relacji
						SELECT Id, TypRelacji_ID
						INTO #Relacje
						FROM Relacje WHERE TypRelacji_ID IN (SELECT ID FROM #TypyRelacji);
					
						BEGIN TRAN T1_RelationTypes_Delete
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curTypyRelacji') > 0 
						BEGIN
							 CLOSE curTypyRelacji
							 DEALLOCATE curTypyRelacji
						END
							
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE curTypyRelacji CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #TypyRelacji
						OPEN curTypyRelacji
						FETCH NEXT FROM curTypyRelacji INTO @TypRelacjiId
						WHILE @@FETCH_STATUS = 0
						BEGIN
							--sprawdzenie czy mozemy usuwac na twardo
							SET @Query = '
								IF EXISTS (SELECT TypRelacji_ID FROM dbo.TypRelacji WHERE TypRelacji_ID = ' + CAST(@TypRelacjiId AS varchar) + @DeleteHardCondition + ')
									SET @MoznaUsuwacNaTwardo = 1;
								ELSE
									SET @MoznaUsuwacNaTwardo = 0;'
									
							EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT					
				
							--usuwanie pozostalych danych w zaleznosci od trybu usuwania
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN
								DELETE FROM [dbo].[Struktura]
								WHERE RelacjaId IN (SELECT Id FROM #Relacje WHERE TypRelacji_ID = @TypRelacjiId);
								
								DELETE FROM [dbo].[TypRelacji_Cechy]
								WHERE TypRelacji_ID = @TypRelacjiId;
								
								DELETE FROM [dbo].[Relacje]
								WHERE TypRelacji_ID = @TypRelacjiId;
								
								DELETE FROM [dbo].[TypRelacji] 
								WHERE TypRelacji_ID = @TypRelacjiId OR IdArch = @TypRelacjiId;						
							END
							ELSE
							BEGIN
								UPDATE [dbo].[Struktura] SET
								ObowiazujeDo = @DataUsunieciaApp,
								IsValid = 0,
								ValidTo = @DataUsunieciaApp,
								IsDeleted = 1,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikId,
								LastModifiedOn = @DataUsunieciaApp,
								LastModifiedBy = @UzytkownikId,
								RealDeletedFrom = @DataUsuniecia
								WHERE RelacjaId IN (SELECT Id FROM #Relacje WHERE TypRelacji_ID = @TypRelacjiId);
								
								UPDATE [dbo].[TypRelacji_Cechy] SET
								ObowiazujeDo = @DataUsunieciaApp,
								IsValid = 0,
								IsDeleted = 1,
								ValidTo = @DataUsunieciaApp,
								LastModifiedOn = @DataUsunieciaApp,
								LastModifiedBy = @UzytkownikId,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikId,
								RealDeletedFrom = @DataUsuniecia
								WHERE TypRelacji_ID = @TypRelacjiId;
						
								UPDATE [dbo].[Relacje] SET
								ObowiazujeDo = @DataUsunieciaApp,
								IsValid = 0,
								ValidTo = @DataUsunieciaApp,
								IsDeleted = 1,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikId,
								LastModifiedOn = @DataUsunieciaApp,
								LastModifiedBy = @UzytkownikId,
								RealDeletedFrom = @DataUsuniecia
								WHERE TypRelacji_ID = @TypRelacjiId;
								
								UPDATE [dbo].[TypRelacji] SET
								IsValid = 0,
								ValidTo = @DataUsunieciaApp,
								ObowiazujeDo = @DataUsunieciaApp,
								IsDeleted = 1,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikId,
								LastModifiedOn = @DataUsunieciaApp,
								LastModifiedBy = @UzytkownikId,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND (TypRelacji_ID = @TypRelacjiId OR IdArch = @TypRelacjiId);	
							END
					
							IF @@ROWCOUNT > 0
							BEGIN
								SET @Usunieto = 1;
							END
							
							FETCH NEXT FROM curTypyRelacji INTO @TypRelacjiId
						END
						CLOSE curTypyRelacji;
						DEALLOCATE curTypyRelacji;
						
						COMMIT TRAN T1_RelationTypes_Delete
					END
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'RelationTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'RelationTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT	
		END
				
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN T1_RelationTypes_Delete
			END
		END CATCH
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="RelationTypes_Delete"'
		
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
		IF OBJECT_ID('tempdb..#TypyRelacji') IS NOT NULL
			DROP TABLE #TypyRelacji
			
		IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
			DROP TABLE #Relacje
			
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 	
END
