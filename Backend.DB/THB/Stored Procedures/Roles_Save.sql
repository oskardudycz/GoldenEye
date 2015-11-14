-- =============================================
-- Author:		DK
-- Create date: 2012-03-22
-- Last modified on: 2013-02-12
-- Description:	Zapisuje dane roli i podleglych operacji. Aktualizuje istniejacy lub wstawia nowy rekord.

-- XML wejsciowy w postaci:

	--<Request RequestType="Roles_Save" UserId="1" AppDate="2012-02-09T12:11:34"
	--	xsi:noNamespaceSchemaLocation="19.2.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	    
	--	<Role Id="1" Name="Rola 1" Rank="16" Description="opis" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<CouplerRoleOperation RoleId="1" OperationId="2" BranchId="12">
	--			<Role Id="1" Name="3321" Description="2213213" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--			<Operation Id="2" Name="1212" Description="213213" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--			<Branch Id="12" Name="12323" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		</CouplerRoleOperation>
	--	</Role>
	
	--	<Role Id="0" Name="Rola 2" Rank="50" Description="2331232" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<CouplerRoleOperation RoleId="1" OperationId="2" BranchId="12">
	--			<Role Id="1" Name="3321" Description="2213213" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--			<Operation Id="2" Name="1212" Description="213213" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--			<Branch Id="12" Name="12323" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		</CouplerRoleOperation>
	--	</Role>
	    
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Roles_Save" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="10.2.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="Role" />
	--			<Ref Id="2" EntityType="Role" />
	--			<Ref Id="3" EntityType="Role" />
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Roles_Save]
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
		@Rank smallint,
		@Index int,
		@LastModifiedOn datetime,
		@Opis nvarchar(MAX),
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@PrzetwarzanaRolaId int,
		@Skip bit = 0,
		@MaUprawnienia bit = 0,
		@RolaId int,
		@OperacjaId int,
		@BranzaDlaRoliId int,
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
		@IstniejacaRolaId int,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@IsStatus bit

	BEGIN TRY
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Roles_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
				
			--usuwanie tabel tymczasowych, jesli istnieja
			IF OBJECT_ID('tempdb..#Role') IS NOT NULL
				DROP TABLE #Role
				
			IF OBJECT_ID('tempdb..#OperacjeDlaRoli') IS NOT NULL
				DROP TABLE #OperacjeDlaRoli
				
			CREATE TABLE #OperacjeDlaRoli (RootIndex int, RolaId int, OperacjaId int, BranzaId int);
				
			IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
				DROP TABLE #Historia
				
			IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
				DROP TABLE #Statusy
				
			IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
				DROP TABLE #IDZmienionych
				
			IF OBJECT_ID('tempdb..#RoleKonfliktowe') IS NOT NULL
				DROP TABLE #RoleKonfliktowe
				
			IF OBJECT_ID('tempdb..#RoleNieUnikalne') IS NOT NULL
				DROP TABLE #RoleNieUnikalne
				
			CREATE TABLE #RoleKonfliktowe(ID int);	
			CREATE TABLE #RoleNieUnikalne(ID int);
				
			CREATE TABLE #IDZmienionych (ID int);

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);
		
			--odczytywanie danych rol
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/Role)','int') )
			)
			SELECT 	j AS 'Index'
				   ,x.value('./@Id', 'int') AS Id
				   ,x.value('./@Name', 'nvarchar(256)') AS Nazwa
				   ,x.value('./@Rank', 'smallint') AS [Rank]
				   ,x.value('./@Description', 'nvarchar(MAX)') AS Opis
				   ,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				   --,x.value('./@LastModifiedBy', 'int') AS LastModifiedBy
				   --,x.value('./@IsDeleted', 'bit') AS IsDeleted
				   --,x.value('./@DeletedFrom', 'datetime') AS DeletedFrom
				   --,x.value('./@DeletedBy', 'int') AS DeletedBy
				   --,x.value('./@CreatedOn', 'datetime') AS CreatedOn
				   --,x.value('./@CreatedBy', 'int') AS CreatedBy
			INTO #Role
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Role[position()=sql:column("j")]')  e(x);
				
			--odczytywanie danych operacji dla roli	
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/Role)','int') )
			)
			INSERT INTO #OperacjeDlaRoli
			SELECT j --AS 'RootIndex'
				,x.value('./@RoleId','int') --AS RolaId
				,x.value('./@OperationId', 'int') --AS OperacjaId
				,x.value('./@BranchId', 'int') --AS BranzaId
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Role[position()=sql:column("j")]/CouplerRoleOperation')  e(x);
			
			--odczytywanie historii
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/UnitOfMeasure)','int') )
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
			CROSS APPLY @xml_data.nodes('/Request/Role[position()=sql:column("j")]/History')  e(x);
			
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
			CROSS APPLY @xml_data.nodes('/Request/Role[position()=sql:column("j")]/Statuses')  e(x);		
			
			--SELECT * FROM #Role;
			--SELECT * FROM #OperacjeDlaRoli;
			--SELECT * FROM #Historia;
			--SELECT @DataProgramu, @UzytkownikID, @RequestType

			IF @RequestType = 'Roles_Save'
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
					BEGIN TRAN T1_Roles_Save
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
				
					DECLARE cur CURSOR LOCAL FOR 
						SELECT [Index], Id, Nazwa, Opis, [Rank], LastModifiedOn FROM #Role
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @Opis, @Rank, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--wyzerowanie zmiennych, potrzebne bo jak nie znajduje danych w tabelkach to nie nadpisuje NULLem
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL;
						SET @Skip = 0;
						SET @IstniejacaRolaId = (SELECT Id FROM dbo.[Role] WHERE Id <> @Id AND Nazwa = @Nazwa AND IsValid = 1 AND IdArch IS NULL AND IsDeleted = 0)
						
						--pobrnaie danych zwiazanych z datami zmian
						SELECT	@ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd, @DataObowiazywaniaDo = DataObowiazywaniaDo
						FROM #Historia WHERE RootIndex = @Index;
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index
						
						--zastapienie NULLi wartosciami domyslnymi
						SELECT @IsStatus = ISNULL(@IsStatus, 1), @StatusP = ISNULL(@StatusP, 0), @StatusS = ISNULL(@StatusS, 0), @StatusW = ISNULL(@StatusW, 0);	

--daty Do narazie nie uzywamy
SET @DataObowiazywaniaDo = NULL;

						IF @IstniejacaRolaId IS NULL
						BEGIN
							IF EXISTS (SELECT Id FROM dbo.[Role] WHERE Id = @Id)
							BEGIN
								--aktualizacja danych roli
								UPDATE dbo.[Role] SET
								Nazwa = @Nazwa,
								[Rank] = @Rank,
								Opis = @Opis,
								LastModifiedOn = @DataModyfikacjiApp,
								LastModifiedBy = @UzytkownikID,
								RealLastModifiedOn = @DataModyfikacji,
								ValidFrom = @DataModyfikacjiApp,
								ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
								ObowiazujeDo = @DataObowiazywaniaDo,
								StatusP = @StatusP,								
								StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
								StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
								StatusS = @StatusS,								
								StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
								StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
								StatusW = @StatusW,
								StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
								StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
								IsStatus = ISNULL(@IsStatus, 1)
								WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanaRolaId = @Id;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaRolaId);
								END
								ELSE
								BEGIN
									--konflikt konkurencyjnosci
									INSERT INTO #RoleKonfliktowe(ID)
									VALUES(@Id);
									
									EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
									SET @Commit = 0;
									SET @Skip = 1;
								END
							END
							ELSE
							BEGIN						
								--wstawienie nowej roli o ile juz taki nie istnieje
								IF NOT EXISTS (SELECT Id FROM dbo.[Role] WHERE Nazwa = @Nazwa AND IdArch IS NULL AND IsValid = 1)
								BEGIN

									INSERT INTO dbo.[Role] (Nazwa, Opis, [Rank], CreatedBy, CreatedOn, RealCreatedOn, ValidFrom, ObowiazujeOd, ObowiazujeDo,
									IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy, IsAlternativeHistory, IsMainHistFlow) 
									VALUES (@Nazwa, @Opis, @Rank, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacji, @DataModyfikacjiApp,
										ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp), @DataObowiazywaniaDo, ISNULL(@IsStatus, 1), @StatusP, 
										CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
										CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
										@StatusS,
										CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
										CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
										@StatusW, 
										CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
										CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
										0,
										1);
									
									IF @@ROWCOUNT > 0
									BEGIN
										SET @PrzetwarzanaRolaId = @@IDENTITY;
										INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaRolaId);
									END
								END
								ELSE
									SET @Skip = 1;
							END
				
							--przetwarzanie danych operacji dla rol
							IF @Skip = 0
							BEGIN
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local', 'cur2') > 0 
								BEGIN
									 CLOSE cur2
									 DEALLOCATE cur2
								END

								DECLARE cur2 CURSOR LOCAL FOR 
									SELECT RolaId, OperacjaId, BranzaId FROM #OperacjeDlaRoli WHERE RootIndex = @Index 
								OPEN cur2
								FETCH NEXT FROM cur2 INTO @RolaId, @OperacjaId, @BranzaDlaRoliId
								WHILE @@FETCH_STATUS = 0
								BEGIN						

									IF EXISTS (SELECT Rola FROM dbo.[RolaOperacja] WHERE Rola = @PrzetwarzanaRolaId AND Operacja = @OperacjaId AND Branza = @BranzaDlaRoliId)
									BEGIN
										UPDATE [RolaOperacja] SET
										ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
										ObowiazujeDo = @DataObowiazywaniaDo,
										LastModifiedBy = @UzytkownikId,
										LastModifiedOn = @DataModyfikacjiApp,
										RealLastModifiedOn = @DataModyfikacji
										WHERE Rola = @PrzetwarzanaRolaId AND Operacja = @OperacjaId AND Branza = @BranzaDlaRoliId;
									END
									ELSE
									BEGIN								
										INSERT INTO [RolaOperacja] (Rola, Operacja, Branza, CreatedBy, CreatedOn, RealCreatedOn, ObowiazujeOd, ObowiazujeDo)
										VALUES (@PrzetwarzanaRolaId, @OperacjaId, @BranzaDlaRoliId, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacji,
										ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp), @DataObowiazywaniaDo);								
									END						
																
									FETCH NEXT FROM cur2 INTO @RolaId, @OperacjaId, @BranzaDlaRoliId
								END
								CLOSE cur2
								DEALLOCATE cur2
							END
						END
						ELSE
						BEGIN
							-- rola o podanych danych juz istnieje, dodanie jego ID do tabeli tymczasowej
							INSERT INTO #RoleNieUnikalne(ID)
							VALUES(@IstniejacaRolaId);
							
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Rola' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
						END
						
						FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @Opis, @Rank, @LastModifiedOn
						
					END
					CLOSE cur
					DEALLOCATE cur
				
					--SELECT * FROM #IDZmienionych
					--SELECT * FROM #IDZmienionychPrzelicznikow
					
					IF (SELECT COUNT(1) FROM #RoleKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT r.[Id] AS "@Id"
									,r.[Nazwa] AS "@Name"
									,r.[Opis] AS "@Description"
									,r.[Rank] AS "@Rank"
									,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
									, (SELECT ro.[Rola] AS "@RoleId"
										,ro.[Operacja] AS "@OperationId"
										,ro.[Branza] AS "@BranchId"
										, (SELECT r2.[Id] AS "@Id"
											,r2.[Nazwa] AS "@Name"
											,r2.[Opis] AS "@Description"
											,ISNULL(r2.[LastModifiedOn], r2.[CreatedOn]) AS "@LastModifiedOn"
											FROM [Role] r2
											WHERE r2.Id = ro.Rola
											FOR XML PATH('Role'), TYPE)										
										, (SELECT o.[Id] AS "@Id"
											,o.[Nazwa] AS "@Name"
											,o.[Opis] AS "@Description"
											,ISNULL(o.[LastModifiedOn], o.[CreatedOn]) AS "@LastModifiedOn"
											FROM [Operacje] o
											WHERE o.Id = ro.Operacja
											FOR XML PATH('Operation'), TYPE)										
										, (SELECT b.[Id] AS "@Id"
											,b.[Nazwa] AS "@Name"
											,ISNULL(b.[LastModifiedOn], b.[CreatedOn]) AS "@LastModifiedOn"
											FROM [Branze] b
											WHERE b.Id = ro.Branza
											FOR XML PATH('Branch'), TYPE)									
										FROM [RolaOperacja] ro
										WHERE ro.Rola = r.Id
										FOR XML PATH('CouplerRoleOperation'), TYPE)							
								FROM [Role] r
								WHERE Id IN (SELECT ID FROM #RoleKonfliktowe)
								FOR XML PATH('Role')
							) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #RoleNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT r.[Id] AS "@Id"
									,r.[Nazwa] AS "@Name"
									,r.[Opis] AS "@Description"
									,r.[Rank] AS "@Rank"
									,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
									, (SELECT ro.[Rola] AS "@RoleId"
										,ro.[Operacja] AS "@OperationId"
										,ro.[Branza] AS "@BranchId"
										, (SELECT r2.[Id] AS "@Id"
											,r2.[Nazwa] AS "@Name"
											,r2.[Opis] AS "@Description"
											,ISNULL(r2.[LastModifiedOn], r2.[CreatedOn]) AS "@LastModifiedOn"
											FROM [Role] r2
											WHERE r2.Id = ro.Rola
											FOR XML PATH('Role'), TYPE)										
										, (SELECT o.[Id] AS "@Id"
											,o.[Nazwa] AS "@Name"
											,o.[Opis] AS "@Description"
											,ISNULL(o.[LastModifiedOn], o.[CreatedOn]) AS "@LastModifiedOn"
											FROM [Operacje] o
											WHERE o.Id = ro.Operacja
											FOR XML PATH('Operation'), TYPE)										
										, (SELECT b.[Id] AS "@Id"
											,b.[Nazwa] AS "@Name"
											,ISNULL(b.[LastModifiedOn], b.[CreatedOn]) AS "@LastModifiedOn"
											FROM [Branze] b
											WHERE b.Id = ro.Branza
											FOR XML PATH('Branch'), TYPE)									
										FROM [RolaOperacja] ro
										WHERE ro.Rola = r.Id
										FOR XML PATH('CouplerRoleOperation'), TYPE)							
									FROM [Role] r
									WHERE Id IN (SELECT ID FROM #RoleNieUnikalne)
									FOR XML PATH('Role')
								) AS nvarchar(MAX)), '');
					END
					
					SET @xmlResponse = ( 
						SELECT TOP 1
							(SELECT ID AS '@Id',
							'Role' AS '@EntityType'
							FROM #IDZmienionych
							FOR XML PATH('Ref'), ROOT('Value'), TYPE
							)
						FROM #IDZmienionych
						FOR XML PATH('Result')
						);
						
					IF @Commit = 1
						COMMIT TRAN T1_Roles_Save;
					ELSE
						ROLLBACK TRAN T1_Roles_Save;														
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Roles_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Roles_Save', @Wiadomosc = @ERRMSG OUTPUT 
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN T1_Roles_Save
	END CATCH
	
	IF @DataProgramu IS NULL
		SET @DataProgramu = GETDATE();

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Roles_Save" AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '">';
	
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
	IF OBJECT_ID('tempdb..#Role') IS NOT NULL
		DROP TABLE #Role
		
	IF OBJECT_ID('tempdb..#OperacjeDlaRoli') IS NOT NULL
		DROP TABLE #OperacjeDlaRoli
		
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
	
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#RoleKonfliktowe') IS NOT NULL
		DROP TABLE #RoleKonfliktowe
		
	IF OBJECT_ID('tempdb..#RoleNieUnikalne') IS NOT NULL
		DROP TABLE #RoleNieUnikalne
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
		
END
