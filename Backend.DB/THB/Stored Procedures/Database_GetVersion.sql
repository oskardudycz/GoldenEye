-- =============================================
-- Author:		DK
-- Create date: 2012-10-24
-- Last modifies on: 2013-02-18
-- Description:	Zwraca wersję aktualnie używanej bazy danych.

-- XML wejsciowy w postaci:

-- <Request RequestType="Database_GetVersion" UserId="1" AppDate="2012-05-09T12:34:44"/>	

-- XML wyjsciowy w postaci:

--<?xml version="1.0" encoding="utf-8"?>
--<Response ResponseType="Database_GetVersion" AppDate="2012-05-09">
--	<Version>1.00</Version>
--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Database_GetVersion]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Wersja varchar(10) = '',
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@DataProgramu datetime
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Database_GetStatistics', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			BEGIN TRY
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@DataProgramu = C.value('./@AppDate', 'datetime')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
			FROM @xml_data.nodes('/Request') T(C) 
		
			IF @RequestType = 'Database_GetVersion'
			BEGIN
				--pobranie numeru wersji wg najnowszej daty obowiazywania
				SELECT TOP 1 @Wersja = Numer
				FROM dbo.[Wersja]
				ORDER BY ValidFrom DESC		
					
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Database_GetVersion', @Wiadomosc = @ERRMSG OUTPUT
			
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Database_GetVersion"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>'	
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += '<Version>' + @Wersja + '</Version>';
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 

END
