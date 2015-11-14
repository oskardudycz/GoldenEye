-- =============================================
-- Author:		DK
-- Create date: 2012-03-06
-- Last modified on: 2012-11-28
-- Description:	Sprawdza czy istnieje użytkownik o podanym loginie i zakodowanym haśle.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Users_IsAuthenticated" AppDate="2012-02-09T12:44:11"
	--	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Credentials Login="Ada" Password="HISFH*^$*##HIREGHI"/>
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Users_IsAuthenticated" AppDate="2012-02-09" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>
	
-- =============================================
CREATE PROCEDURE [THB].[Users_AreCredentialsValid]
(	
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@Login nvarchar(32),
		@Haslo nvarchar(32),
		@DataProgramu datetime,
		@RequestType nvarchar(255),
		@xml_data xml,
		@xmlOut xml,
		@xmlOk bit = 0,
		@auth varchar(5) = 'false',
		@ERRMSG nvarchar(255),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@MaUprawnienia bit = 0,
		@DateFromColumnName nvarchar(100),
		@AppDate datetime
	
	SET @XMLDataOut = '';
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Users_AreCredentialsValid', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT --Schema_Users_IsAuthenticated
	
	IF @xmlOk = 0
	BEGIN
		SET @ERRMSG = @ERRMSG;
	END
	ELSE
	BEGIN
		SET @xml_data = CAST(@XMLDataIn AS xml)
			
		--wyciaganie danych uzytkownika
		SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
			   ,@RequestType = C.value('./@RequestType', 'nvarchar(255)')
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@BranzaID = C.value('./@BranchId', 'int')
				FROM @xml_data.nodes('/Request') T(C)
				
		SELECT @Login = C.value('./@Login', 'nvarchar(32)')
		   ,@Haslo = C.value('./@Password', 'nvarchar(300)')
			FROM @xml_data.nodes('/Request/Credentials') T(C)
		
		IF @RequestType = 'Users_AreCredentialsValid'
		BEGIN
			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);

			--pobranie nazwy kolumny po ktorej filtrowane sa daty
			SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();
			
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			--EXEC [THB].[CheckUserPermission]
			--	@Operation = N'GET',
			--	@UserId = @UzytkownikID,
			--	@BranchId = @BranzaId,
			--	@Result = @MaUprawnienia OUTPUT
			
			SET @MaUprawnienia = 1
			
			IF @MaUprawnienia = 1
			BEGIN			
				
				SET @Query = 'IF EXISTS (SELECT Id FROM Uzytkownicy WHERE [Login] = ''' + @Login + ''' AND [Haslo] = ''' + @Haslo + ''' AND IsValid = 1 ' 
				
				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhrase] (NULL, @AppDate);
				
				SET @Query += ')
					SET @auth = ''true''';
				
				PRINT @Query;
				EXECUTE sp_executesql @Query, N'@auth varchar(5) OUTPUT', @auth = @auth OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Users_AreCredentialsValid', @Wiadomosc = @ERRMSG OUTPUT
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Users_AreCredentialsValid', @Wiadomosc = @ERRMSG OUTPUT

	END
	
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Users_AreCredentialsValid"';

	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
	
	IF @ERRMSG IS NULL OR @ERRMSG = ''
	BEGIN
		SET @XMLDataOut += CAST(
		(
			SELECT @auth AS "Value"
			FOR XML PATH('Result')
		) AS nvarchar(MAX)
		)
	END
	ELSE
	BEGIN
		SET @XMLDataOut += CAST(
		(
			SELECT [THB].[PrepareErrorMessage](@ERRMSG) AS "Error/@ErrorMessage"
			FOR XML PATH('Result')
		) AS nvarchar(MAX)
		)
	END
	
	SET @XMLDataOut += '</Response>';
	
END
