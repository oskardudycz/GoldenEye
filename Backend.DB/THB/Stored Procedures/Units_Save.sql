-- =============================================
-- Author:		DK
-- Create date: 2012-04-01
-- Last modified on: 2013-07-25
-- Description:	Zapisuje dane obiektow. Aktualizuje istniejacy lub wstawia nowy rekord.

-- Przykladowy plik XML wejsciowy:
	--<?xml version="1.0"?>
	--<Request RequestType="Units_Save" UserId="1" AppDate="2012-02-09T11:33:22">
		
	--	<Unit Id="1" TypeId="20" Name="21323123" Version="12" LastModifiedOn="2012-02-09T12:12:12.121Z">        
	--		<Attribute Id="1" TypeId="12" Priority="1" UIOrder="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<ValDictionary Id="5" ElementId="23"/>
	--		</Attribute>
	--		<Attribute Id="2" TypeId="45" Priority="0" UIOrder="1" LastModifiedOn="2012-02-09T12:12:12.121Z">            
	--			<ValDecimal Value="46.09"/>
	--		</Attribute>
	--	</Unit>
	    
	--	<Unit Id="2" TypeId="21" Name="bbb21323123" Version="12" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<Attribute Id="1" TypeId="12" Priority="1" UIOrder="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<ValDictionary Id="5" ElementId="23"/>
	--		</Attribute>
	--		<Attribute Id="2" TypeId="45" Priority="0" UIOrder="1" LastModifiedOn="2012-02-09T12:12:12.121Z">            
	--			<ValDecimal Value="46.09"/>
	--		</Attribute>
	--	</Unit>	    
	--</Request>
	
-- Przykłądowy plik XML wyjściowy:
	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Units_Save" AppDate="2012-02-09">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="Unit" />
	--			<Ref Id="2" EntityType="Unit" />
	--		</Value>
	--	</Result>
	--</Response>
-- =============================================
CREATE PROCEDURE [THB].[Units_Save]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	--SET ANSI_WARNINGS OFF;

	DECLARE @DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@xmlOk bit,
		@Query nvarchar(MAX) = '',
		@xml_data xml,
		@BranzaID int,
		@Id int,
		@Nazwa nvarchar(500),
		@Index int,
		@Wersja int,
		@LastModifiedOn datetime,
		@Uwagi nvarchar(MAX),
		@ERRMSG nvarchar(MAX),
		@xmlResponse xml,
		@PrzetwarzanyObiektId int,
		@Skip bit = 0,
		@MaUprawnienia bit = 0,
		@Counter int = 0,
		@IloscObiektow int = 0,
		@IloscCechObiektu int = 0,
		@TypObiektuId int,
		@CechaId int,
		@NazwaTypuObiektu nvarchar(MAX),
		@CechaIndex int,
		@IdCechyObiektu int,
		@UIOrder smallint,
		@Priority smallint,
		@CechaWartoscXML xml,
		@TypWartosciCechy varchar(150),
		@WartoscCechy nvarchar(MAX),
		@IdSlownika int,
		@IdElementuSlownika int,
		@IndexCechy int,
		@CounterCechObiektow int,
		@WartoscCechyQuery nvarchar(MAX),
		@CzySlownik bit,
		@XmlSparse xml,
		@CechaTyp varchar(150),
		@CechaTypId int,
		@WartoscString nvarchar(MAX),
		@CechaWartosc nvarchar(MAX),
		@CechaObiektuId int,
		@CechaHasAlternativeHistory bit = 0,
		@CechaDlaObiektuIstnieje bit = 0,
		@Commit bit = 1,
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@TmpDaneOb nvarchar(MAX) = '',
		@DataModyfikacji datetime = GETDATE(),
		@CechyWidoczneDlaUzytkownika nvarchar(MAX),
		@NazwaSlownika nvarchar(500),
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
		@maxDate date = '9999-12-31',
		--parametry dla zapytania dynamicznego
		@OldIsStatus bit,
		@OldStatusS int,
		@OldStatusW int,
		@OldStatusP int,
		@OldIsOuter bit,
		@OldWersja int,
		@OldNazwa nvarchar(500),
		@SaNoweCechy bit = 0,
		@AttributeIndex int,
		--@PrzedzialCzasowyId int,
		@PrzedzialMinDate datetime,
		@PrzedzialMaxDate datetime,
		
		@CzyTabela bit,
		@TypKolumny varchar(200),
		@NazwaKolumny nvarchar(500),
		@CechaIdKolumny int,
		@UnitTypeColumns nvarchar(MAX) = '',
		@ObiektIdDlaCechy int,
		@CzyTabelaCounter int = 0,
		@TabelaryczneKolumnyQuery nvarchar(MAX),
		@TabelaryczneWartosciQuery nvarchar(MAX),
		@CzyInsert bit = 0,
		@NazwaCechy nvarchar(500),
		@AktualnaWartoscCechy nvarchar(MAX),
		@NowaWartoscCechy bit = 1			

	BEGIN TRY

--select 'rozpoczecie', getdate();
		print 'ok'
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Units_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			IF OBJECT_ID('tempdb..#KolumnyTypuObiektu') IS NOT NULL
				DROP TABLE #KolumnyTypuObiektu
				
			--usuwanie tabel tymczasowych, jesli istnieja
			IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
				DROP TABLE #Obiekty
				
			IF OBJECT_ID('tempdb..#CechyObiektow') IS NOT NULL
				DROP TABLE #CechyObiektow
				
			IF OBJECT_ID('tempdb..#WartosciCech') IS NOT NULL
				DROP TABLE #WartosciCech
				
			IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
				DROP TABLE #IDZmienionych
				
			IF OBJECT_ID('tempdb..#ObiektyKonfliktowe') IS NOT NULL
				DROP TABLE #ObiektyKonfliktowe
			
			IF OBJECT_ID('tempdb..#ObiektyNieUnikalne') IS NOT NULL
				DROP TABLE #ObiektyNieUnikalne
				
			IF OBJECT_ID('tempdb..#ObiektyZle') IS NOT NULL
				DROP TABLE #ObiektyZle
			
			IF OBJECT_ID('tempdb..#ObiektyDaneZle') IS NOT NULL
				DROP TABLE #ObiektyDaneZle
				
			IF OBJECT_ID('tempdb..#CechyObiektuDaneZle') IS NOT NULL
				DROP TABLE #CechyObiektuDaneZle
				
			IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
				DROP TABLE #Statusy
			
			IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
				DROP TABLE #Historia
				
			IF OBJECT_ID('tempdb..#HistoriaCech') IS NOT NULL
				DROP TABLE #HistoriaCech
			
			IF OBJECT_ID('tempdb..#StatusyCech') IS NOT NULL
				DROP TABLE #StatusyCech
				
			CREATE TABLE #ObiektyKonfliktowe(ID int, TypId int);	
			CREATE TABLE #ObiektyNieUnikalne(ID int, TypId int);	
			CREATE TABLE #IDZmienionych (ID int, TypObiektuId int, Lp int IDENTITY(1,1));
			CREATE TABLE #WartosciCech (RootIndex int, AttributeIndex int, Value xml);
			CREATE TABLE #KolumnyTypuObiektu(TypObiektuId int, CechaId int, NazwaKolumny nvarchar(500), TypKolumny varchar(150));
			CREATE TABLE #ObiektyZle(ID int, TypId int);
			
			CREATE TABLE #StatusyCech (RootIndex int, AttributeIndex int, IsStatus bit, StatusP int, StatusPFrom datetime, StatusPTo datetime,
				StatusPFromBy int, StatusPToBy int, StatusS int, StatusSFrom datetime, StatusSTo datetime, StatusSFromBy int, StatusSToBy int,
				StatusW int, StatusWFrom datetime, StatusWTo datetime, StatusWFromBy int, StatusWToBy int);
		
			CREATE TABLE #HistoriaCech (RootIndex int, AttributeIndex int, ZmianaOd datetime, ZmianaDo datetime, DataObowiazywaniaOd datetime, DataObowiazywaniaDo datetime,
				IsAlternativeHistory bit, IsMainHistFlow bit);
			
			CREATE TABLE #ObiektyDaneZle(TypObiektuId int, Id int, Nazwa nvarchar(500), IsStatus bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,[StatusSFromBy] int,
			[StatusSToBy] int, [StatusW] int, [StatusWFrom] datetime, [StatusWTo] datetime, [StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,[StatusPTo] datetime,
			[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,[ValidFrom] datetime,[ValidTo] datetime,
			[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,[CreatedBy] int,[LastModifiedOn] datetime,
			[LastModifiedBy] int,[IsAlternativeHistory] bit,[IsMainHistFlow] bit);	
	
			CREATE TABLE #CechyObiektuDaneZle(TypObiektuId int, ObiektId int, Id int, CechaId int, TypCechyId int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), [IsStatus] bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,
			[StatusSFromBy] int,[StatusSToBy] int,[StatusW] int,[StatusWFrom] datetime,[StatusWTo] datetime,[StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,
			[StatusPTo] datetime,[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,
			[ValidFrom] datetime,[ValidTo] datetime,[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,
			[CreatedBy] int,[LastModifiedOn] datetime,[LastModifiedBy] int,[Priority] smallint,[UIOrder] smallint,[IsAlternativeHistory] bit,[IsMainHistFlow] bit);

			CREATE TABLE #CechyObiektow (RootIndex int, AttributeIndex int, Id int, CechaId int, [Priority] smallint, UIOrder smallint, TypId int, LastModifiedOn datetime);
					
			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);
		
			SET @IloscObiektow = (SELECT @xml_data.value('count(/Request/Unit)','int'));
		
			--odczytywanie danych obiektow
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/Unit)','int') )
			)
			SELECT 	j AS 'Index'
				   ,x.value('./@Id', 'int') AS ID
				   ,x.value('./@TypeId', 'int') AS TypObiektuId
				   ,x.value('./@Name', 'nvarchar(256)') AS Nazwa
				   ,x.value('./@Version', 'int') AS Wersja
				   ,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
			INTO #Obiekty
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Unit[position()=sql:column("j")]')  e(x);
			
			
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/Unit)','int') )
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
			CROSS APPLY @xml_data.nodes('/Request/Unit[position()=sql:column("j")]/History')  e(x);
			
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/Unit)','int') )
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
			CROSS APPLY @xml_data.nodes('/Request/Unit[position()=sql:column("j")]/Statuses')  e(x);			
			
			--pobieranie wartosci cech dla obiektow
			SET @Counter = 0;
			
			WHILE @Counter <= @IloscObiektow
			BEGIN
				
				--odczytywanie danych cech obiektu	
				SET @Query = '
				;WITH Num(j)
				AS
				(
				   SELECT 1
				   UNION ALL
				   SELECT j + 1
				   FROM Num
				   WHERE j < (SELECT @xml_data.value(''count(/Request/Unit[position()=' + CAST(@Counter AS varchar) + ']/Attribute)'', ''int'') )
				)
				INSERT INTO #CechyObiektow (RootIndex, AttributeIndex, Id, CechaId, [Priority], UIOrder, TypId, LastModifiedOn)				
				SELECT ' + CAST(@Counter AS varchar) + '
					,j
					,x.value(''./@Id'',''int'')
					,x.value(''./@TypeId'', ''int'')
					,x.value(''./@Priority'', ''smallint'')
					,x.value(''./@UIOrder'', ''smallint'')
					,x.value(''../@TypeId'', ''int'')
					,x.value(''./@LastModifiedOn'', ''datetime'')
				FROM Num
				CROSS APPLY @xml_data.nodes(''/Request/Unit[position()=' + CAST(@Counter AS varchar) + ']/Attribute[position()=sql:column("j")]'')  e(x)';
				
				--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				
				SET @Query = '
					WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Unit[position()=' + CAST(@Counter AS varchar) + ']/Attribute)'', ''int'') )
					)	
						
					INSERT INTO #WartosciCech (RootIndex, AttributeIndex, Value)
					SELECT ' + CAST(@Counter AS varchar) + '
							, j
							,x.query(''.'')	
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/Unit[position()=' + CAST(@Counter AS varchar) + ']/Attribute[position()=sql:column("j")]/*[not(self::History) and not(self::Statuses)]'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				--statusy dla cech obiektu
				SET @Query = '
					;WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Unit[position()=' + CAST(@Counter AS varchar) + ']/Attribute)'', ''int'') )
					)							
					INSERT INTO #StatusyCech (RootIndex, AttributeIndex, IsStatus, StatusP, StatusPFrom, StatusPTo, StatusPFromBy, StatusPToBy, StatusS, StatusSFrom, 
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
					CROSS APPLY @xml_data.nodes(''/Request/Unit[position()=' + CAST(@Counter AS varchar) + ']/Attribute[position()=sql:column("j")]/Statuses'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				--historia cech obiektow
				SET @Query = '
					;WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Unit[position()=' + CAST(@Counter AS varchar) + ']/Attribute)'', ''int'') )
					)	
						
					INSERT INTO #HistoriaCech (RootIndex, AttributeIndex, ZmianaOd, ZmianaDo, DataObowiazywaniaOd, DataObowiazywaniaDo, IsAlternativeHistory, IsMainHistFlow)
					SELECT ' + CAST(@Counter AS varchar) + '
							, j
							,x.value(''./@ChangeFrom'', ''datetime'') 
							,x.value(''./@ChangeTo'', ''datetime'')
							,x.value(''./@EffectiveFrom'', ''datetime'')
							,x.value(''./@EffectiveTo'', ''datetime'')
							,x.value(''./@IsAlternativeHistory'', ''bit'')
							,x.value(''./@IsMainHistFlow'', ''bit'')
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/Unit[position()=' + CAST(@Counter AS varchar) + ']/Attribute[position()=sql:column("j")]/History'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
			
				SET @Counter = @Counter + 1; 
			END	
			
			--SELECT * FROM #Obiekty;
			--SELECT * FROM #Historia;
			--SELECT * FROM #Statusy;
			--SELECT * FROM #CechyObiektow
			--SELECT * FROM #WartosciCech
			--SELECT * FROM #HistoriaCech;
			--SELECT * FROM #StatusyCech;
			--SELECT @DataProgramu, @UzytkownikID, @RequestType
			
--select 'po odczytaniu xml', getdate()

			
			IF @RequestType = 'Units_Save'
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
						
					BEGIN TRAN T1_Units_Save
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
					
					DECLARE cur CURSOR LOCAL FOR 
						SELECT [Index], Id, TypObiektuId, Nazwa, LastModifiedOn FROM #Obiekty
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @TypObiektuId, @Nazwa, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--wyzerowanie zmiennych
						SET @Skip = 0;
						SET @CzyTabela = NULL;
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL;
						
						SELECT @NazwaTypuObiektu = Nazwa, @CzyTabela = Tabela
						FROM dbo.[TypObiektu] WHERE TypObiekt_ID = @TypObiektuId;
						
						--pobranie danych zmian obietow
						SELECT	@ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, 
						@DataObowiazywaniaOd = DataObowiazywaniaOd, @DataObowiazywaniaDo = DataObowiazywaniaDo
						FROM #Historia WHERE RootIndex = @Index;		
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index
		
						--jesli obiekt tabelaryczny to pobranie jego cech/nazw kolumn
						IF @CzyTabela = 1
						BEGIN
						
					--		DELETE FROM #KolumnyTypuObiektu;
							
							IF NOT EXISTS (SELECT TypObiektuId FROM #KolumnyTypuObiektu WHERE TypObiektuId = @TypObiektuId)
							BEGIN
								--pobranie nazw i typow kolumn/cech na podstawie PIERWSZEJ nazwy cechy
								INSERT INTO #KolumnyTypuObiektu (TypObiektuId, NazwaKolumny, TypKolumny, CechaId)
								SELECT DISTINCT @TypObiektuId, c.Nazwa, ct.NazwaSql, ISNULL(allData.IdArch, allData.Cecha_ID)
								FROM
								(
									SELECT o.Cecha_ID, o.IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(o.IdArch, o.Cecha_ID) ORDER BY o.Cecha_ID ASC) AS Rn
									FROM [dbo].[Cechy] o
									INNER JOIN
									(
										SELECT ISNULL(c2.IdArch, c2.Cecha_ID) AS RowID, MIN(c2.ObowiazujeOd) AS MinDate
										FROM [dbo].[Cechy] c2							 
										JOIN dbo.TypObiektu_Cechy toc ON (c2.Cecha_Id = toc.Cecha_Id OR c2.IdArch = toc.Cecha_Id)
										WHERE toc.TypObiektu_ID = @TypObiektuId AND toc.IsDeleted = 0
										GROUP BY ISNULL(c2.IdArch, c2.Cecha_ID)
									) latestWithMaxDate
									ON ISNULL(o.IdArch, o.Cecha_ID) = latestWithMaxDate.RowID AND o.ObowiazujeOd = latestWithMaxDate.MinDate
								) allData
								JOIN dbo.Cechy c ON (c.Cecha_Id = allData.Cecha_Id)
								JOIN dbo.Cecha_Typy ct ON (c.TypId = ct.Id) 
								WHERE allData.Rn = 1						
							END

--SELECT * FROM #KolumnyTypuObiektu					
						END						

--poki co kolumna nie uzywana
SET @DataObowiazywaniaDo = NULL;
						
						--pobranie dnaych zmian i obowiazywania
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
					
						IF @NazwaTypuObiektu IS NOT NULL
						BEGIN					
						
							--sprawdzenie czy sa nowe cechy dla obiektu
							--nowo dodawane cechy maja w polu Id wartosc 0
							IF EXISTS (SELECT Id FROM #CechyObiektow WHERE RootIndex = @Index) --Id = 0 AND
								SET @SaNoweCechy = 1;
							ELSE
								SET @SaNoweCechy = 0;
						
						    --zabezpieczenie dla tabel z rekordem o Id = 0

							
						    IF @Id = 0
								SET @Id = -1;
						
							SET @Query = '							
								--pobranie aktualnych danych obiektu by sprawdzic czy zmienila sie jakas dana
								SELECT @OldIsStatus = ISNULL(IsStatus, 0), @OldStatusS = StatusS, @OldStatusW = StatusW, @OldStatusP = StatusP, @OldNazwa = Nazwa --@OldWersja = Wersja,
								FROM dbo.[_' + @NazwaTypuObiektu + '] WHERE Id = ' + CAST(@Id AS varchar) + ';
							
								--jesli obiekt istnieje					
								IF @OldNazwa IS NOT NULL
								BEGIN
					
									--sprawdzenie czy zmienily sie dane obiektu
									IF (@OldIsStatus = ISNULL(@IsStatus, 0) AND CAST(ISNULL(@OldStatusS, 0) AS varchar) = CAST(ISNULL(@StatusS, 0) AS varchar) AND
										CAST(ISNULL(@OldStatusW, 0) AS varchar) = CAST(ISNULL(@StatusW, 0) AS varchar) AND CAST(ISNULL(@OldStatusP, 0) AS varchar) = CAST(ISNULL(@StatusP, 0) AS varchar) AND 
										@OldNazwa = @Nazwa AND ' + CAST(@CzyTabela AS varchar) + ' = 0) --AND ' + CAST(@SaNoweCechy AS varchar) + ' = 0)
									BEGIN
									
										IF EXISTS(SELECT Id FROM dbo.[_' + @NazwaTypuObiektu + '] WHERE Id = ' + CAST(@Id AS varchar) + ' AND (LastModifiedOn = ''' + CONVERT(nvarchar(50), @LastModifiedOn, 109) + ''' OR (LastModifiedOn IS NULL AND CreatedOn = ''' + CONVERT(nvarchar(50), @LastModifiedOn, 109) + ''')))
										BEGIN
											--brak zmian danych, ustalamy tylko Id dla przetwarzanego rekordu
											SET @PrzetwarzanyObiektId = ' + CAST(@Id AS varchar) + ';
											INSERT INTO #IDZmienionych (ID, TypObiektuId) VALUES(@PrzetwarzanyObiektId,' + CAST(@TypObiektuId AS varchar) + ');
	PRINT ''Brak zmiany danych obiektu'';				
											--zmieniamy tylko daty ostatnich modyfikacji przy wylaczonych triggerach
											DISABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_UPDATE] ON dbo.[_' + @NazwaTypuObiektu + '];
											
											UPDATE dbo.[_' + @NazwaTypuObiektu + '] SET
												LastModifiedOn = ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''',
												RealLastModifiedOn = ''' + CONVERT(nvarchar(50), @DataModyfikacji, 109) + '''
											WHERE Id = ' + CAST(@Id AS varchar) + ';
											
											ENABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_UPDATE] ON dbo.[_' + @NazwaTypuObiektu + '];
										END
										ELSE
										BEGIN
											INSERT INTO #ObiektyKonfliktowe(ID, TypId)
											VALUES(' + CAST(@Id AS varchar) + ', ' + CAST(@TypObiektuId AS varchar) + ');
												
											EXEC [THB].[GetErrorMessage] @Nazwa = N''CONCURRENCY_ERROR'', @Grupa = N''PROC_RESULT'', @Wiadomosc = @ERRMSGTmp OUTPUT
											SET @CommitTmp = 0;
											SET @Skip = 1;
										END
									END
									ELSE
									BEGIN'
									
							SET @Query += '							
	PRINT ''Zmiana	danych''
										SET @CzyInsert = 0;	
		
										IF @CzyTabela = 0
										BEGIN										
									
											UPDATE dbo.[_' + @NazwaTypuObiektu + '] SET
												Nazwa = ''' + @Nazwa + ''',
												--ObowiazujeOd = ' + @DataObowiazywaniaOdStr + ',
												--ObowiazujeDo = ' + @DataObowiazywaniaDoStr + ',
												ObowiazujeOd = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
												ObowiazujeDo = NULL,
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
											WHERE Id = ' + CAST(@Id AS varchar) + ' AND (LastModifiedOn = ''' + CONVERT(nvarchar, @LastModifiedOn, 109) + ''' OR (LastModifiedOn IS NULL AND CreatedOn = ''' + CONVERT(nvarchar, @LastModifiedOn, 109) + '''));
											
											IF @@ROWCOUNT > 0
											BEGIN
												SET @PrzetwarzanyObiektId = ' + CAST(@Id AS varchar) + ';
												INSERT INTO #IDZmienionych (ID, TypObiektuId) VALUES(@PrzetwarzanyObiektId,' + CAST(@TypObiektuId AS varchar) + ');
											END
											ELSE
											BEGIN
												--brak aktualizacji bo nie zgadzala sie data ostatneij modyfikacji
												INSERT INTO #ObiektyKonfliktowe(ID, TypId)
												VALUES(' + CAST(@Id AS varchar) + ', ' + CAST(@TypObiektuId AS varchar) + ');
												
												EXEC [THB].[GetErrorMessage] @Nazwa = N''CONCURRENCY_ERROR'', @Grupa = N''PROC_RESULT'', @Wiadomosc = @ERRMSGTmp OUTPUT
												SET @CommitTmp = 0;
												SET @Skip = 1;
											END
										END
										ELSE
										BEGIN									
											SET @PrzetwarzanyObiektId = ' + CAST(@Id AS varchar) + ';

											IF EXISTS(SELECT Id FROM dbo.[_' + @NazwaTypuObiektu + '] WHERE Id = ' + CAST(@Id AS varchar) + ' AND (LastModifiedOn = ''' + CONVERT(nvarchar, @LastModifiedOn, 109) + ''' OR (LastModifiedOn IS NULL AND CreatedOn = ''' + CONVERT(nvarchar, @LastModifiedOn, 109) + ''')))
											BEGIN											
										
												SET @TabelaryczneKolumnyQuery = ''
													UPDATE dbo.[_' + @NazwaTypuObiektu + '] SET
														Nazwa = ''''' + @Nazwa + ''''',
														ObowiazujeOd = ''''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''''',
														ObowiazujeDo = NULL,
														LastModifiedOn = ''''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''''',
														LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + '''
												
												SET @TabelaryczneWartosciQuery = ''
													WHERE Id = ' + CAST(@Id AS varchar) + ' AND (LastModifiedOn = ''''' + CONVERT(nvarchar, @LastModifiedOn, 109) + ''''' OR (LastModifiedOn IS NULL AND CreatedOn = ''''' + CONVERT(nvarchar, @LastModifiedOn, 109) + '''''))'';									
											END
											ELSE
											BEGIN
												INSERT INTO #ObiektyKonfliktowe(ID, TypId)
												VALUES(' + CAST(@Id AS varchar) + ', ' + CAST(@TypObiektuId AS varchar) + ');
												
												EXEC [THB].[GetErrorMessage] @Nazwa = N''CONCURRENCY_ERROR'', @Grupa = N''PROC_RESULT'', @Wiadomosc = @ERRMSGTmp OUTPUT
												SET @CommitTmp = 0;
												SET @Skip = 1;
											END
										END
									END
								END'
								
										--	INSERT INTO dbo.[_' + @NazwaTypuObiektu + '] (Nazwa, CreatedOn, CreatedBy, ValidFrom, ObowiazujeOd, ObowiazujeDo,
										--	IsAlternativeHistory, IsMainHistFlow) VALUES (''' + @Nazwa + ''', ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''', ' 
										--+ CAST(@UzytkownikId AS varchar) + ', ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''', 
										--''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''', NULL, 0, 1);
								
							SET @Query += '	
								ELSE
								BEGIN															
									SET @CzyInsert = 1;
							
									IF @CzyTabela = 0
									BEGIN

										INSERT INTO dbo.[_' + @NazwaTypuObiektu + '] (Nazwa, CreatedOn, CreatedBy, ValidFrom, RealCreatedOn, ObowiazujeOd, ObowiazujeDo,
										IsStatus, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy, StatusP, StatusPFrom, StatusPFromBy, IsAlternativeHistory, IsMainHistFlow) VALUES 
										(''' + @Nazwa + ''', ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''', ' 
										+ CAST(@UzytkownikId AS varchar) + ', ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''', ''' + CONVERT(varchar, @DataModyfikacji, 109) + ''', 
										''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''', NULL, ' + CAST(ISNULL(@IsStatus, 0) AS varchar) + ', ' +
										@StatusSStr + ', CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END,
										CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END, ' + @StatusWStr + ', 
										CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END,
										CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END, ' + @StatusPStr + ',
										CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END,
										CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END,
										0, 1);
				
										IF @@ROWCOUNT > 0
										BEGIN
											SET @PrzetwarzanyObiektId = @@IDENTITY;
											INSERT INTO #IDZmienionych (ID, TypObiektuId) VALUES(@PrzetwarzanyObiektId, ' + CAST(@TypObiektuId AS varchar) + ');
										END
									END
									ELSE
									BEGIN									
										SET @TabelaryczneKolumnyQuery = ''INSERT INTO dbo.[_' + @NazwaTypuObiektu + '] (Nazwa, CreatedOn, CreatedBy, ValidFrom, ObowiazujeOd, ObowiazujeDo, IsAlternativeHistory, IsMainHistFlow''			
										SET @TabelaryczneWartosciQuery = ''VALUES (''''' + @Nazwa + ''''', ''''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''''', ' + CAST(@UzytkownikId AS varchar) + ', ''''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''''', 
										''''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''''', NULL, 0, 1''									
									END
								END'



						PRINT @Query;						
							EXECUTE sp_executesql @Query, N'@PrzetwarzanyObiektId int OUTPUT, @Skip bit OUTPUT, @OldIsStatus bit, @Wersja int, @OldStatusS int, @OldStatusW int, @OldStatusP int, @OldIsOuter bit,
								@OldWersja int, @OldNazwa nvarchar(256), @IsStatus bit, @Nazwa nvarchar(256), @StatusS int, @StatusW int, @StatusP int, @CzyTabela bit, @CzyInsert bit OUTPUT, @ERRMSGTmp nvarchar(MAX) OUTPUT, @CommitTmp bit OUTPUT,
								@TabelaryczneKolumnyQuery nvarchar(MAX) OUTPUT, @TabelaryczneWartosciQuery nvarchar(MAX) OUTPUT', 
								@IsStatus = @IsStatus, @StatusP = @StatusP, @StatusW = @StatusW, @StatusS = @StatusS, @Wersja = @Wersja, @Nazwa = @Nazwa, 
								@OldIsStatus = @OldIsStatus, @OldStatusS = @OldStatusS, @OldStatusW = @OldStatusW, @OldStatusP = @OldStatusP, @OldIsOuter = @OldIsOuter, @CzyTabela = @CzyTabela,
								@OldWersja = @OldWersja, @OldNazwa = @OldNazwa, @PrzetwarzanyObiektId = @PrzetwarzanyObiektId OUTPUT, @Skip = @Skip OUTPUT, @ERRMSGTmp = @ERRMSG OUTPUT, @CommitTmp = @Commit OUTPUT, @CzyInsert = @CzyInsert OUTPUT,
								@TabelaryczneKolumnyQuery = @TabelaryczneKolumnyQuery OUTPUT, @TabelaryczneWartosciQuery = @TabelaryczneWartosciQuery OUTPUT  
								
							--przetwarzanie danych cech obiektu
							IF @Skip = 0
							BEGIN
								SET @Query = '';
								--SET @IloscCechObiektu = (SELECT COUNT(1) FROM #CechyObiektow WHERE RootIndex = @Index;
								SET @CounterCechObiektow = 1;
								
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local','cur2') > 0 
								BEGIN
									 CLOSE cur2
									 DEALLOCATE cur2
								END

								DECLARE cur2 CURSOR LOCAL FOR 
									SELECT AttributeIndex, Id, CechaId, [Priority], UIOrder, LastModifiedOn FROM #CechyObiektow WHERE RootIndex = @Index
								OPEN cur2
								FETCH NEXT FROM cur2 INTO @AttributeIndex, @IdCechyObiektu, @CechaId, @Priority, @UIOrder, @LastModifiedOn
								WHILE @@FETCH_STATUS = 0
								BEGIN						
				--					SET @CechaDlaObiektuIstnieje = 0;
				
									--wyzerowanie zmiennych
									SET @NowaWartoscCechy = 1;
									SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
									SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL;
									SELECT @CechaObiektuWartoscId = NULL, @CechaObowiazujeOd = NULL, @CechaObowiazujeDo = NULL;
									
									SELECT	@ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, 
									@DataObowiazywaniaOd = DataObowiazywaniaOd, @DataObowiazywaniaDo = DataObowiazywaniaDo
									FROM #HistoriaCech WHERE RootIndex = @Index AND AttributeIndex = @AttributeIndex;		
									
									--pobranie danych statusow
									SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
									FROM #StatusyCech WHERE RootIndex = @Index AND AttributeIndex = @AttributeIndex;

--poki co kolumna nie uzywana
SET @DataObowiazywaniaDo = NULL;									
									
									----ustalenie dat obowiazywania na podstawie granic czasowych przedzialow
									--SELECT @PrzedzialCzasowyId = PrzedzialCzasowyId, @NazwaCechy = Nazwa
									--FROM dbo.Cechy
									--WHERE Cecha_Id = @CechaId;
															
									--	EXEC [THB].[PrepareTimePeriods]
									--		@AppDate = @DataModyfikacjiApp,
									--		@TimeIntervalId = @PrzedzialCzasowyId,
									--		@MinDate = @PrzedzialMinDate OUTPUT,
									--		@MaxDate = @PrzedzialMaxDate OUTPUT
									
									EXEC [THB].[PrepareHistoryData]
										@AppDate = @DataModyfikacjiApp,
										@AttributeTypeId = @CechaId,
										@MinDate = @PrzedzialMinDate OUTPUT,
										@MaxDate = @PrzedzialMaxDate OUTPUT																			
									
									--pobranie danych zmian i obowiazywania
									IF @ZmianaOd IS NOT NULL
										SET @ZmianaOdStr = '''' + CONVERT(nvarchar(50), @ZmianaOd, 109) + '''';
									ELSE
										SET @ZmianaOdStr = 'NULL';
										
									IF @ZmianaDo IS NOT NULL
										SET @ZmianaDoStr = '''' + CONVERT(nvarchar(50), @ZmianaDo, 109) + '''';
									ELSE
										SET @ZmianaDoStr = 'NULL';
										
				--zmiana dat na min z przedzialu						
									--IF @DataObowiazywaniaOd IS NOT NULL
									--	SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataObowiazywaniaOd, 109) + '''';
									--ELSE
									--	SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + '''';
										
									IF @PrzedzialMinDate IS NOT NULL
										SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @PrzedzialMinDate, 109) + '''';
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
								
									--sprawdzenie czy cecha posiada juz podana wartosc
									IF @CzyTabela = 0
									BEGIN
										--sprawdzenie czy istnieje juz wpis tej cechy dla tego obiektu
										SET @Query = '
										SELECT @CechaObiektuWartoscId = Id, @CechaObowiazujeOd = ObowiazujeOd, @CechaObowiazujeDo = ObowiazujeDo 
										FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] 
										WHERE Id <> ' + CAST(@IdCechyObiektu AS varchar) + ' AND ObiektId = ' + CAST(@PrzetwarzanyObiektId AS varchar) + 
										' AND CechaID = ' + CAST(@CechaId AS varchar) + ' AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0'
											
										SET @Query += [THB].[PrepareDatesPhrase] (NULL, @DataModyfikacjiApp);								
			
										--PRINT @Query;
										EXECUTE sp_executesql @Query, N'@CechaObiektuWartoscId int OUTPUT, @CechaObowiazujeOd datetime OUTPUT, @CechaObowiazujeDo datetime OUTPUT', 
										@CechaObiektuWartoscId = @CechaObiektuWartoscId OUTPUT, @CechaObowiazujeOd = @CechaObowiazujeOd OUTPUT, @CechaObowiazujeDo = @CechaObowiazujeDo OUTPUT	
						
									END
									ELSE
									BEGIN

										SET @Query = '
											SELECT @AktualnaWartoscCechy = CAST([' + @NazwaCechy + '] AS nvarchar(MAX)) --, @CechaObiektuWartoscId = Id
											FROM [_' + @NazwaTypuObiektu + ']
											WHERE Id = ' + CAST(@PrzetwarzanyObiektId AS varchar)
										
										--PRINT @Query;
									   --EXECUTE sp_executesql @Query, N'@AktualnaWartoscCechy nvarchar(MAX) OUTPUT, @CechaObiektuWartoscId int OUTPUT', 
									--		@AktualnaWartoscCechy = @AktualnaWartoscCechy OUTPUT, @CechaObiektuWartoscId = @CechaObiektuWartoscId OUTPUT	
				
										--IF @AktualnaWartoscCechy IS NOT NULL
										--BEGIN
										--	SELECT @CechaWartoscXML = Value
										--	FROM #WartosciCech
										--	WHERE RootIndex = @Index AND [AttributeIndex] = @CounterCechObiektow;
											
										--	SELECT @WartoscCechy = c.value('./@Value', 'nvarchar(MAX)')
										--	FROM @CechaWartoscXML.nodes('/*') AS t(c)
											
										--	IF @WartoscCechy = @AktualnaWartoscCechy
										--		SET @NowaWartoscCechy = 0;
										--		--SET @CechaDlaObiektuIstnieje = 1;
										--		--FETCH NEXT FROM cur2 INTO @AttributeIndex, @IdCechyObiektu, @CechaId, @Priority, @UIOrder, @LastModifiedOn
										--END
										--ELSE
										--	SET @CechaDlaObiektuIstnieje = 0; 
											
										SET @CechaDlaObiektuIstnieje = 0;
									END											
--SELECT @WartoscCechy, @AktualnaWartoscCechy
--SELECT @CechaDlaObiektuIstnieje	
									IF @CechaObiektuWartoscId IS NOT NULL AND @CechaObiektuWartoscId > 0
										SET @CechaDlaObiektuIstnieje = 1;
									ELSE
									BEGIN
										IF (COALESCE(@CechaObowiazujeDo, @maxDate) >= COALESCE(@DataObowiazywaniaOd, @maxDate)
											 AND COALESCE(@CechaObowiazujeOd, @maxDate) <= COALESCE(@DataObowiazywaniaDo, @maxDate))
											SET @CechaDlaObiektuIstnieje = 0;
										ELSE
											SET @CechaDlaObiektuIstnieje = 1;	
									END	
								
									--sprawdzenie czy istnieje juz dla danego obiektu wpis dotyczacy danej cechy
									IF @CechaDlaObiektuIstnieje = 0
									BEGIN
									
										-- pobranie wartosci dla cechy i odczytanie odpowiedniego typu na jak bedzie konwertowane
										SELECT @CechaWartoscXML = Value
										FROM #WartosciCech
										WHERE RootIndex = @Index AND [AttributeIndex] = @CounterCechObiektow;
--SELECT @CechaWartoscXML AS CechaWartosc
		
										IF @CechaWartoscXML IS NOT NULL
										BEGIN
											SELECT @TypWartosciCechy = c.value('local-name(.)', 'varchar(max)'),
												   @WartoscCechy = c.value('./@Value', 'nvarchar(max)'),
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
																	WHEN 'valxml' THEN '''' + THB.[PrepareXMLValue](@WartoscCechy) + ''''
																	WHEN 'valref' THEN '''' + THB.[PrepareXMLValue](@WartoscCechy) + ''''																							
																END												
										
									
										IF @CzyTabela = 1
										BEGIN
											SET @NazwaKolumny = NULL;
										
											--sprawdzenie czy podana cecha jest faktycznie powiazana z typem obiektu
											SELECT @NazwaKolumny = NazwaKolumny FROM #KolumnyTypuObiektu WHERE CechaId = @CechaId AND TypObiektuId = @TypObiektuId;
										
											IF @NazwaKolumny IS NOT NULL AND @NazwaKolumny <> 'Id' AND @NazwaKolumny <> 'Nazwa' -- AND @NowaWartoscCechy = 1
											BEGIN
												--jesli wstawianie nowego obiektu
												IF @CzyInsert = 1
												BEGIN
													
													SET @TabelaryczneKolumnyQuery += ', [' + @NazwaKolumny + ']';
													SET @TabelaryczneWartosciQuery += ', ' + @WartoscCechyQuery;
													
												END
												ELSE
												BEGIN --jesli update danych obiektu tabelarycznego
													
													SET @TabelaryczneKolumnyQuery += '
														, [' + @NazwaKolumny + '] = ' + @WartoscCechyQuery;
													--SET @TabelaryczneWartosciQuery += '';
												
												END
											END			
										END
										ELSE
										BEGIN
	
											--SELECT @WartoscCechyQuery, @TypWartosciCechy AS TYPWartosci, @WartoscCechy AS WartoscCechy, @IdSlownika AS IdSlownika, @IdElementuSlownika AS IdElementuSlownika
										
											SET @Query = '
											 IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
											 BEGIN
												IF EXISTS (SELECT Id FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] WHERE Id = ' + CAST(@IdCechyObiektu AS varchar) + ')
												BEGIN
													--jesli zgadza sie data ostatniej modyfikacji dla cechy
													IF EXISTS (SELECT Id FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] WHERE Id = ' + CAST(@IdCechyObiektu AS varchar) + ' AND (LastModifiedOn = ''' + CONVERT(varchar, @LastModifiedOn, 109) + ''' OR (LastModifiedOn IS NULL AND CreatedOn = ''' + CONVERT(varchar, @LastModifiedOn, 109) + ''' )))
													BEGIN'
												
													IF @TypWartosciCechy <> 'ValXml' AND @TypWartosciCechy <> 'ValRef' -- AND @TypWartosciCechy <> 'ValString'    AND @TypWartosciCechy <> 'ValDictionary'
													BEGIN
														SET @Query += '												
														IF (SELECT ' + @TypWartosciCechy + ' FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] WHERE Id = ' + CAST(@IdCechyObiektu AS varchar) + ') <> ' + @WartoscCechyQuery + '
														BEGIN'  
													END	
													
													SET @Query += '
															UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
															UIOrder = ' + CAST(@UIOrder AS varchar) + ',
															[Priority] = ' + CAST(ISNULL(@Priority, 2) AS varchar) + ', ';												
														
													--IF @TypWartosciCechy <> 'ValDictionary'
													BEGIN
														SET @Query += '
															' + @TypWartosciCechy + ' = ' + @WartoscCechyQuery + ','
													END												
												
													SET @Query += '
															CechaId = ' + CAST(@CechaId AS varchar) + ',
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
															WHERE Id = ' + CAST(@IdCechyObiektu AS varchar) + ' AND (LastModifiedOn = ''' + CONVERT(varchar, @LastModifiedOn, 109) + ''' OR (LastModifiedOn IS NULL AND CreatedOn = ''' + CONVERT(varchar, @LastModifiedOn, 109) + ''' ))
															
															IF @@ROWCOUNT < 1
															BEGIN
																INSERT INTO #ObiektyKonfliktowe(ID, TypId)
																VALUES(' + CAST(@PrzetwarzanyObiektId AS varchar) + ', ' + CAST(@TypObiektuId AS varchar) + ');
																
																EXEC [THB].[GetErrorMessage] @Nazwa = N''CONCURRENCY_ERROR'', @Grupa = N''PROC_RESULT'', @Wiadomosc = @ERRMSGTmp OUTPUT
																SET @CommitTmp = 0;
															END'
													
												IF @TypWartosciCechy <> 'ValXml' AND @TypWartosciCechy <> 'ValRef' -- AND @TypWartosciCechy <> 'ValString'   AND @TypWartosciCechy <> 'ValDictionary'
												BEGIN
													SET @Query += '												
														END
														ELSE
															PRINT ''Brak zmian wartosci cechy'' ' 
												END	
														
											SET @Query += '
													END
													ELSE
													BEGIN
														INSERT INTO #ObiektyKonfliktowe(ID, TypId)
														VALUES(' + CAST(@PrzetwarzanyObiektId AS varchar) + ', ' + CAST(@TypObiektuId AS varchar) + ');
														
														EXEC [THB].[GetErrorMessage] @Nazwa = N''CONCURRENCY_ERROR'', @Grupa = N''PROC_RESULT'', @Wiadomosc = @ERRMSGTmp OUTPUT
														SET @CommitTmp = 0;
													END			
												END
												ELSE
												BEGIN  

													INSERT INTO [_' + @NazwaTypuObiektu + '_Cechy_Hist] (ObiektId, CechaId, UIOrder, [Priority], CreatedOn, CreatedBy, ValidFrom,
													RealCreatedOn, ObowiazujeOd, ObowiazujeDo, IsStatus, StatusS, StatusSFrom, StatusSFromBy, 
													StatusW, StatusWFrom, StatusWFromBy, StatusP, StatusPFrom, StatusPFromBy, IsAlternativeHistory, IsMainHistFlow'
													
													--IF @TypWartosciCechy <> 'ValDictionary'
														SET @Query += ', ' + @TypWartosciCechy + ') '										
													--ELSE
													--	SET @Query += ')'	
													
													SET @Query += ' VALUES (' + CAST(@PrzetwarzanyObiektId AS varchar) + ', ' + CAST(@CechaId AS varchar) + ', ' + CAST(@UIOrder AS varchar) + ', ' 
														+ CAST(ISNULL(@Priority, 2) AS varchar) + ', ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''', ' + CAST(@UzytkownikId AS varchar) + 
														', ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''', ''' + CONVERT(varchar, @DataModyfikacji, 109) + ''', ' +
														@DataObowiazywaniaOdStr + ', ' + @DataObowiazywaniaDoStr + ', ' + CAST(ISNULL(@IsStatus, 0) AS varchar) + ', ' +
														@StatusSStr + ', CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END,
														CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END, ' + @StatusWStr + ', 
														CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END,
														CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END, ' + @StatusPStr + ',
														CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END,
														CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END,
														0, 1'
														
													--IF @TypWartosciCechy <> 'ValDictionary'
														SET @Query += ', ' + @WartoscCechyQuery + ') '										
													--ELSE
													--	SET @Query += ');'
														
											SET @Query += '													
												END
											END
											'
										
											PRINT @Query;
											EXECUTE sp_executesql @Query, N'@PrzetwarzanyObiektId int OUTPUT, @ERRMSGTmp nvarchar(MAX) OUTPUT, @CommitTmp bit OUTPUT', @PrzetwarzanyObiektId = @PrzetwarzanyObiektId OUTPUT, @ERRMSGTmp = @ERRMSG OUTPUT, @CommitTmp = @Commit OUTPUT
										END
									END
				------------>>		
									ELSE
									BEGIN
										INSERT INTO #ObiektyNieUnikalne(ID, TypId)
										VALUES(@PrzetwarzanyObiektId, @TypObiektuId);
										
										EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Cecha dla obiektu' , @Wiadomosc = @ERRMSG OUTPUT
										SET @Commit = 0;
									END
								
									SET @CounterCechObiektow += 1;
									FETCH NEXT FROM cur2 INTO @AttributeIndex, @IdCechyObiektu, @CechaId, @Priority, @UIOrder, @LastModifiedOn
								END
								CLOSE cur2
								DEALLOCATE cur2
							
								--jesli obiekt tabelaryczny to robimy dopiero teraz insert danych
								IF @CzyTabela = 1
								BEGIN
									
									--wylaczenie trigerow na update
									SET @Query = 'DISABLE TRIGGER dbo.[WartoscZmiany_' + @NazwaTypuObiektu + '_UPDATE] ON dbo.[_' + @NazwaTypuObiektu + ']';
									EXECUTE sp_executesql @Query									
									
									IF @CzyInsert = 1
									BEGIN
										SET @TabelaryczneKolumnyQuery += ')';
										SET @TabelaryczneWartosciQuery += ')';
									END
									
									SET @Query = @TabelaryczneKolumnyQuery + @TabelaryczneWartosciQuery;
							
									--PRINT @Query
									EXECUTE sp_executesql @Query
									
									IF @@ROWCOUNT > 0
									BEGIN
										
										IF @CzyInsert = 1
											SET @PrzetwarzanyObiektId = @@IDENTITY;
										ELSE
											SET @PrzetwarzanyObiektId = @Id;
										
										INSERT INTO #IDZmienionych (ID, TypObiektuId) VALUES(@PrzetwarzanyObiektId, @TypObiektuId);
									END
									
									--wlaczenie trigerow na update
									SET @Query = 'ENABLE TRIGGER dbo.[WartoscZmiany_' + @NazwaTypuObiektu + '_UPDATE] ON dbo.[_' + @NazwaTypuObiektu + ']';
									EXECUTE sp_executesql @Query
									
								END
							END
						END
						ELSE --typ obiektu o podanym Id nie istnieje
						BEGIN
							SET @ERRMSG = 'Błąd. Typ obiektu o podanym Id (' + CAST(@TypObiektuId AS varchar) + ') nie istnieje.';
							SET @Commit = 0;
							BREAK;
						END
						
						FETCH NEXT FROM cur INTO @Index, @Id, @TypObiektuId, @Nazwa, @LastModifiedOn
					
					END
					CLOSE cur
					DEALLOCATE cur
					
					--SELECT * FROM #IDZmienionych
					--SELECT * FROM #IDZmienionychWpisowSlownika				
					--SELECT DISTINCT Id, TypId FROM #ObiektyKonfliktowe;
					--SELECT DISTINCT Id, TypId FROM #ObiektyNieUnikalne;
					
					--pobieranie danych dla obiektow konfliktowych
					INSERT INTO #ObiektyZle(ID, TypId)
					(
						SELECT ID, TypId FROM #ObiektyKonfliktowe
						UNION ALL
						SELECT ID, TypId FROM #ObiektyNieUnikalne
					)
					
					--SELECT DISTINCT Id AS ZleID, TypId AS ZleTyp FROM #ObiektyZle;
					
					-- pobranie danych obiektow konfliktowych
					IF (SELECT COUNT(1) FROM #ObiektyZle) > 0
					BEGIN
					
						IF Cursor_Status('local','cur') > 0 
						BEGIN
							 CLOSE cur
							 DEALLOCATE cur
						END
					
						DECLARE cur CURSOR LOCAL FOR 
							SELECT DISTINCT TypId FROM #ObiektyZle
						OPEN cur
						FETCH NEXT FROM cur INTO @TypObiektuId
						WHILE @@FETCH_STATUS = 0
						BEGIN
							--pobranie nazwy typu obiektu po Id typu
							SELECT @NazwaTypuObiektu = t.Nazwa 
							FROM dbo.TypObiektu t 
							WHERE t.TypObiekt_ID = @TypObiektuId
							
							--pobieranie danych obiektow to tabel tymczasowych
							SET @query = N'
								INSERT INTO #ObiektyDaneZle (TypObiektuId, Id, Nazwa, IsStatus,[StatusS],[StatusSFrom],[StatusSTo],[StatusSFromBy],
									[StatusSToBy], [StatusW], [StatusWFrom], [StatusWTo], [StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],[StatusPTo],
									[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],[ValidFrom],[ValidTo],
									[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],[CreatedBy],[LastModifiedOn],
									[LastModifiedBy],[IsAlternativeHistory],[IsMainHistFlow])
								SELECT ' + CAST(@TypObiektuId AS varchar) + ', Id, Nazwa, IsStatus,[StatusS],[StatusSFrom],[StatusSTo],[StatusSFromBy],
									[StatusSToBy], [StatusW], [StatusWFrom], [StatusWTo], [StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],[StatusPTo],
									[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],[ValidFrom],[ValidTo],
									[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],[CreatedBy],[LastModifiedOn],
									[LastModifiedBy],[IsAlternativeHistory],[IsMainHistFlow]
								FROM [dbo].[_' + @NazwaTypuObiektu + '] 
								WHERE IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0 AND Id IN (SELECT Id FROM #ObiektyZle WHERE TypId = ' + CAST(@TypObiektuId AS varchar) + ')';
							
								--print @query
								EXECUTE sp_executesql @query;
							
							IF @CzyTabela = 0
							BEGIN	
								SET @query = N'
									INSERT INTO #CechyObiektuDaneZle(TypObiektuId, ObiektId, Id, CechaId, TypCechyId, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
										[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
										[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
										[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
										[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow])
									SELECT ' + CAST(@TypObiektuId AS varchar) + ', ch.ObiektId, ch.Id, ch.CechaID, c.TypID, c.CzySlownik, ch.ColumnsSet, ch.ValString, ch.[IsStatus], ch.[StatusS], ch.[StatusSFrom],
										ch.[StatusSTo], ch.[StatusSFromBy], ch.[StatusSToBy], ch.[StatusW], ch.[StatusWFrom], ch.[StatusWTo], ch.[StatusWFromBy], ch.[StatusWToBy], ch.[StatusP],
										ch.[StatusPFrom], ch.[StatusPTo], ch.[StatusPFromBy], ch.[StatusPToBy], ch.[ObowiazujeOd], ch.[ObowiazujeDo], ch.[IsValid],
										ch.[ValidFrom], ch.[ValidTo], ch.[IsDeleted], ch.[DeletedFrom], ch.[DeletedBy], ch.[CreatedOn],
										ch.[CreatedBy], ch.[LastModifiedOn], ch.[LastModifiedBy], ch.[Priority], ch.[UIOrder], ch.[IsAlternativeHistory], ch.[IsMainHistFlow]
									FROM [dbo].[_' + @NazwaTypuObiektu + '_Cechy_Hist] ch
									JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch.CechaID)
									WHERE ObiektId IN (SELECT Id FROM #ObiektyZle WHERE TypId = ' + CAST(@TypObiektuId AS varchar) + ')'
									
								--ch.IdArch IS NULL	AND ch.IsValid = 1 AND ch.IsDeleted = 0 AND
								
								SET @Query += [THB].[PrepareDatesPhrase] ('c', @DataModyfikacjiApp);
								SET @Query += [THB].[PrepareDatesPhrase] ('ch', @DataModyfikacjiApp);
							
								-- pobranie Id cech do ktorych uzytkownik ma dostep
								EXEC [THB].[GetUserAttributeTypes]
									@Alias = 'ch',
									@DataProgramu = @DataProgramu,
									@UserId = @UzytkownikID,
									@BranchId = @BranzaId,
									@AtributeTypesWhere = @CechyWidoczneDlaUzytkownika OUTPUT
								
								--filtracja po cechach ktore moze widziec uzytkownik
								IF @CechyWidoczneDlaUzytkownika IS NOT NULL
									SET @query += @CechyWidoczneDlaUzytkownika;					
						
								PRINT @query
								EXECUTE sp_executesql @query;
							END 

							FETCH NEXT FROM cur INTO @TypObiektuId
						END
						CLOSE cur;
						DEALLOCATE cur;
					
					--SELECT * FROM #ObiektyDaneZle
					--SELECT * FROM #CechyObiektuDaneZle
					
					--zwrocenie danych elementow konfliktowych
					IF (SELECT COUNT(1) FROM #ObiektyKonfliktowe) > 0
					BEGIN
					
						IF Cursor_Status('local','cur') > 0 
						BEGIN
							 CLOSE cur
							 DEALLOCATE cur
						END
					
						DECLARE cur CURSOR LOCAL FOR 
							SELECT DISTINCT Id, TypId FROM #ObiektyKonfliktowe
						OPEN cur
						FETCH NEXT FROM cur INTO @Id, @TypObiektuId
						WHILE @@FETCH_STATUS = 0
						BEGIN
						
							SET @query = 'SET @xmlErrorConcurrencyTmp = ISNULL(CAST((SELECT obj.[Id] AS "@Id"
											, ' + CAST(@TypObiektuId AS varchar) + ' AS "@TypeId"
											,obj.[Nazwa] AS "@Name"
											,obj.[IsDeleted] AS "@IsDeleted"
											,obj.[DeletedFrom] AS "@DeletedFrom"
											,obj.[DeletedBy] AS "@DeletedBy"
											,obj.[CreatedOn] AS "@CreatedOn"
											,obj.[CreatedBy] AS "@CreatedBy"
											,obj.[LastModifiedBy] AS "@LastModifiedBy"
											,ISNULL(obj.[LastModifiedOn], obj.[CreatedOn]) AS "@LastModifiedOn"
											,obj.[ObowiazujeOd] AS "History/@EffectiveFrom"
											,obj.[ObowiazujeDo] AS "History/@EffectiveTo"
											,obj.[IsStatus] AS "Statuses/@IsStatus"
											,obj.[StatusS] AS "Statuses/@StatusS"
											,obj.[StatusSFrom] AS "Statuses/@StatusSFrom"
											,obj.[StatusSTo] AS "Statuses/@StatusSTo"
											,obj.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
											,obj.[StatusSToBy] AS "Statuses/@StatusSToBy"
											,obj.[StatusW] AS "Statuses/@StatusW"
											,obj.[StatusWFrom] AS "Statuses/@StatusWFrom"
											,obj.[StatusWTo] AS "Statuses/@StatusWTo"
											,obj.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
											,obj.[StatusWToBy] AS "Statuses/@StatusWToBy"
											,obj.[StatusP] AS "Statuses/@StatusP"
											,obj.[StatusPFrom] AS "Statuses/@StatusPFrom"
											,obj.[StatusPTo] AS "Statuses/@StatusPTo"
											,obj.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
											,obj.[StatusPToBy] AS "Statuses/@StatusPToBy"'
											
											IF Cursor_Status('local','cur3') > 0 
											BEGIN
												 CLOSE cur3
												 DEALLOCATE cur3
											END
							
											--pobieranie danych podwezlow, cech obiektu
											DECLARE cur3 CURSOR LOCAL FOR 
												SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory  FROM #CechyObiektuDaneZle WHERE TypObiektuId = @TypObiektuId AND ObiektId = @Id
											OPEN cur3
											FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory 
											WHILE @@FETCH_STATUS = 0
											BEGIN
												
												SET @query += ', (SELECT c.[Id] AS "@Id"
													,c.[CechaID] AS "@TypeId"
													,c.[Priority] AS "@Priority"
													,c.[UIOrder] AS "@UIOrder"								
													,c.[IsDeleted] AS "@IsDeleted"
													,c.[DeletedFrom] AS "@DeletedFrom"
													,c.[DeletedBy] AS "@DeletedBy"
													,c.[CreatedOn] AS "@CreatedOn"
													,c.[CreatedBy] AS "@CreatedBy"
													,c.[LastModifiedBy] AS "@LastModifiedBy"
													,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
													,c.[ObowiazujeOd] AS "History/@EffectiveFrom"
													,c.[ObowiazujeDo] AS "History/@EffectiveTo"
													,ISNULL(c.[IsMainHistFlow], 0) AS "History/@IsMainHistFlow"
													,ISNULL(c.[IsAlternativeHistory], 0) AS "History/@IsAlternativeHistory"
													,c.[IsStatus] AS "Statuses/@IsStatus"
													,c.[StatusS] AS "Statuses/@StatusS"
													,c.[StatusSFrom] AS "Statuses/@StatusSFrom"
													,c.[StatusSTo] AS "Statuses/@StatusSTo"
													,c.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
													,c.[StatusSToBy] AS "Statuses/@StatusSToBy"
													,c.[StatusW] AS "Statuses/@StatusW"
													,c.[StatusWFrom] AS "Statuses/@StatusWFrom"
													,c.[StatusWTo] AS "Statuses/@StatusWTo"
													,c.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
													,c.[StatusWToBy] AS "Statuses/@StatusWToBy"
													,c.[StatusP] AS "Statuses/@StatusP"
													,c.[StatusPFrom] AS "Statuses/@StatusPFrom"
													,c.[StatusPTo] AS "Statuses/@StatusPTo"
													,c.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
													,c.[StatusPToBy] AS "Statuses/@StatusPToBy"'
													
												-- przygotowanie danych/wasrtosci cechy
												IF @XmlSparse IS NOT NULL
												BEGIN								
													SELECT	@CechaTyp = C.value('local-name(.)', 'varchar(max)')
													,@CechaWartosc = C.value('text()[1]', 'nvarchar(200)')
													FROM @XmlSparse.nodes('/*') AS t(c)
												END
												ELSE
												BEGIN
													IF @WartoscString IS NOT NULL
													BEGIN
														SET @CechaWartosc = @WartoscString;
														SET @CechaTyp = 'ValString';
													END								
												END								
								
												IF @CechaWartosc IS NOT NULL AND @CechaTyp IS NOT NULL
												BEGIN
													
													--jesli cecha nie posiada wartosci slownikowej
													IF @CzySlownik = 0 AND @CechaTyp <> 'ValDictionary'
													BEGIN
														IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
															SET @query += ', ''' + @CechaWartosc + ''' AS "' + @CechaTyp + '/@Value"'
														ELSE
														BEGIN
														
															SET @query += ', ( SELECT ''' + @CechaWartosc + ''' AS "@Value"
																		,( SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
																			,c2.[ZmianaDo] AS "@ChangeTo"
																			,c2.[ObowiazujeOd] AS "@EffectiveFrom"
																			,c2.[ObowiazujeDo] AS "@EffectiveTo"
																			,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																			FROM #CechyObiektuDaneZle c2
																			WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																				+ ' AND c2.ObiektId = ' + CAST(@Id AS varchar) + '
																			FOR XML PATH(''History''), TYPE)
																		FOR XML PATH(''' + @CechaTyp + '''), TYPE)'
														END										
													END
													ELSE
													BEGIN
														
														-- pobranie nazwy slownika skojarzonego z cecha
														SET @NazwaSlownika = (SELECT Nazwa FROM [Slowniki] WHERE Id = @CechaTypId);
														
														IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
														BEGIN
															SET @query += ', ' + CAST(@CechaId AS varchar) + ' AS "ValDictionary/@ElementId"
																	, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"';
																	
															IF @NazwaSlownika IS NOT NULL
																SET @query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "ValDictionary/@DisplayValue"'
														END
														ELSE
														BEGIN
															SET @query += ', ( SELECT' + CAST(@CechaId AS varchar) + ' AS "@ElementId"
																		, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"'
																		
															IF @NazwaSlownika IS NOT NULL
																SET @query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "@DisplayValue"'
												
															SET @query += '	, (SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
																			,c2.[ZmianaDo] AS "@ChangeTo"
																			,c2.[ObowiazujeOd] AS "@EffectiveFrom"
																			,c2.[ObowiazujeDo] AS "@EffectiveTo"
																			,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																			FROM #CechyObiektuDaneZle c2
																				WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																				+ ' AND c2.ObiektId = ' + CAST(@Id AS varchar) + '
																			FOR XML PATH(''History''), TYPE)
																		)
																		FOR XML PATH(''ValDictionary''), TYPE)'											
														END
													END																								
												END								
										-- koniec wartosci cech	
												SET @query += '	
													FROM #CechyObiektuDaneZle c
													WHERE c.[Id] = ' + CAST(@CechaObiektuId AS varchar) + '
													FOR XML PATH(''Attribute''), TYPE
													)'
													
												FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory								
											END
											CLOSE cur3;
											DEALLOCATE cur3;							

										SET @query += ' 
										 FROM #ObiektyDaneZle obj 
										 WHERE obj.Id = ' + CAST(@Id AS varchar) + ' AND TypObiektuId = ' + CAST(@TypObiektuId AS varchar) + '
										 FOR XML PATH(''Unit'')
										)
										AS nvarchar(MAX)), '''')' 	
								
								--PRINT @query		
								EXECUTE sp_executesql @query, N'@xmlErrorConcurrencyTmp nvarchar(MAX) OUTPUT', @xmlErrorConcurrencyTmp = @TmpDaneOb OUTPUT							
								SET @xmlErrorConcurrency += @TmpDaneOb			

							FETCH NEXT FROM cur INTO @Id, @TypObiektuId
						END
						
						CLOSE cur;
						DEALLOCATE cur;
					END
					
					--zwrocenie danych elementow nie unikalnych
					IF (SELECT COUNT(1) FROM #ObiektyNieUnikalne) > 0
					BEGIN
					
						IF Cursor_Status('local','cur') > 0 
						BEGIN
							 CLOSE cur
							 DEALLOCATE cur
						END
					
						DECLARE cur CURSOR LOCAL FOR 
							SELECT DISTINCT Id, TypId FROM #ObiektyNieUnikalne
						OPEN cur
						FETCH NEXT FROM cur INTO @Id, @TypObiektuId
						WHILE @@FETCH_STATUS = 0
						BEGIN
						
							SET @query = 'SET @xmlErrorsUniqueTmp = ISNULL(CAST((SELECT obj.[Id] AS "@Id"
											, ' + CAST(@TypObiektuId AS varchar) + ' AS "@TypeId"
											,obj.[Nazwa] AS "@Name"
											,obj.[IsDeleted] AS "@IsDeleted"
											,obj.[DeletedFrom] AS "@DeletedFrom"
											,obj.[DeletedBy] AS "@DeletedBy"
											,obj.[CreatedOn] AS "@CreatedOn"
											,obj.[CreatedBy] AS "@CreatedBy"
											,obj.[LastModifiedBy] AS "@LastModifiedBy"
											,ISNULL(obj.[LastModifiedOn], obj.[CreatedOn]) AS "@LastModifiedOn"
											,obj.[ObowiazujeOd] AS "History/@EffectiveFrom"
											,obj.[ObowiazujeDo] AS "History/@EffectiveTo"
											,obj.[IsStatus] AS "Statuses/@IsStatus"
											,obj.[StatusS] AS "Statuses/@StatusS"
											,obj.[StatusSFrom] AS "Statuses/@StatusSFrom"
											,obj.[StatusSTo] AS "Statuses/@StatusSTo"
											,obj.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
											,obj.[StatusSToBy] AS "Statuses/@StatusSToBy"
											,obj.[StatusW] AS "Statuses/@StatusW"
											,obj.[StatusWFrom] AS "Statuses/@StatusWFrom"
											,obj.[StatusWTo] AS "Statuses/@StatusWTo"
											,obj.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
											,obj.[StatusWToBy] AS "Statuses/@StatusWToBy"
											,obj.[StatusP] AS "Statuses/@StatusP"
											,obj.[StatusPFrom] AS "Statuses/@StatusPFrom"
											,obj.[StatusPTo] AS "Statuses/@StatusPTo"
											,obj.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
											,obj.[StatusPToBy] AS "Statuses/@StatusPToBy"'
											
											IF Cursor_Status('local','cur3') > 0 
											BEGIN
												 CLOSE cur3
												 DEALLOCATE cur3
											END
							
											--pobieranie danych podwezlow, cech obiektu
											DECLARE cur3 CURSOR LOCAL FOR 
												SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory  FROM #CechyObiektuDaneZle WHERE TypObiektuId = @TypObiektuId AND ObiektId = @Id
											OPEN cur3
											FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory 
											WHILE @@FETCH_STATUS = 0
											BEGIN
												
												SET @query += ', (SELECT c.[Id] AS "@Id"
													,c.[CechaID] AS "@TypeId"
													,c.[Priority] AS "@Priority"
													,c.[UIOrder] AS "@UIOrder"								
													,c.[IsDeleted] AS "@IsDeleted"
													,c.[DeletedFrom] AS "@DeletedFrom"
													,c.[DeletedBy] AS "@DeletedBy"
													,c.[CreatedOn] AS "@CreatedOn"
													,c.[CreatedBy] AS "@CreatedBy"
													,c.[LastModifiedBy] AS "@LastModifiedBy"
													,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
													,c.[ObowiazujeOd] AS "History/@EffectiveFrom"
													,c.[ObowiazujeDo] AS "History/@EffectiveTo"
													,ISNULL(c.[IsMainHistFlow], 0) AS "History/@IsMainHistFlow"
													,ISNULL(c.[IsAlternativeHistory], 0) AS "History/@IsAlternativeHistory"
													,c.[IsStatus] AS "Statuses/@IsStatus"
													,c.[StatusS] AS "Statuses/@StatusS"
													,c.[StatusSFrom] AS "Statuses/@StatusSFrom"
													,c.[StatusSTo] AS "Statuses/@StatusSTo"
													,c.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
													,c.[StatusSToBy] AS "Statuses/@StatusSToBy"
													,c.[StatusW] AS "Statuses/@StatusW"
													,c.[StatusWFrom] AS "Statuses/@StatusWFrom"
													,c.[StatusWTo] AS "Statuses/@StatusWTo"
													,c.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
													,c.[StatusWToBy] AS "Statuses/@StatusWToBy"
													,c.[StatusP] AS "Statuses/@StatusP"
													,c.[StatusPFrom] AS "Statuses/@StatusPFrom"
													,c.[StatusPTo] AS "Statuses/@StatusPTo"
													,c.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
													,c.[StatusPToBy] AS "Statuses/@StatusPToBy"'
													
												-- przygotowanie danych/wasrtosci cechy
												IF @XmlSparse IS NOT NULL
												BEGIN								
													SELECT	@CechaTyp = C.value('local-name(.)', 'varchar(max)')
													,@CechaWartosc = C.value('text()[1]', 'nvarchar(200)')
													FROM @XmlSparse.nodes('/*') AS t(c)
												END
												ELSE
												BEGIN
													IF @WartoscString IS NOT NULL
													BEGIN
														SET @CechaWartosc = @WartoscString;
														SET @CechaTyp = 'ValString';
													END								
												END								
								
												IF @CechaWartosc IS NOT NULL AND @CechaTyp IS NOT NULL
												BEGIN
													
													--jesli cecha nie ma wartosci slownikowej
													IF @CzySlownik = 0 AND @CechaTyp <> 'ValDictionary'
													BEGIN
														IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
															SET @query += ', ''' + @CechaWartosc + ''' AS "' + @CechaTyp + '/@Value"'
														ELSE
														BEGIN
														
															SET @query += ', ( SELECT ''' + @CechaWartosc + ''' AS "@Value"
																		,( SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
																			,c2.[ZmianaDo] AS "@ChangeTo"
																			,c2.[ObowiazujeOd] AS "@EffectiveFrom"
																			,c2.[ObowiazujeDo] AS "@EffectiveTo"
																			,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																			FROM #CechyObiektuDaneZle c2
																			WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																				+ ' AND c2.ObiektId = ' + CAST(@Id AS varchar) + '
																			FOR XML PATH(''History''), TYPE)
																		FOR XML PATH(''' + @CechaTyp + '''), TYPE)'
														END										
													END
													ELSE
													BEGIN
														
														-- pobranie nazwy slownika skojarzonego z cecha
														SET @NazwaSlownika = (SELECT Nazwa FROM [Slowniki] WHERE Id = @CechaTypId);
														
														IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
														BEGIN
															SET @query += ', ' + CAST(@CechaId AS varchar) + ' AS "ValDictionary/@ElementId"
																	, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"';
																	
															IF @NazwaSlownika IS NOT NULL
																SET @query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "ValDictionary/@DisplayValue"'
														END
														ELSE
														BEGIN
															SET @query += ', ( SELECT' + CAST(@CechaId AS varchar) + ' AS "@ElementId"
																		, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"'
																		
															IF @NazwaSlownika IS NOT NULL
																SET @query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "@DisplayValue"'
												
															SET @query += '	, (SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
																			,c2.[ZmianaDo] AS "@ChangeTo"
																			,c2.[ObowiazujeOd] AS "@EffectiveFrom"
																			,c2.[ObowiazujeDo] AS "@EffectiveTo"
																			,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																			FROM #CechyObiektuDaneZle c2
																				WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																				+ ' AND c2.ObiektId = ' + CAST(@Id AS varchar) + '
																			FOR XML PATH(''History''), TYPE)
																		)
																		FOR XML PATH(''ValDictionary''), TYPE)'											
														END
													END																								
												END								
										-- koniec wartosci cech	
												SET @query += '	
													FROM #CechyObiektuDaneZle c
													WHERE c.[Id] = ' + CAST(@CechaObiektuId AS varchar) + '
													FOR XML PATH(''Attribute''), TYPE
													)'
													
												FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory								
											END
											CLOSE cur3;
											DEALLOCATE cur3;							

										SET @query += ' 
										 FROM #ObiektyDaneZle obj 
										 WHERE obj.Id = ' + CAST(@Id AS varchar) + ' AND TypObiektuId = ' + CAST(@TypObiektuId AS varchar) + '
										 FOR XML PATH(''Unit'')
										)
										AS nvarchar(MAX)), '''')' 	
								
								--PRINT @query		
								EXECUTE sp_executesql @query, N'@xmlErrorsUniqueTmp nvarchar(MAX) OUTPUT', @xmlErrorsUniqueTmp = @TmpDaneOb OUTPUT							
								SET @xmlErrorsUnique += @TmpDaneOb			

							FETCH NEXT FROM cur INTO @Id, @TypObiektuId
						END
						
						CLOSE cur;
						DEALLOCATE cur;
					END
					
					END
					
					SET @xmlResponse = (SELECT TOP 1
						(SELECT sl.ID AS '@Id',
							'Unit' AS '@EntityType'
							FROM #IDZmienionych sl
							GROUP BY sl.Id, sl.TypObiektuId
							ORDER BY MIN(sl.Lp)							
							FOR XML PATH('Ref'), ROOT('Value'), TYPE
							)
						FROM #IDZmienionych
						FOR XML PATH('Result'));
			
					IF @Commit = 1
						COMMIT TRAN T1_Units_Save
					ELSE
						ROLLBACK TRAN T1_Units_Save
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Units_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Units_Save', @Wiadomosc = @ERRMSG OUTPUT	
		END
			
	END TRY
	BEGIN CATCH
		

		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_Units_Save
		END
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Units_Save"';
	
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
	IF OBJECT_ID('tempdb..#KolumnyTypuObiektu') IS NOT NULL
		DROP TABLE #KolumnyTypuObiektu
	
	IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
		DROP TABLE #Obiekty
		
	IF OBJECT_ID('tempdb..#CechyObiektow') IS NOT NULL
		DROP TABLE #CechyObiektow
		
	IF OBJECT_ID('tempdb..#WartosciCech') IS NOT NULL
		DROP TABLE #WartosciCech
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#ObiektyKonfliktowe') IS NOT NULL
		DROP TABLE #ObiektyKonfliktowe
	
	IF OBJECT_ID('tempdb..#ObiektyNieUnikalne') IS NOT NULL
		DROP TABLE #ObiektyNieUnikalne
		
	IF OBJECT_ID('tempdb..#ObiektyZle') IS NOT NULL
		DROP TABLE #ObiektyZle
	
	IF OBJECT_ID('tempdb..#ObiektyDaneZle') IS NOT NULL
		DROP TABLE #ObiektyDaneZle
		
	IF OBJECT_ID('tempdb..#CechyObiektuDaneZle') IS NOT NULL
		DROP TABLE #CechyObiektuDaneZle
		
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
	
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
		
	IF OBJECT_ID('tempdb..#HistoriaCech') IS NOT NULL
		DROP TABLE #HistoriaCech
	
	IF OBJECT_ID('tempdb..#StatusyCech') IS NOT NULL
		DROP TABLE #StatusyCech
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
