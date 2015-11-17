-- =============================================
-- Author:		DK
-- Create date: 2012-03-07
-- Last modified on: 2013-02-12
-- Description:	Zapisuje dane branz w bazie. Aktualizuje istniejacy lub wstawia nowy rekord.

-- XML wejsciowy:

	--<Request RequestType="Branches_Save" UserId="1" AppDate="2012-02-09"
	--	xsi:noNamespaceSchemaLocation="3.2.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Branch Id="1" Name="adqwqwe" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--	<Branch Id="2" Name="adqwqwe2" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--	<Branch Id="3" Name="adqwqwe3" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--	<Branch Id="4" Name="adqwqwe4" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Branches_Save" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="3.2.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="Branch" />
	--			<Ref Id="2" EntityType="Branch" />
	--			<Ref Id="3" EntityType="Branch" />
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Branches_Save]
(
	@XMLDataIn nvarchar(MAX),
	@XmlDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@RequestType nvarchar(100),
		@LastModifiedOn datetime,
		@UzytkownikID int,
		@BranzaID int,
		@Id int,
		@Nazwa nvarchar(50),
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@IsStatus bit,
		@xmlOk bit = 0,
		@xml_data xml,
		@MaUprawnienia bit = 0,
		@Index int,
		@ERRMSG nvarchar(255),
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
		@IstniejacaBranzaId int,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#Branze') IS NOT NULL
			DROP TABLE #Branze
			
		IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
			DROP TABLE #IDZmienionych
			
		IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
			DROP TABLE #Statusy
			
		IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
			DROP TABLE #Historia
			
		IF OBJECT_ID('tempdb..#BranzeKonfliktowe') IS NOT NULL
			DROP TABLE #BranzeKonfliktowe
			
		IF OBJECT_ID('tempdb..#BranzeNieUnikalne') IS NOT NULL
			DROP TABLE #BranzeNieUnikalne
				
			CREATE TABLE #BranzeKonfliktowe(ID int);	
			CREATE TABLE #BranzeNieUnikalne(ID int);
			
		CREATE TABLE #IDZmienionych (ID int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Branches_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co robic na zlej walidacji?			
			SET @ERRMSG = @ERRMSG
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
							
			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)
			
			--odczytywanie danych branz
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/Branch)','int') )
			)
			SELECT 	j AS 'Index'
				,x.value('./@Id','int') AS Id
				,x.value('./@Name', 'nvarchar(200)') AS Nazwa
				,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
			INTO #Branze
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Branch[position()=sql:column("j")]')  e(x);			
			
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/Branch)','int') )
			)
			SELECT 	j AS 'RootIndex'
				,x.value('./@ChangeFrom', 'datetime') AS ZmianaOd 
				,x.value('./@ChangeTo', 'datetime') AS ZmianaDo
				,x.value('./@EffectiveFrom', 'datetime') AS DataObowiazywaniaOd
				,x.value('./@EffectiveTo', 'datetime') AS DataObowiazywaniaDo
				,x.value('./@IsAlternativeHistory', 'bit') AS IsAlternativeHistory
				,x.value('./@IsMainHistFlow', 'bit') AS IsMainHistFlow
			INTO #Historia
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Branch[position()=sql:column("j")]/History')  e(x);
			
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/Branch)','int') )
			)
			SELECT 	j AS 'RootIndex'
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
			CROSS APPLY @xml_data.nodes('/Request/Branch[position()=sql:column("j")]/Statuses')  e(x);
		
			--SELECT * FROM #Branze;
			--select * from #Historia
			--select * from #Statusy

			IF @RequestType = 'Branches_Save'
			BEGIN	
				
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);
			
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji save
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
					BEGIN TRANSACTION T1_Branches_Save
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur_Branches_Save') > 0 
					BEGIN
						 CLOSE cur_Branches_Save
						 DEALLOCATE cur_Branches_Save
					END
			
					DECLARE cur_Branches_Save CURSOR LOCAL FOR 
					SELECT [Index], Id, Nazwa, LastModifiedOn FROM #Branze
					OPEN cur_Branches_Save
					FETCH NEXT FROM cur_Branches_Save INTO @Index, @Id, @Nazwa, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						--wyzerowanie zmiennych, potrzebne!
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL;											
						
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, 
						@DataObowiazywaniaOd = DataObowiazywaniaOd, @DataObowiazywaniaDo = DataObowiazywaniaDo
						FROM #Historia WHERE RootIndex = @Index;
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index

-- pole obecnie nie uzywane		
SET @DataObowiazywaniaDo = NULL;
						
						SET @IstniejacaBranzaId = (SELECT Id FROM [Branze] WHERE Nazwa = @Nazwa AND Id <> @Id AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0);
						
						--jesli branza o podanej nazie niestnieje
						IF @IstniejacaBranzaId IS NULL
						BEGIN
							--jesli branza o podanym ID juz istnieje to jej aktualizacja (blokada na update branzy nr 0
							IF EXISTS (SELECT Id FROM [Branze] WHERE Id = @Id AND @Id <> 0)
							BEGIN													
								UPDATE [Branze] SET
								Nazwa = @Nazwa,
								StatusP = @StatusP,								
								StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
								StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
								StatusS = @StatusS,								
								StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
								StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
								StatusW = @StatusW,
								StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
								StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
								IsStatus = ISNULL(@IsStatus, 0),
								LastModifiedOn = @DataModyfikacjiApp,
								LastModifiedBy = @UzytkownikID,
								RealLastModifiedOn = @DataModyfikacji,
								ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
								ObowiazujeDo = @DataObowiazywaniaDo
								WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
								
								IF @@ROWCOUNT > 0
								BEGIN
									INSERT INTO #IDZmienionych
									VALUES(@Id);
								END
								ELSE
								BEGIN
									--wystapil konflikt konkurencji - data ostaniej modyfikacji sie nie zgadza									
									INSERT INTO #BranzeKonfliktowe(ID)
									VALUES(@Id);
										
									EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
									SET @Commit = 0;	
								END
							END
							ELSE
							BEGIN
								--jesli nie istnieje to jej wstawienie do bazy
								INSERT INTO [Branze] (Nazwa, IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy, 
									CreatedBy, CreatedOn, RealCreatedOn, ValidFrom, ObowiazujeOd, ObowiazujeDo, IsAlternativeHistory, IsMainHistFlow)
								VALUES(
									@Nazwa,
									ISNULL(@IsStatus, 0),
									@StatusP, 
									CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
									CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
									@StatusS,
									CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
									CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
									@StatusW, 
									CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
									CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END, 
									@UzytkownikID,
									@DataModyfikacjiApp,
									@DataModyfikacji,
									@DataModyfikacjiApp,
									ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
									@DataObowiazywaniaDo,
									0,
									1
								);
						
								IF @@ROWCOUNT > 0
								BEGIN
									INSERT INTO #IDZmienionych
									VALUES(@@IDENTITY);
								END
							END
						END
						ELSE
						BEGIN
							--branza o podanej nazwie juz istnieje - dodanie danych do wartosci nieunikalnych							
							INSERT INTO #BranzeNieUnikalne(ID)
							VALUES(@IstniejacaBranzaId);
							
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Branża' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
						END
						
						FETCH NEXT FROM cur_Branches_Save INTO @Index, @Id, @Nazwa, @LastModifiedOn
					END
					CLOSE cur_Branches_Save
					DEALLOCATE cur_Branches_Save
					
					IF (SELECT COUNT(1) FROM #BranzeKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT b.[Id] AS "@Id"
							  ,b.[Nazwa] AS "@Name"
							  ,b.[CreatedOn] AS "@CreatedOn"
							  ,b.[CreatedBy] AS "@CreatedBy"
							  ,ISNULL(b.[LastModifiedOn], b.[CreatedOn]) AS "@LastModifiedOn"
							  ,b.[LastModifiedBy] AS "@LastModifiedBy"							
							FROM [Branze] b
							WHERE Id IN (SELECT ID FROM #BranzeKonfliktowe)
							FOR XML PATH('Branch')
						) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #BranzeNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT b.[Id] AS "@Id"
							  ,b.[Nazwa] AS "@Name"
							  ,b.[CreatedOn] AS "@CreatedOn"
							  ,b.[CreatedBy] AS "@CreatedBy"
							  ,ISNULL(b.[LastModifiedOn], b.[CreatedOn]) AS "@LastModifiedOn"
							  ,b.[LastModifiedBy] AS "@LastModifiedBy"								
						FROM [Branze] b
						WHERE Id IN (SELECT ID FROM #BranzeNieUnikalne)
						FOR XML PATH('Branch')
					) AS nvarchar(MAX)), '');
					END					
					
					IF @Commit = 1
						COMMIT TRAN T1_Branches_Save;
					ELSE
						ROLLBACK TRAN T1_Branches_Save;
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Branches_Save', @Wiadomosc = @ERRMSG OUTPUT		
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Branches_Save', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF Cursor_Status('local','cur_Branches_Save') > 0 
		BEGIN
			 CLOSE cur_Branches_Save
			 DEALLOCATE cur_Branches_Save
		END
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_Branches_Save
		END
		
	END CATCH 
	
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Branches_Save"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG IS NULL OR @ERRMSG = '' 	
	BEGIN
		IF (SELECT COUNT(1) FROM #IdZmienionych) > 0
		BEGIN
			SET @XMLDataOut += ISNULL(CAST( 
				(SELECT TOP 1
					(SELECT ID AS '@Id',
					'Branch' AS '@EntityType'
					FROM #IDZmienionych
					FOR XML PATH('Ref'), ROOT('Value'), TYPE
					)
				FROM #IDZmienionych
				FOR XML PATH('Result')
				) AS nvarchar(MAX)), '');			
		END
		ELSE
			SET @XMLDataOut += '<Result><Value/></Result>';
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '">'
		
		--dodawanie danych rekordow nie zapisanych z powodu konkurencji
		IF @xmlErrorConcurrency IS NOT NULL AND LEN(@xmlErrorConcurrency) > 3
		BEGIN
			SET @XMLDataOut += '<ConcurrencyConflicts>' + @xmlErrorConcurrency + '</ConcurrencyConflicts>';
		END
		
		--dodawanie danych rekordow nie zapisanych z powodu konfliktow
		IF @xmlErrorsUnique IS NOT NULL AND LEN(@xmlErrorsUnique) > 3
		BEGIN
			SET @XMLDataOut += '<UniquenessConflicts>' + @xmlErrorsUnique + '</UniquenessConflicts>';
		END
		
		SET @XMLDataOut += '</Error></Result>';
	END
	
	SET @XMLDataOut += '</Response>';
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#Branze') IS NOT NULL
		DROP TABLE #Branze
		
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
		
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#BranzeKonfliktowe') IS NOT NULL
		DROP TABLE #BranzeKonfliktowe
		
	IF OBJECT_ID('tempdb..#BranzeNieUnikalne') IS NOT NULL
		DROP TABLE #BranzeNieUnikalne
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
