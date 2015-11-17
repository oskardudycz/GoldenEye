-- =============================================
-- Author:		DK
-- Create date: 2012-03-19
-- Last modified on: 2013-02-14
-- Description:	Zapisuje dane uzytkownikow do tabeli 'Uzytkownicy' i GrupyUzytkownikowUzytkownik. Aktualizuje istniejacy lub wstawia nowy rekord.

-- XML wejsciowy w postaci:

	--<Request RequestType="Users_Save" UserId="1" AppDate="2012-02-09T12:45:33"
	--	xsi:noNamespaceSchemaLocation="17.4.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<User Id="1" Name="efwere" Login="2132312" FirstName="1121" LastName="12" Email="1212" Password="HKIsfsdf" IsActive="true" IsDeleted="false" IsDomain="false"
	--		LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<Roles>
	--			<Role Id="1" Name="213221" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		</Roles>
	--		<Groups>
	--			<UserGroup Id="2" Name="2321312" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		</Groups>
	--	</User>
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Users_Save" AppDate="2012-02-09" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="User" />
	--			<Ref Id="2" EntityType="User" />
	--			<Ref Id="3" EntityType="User" />
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Users_Save]
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
		@Id int,
		@Nazwa nvarchar(200),
		@Index int,
		@Login nvarchar(32),
		@Imie nvarchar(32),
		@Nazwisko nvarchar(64),
		@Email nvarchar(64),
		@Haslo nvarchar(300),
		@Aktywny bit,
		@Domenowy bit,
		@Usuniety bit,
		@LastModifiedOn datetime,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@PrzetwarzanyUzytkownikId int,
		@Skip bit = 0,
		@NazwaRoli nvarchar(64),
		@GrupaUzytkownikowId int,
		@NazwaGrupyUzytkownikow nvarchar(64),
		@MaUprawnienia bit = 0,
		@Commit bit = 1,
		@Query nvarchar(MAX) = '',
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacyUzytkownikId int,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@IsStatus bit

	BEGIN TRY

		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Users_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#Uzytkownicy') IS NOT NULL
			DROP TABLE #Uzytkownicy
			
		IF OBJECT_ID('tempdb..#Role') IS NOT NULL
			DROP TABLE #Role
			
		IF OBJECT_ID('tempdb..#Grupy') IS NOT NULL
			DROP TABLE #Grupy
			
		IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
			DROP TABLE #Historia
		
		IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
			DROP TABLE #Statusy
			
		IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
			DROP TABLE #IDZmienionych
			
		IF OBJECT_ID('tempdb..#UzytkownicyKonfliktowi') IS NOT NULL
			DROP TABLE #UzytkownicyKonfliktowi
			
		IF OBJECT_ID('tempdb..#UzytkownicyNieUnikalni') IS NOT NULL
			DROP TABLE #UzytkownicyNieUnikalni
			
		CREATE TABLE #UzytkownicyKonfliktowi(ID int);	
		CREATE TABLE #UzytkownicyNieUnikalni(ID int);	
		CREATE TABLE #IDZmienionych (ID int);

		
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
		
			--odczytywanie danych uzytkownika
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/User)','int') )
			)
			SELECT 	j AS 'Index'
				   ,x.value('./@Id', 'int') AS Id
				   ,x.value('./@Name', 'nvarchar(256)') AS Nazwa
				   ,x.value('./@Login', 'nvarchar(32)') AS [Login]
				   ,x.value('./@FirstName', 'nvarchar(32)') AS Imie
				   ,x.value('./@LastName', 'nvarchar(64)') AS Nazwisko
				   ,x.value('./@Email', 'nvarchar(64)') AS Email
				   ,x.value('./@Password', 'nvarchar(300)') AS Haslo
				   ,x.value('./@IsActive', 'bit') AS Aktywny
				   ,x.value('./@IsDomain', 'bit') AS Domenowy
				   ,x.value('./@IsDeleted', 'bit') AS IsDeleted
				   ,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				  -- ,x.value('./@LastModifiedBy', 'int') AS LastModifiedBy
				   --,x.value('./@DeletedFrom', 'datetime') AS DeletedFrom
				   --,x.value('./@DeletedBy', 'int') AS DeletedBy
				   --,x.value('./@CreatedOn', 'datetime') AS CreatedOn
				   --,x.value('./@CreatedBy', 'int') AS CreatedBy
			INTO #Uzytkownicy
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/User[position()=sql:column("j")]')  e(x);
			
			--odczytywanie danych roli uzytkownika	
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/User)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('./@Id','int') AS Id
				,x.value('./@Name', 'nvarchar(64)') AS Nazwa
				,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
			INTO #Role
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/User[position()=sql:column("j")]/Roles/Role')  e(x);
			
			--odczytywanie danych grup uzytkownika	
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/User)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('./@Id','int') AS Id
				,x.value('./@Name', 'nvarchar(64)') AS Nazwa
				,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
			INTO #Grupy
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/User[position()=sql:column("j")]/Groups/UserGroup')  e(x);
			
			--odczytywanie statusow
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/User)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('./@IsStatus', 'bit') AS IsStatus
				,x.value('./@StatusP', 'int') AS StatusP  
				,x.value('./@StatusPFrom', 'datetime') AS StatusPFrom 
				,x.value('./@StatusPTo', 'datetime') AS StatusPTo
				,x.value('./@StatusPFromBy', 'int') AS StatusPFromBy
				,x.value('./@StatusPToBy', 'int') AS StatusPToBy
				,x.value('./@StatusS', 'int') AS StatusS
				,x.value('./@StatusSFrom', 'datetime') AS StatusSFrom
				,x.value('./@StatusSTo', 'datetime') AS StatusSTo
				,x.value('./@StatusSFromBy', 'int') AS StatusSFromBy
				,x.value('./@StatusSToBy', 'int') AS StatusSToBy
				,x.value('./@StatusW', 'int') AS StatusW
				,x.value('./@StatusWFrom', 'datetime') AS StatusWFrom 
				,x.value('./@StatusWTo', 'datetime') AS StatusWTo
				,x.value('./@StatusWFromBy', 'int') AS StatusWFromBy
				,x.value('./@StatusWToBy', 'int') AS StatusWToBy
			INTO #Statusy
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/User[position()=sql:column("j")]/Statuses')  e(x);
			
			--odczytywanie historii
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/User)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('./@ChangeFrom', 'datetime') AS ZmianaOd 
				,x.value('./@ChangeTo', 'datetime') AS ZmianaDo
				,x.value('./@EffectiveFrom', 'datetime') AS DataObowiazywaniaOd
				,x.value('./@EffectiveTo', 'datetime') AS DataObowiazywaniaDo
				,x.value('./@IsAlternativeHistory', 'bit') AS IsAlternativeHistory
				,x.value('./@IsMainHistFlow', 'bit') AS IsMainHistFlow
			INTO #Historia 
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/User[position()=sql:column("j")]/History')  e(x);			
			
			--SELECT * FROM #Uzytkownicy;
			--SELECT * FROM #Role;
			--SELECT * FROM #Grupy;
			--SELECT * FROM #Statusy;
			--SELECT * FROM #Historia;

			IF @RequestType = 'Users_Save'
			BEGIN 
				
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					BEGIN TRAN T1
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
					
					DECLARE cur CURSOR LOCAL FOR 
						SELECT [Index], Id, [Login], Imie, Nazwisko, Email, Haslo, Aktywny, Domenowy, IsDeleted, LastModifiedOn FROM #Uzytkownicy
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @Login, @Imie, @Nazwisko, @Email, @Haslo, @Aktywny, @Domenowy, @Usuniety, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--wyzerowanie zmiennych, potrzebne!
						SET @Skip = 0;
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL;
						
						--zabezpieczenie sie przed wpisywaniem do bazy pustego adresu emial (pusty string).
						IF LEN(@Email) = 0
							SET @Email = NULL;
						
						--pobranie dnaych zwiazanych z datami
						SELECT	@ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, 
						@DataObowiazywaniaOd = DataObowiazywaniaOd, @DataObowiazywaniaDo = DataObowiazywaniaDo
						FROM #Historia WHERE RootIndex = @Index;
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index
						
						--zastapienie NULLi wartosciami domyslnymi
						SELECT @IsStatus = ISNULL(@IsStatus, 1), @StatusP = ISNULL(@StatusP, 0), @StatusS = ISNULL(@StatusS, 0), @StatusW = ISNULL(@StatusW, 0);		

--kolumna poki co nie uzywana
SET @DataObowiazywaniaDo = NULL;

						--sprawdzenie czy uzytkownik o podanym loginie lub adresie email juz istnieje
						SET @IstniejacyUzytkownikId = (SELECT TOP 1 Id FROM dbo.[Uzytkownicy] WHERE Id <> @Id AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0 AND ([Login] = @Login OR Email = @Email));
						
						IF @IstniejacyUzytkownikId IS NULL
						BEGIN
							IF EXISTS (SELECT Id FROM dbo.[Uzytkownicy] WHERE Id = @Id)
							BEGIN
								--aktualizacja danych slownika
								UPDATE dbo.[Uzytkownicy] SET
								[Login] = @Login,
								Imie = @Imie,
								Nazwisko = @Nazwisko,
								Email = @Email,
								Haslo = @Haslo,
								Aktywny = @Aktywny,
								Domenowy = @Domenowy,
								ValidFrom = @DataModyfikacjiApp,
								StatusP = @StatusP,								
								StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
								StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
								StatusS = @StatusS,								
								StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
								StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
								StatusW = @StatusW,
								StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
								StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
								IsStatus = ISNULL(@IsStatus, 1),
								ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
								ObowiazujeDo = @DataObowiazywaniaDo,
								LastModifiedOn = @DataModyfikacjiApp,
								LastModifiedBy = @UzytkownikId,
								RealLastModifiedOn = @DataModyfikacji
								WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanyUzytkownikId = @Id;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanyUzytkownikId);
								END
								ELSE
								BEGIN
									--konflikt konkurencyjnosci
									INSERT INTO #UzytkownicyKonfliktowi(ID)
									VALUES(@Id);
									
									EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
									SET @Commit = 0;
									SET @Skip = 1;
								END
							END
							ELSE
							BEGIN						
								--wstawienie nowego uzytkownika ile juz taki nie istnieje
								INSERT INTO dbo.[Uzytkownicy] ([Login], Imie, Nazwisko, Email, Haslo, Aktywny, Domenowy, CreatedBy, CreatedOn, ValidFrom, RealCreatedOn,
								IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy, 
								ObowiazujeOd, ObowiazujeDo) 
								VALUES (
									@Login, @Imie, @Nazwisko, @Email, @Haslo, @Aktywny, @Domenowy, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacjiApp, @DataModyfikacji,
									ISNULL(@IsStatus, 1), @StatusP, 
									CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
									CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
									@StatusS,
									CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
									CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
									@StatusW, 
									CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
									CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
									ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
									@DataObowiazywaniaDo
								);
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanyUzytkownikId = @@IDENTITY;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanyUzytkownikId);
								END
								ELSE
								BEGIN
									SET @Skip = 1;
								END
							END
											
							--przetwarzanie danych grup uzytkownikow dla uzytkonika
							IF @Skip = 0
							BEGIN
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local', 'cur2') > 0 
								BEGIN
									 CLOSE cur2
									 DEALLOCATE cur2
								END

								DECLARE cur2 CURSOR LOCAL FOR 
									SELECT Id, Nazwa, LastModifiedOn FROM #Grupy WHERE RootIndex = @Index
								OPEN cur2
								FETCH NEXT FROM cur2 INTO @GrupaUzytkownikowId, @NazwaGrupyUzytkownikow, @LastModifiedOn
								WHILE @@FETCH_STATUS = 0
								BEGIN				
									--sprawdzenie czy istnieje grupa o podanej nazwie i czasie ostatniej aktualicacji - dla wyeliminowania kolizji
									IF EXISTS(SELECT Id FROM dbo.GrupyUzytkownikow WHERE Id = @GrupaUzytkownikowId AND Nazwa = @NazwaGrupyUzytkownikow 
										AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn)))
									BEGIN							
										IF EXISTS (SELECT GrupaUzytkownikow FROM [GrupaUzytkownikowUzytkownik] WHERE GrupaUzytkownikow = @GrupaUzytkownikowId AND Uzytkownik = @Id)
										BEGIN
											UPDATE [GrupaUzytkownikowUzytkownik] SET
											ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
											ObowiazujeDo = NULL,
											LastModifiedOn = @DataModyfikacjiApp,
											LastModifiedBy = @UzytkownikId,
											RealLastModifiedOn = @DataModyfikacji
											WHERE GrupaUzytkownikow = @GrupaUzytkownikowId AND Uzytkownik = @Id;
										END
										ELSE
										BEGIN								
											INSERT INTO [GrupaUzytkownikowUzytkownik] (GrupaUzytkownikow, Uzytkownik, ObowiazujeOd, ObowiazujeDo,
											CreatedBy, CreatedOn, RealCreatedOn)
											VALUES (@GrupaUzytkownikowId, @PrzetwarzanyUzytkownikId, ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp), @DataObowiazywaniaDo,
											@UzytkownikId, @DataModyfikacjiApp, @DataModyfikacji);								
										END							
									END
									
									FETCH NEXT FROM cur2 INTO @GrupaUzytkownikowId, @NazwaGrupyUzytkownikow, @LastModifiedOn
								END
								CLOSE cur2
								DEALLOCATE cur2
							END
						END
						ELSE
						BEGIN
							-- uzytkownik o podanych danych juz istnieje, dodanie jego ID do tabeli tymczasowej
							INSERT INTO #UzytkownicyNieUnikalni(ID)
							VALUES(@IstniejacyUzytkownikId);
							
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Użytkownik' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
						END
						
						FETCH NEXT FROM cur INTO @Index, @Id, @Login, @Imie, @Nazwisko, @Email, @Haslo, @Aktywny, @Domenowy, @Usuniety, @LastModifiedOn
						
					END
					CLOSE cur
					DEALLOCATE cur
				
					--SELECT * FROM #IDZmienionych										
					--SELECT * FROM #UzytkownicyKonfliktowi
					--SELECT * FROM #UzytkownicyNieUnikalni
					
					IF (SELECT COUNT(1) FROM #UzytkownicyKonfliktowi) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT u.[Id] AS "@Id"
							,u.[Login] AS "@Login"
							,u.[Imie] AS "@FirstName"
							,u.[Nazwisko] AS "@LastName"
							,u.[Email] AS "@Email"
							,u.[Haslo] AS "@Password"
							,u.[Aktywny] AS "@IsActive"
							,u.[Domenowy] AS "@IsDomain"
							  ,u.[IsDeleted] AS "@IsDeleted"
							  ,u.[DeletedFrom] AS "@DeletedFrom"
							  ,u.[DeletedBy] AS "@DeletedBy"
							  ,u.[CreatedOn] AS "@CreatedOn"
							  ,u.[CreatedBy] AS "@CreatedBy"
							  ,ISNULL(u.[LastModifiedOn], u.[CreatedOn]) AS "@LastModifiedOn"
							  ,ISNULL(u.[LastModifiedBy], u.[CreatedBy]) AS "@LastModifiedBy"
							  ,u.[ObowiazujeOd] AS "History/@EffectiveFrom"
							  ,u.[ObowiazujeDo] AS "History/@EffectiveTo"							
							FROM [Uzytkownicy] u
							WHERE Id IN (SELECT ID FROM #UzytkownicyKonfliktowi)
							FOR XML PATH('User')
						) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #UzytkownicyNieUnikalni) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT u.[Id] AS "@Id"
										,u.[Login] AS "@Login"
										,u.[Imie] AS "@FirstName"
										,u.[Nazwisko] AS "@LastName"
										,u.[Email] AS "@Email"
										,u.[Haslo] AS "@Password"
										,u.[Aktywny] AS "@IsActive"
										,u.[Domenowy] AS "@IsDomain"
										  ,u.[IsDeleted] AS "@IsDeleted"
										  ,u.[DeletedFrom] AS "@DeletedFrom"
										  ,u.[DeletedBy] AS "@DeletedBy"
										  ,u.[CreatedOn] AS "@CreatedOn"
										  ,u.[CreatedBy] AS "@CreatedBy"
										  ,ISNULL(u.[LastModifiedOn], u.[CreatedOn]) AS "@LastModifiedOn"
										  ,ISNULL(u.[LastModifiedBy], u.[CreatedBy]) AS "@LastModifiedBy"
										  ,u.[ObowiazujeOd] AS "History/@EffectiveFrom"
										  ,u.[ObowiazujeDo] AS "History/@EffectiveTo"							
										FROM [Uzytkownicy] u
										WHERE Id IN (SELECT ID FROM #UzytkownicyNieUnikalni)
										FOR XML PATH('User')
									) AS nvarchar(MAX)), '');
					END
					
					SET @xmlResponse = (
						SELECT TOP 1 NULL AS '@Ids'
						, (
							SELECT Id AS '@Id'
							,'User' AS '@EntityType'
							FROM #IDZmienionych
							FOR XML PATH('Ref'), ROOT('Value'), TYPE
							)
						FROM #IDZmienionych
						FOR XML PATH('Result')
						)
					
					IF @Commit = 1
						COMMIT TRAN T1
					ELSE
						ROLLBACK TRAN T1
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Users_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Users_Save', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1
		END
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Users_Save"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';

	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = '' 	
	BEGIN
		IF (SELECT COUNT(1) FROM #IdZmienionych) > 0
			SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		ELSE
			SET @XMLDataOut += '<Result><Value/></Result>';
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '">'

		IF @xmlErrorConcurrency IS NOT NULL AND LEN(@xmlErrorConcurrency) > 3
			SET @XMLDataOut += '<ConcurrencyConflicts>' + @xmlErrorConcurrency + '</ConcurrencyConflicts>';

		IF @xmlErrorsUnique IS NOT NULL AND LEN(@xmlErrorsUnique) > 3
			SET @XMLDataOut += '<UniquenessConflicts>' + @xmlErrorsUnique + '</UniquenessConflicts>';
		
		SET @XMLDataOut += '</Error></Result>';
	END	

	SET @XMLDataOut += '</Response>';	
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#Uzytkownicy') IS NOT NULL
		DROP TABLE #Uzytkownicy
		
	IF OBJECT_ID('tempdb..#Role') IS NOT NULL
		DROP TABLE #Role
		
	IF OBJECT_ID('tempdb..#Grupy') IS NOT NULL
		DROP TABLE #Grupy
		
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
	
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#UzytkownicyKonfliktowi') IS NOT NULL
		DROP TABLE #UzytkownicyKonfliktowi
		
	IF OBJECT_ID('tempdb..#UzytkownicyNieUnikalni') IS NOT NULL
		DROP TABLE #UzytkownicyNieUnikalni
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
