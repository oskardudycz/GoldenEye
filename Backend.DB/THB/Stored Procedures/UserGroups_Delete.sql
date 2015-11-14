-- =============================================
-- Author:		DK
-- Create date: 2012-03-19
-- Last modified on: 2013-02-22
-- Description:	Usuwa wpis z tabeli GrupaUzytkownikow o podanych Id.
-- Usuwane (modyfikowane) sa takze wiersze w tabelach powiazanych z usuwanymi grupami uzytkownikow.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="UserGroups_Delete" UserId="1" StatusS="" StatusP="" StatusW="" AppDate="2012-02-09T12:45:22" IsSoftDelete="false" 
	--	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" GetFullColumnsData="false">
	--	<Ref Id="1" EntityType="UserGroup" />
	--	<Ref Id="2" EntityType="UserGroup" />
	--	<Ref Id="3" EntityType="UserGroup" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="UserGroups_Delete" AppDate="2012-02-09">
	--	<Result>
		--	<Value>true</Value>
		--LUB
		--	<Error ErrorMessage="tresc bledu"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UserGroups_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@vTypObiektu nvarchar(256),
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255) = '',
		@xmlOk bit = 0,
		@xml_data xml,
		@result varchar(5) = 'true',
		@Id int,
		@MaUprawnienia bit = 0,
		@Usunieto bit = 0,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@MoznaUsuwacNaTwardo bit = 0,
		@GrupaUzytkownikowId int

	BEGIN TRY
		
		--usuniecie tabel tymczasowych		
		IF OBJECT_ID('tempdb..#Grupy') IS NOT NULL
			DROP TABLE #Grupy
		
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
			INTO #Grupy
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'UserGroup'			
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			--SELECT * FROM #Grupy
			
			IF @RequestType = 'UserGroups_Delete'
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
				
					--pobranie warunkow usuniecia danych w trybie miekkim i twardym
					SET @DeleteHardCondition = THB.GetHardDeleteCondition();
					SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();				
					
					IF NOT EXISTS (SELECT ID FROM #Grupy WHERE ID < 4)
					BEGIN
						BEGIN TRAN UG_DELETE
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local', 'curGrupyUzytkownikow') > 0 
						BEGIN
							 CLOSE curGrupyUzytkownikow
							 DEALLOCATE curGrupyUzytkownikow
						END
							
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE curGrupyUzytkownikow CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #Grupy
						OPEN curGrupyUzytkownikow
						FETCH NEXT FROM curGrupyUzytkownikow INTO @GrupaUzytkownikowId
						WHILE @@FETCH_STATUS = 0
						BEGIN
						
							--sprawdzenie czy mozemy usuwac na twardo
							SET @Query = '
								IF EXISTS (SELECT Id FROM dbo.GrupyUzytkownikow WHERE Id = ' + CAST(@GrupaUzytkownikowId AS varchar) + @DeleteHardCondition + ')
									SET @MoznaUsuwacNaTwardo = 1;
								ELSE
									SET @MoznaUsuwacNaTwardo = 0;'
									
							EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT	
									
								
							--usuwanie pozostalych danych w zaleznosci od trybu usuwania
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN
								DELETE FROM [dbo].[RolaGrupaUzytkownikow]
								WHERE GrupaUzytkownikow = @GrupaUzytkownikowId;
								
								DELETE FROM [dbo].[GrupaUzytkownikowUzytkownik]
								WHERE GrupaUzytkownikow = @GrupaUzytkownikowId;
								
								DELETE FROM [dbo].[GrupyUzytkownikow] 
								WHERE Id = @GrupaUzytkownikowId OR IdArch = @GrupaUzytkownikowId;						
							END
							ELSE
							BEGIN
								UPDATE [dbo].[RolaGrupaUzytkownikow] SET
								IsDeleted = 1,
								IsValid = 0,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikId,
								ObowiazujeDo = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND GrupaUzytkownikow = @GrupaUzytkownikowId;
								
								UPDATE [dbo].[GrupaUzytkownikowUzytkownik] SET
								IsDeleted = 1,
								IsValid = 0,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikId,
								ObowiazujeDo = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND GrupaUzytkownikow = @GrupaUzytkownikowId;
						
								UPDATE [dbo].[GrupyUzytkownikow] SET
								IsDeleted = 1,
								IsValid = 0,
								DeletedFrom = @DataUsunieciaApp,
								DeletedBy = @UzytkownikId,
								ObowiazujeDo = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND (Id = @GrupaUzytkownikowId OR IdArch = @GrupaUzytkownikowId);
							END
					
							IF @@ROWCOUNT > 0
							BEGIN
								SET @Usunieto = 1;
							END
							
							FETCH NEXT FROM curGrupyUzytkownikow INTO @GrupaUzytkownikowId							
						END
						CLOSE curGrupyUzytkownikow;
						DEALLOCATE curGrupyUzytkownikow;
						
						COMMIT TRAN UG_DELETE
					END
					ELSE
						SET @ERRMSG = 'Błąd. Nie można usunąć grupy użytkowników wbudowanej w system.';
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UserGroups_Delete', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UserGroups_Delete', @Wiadomosc = @ERRMSG OUTPUT
		END
				
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN UG_DELETE
			END
		END CATCH
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UserGroups_Delete"';
		
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
		IF OBJECT_ID('tempdb..#Grupy') IS NOT NULL
			DROP TABLE #Grupy
			
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
