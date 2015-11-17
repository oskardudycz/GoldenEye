-- =============================================
-- Author:		DK
-- Create date: 2012-03-19
-- Last modified on: 2013-02-12
-- Description:	Zapisuje dane grup uzytkownikow do tabeli 'GrupyUzytkownikow' i GrupyUzytkownikowUzytkownik i RolaGrupyUzytkownikow. 
-- Aktualizuje istniejacy lub wstawia nowy rekord.

-- XML wejsciowy w postaci:

	--<Request RequestType="UserGroups_Save" UserId="1" AppDate="2012-02-09T09:34:54"
	--	xsi:noNamespaceSchemaLocation="18.2.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<UserGroup Id="1" Name="23123" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<Users>
	--			<User Id="21" Name="12321" IsDeleted="false" Login="23" FirstName="2331" LastName="23122" Email="23132" Password="232312" IsActive="true" IsDomain="false" 
	--				LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		</Users>
	--		<Roles>
	--			<Role Id="50" Name="2312" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		</Roles>        
	--	</UserGroup>
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
CREATE PROCEDURE [THB].[UserGroups_Save]
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
		@xmlOk bit,
		@xml_data xml,
		@BranzaID int,
		@Id int,
		@Nazwa nvarchar(200),
		@Index int,
		@Login nvarchar(32),
		@LastModifiedOn datetime,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@PrzetwarzanaGrupaId int,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@UserId int,
		@Skip bit = 0,
		@RolaId int,
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@IsStatus bit,
		@NazwaGrupyUzytkownikow nvarchar(64),
		@Opis nvarchar(MAX),
		@Commit bit = 1,
		@Query nvarchar(MAX) = '',
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacaGrupaId int,
		@MaUprawnienia bit = 0,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime

	BEGIN TRY
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_UserGroups_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
				
			--usuwanie tabel tymczasowych, jesli istnieja
			IF OBJECT_ID('tempdb..#GrupyUzytkownikow') IS NOT NULL
				DROP TABLE #GrupyUzytkownikow
			
			IF OBJECT_ID('tempdb..#Uzytkownicy') IS NOT NULL
				DROP TABLE #Uzytkownicy
				
			IF OBJECT_ID('tempdb..#Role') IS NOT NULL
				DROP TABLE #Role
				
			IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
				DROP TABLE #Historia
			
			IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
				DROP TABLE #Statusy
				
			IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
				DROP TABLE #IDZmienionych
				
			IF OBJECT_ID('tempdb..#GrupyKonfliktowe') IS NOT NULL
				DROP TABLE #GrupyKonfliktowe
				
			IF OBJECT_ID('tempdb..#GrupyNieUnikalne') IS NOT NULL
				DROP TABLE #GrupyNieUnikalne
				
			CREATE TABLE #GrupyKonfliktowe(ID int);	
			CREATE TABLE #GrupyNieUnikalne(ID int);
				
			CREATE TABLE #IDZmienionych (ID int);

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);
		
			--odczytywanie danych grup uzytkownika
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/UserGroup)','int') )
			)
			SELECT 	j AS 'Index'
				   ,x.value('./@Id', 'int') AS Id
				   ,x.value('./@Name', 'nvarchar(256)') AS Nazwa
				   ,x.value('./@Description', 'nvarchar(MAX)') AS Opis
				   ,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				  -- ,x.value('./@LastModifiedBy', 'int') AS LastModifiedBy
				   --,x.value('./@DeletedFrom', 'datetime') AS DeletedFrom
				   --,x.value('./@DeletedBy', 'int') AS DeletedBy
				   --,x.value('./@CreatedOn', 'datetime') AS CreatedOn
				   --,x.value('./@CreatedBy', 'int') AS CreatedBy
			INTO #GrupyUzytkownikow
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/UserGroup[position()=sql:column("j")]')  e(x);
				
			--odczytywanie danych rol dla grupy uzytkownika	
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/UserGroup)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('./@Id','int') AS Id
				,x.value('./@Name', 'nvarchar(64)') AS Nazwa
				,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
			INTO #Role
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/UserGroup[position()=sql:column("j")]/Roles/Role')  e(x);
			
			--odczytywanie danych uzytkownikow dla grupy uzytkownika	
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/UserGroup)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('./@Id','int') AS Id
				,x.value('./@Name', 'nvarchar(64)') AS Nazwa
				,x.value('./@Login', 'nvarchar(32)') AS [Login]
				,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
			INTO #Uzytkownicy
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/UserGroup[position()=sql:column("j")]/Users/User')  e(x);
			
			--odczytywanie statusow
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/UserGroup)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('../@Id','int') AS Id
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
			CROSS APPLY @xml_data.nodes('/Request/UserGroup[position()=sql:column("j")]/Statuses')  e(x);
			
			--odczytywanie historii
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/UserGroup)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('../@Id','int') AS Id
				,x.value('./@ChangeFrom', 'datetime') AS ZmianaOd 
				,x.value('./@ChangeTo', 'datetime') AS ZmianaDo
				,x.value('./@EffectiveFrom', 'datetime') AS DataObowiazywaniaOd
				,x.value('./@EffectiveTo', 'datetime') AS DataObowiazywaniaDo
				,x.value('./@IsAlternativeHistory', 'bit') AS IsAlternativeHistory
				,x.value('./@IsMainHistFlow', 'bit') AS IsMainHistFlow
			INTO #Historia 
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/UserGroup[position()=sql:column("j")]/History')  e(x);			
			
			--SELECT * FROM #Uzytkownicy;
			--SELECT * FROM #Role;
			--SELECT * FROM #GrupyUzytkownikow;
			--SELECT * FROM #Statusy;
			--SELECT * FROM #Historia;
			--SELECT @DataProgramu, @UzytkownikID, @RequestType

			IF @RequestType = 'UserGroups_Save'
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
						SELECT [Index], Id, Nazwa, Opis, LastModifiedOn FROM #GrupyUzytkownikow
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @Opis, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--wyzerowanie zmiennych
						SET @Skip = 0;
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL;
						SET @PrzetwarzanaGrupaId = NULL
						
						--sprawdzene czy grupa uzytkownikow o podanej nazwie juz istnieje
						SET @IstniejacaGrupaId = (SELECT Id FROM dbo.[GrupyUzytkownikow] WHERE Id <> @Id AND Nazwa = @Nazwa AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0);
						
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
						
						IF @IstniejacaGrupaId IS NULL
						BEGIN
							IF EXISTS (SELECT Id FROM dbo.[GrupyUzytkownikow] WHERE Id = @Id)
							BEGIN
								--aktualizacja danych slownika
								UPDATE dbo.[GrupyUzytkownikow] SET
								[Nazwa] = @Nazwa,
								[Opis] = @Opis,
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
								ValidFrom = @DataModyfikacjiApp,
								LastModifiedOn = @DataModyfikacjiApp,
								LastModifiedBy = @UzytkownikId,
								ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
								ObowiazujeDo = @DataObowiazywaniaDo,
								RealLastModifiedOn = @DataModyfikacji
								WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanaGrupaId = @Id;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaGrupaId);
								END
								ELSE
								BEGIN
									--konflikt konkurencyjnosci
									INSERT INTO #GrupyKonfliktowe(ID)
									VALUES(@Id);
									
									EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
									SET @Commit = 0;
								END
							END
							ELSE
							BEGIN						
								--wstawienie nowego uzytkownika ile juz taki nie istnieje
								INSERT INTO dbo.[GrupyUzytkownikow] (Nazwa, Opis, CreatedBy, CreatedOn, ValidFrom, RealCreatedOn, ObowiazujeOd, ObowiazujeDo,
								IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy) 
								VALUES (@Nazwa, @Opis, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacjiApp, @DataModyfikacji, 
									ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp), @DataObowiazywaniaDo,
									ISNULL(@IsStatus, 1),
									@StatusP, 
									CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
									CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
									@StatusS,
									CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
									CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
									@StatusW, 
									CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
									CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END);
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanaGrupaId = @@IDENTITY;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaGrupaId);
								END
								ELSE
								BEGIN
									SET @Skip = 1;
								END
							END
					
							--przetwarzanie danych uzytkownikow nalezacych do grupy
							IF @Skip = 0
							BEGIN
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local', 'cur2') > 0 
								BEGIN
									 CLOSE cur2
									 DEALLOCATE cur2
								END

								DECLARE cur2 CURSOR LOCAL FOR 
									SELECT Id, LastModifiedOn FROM #Uzytkownicy WHERE RootIndex = @Index
								OPEN cur2
								FETCH NEXT FROM cur2 INTO @UserId, @LastModifiedOn
								WHILE @@FETCH_STATUS = 0
								BEGIN				
									--sprawdzenie czy istnieje grupa o podanej nazwie i czasie ostatniej aktualicacji - dla wyeliminowania kolizji
									IF EXISTS(SELECT Id FROM dbo.Uzytkownicy WHERE Id = @UserId) -- AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn)))
									BEGIN							
										IF EXISTS (SELECT Uzytkownik FROM [GrupaUzytkownikowUzytkownik] WHERE GrupaUzytkownikow = @PrzetwarzanaGrupaId AND Uzytkownik = @UserId)
										BEGIN
											UPDATE [GrupaUzytkownikowUzytkownik] SET
											ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
											ObowiazujeDo = @DataObowiazywaniaDo,
											LastModifiedOn = @DataModyfikacjiApp,
											LastModifiedBy = @UzytkownikId,
											RealLastModifiedOn = @DataModyfikacji,
											IsValid = 1,
											ValidTo = NULL,
											IsDeleted = 0,
											DeletedFrom = NULL,
											DeletedBy = NULL
											WHERE GrupaUzytkownikow = @PrzetwarzanaGrupaId AND Uzytkownik = @UserId;
										END
										ELSE
										BEGIN								
											INSERT INTO [GrupaUzytkownikowUzytkownik] (GrupaUzytkownikow, Uzytkownik, ObowiazujeOd, ObowiazujeDo, CreatedBy, CreatedOn, ValidFrom, RealCreatedOn)
											VALUES (@PrzetwarzanaGrupaId, @UserId, ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp), @DataObowiazywaniaDo, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacjiApp, @DataModyfikacji);								
										END							
									END
									
									FETCH NEXT FROM cur2 INTO @UserId, @LastModifiedOn
								END
								CLOSE cur2
								DEALLOCATE cur2
						
								--przetwarzanie rol powiazanych z grupa uzytkownikow
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local', 'cur3') > 0 
								BEGIN
									 CLOSE cur3
									 DEALLOCATE cur3
								END

								DECLARE cur3 CURSOR LOCAL FOR 
									SELECT Id, LastModifiedOn FROM #Role WHERE RootIndex = @Index
								OPEN cur3
								FETCH NEXT FROM cur3 INTO @RolaId, @LastModifiedOn
								WHILE @@FETCH_STATUS = 0
								BEGIN				
									--sprawdzenie czy istnieje grupa o podanej nazwie i czasie ostatniej aktualicacji - dla wyeliminowania kolizji
									IF EXISTS(SELECT Id FROM dbo.[Role] WHERE Id = @RolaId) -- AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn)))
									BEGIN							
										IF EXISTS (SELECT Rola FROM [RolaGrupaUzytkownikow] WHERE GrupaUzytkownikow = @PrzetwarzanaGrupaId AND Rola = @RolaId)
										BEGIN
											UPDATE [RolaGrupaUzytkownikow] SET
											ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
											ObowiazujeDo = @DataObowiazywaniaDo,
											LastModifiedOn = @DataModyfikacjiApp,
											LastModifiedBy = @UzytkownikId,
											ValidFrom = @DataModyfikacjiApp,
											RealLastModifiedOn = @DataModyfikacji,
											IsValid = 1,
											ValidTo = NULL,
											IsDeleted = 0,
											DeletedFrom = NULL,
											DeletedBy = NULL
											WHERE GrupaUzytkownikow = @PrzetwarzanaGrupaId AND Rola = @RolaId;
										END
										ELSE
										BEGIN								
											INSERT INTO [RolaGrupaUzytkownikow] (GrupaUzytkownikow, Rola, ObowiazujeOd, ObowiazujeDo, CreatedBy, CreatedOn, RealCreatedOn, ValidFrom)
											VALUES (@PrzetwarzanaGrupaId, @RolaId, ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp), @DataObowiazywaniaDo, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacji, @DataModyfikacjiApp);								
										END							
									END
									
									FETCH NEXT FROM cur3 INTO @RolaId, @LastModifiedOn
								END
								CLOSE cur3
								DEALLOCATE cur3
							END
						END
						ELSE
						BEGIN
							-- uzytkownik o podanych danych juz istnieje, dodanie jego ID do tabeli tymczasowej
							INSERT INTO #GrupyNieUnikalne(ID)
							VALUES(@IstniejacaGrupaId);
							
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Grupa użytkowników' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
						END
						
						FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @Opis, @LastModifiedOn
						
					END
					CLOSE cur
					DEALLOCATE cur
				
					--SELECT * FROM #IDZmienionych
					--SELECT * FROM #GrupyNieUnikalne
					--SELECT * FROM #GrupyKonfliktowe;
					
					IF (SELECT COUNT(1) FROM #GrupyKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT gu.[Id] AS "@Id"
										,gu.[Nazwa] AS "@Name"
										,gu.[Opis] AS "@Description"
									  --,gu.[IsDeleted] AS "@IsDeleted"
									  --,gu.[DeletedFrom] AS "@DeletedFrom"
									  --,gu.[DeletedBy] AS "@DeletedBy"
									  ,gu.[CreatedOn] AS "@CreatedOn"
									  ,gu.[CreatedBy] AS "@CreatedBy"
									  ,ISNULL(gu.[LastModifiedOn], gu.[CreatedOn]) AS "@LastModifiedOn"
									  ,gu.[LastModifiedBy] AS "@LastModifiedBy"							
							FROM [GrupyUzytkownikow] gu
							WHERE Id IN (SELECT ID FROM #GrupyKonfliktowe)
							FOR XML PATH('UserGroup')
						) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #GrupyNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT gu.[Id] AS "@Id"
										,gu.[Nazwa] AS "@Name"
										,gu.[Opis] AS "@Description"
									  --,gu.[IsDeleted] AS "@IsDeleted"
									  --,gu.[DeletedFrom] AS "@DeletedFrom"
									  --,gu.[DeletedBy] AS "@DeletedBy"
									  ,gu.[CreatedOn] AS "@CreatedOn"
									  ,gu.[CreatedBy] AS "@CreatedBy"
									  ,ISNULL(gu.[LastModifiedOn], gu.[CreatedOn]) AS "@LastModifiedOn"
									  ,gu.[LastModifiedBy] AS "@LastModifiedBy"							
							FROM [GrupyUzytkownikow] gu
							WHERE Id IN (SELECT ID FROM #GrupyNieUnikalne)
							FOR XML PATH('UserGroup')
									) AS nvarchar(MAX)), '');
					END
					
					SET @xmlResponse = (
							SELECT TOP 1 NULL AS '@Ids'
							, (
								SELECT Id AS '@Id'
								,'UserGroup' AS '@EntityType'
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
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UserGroups_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UserGroups_Save', @Wiadomosc = @ERRMSG OUTPUT
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
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UserGroups_Save"';
	
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
		
	IF OBJECT_ID('tempdb..#GrupyKonfliktowe') IS NOT NULL
		DROP TABLE #GrupyKonfliktowe
		
	IF OBJECT_ID('tempdb..#GrupyNieUnikalne') IS NOT NULL
		DROP TABLE #GrupyNieUnikalne
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
