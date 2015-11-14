-- =============================================
-- Author:		DK
-- Create date: 2012-03-15
-- Last modified on: 2013-03-04
-- Description:	Zapisuje dane slownikow. Aktualizuje istniejacy lub wstawia nowy rekord.
-- =============================================
CREATE PROCEDURE [THB].[Dictionary_Save]
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
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@StatusPStr varchar(10) = NULL,
		@StatusSStr varchar(10) = NULL,
		@StatusWStr varchar(10) = NULL,
		@Query nvarchar(MAX) = '',
		@xml_data xml,
		@BranzaID int,
		@Id int,
		@Nazwa nvarchar(200),
		@Index int,
		@IsStatus bit,
		@IdElementu int,
		@NazwaElementu nvarchar(200),
		@NazwaSkrocona nvarchar(50),
		@LastModifiedOn datetime,
		@Uwagi nvarchar(MAX),
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@PrzetwarzanySlownikId int,
		@Skip bit = 0,
		@TypId int,
		@MaUprawnienia bit = 0,
		@Commit bit = 1,
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyTmp nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueTmp nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacySlownikId int,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@ZmianaOdStr varchar(30),
		@ZmianaDoStr varchar(30),
		@DataObowiazywaniaOdStr varchar(30),
		@DataObowiazywaniaDoStr varchar(30),
		@ZmianaNazwySlownika bit = 0,
		@ObecnaNazwaSlownika nvarchar(200),
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@IloscSlownikow int,
		@Counter int = 0,
		@EntryIndex int,
		--aktualne dane wpisu slownika
		@OldIsStatus bit,
		@OldStatusS int,
		@OldStatusW int, 
		@OldStatusP int,
		@OldNazwa nvarchar(200),
		@OldNazwaSkrocona nvarchar(50),
		@OldUwagi nvarchar(MAX)

		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Dictionary_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN
		
			BEGIN TRY
		
			SET @xml_data = CAST(@XMLDataIn AS xml);
				
			--usuwanie tabel tymczasowych, jesli istnieja
			IF OBJECT_ID('tempdb..#Slowniki') IS NOT NULL
				DROP TABLE #Slowniki
				
			IF OBJECT_ID('tempdb..#WartosciSlownikow') IS NOT NULL
				DROP TABLE #WartosciSlownikow
				
			IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
				DROP TABLE #IDZmienionych
				
			IF OBJECT_ID('tempdb..#IDZmienionychWpisowSlownika') IS NOT NULL
				DROP TABLE #IDZmienionychWpisowSlownika
				
			IF OBJECT_ID('tempdb..#SlownikiKonfliktowe') IS NOT NULL
				DROP TABLE #SlownikiKonfliktowe
				
			IF OBJECT_ID('tempdb..#SlownikiNieUnikalne') IS NOT NULL
				DROP TABLE #SlownikiNieUnikalne
				
			IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
				DROP TABLE #Statusy
			
			IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
				DROP TABLE #Historia
				
			IF OBJECT_ID('tempdb..#StatusyWpisow') IS NOT NULL
				DROP TABLE #StatusyWpisow
			
			IF OBJECT_ID('tempdb..#HistoriaWpisow') IS NOT NULL
				DROP TABLE #HistoriaWpisow
				
			CREATE TABLE #SlownikiKonfliktowe(ID int);	
			CREATE TABLE #SlownikiNieUnikalne(ID int);				
			CREATE TABLE #IDZmienionych (ID int);
			CREATE TABLE #IDZmienionychWpisowSlownika(ID int, RootID int);
			
			CREATE TABLE #WartosciSlownikow (RootIndex int, EntryIndex int, Id int, Nazwa nvarchar(200), NazwaSkrocona nvarchar(50), Uwagi nvarchar(MAX), LastModifiedOn datetime);
			
			CREATE TABLE #StatusyWpisow (RootIndex int, EntryIndex int, IsStatus bit, StatusP int, StatusPFrom datetime, StatusPTo datetime,
			StatusPFromBy int, StatusPToBy int, StatusS int, StatusSFrom datetime, StatusSTo datetime, StatusSFromBy int, StatusSToBy int,
			StatusW int, StatusWFrom datetime, StatusWTo datetime, StatusWFromBy int, StatusWToBy int);
		
			CREATE TABLE #HistoriaWpisow (RootIndex int, EntryIndex int, ZmianaOd datetime, ZmianaDo datetime, DataObowiazywaniaOd datetime, DataObowiazywaniaDo datetime,
			IsAlternativeHistory bit, IsMainHistFlow bit);

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);
			
			--SELECT @DataProgramu, @UzytkownikID, @RequestType	
					
			IF @RequestType = 'Dictionary_Save'
			BEGIN 
				
				--pobranie ilosci danych slownikow w XMLu
				SELECT @IloscSlownikow = @xml_data.value('count(/Request/Dictionary)', 'int');
		
				--odczytywanie danych slownika
				;WITH Num(j)
				AS
				(
				   SELECT 1
				   UNION ALL
				   SELECT j + 1
				   FROM Num
				   WHERE j < @IloscSlownikow
				)
				SELECT 	j AS 'Index'
					   ,x.value('./@Id', 'int') AS ID
					   ,x.value('./@Name', 'nvarchar(256)') AS Nazwa
					   ,x.value('./@DataTypeId', 'int') AS TypId
					   ,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				INTO #Slowniki
				FROM Num
				CROSS APPLY @xml_data.nodes('/Request/Dictionary[position()=sql:column("j")]')  e(x);	
				
				--odczytyanie danych zmian slownikow
				;WITH Num(j)
				AS
				(
				   SELECT 1
				   UNION ALL
				   SELECT j + 1
				   FROM Num
				   WHERE j < @IloscSlownikow
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
				CROSS APPLY @xml_data.nodes('/Request/Dictionary[position()=sql:column("j")]/History')  e(x);
				
				--odczytywanie statusow slownikow
				;WITH Num(j)
				AS
				(
				   SELECT 1
				   UNION ALL
				   SELECT j + 1
				   FROM Num
				   WHERE j < @IloscSlownikow
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
				CROSS APPLY @xml_data.nodes('/Request/Dictionary[position()=sql:column("j")]/Statuses')  e(x);
				
				
				SET @Counter = 0;
			
				WHILE @Counter <= @IloscSlownikow
				BEGIN
				
					--odczytywanie danych wpisow slownika
					SET @Query = '
					WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Dictionary[position()=' + CAST(@Counter AS varchar) + ']/Entries/DictionaryEntry)'', ''int'') )
					)	
						
					INSERT INTO #WartosciSlownikow (RootIndex, EntryIndex, Id, Nazwa, NazwaSkrocona, Uwagi, LastModifiedOn)
					SELECT ' + CAST(@Counter AS varchar) + '
							, j
							,x.value(''./@Id'',''int'') AS Id
							,x.value(''./@Name'', ''nvarchar(200)'') AS Nazwa
							,x.value(''./@ShortName'', ''nvarchar(50)'') AS NazwaSkrocona
							,x.value(''./@Comment'', ''nvarchar(MAX)'') AS Uwagi
							,x.value(''./@LastModifiedOn'', ''datetime'') AS LastModifiedOn
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/Dictionary[position()=' + CAST(@Counter AS varchar) + ']/Entries/DictionaryEntry[position()=sql:column("j")]'')  e(x);	
					';

				--	PRINT @Query
					EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
					
					--statusy dla wpisow slownika
					SET @Query = '
						;WITH Num(j)
						AS
						(
						   SELECT 1
						   UNION ALL
						   SELECT j + 1
						   FROM Num
						   WHERE j < (SELECT @xml_data.value(''count(/Request/Dictionary[position()=' + CAST(@Counter AS varchar) + ']/Entries/DictionaryEntry)'', ''int'') )
						)	
							
						INSERT INTO #StatusyWpisow (RootIndex, EntryIndex, IsStatus, StatusP, StatusPFrom, StatusPTo, StatusPFromBy, StatusPToBy, StatusS, StatusSFrom, 
							StatusSTo, StatusSFromBy, StatusSToBy, StatusW, StatusWFrom, StatusWTo, StatusWFromBy, StatusWToBy)
						SELECT ' + CAST(@Counter AS varchar) + '
								, j
								,x.value(''./@IsStatus'', ''bit'')
								,x.value(''./@StatusP'', ''int'')  
								,x.value(''./@StatusPFrom'', ''datetime'')  
								,x.value(''./@StatusPTo'', ''datetime'')
								,x.value(''./@StatusPFromBy'', ''int'')
								,x.value(''./@StatusPToBy'', ''int'')
								,x.value(''./@StatusS'', ''int'')
								,x.value(''./@StatusSFrom'', ''datetime'')
								,x.value(''./@StatusSTo'', ''datetime'') 
								,x.value(''./@StatusSFromBy'', ''int'')
								,x.value(''./@StatusSToBy'', ''int'') 
								,x.value(''./@StatusW'', ''int'')
								,x.value(''./@StatusWFrom'', ''datetime'')
								,x.value(''./@StatusWTo'', ''datetime'')
								,x.value(''./@StatusWFromBy'', ''int'') 
								,x.value(''./@StatusWToBy'', ''int'')	
						FROM Num
						CROSS APPLY @xml_data.nodes(''/Request/Dictionary[position()=' + CAST(@Counter AS varchar) + ']/Entries/DictionaryEntry[position()=sql:column("j")]/Statuses'')  e(x);	
						';

				--	PRINT @Query
					EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
					
					--zmiany (historia) dla wpisow slownika
					SET @Query = '
						;WITH Num(j)
						AS
						(
						   SELECT 1
						   UNION ALL
						   SELECT j + 1
						   FROM Num
						   WHERE j < (SELECT @xml_data.value(''count(/Request/Dictionary[position()=' + CAST(@Counter AS varchar) + ']/Entries/DictionaryEntry)'', ''int'') )
						)	
							
						INSERT INTO #HistoriaWpisow (RootIndex, EntryIndex, ZmianaOd, ZmianaDo, DataObowiazywaniaOd, DataObowiazywaniaDo, IsAlternativeHistory, IsMainHistFlow)
						SELECT ' + CAST(@Counter AS varchar) + '
								, j
								,x.value(''./@ChangeFrom'', ''datetime'') 
								,x.value(''./@ChangeTo'', ''datetime'')
								,x.value(''./@EffectiveFrom'', ''datetime'')
								,x.value(''./@EffectiveTo'', ''datetime'')
								,x.value(''./@IsAlternativeHistory'', ''bit'')
								,x.value(''./@IsMainHistFlow'', ''bit'')	
						FROM Num
						CROSS APPLY @xml_data.nodes(''/Request/Dictionary[position()=' + CAST(@Counter AS varchar) + ']/Entries/DictionaryEntry[position()=sql:column("j")]/History'')  e(x);	
						';

				--	PRINT @Query
					EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
					SET @Counter += 1;
				END
				
				--SELECT * FROM #Slowniki;
				--SELECT * FROM #WartosciSlownikow
				--SELECT * FROM #Historia;
				--SELECT * FROM #Statusy;
				--SELECT * FROM #StatusyWpisow;
				--SELECT * FROM #HistoriaWpisow;		
				
				-- pobranie daty usuniecia na podstawie przekazanego AppDate
				SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN				
				
					BEGIN TRAN T1_Dictionary_Save
				
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
					
					DECLARE cur CURSOR LOCAL FOR 
						SELECT [Index], Id, dbo.Trim(Nazwa), TypId, LastModifiedOn FROM #Slowniki
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @TypId, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--wyzerowanie zmiennych
						SET @Skip = 0;
						SET @ZmianaNazwySlownika = 0;
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL;
			
						SET @IstniejacySlownikId = (SELECT Id From dbo.[Slowniki] WHERE Id <> @Id AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0 AND LOWER(Nazwa) = LOWER(@Nazwa));
						
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, 
						@DataObowiazywaniaOd = DataObowiazywaniaOd, @DataObowiazywaniaDo = DataObowiazywaniaDo
						FROM #Historia WHERE RootIndex = @Index;		
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index;			

-- pole obecnie nie uzywane		
SET @DataObowiazywaniaDo = NULL;
						
						--sprawdzenie czy slownik o podanej nazwie juz nie istnieje
						IF @IstniejacySlownikId IS NULL
						BEGIN
							IF EXISTS (SELECT Id FROM dbo.[Slowniki] WHERE Id = @Id)
							BEGIN
								--sprawdzenie czy zmienila sie nazwa slownika
								SET @ObecnaNazwaSlownika = (SELECT Nazwa FROM dbo.[Slowniki] WHERE Id = @Id);
		
								--aktualizacja danych slownika
								UPDATE dbo.[Slowniki] SET
								Nazwa = @Nazwa,
								TypId = @TypId,
								LastModifiedOn = @DataModyfikacjiApp,
								LastModifiedBy = @UzytkownikId,
								ValidFrom = @DataModyfikacjiApp,
								RealLastModifiedOn = @DataModyfikacji,
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
								IsStatus = ISNULL(@IsStatus, 0)
								WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
								
								IF @@ROWCOUNT > 0
								BEGIN  
									SET @PrzetwarzanySlownikId = @Id;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanySlownikId);
									
									IF LOWER(@ObecnaNazwaSlownika) <> LOWER(@Nazwa)
										SET @ZmianaNazwySlownika = 1;
								END
								ELSE
								BEGIN
									--konflikt konkurencyjnosci
									INSERT INTO #SlownikiKonfliktowe(ID)
									VALUES(@Id);
									
									EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
									SET @Commit = 0;
									SET @Skip = 1;
								END
							END
							ELSE
							BEGIN						
								--wstawienie nowego slownika o ile juz taki nie istnieje
								IF NOT EXISTS (SELECT Id FROM dbo.[Slowniki] WHERE Nazwa = @Nazwa AND IdArch IS NULL AND IsValid = 1)
								BEGIN
									INSERT INTO dbo.[Slowniki] (Nazwa, TypId, IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy,
									CreatedBy, CreatedOn, ValidFrom, RealCreatedOn, ObowiazujeOd, ObowiazujeDo) 
									VALUES (
									@Nazwa, 
									@TypId,
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
									@UzytkownikId, 
									@DataModyfikacjiApp, 
									@DataModyfikacjiApp,
									@DataModyfikacji,
									ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
									@DataObowiazywaniaDo);
									
									IF @@ROWCOUNT > 0
									BEGIN
										SET @PrzetwarzanySlownikId = @@IDENTITY;
										INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanySlownikId);
										
										SET @ObecnaNazwaSlownika = @Nazwa;
									END
								END
								ELSE
									SET @Skip = 1;
							END

							--przetwarzanie danych wartosci slownika
							IF @Skip = 0
							BEGIN
				
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local','cur2') > 0 
								BEGIN
									 CLOSE cur2
									 DEALLOCATE cur2
								END									

								DECLARE cur2 CURSOR LOCAL FOR 
									SELECT EntryIndex, Id, dbo.Trim(Nazwa), dbo.Trim(NazwaSkrocona), dbo.Trim(Uwagi), LastModifiedOn FROM #WartosciSlownikow WHERE RootIndex = @Index
								OPEN cur2
								FETCH NEXT FROM cur2 INTO @EntryIndex, @IdElementu, @NazwaElementu, @NazwaSkrocona, @Uwagi, @LastModifiedOn
								WHILE @@FETCH_STATUS = 0
								BEGIN	
								
									--wyzerowanie zmiennych
									SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
									SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL
								
									--SELECT @IdElementu, @NazwaElementu, @NazwaSkrocona, @Uwagi, @LastModifiedOn
									--SELECT @ObecnaNazwaSlownika AS ObecnaNazwa
									
									--pobranie danych zmian (historycznych)
									SELECT	@ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, 
									@DataObowiazywaniaOd = DataObowiazywaniaOd, @DataObowiazywaniaDo = DataObowiazywaniaDo
									FROM #HistoriaWpisow WHERE RootIndex = @Index AND EntryIndex = @EntryIndex;;		

-- pole obecnie nie uzywane		
SET @DataObowiazywaniaDo = NULL;
SET @DataObowiazywaniaOd = @DataModyfikacjiApp;
					
									--pobranie danych statusow
									SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
									FROM #StatusyWpisow WHERE RootIndex = @Index AND EntryIndex = @EntryIndex;	
									
									--przetworzenie dat na stringi
									IF @ZmianaOd IS NOT NULL
										SET @ZmianaOdStr = '''' + CONVERT(nvarchar(50), @ZmianaOd, 109) + '''';
									ELSE
										SET @ZmianaOdStr = 'NULL';
										
									IF @ZmianaDo IS NOT NULL
										SET @ZmianaDoStr = '''' + CONVERT(nvarchar(50), @ZmianaDo, 109) + '''';
									ELSE
										SET @ZmianaDoStr = 'NULL';
										
									IF @DataObowiazywaniaOd IS NOT NULL
										SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataObowiazywaniaOd, 109) + '''';
									ELSE
										SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + '''';
										
									IF @DataObowiazywaniaDo IS NOT NULL
										SET @DataObowiazywaniaDoStr = '''' + CONVERT(nvarchar(50), @DataObowiazywaniaDo, 109) + '''';
									ELSE
										SET @DataObowiazywaniaDoStr = 'NULL';
								
									IF @StatusS IS NOT NULL
										SET @StatusSStr = CAST(@StatusS AS varchar);
									ELSE
										SET @StatusSStr = 'NULL';
										
									IF @StatusW IS NOT NULL
										SET @StatusWStr = CAST(@StatusW AS varchar);
									ELSE
										SET @StatusWStr = 'NULL';
										
									IF @StatusP IS NOT NULL
										SET @StatusPStr = CAST(@StatusP AS varchar);
									ELSE
										SET @StatusPStr = 'NULL';									
	
	
	
			--											--sprawdzenie czy zmienily sie dane obiektu
			--										IF (@OldIsStatus = ' + CAST(ISNULL(@IsStatus, 0) AS varchar) + ' AND CAST(ISNULL(@OldStatusS, 0) AS varchar) = CAST(ISNULL(' + @StatusSStr + ', 0) AS varchar) AND CAST(ISNULL(@OldStatusW, 0) AS varchar) = CAST(ISNULL(' + @StatusWStr + ', 0) AS varchar)
			--											AND CAST(ISNULL(@OldStatusP, 0) AS varchar) = CAST(ISNULL(' + @StatusPStr + ', 0) AS varchar) AND @OldNazwa = ''' + @NazwaElementu + ''' AND ISNULL(@OldNazwaSkrocona, '''') = ISNULL(''' + @NazwaSkrocona + ''', '''') AND ISNULL(@OldUwagi, '''') == ISNULL(''' + @Uwagi + ''', '''')) 
			--										BEGIN
												
			--PRINT ''Brak zmiany danych slownika'';				
			--											--zmieniamy tylko daty ostatnich modyfikacji przy wylaczonych triggerach
			--											DISABLE TRIGGER [WartoscZmiany_Slownik_' + @ObecnaNazwaSlownika + '_UPDATE] ON dbo.[_Slownik_' + @ObecnaNazwaSlownika + '];
														
			--											UPDATE dbo.[_Slownik_' + @ObecnaNazwaSlownika + '] SET
			--											LastModifiedOn = ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''',
			--											RealLastModifiedOn = ''' + CONVERT(nvarchar(50), @DataModyfikacji, 109) + '''
			--											WHERE Id = ' + CAST(@IdElementu AS varchar) + ';
														
			--											ENABLE TRIGGER [WartoscZmiany_Slownik_' + @ObecnaNazwaSlownika + '_UPDATE] ON dbo.[_Slownik_' + @ObecnaNazwaSlownika + '];
												
			--										END
			--										ELSE
	
													
									SET @Query = '
									 IF OBJECT_ID(''_Slownik_' + @ObecnaNazwaSlownika + ''', N''U'') IS NOT NULL
									 BEGIN
										IF NOT EXISTS (SELECT Id FROM [_Slownik_' + @ObecnaNazwaSlownika + '] WHERE IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0 AND Id <> ' + CAST(@IdElementu AS varchar) + ' AND Nazwa = ''' + @NazwaElementu + ''' AND NazwaSkrocona = ''' + @NazwaSkrocona + ''' AND TypId = ' + CAST(@TypId AS varchar) + ')
										BEGIN
											IF EXISTS (SELECT Id FROM [_Slownik_' + @ObecnaNazwaSlownika + '] WHERE Id = ' + CAST(@IdElementu AS varchar) + ')
											BEGIN
												
												--sprawdzamy czy zmienila sie jakas wartosc wpisu slownika
												SELECT @OldIsStatus = ISNULL(IsStatus, 0), @OldStatusS = StatusS, @OldStatusW = StatusW, @OldStatusP = StatusP, @OldNazwa = Nazwa, @OldNazwaSkrocona = NazwaSkrocona, @OldUwagi = Uwagi
												FROM dbo.[_Slownik_' + @ObecnaNazwaSlownika + '] WHERE Id = ' + CAST(@IdElementu AS varchar) + ';
												
													IF (@OldIsStatus = ' + CAST(ISNULL(@IsStatus, 0) AS varchar) + ' AND CAST(ISNULL(@OldStatusS, 0) AS varchar) = CAST(ISNULL(' + @StatusSStr + ', 0) AS varchar) AND CAST(ISNULL(@OldStatusW, 0) AS varchar) = CAST(ISNULL(' + @StatusWStr + ', 0) AS varchar)
														AND CAST(ISNULL(@OldStatusP, 0) AS varchar) = CAST(ISNULL(' + @StatusPStr + ', 0) AS varchar) AND @OldNazwa = ''' + @NazwaElementu + ''' AND ISNULL(@OldNazwaSkrocona, '''') = ISNULL(''' + @NazwaSkrocona + ''', '''') AND ISNULL(@OldUwagi, '''') = ISNULL(''' + @Uwagi + ''', '''')) 
													BEGIN												
			--PRINT ''Brak zmiany danych slownika'';				
														--zmieniamy tylko daty ostatnich modyfikacji przy wylaczonych triggerach
														DISABLE TRIGGER [WartoscZmiany_Slownik_' + @ObecnaNazwaSlownika + '_UPDATE] ON dbo.[_Slownik_' + @ObecnaNazwaSlownika + '];
														
														UPDATE dbo.[_Slownik_' + @ObecnaNazwaSlownika + '] SET
														LastModifiedOn = ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''',
														RealLastModifiedOn = ''' + CONVERT(nvarchar(50), @DataModyfikacji, 109) + '''
														WHERE Id = ' + CAST(@IdElementu AS varchar) + ';
														
														INSERT INTO #IDZmienionychWpisowSlownika (Id, RootId) VALUES(' + CAST(@IdElementu AS varchar) + ',' + CAST(@PrzetwarzanySlownikId AS varchar) + ');
														
														ENABLE TRIGGER [WartoscZmiany_Slownik_' + @ObecnaNazwaSlownika + '_UPDATE] ON dbo.[_Slownik_' + @ObecnaNazwaSlownika + '];
												
													END
													ELSE'
												
									SET @Query += '			
													BEGIN
													
														UPDATE [_Slownik_' + @ObecnaNazwaSlownika + '] SET
														Nazwa = ''' + @NazwaElementu + ''',
														TypId = ' + CAST(@TypId AS varchar) + ',
														NazwaSkrocona = ' + ISNULL('''' + @NazwaSkrocona + '''', 'NULL') + ',
														Uwagi = ' + ISNULL('''' + @Uwagi + '''', 'NULL') + ',
														LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + ',
														LastModifiedOn = ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''',
														ValidFrom = ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''',
														RealLastModifiedOn = ''' + CONVERT(nvarchar(50), @DataModyfikacji, 109) + ''',						
														ObowiazujeOd = ' + @DataObowiazywaniaOdStr + ',
														ObowiazujeDo = ' + @DataObowiazywaniaDoStr + ',
														StatusP = ' + @StatusPStr + ',
														StatusPFromBy = CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END,	
														StatusPFrom = CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END, 
														StatusS = ' + @StatusSStr + ',
														StatusSFromBy = CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END,	
														StatusSFrom = CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END, 
														StatusW = ' + @StatusWStr + ',
														StatusWFrom = CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END, 
														StatusWFromBy = CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END,
														IsStatus = ' + CAST(ISNULL(@IsStatus, 0) AS varchar) + '
														WHERE Id = ' + CAST(@IdElementu AS varchar) + ' AND (LastModifiedOn = ''' + CONVERT(nvarchar(50), @LastModifiedOn, 109) + ''' OR (LastModifiedOn IS NULL AND CreatedOn = ''' + CONVERT(nvarchar(50), @LastModifiedOn, 109) + ''' ))
														
														IF @@ROWCOUNT > 0
														BEGIN
															INSERT INTO #IDZmienionychWpisowSlownika (Id, RootId) VALUES(' + CAST(@IdElementu AS varchar) + ',' + CAST(@PrzetwarzanySlownikId AS varchar) + ')
														END
														ELSE
														BEGIN
															INSERT INTO #SlownikiKonfliktowe(ID)
															VALUES(' + CAST(@Id AS varchar) + ');
															
															EXEC [THB].[GetErrorMessage] @Nazwa = N''CONCURRENCY_ERROR'', @Grupa = N''PROC_RESULT'', @Wiadomosc = @ERRMSGTmp OUTPUT
															SET @CommitTmp = 0;
														END
													END
											END'
					
									SET @Query += '	
											ELSE
											BEGIN
												INSERT INTO [_Slownik_' + @ObecnaNazwaSlownika + '] 
												(Nazwa, NazwaSkrocona, Uwagi, ObowiazujeOd, ObowiazujeDo, CreatedOn, CreatedBy, TypId, ValidFrom, RealCreatedOn,
												IsStatus, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy, StatusP, StatusPFrom, StatusPFromBy, IsAlternativeHistory, IsMainHistFlow)
												VALUES (''' + @NazwaElementu + ''', ' + ISNULL('''' + @NazwaSkrocona + '''', 'NULL') + ', ' + ISNULL('''' + @Uwagi + '''', 'NULL') + 
												', ' + @DataObowiazywaniaOdStr + ', ' + @DataObowiazywaniaDoStr +
												', ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''', ' + CAST(@UzytkownikId AS varchar) + ', ' + CAST(@TypId AS varchar) + 
												', ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''', ' +
												' ''' + CONVERT(nvarchar(50), @DataModyfikacji, 109) + ''', ' + CAST(ISNULL(@IsStatus, 0) AS varchar) + ', ' +
													@StatusSStr + ', CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END,
													CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END, ' + @StatusWStr + ', 
													CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END,
													CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END, ' + @StatusPStr + ',
													CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END,
													CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END, 0, 1);
												
												IF @@ROWCOUNT > 0
												BEGIN
													INSERT INTO #IDZmienionychWpisowSlownika (Id, RootId) VALUES (@@IDENTITY,' + CAST(@PrzetwarzanySlownikId AS varchar) + ')
												END										
											END
										END
										ELSE
										BEGIN
											INSERT INTO #SlownikiNieUnikalne(ID)
											VALUES(' + CAST(@PrzetwarzanySlownikId AS varchar) + ');
											
											EXEC [THB].[GetErrorMessage] @Nazwa = N''RECORD_EXISTS'', @Grupa = N''PROC_RESULT'', @Val1 = ''Wartość słownika'' , @Wiadomosc = @ERRMSGTmp OUTPUT
											SET @CommitTmp = 0;
										END
									END
									'
										
									--PRINT @Query
									EXECUTE sp_executesql @Query, 
										N'@OldIsStatus bit, @OldStatusS int, @OldStatusW int, @OldStatusP int, @OldNazwa nvarchar(200), @OldNazwaSkrocona nvarchar(50),
											@OldUwagi nvarchar(MAX), @CommitTmp bit OUTPUT, @ERRMSGTmp nvarchar(500) OUTPUT', 
										@OldIsStatus = @OldIsStatus, @OldStatusS = @OldStatusS, @OldStatusW = @OldStatusW, @OldStatusP = @OldStatusP, @OldNazwa = @OldNazwa, @OldNazwaSkrocona = @OldNazwaSkrocona,
										@OldUwagi = @OldUwagi, @CommitTmp = @Commit OUTPUT, @ERRMSGTmp = @ERRMSG OUTPUT
	 
									FETCH NEXT FROM cur2 INTO @EntryIndex, @IdElementu, @NazwaElementu, @NazwaSkrocona, @Uwagi, @LastModifiedOn
								END
								CLOSE cur2
								DEALLOCATE cur2
							END
						END
						ELSE
						BEGIN
							-- uzytkownik o podanych danych juz istnieje, dodanie jego ID do tabeli tymczasowej
							INSERT INTO #SlownikiNieUnikalne(ID)
							VALUES(@IstniejacySlownikId);
							
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Słownik' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
						END
						
						--zmiana nazwy tabel i triggetow jesli zieniono nazwe slownika
						IF @ZmianaNazwySlownika = 1
						BEGIN
							--zmiana nazwy tabeli
							DECLARE @OldN nvarchar(64) = '_Slownik_' + @ObecnaNazwaSlownika
							DECLARE @NewN nvarchar(64) = '_Slownik_' + @Nazwa
							
							IF @OldN <> @NewN
								EXEC sp_rename @OldN, @NewN
								
							--TODO co ze zmiana trigerow w tabelach w ktorych zmieniano nazwe?
							EXEC [THB].[UpdateTriggersForDictionary] @OldName = @ObecnaNazwaSlownika, @NewName = @Nazwa;
						END
					
						FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @TypId, @LastModifiedOn						
					END
					CLOSE cur
					DEALLOCATE cur
					
					--SELECT * FROM #IDZmienionych
					--SELECT * FROM #IDZmienionychWpisowSlownika
					
					IF (SELECT COUNT(1) FROM #SlownikiKonfliktowe) > 0
					BEGIN
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','cur3') > 0 
						BEGIN
							 CLOSE cur3
							 DEALLOCATE cur3
						END

						DECLARE cur3 CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #SlownikiKonfliktowe
						OPEN cur3
						FETCH NEXT FROM cur3 INTO @Id
						WHILE @@FETCH_STATUS = 0
						BEGIN						
							SET @ObecnaNazwaSlownika = (SELECT Nazwa FROM dbo.Slowniki WHERE Id = @Id);
						
							IF @ObecnaNazwaSlownika IS NOT NULL
							BEGIN
								SET @Query = '
								SET @xmlErrorConcurrencyTmp = ISNULL(CAST((SELECT s.[Id] AS "@Id"
											,s.[Nazwa] AS "@Name"
											,s.[TypId] AS "@TypeId"
											,s.[IsDeleted] AS "@IsDeleted"
											,s.[DeletedFrom] AS "@DeletedFrom"
											,s.[DeletedBy] AS "@DeletedBy"
											,s.[CreatedOn] AS "@CreatedOn"
											,s.[CreatedBy] AS "@CreatedBy"
											,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
										    ,s.[LastModifiedBy] AS "@LastModifiedBy"
										    --, (SELECT TOP 1 sr.[TypId] AS "@TypeId"
														, (SELECT sr.[Id] AS "@Id"
															,sr.[Nazwa] AS "@Name"
															,sr.[NazwaSkrocona] AS "@ShortName"
															,sr.[NazwaPelna] AS "@FullName"
															,sr.[Uwagi] AS "@Comment"
															,ISNULL(sr.[LastModifiedOn], sr.[CreatedOn]) AS "@LastModifiedOn"
															FROM [_Slownik_' + @ObecnaNazwaSlownika + '] sr
															WHERE sr.IdArch IS NULL AND sr.IsValid = 1 AND sr.IsDeleted = 0
															FOR XML PATH(''DictionaryEntry''), ROOT(''Entries''), TYPE
															)
														--FROM [_Slownik_' + @ObecnaNazwaSlownika + '] sr
														--FOR XML PATH(''Entries''), TYPE
													--)							
								FROM [Slowniki] s
								WHERE Id = ' + CAST(@Id AS varchar) + '
								FOR XML PATH(''Dictionary'')
								) AS nvarchar(MAX)), '''')'
							
								PRINT @query;
								EXECUTE sp_executesql @query, N'@xmlErrorConcurrencyTmp nvarchar(MAX) OUTPUT', @xmlErrorConcurrencyTmp = @xmlErrorConcurrencyTmp OUTPUT
							END
							
							SET @xmlErrorConcurrency += @xmlErrorConcurrencyTmp;
							FETCH NEXT FROM cur3 INTO @Id
						END
						CLOSE cur3;
						DEALLOCATE cur3;
					END
					
					IF (SELECT COUNT(1) FROM #SlownikiNieUnikalne) > 0
					BEGIN
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','cur3') > 0 
						BEGIN
							 CLOSE cur3
							 DEALLOCATE cur3
						END

						DECLARE cur3 CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #SlownikiNieUnikalne
						OPEN cur3
						FETCH NEXT FROM cur3 INTO @Id
						WHILE @@FETCH_STATUS = 0
						BEGIN						
							SET @ObecnaNazwaSlownika = (SELECT Nazwa FROM dbo.Slowniki WHERE Id = @Id);
						
							IF @ObecnaNazwaSlownika IS NOT NULL
							BEGIN
						
								SET @Query = '
								SET @xmlErrorsUniqueTmp = ISNULL(CAST((SELECT s.[Id] AS "@Id"
												,s.[Nazwa] AS "@Name"
												,s.[TypId] AS "@TypeId"
												,s.[IsDeleted] AS "@IsDeleted"
												,s.[DeletedFrom] AS "@DeletedFrom"
												,s.[DeletedBy] AS "@DeletedBy"
												,s.[CreatedOn] AS "@CreatedOn"
												,s.[CreatedBy] AS "@CreatedBy"
												,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
												,s.[LastModifiedBy] AS "@LastModifiedBy"									    
												--, (SELECT TOP 1 sr.[TypId] AS "@TypeId"
															, (SELECT sr.[Id] AS "@Id"
																,sr.[Nazwa] AS "@Name"
																,sr.[NazwaSkrocona] AS "@ShortName"
																,sr.[NazwaPelna] AS "@FullName"
																,sr.[Uwagi] AS "@Comment"
																,ISNULL(sr.[LastModifiedOn], sr.[CreatedOn]) AS "@LastModifiedOn"
																FROM [_Slownik_' + @ObecnaNazwaSlownika + '] sr
																WHERE sr.IdArch IS NULL AND sr.IsValid = 1 AND sr.IsDeleted = 0
																FOR XML PATH(''DictionaryEntry''), TYPE
																)
															--FROM [_Slownik_' + @ObecnaNazwaSlownika + '] sr
															--FOR XML PATH(''Entries''), TYPE
														--)									    							
												FROM [Slowniki] s
												WHERE Id = ' + CAST(@Id AS varchar) + '
												FOR XML PATH(''Dictionary'')
											) AS nvarchar(MAX)), '''')'
						
								--PRINT @query		
								EXECUTE sp_executesql @query, N'@xmlErrorsUniqueTmp nvarchar(MAX) OUTPUT', @xmlErrorsUniqueTmp = @xmlErrorsUniqueTmp OUTPUT
								SET @xmlErrorsUnique += @xmlErrorsUniqueTmp;
							END
							
							FETCH NEXT FROM cur3 INTO @Id
						END
						CLOSE cur3;
						DEALLOCATE cur3;
					END				
					
					SET @xmlResponse = (SELECT TOP 1
						(SELECT ID AS '@Id',
							'Dictionary' AS '@EntityType'
							,(
								SELECT ID AS '@Id',
								'DictionaryEntry' AS '@EntityType'
								FROM #IDZmienionychWpisowSlownika slWp
								WHERE sl.ID = slWp.RootId
								FOR XML PATH('Ref'), TYPE
							)
							FROM #IDZmienionych sl
							FOR XML PATH('Ref'), ROOT('Value'), TYPE
							)
						FROM #IDZmienionych
						FOR XML PATH('Result'));
	
					IF @Commit = 1
						COMMIT TRAN T1_Dictionary_Save
					ELSE
						ROLLBACK TRAN T1_Dictionary_Save
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Dictionary_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Dictionary_Save', @Wiadomosc = @ERRMSG OUTPUT
		
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN T1_Dictionary_Save
			END
		END CATCH	
	END			

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Dictionary_Save"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';

	SET @XMLDataOut += '>';

	IF @ERRMSG IS NULL OR @ERRMSG = ''		
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
	IF OBJECT_ID('tempdb..#Slowniki') IS NOT NULL
		DROP TABLE #Slowniki
		
	IF OBJECT_ID('tempdb..#WartosciSlownikow') IS NOT NULL
		DROP TABLE #WartosciSlownikow
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#IDZmienionychWpisowSlownika') IS NOT NULL
		DROP TABLE #IDZmienionychWpisowSlownika
		
	IF OBJECT_ID('tempdb..#SlownikiKonfliktowe') IS NOT NULL
		DROP TABLE #SlownikiKonfliktowe
		
	IF OBJECT_ID('tempdb..#SlownikiNieUnikalne') IS NOT NULL
		DROP TABLE #SlownikiNieUnikalne
		
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
	
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
		
	IF OBJECT_ID('tempdb..#StatusyWpisow') IS NOT NULL
		DROP TABLE #StatusyWpisow
	
	IF OBJECT_ID('tempdb..#HistoriaWpisow') IS NOT NULL
		DROP TABLE #HistoriaWpisow
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
