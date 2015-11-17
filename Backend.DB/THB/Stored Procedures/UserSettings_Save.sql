-- =============================================
-- Author:		DK
-- Create date: 2012-07-19
-- Last modified on: 2012-09-07
-- Description:	Zapisuje dane ustawien użytkowników (klucz i wartość).

-- XML wejsciowy w postaci:

	--<Request RequestType="UserSettings_Save" UserId="1" AppDate="2012-02-09T11:56:34" xsi:noNamespaceSchemaLocation="17.7.Request.xsd" 
	--xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Settings UserId="0">
	--		<Entries>
	--			<SettingEntry Key="Lines" Value="10"/>
	--			<SettingEntry Key="LastView" Value="UnitType"/>
	--		</Entries>
	--	</Settings>
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="UserSettings_Save" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="17.7.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result><Value>true</Value></Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UserSettings_Save]
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
		@xmlOk bit = 0,
		@xml_data xml,
		@BranzaID int,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@MaUprawnienia bit = 0,
		@UserId int,
		@Klucz nvarchar(20),
		@Wartosc nvarchar(300),
		@Query nvarchar(MAX) = '',
		@DataModyfikacji datetime = GETDATE(),
		@Zapisano varchar(5) = 'false';

	BEGIN TRY

		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_UserSettings_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#Ustawienia') IS NOT NULL
			DROP TABLE #Ustawienia
			
		IF @xmlOk = 0 OR @xmlOk IS NULL
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN
		
			SET @xml_data = CAST(@XMLDataIn AS xml);

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);			
			
			--odczytywanie ustawien uzytkownikow
			SELECT	C.value('../../@UserId', 'int') AS UzytkownikId,
					C.value('./@Key', 'nvarchar(20)') AS Klucz,
					C.value('./@Value', 'nvarchar(300)') AS Wartosc
			INTO #Ustawienia
			FROM @xml_data.nodes('/Request/Settings/Entries/SettingEntry') T(C);

			IF @RequestType = 'UserSettings_Save'
			BEGIN 
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				--EXEC [THB].[CheckUserPermission]
				--	@Operation = N'SAVE',
				--	@UserId = @UzytkownikID,
				--	@BranchId = @BranzaId,
				--	@Result = @MaUprawnienia OUTPUT
				
				SET @MaUprawnienia = 1;
				
				IF @MaUprawnienia = 1
				BEGIN
				
					BEGIN TRAN T_SETTINGS
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
					
					DECLARE cur CURSOR LOCAL FOR 
						SELECT UzytkownikId, Klucz, Wartosc FROM #Ustawienia
					OPEN cur
					FETCH NEXT FROM cur INTO @UserId, @Klucz, @Wartosc
					WHILE @@FETCH_STATUS = 0
					BEGIN
						
						--zapis ustawien do bazy
						MERGE Uzytkownicy_Ustawienia AS target
						USING (SELECT @UserId, @Klucz, @Wartosc) AS source (UserId, Klucz, Wartosc)
						ON (target.UzytkownikId = source.UserId AND target.Klucz = source.Klucz)
						WHEN MATCHED THEN 
							UPDATE SET 
							Wartosc = source.Wartosc,
							LastModifiedOn = @DataModyfikacji
						WHEN NOT MATCHED THEN	
							INSERT (UzytkownikId, Klucz, Wartosc, CreatedOn, IsValid)
							VALUES (source.UserId, source.Klucz, source.Wartosc, @DataModyfikacji, 1);
	
						IF @@ROWCOUNT > 0
							SET @Zapisano = 'true';
						
						FETCH NEXT FROM cur INTO @UserId, @Klucz, @Wartosc
						
					END
					CLOSE cur
					DEALLOCATE cur  
					
					COMMIT TRAN T_SETTINGS
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UserSettings_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UserSettings_Save', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T_SETTINGS
		END
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UserSettings_Save"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';

	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = '' 	
	BEGIN
		SET @XMLDataOut += '<Result><Value>' + @Zapisano + '</Value></Result>';
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"></Error></Result>';
	END	

	SET @XMLDataOut += '</Response>';	
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#Ustawienia') IS NOT NULL
		DROP TABLE #Ustawienia;

END
