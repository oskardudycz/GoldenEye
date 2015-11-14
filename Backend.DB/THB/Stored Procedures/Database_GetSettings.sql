-- =============================================
-- Author:		DK
-- Create date: 2012-10-26
-- Last modified on: 2013-02-18
-- Description:	Pobiera dane ustawien aplikacji/bazy danych.

-- XML wejsciowy w postaci:

--<Request RequestType="Database_GetSettings" UserId="1" AppDate="2012-02-09T12:45:22"/>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Database_GetSettings" AppDate="2012-02-09">
	--		<SettingEntry Key="AutomaticAlternativeHistoryEnable" Value="0" />
	--		<SettingEntry Key="CompleteContinuityOfAttributes" Value="ExtendRange" />
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Database_GetSettings]
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
		@MaUprawnienia bit = 0

	BEGIN TRY

		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_StandardRequest', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
			
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

			IF @RequestType = 'Database_GetSettings'
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
				
					SET @xmlResponse = 
					(
						SELECT Klucz AS "@Key"
							,[Wartosc] AS "@Value"
							,[TypPola] AS "@DataType"
						FROM dbo.[Ustawienia]
						FOR XML PATH('SettingEntry')
					)

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Database_GetSettings', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Database_GetSettings', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_DATABASE_SETTINGS
		END
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Database_GetSettings"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';

	SET @XMLDataOut += '>';
	
	IF @ERRMSG IS NULL OR @ERRMSG = '' 	
	BEGIN
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"></Error></Result>';
	END	

	SET @XMLDataOut += '</Response>';
	
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut	

END
