-- =============================================
-- Author:		DK
-- Create date: 2012-03-16
-- Last modified on: 2013-02-22
-- Description:	Usuwa wpis z tabeli Uzytkownicy o podanych Id.
-- Usuwane (modyfikowane) sa takze wiersze w tabelach powiazanych z usuwanym typem cechy.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="Users_Delete" UserId="1" AppDate="2012-02-09T11:56:56" IsSoftDelete="false" 
	--	xsi:noNamespaceSchemaLocation="17.3.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" GetFullColumnsData="false">
	--	<Ref Id="1" EntityType="User" />
	--	<Ref Id="2" EntityType="User" />
	--	<Ref Id="3" EntityType="User" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="Users_Delete" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="8.1.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
		--	<Value>true</Value>
		--LUB
		--	<Error ErrorMessage="ble vble"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Users_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@Query nvarchar(MAX),
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
		@MoznaUsuwacNaTwardo bit = 0,
		@UzytkownikDoUsunieciaId int

	BEGIN TRY
		
		--usuniecie tabel tymczasowych		
		IF OBJECT_ID('tempdb..#Uzytkownicy') IS NOT NULL
			DROP TABLE #Uzytkownicy
		
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
					,@BranzaID = C.value('./@BranchId', 'int')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow cech do usuniecia
			SELECT C.value('./@Id', 'int') AS ID
			INTO #Uzytkownicy
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'User'			
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			--SELECT * FROM #Uzytkownicy
			
			IF @RequestType = 'Users_Delete'
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
					
					BEGIN TRAN T1_Users_Delete
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local', 'curUsers') > 0 
					BEGIN
						 CLOSE curUsers
						 DEALLOCATE curUsers
					END
						
					--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
					DECLARE curUsers CURSOR LOCAL FOR 
						SELECT DISTINCT Id FROM #Uzytkownicy
					OPEN curUsers
					FETCH NEXT FROM curUsers INTO @UzytkownikDoUsunieciaId
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						--sprawdzenie czy mozemy usuwac na twardo
						SET @Query = '
							IF EXISTS (SELECT Id FROM dbo.Uzytkownicy WHERE Id = ' + CAST(@UzytkownikDoUsunieciaId AS varchar) + @DeleteHardCondition + ')
								SET @MoznaUsuwacNaTwardo = 1;
							ELSE
								SET @MoznaUsuwacNaTwardo = 0;'
						
						--PRINT @Query;	
						EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT								
					
				
						--usuwanie pozostalych danych w zaleznosci od trybu usuwania
						IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
						BEGIN
							DELETE FROM [dbo].[GrupaUzytkownikowUzytkownik]
							WHERE Uzytkownik = @UzytkownikDoUsunieciaId;
							
							DELETE FROM [dbo].[Uzytkownicy_Ustawienia]
							WHERE UzytkownikId = @UzytkownikDoUsunieciaId;
							
							DELETE FROM [dbo].[Uzytkownicy] 
							WHERE Id = @UzytkownikDoUsunieciaId OR IdArch = @UzytkownikDoUsunieciaId;						
						END
						ELSE
						BEGIN
							UPDATE [dbo].[GrupaUzytkownikowUzytkownik] SET
							IsDeleted = 1,
							DeletedBy = @UzytkownikId,
							DeletedFrom = @DataUsunieciaApp,
							ObowiazujeDo = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE Uzytkownik = @UzytkownikDoUsunieciaId;
							
							UPDATE [dbo].[Uzytkownicy_Ustawienia] SET
							DeletedFrom = @DataUsunieciaApp,
							IsValid = 0
							WHERE UzytkownikId = @UzytkownikDoUsunieciaId;
							
							UPDATE [dbo].[Uzytkownicy] SET
							Aktywny = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikId,
							LastModifiedOn = @DataUsunieciaApp,
							LastModifiedBy = @UzytkownikId,
							ValidTo = @DataUsunieciaApp,
							IsValid = 0,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND (Id = @UzytkownikDoUsunieciaId OR IdArch = @UzytkownikDoUsunieciaId);
						END
					
						IF @@ROWCOUNT > 0
						BEGIN
							SET @Usunieto = 1;
						END
						
						FETCH NEXT FROM curUsers INTO @UzytkownikDoUsunieciaId
					END
					CLOSE curUsers;
					DEALLOCATE curUsers;
						
					COMMIT TRAN T1_Users_Delete
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Users_Delete', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Users_Delete', @Wiadomosc = @ERRMSG OUTPUT
		END
				
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN T1_Users_Delete
			END
		END CATCH
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Users_Delete"'
		
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
		IF OBJECT_ID('tempdb..#Uzytkownicy') IS NOT NULL
			DROP TABLE #Uzytkownicy
			
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 
	
END
