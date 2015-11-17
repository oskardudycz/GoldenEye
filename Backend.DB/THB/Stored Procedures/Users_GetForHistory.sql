-- =============================================
-- Author:		DK
-- Create date: 2013-02-14
-- Last modified on: --
-- Description:	Pobiera podstawowe dane uzytkownikow o podanych Id, takze tych usunietych

-- XML wejsciowy w postaci:

	--<Request RequestType="Users_GetForHistory" UserId="1" AppDate="2012-09-20T12:45:32">
 --       <Ref Id="1" EntityType="User" />
 --       <Ref Id="2" EntityType="User" />
 --       <Ref Id="3" EntityType="User" />
	--</Request>

-- XM wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Users_GetForHistory" AppDate="2012-02-09T12:33:34">	    
	--	<User Id="1" Login="Ewa" FirstName="Ewa" LastName="Kawka"/>
	--	<User Id="2" Login="Steve" FirstName="Steve" LastName="Kawka"/>	    
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Users_GetForHistory]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @query nvarchar(max) = '',
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@MaUprawnienia bit = 0,
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DateFromColumnName nvarchar(100)
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_GetByIds', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			BEGIN TRY
			
			--usuwanie tabel tymczasowych, jesli istnieja				
			IF OBJECT_ID('tempdb..#UzytkownicyDoPobrania') IS NOT NULL
				DROP TABLE #UzytkownicyDoPobrania
				
			IF OBJECT_ID('tempdb..#Uzytkownicy') IS NOT NULL
				DROP TABLE #Uzytkownicy
			
			CREATE TABLE #UzytkownicyDoPobrania (Id int);
			CREATE TABLE #Uzytkownicy (Id int);			
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)
			
			IF @RequestType = 'Users_GetForHistory'
			BEGIN
			
				--pobranie id elementow do usuniecia
				INSERT INTO #UzytkownicyDoPobrania(Id)
				SELECT C.value('./@Id', 'int')	
				FROM @xml_data.nodes('/Request/Ref') T(C)
				WHERE C.value('./@EntityType', 'nvarchar(20)') = 'User'
		
				-- pobranie daty na podstawie przekazanego AppDate
				SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);

				--pobranie nazwy kolumny po ktorej filtrowane sa daty
				SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();
		
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'GET',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					--pobranie danych Id pasujacych uzytkownikow do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Uzytkownicy (Id)
							SELECT allData.Id FROM
							(
								SELECT u.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(u.IdArch, u.Id) ORDER BY u.Id ASC) AS Rn
								FROM [dbo].[Uzytkownicy] u
								INNER JOIN
								(
									SELECT ISNULL(u2.IdArch, u2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, u2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Uzytkownicy] u2								 
									INNER JOIN 
									(
										SELECT ISNULL(u3.IdArch, u3.Id) AS RowID, MAX(u3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Uzytkownicy] u3
										WHERE ISNULL(IdArch, Id) IN (SELECT DISTINCT Id FROM #UzytkownicyDoPobrania)';
										
					--dodanie frazy statusow na filtracje jesli trzeba
					--SET @Query += [THB].[PrepareStatusesPhrase] ('u3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhraseExtended] ('u3', @AppDate, 0);										
											
									
					SET @Query += '
										GROUP BY ISNULL(u3.IdArch, u3.Id)
									) latest
									ON ISNULL(u2.IdArch, u2.Id) = latest.RowID AND u2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(u2.IdArch, u2.Id), u2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(u.IdArch, u.Id) = latestWithMaxDate.RowID AND u.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND u.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
			
					SET @xmlResponse = (SELECT ISNULL(u.[IdArch], u.[Id]) AS "@Id"								
										,u.[Login] AS "@Login"
										,u.[Imie] AS "@FirstName"
										,u.[Nazwisko] AS "@LastName"
									FROM dbo.Uzytkownicy u
									WHERE u.[Id] IN (SELECT DISTINCT Id FROM #Uzytkownicy)
									FOR XML PATH('User')
									)

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Users_GetForHistory', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Users_GetForHistory', @Wiadomosc = @ERRMSG OUTPUT
				
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH			
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Users_GetForHistory"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
	
	IF @ERRMSG IS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), ''); 
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	--usuwanie tabel tymczasowych, jesli istnieja		
	IF OBJECT_ID('tempdb..#UzytkownicyDoPobrania') IS NOT NULL
		DROP TABLE #UzytkownicyDoPobrania
		
	IF OBJECT_ID('tempdb..#Uzytkownicy') IS NOT NULL
		DROP TABLE #Uzytkownicy
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 

END
