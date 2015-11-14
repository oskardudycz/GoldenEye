-- =============================================
-- Author:		DK
-- Create date: 2012-07-03
-- Last modified on: 2013-02-22
-- Description:	Pobiera dane z tabeli Relacje z uwzglednieniem filrów. Pobierane sa takze obiekty L i P.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="Relations_Get" UserId="1" AppDate="2012-09-20T11:45:22" GetFullColumnsData="true" ExpandNestedValues="true"
	--	 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<PartFilter Side="Left" TypeId="1" EntityType="Unit">
	--		<CompositeFilterDescriptor LogicalOperator="AND">
	--		<FilterDescriptor AttributeTypeId="12" Operator="IsGreaterThanOrEqualTo" Value="12" />
	--		<FilterDescriptor AttributeTypeId="33" Operator="IsEqualTo" Value="4" />
	--		<CompositeFilterDescriptor LogicalOperator="OR">
	--			<FilterDescriptor AttributeTypeId="40" Operator="IsLessThan" Value="200" />
	--			<CompositeFilterDescriptor LogicalOperator="AND">
	--				<FilterDescriptor AttributeTypeId="15" Operator="IsLessThan" Value="1" />
	--			</CompositeFilterDescriptor>
	--		</CompositeFilterDescriptor>
	--		</CompositeFilterDescriptor>
	--	</PartFilter>
	--	<PartFilter Side="Right" TypeId="45" EntityType="Unit">
	--		<CompositeFilterDescriptor LogicalOperator="AND">
	--		<FilterDescriptor AttributeTypeId="12" Operator="IsGreaterThanOrEqualTo" Value="12" />
	--		<FilterDescriptor AttributeTypeId="33" Operator="IsEqualTo" Value="4" />
	--		<CompositeFilterDescriptor LogicalOperator="OR">
	--			<FilterDescriptor AttributeTypeId="40" Operator="IsLessThan" Value="200" />
	--			<CompositeFilterDescriptor LogicalOperator="AND">
	--				<FilterDescriptor AttributeTypeId="15" Operator="IsLessThan" Value="1" />
	--			</CompositeFilterDescriptor>
	--		</CompositeFilterDescriptor>
	--		</CompositeFilterDescriptor>
	--	</PartFilter>
	--	<PartFilter TypeId="13" EntityType="Relation">
	--		<CompositeFilterDescriptor LogicalOperator="AND">
	--		<FilterDescriptor AttributeTypeId="12" Operator="IsGreaterThanOrEqualTo" Value="12" />
	--		<FilterDescriptor AttributeTypeId="33" Operator="IsEqualTo" Value="4" />
	--		<CompositeFilterDescriptor LogicalOperator="OR">
	--			<FilterDescriptor AttributeTypeId="40" Operator="IsLessThan" Value="200" />
	--			<CompositeFilterDescriptor LogicalOperator="AND">
	--				<FilterDescriptor AttributeTypeId="15" Operator="IsLessThan" Value="1" />
	--			</CompositeFilterDescriptor>
	--		</CompositeFilterDescriptor>
	--		</CompositeFilterDescriptor>
	--	</PartFilter>    
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Relations_Get" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="2.2.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		
	--<!-- przy <Request .. GetFullColumnsData="false" .. ExpandNestedValues="true" ..  /> -->
	--<Relation Id="2" TypeId="3" IsOuter="false" SourceId="0" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<ObjectLeft Id="3" TypeId="5"/>
	--		<ObjectRight Id="5" TypeId="2"/>
	--		<Attribute Id="4" TypeId="66" Priority="0" UIOrder="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<ValDecimal Value="46.09"/>
	--		</Attribute>
	--		<Attribute Id="4" TypeId="66" Priority="0" UIOrder="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<ValDictionary Id="5" ElementId="23"/>
	--		</Attribute>
	--	</Relation>
	--<!-- przy <Request .. GetFullColumnsData="false" .. ExpandNestedValues="false" ..   /> -->
	--<Relation Id="2" TypeId="3" IsOuter="false" SourceId="0" LastModifiedOn="2012-02-09T12:12:12.121Z" >
	--		<ObjectLeft Id="3" TypeId="5"/>
	--		<ObjectRight Id="5" TypeId="2"/>
	--	</Relation>

	--</Response>
-- =============================================
CREATE PROCEDURE [THB].[Relations_Get]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
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
		@stronicowanieWl bit = 0,
		@from int,
		@to int,
		@WhereClause nvarchar(MAX),
		@OrderByClause nvarchar(255),
		@IloscRekordow int,
		@NumerStrony int = NULL,
		@RozmiarStrony int = NULL,
		@IloscStron int = 0,
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
		@QueryDlaCechy nvarchar(MAX) = '',
		@DateFromColumnName nvarchar(100),
		@ValRefAttribute nvarchar(MAX)
		
		--usuwanie tabel roboczych
		IF OBJECT_ID('tempdb..#IDRelacji') IS NOT NULL
			DROP TABLE #IDRelacji
			
		IF OBJECT_ID('tempdb..#IDRelacjiFinal') IS NOT NULL
			DROP TABLE #IDRelacjiFinal
		
		IF OBJECT_ID('tempdb..#CechyRelacji') IS NOT NULL
			DROP TABLE #CechyRelacji
			
		IF OBJECT_ID('tempdb..#CechyRelacjiId') IS NOT NULL
			DROP TABLE #CechyRelacjiId
			
		IF OBJECT_ID('tempdb..#CechyTypuRelacji') IS NOT NULL
			DROP TABLE #CechyTypuRelacji
			
		IF OBJECT_ID('tempdb..#TypRelacjiCechy') IS NOT NULL
			DROP TABLE #TypRelacjiCechy
			
		IF OBJECT_ID('tempdb..#TypRelacjiCechyTmp') IS NOT NULL
			DROP TABLE #TypRelacjiCechyTmp
			
		CREATE TABLE #IDRelacji (Id int, IdArch int);
		CREATE TABLE #IDRelacjiFinal (Id int, IdArch int, Rn int);
		CREATE TABLE #IDRelacjiTmp (Id int, IdArch int, IdArchLink int, ValidFrom datetime, ValidTo datetime, RealCreatedOn datetime);
		CREATE TABLE #TypRelacjiCechy(Id int);
		CREATE TABLE #CechyTypuRelacji(CechaId int, TypRelacjiId int, [Priority] smallint, UIOrder smallint);	
		CREATE TABLE #CechyRelacjiId(Id int);
		CREATE TABLE #CechyRelacji(Id int, RelacjaId int, CechaId int, TypCechyId int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), [IsStatus] bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,
			[StatusSFromBy] int,[StatusSToBy] int,[StatusW] int,[StatusWFrom] datetime,[StatusWTo] datetime,[StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,
			[StatusPTo] datetime,[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,
			[ValidFrom] datetime,[ValidTo] datetime,[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,
			[CreatedBy] int,[LastModifiedOn] datetime,[LastModifiedBy] int,[Priority] smallint,[UIOrder] smallint, [IsAlternativeHistory] bit,[IsMainHistFlow] bit);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Relations_Get', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
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
		
			IF @RequestType = 'Relations_Get'
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
					
					--pobranie danych filtrow, sortowania, stronicowania
					EXEC [THB].[PrepareFilters_Relations_Get]
						@XMLDataIn = @XMLDataIn,
						@WhereClause = @WhereClause OUTPUT,
						@OrderByClause = @OrderByClause OUTPUT,
						@PageSize = @RozmiarStrony OUTPUT,
						@PageIndex = @NumerStrony OUTPUT,
						@ERRMSG = @ERRMSG OUTPUT
				
					IF @NumerStrony IS NOT NULL AND @NumerStrony > 0 AND @RozmiarStrony IS NOT NULL AND @RozmiarStrony > 0
					BEGIN
						SET @from = ((@NumerStrony - 1) * @RozmiarStrony);		
						SET @to = ((@NumerStrony) * @RozmiarStrony);			
						SET @stronicowanieWl = 1;
					END
				
					--ustawienie sortowania dla funkcji rankingowych
					IF @OrderByClause IS NULL OR @OrderByClause = ''
						SET @OrderByClause = 'Id ASC';			
					
					--pobranie danych Id pasujacych relacji do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #IDRelacji (Id, IdArch)
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
										WHERE 1=1'									
									
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('r3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('r3', @AppDate);					
									
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);	
									
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
					
--SELECT * FROM #IDRelacji
						
					--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
					SET @Query = 'SET @IloscStron = (SELECT COUNT(1) FROM #IDRelacji)' 
					
					EXECUTE sp_executesql @query, N'@IloscStron int OUTPUT', @IloscStron = @IloscRekordow OUTPUT
										
					SET @Query = 'INSERT INTO #IDRelacjiFinal (Id, IdArch, Rn)
								SELECT Id, IdArch, Rn FROM
								(
									SELECT Id, IdArch, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
									FROM [Relacje] 
									WHERE Id IN (SELECT Id FROM #IDRelacji)
								) X
								WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					SET @query += ' ORDER BY Rn'
					
					--PRINT @query;
					EXECUTE sp_executesql @query
								
					IF @RozwijajPodwezly = 1
					BEGIN

						--pobranie danych cech relacji do tabeli tymczasowej							
						SET @Query = '
								INSERT INTO #CechyRelacjiId (Id)
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
											WHERE rch3.RelacjaID IN (SELECT DISTINCT ISNULL(IdArch, Id) FROM #IDRelacjiFinal) AND rch3.IsMainHistFlow = 1'									
										
						--dodanie frazy statusow na filtracje jesli trzeba
						SET @Query += [THB].[PrepareStatusesPhraseForAttributes] ('rch3', @StatusS, @StatusP, @StatusW);
						
						--filtracja po cechach ktore moze widziec uzytkownik
						IF @CechyWidoczneDlaUzytkownika IS NOT NULL
							SET @Query += @CechyWidoczneDlaUzytkownika;
						
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhrase] ('rch3', @AppDate);					
										
						IF @WhereClause IS NOT NULL
							SET @Query += [THB].PrepareSafeQuery(@WhereClause);	
										
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
							
	-----------			
	
						--pobranie danych cech typu relacji do tabeli tymczasowej							
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
											WHERE trc3.TypRelacji_Id IN (SELECT DISTINCT TypRelacji_ID FROM dbo.Relacje WHERE Id IN (SELECT Id FROM #IDRelacjiFinal))'									
										
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
					
						SET @Query = 'INSERT INTO #CechyRelacji(Id, RelacjaId, CechaId, TypCechyId, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
							[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
							[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
							[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
							[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder], [IsAlternativeHistory],[IsMainHistFlow])					
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
						WHERE ch.Id IN (SELECT Id FROM #CechyRelacjiId) AND (trc.ID IN (SELECT Id FROM #TypRelacjiCechy) OR trc.ID IS NULL)'
						
						--SET @Query += [THB].[PrepareDatesPhrase] ('trc', @AppDate); 
						
						--PRINT @Query
						EXECUTE sp_executesql @Query					
							
	-----------				
						--pobranie cech podanego typu relacji
						SET @query = N'INSERT INTO #CechyTypuRelacji(CechaId, TypRelacjiId, [Priority], UIOrder)
							SELECT Cecha_ID, TypRelacji_ID, [Priority], UIOrder
							FROM TypRelacji_Cechy
							WHERE IdArch IS NULL AND IsValid = 1 AND TypRelacji_ID IN (SELECT DISTINCT TypRelacji_ID FROM Relacje WHERE Id IN (SELECT ID FROM #IDRelacji))'
						
						--dodanie frazy statusow na filtracje jesli trzeba
						SET @Query += [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);
																					
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhrase] (NULL, @AppDate);							
						
						-- pobranie Id cech do ktorych uzytkownik ma dostep
						EXEC [THB].[GetUserAttributeTypes]
							@NazwaKolumnyZCecha = 'Cecha_ID',
							@DataProgramu = @DataProgramu,
							@UserId = @UzytkownikID,
							@BranchId = @BranzaId,
							@AtributeTypesWhere = @CechyWidoczneDlaUzytkownika OUTPUT
							
						--filtracja po cechach ktore moze widziec uzytkownik
						IF @CechyWidoczneDlaUzytkownika IS NOT NULL
							SET @Query += @CechyWidoczneDlaUzytkownika;
						
						--PRINT @query;
						EXECUTE sp_executesql @Query;
						
					END
										
					--SELECT * FROM #CechyRelacji
					
					IF Cursor_Status('local','cur77') > 0 
					BEGIN
						 CLOSE cur77
						 DEALLOCATE cur77
					END
				
					DECLARE cur77 CURSOR LOCAL FOR 
						SELECT Id, ISNULL(IdArch, Id) FROM #IDRelacjiFinal ORDER BY Rn
					OPEN cur77
					FETCH NEXT FROM cur77 INTO @IdRelacji, @IdArchRelacji
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						SET @query = 'SET @xmlTemp = (';
					
						IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
						BEGIN
							SET @query += 'SELECT ISNULL(r.[IdArch], r.[Id]) AS "@Id"
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
									SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory FROM #CechyRelacji WHERE RelacjaId = @IdArchRelacji ORDER BY Id  --@IdRelacji
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
									
									SET @Query += '
									, (SELECT c.[Id] AS "@Id"
										,c.[CechaID] AS "@TypeId"
										,c.[Priority] AS "@Priority"
										,c.[UIOrder] AS "@UIOrder"
										,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
										,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"'
										
									--sprawdzenie czy cecha zawiera dane osobowe i ma status wiekszy niz status usera
									IF @CechaIsStatus = 1 AND @CechaCzyDanaOsobowa = 1 AND @CechaStatusS > @StatusS
									BEGIN
										SET @Query += '
										, ''' + THB.GetHiddenValue() + ''' AS "ValHidden/@Value"'
									END
									ELSE
									BEGIN
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
											IF @CzySlownik = 1 AND @CechaTyp = 'ValDictionary'
											BEGIN
																					
												-- pobranie nazwy slownika skojarzonego z cecha
												SET @NazwaSlownika = (SELECT Nazwa FROM [Slowniki] WHERE Id = @CechaTypId);
												
												IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
												BEGIN
													SET @Query += ', ' + CAST(@CechaWartosc AS varchar) + ' AS "ValDictionary/@ElementId" 
															, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"'
													
													IF @NazwaSlownika IS NOT NULL		
														SET @Query += ', ISNULL((SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + '), '''') AS "ValDictionary/@DisplayValue"';
												END
												ELSE
												BEGIN							
												
													SET @Query += ', ( SELECT' + CAST(@CechaWartosc AS varchar) + ' AS "@ElementId"  
																, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"'
																
													IF @NazwaSlownika IS NOT NULL
														SET @Query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "@DisplayValue"'
														
													SET @Query += ' , (SELECT TOP 1 ISNULL(c2.[ZmianaOd], c2.[CreatedOn]) AS "@ChangeFrom"
																	,c2.[ZmianaDo] AS "@ChangeTo"
																	,ISNULL(c2.[ObowiazujeOd], c2.[CreatedOn]) AS "@EffectiveFrom"
																	,c2.[ObowiazujeDo] AS "@EffectiveTo"
																	,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																	FROM #CechyRelacji c2
																		WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.RelacjaId = ' + CAST(@IdArchRelacji AS varchar) --@IdRelacji
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
																	WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.RelacjaId = ' + CAST(@IdArchRelacji AS varchar)   --@IdRelacji
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
										WHERE c.[RelacjaId] = ' + CAST(@IdArchRelacji AS varchar) + ' AND Id = ' + CAST(@CechaObiektuId AS varchar) + '   --@IdRelacji
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
							SET @query += 'SELECT ISNULL(r.[IdArch], r.[Id]) AS "@Id"
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
									SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory  FROM #CechyRelacji WHERE RelacjaId = @IdArchRelacji ORDER BY Id --@IdRelacji
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
									
									
									SET @query += '
									, (SELECT c.[Id] AS "@Id"
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
										SET @query += ', ''' + THB.GetHiddenValue() + ''' AS "ValHidden/@Value"'
									END
									ELSE
									BEGIN	
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
														SET @Query += ', ISNULL((SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + '), '''') AS "ValDictionary/@DisplayValue"';

												END
												ELSE
												BEGIN
													SET @Query += ', ( SELECT' + CAST(@CechaWartosc AS varchar) + ' AS "@ElementId"    --@CechaId
																, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"'
																
																
													IF @NazwaSlownika IS NOT NULL		
														SET @Query += ', ISNULL((SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + '), '''') AS "@DisplayValue"'
														
													SET @Query += ', (SELECT TOP 1 ISNULL(c2.[ZmianaOd], c2.[CreatedOn]) AS "@ChangeFrom"
																	,c2.[ZmianaDo] AS "@ChangeTo"
																	,ISNULL(c2.[ObowiazujeOd], c2.[CreatedOn]) AS "@EffectiveFrom"
																	,c2.[ObowiazujeDo] AS "@EffectiveTo"
																	,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																	FROM #CechyRelacji c2
																		WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.RelacjaId = ' + CAST(@IdArchRelacji AS varchar) --@IdRelacji
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
																	WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.RelacjaId = ' + CAST(@IdArchRelacji AS varchar) --@IdRelacji
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
										WHERE c.[RelacjaId] = ' + CAST(@IdArchRelacji AS varchar) + ' AND Id = ' + CAST(@CechaObiektuId AS varchar) + '  --@IdRelacji
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
						
						FETCH NEXT FROM cur77 INTO @IdRelacji, @IdArchRelacji					
					END
					CLOSE cur77;
					DEALLOCATE cur77;					
					
					END TRY
					BEGIN CATCH
						SET @ERRMSG = @@ERROR;
						SET @ERRMSG += ' ';
						SET @ERRMSG += ERROR_MESSAGE();
					END CATCH
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Relations_Get', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Relations_Get', @Wiadomosc = @ERRMSG OUTPUT
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Relations_Get"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';	
	
	SET @XMLDataOut += '>';
	
	--dodanie do odpowiedzi informacji o stronach
	IF @stronicowanieWl = 1
	BEGIN
		SET @XMLDataOut += '<TotalPages PageIndex="' + CAST(@NumerStrony AS varchar) + '" PageSize="' + CAST(@RozmiarStrony AS varchar) + '" ItemCount="' + CAST(ISNULL(@IloscRekordow, 0) AS varchar) + '"/>'; --'" TotalPagesCount="' + CAST(ISNULL(@IloscStron, 0) AS varchar) + '"/>'
	END
	
	IF @ERRMSG IS NULL OR @ERRMSG = ''
	BEGIN
	
		--zamiana znakow specjalnych na xmlowe odpowiedniki
		SET @xml_tmp = THB.PrepareXMLRefValue(@xml_tmp);
	
		--SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		SET @XMLDataOut += @xml_tmp;
	END
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';	
	
	SET @XMLDataOut += '</Response>'; 
	
	--usuwanie tabel roboczych
	IF OBJECT_ID('tempdb..#IDRelacji') IS NOT NULL
		DROP TABLE #IDRelacji
		
	IF OBJECT_ID('tempdb..#IDRelacjiFinal') IS NOT NULL
		DROP TABLE #IDRelacjiFinal
	
	IF OBJECT_ID('tempdb..#CechyRelacji') IS NOT NULL
		DROP TABLE #CechyRelacji
		
	IF OBJECT_ID('tempdb..#CechyTypuRelacji') IS NOT NULL
		DROP TABLE #CechyTypuRelacji
			
	IF OBJECT_ID('tempdb..#CechyRelacjiId') IS NOT NULL
		DROP TABLE #CechyRelacjiId
		
	IF OBJECT_ID('tempdb..#TypRelacjiCechy') IS NOT NULL
		DROP TABLE #TypRelacjiCechy
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
