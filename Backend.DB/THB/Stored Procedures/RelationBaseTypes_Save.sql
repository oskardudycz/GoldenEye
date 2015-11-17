-- =============================================
-- Author:		DK
-- Create date: 2012-08-21
-- Last modified on: 2013-02-12
-- Description:	Zapisuje dane bazowego typu relacji (tabela Relacja_Typ). Aktualizuje istniejacy rekord lub wstawia nowy rekord.

-- XML wejsciowy w postaci:

	--<Request RequestType="RelationBaseTypes_Save" UserId="1" AppDate="2012-02-09T22:11:34">
		
	--	<RelationBaseType Id="11" Name="bazowa1"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121" ChangeTo="2012-02-09T12:12:12.121" EffectiveFrom="2012-02-09T12:12:12.121" EffectiveTo="2012-02-09T12:12:12.121" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121" StatusSTo="2012-02-09T12:12:12.121" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121" StatusWTo="2012-02-09T12:12:12.121" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121" StatusPTo="2012-02-09T12:12:12.121" StatusPFromBy="1" StatusPToBy="1" />
	--	</RelationType>
		
	--	<RelationType Id="0" Name="efew2"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121" ChangeTo="2012-02-09T12:12:12.121" EffectiveFrom="2012-02-09T12:12:12.121" EffectiveTo="2012-02-09T12:12:12.121" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121" StatusSTo="2012-02-09T12:12:12.121" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121" StatusWTo="2012-02-09T12:12:12.121" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121" StatusPTo="2012-02-09T12:12:12.121" StatusPFromBy="1" StatusPToBy="1" />
	--	</RelationType>
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="RelationBaseTypes_Save" AppDate="2012-02-09">
	--	<Result>
	--		<Value>
	--			<Ref Id="11" EntityType="RelationBaseType" />
	--			<Ref Id="24" EntityType="RelationBaseType" />
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[RelationBaseTypes_Save]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_typ nvarchar(50),
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@xmlOk bit,
		@xml_data xml,
		@BranzaID int,
		@Id int,
		@Nazwa nvarchar(64),
		@Index int,
		@LastModifiedOn datetime,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@PrzetwarzanyTypRelacjiId int,
		@IloscTypowRelacji int = 0,
		@MaUprawnienia bit = 0,
		@Commit bit = 1,
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacyTypRelacjiId int,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@IsStatus bit,
		@StatusP int,
		@StatusW int,
		@StatusS int,
		@IsAlternativeHistory bit,
		@IsMainHistFlow bit

	BEGIN TRY
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_RelationBaseTypes_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
				
			--usuwanie tabel tymczasowych, jesli istnieja			
			IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
				DROP TABLE #Historia
			
			IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
				DROP TABLE #Statusy
			
			IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
				DROP TABLE #IDZmienionych
				
			IF OBJECT_ID('tempdb..#BazoweTypyRelacji') IS NOT NULL
				DROP TABLE #BazoweTypyRelacji
				
			IF OBJECT_ID('tempdb..#BazoweTypyRelacjiKonfliktowe') IS NOT NULL
				DROP TABLE #BazoweTypyRelacjiKonfliktowe
			
			IF OBJECT_ID('tempdb..#BazoweTypyRelacjiNieUnikalne') IS NOT NULL
				DROP TABLE #BazoweTypyRelacjiNieUnikalne
				
			CREATE TABLE #BazoweTypyRelacjiKonfliktowe(ID int);	
			CREATE TABLE #BazoweTypyRelacjiNieUnikalne(ID int);	
				
			CREATE TABLE #IDZmienionych (ID int);
			
			--pobranie ilosci typow relacji do zapisu
			SET @IloscTypowRelacji = (SELECT @xml_data.value('count(/Request/RelationBaseType)','int') )

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);
			
			--odczytywanie danych typow relacji
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowRelacji
			)
			SELECT 	j AS 'Index'
				   ,x.value('./@Id', 'int') AS Id
				   ,x.value('./@Name', 'nvarchar(256)') AS Nazwa
				   ,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				  -- ,x.value('./@LastModifiedBy', 'int') AS LastModifiedBy
				   --,x.value('./@CreatedOn', 'datetime') AS CreatedOn
				   --,x.value('./@CreatedBy', 'int') AS CreatedBy
			INTO #BazoweTypyRelacji
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/RelationBaseType[position()=sql:column("j")]')  e(x);
			
			--odczytywanie statusow
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowRelacji
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
			CROSS APPLY @xml_data.nodes('/Request/RelationBaseType[position()=sql:column("j")]/Statuses')  e(x);
			
			--odczytywanie historii
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowRelacji
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
			CROSS APPLY @xml_data.nodes('/Request/RelationBaseType[position()=sql:column("j")]/History')  e(x);				
				
			--SELECT * FROM #BazoweTypyRelacji
			--SELECT * FROM #Statusy;
			--SELECT * FROM #Historia;
			--SELECT @DataProgramu, @UzytkownikID, @RequestType

			IF @RequestType = 'RelationBaseTypes_Save'
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
				
					BEGIN TRAN RelationBT_SAVE
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
					
					DECLARE cur CURSOR LOCAL FOR 
						SELECT [Index], Id, Nazwa, LastModifiedOn FROM #BazoweTypyRelacji
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						--wyzerowanie zmiennych, potrzebne!
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL, @IsAlternativeHistory = 0, @IsMainHistFlow = 0;
						
						--pobranie danych historii
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
						@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
						FROM #Historia WHERE RootIndex = @Index;
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index;

-- pole obecnie nie uzywane		
SET @DataObowiazywaniaDo = NULL;

						
						SET @IstniejacyTypRelacjiId = (SELECT Id FROM dbo.[Relacja_Typ] WHERE Id <> @Id AND Nazwa = @Nazwa AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0)
						
						IF @IstniejacyTypRelacjiId IS NULL
						BEGIN
							IF EXISTS (SELECT Id FROM dbo.[Relacja_Typ] WHERE Id = @Id)
							BEGIN

								--aktualizacja danych typu relacji
								UPDATE dbo.[Relacja_Typ] SET
								Nazwa = ISNULL(@Nazwa, 'Bez nazwy'),
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
								LastModifiedBy = @UzytkownikId,
								RealLastModifiedOn = @DataModyfikacji,
								--IsAlternativeHistory = @IsAlternativeHistory,
								--IsMainHistFlow = @IsMainHistFlow,
								ValidFrom = @DataModyfikacjiApp,
								ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
								ObowiazujeDo = @DataObowiazywaniaDo
								WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanyTypRelacjiId = @Id;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanyTypRelacjiId);
								END
								ELSE
								BEGIN
									INSERT INTO #BazoweTypyRelacjiKonfliktowe(ID)
									VALUES(@Id);
										
									EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
									SET @Commit = 0;
								END
							END
							ELSE
							BEGIN						
							
								--wstawienie nowego typu relacji ile juz taki nie istnieje (o podanej nazwie i typie bazowym)
								IF NOT EXISTS (SELECT Id FROM dbo.[Relacja_Typ] WHERE Nazwa = @Nazwa AND IdArch IS NULL AND IsValid = 1)
								BEGIN
									INSERT INTO dbo.[Relacja_Typ] (IdArch, Nazwa, CreatedBy, CreatedOn, ValidFrom, IsStatus, 
									StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy,
									RealCreatedOn, ObowiazujeOd, ObowiazujeDo, IsAlternativeHistory, IsMainHistFlow) VALUES 
									(NULL, @Nazwa, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacjiApp,
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
									@DataModyfikacji,
									ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
									@DataObowiazywaniaDo, 0, 1);
									
									IF @@ROWCOUNT > 0
									BEGIN
										SET @PrzetwarzanyTypRelacjiId = @@IDENTITY;
										INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanyTypRelacjiId);
									END
								END

							END
						END
						ELSE
						BEGIN							
							INSERT INTO #BazoweTypyRelacjiNieUnikalne(ID)
							VALUES(@IstniejacyTypRelacjiId);
							
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Bazowy typ relacji' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
						END
						
						FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @LastModifiedOn
						
					END
					CLOSE cur
					DEALLOCATE cur
					
					--	SELECT * FROM #TypyRelacjiKonfliktowe;	
					--	SELECT * FROM #TypyRelacjiNieUnikalne;
					--SELECT * FROM #IDZmienionych
					
					IF (SELECT COUNT(1) FROM #BazoweTypyRelacjiKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT tr.[Id] AS "@Id"
										  ,tr.[Nazwa] AS "@Name"
										  ,tr.[IsDeleted] AS "@IsDeleted"
										  ,tr.[DeletedFrom] AS "@DeletedFrom"
										  ,tr.[DeletedBy] AS "@DeletedBy"
										  ,tr.[CreatedOn] AS "@CreatedOn"
										  ,tr.[CreatedBy] AS "@CreatedBy"
										  ,ISNULL(tr.[LastModifiedOn], ISNULL(tr.[CreatedOn], '')) AS "@LastModifiedOn"
										  ,tr.[LastModifiedBy] AS "@LastModifiedBy"
										  ,tr.[ObowiazujeOd] AS "History/@EffectiveFrom"
										  ,tr.[ObowiazujeDo] AS "History/@EffectiveTo"
										  ,tr.[IsMainHistFlow] AS "History/@IsMainHistFlow"
										  ,tr.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
										  ,tr.[IsStatus] AS "Statuses/@IsStatus"
										  ,tr.[StatusS] AS "Statuses/@StatusS"
										  ,tr.[StatusSFrom] AS "Statuses/@StatusSFrom"
										  ,tr.[StatusSTo] AS "Statuses/@StatusSTo"
										  ,tr.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
										  ,tr.[StatusSToBy] AS "Statuses/@StatusSToBy"
										  ,tr.[StatusW] AS "Statuses/@StatusW"
										  ,tr.[StatusWFrom] AS "Statuses/@StatusWFrom"
										  ,tr.[StatusWTo] AS "Statuses/@StatusWTo"
										  ,tr.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
										  ,tr.[StatusWToBy] AS "Statuses/@StatusWToBy"
										  ,tr.[StatusP] AS "Statuses/@StatusP"
										  ,tr.[StatusPFrom] AS "Statuses/@StatusPFrom"
										  ,tr.[StatusPTo] AS "Statuses/@StatusPTo"
										  ,tr.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
										  ,tr.[StatusPToBy] AS "Statuses/@StatusPToBy"							
							FROM [Relacja_Typ] tr
							WHERE Id IN (SELECT ID FROM #BazoweTypyRelacjiKonfliktowe)
							FOR XML PATH('RelationBaseType')
						) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #BazoweTypyRelacjiNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT tr.[Id] AS "@Id"
										  ,tr.[Nazwa] AS "@Name"
										  ,tr.[IsDeleted] AS "@IsDeleted"
										  ,tr.[DeletedFrom] AS "@DeletedFrom"
										  ,tr.[DeletedBy] AS "@DeletedBy"
										  ,tr.[CreatedOn] AS "@CreatedOn"
										  ,tr.[CreatedBy] AS "@CreatedBy"
										  ,ISNULL(tr.[LastModifiedOn], ISNULL(tr.[CreatedOn], '')) AS "@LastModifiedOn"
										  ,tr.[LastModifiedBy] AS "@LastModifiedBy"
										  ,tr.[ObowiazujeOd] AS "History/@EffectiveFrom"
										  ,tr.[ObowiazujeDo] AS "History/@EffectiveTo"
										  ,tr.[IsMainHistFlow] AS "History/@IsMainHistFlow"
										  ,tr.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
										  ,tr.[IsStatus] AS "Statuses/@IsStatus"
										  ,tr.[StatusS] AS "Statuses/@StatusS"
										  ,tr.[StatusSFrom] AS "Statuses/@StatusSFrom"
										  ,tr.[StatusSTo] AS "Statuses/@StatusSTo"
										  ,tr.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
										  ,tr.[StatusSToBy] AS "Statuses/@StatusSToBy"
										  ,tr.[StatusW] AS "Statuses/@StatusW"
										  ,tr.[StatusWFrom] AS "Statuses/@StatusWFrom"
										  ,tr.[StatusWTo] AS "Statuses/@StatusWTo"
										  ,tr.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
										  ,tr.[StatusWToBy] AS "Statuses/@StatusWToBy"
										  ,tr.[StatusP] AS "Statuses/@StatusP"
										  ,tr.[StatusPFrom] AS "Statuses/@StatusPFrom"
										  ,tr.[StatusPTo] AS "Statuses/@StatusPTo"
										  ,tr.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
										  ,tr.[StatusPToBy] AS "Statuses/@StatusPToBy"								
						FROM [Relacja_Typ] tr
						WHERE Id IN (SELECT ID FROM #BazoweTypyRelacjiNieUnikalne)
						FOR XML PATH('RelationBaseType')
					) AS nvarchar(MAX)), '');
					END	
					
					SET @xmlResponse = (
						SELECT TOP 1 NULL AS '@Ids'
						, (
							SELECT Id AS '@Id'
							,'RelationBaseType' AS '@EntityType'
							FROM #IDZmienionych
							FOR XML PATH('Ref'), ROOT('Value'), TYPE
							)
						FROM #IDZmienionych
						FOR XML PATH('Result')
						)
					
					IF @Commit = 1
						COMMIT TRAN RelationBT_SAVE
					ELSE
						ROLLBACK TRAN RelationBT_SAVE
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'RelationBaseTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'RelationBaseTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN RelationBT_SAVE
		END
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="RelationBaseTypes_Save"'
	
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
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
	
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#BazoweTypyRelacji') IS NOT NULL
		DROP TABLE #BazoweTypyRelacji
		
	IF OBJECT_ID('tempdb..#BazoweTypyRelacjiKonfliktowe') IS NOT NULL
		DROP TABLE #BazoweTypyRelacjiKonfliktowe
	
	IF OBJECT_ID('tempdb..#BazoweTypyRelacjiNieUnikalne') IS NOT NULL
		DROP TABLE #BazoweTypyRelacjiNieUnikalne
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
