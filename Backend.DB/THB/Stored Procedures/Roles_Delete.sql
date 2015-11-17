-- =============================================
-- Author:		DK
-- Create date: 2012-03-21
-- Last modified on: 2013-02-19
-- Description:	Usuwa wpis z tabeli Role o podanych Id.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="Roles_Delete" UserId="1" StatusS="" StatusP="" StatusW="" AppDate="2012-02-09T11:23:11" IsSoftDelete="false" 
	--	xsi:noNamespaceSchemaLocation="17.3.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" GetFullColumnsData="false">
	--	<Ref Id="1" EntityType="Role" />
	--	<Ref Id="2" EntityType="Role" />
	--	<Ref Id="3" EntityType="Role" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="Roles_Delete" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="8.1.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
		--	<Value>true</Value>
		--LUB
		--	<Error ErrorMessage="ble vble"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Roles_Delete]
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
		@BranzaID int,
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
		@MoznaUsuwacNaTwardo bit = 0,
		@RolaId int

	BEGIN TRY
		
		--usuniecie tabel tymczasowych		
		IF OBJECT_ID('tempdb..#Role') IS NOT NULL
			DROP TABLE #Role
		
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
					,@BranzaID = c.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow cech do usuniecia
			SELECT C.value('./@Id', 'int') AS ID
			INTO #Role
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Role'			
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			--SELECT * FROM #Uzytkownicy
			
			IF @RequestType = 'Roles_Delete'
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
				
					--sprawdzenie czy w usuwanych rolach jest rola zastrzezona (wbudowana w system)
					IF NOT EXISTS (SELECT ID FROM #Role WHERE ID < 5)
					BEGIN
						BEGIN TRAN T1_ROLES_DELETE
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curRole') > 0 
						BEGIN
							 CLOSE curRole
							 DEALLOCATE curRole
						END
								
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE curRole CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #Role
						OPEN curRole
						FETCH NEXT FROM curRole INTO @RolaId
						WHILE @@FETCH_STATUS = 0
						BEGIN
						
							--sprawdzenie czy mozemy usuwac na twardo
							SET @Query = '
								IF EXISTS (SELECT Id FROM dbo.Role WHERE Id = ' + CAST(@RolaId AS varchar) + @DeleteHardCondition + ')
									SET @MoznaUsuwacNaTwardo = 1;
								ELSE
									SET @MoznaUsuwacNaTwardo = 0;'
									
							EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT
					
							--usuwanie pozostalych danych w zaleznosci od trybu usuwania
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN
								DELETE FROM [dbo].[RolaGrupaUzytkownikow]
								WHERE Rola = @RolaId;
								
								DELETE FROM [dbo].[RolaOperacja]
								WHERE Rola = @RolaId;
								
								DELETE FROM [dbo].[Role] 
								WHERE Id = @RolaId OR IdArch = @RolaId;						
							END
							ELSE
							BEGIN
								UPDATE [dbo].[RolaGrupaUzytkownikow] SET
								ObowiazujeDo = @DataUsunieciaApp,
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikId,
								DeletedFrom = @DataUsunieciaApp,
								LastModifiedOn = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								LastModifiedBy = @UzytkownikId,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND Rola = @RolaId;
								
								--UPDATE [dbo].[RolaOperacja] SET
								--ObowiazujeDo = @DataUsunieciaApp,
								--LastModifiedOn = @DataUsunieciaApp,
								--LastModifiedBy = @UzytkownikId,
								--RealLastModifiedOn = @DataUsuniecia
								--WHERE Rola = @RolaId;
								
								DELETE FROM [dbo].[RolaOperacja]
								WHERE Rola = @RolaId;
							
								UPDATE [dbo].[Role] SET
								ObowiazujeDo = @DataUsunieciaApp,
								IsValid = 0,
								ValidTo = @DataUsunieciaApp,
								IsDeleted = 1,
								DeletedBy = @UzytkownikId,
								DeletedFrom = @DataUsunieciaApp,
								LastModifiedOn = @DataUsunieciaApp,
								LastModifiedBy = @UzytkownikId,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND (Id = @RolaId OR IdArch = @RolaId);
							END
						
							IF @@ROWCOUNT > 0
							BEGIN
								SET @Usunieto = 1;
							END
							
							FETCH NEXT FROM curRole INTO @RolaId							
						END
						CLOSE curRole
						DEALLOCATE curRole
						
						COMMIT TRAN T1_ROLES_DELETE
					END
					ELSE
						SET @ERRMSG = 'Błąd. Nie można usunąć roli wbudowanej w system.';
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Roles_Delete', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Roles_Delete', @Wiadomosc = @ERRMSG OUTPUT 
		END
				
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN T1_ROLES_DELETE
			END
		END CATCH
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Roles_Delete"';
		
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
		IF OBJECT_ID('tempdb..#Role') IS NOT NULL
			DROP TABLE #Role
			
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 
	
END
