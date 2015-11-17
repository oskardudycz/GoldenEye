-- =============================================
-- Author:		DK
-- Create date: 2012-03-06
-- Last modified on: 2013-02-12
-- Description:	Zwraca dane użytkownika z tabeli Uzytkownicy dla podanego loginu + Dane o rolach uzytkownika + jego ustawienia.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy w postaci:

	--<Request RequestType="Users_GetByLogin" AppDate="2012-02-09">
	--	<Credentials Login="Ada" />
	--</Request>

-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Users_GetByLogin" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="17.5.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<User Id="1" Login="Ewa" FirstName="Ewa" LastName="Kawka" Email="ewa@wp.pl" Password="LKOEFJ#@YHRIW" IsActive="true" IsDeleted="false" IsDomain="false" LastModifiedOn="2012-02-09T12:12:12.121">
	--		<Statuses IsStatus="1" StatusS="2" StatusSFrom="2012-02-09T14:12:54.947" StatusSFromBy="1" StatusW="5" StatusWFrom="2012-02-09T14:12:54.947" StatusWFromBy="1" StatusP="1" StatusPFrom="2012-02-09T14:12:54.947" StatusPFromBy="1"/>
	--		<History EffectiveFrom="2012-02-09T14:12:54.947"/>
	--		<Roles>
	--			<Role Id="1" Name="Supervisor" Description="Maksymalny dostęp" Rank="1" LastModifiedOn="2012-02-09T12:12:12.121" />
	--			<Role Id="2" Name="Administrator" Description="Administrator" Rank="1" LastModifiedOn="2012-02-09T12:12:12.121" />
	--			<Role Id="3" Name="User" Description="Użytkownik" Rank="1" LastModifiedOn="2012-02-09T12:12:12.121" />
	--		</Roles>
		--	<Settings UserId="1">
		--	<Entries>
		--		<SettingEntry Key="a" Value="1"/>
		--		<SettingEntry Key="b" Value="2"/>
		--	</Entries>
		--</Settings>
	--	</User>
	--</Response>
-- =============================================
CREATE PROCEDURE [THB].[Users_GetByLogin]
(	
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@Login nvarchar(32),
		@DataProgramu datetime,
		@RequestType nvarchar(255),
		@xml_data xml,
		@xmlOut xml,
		@xmlOk bit = 0,
		@UzytkownikID int,
		@BranzaID int = NULL,
		@ERRMSG nvarchar(255),
		@MaUprawnienia bit = 0,
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int
	
	SET @XMLDataOut = '';
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Users_GetByLogin', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
	IF @xmlOk = 0
	BEGIN
		-- co zrobic jak nie poprawna walidacja XML
		SET @ERRMSG = @ERRMSG;
	END
	ELSE
	BEGIN
		BEGIN TRY
		
		SET @xml_data = CAST(@XMLDataIn AS xml)

		--wyciaganie daty i typu zadania
		SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
				,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@BranzaID = C.value('./@BranchId', 'int')
				,@StatusS = C.value('./@StatusS', 'int')
				,@StatusP = C.value('./@StatusP', 'int')
				,@StatusW = C.value('./@StatusW', 'int')
		FROM @xml_data.nodes('/Request') T(C)
		
		SELECT @Login = C.value('./@Login', 'nvarchar(32)')
		FROM @xml_data.nodes('/Request/Credentials') T(C)
		
		IF @RequestType = 'Users_GetByLogin'
		BEGIN

			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
			
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			EXEC [THB].[CheckUserPermission]
				@Operation = N'GET',
				@UserId = @UzytkownikID,
				@BranchId = @BranzaId,
				@Result = @MaUprawnienia OUTPUT
			
			--todo brak atrybutu UserId przy wywolywaniu procedury
			SET @MaUprawnienia = 1;
			
			IF @MaUprawnienia = 1
			BEGIN
			
				SET @Query = '
					SET @xmlOut =
					(
						SELECT u.[Id] AS "@Id"
						  ,u.[Login] AS "@Login"  
						  ,u.[Imie] AS "@FirstName"
						  ,u.[Nazwisko] AS "@LastName"
						  ,u.[Email] AS "@Email"
						  ,u.[Haslo] AS "@Password"
						  ,u.[Aktywny] AS "@IsActive"
						  ,u.[IsDeleted] AS "@IsDeleted"
						  ,u.[Domenowy] AS "@IsDomain"
						  ,ISNULL(u.[LastModifiedOn], u.[CreatedOn]) AS "@LastModifiedOn"
						  ,u.[IsStatus] AS "Statuses/@IsStatus"
						  ,u.[StatusS] AS "Statuses/@StatusS"
						  ,u.[StatusSFrom] AS "Statuses/@StatusSFrom"
						  ,u.[StatusSTo] AS "Statuses/@StatusSTo"
						  ,u.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
						  ,u.[StatusSToBy] AS "Statuses/@StatusSToBy"
						  ,u.[StatusW] AS "Statuses/@StatusW"
						  ,u.[StatusWFrom] AS "Statuses/@StatusWFrom"
						  ,u.[StatusWTo] AS "Statuses/@StatusWTo"
						  ,u.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
						  ,u.[StatusWToBy] AS "Statuses/@StatusWToBy"
						  ,u.[StatusP] AS "Statuses/@StatusP"
						  ,u.[StatusPFrom] AS "Statuses/@StatusPFrom"
						  ,u.[StatusPTo] AS "Statuses/@StatusPTo"
						  ,u.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
						  ,u.[StatusPToBy] AS "Statuses/@StatusPToBy"
						  ,u.[ObowiazujeOd] AS "History/@EffectiveFrom"
						  ,u.[ObowiazujeDo] AS "History/@EffectiveTo"
							,(SELECT DISTINCT ISNULL(r.IdArch, r.id) AS "@Id"
								,r.Nazwa AS "@Name"
								,r.Opis AS "@Description"
								,r.Rank AS "@Rank"
								,ISNULL(r.LastModifiedOn, r.CreatedOn) AS "@LastModifiedOn"
								,r.[IsStatus] AS "Statuses/@IsStatus"
								,r.[StatusS] AS "Statuses/@StatusS"
								,r.[StatusSFrom] AS "Statuses/@StatusSFrom"
								,r.[StatusSTo] AS "Statuses/@StatusSTo"
								,r.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
								,r.[StatusSToBy] AS "Statuses/@StatusSToBy"
								,r.[StatusW] AS "Statuses/@StatusW"
								,r.[StatusWFrom] AS "Statuses/@StatusWFrom"
								,r.[StatusWTo] AS "Statuses/@StatusWTo"
								,r.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
								,r.[StatusWToBy] AS "Statuses/@StatusWToBy"
								,r.[StatusP] AS "Statuses/@StatusP"
								,r.[StatusPFrom] AS "Statuses/@StatusPFrom"
								,r.[StatusPTo] AS "Statuses/@StatusPTo"
								,r.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
								,r.[StatusPToBy] AS "Statuses/@StatusPToBy"
								,r.[ObowiazujeOd] AS "History/@EffectiveFrom"
								,r.[ObowiazujeDo] AS "History/@EffectiveTo"
							FROM [GrupaUzytkownikowUzytkownik] guu
							JOIN [RolaGrupaUzytkownikow] rgu ON (rgu.GrupaUzytkownikow = guu.GrupaUzytkownikow)
							JOIN [Role] r ON (r.Id = rgu.Rola)
							WHERE guu.Uzytkownik = u.Id'
							
				--dodanie filtracji na statusy
				SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
					
				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhrase] ('r', @AppDate);
				SET @Query += [THB].[PrepareDatesPhrase] ('guu', @AppDate);
				SET @Query += [THB].[PrepareDatesPhrase] ('rgu', @AppDate);						
							
				SET @Query += '
							FOR XML PATH(''Role''), ROOT(''Roles''), TYPE
							)
							,(SELECT u.[Id] AS "@UserId"
								,(SELECT uu.Klucz AS "@Key"
									,uu.Wartosc AS "@Value"
								FROM [Uzytkownicy_Ustawienia] uu
								WHERE uu.UzytkownikId = u.Id AND IsValid = 1
								FOR XML PATH(''SettingEntry''), ROOT(''Entries''), TYPE
								)
							FOR XML PATH(''Settings''), TYPE
							)
						FROM [Uzytkownicy] u
						WHERE u.[Login] = ''' + @Login + '''';						
						
				SET @Query += [THB].[PrepareDatesPhrase] ('u', @AppDate);
				
				--dodanie ewentualnej filtracji na statusy	
				SET @Query += [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);		
					
				--WHERE u.[Login] COLLATE DATABASE_DEFAULT IN (SELECT [Login] FROM #Loginy)
				SET @Query += '
					FOR XML PATH(''User'') 
					)'
				
				--PRINT @Query
				EXECUTE sp_executesql @Query, N'@xmlOut xml OUTPUT', @xmlOut = @xmlOut OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Users_GetByLogin', @Wiadomosc = @ERRMSG OUTPUT
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Users_GetByLogin', @Wiadomosc = @ERRMSG OUTPUT
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
		END CATCH
	END

	--przygotowanie XMLa z odpowiedzia	
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Users_GetByLogin"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlOut AS nvarchar(MAX)), ''); 
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';

	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
