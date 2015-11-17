-- =============================================
-- Author:		DK
-- Create date: 2012-03-16
-- Last modified on: 2012-09-07
-- Description:	Sprawdza czy istnieje uzytkownik o podanym loginie.

-- XML wejsciowy w postaci:

	--<Request RequestType="User_IsLoginUnique" UserId="3" AppDate="2012-02-09T11:34:54"
	--	xsi:noNamespaceSchemaLocation="17.2.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Login Value="Marta" />
	--</Request>

-- XM wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="User_IsLoginUnique" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="17.2.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result><Value>true</Value></Result>
	--</Response>


-- =============================================
CREATE PROCEDURE [THB].[User_IsLoginUnique]
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
		@BranzaID int,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@UniqueLogin varchar(5) = 'false',
		@Login nvarchar(32),
		@StartDate nvarchar(40),
		@EndDate nvarchar(40),
		@MaUprawnienia bit = 0
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_User_IsLoginUnique', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

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
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
			FROM @xml_data.nodes('/Request') T(C) 
			
			--pobranie loginu
			SELECT @Login = C.value('./@Login', 'nvarchar(32)')
			FROM @xml_data.nodes('/Request/Credentials') T(C) 	
			
			IF @RequestType = 'User_IsLoginUnique'
			BEGIN
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji save
				EXEC [THB].[CheckUserPermission]
					@Operation = N'GET',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					--SET @StartDate = CONVERT(varchar, @DataProgramu, 112) + ' 23:59:59';
					--SET @EndDate = CONVERT(varchar, @DataProgramu, 112) + ' 00:00:00';
					--SELECT @StartDate, @EndDate
					--AND (ValidFrom <= @StartDate AND (ValidTo IS NULL OR ValidTo >= @EndDate))					) 
					
					IF @Login IS NOT NULL AND NOT EXISTS (SELECT Id FROM Uzytkownicy WHERE [Login] = @Login AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0)						
						SET @UniqueLogin = 'true';
					ELSE
						SET @UniqueLogin = 'false';
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'User_IsLoginUnique', @Wiadomosc = @ERRMSG OUTPUT				
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'User_IsLoginUnique', @Wiadomosc = @ERRMSG OUTPUT	
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="User_IsLoginUnique"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += '<Result><Value>' + @UniqueLogin + '</Value></Result>'
	ELSE
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>';
	
	SET @XMLDataOut += '</Response>'; 

END
