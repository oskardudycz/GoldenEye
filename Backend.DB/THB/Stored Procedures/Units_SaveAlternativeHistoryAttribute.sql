-- =============================================
-- Author:		DK
-- Create date: 2012-10-16
-- Last modified on: 2013-02-12
-- Description:	Zapisuje dane obiektow. Aktualizuje istniejacy lub wstawia nowy rekord.

-- Przykladowy plik XML wejsciowy:
	--<?xml version="1.0"?>
	--<Request UserId="1" AppDate="2012-09-09T11:23:22" RequestType="Units_SaveAlternativeHistoryAttribute" UnitId="1" UnitTypeId="20">
	--	<Attribute Id="0" TypeId="12" Priority="1" UIOrder="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" 
	--		EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="2" 
	--		StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="2" StatusPFrom="2012-02-09T12:12:12.121Z" 
	--		StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<ValInt Value="45"/>
	--	</Attribute>
	--</Request>
	
-- Przykłądowy plik XML wyjściowy:
	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Units_SaveAlternativeHistoryAttribute" AppDate="2012-02-09">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="Attribute" />
	--		</Value>
	--	</Result>
	--</Response>
-- =============================================
CREATE PROCEDURE [THB].[Units_SaveAlternativeHistoryAttribute]
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
		@HistoryType int,
		@xmlOk bit,
		@Query nvarchar(MAX) = '',
		@xml_data xml,
		@BranzaID int,
		@IsAlternativeHistory bit,
		@IsMainHistFlow bit,
		@LastModifiedOn datetime,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@MaUprawnienia bit = 0,
		@TypObiektuId int,
		@ObiektId int,
		@CechaId int,
		@CechaTypId int,
		@IdCechyObiektu int,
		@CechaWartosc nvarchar(200),
		@NazwaTypuObiektu nvarchar(MAX),
		@UIOrder smallint,
		@Priority smallint,
		@CechaWartoscXML xml,
		@TypWartosciCechy varchar(20),
		@WartoscCechy nvarchar(500),
		@IdSlownika int,
		@IdElementuSlownika int,
		@WartoscCechyQuery nvarchar(200),			
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@ZmianaOdStr varchar(30),
		@ZmianaDoStr varchar(30),
		@DataObowiazywaniaOdStr varchar(30),
		@DataObowiazywaniaDoStr varchar(30),
		@IsStatus bit,
		@StatusS int,
		@StatusP int,
		@StatusW int,
		@StatusSStr varchar(7),
		@StatusPStr varchar(7),
		@StatusWStr varchar(7),
		@CechaObowiazujeOd datetime,
		@CechaObowiazujeDo datetime,
		@CechaObiektuWartoscId int,
		@MaxDate date = '9999-12-31 23:59:59',
		@IdGlownegoRekorduZCecha int,
		@CzyJestHistoriaAlternatywnaJuzWBazie bit,
		@WstawicNowyPrzedzial bit,
		@IstniejacyObiektId int,
		@CechaAlternatywnaIstniejeId int,		
		@PrzedzialObowiazujeOdMinDate datetime,
		@PrzedzialObowiazujeDoMaxDate datetime,
		@PrzedzialObowiazujeTmp datetime,
		@PrzedzialCzasowyId int,
		@WartoscCechyQueryTmp nvarchar(300),
		@NowyPrzedzialDataOd datetime,
		@NowyPrzedzialWartoscXml xml,
		@NowyPrzedzialWartoscString nvarchar(MAX),
		@IsMainHistFlowTmp bit,
		@DateFromColumnName nvarchar(100)

	BEGIN TRY
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Units_SaveAlternativeHistoryAttribute', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
				
			--usuwanie tabel tymczasowych, jesli istnieja								
			IF OBJECT_ID('tempdb..#CechyZmienione') IS NOT NULL
				DROP TABLE #CechyZmienione
			
			IF OBJECT_ID('tempdb..#PrzedzialyWpisow') IS NOT NULL
				DROP TABLE #PrzedzialyWpisow
				
			IF OBJECT_ID('tempdb..#CechyDoZastapienia') IS NOT NULL
				DROP TABLE #CechyDoZastapienia
				
			CREATE TABLE #CechyZmienione (Id int);
			CREATE TABLE #PrzedzialyWpisow (Id int, CechaId int, ObowiazujeOd datetime, ObowiazujeDo datetime, ValidFrom datetime, ValidTo datetime, IsValid bit, LastModifiedOn datetime, ColumnsSet xml, ValString nvarchar(MAX));			
			CREATE TABLE #CechyDoZastapienia(Id int, LastModifiedOn datetime);

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
					,@TypObiektuId = C.value('./@UnitTypeId', 'int')
					,@ObiektId = C.value('./@UnitId', 'int')
					,@HistoryType = C.value('./@HistoryType', 'int')
			FROM @xml_data.nodes('/Request') T(C);
		
			--wyciagniecie danych statusow, historii i podstawowych cechy
			SELECT @IdCechyObiektu = x.value('./@Id','int')
					,@CechaId = x.value('./@TypeId', 'int')
					,@Priority = x.value('./@Priority', 'smallint')
					,@UIOrder = x.value('./@UIOrder', 'smallint')
					,@LastModifiedOn = x.value('./@LastModifiedOn', 'datetime')
			FROM @xml_data.nodes('/Request/Attribute') E(x);
			
			--pobranie typu cechy
			SELECT @CechaTypId = TypId
			FROM dbo.Cechy
			WHERE Cecha_Id = @CechaId;
			
			--pobranie nazwy kolumny po ktorej filtrowane sa daty
			SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();
			
			--pobranie wartosci cechy w postaci XML
			SELECT @CechaWartoscXML = x.query('.')
			FROM @xml_data.nodes('/Request/Attribute/*[not(self::History) and not(self::Statuses)]') e(x);
			
			
			-- o ile wybrano typ zapisu 2 lub 3 to odczytanie ewentualnych danych cech ktore maja zostac zastapione - jesli nie podano zadnych - zapis bedzie dzialaj jak opcja nr 1
			IF @HistoryType = 2 OR @HistoryType = 3
			BEGIN
			
				INSERT INTO #CechyDoZastapienia (Id, LastModifiedOn)
				SELECT x.value('./@Id','int')
					, x.value('./@LastModifiedOn', 'datetime')
				FROM @xml_data.nodes('/Request/AttributesToReplace/Attribute') E(x);
			
			END
				
			--pobranie statusow dla nowej cechy
			SELECT @IsStatus = x.value('./@IsStatus', 'bit')
				,@StatusP = x.value('./@StatusP', 'int')  
					--		,x.value(''./@StatusPFrom'', ''datetime'')  
					--		,x.value(''./@StatusPTo'', ''datetime'')
					--		,x.value(''./@StatusPFromBy'', ''int'')
					--		,x.value(''./@StatusPToBy'', ''int'')
				,@StatusS = x.value('./@StatusS', 'int')
					--		,x.value(''./@StatusSFrom'', ''datetime'')
					--		,x.value(''./@StatusSTo'', ''datetime'') 
					--		,x.value(''./@StatusSFromBy'', ''int'')
					--		,x.value(''./@StatusSToBy'', ''int'') 
				,@StatusW = x.value('./@StatusW', 'int')
					--		,x.value(''./@StatusWFrom'', ''datetime'')
					--		,x.value(''./@StatusWTo'', ''datetime'')
					--		,x.value(''./@StatusWFromBy'', ''int'') 
					--		,x.value(''./@StatusWToBy'', ''int'')	
			FROM @xml_data.nodes('/Request/Attribute/Statuses')  e(x);
				
			--pobranie historii dla nowej cechy
			SELECT @ZmianaOd = x.value('./@ChangeFrom', 'datetime') 
					,@ZmianaDo = x.value('./@ChangeTo', 'datetime')
					,@DataObowiazywaniaOd = x.value('./@EffectiveFrom', 'datetime')
					,@DataObowiazywaniaDo = x.value('./@EffectiveTo', 'datetime')
					,@IsAlternativeHistory = x.value('./@IsAlternativeHistory', 'bit')
					,@IsMainHistFlow = x.value('./@IsMainHistFlow', 'bit')
			FROM @xml_data.nodes('/Request/Attribute/History')  e(x);

--SELECT @DataProgramu, @UzytkownikID, @RequestType
--SELECT @TypObiektuId AS TypObiektu, @ObiektId AS ObiektId
--SELECT @CechaWartoscXML AS WartoscXML, @CechaObiektuId AS Id, @CechaId AS CechaId, @CechaTypId AS TypCechy, @Priority AS Priority, @UIOrder AS UIOrder,@LastModifiedOn AS LastModifiedOn					
--SELECT @IsStatus AS IsStatus, @StatusS AS StatusS, @StatusW AS StatusW, @StatusP AS StatusP
--SELECT @ZmianaOd AS ZmOd, @ZmianaDo	AS ZmDo, @DataObowiazywaniaOd AS ObowOd, @DataObowiazywaniaDo AS ObowDo, @IsAlternativeHistory AS IsAlternative, @IsMainHistFlow AS IsMain						
--SELECT * FROM #CechyDoZastapienia

			IF @RequestType = 'Units_SaveAlternativeHistoryAttribute'
			BEGIN 
			
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT					
					
				--jesli ma uprawnienia do zapisu to sprawdzenie czy nalezy do roli ZmianyHistorii	
				IF @MaUprawnienia = 1
				BEGIN
				
					EXEC [THB].[CheckUserInRole]
						@UserId = @UzytkownikID,
						@RoleRank = 3, --rola dla zmian histori ma niezmienny Rank = 3
						@AppDate = NULL,
						@CheckDate = 0,
						@UserInRole = @MaUprawnienia OUTPUT
				END
		
				IF @MaUprawnienia = 1
				BEGIN
			
					--pobranie nazwy typu obiektu
					SELECT @NazwaTypuObiektu = Nazwa FROM dbo.[TypObiektu] WHERE TypObiekt_ID = @TypObiektuId AND IsDeleted = 0;
					
					--jesli typ obiektu o podanej nazwie nie istnieje to ustawienie tresci bledu
					IF @NazwaTypuObiektu IS NULL
					BEGIN
						SET @ERRMSG = 'Błąd. Typ obiektu o podanym Id (' + CAST(@TypObiektuId AS varchar) + ') nie istnieje.';
						RAISERROR (@ERRMSG, 16, 1, 1) --WITH SETERROR;
					END

					--istnieje typ obiektu o podanym id, wiec sprawdzenie czy obiekt o podanym id istnieje
					SET @Query = 'SELECT @IstniejacyObiektId = Id
									FROM [_' + @NazwaTypuObiektu + ']
									WHERE IsDeleted = 0 AND Id = ' + CAST(@ObiektId AS varchar)
					
					--PRINT @Query;			
					EXECUTE sp_executesql @Query, N'@IstniejacyObiektId int OUTPUT', @IstniejacyObiektId = @IstniejacyObiektId OUTPUT
					
					IF @IstniejacyObiektId IS NULL
					BEGIN
						SET @ERRMSG = 'Błąd. Obiekt o podanym Id (' + CAST(@ObiektId AS varchar) + ') nie istnieje w typie obiektu ' + @NazwaTypuObiektu + '.';
						RAISERROR (@ERRMSG, 16, 1, 2) --WITH SETERROR;
					END
						
					--ustalenie wartosci granicznych dla przedzialow wg podanych dat obowiazywania
					--pobranie przedzialu czasowego z danych cechy oraz jej charakteru chwilowego
					SELECT @PrzedzialCzasowyId = PrzedzialCzasowyId
					FROM Cechy
					WHERE Cecha_ID = @CechaId;
					
					IF @PrzedzialCzasowyId IS NULL
					BEGIN
						SET @ERRMSG = 'Błąd. Nie istnieje cecha o podanym Id: ' + CAST(@CechaId AS varchar) + '.';
						RAISERROR (@ERRMSG, 16, 1, 3);
					END
												
					--ustalenie min i max dat obowiazywania cech na podstawie przedzialow (jednostek) czasowych		
					IF @DataObowiazywaniaOd IS NOT NULL
					BEGIN
						--pobranie przedzialu czasowego dla przedzialu czasowego modyfikowanego typu cechy i daty poczatku jej obowiazywania
						EXEC [THB].[PrepareTimePeriods]
							@AppDate = @DataObowiazywaniaOd,
							@TimeIntervalId = @PrzedzialCzasowyId,
							@MinDate = @PrzedzialObowiazujeOdMinDate OUTPUT,
							@MaxDate = @PrzedzialObowiazujeTmp OUTPUT
							
						SET @DataObowiazywaniaOd = @PrzedzialObowiazujeOdMinDate;
					END
								
					IF @DataObowiazywaniaDo IS NOT NULL
					BEGIN
						--pobranie przedzialu czasowego dla przedzialu czasowego modyfikowanego typu cechy i daty konca jej obowiazywania
						EXEC [THB].[PrepareTimePeriods]
							@AppDate = @DataObowiazywaniaDo,
							@TimeIntervalId = @PrzedzialCzasowyId,
							@MinDate = @PrzedzialObowiazujeTmp OUTPUT,
							@MaxDate = @PrzedzialObowiazujeDoMaxDate OUTPUT
							
						SET @DataObowiazywaniaDo = @PrzedzialObowiazujeDoMaxDate;
					END
													
								
					--jesli wybrano opcje 1 lub 2 to ustawienie daty Do na odpowiednia wartosc
					IF @HistoryType = 1
					BEGIN
						SET @DataObowiazywaniaDo = NULL;
					END
					ELSE IF @HistoryType = 2 
					BEGIN
						SET @DataObowiazywaniaDo = @MaxDate;
					END									
					
					--ustalenie danych zmian i obowiazywania dla dynamicznego zapytania SQL
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
									
					--pobranie w zaleznosci od trybu zapisu przedzialow (wpisow) jakie beda zastapione)
					IF @HistoryType = 2
					BEGIN

						--wyznaczenie wpisow z przyszlosci bedacych teraz historia glowna
						SET @Query = '
							INSERT INTO #PrzedzialyWpisow (Id, CechaId, ObowiazujeOd, ObowiazujeDo, ValidFrom, ValidTo, IsValid, LastModifiedOn, ColumnsSet, ValString)
							SELECT Id, CechaId, ObowiazujeOd, ObowiazujeDo, ValidFrom, ValidTo, IsValid, ISNULL(LastModifiedOn, CreatedOn), ColumnsSet, ValString
							FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] c
							WHERE c.ObiektId = ' + CAST(@ObiektId AS varchar) + ' AND c.CechaID = ' + CAST(@CechaId AS varchar) + ' AND c.IsMainHistFlow = 1
								AND c.' + @DateFromColumnName + ' >= ' + @DataObowiazywaniaOdStr
							
						--PRINT @Query;	
						EXECUTE sp_executesql @Query, N'@maxDate date', @maxDate = @maxDate							
						
					END								
					ELSE IF @HistoryType = 3
					BEGIN
					
						--pobranie przedzialow z wartosciami dla historii glownej, ktore przecinaja sie z wstawianym przedzialem(jesli do nieskonczonosci lub podanej daty)
						SET @Query = '
							INSERT INTO #PrzedzialyWpisow (Id, CechaId, ObowiazujeOd, ObowiazujeDo, ValidFrom, ValidTo, IsValid, LastModifiedOn, ColumnsSet, ValString)
							SELECT Id, CechaId, ObowiazujeOd, ObowiazujeDo, ValidFrom, ValidTo, IsValid, ISNULL(LastModifiedOn, CreatedOn), ColumnsSet, ValString
							FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] c
							WHERE c.ObiektId = ' + CAST(@ObiektId AS varchar) + ' AND c.CechaID = ' + CAST(@CechaId AS varchar) + ' AND c.IsMainHistFlow = 1
								 AND COALESCE(c.' + @DateFromColumnName + ', @maxDate) <= COALESCE(' + @DataObowiazywaniaDoStr + ', @maxDate)
								AND COALESCE(c.' + @DateFromColumnName + ', @maxDate) >= COALESCE(' + @DataObowiazywaniaOdStr + ', @maxDate)'
						
						--PRINT @Query;	
						EXECUTE sp_executesql @Query, N'@maxDate date', @maxDate = @maxDate
		
						SELECT @NowyPrzedzialWartoscXml = pw.ColumnsSet, @NowyPrzedzialWartoscString = pw.ValString
						FROM #PrzedzialyWpisow pw
						JOIN					
						(
							SELECT MAX(pw2.ObowiazujeOd) AS MaxObowiazujeOd
							FROM #PrzedzialyWpisow pw2
							JOIN #CechyDoZastapienia cdz ON (pw2.Id = cdz.Id AND pw2.LastModifiedOn = cdz.LastModifiedOn)
						) najnowszy
						ON pw.ObowiazujeOd = najnowszy.MaxObowiazujeOd
						
						--pobranie przedzialu czasowego dla przedzialu czasowego modyfikowanego typu cechy i daty konca jej obowiazywania
						EXEC [THB].[PrepareTimeForNextPeriod]
							@AppDate = @DataObowiazywaniaDo,
							@TimeIntervalId = @PrzedzialCzasowyId,
							@MinDate = @NowyPrzedzialDataOd OUTPUT,
							@MaxDate = @PrzedzialObowiazujeTmp OUTPUT
						
--SELECT @NowyPrzedzialDataOd AS NoweOd, @NowyPrzedzialWartoscXml AS WartXml, @NowyPrzedzialWartoscString AS WartoscString
						
						IF @NowyPrzedzialDataOd IS NOT NULL AND (@NowyPrzedzialWartoscXml IS NOT NULL OR @NowyPrzedzialWartoscString IS NOT NULL)
							SET @WstawicNowyPrzedzial = 1;
						ELSE
							SET @WstawicNowyPrzedzial = 0;						
						
					END
								
--SELECT * FROM #PrzedzialyWpisow
								
					BEGIN TRAN T1_Units_SaveAlternative							

					-- pobranie wartosci wstawianej cechy
					IF @CechaWartoscXML IS NOT NULL
					BEGIN
						SELECT @TypWartosciCechy = c.value('local-name(.)', 'varchar(max)'),
							   @WartoscCechy = c.value('./@Value', 'nvarchar(500)'),
							   @IdSlownika = c.value('./@Id', 'int'),
							   @IdElementuSlownika = c.value('./@ElementId', 'int')
						FROM @CechaWartoscXML.nodes('/*') AS t(c)
					END										

					SET @WartoscCechyQuery = CASE LOWER(@TypWartosciCechy)
												WHEN 'valstring' THEN '''' + @WartoscCechy + ''''
												WHEN 'valdecimal' THEN ' CONVERT(decimal(18,5), ''' + @WartoscCechy + ''')'
												WHEN 'valint' THEN ' CAST(''' + @WartoscCechy + ''' AS int)'
												WHEN 'valdouble' THEN ' CONVERT(double, ''' + @WartoscCechy + ''')'
												WHEN 'valdatetime' THEN ' CONVERT(datetime, ''' + @WartoscCechy + ''')'
												WHEN 'valbit' THEN ' CAST(''' + @WartoscCechy + ''' AS bit)'
												WHEN 'valfloat' THEN ' CONVERT(float, ''' + @WartoscCechy + ''')'
												WHEN 'valtime' THEN ' CONVERT(time, ''' + @WartoscCechy + ''' AS bit)'
												WHEN 'valdate' THEN ' CONVERT(date, ''' + @WartoscCechy + ''')'
												WHEN 'valdictionary' THEN CAST(@IdElementuSlownika AS varchar)																								
											END												
												
--SELECT @WartoscCechyQuery, @TypWartosciCechy AS TYPWartosci, @WartoscCechy AS WartoscCechy, @IdSlownika AS IdSlownika, @IdElementuSlownika AS IdElementuSlownika
					
					--srawdzenie czy wpis o podanej dacie obowiazywania od posiada juz w bazie wpis histori alternatywnej
					SET @Query = '
						IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
						BEGIN
							IF EXISTS (SELECT Id FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist]
								WHERE IsMainHistFlow = 0 AND CechaId = ' + CAST(@CechaId AS varchar) + ' AND ObiektId = ' + CAST(@ObiektId AS varchar) + ' AND ObowiazujeOd = ' + @DataObowiazywaniaOdStr + ')
							BEGIN
								SET @CzyJestHistoriaAlternatywnaJuzWBazie = 1;
							END
							ELSE
							BEGIN
								SET @CzyJestHistoriaAlternatywnaJuzWBazie = 0;
							END
						END
						ELSE
							SET @CzyJestHistoriaAlternatywnaJuzWBazie = 0;'
					
					--PRINT @Query;	
					EXECUTE sp_executesql @Query, N'@CzyJestHistoriaAlternatywnaJuzWBazie bit OUTPUT', @CzyJestHistoriaAlternatywnaJuzWBazie = @CzyJestHistoriaAlternatywnaJuzWBazie OUTPUT

--SELECT @CzyJestHistoriaAlternatywnaJuzWBazie AS CzyJestHistoriaAlternatywnaJuzWBazie					
																							
					-- sprawdzenie czy cecha alternatywna istnieje juz w podanym przedziale czasowym
					SET @Query = '
						IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
						BEGIN
							SELECT TOP 1 @CechaAlternatywnaIstniejeId = Id, @WartoscCechyQueryTmp = ' + @TypWartosciCechy + ', @IsMainHistFlowTmp = IsMainHistFlow 
							FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] 
							WHERE ObowiazujeOd = ' + @DataObowiazywaniaOdStr + ' AND CechaId = ' + CAST(@CechaId AS varchar) + ' AND ObiektId = ' + CAST(@ObiektId AS varchar) + '
								AND IsMainHistFlow = ' + CAST(@IsMainHistFlow AS varchar);											
				
				--narazie niepotrzebne
					--IF @HistoryType = 2 OR @HistoryType = 3
					--BEGIN
					
					--	SET @Query += ' AND Id IN (SELECT Id FROM #PrzedzialyWpisow)'
					
					--END	
										
					
					SET @Query += '
						END';
									
					--PRINT @Query;	
					EXECUTE sp_executesql @Query, N'@CechaAlternatywnaIstniejeId int OUTPUT, @WartoscCechyQueryTmp nvarchar(300) OUTPUT, @IsMainHistFlowTmp bit OUTPUT', 
						@CechaAlternatywnaIstniejeId = @CechaAlternatywnaIstniejeId OUTPUT, @WartoscCechyQueryTmp = @WartoscCechyQueryTmp OUTPUT, @IsMainHistFlowTmp = @IsMainHistFlowTmp OUTPUT

--SELECT @CechaAlternatywnaIstniejeId AS CechaAlternatywnaId_Istniejaca, @DataObowiazywaniaOd AS ObowiazujeOd

					SET @WartoscCechyQueryTmp = CASE LOWER(@TypWartosciCechy)
												WHEN 'valstring' THEN '''' + @WartoscCechyQueryTmp + ''''
												WHEN 'valdecimal' THEN ' CONVERT(decimal(18,5), ''' + @WartoscCechyQueryTmp + ''')'
												WHEN 'valint' THEN ' CAST(''' + @WartoscCechyQueryTmp + ''' AS int)'
												WHEN 'valdouble' THEN ' CONVERT(double, ''' + @WartoscCechyQueryTmp + ''')'
												WHEN 'valdatetime' THEN ' CONVERT(datetime, ''' + @WartoscCechyQueryTmp + ''')'
												WHEN 'valbit' THEN ' CAST(''' + @WartoscCechyQueryTmp + ''' AS bit)'
												WHEN 'valfloat' THEN ' CONVERT(float, ''' + @WartoscCechyQueryTmp + ''')'
												WHEN 'valtime' THEN ' CONVERT(time, ''' + @WartoscCechyQueryTmp + ''' AS bit)'
												WHEN 'valdate' THEN ' CONVERT(date, ''' + @WartoscCechyQueryTmp + ''')'
												WHEN 'valdictionary' THEN CAST(@IdElementuSlownika AS varchar)																								
											END					
						
					-- jesli znaleziono wpis dla podanego obiektu, cechy i wartosc i flaga isMainHistFlow w podanym przedziale to rzucenie bledu
					IF @CechaAlternatywnaIstniejeId IS NOT NULL AND @CechaAlternatywnaIstniejeId > 1 AND @WartoscCechyQueryTmp = @WartoscCechyQuery --AND @IsMainHistFlowTmp = @IsMainHistFlow
					BEGIN
						RAISERROR ('Błąd. Podana wartość dla cechy alternatywnej w podanym przedziale już istnieje.', 16, 1);
					END													
			
					--jesli wpis dla cechy jeszcze nie istnieje
					IF @CechaAlternatywnaIstniejeId IS NULL
					BEGIN						
						
						--pobranie Id wpisu - de facto wartosci IdArch rekordu o najwiekszej dacie ValidFrom
						SET @Query = '
							SELECT TOP 1 @IdGlownegoRekorduZCecha = ISNULL(IdArch, Id)																					
							FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist]
							WHERE CechaId = ' + CAST(@CechaId AS varchar) + ' AND ObiektId = ' + CAST(@ObiektId AS varchar) + '
							ORDER BY ValidFrom DESC'
							
						--	PRINT @Query;
						EXECUTE sp_executesql @Query, N'@IdGlownegoRekorduZCecha int OUTPUT', @IdGlownegoRekorduZCecha = @IdGlownegoRekorduZCecha OUTPUT													
													
						-- insert wstawienie danych nowego wpisu historycznego	
						SET @Query = '
							IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
							BEGIN																	
								UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
									UIOrder = ' + CAST(@UIOrder AS varchar) + ',
									[Priority] = ' + CAST(ISNULL(@Priority, 2) AS varchar) + ', '											
									 + @TypWartosciCechy + ' = ' + @WartoscCechyQuery + ','
								 
						--IF @IsMainHistFlow = 1		 
						--	SET @Query += '	 
						--		IsAlternativeHistory = 0,';
						--ELSE
						--	SET @Query += '
						--		IsAlternativeHistory = 1,';
						
						SET @Query += '
									IsAlternativeHistory = ' + CAST(@CzyJestHistoriaAlternatywnaJuzWBazie AS varchar) + ',	
									IsMainHistFlow = ' +  CAST(@IsMainHistFlow AS varchar) + ',											
									--CechaId = ' + CAST(@CechaId AS varchar) + ',
									ValidFrom = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
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
									IsStatus = ' + CAST(ISNULL(@IsStatus, 0) AS varchar) + ',
									LastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
									LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + ',
									RealLastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacji, 109) + '''
								WHERE Id = ' + CAST(@IdGlownegoRekorduZCecha AS varchar) + '
						
							IF @@ROWCOUNT > 0
							BEGIN
								INSERT INTO #CechyZmienione(Id)
								VALUES(' + CAST(@IdGlownegoRekorduZCecha AS varchar) + ')
							END
						END'							
							
					END
					ELSE  --cecha dla okresu juz istnieje ale ma inna wartosc to jej nadpisanie z wylaczonym triggerem na update
					BEGIN
					
						SET @IdGlownegoRekorduZCecha = @CechaAlternatywnaIstniejeId;
												
						SET @Query = '
							IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
							BEGIN
								DISABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_Cechy_Hist_UPDATE] ON [_' + @NazwaTypuObiektu + '_Cechy_Hist];
																	
								UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
									UIOrder = ' + CAST(@UIOrder AS varchar) + ',
									[Priority] = ' + CAST(ISNULL(@Priority, 2) AS varchar) + ', '											
									 + @TypWartosciCechy + ' = ' + @WartoscCechyQuery + ',
									--IsAlternativeHistory = 1,
									--IsMainHistFlow = ' +  CAST(@IsMainHistFlow AS varchar) + ',											
									--CechaId = ' + CAST(@CechaId AS varchar) + ',
									--ValidFrom = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
									ObowiazujeOd = ' + @DataObowiazywaniaOdStr + ',
									--ObowiazujeDo = ' + @DataObowiazywaniaDoStr + ',
									StatusP = ' + @StatusPStr + ',
									StatusPFromBy = CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END,	
									StatusPFrom = CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END, 
									StatusS = ' + @StatusSStr + ',
									StatusSFromBy = CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END,	
									StatusSFrom = CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END, 
									StatusW = ' + @StatusWStr + ',
									StatusWFrom = CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END, 
									StatusWFromBy = CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END,
									IsStatus = ' + CAST(ISNULL(@IsStatus, 0) AS varchar) + ',
									LastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
									LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + ',
									RealLastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacji, 109) + '''
								WHERE Id = ' + CAST(@IdGlownegoRekorduZCecha AS varchar) + ';
							
								IF @@ROWCOUNT > 0
								BEGIN
									INSERT INTO #CechyZmienione(Id)
									VALUES(' + CAST(@IdGlownegoRekorduZCecha AS varchar) + ');
								END;
							
								ENABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_Cechy_Hist_UPDATE] ON [_' + @NazwaTypuObiektu + '_Cechy_Hist];
							END'
											
					END															
											
					PRINT @Query;
					EXECUTE sp_executesql @Query --, N'@ERRMSGTmp nvarchar(MAX) OUTPUT', @ERRMSGTmp = @ERRMSG OUTPUT
	
					
					--jesli wstawiono nowe dane jako historia alternatywna to modyfikacja glownej histori o dokladnie pokrywajacej sie dacie od z flaga IsAlternativeHistory z 0 -> 1
					IF @IsMainHistFlow = 0
					BEGIN
					
						SET @Query = '
							IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
							BEGIN																					
								DISABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_Cechy_Hist_UPDATE] ON [_' + @NazwaTypuObiektu + '_Cechy_Hist];
								
								UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
									IsAlternativeHistory = 1,
									LastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
									LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + ',
									RealLastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacji, 109) + '''
								WHERE CechaId = ' + CAST(@CechaId AS varchar) + ' AND ObiektId = ' + CAST(@ObiektId AS varchar) + ' AND IsAlternativeHistory = 0
									AND ' + @DateFromColumnName + ' = ' + @DataObowiazywaniaOdStr + ';
									
								ENABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_Cechy_Hist_UPDATE] ON [_' + @NazwaTypuObiektu + '_Cechy_Hist];
							END;'
							
						--PRINT @Query;
						EXECUTE sp_executesql @Query;
					
					END
					
					-- jesli sa wpisy ktore maja stac sie historia alternatywna to ich podmiana przy wylaczonych triggerach na update
					-- tylko wtedy gdy dane podanych przedzialow do zastapenia zgadzaja sie z tymi wyznaczonymi przez procedure (Id i LastModifiedOn)
					IF (SELECT COUNT(1) FROM #PrzedzialyWpisow) > 0
					BEGIN
						
						IF @IsMainHistFlow = 1
						BEGIN
							SET @Query = '
								DISABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_Cechy_Hist_UPDATE] ON [_' + @NazwaTypuObiektu + '_Cechy_Hist];							
								
								IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
								BEGIN
									UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
										IsMainHistFlow = 0,
										IsAlternativeHistory = 1,
										LastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
										LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + ',
										RealLastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacji, 109) + '''
									WHERE Id IN
									(
										SELECT pw.Id
										FROM #PrzedzialyWpisow pw
										JOIN #CechyDoZastapienia cdz ON (pw.Id = cdz.Id AND pw.LastModifiedOn = cdz.LastModifiedOn)
									)
								END;							
								
								ENABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_Cechy_Hist_UPDATE] ON [_' + @NazwaTypuObiektu + '_Cechy_Hist];'
						
							--PRINT @Query;
							EXECUTE sp_executesql @Query
						
						
							-- wstawienie nowego przedzialu z wartoscia obowiazujaca w poprzednim przedziale od daty Do ustawionego przedzialu
							IF @WstawicNowyPrzedzial = 1
							BEGIN
								
								IF @NowyPrzedzialDataOd IS NOT NULL
									SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @NowyPrzedzialDataOd, 109) + '''';
								ELSE
									SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + '''';							
								
								IF @NowyPrzedzialWartoscString IS NULL
									SET @NowyPrzedzialWartoscString = 'NULL';
								
								SET @Query = '
									IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
									BEGIN
										UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
											IsAlternativeHistory = 1,
											IsMainHistFlow = 1,
											ObowiazujeOd = ' + @DataObowiazywaniaOdStr + ',
											ValString = ' + @NowyPrzedzialWartoscString + ','
										
								IF @NowyPrzedzialWartoscXml IS NULL		
									SET @Query += '
											ColumnsSet = NULL,';
								ELSE
									SET @Query += '								
											ColumnsSet = ''' + CAST(@NowyPrzedzialWartoscXml AS nvarchar(MAX)) + ''','
										
								SET @Query += '			
											LastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
											LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + ',
											RealLastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacji, 109) + '''
										WHERE CechaId = ' + CAST(@CechaId AS varchar) + ' AND ObiektId = ' + CAST(@ObiektId AS varchar) + ' AND Id = ' + CAST(@IdGlownegoRekorduZCecha AS varchar) + '
									END'
										--AND ' + @DateFromColumnName + ' = ' + @DataObowiazywaniaOdStr + ' AND IsAlternativeHistory = 0 ;
									
								--PRINT @Query;
								EXECUTE sp_executesql @Query						
								
							END
						END					
					END							
					
						
					--przygotowanie XMLa zwrotnego
					SET @xmlResponse = (SELECT TOP 1
						(SELECT ID AS '@Id',
							'Attribute' AS '@EntityType'
							FROM #CechyZmienione sl
							FOR XML PATH('Ref'), ROOT('Value'), TYPE
							)
						FROM #CechyZmienione
						FOR XML PATH('Result'));
			
					COMMIT TRAN T1_Units_SaveAlternative

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Units_SaveAlternativeHistoryAttribute', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Units_SaveAlternativeHistoryAttribute', @Wiadomosc = @ERRMSG OUTPUT	
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_Units_SaveAlternative
		END
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Units_SaveAlternativeHistoryAttribute"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += + '>';
	
	IF @ERRMSG IS NULL OR @ERRMSG = '' 	
	BEGIN
		IF @xmlResponse IS NOT NULL
		BEGIN
			SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		END
		ELSE
			SET @XMLDataOut += '<Result><Value/></Result>';
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>'
	END

	SET @XMLDataOut += '</Response>';	
	
	--usuwanie tabel tymczasowych, jesli istnieja				
	IF OBJECT_ID('tempdb..#CechyZmienione') IS NOT NULL
		DROP TABLE #CechyZmienione
	
	IF OBJECT_ID('tempdb..#PrzedzialyWpisow') IS NOT NULL
		DROP TABLE #PrzedzialyWpisow
		
	IF OBJECT_ID('tempdb..#CechyDoZastapienia') IS NOT NULL
		DROP TABLE #CechyDoZastapienia	
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut			

END
