-- =============================================
-- Author:		DK
-- Create date: 2012-03-27
-- Last modified on: 2013-02-22
-- Description:	Pobiera dane z tabeli relacje dla relacji o podanych ID.

-- XML wejsciowy w postaci:

	--<Request RequestType="Relations_GetByIds" UserId="1" AppDate="2012-09-20T12:45:32" GetFullColumnsData="false">
 --       <Ref Id="1" EntityType="Relation" />
 --       <Ref Id="2" EntityType="Relation" />
 --       <Ref Id="3" EntityType="Relation" />
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Relations_GetByIds" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="2.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		
	--<!-- przy <Request .. GetFullColumnsData="false" .. ExpandNestedValues="true" ..  /> -->
	--<Relation Id="2" TypeId="3" IsOuter="false" SourceId="0" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<ObjectLeft Id="3" TypeId="5"/>
	--		<ObjectRight Id="5" TypeId="2"/>
	--		<Attribute Id="4" TypeId="66" Priority="0" UIOrder="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<ValDecimal Value="46.09"/>
	--		</Attribute>
	--		<Attribute Id="4" TypeId="66" Priority="0" UIOrder="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<ValDictionary Id="5" ElementId="23" DisplayValue="Smok"/>
	--		</Attribute>
	--	</Relation>
		
	--<!-- przy <Request .. GetFullColumnsData="false" .. ExpandNestedValues="false" ..   /> -->
	--<Relation Id="2" TypeId="3" IsOuter="false" SourceId="0" LastModifiedOn="2012-02-09T12:12:12.121Z" >
	--		<ObjectLeft Id="3" TypeId="5"/>
	--		<ObjectRight Id="5" TypeId="2"/>
	--	</Relation>

	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Relations_GetByIds]
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
		@PobierzWszystieDane bit = 0,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@RozwijajPodwezly bit = 0,
		@MaUprawnienia bit = 0,
		@IdRelacji int,
		@xml_tmp nvarchar(MAX) = '',		
		@CzySlownik bit,
		@XmlSparse xml,
		@CechaTyp varchar(30),
		@CechaTypId int,
		@WartoscString nvarchar(MAX),
		@CechaWartosc nvarchar(MAX),
		@CechaWartoscXML nvarchar(MAX),		
		@CechaWartoscRef nvarchar(300),	
		@CechaObiektuId int,
		@CechaId int,
		@CechyWidoczneDlaUzytkownika nvarchar(MAX),
		@NazwaSlownika nvarchar(500),
		@CechaHasAlternativeHistory bit = 0,
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@IdArchRelacji int,
		@CechaStatusS int,
		@CechaCzyDanaOsobowa bit,
		@CechaIsStatus bit,
		@QueryDlaCechy nvarchar(MAX),
		@DateFromColumnName nvarchar(100),
		@ValRefAttribute nvarchar(MAX)
		
		IF OBJECT_ID('tempdb..#IDDoPobrania') IS NOT NULL
			DROP TABLE #IDDoPobrania
			
		IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
			DROP TABLE #Relacje
		
		IF OBJECT_ID('tempdb..#CechyRelacji') IS NOT NULL
			DROP TABLE #CechyRelacji
			
		IF OBJECT_ID('tempdb..#CechyTypuRelacji') IS NOT NULL
			DROP TABLE #CechyTypuRelacji
			
		IF OBJECT_ID('tempdb..#CechyRelacjiId') IS NOT NULL
			DROP TABLE #CechyRelacjiId
			
		IF OBJECT_ID('tempdb..#TypRelacjiCechy') IS NOT NULL
			DROP TABLE #TypRelacjiCechy		
		
		CREATE TABLE #Relacje (Id int, IdArch int);
		CREATE TABLE #IDDoPobrania (ID int);
		CREATE TABLE #CechyTypuRelacji(CechaId int, TypRelacjiId int, [Priority] smallint, UIOrder smallint);
		CREATE TABLE #CechyRelacjiId(Id int);
		CREATE TABLE #TypRelacjiCechy(Id int);
	
		CREATE TABLE #CechyRelacji(Id int, RelacjaId int, CechaId int, TypCechyId int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), [IsStatus] bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,
		[StatusSFromBy] int,[StatusSToBy] int,[StatusW] int,[StatusWFrom] datetime,[StatusWTo] datetime,[StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,
		[StatusPTo] datetime,[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,
		[ValidFrom] datetime,[ValidTo] datetime,[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,
		[CreatedBy] int,[LastModifiedOn] datetime,[LastModifiedBy] int,[Priority] smallint,[UIOrder] smallint, [IsAlternativeHistory] bit,[IsMainHistFlow] bit);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_GetByIds', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
			
			--wyciaganie ID elenentow do pobrania
			INSERT INTO #IDDoPobrania(Id)
			SELECT	C.value('./@Id', 'int')
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(100)') = 'Relation' 
		
			IF @RequestType = 'Relations_GetByIds'
			BEGIN		
				
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
					
				-- pobranie Id cech do ktorych uzytkownik ma dostep
				EXEC [THB].[GetUserAttributeTypes]
					@Alias = 'ch',
					@DataProgramu = @DataProgramu,
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@AtributeTypesWhere = @CechyWidoczneDlaUzytkownika OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN		
					BEGIN TRY
					
					--pobranie danych Id pasujacych relacji do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Relacje (Id, IdArch)
							SELECT allData.Id, allData.IdArch FROM
							(
								SELECT r.Id, r.IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(r.IdArch, r.Id) ORDER BY r.Id ASC) AS Rn
								FROM [dbo].[Relacje] r
								INNER JOIN
								(
									SELECT ISNULL(r2.IdArch, r2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, r2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Relacje] r2								 
									INNER JOIN 
									(
										SELECT ISNULL(r3.IdArch, r3.Id) AS RowID, MAX(r3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Relacje] r3
										WHERE (r3.Id IN (SELECT Id FROM #IDDoPobrania) OR r3.IdArch IN (SELECT Id FROM #IDDoPobrania))'									
									
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('r3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('r3', @AppDate);					
									
					SET @Query += '
										GROUP BY ISNULL(r3.IdArch, r3.Id)
									) latest
									ON ISNULL(r2.IdArch, r2.Id) = latest.RowID AND r2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(r2.IdArch, r2.Id), r2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(r.IdArch, r.Id) = latestWithMaxDate.RowID AND r.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND r.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
		
--SELECT * FROM #RelacjeTmp
--SELECT * FROM #Relacje;			
					
					IF @RozwijajPodwezly = 1
					BEGIN
						
						--pobranie cech typu relacji							
						SET @Query = '
								INSERT INTO #TypRelacjiCechy(Id)
								SELECT allData.Id FROM
								(
									SELECT trc.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(trc.IdArch, trc.Id) ORDER BY trc.Id ASC) AS Rn
									FROM [dbo].[TypRelacji_Cechy] trc
									INNER JOIN
									(
										SELECT ISNULL(trc2.IdArch, trc2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, trc2.' + @DateFromColumnName + ' AS MaxDate
										FROM [dbo].[TypRelacji_Cechy] trc2								 
										INNER JOIN 
										(
											SELECT ISNULL(trc3.IdArch, trc3.Id) AS RowID, MAX(trc3.' + @DateFromColumnName + ') AS MaxDate
											FROM [dbo].[TypRelacji_Cechy] trc3
											WHERE trc3.TypRelacji_Id IN (SELECT DISTINCT TypRelacji_ID FROM dbo.Relacje WHERE Id IN (SELECT Id FROM #Relacje))'									
										
						--dodanie frazy statusow na filtracje jesli trzeba
						SET @Query += [THB].[PrepareStatusesPhrase] ('trc3', @StatusS, @StatusP, @StatusW);
						
						----filtracja po cechach ktore moze widziec uzytkownik
						--IF @CechyWidoczneDlaUzytkownika IS NOT NULL
						--	SET @Query += @CechyWidoczneDlaUzytkownika;
						
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhrase] ('trc3', @AppDate);					
										
						SET @Query += '
											GROUP BY ISNULL(trc3.IdArch, trc3.Id)
										) latest
										ON ISNULL(trc2.IdArch, trc2.Id) = latest.RowID AND trc2.' + @DateFromColumnName + ' = latest.MaxDate
										GROUP BY ISNULL(trc2.IdArch, trc2.Id), trc2.' + @DateFromColumnName + '					
									) latestWithMaxDate
									ON  ISNULL(trc.IdArch, trc.Id) = latestWithMaxDate.RowID AND trc.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND trc.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
								) allData
								WHERE allData.Rn = 1'
			
						--PRINT @Query;
						EXECUTE sp_executesql @Query;
				
						--pobranie danych cech relacji do tabeli tymczasowej							
						SET @Query = '
								INSERT INTO #CechyRelacjiId(Id)
								SELECT allData.Id FROM
								(
									SELECT rch.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(rch.IdArch, rch.Id) ORDER BY rch.Id ASC) AS Rn
									FROM [dbo].[Relacja_Cecha_Hist] rch
									INNER JOIN
									(
										SELECT ISNULL(rch2.IdArch, rch2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, rch2.' + @DateFromColumnName + ' AS MaxDate
										FROM [dbo].[Relacja_Cecha_Hist] rch2								 
										INNER JOIN 
										(
											SELECT ISNULL(rch3.IdArch, rch3.Id) AS RowID, MAX(rch3.' + @DateFromColumnName + ') AS MaxDate
											FROM [dbo].[Relacja_Cecha_Hist] rch3
											JOIN dbo.[Cechy] c ON (c.Cecha_ID = rch3.CechaID)
											JOIN dbo.[Relacje] r ON (r.Id = rch3.RelacjaID)
											LEFT OUTER JOIN dbo.[TypRelacji_Cechy] trc ON (trc.Cecha_ID = c.Cecha_ID AND trc.TypRelacji_ID = r.TypRelacji_ID)
											WHERE rch3.RelacjaID IN (SELECT DISTINCT ISNULL(IdArch, Id) FROM #Relacje) AND rch3.IsMainHistFlow = 1'									
										
						--dodanie frazy statusow na filtracje jesli trzeba
						SET @Query += [THB].[PrepareStatusesPhraseForAttributes] ('rch3', @StatusS, @StatusP, @StatusW);
						
						--filtracja po cechach ktore moze widziec uzytkownik
						IF @CechyWidoczneDlaUzytkownika IS NOT NULL
							SET @Query += @CechyWidoczneDlaUzytkownika;
						
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhrase] ('rch3', @AppDate);					
										
						SET @Query += '
											GROUP BY ISNULL(rch3.IdArch, rch3.Id)
										) latest
										ON ISNULL(rch2.IdArch, rch2.Id) = latest.RowID AND rch2.' + @DateFromColumnName + ' = latest.MaxDate
										GROUP BY ISNULL(rch2.IdArch, rch2.Id), rch2.' + @DateFromColumnName + '					
									) latestWithMaxDate
									ON  ISNULL(rch.IdArch, rch.Id) = latestWithMaxDate.RowID AND rch.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND rch.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
								) allData
								WHERE allData.Rn = 1'
			
						--PRINT @Query;
						EXECUTE sp_executesql @Query;

						
						SET @Query = 'INSERT INTO #CechyRelacji(Id, RelacjaId, CechaId, TypCechyId, CzySlownik, SparceValue, ValString, [IsStatus], [StatusS], [StatusSFrom], [StatusSTo],
							[StatusSFromBy], [StatusSToBy], [StatusW], [StatusWFrom], [StatusWTo], [StatusWFromBy], [StatusWToBy], [StatusP], [StatusPFrom],
							[StatusPTo], [StatusPFromBy], [StatusPToBy], [ObowiazujeOd], [ObowiazujeDo], [IsValid],
							[ValidFrom], [ValidTo], [IsDeleted], [DeletedFrom], [DeletedBy], [CreatedOn],
							[CreatedBy], [LastModifiedOn], [LastModifiedBy], [Priority], [UIOrder], [IsAlternativeHistory], [IsMainHistFlow])					
						SELECT ch.Id, ch.RelacjaId, ch.CechaId, c.TypID, c.CzySlownik, THB.GetAttributeValueFromSparseXML(ch.ColumnsSet), ch.ValString, ch.[IsStatus], ch.[StatusS], ch.[StatusSFrom],
								ch.[StatusSTo], ch.[StatusSFromBy], ch.[StatusSToBy], ch.[StatusW], ch.[StatusWFrom], ch.[StatusWTo], ch.[StatusWFromBy], ch.[StatusWToBy], ch.[StatusP],
								ch.[StatusPFrom], ch.[StatusPTo], ch.[StatusPFromBy], ch.[StatusPToBy], ch.[ObowiazujeOd], ch.[ObowiazujeDo], ch.[IsValid],
								ch.[ValidFrom], ch.[ValidTo], ch.[IsDeleted], ch.[DeletedFrom], ch.[DeletedBy], ch.[CreatedOn],
								ch.[CreatedBy], ch.[LastModifiedOn], ch.[LastModifiedBy], 
								CASE 
									WHEN trc.ID IS NULL THEN 2
									ELSE ISNULL(trc.[Priority], 0)
								END AS [Priority],
								CASE 
									WHEN trc.ID IS NULL THEN 100
									ELSE ISNULL(trc.[UIOrder], 0)
								END AS [UIOrder],
								ch.[IsAlternativeHistory], ch.[IsMainHistFlow]
						FROM [dbo].[Relacja_Cecha_Hist] ch
						JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch.CechaID)
						JOIN dbo.[Relacje] r ON (r.Id = ch.RelacjaID)
						LEFT OUTER JOIN dbo.[TypRelacji_Cechy] trc ON (trc.Cecha_ID = c.Cecha_ID AND trc.TypRelacji_ID = r.TypRelacji_ID)
						WHERE ch.Id IN (SELECT Id FROM #CechyRelacjiId) AND (trc.ID IN (SELECT Id FROM #TypRelacjiCechy) OR trc.ID IS NULL)';
						
						--SET @Query += [THB].[PrepareDatesPhrase] ('trc', @AppDate); 
							
						--PRINT @query
						EXECUTE sp_executesql @Query
		
						--pobranie cech podanego typu relacji
						SET @query = N'INSERT INTO #CechyTypuRelacji(CechaId, TypRelacjiId, [Priority], UIOrder)
							SELECT DISTINCT Cecha_ID, TypRelacji_ID, [Priority], UIOrder
							FROM TypRelacji_Cechy
							WHERE IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0 AND TypRelacji_ID IN (SELECT DISTINCT TypRelacji_ID FROM Relacje WHERE Id IN (SELECT ID FROM #Relacje))'
						
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhrase] (NULL, @AppDate);				

						SET @Query += [THB].[PrepareStatusesPhraseForAttributes] (NULL, @StatusS, @StatusP, @StatusW);
						
						-- pobranie Id cech do ktorych uzytkownik ma dostep
						EXEC [THB].[GetUserAttributeTypes]
							@NazwaKolumnyZCecha = 'Cecha_ID',
							@DataProgramu = @DataProgramu,
							@UserId = @UzytkownikID,
							@BranchId = @BranzaId,
							@AtributeTypesWhere = @CechyWidoczneDlaUzytkownika OUTPUT
							
						--filtracja po cechach ktore moze widziec uzytkownik
						IF @CechyWidoczneDlaUzytkownika IS NOT NULL
							SET @query += @CechyWidoczneDlaUzytkownika;
						
						--PRINT @query;
						EXECUTE sp_executesql @query;
					END
					
		--SELECT * FROM #CechyRelacji
		--SELECT * FROM #CechyTypuRelacji
					
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
				
					DECLARE cur CURSOR LOCAL FOR 
						SELECT DISTINCT Id, ISNULL(IdArch, Id) FROM #Relacje 
					OPEN cur
					FETCH NEXT FROM cur INTO @IdRelacji, @IdArchRelacji
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						SET @Query = 'SET @xmlTemp = (';
					
						IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
						BEGIN
							SET @Query += 'SELECT ISNULL(r.[IdArch], r.[Id]) AS "@Id"
											,r.[TypRelacji_ID] AS "@TypeId"
											,r.[IsOuter] AS "@IsOuter"
											,r.[SourceId] AS "@SourceId"
											,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
											,ISNULL(r.[LastModifiedBy], r.[CreatedBy]) AS "@LastModifiedBy"
											,r.[TypObiektuID_L] AS "ObjectLeft/@TypeId"
											,r.[ObiektID_L] AS "ObjectLeft/@Id"
											,r.[TypObiektuID_R] AS "ObjectRight/@TypeId"
											,r.[ObiektID_R] AS "ObjectRight/@Id"'
										
							--pobieranie danych podwezlow			
							IF @RozwijajPodwezly = 1
							BEGIN
															
								IF Cursor_Status('local','cur2') > 0 
								BEGIN
									 CLOSE cur2
									 DEALLOCATE cur2
								END
							
								--pobieranie danych podwezlow, cech obiektu
								DECLARE cur2 CURSOR LOCAL FOR 
									SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory FROM #CechyRelacji WHERE RelacjaId = @IdArchRelacji
								OPEN cur2
								FETCH NEXT FROM cur2 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory 
								WHILE @@FETCH_STATUS = 0
								BEGIN
									--wyzerowanie zmiennych, potrzebne!
									SET @CechaWartosc = NULL;
									SET @CechaWartoscXML = NULL;
									SET @CechaTyp = NULL;
									SET @CechaStatusS = NULL;
									SET @CechaCzyDanaOsobowa = 0;
									SET @CechaIsStatus = 0;
									SET @ValRefAttribute = NULL;
									
									SET @QueryDlaCechy = '
										SELECT TOP 1 @CechaStatusS = StatusS, @CechaCzyDanaOsobowa = CzyJestDanaOsobowa, @CechaIsStatus = IsStatus
										FROM Cechy
										WHERE (Cecha_ID = ' + CAST(@CechaId AS varchar) + ' OR IdArch = ' + CAST(@CechaId AS varchar) + ')';
									
									--dodanie frazy na daty
									SET @QueryDlaCechy += [THB].[PrepareDatesPhrase] (NULL, @AppDate);
									
									--SET @Query += [THB].[PrepareStatusesPhraseForAttributes] (NULL, @StatusS, @StatusP, @StatusW);
										
									SET @QueryDlaCechy += '
										ORDER BY ValidFrom DESC';
										
									--PRINT @query;
									EXECUTE sp_executesql @QueryDlaCechy, N'@CechaStatusS int OUTPUT, @CechaCzyDanaOsobowa bit OUTPUT, @CechaIsStatus bit OUTPUT', 
										@CechaStatusS = @CechaStatusS OUTPUT, @CechaCzyDanaOsobowa = @CechaCzyDanaOsobowa OUTPUT, @CechaIsStatus = @CechaIsStatus OUTPUT										
									
									SET @Query += ', (SELECT c.[Id] AS "@Id"
										,c.[CechaID] AS "@TypeId"
										,c.[Priority] AS "@Priority"
										,c.[UIOrder] AS "@UIOrder"
										,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
										,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"'
									
									--sprawdzenie czy cecha zawiera dane osobowe i ma status wiekszy niz status usera
									IF @CechaIsStatus = 1 AND @CechaCzyDanaOsobowa = 1 AND @CechaStatusS > @StatusS
									BEGIN
										SET @query += '
										, ''' + THB.GetHiddenValue() + ''' AS "ValHidden/@Value"'
									END
									ELSE
									BEGIN --pobranie dokladnej wartosci cechy
										
										-- przygotowanie danych/wartosci cechy
										IF @XmlSparse IS NOT NULL
										BEGIN								
											SELECT	@CechaTyp = C.value('local-name(.)', 'varchar(MAX)')
													,@CechaWartosc = C.value('text()[1]', 'nvarchar(MAX)')
													,@CechaWartoscXML = CAST(C.query('/ValXml/*') AS nvarchar(MAX))	
													,@CechaWartoscRef = CAST(C.query('/ValRef/*') AS nvarchar(MAX))									
											FROM @XmlSparse.nodes('/*') AS t(c)
											
											IF @CechaTyp = 'ValXml'
												SET @CechaWartosc = [THB].[PrepareCodedXML](@CechaWartoscXML);
											ELSE IF @CechaTyp = 'ValRef'
											BEGIN
												SET @CechaWartosc = [THB].[PrepareCodedXML](@CechaWartoscRef);
												
												--pobranie wartosci cechy podlinkowanej
												EXEC [THB].[GetRefAttributeValue]
													@ValRef = @CechaWartosc,
													@StatusS = @StatusS,
													@StatusW = @StatusW,
													@StatusP = @StatusP,
													@AppDate = @AppDate,
													@UserId = @UzytkownikID,
													@BranchId = @BranzaId,
													@GetFullData = 0,
													@Value = @ValRefAttribute OUTPUT
											END
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
											IF @CzySlownik = 1 AND @CechaTyp = 'ValDictionary'
											BEGIN
												-- pobranie nazwy slownika skojarzonego z cecha
												SET @NazwaSlownika = (SELECT Nazwa FROM [Slowniki] WHERE Id = @CechaTypId);
												
												IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
												BEGIN
													SET @Query += ', ' + CAST(@CechaWartosc AS varchar) + ' AS "ValDictionary/@ElementId" 
															, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"'
															
													IF @NazwaSlownika IS NOT NULL
														SET @Query += '	, (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "ValDictionary/@DisplayValue"';
												END
												ELSE
												BEGIN
													SET @Query += ', ( SELECT' + CAST(@CechaWartosc AS varchar) + ' AS "@ElementId"    --@CechaId
																, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"'
																
													IF @NazwaSlownika IS NOT NULL
														SET @Query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "@DisplayValue"'
														
													SET @Query += ', (SELECT TOP 1 ISNULL(c2.[ZmianaOd], c2.[CreatedOn]) AS "@ChangeFrom"
																	,c2.[ZmianaDo] AS "@ChangeTo"
																	,ISNULL(c2.[ObowiazujeOd], c2.[CreatedOn]) AS "@EffectiveFrom"
																	,c2.[ObowiazujeDo] AS "@EffectiveTo"
																	,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																	FROM #CechyRelacji c2
																		WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.RelacjaId = ' + CAST(@IdArchRelacji AS varchar) 
																		 + ' AND c.[CechaId] = c2.[CechaId]
																	FOR XML PATH(''History''), TYPE)
																)
																FOR XML PATH(''ValDictionary''), TYPE)'							
												END
											END									
											ELSE
											BEGIN											
												
												IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
												BEGIN
													SET @Query += '
													, ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "' + @CechaTyp + '/@Value"' 
													 
													--dodanie zwracanej wartosci cechy podlinkowanej
													IF @ValRefAttribute IS NOT NULL
													BEGIN
														SET @Query += '
												,''' + @ValRefAttribute + ''' AS "ValRef"'
													END 
													 
												END
												ELSE
												BEGIN
												
													SET @Query += ', ( SELECT ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "@Value"
																,( SELECT TOP 1 ISNULL(c2.[ZmianaOd], c2.[CreatedOn]) AS "@ChangeFrom"
																	,c2.[ZmianaDo] AS "@ChangeTo"
																	,ISNULL(c2.[ObowiazujeOd], c2.[CreatedOn]) AS "@EffectiveFrom"
																	,c2.[ObowiazujeDo] AS "@EffectiveTo"
																	,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																	FROM #CechyRelacji c2
																	WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.RelacjaId = ' + CAST(@IdArchRelacji AS varchar) 
																		+ ' AND c.[CechaId] = c2.[CechaId]
																	FOR XML PATH(''History''), TYPE)
																FOR XML PATH(''' + @CechaTyp + '''), TYPE)'
																
													--dodanie zwracanej wartosci cechy podlinkowanej
													IF @ValRefAttribute IS NOT NULL
													BEGIN
														SET @Query += '
												,''' + @ValRefAttribute + ''' AS "ValRef"'
													END 
												END
																				
											END
										END
									END  --koniec pobieranie dokladnej wartosci cechy
									
									SET @Query += '	
										FROM #CechyRelacji c
										WHERE c.[RelacjaId] = ' + CAST(@IdArchRelacji AS varchar) + ' AND Id = ' + CAST(@CechaObiektuId AS varchar) + ' 
										FOR XML PATH(''Attribute''), TYPE
										)'
										
									FETCH NEXT FROM cur2 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory
									
								END
								CLOSE cur2;
								DEALLOCATE cur2;
							END					
						END
						ELSE
						BEGIN
							--pobranie wszystkich danych
							SET @Query += 'SELECT ISNULL(r.[IdArch], r.[Id]) AS "@Id"
											,r.[TypRelacji_ID] AS "@TypeId"
											,r.[IsOuter] AS "@IsOuter"
											,r.[SourceId] AS "@SourceId"
											,r.[IsDeleted] AS "@IsDeleted"
											,r.[DeletedFrom] AS "@DeletedFrom"
											,r.[DeletedBy] AS "@DeletedBy"
											,r.[CreatedOn] AS "@CreatedOn"
											,r.[CreatedBy] AS "@CreatedBy"
											,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
											,ISNULL(r.[LastModifiedBy], r.[CreatedBy]) AS "@LastModifiedBy"
											,r.[ObowiazujeOd] AS "History/@EffectiveFrom"
											,r.[ObowiazujeDo] AS "History/@EffectiveTo"
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
											,r.[TypObiektuID_L] AS "ObjectLeft/@TypeId"
											,r.[ObiektID_L] AS "ObjectLeft/@Id"
											,r.[TypObiektuID_R] AS "ObjectRight/@TypeId"
											,r.[ObiektID_R] AS "ObjectRight/@Id"';
							  
							--pobieranie danych podwezlow					
							IF @RozwijajPodwezly = 1
							BEGIN
															
								IF Cursor_Status('local','cur2') > 0 
								BEGIN
									 CLOSE cur2
									 DEALLOCATE cur2
								END
							
								--pobieranie danych podwezlow, cech obiektu
								DECLARE cur2 CURSOR LOCAL FOR 
									SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory  FROM #CechyRelacji WHERE RelacjaId = @IdArchRelacji
								OPEN cur2
								FETCH NEXT FROM cur2 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory 
								WHILE @@FETCH_STATUS = 0
								BEGIN
									
									--wyzerowanie zmiennych
									SET @CechaTyp = NULL;
									SET @CechaWartosc = NULL;
									SET @CechaWartoscXML = NULL;
									SET @CechaStatusS = NULL;
									SET @CechaCzyDanaOsobowa = 0;
									SET @CechaIsStatus = 0;
									SET @ValRefAttribute = NULL;								
									
									SET @QueryDlaCechy = '
										SELECT TOP 1 @CechaStatusS = StatusS, @CechaCzyDanaOsobowa = CzyJestDanaOsobowa, @CechaIsStatus = IsStatus
										FROM Cechy
										WHERE (Cecha_ID = ' + CAST(@CechaId AS varchar) + ' OR IdArch = ' + CAST(@CechaId AS varchar) + ')';
									
									--dodanie frazy na daty
									SET @QueryDlaCechy += [THB].[PrepareDatesPhrase] (NULL, @AppDate);
									
									--SET @Query += [THB].[PrepareStatusesPhraseForAttributes] (NULL, @StatusS, @StatusP, @StatusW);
										
									SET @QueryDlaCechy += '
										ORDER BY ValidFrom DESC';
										
									--PRINT @query;
									EXECUTE sp_executesql @QueryDlaCechy, N'@CechaStatusS int OUTPUT, @CechaCzyDanaOsobowa bit OUTPUT, @CechaIsStatus bit OUTPUT', 
										@CechaStatusS = @CechaStatusS OUTPUT, @CechaCzyDanaOsobowa = @CechaCzyDanaOsobowa OUTPUT, @CechaIsStatus = @CechaIsStatus OUTPUT															
									
									SET @Query += ', (SELECT c.[Id] AS "@Id"
										,c.[CechaID] AS "@TypeId"
										,c.[Priority] AS "@Priority"
										,c.[UIOrder] AS "@UIOrder"
										,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
										,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
										,c.[ObowiazujeOd] AS "History/@EffectiveFrom"
										,c.[ObowiazujeDo] AS "History/@EffectiveTo"
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
									
									--sprawdzenie czy cecha zawiera dane osobowe i ma status wiekszy niz status usera
									IF @CechaIsStatus = 1 AND @CechaCzyDanaOsobowa = 1 AND @CechaStatusS > @StatusS
									BEGIN
										SET @Query += '
										, ''' + THB.GetHiddenValue() + ''' AS "ValHidden/@Value"'
									END
									ELSE
									BEGIN --pobranie dokladnej wartosci cechy
										
										-- przygotowanie danych/wasrtosci cechy
										IF @XmlSparse IS NOT NULL
										BEGIN								
											SELECT	@CechaTyp = C.value('local-name(.)', 'varchar(MAX)')
													,@CechaWartosc = C.value('text()[1]', 'nvarchar(MAX)')
													,@CechaWartoscXML = CAST(C.query('/ValXml/*') AS nvarchar(MAX))
													,@CechaWartoscRef = CAST(C.query('/ValRef/*') AS nvarchar(MAX))										
											FROM @XmlSparse.nodes('/*') AS t(c)
											
											IF @CechaTyp = 'ValXml'
												SET @CechaWartosc = [THB].[PrepareCodedXML](@CechaWartoscXML);
											ELSE IF @CechaTyp = 'ValRef'
											BEGIN
												SET @CechaWartosc = [THB].[PrepareCodedXML](@CechaWartoscRef);
												
												--pobranie wartosci cechy podlinkowanej
												EXEC [THB].[GetRefAttributeValue]
													@ValRef = @CechaWartosc,
													@StatusS = @StatusS,
													@StatusW = @StatusW,
													@StatusP = @StatusP,
													@AppDate = @AppDate,
													@UserId = @UzytkownikID,
													@BranchId = @BranzaId,
													@GetFullData = 1,
													@Value = @ValRefAttribute OUTPUT
											END
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
											IF @CzySlownik = 1 AND @CechaTyp = 'ValDictionary'
											BEGIN
												-- pobranie nazwy slownika skojarzonego z cecha
												SET @NazwaSlownika = (SELECT Nazwa FROM [Slowniki] WHERE Id = @CechaTypId);
												
												IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
												BEGIN
													SET @Query += ', ' + CAST(@CechaWartosc AS varchar) + ' AS "ValDictionary/@ElementId" 
															, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"'
															
													IF @NazwaSlownika IS NOT NULL
														SET @Query += '	, (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "ValDictionary/@DisplayValue"';
												END
												ELSE
												BEGIN
													SET @Query += ', ( SELECT' + CAST(@CechaWartosc AS varchar) + ' AS "@ElementId"    --@CechaId
																, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"'
																
													IF @NazwaSlownika IS NOT NULL
														SET @Query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "@DisplayValue"'
														
													SET @Query += ', (SELECT TOP 1 ISNULL(c2.[ZmianaOd], c2.[CreatedOn]) AS "@ChangeFrom"
																	,c2.[ZmianaDo] AS "@ChangeTo"
																	,ISNULL(c2.[ObowiazujeOd], c2.[CreatedOn]) AS "@EffectiveFrom"
																	,c2.[ObowiazujeDo] AS "@EffectiveTo"
																	,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																	FROM #CechyRelacji c2
																		WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.RelacjaId = ' + CAST(@IdArchRelacji AS varchar) 
																		 + ' AND c.[CechaId] = c2.[CechaId]
																	FOR XML PATH(''History''), TYPE)
																)
																FOR XML PATH(''ValDictionary''), TYPE)'							
												END
											END
											ELSE
											BEGIN

												IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
												BEGIN
													SET @Query += '
													, ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "' + @CechaTyp + '/@Value"'
														
													--dodanie zwracanej wartosci cechy podlinkowanej
													IF @ValRefAttribute IS NOT NULL
													BEGIN
														SET @Query += '
												,''' + @ValRefAttribute + ''' AS "ValRef"'
													END
												END
												ELSE
												BEGIN
												
													SET @Query += ', ( SELECT ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "@Value"
																,( SELECT TOP 1 ISNULL(c2.[ZmianaOd], c2.[CreatedOn]) AS "@ChangeFrom"
																	,c2.[ZmianaDo] AS "@ChangeTo"
																	,ISNULL(c2.[ObowiazujeOd], c2.[CreatedOn]) AS "@EffectiveFrom"
																	,c2.[ObowiazujeDo] AS "@EffectiveTo"
																	,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																	FROM #CechyRelacji c2
																	WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.RelacjaId = ' + CAST(@IdArchRelacji AS varchar) 
																		+ ' AND c.[CechaId] = c2.[CechaId]
																	FOR XML PATH(''History''), TYPE)
																FOR XML PATH(''' + @CechaTyp + '''), TYPE)'
																
													--dodanie zwracanej wartosci cechy podlinkowanej
													IF @ValRefAttribute IS NOT NULL
													BEGIN
														SET @Query += '
												,''' + @ValRefAttribute + ''' AS "ValRef"'
													END 
												END	
												
											END
										END
									END
									
									SET @query += '	
										FROM #CechyRelacji c
										WHERE c.[RelacjaId] = ' + CAST(@IdArchRelacji AS varchar) + ' AND Id = ' + CAST(@CechaObiektuId AS varchar) + ' 
										FOR XML PATH(''Attribute''), TYPE
										)'
										
									FETCH NEXT FROM cur2 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory
									
								END
								CLOSE cur2;
								DEALLOCATE cur2;
							END	
						END
						
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @query += '
								, (SELECT 0 AS "@Id"
										,bez.[CechaID] AS "@TypeId"
										,bez.[Priority] AS "@Priority"
										,bez.[UIOrder] AS "@UIOrder"								
										,''1753-12-31T00:00:00.000'' AS "@LastModifiedOn"
										FROM #CechyTypuRelacji bez
										WHERE bez.TypRelacjiId = r.[TypRelacji_ID] AND bez.[CechaID] NOT IN (SELECT CechaId FROM #CechyRelacji c WHERE c.[RelacjaId] = ' + CAST(@IdArchRelacji AS varchar) + ') 
										FOR XML PATH(''Attribute''), TYPE
										)'
						END	 
				
						SET @query += ' FROM [Relacje] r
								WHERE r.Id = ' + CAST(@IdRelacji AS varchar) + '
								FOR XML PATH(''Relation''))';				  
			
						--PRINT @query;
						EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT;
						
						SET @xml_tmp += CAST(ISNULL(@xmlResponse, '') AS nvarchar(MAX));
						SET @xmlResponse = NULL;
						
						FETCH NEXT FROM cur INTO @IdRelacji, @IdArchRelacji
						
					END
					CLOSE cur;
					DEALLOCATE cur;					
					
					END TRY
					BEGIN CATCH
						SET @ERRMSG = @@ERROR;
						SET @ERRMSG += ' ';
						SET @ERRMSG += ERROR_MESSAGE();
					END CATCH
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Relations_GetByIds', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Relations_GetByIds', @Wiadomosc = @ERRMSG OUTPUT
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Relations_GetByIds"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';	
		
	IF @ERRMSG iS NULL OR @ERRMSG = ''
	BEGIN		
		--zamiana znakow specjalnych na xmlowe odpowiedniki
		SET @xml_tmp = THB.PrepareXMLRefValue(@xml_tmp);
		
		--SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		SET @XMLDataOut += @xml_tmp;
	END
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';	
	
	SET @XMLDataOut += '</Response>'; 
	
	
	IF OBJECT_ID('tempdb..#IDDoPobrania') IS NOT NULL
		DROP TABLE #IDDoPobrania
	
	IF OBJECT_ID('tempdb..#CechyRelacji') IS NOT NULL
		DROP TABLE #CechyRelacji
		
	IF OBJECT_ID('tempdb..#CechyTypuRelacji') IS NOT NULL
		DROP TABLE #CechyTypuRelacji
		
	IF OBJECT_ID('tempdb..#CechyRelacjiId') IS NOT NULL
		DROP TABLE #CechyRelacjiId

	IF OBJECT_ID('tempdb..#TypRelacjiCechy') IS NOT NULL
		DROP TABLE #TypRelacjiCechy
		
	IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
		DROP TABLE #Relacje
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
			
END
