-- =============================================
-- Author:		DK
-- Create date: 2012-03-26
-- Last modified on: 2013-04-28
-- Description:	Zwraca liste obiektow o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Units_GetOfType" TypeId="3" UserId="1" AppDate="2012-09-26T12:43:22" GetFullColumnsData="true" ExpandNestedValues="true"
	--	xsi:noNamespaceSchemaLocation="1.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<CompositeFilterDescriptor LogicalOperator="AND">
	--		<FilterDescriptor AttributeTypeId="12" Operator="IsGreaterThanOrEqualTo" Value="12" />
	--		<FilterDescriptor AttributeTypeId="33" Operator="IsEqualTo" Value="4" />
	--		<CompositeFilterDescriptor LogicalOperator="OR">
	--			<FilterDescriptor AttributeTypeId="40" Operator="IsLessThan" Value="200" />
	--			<CompositeFilterDescriptor LogicalOperator="AND">
	--				<FilterDescriptor AttributeTypeId="15" Operator="IsLessThan" Value="1" />
	--			</CompositeFilterDescriptor>
	--		</CompositeFilterDescriptor>
	--	</CompositeFilterDescriptor>
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Units_GetOfType" AppDate="2012-02-09">
	    
	--	<!-- przy <Request .. GetFullColumnsData="true" ExpandNestedValues="true"  ../> -->
	--	<Unit Id="1" TypeId="20" Name="21323123" Version="12"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--		<Attribute Id="1" TypeId="12" Priority="1" UIOrder="2"
	--			IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--			<ValDictionary Id="12" ElementId="3">
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />                
	--			</ValDictionary>
	--		</Attribute>
	--		<Attribute Id="2" TypeId="45" Priority="0" UIOrder="1"
	--			IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--			 <ValDecimal Value="43.008">
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />
	--			</ValDecimal>
	--		</Attribute>
	--	</Unit>
	    
	--	<!-- przy <Request .. GetFullColumnsData="true" ExpandNestedValues="false"  ../> -->
	--	<Unit Id="1" TypeId="20" Name="21323123" Version="12"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />        
	--	</Unit>
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ExpandNestedValues="false"  ../> -->
	--	<Unit Id="1" TypeId="20" Name="21323123" Version="12" LastModifiedOn="2012-02-09T12:12:12.121Z" />   
	    
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Units_GetOfType]
(	
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@TableName nvarchar(500),
		@RequestType nvarchar(100),
		@xml_data xml,
		@xmlOk bit = 0,
		@xmlOut xml,
		@StatusS int,
		@StatusP int,
		@StatusW int,
		@DataProgramu datetime,
		@UzytkownikID int = NULL,
		@BranzaID int,
		@xmlVar nvarchar(MAX) = '',
		@TypObiektuId int,		
		@NazwaTypuObiektu nvarchar(500),		
		@ObiektId int,
		@MaUprawnienia bit = 0,
		@ERRMSG nvarchar(255),
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@CzySlownik bit,
		@XmlSparse xml,
		@IloscRekordow int,
		@CechaTyp varchar(50),
		@CechaTypId int,
		@WartoscString nvarchar(MAX),
		@CechaWartosc nvarchar(MAX),
		@CechaWartoscXML nvarchar(MAX),
		@CechaWartoscRef nvarchar(MAX),
		@CechaObiektuId int,
		@CechaId int,
		@CechaHasAlternativeHistory bit = 0,
		@NumerStrony int = NULL,
		@RozmiarStrony int = NULL,
		@WhereClause nvarchar(MAX),
		@OrderByClause nvarchar(500),
		@stronicowanieWl bit = 0,
		@from int,
		@to int,
		@CechyWidoczneDlaUzytkownika nvarchar(MAX),
		@NazwaSlownika nvarchar(500),
		@AppDate datetime,
		@IdArchObiektu int,
		@CechaStatusS int,
		@CechaCzyDanaOsobowa bit,
		@CechaIsStatus bit,
		@QueryDlaCechy nvarchar(MAX) = '',
		@DateFromColumnName nvarchar(100),
		@ValRefAttribute nvarchar(MAX),
		
		@CzyTabela bit,
		@TypKolumny varchar(100),
		@NazwaKolumny nvarchar(500),
		@CechaIdKolumny int,
		@UnitTypeColumns nvarchar(MAX) = '',
		@ObiektIdDlaCechy int,
		@WartoscCechy nvarchar(MAX),
		@WartoscCechyString nvarchar(MAX),
		@WartoscCechyXml nvarchar(MAX),
		@CzyTabelaCounter int = 0,
		@StatusesForFilters nvarchar(300),
		@CreateTablePhrase nvarchar(MAX) = '',
		@QueryWstawianiaCechTabelarycznych nvarchar(MAX) = '',
		@CounterForSubQueryTableTypes int = 0;
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Units_GetOfType', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

	IF @xmlOk = 0
	BEGIN
		-- co zrobic jak nie poprawna walidacja XML
		SET @ERRMSG = @ERRMSG;
	END
	ELSE
	BEGIN
		
		--usuwanie tabel tymczasowych, jesli istnieja	
		IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
			DROP TABLE #Obiekty
			
		IF OBJECT_ID('tempdb..#CechyObiektu') IS NOT NULL
			DROP TABLE #CechyObiektu
			
		IF OBJECT_ID('tempdb..#KolumnyTypuObiektu') IS NOT NULL
			DROP TABLE #KolumnyTypuObiektu
			
		IF OBJECT_ID('tempdb..#CechyObiektuMain') IS NOT NULL
			DROP TABLE #CechyObiektuMain
				
		IF OBJECT_ID('tempdb..#CechyTypuObiektuWspolne') IS NOT NULL
			DROP TABLE #CechyTypuObiektuWspolne
			
		IF OBJECT_ID('tempdb..#ObiektyMain') IS NOT NULL
			DROP TABLE #ObiektyMain
			
		IF OBJECT_ID('tempdb..#ObiektyMainFinal') IS NOT NULL
			DROP TABLE #ObiektyMainFinal
		
		IF OBJECT_ID('tempdb..#CTS_GetOfType') IS NOT NULL
			DROP TABLE #CTS_GetOfType
			
		IF OBJECT_ID('tempdb..#WartosciCechObiektowTabelarycznych') IS NOT NULL
			DROP TABLE #WartosciCechObiektowTabelarycznych
		
		CREATE TABLE #WartosciCechObiektowTabelarycznych(Id int, ObiektId int, CechaId int, ValString nvarchar(MAX), ValXml xml);
		CREATE TABLE #CechyTypuObiektuWspolne(CechaId int, [Priority] smallint, UIOrder smallint);		
		CREATE TABLE #ObiektyMain (Id int PRIMARY KEY, IdArch int);	
		CREATE TABLE #ObiektyMainFinal (Id int, IdArch int, Rn int);	
		CREATE TABLE #CechyObiektuMain (Id int, ObiektId int);
		CREATE TABLE #KolumnyTypuObiektu(CechaId int, NazwaKolumny nvarchar(250), TypKolumny varchar(50));
			
		CREATE TABLE #Obiekty(Id int, IdArch int, Nazwa nvarchar(500), IsStatus bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,[StatusSFromBy] int,
			[StatusSToBy] int, [StatusW] int, [StatusWFrom] datetime, [StatusWTo] datetime, [StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,[StatusPTo] datetime,
			[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,[ValidFrom] datetime,[ValidTo] datetime,
			[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,[CreatedBy] int,[LastModifiedOn] datetime,
			[LastModifiedBy] int,[IsAlternativeHistory] bit,[IsMainHistFlow] bit, Rn int);	
		
		CREATE TABLE #CechyObiektu(ObiektId int, Id int, CechaId int, TypCechyId int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), [IsStatus] bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,
			[StatusSFromBy] int,[StatusSToBy] int,[StatusW] int,[StatusWFrom] datetime,[StatusWTo] datetime,[StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,
			[StatusPTo] datetime,[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,
			[ValidFrom] datetime,[ValidTo] datetime,[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,
			[CreatedBy] int,[LastModifiedOn] datetime,[LastModifiedBy] int,[Priority] smallint,[UIOrder] smallint,[IsAlternativeHistory] bit,[IsMainHistFlow] bit);
		
		--poprawny XML wejsciowy
		SET @xml_data = CAST(@XMLDataIn AS xml);
		
		--wyciaganie daty i typu zadania
		SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
				,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
				,@BranzaId = C.value('./@BranchId', 'int')
				,@TypObiektuId = C.value('./@TypeId', 'int')
				,@NazwaTypuObiektu = C.value('./@Name', 'nvarchar(300)')
				,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
				,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@StatusS =  C.value('./@StatusS','int') 
				,@StatusP = C.value('./@StatusP','int') 
				,@StatusW = C.value('./@StatusW','int') 
		FROM @xml_data.nodes('/Request') T(C) 
	
		IF @RequestType = 'Units_GetOfType'
		BEGIN
			SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
			BEGIN TRY
			BEGIN TRANSACTION T_Units_GetOfType
			
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
			
			IF @MaUprawnienia = 1
			BEGIN
				--pobranie nazwy typu obiektu po Id typu
				SELECT @tableName = t.Nazwa, @CzyTabela = Tabela 
				FROM dbo.TypObiektu t 
				WHERE t.TypObiekt_ID = @TypObiektuId AND t.IdArch IS NULL AND t.IsValid = 1 AND t.IsDeleted = 0;
						
				--jesli nie udalo sie pobrac po Id to proba pobrania po nazwie
				IF @tableName IS NULL AND @NazwaTypuObiektu IS NOT NULL
				BEGIN
					SELECT @tableName = t.Nazwa 
					FROM dbo.TypObiektu t 
					WHERE t.Nazwa = @NazwaTypuObiektu AND t.IdArch IS NULL AND t.IsValid = 1 AND t.IsDeleted = 0;
				END
		
				IF @tableName IS NOT NULL AND @tableName <> ''
				BEGIN
				
					SET @StatusesForFilters = [THB].[PrepareStatusesPhrase] ('ch', @StatusS, @StatusP, @StatusW);			
		
					--pobranie danych filtrow, sortowania, stronicowania
					EXEC [THB].[PrepareFilters_UnitsGetOfType]
						@XMLDataIn = @XMLDataIn,
						@ObjectTypeId = @TypObiektuId,
						@ObjectType = @tableName,
						@AppDate = @AppDate,
						@IsTable = @CzyTabela,
						@StatusesClause = @StatusesForFilters,
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
				
--SELECT @WhereClause, @OrderByClause, @RozmiarStrony, @NumerStrony,  'po filtrach'										

					--ustawienie sortowania dla funkcji rankingowych
					IF @OrderByClause IS NULL OR @OrderByClause = ''
						SET @OrderByClause = 'ISNULL(IdArch, Id) ASC';	

					IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Id', 'ISNULL(IdArch, Id)');

					IF @CzyTabela = 0
					BEGIN
					--pobranie danych Id pasujacych obiektow do tabeli tymczasowej							
					SET @Query = '
						IF OBJECT_ID (N''[_' + @tableName + ']'', N''U'') IS NOT NULL
						BEGIN
							INSERT INTO #ObiektyMain (Id, IdArch)
							SELECT allData.Id, allData.IdArch FROM
							(
								SELECT o.Id, o.IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(o.IdArch, o.Id) ORDER BY o.Id ASC) AS Rn
								FROM [dbo].[_' + @tableName + '] o
								INNER JOIN
								(
									SELECT ISNULL(o2.IdArch, o2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, o2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[_' + @tableName + '] o2								 
									INNER JOIN 
									(
										SELECT ISNULL(o3.IdArch, o3.Id) AS RowID, MAX(o3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[_' + @tableName + '] o3
										WHERE 1=1';
										
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('o3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('o3', @AppDate);
					
					--IF @WhereClause IS NOT NULL
					--	SET @Query += [THB].PrepareSafeQuery(@WhereClause)																
									
					SET @Query += '
										GROUP BY ISNULL(o3.IdArch, o3.Id)
									) latest
									ON ISNULL(o2.IdArch, o2.Id) = latest.RowID AND o2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(o2.IdArch, o2.Id), o2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(o.IdArch, o.Id) = latestWithMaxDate.RowID AND o.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND o.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							WHERE 1=1'
					
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);
						
					SET @Query += [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] (NULL, @AppDate);
					
					SET @Query += '			
							) allData
							WHERE allData.Rn = 1
						END'
					END
					ELSE
					BEGIN						
						
						--jesli obiekt tabelaryczny mozmy od razu wstawic dane do tabeli finalnej w rankingiem
						SET @Query = '
							IF OBJECT_ID (N''[_' + @tableName + ']'', N''U'') IS NOT NULL
							BEGIN
								INSERT INTO #ObiektyMain (Id, IdArch)
								SELECT Id, IdArch							
								FROM [dbo].[_' + @tableName + ']
								WHERE 1=1'									
									
						IF @WhereClause IS NOT NULL
							SET @Query += [THB].PrepareSafeQuery(@WhereClause);
							
						SET @Query += [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);
						
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhrase] (NULL, @AppDate);
						
						SET @Query += '
						  END';							
					
					END
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
					
					--IF @CzyTabela = 0
					BEGIN
						--posortowanie i wybranie przedzialu stronicowego pasujacych branz
						SET @Query = 'INSERT INTO #ObiektyMainFinal (Id, IdArch, Rn)
							SELECT Id, IdArch, Rn FROM
							(
								SELECT Id, IdArch, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
								FROM [dbo].[_' + @tableName + ']
								WHERE Id IN (SELECT Id FROM #ObiektyMain)
							) X
							WHERE 1=1'
									
						IF @stronicowanieWl = 1
							SET @Query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
						
						--PRINT @query;
						EXECUTE sp_executesql @Query
					END
---
--SELECT * FROM #ObiektyMain;	
--SELECT * FROM #ObiektyMainFinal
	
					--pobieranie danych obiektow to tabel tymczasowych
					SET @Query = N'
						INSERT INTO #Obiekty (Id, IdArch, Nazwa, IsStatus,[StatusS],[StatusSFrom],[StatusSTo],[StatusSFromBy],
							[StatusSToBy], [StatusW], [StatusWFrom], [StatusWTo], [StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],[StatusPTo],
							[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],[ValidFrom],[ValidTo],
							[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],[CreatedBy],[LastModifiedOn],
							[LastModifiedBy],[IsAlternativeHistory],[IsMainHistFlow], Rn)
						SELECT ob.Id, ob.IdArch, ob.Nazwa, ob.IsStatus, ob.[StatusS], ob.[StatusSFrom], ob.[StatusSTo], ob.[StatusSFromBy],
							ob.[StatusSToBy], ob.[StatusW], ob.[StatusWFrom], ob.[StatusWTo], ob.[StatusWFromBy], ob.[StatusWToBy], ob.[StatusP], ob.[StatusPFrom], ob.[StatusPTo],
							ob.[StatusPFromBy], ob.[StatusPToBy], ob.[ObowiazujeOd], ob.[ObowiazujeDo], ob.[IsValid], ob.[ValidFrom], ob.[ValidTo],
							ob.[IsDeleted], ob.[DeletedFrom], ob.[DeletedBy], ob.[CreatedOn], ob.[CreatedBy], ob.[LastModifiedOn],
							ob.[LastModifiedBy], ob.[IsAlternativeHistory], ob.[IsMainHistFlow], omf.Rn
						FROM [dbo].[_' + @tableName + '] ob
						JOIN #ObiektyMainFinal omf ON (ob.Id = omf.Id)';				
					
					--PRINT @Query
					EXECUTE sp_executesql @Query;

--SELECT * FROM #Obiekty
						
					IF @RozwijajPodwezly = 1
					BEGIN	
						-- pobranie Id cech do ktorych uzytkownik ma dostep
						EXEC [THB].[GetUserAttributeTypes]
							@Alias = 'ch3',
							@DataProgramu = @DataProgramu,
							@UserId = @UzytkownikID,
							@BranchId = @BranzaId,
							@AtributeTypesWhere = @CechyWidoczneDlaUzytkownika OUTPUT
					
					-- jesli typ obiektu zdefiniownay jako tabelaryczny (cechy wprost w tabeli)			
						IF @CzyTabela = 1
						BEGIN
							SET @CzyTabelaCounter = 0;	
					
							--pobranie nazw i typow kolumn/cech na podstawie PIERWSZEJ nazwy cechy
							INSERT INTO #KolumnyTypuObiektu (NazwaKolumny, TypKolumny, CechaId)
							SELECT DISTINCT c.Nazwa, ct.NazwaSql, ISNULL(allData.IdArch, allData.Cecha_ID)
							FROM
							(
								SELECT c.Cecha_ID, c.IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(c.IdArch, c.Cecha_ID) ORDER BY c.Cecha_ID ASC) AS Rn
								FROM [dbo].[Cechy] c
								INNER JOIN
								(
									SELECT ISNULL(c2.IdArch, c2.Cecha_ID) AS RowID, MIN(c2.ObowiazujeOd) AS MinDate
									FROM [dbo].[Cechy] c2							 
									JOIN dbo.TypObiektu_Cechy toc ON (c2.Cecha_Id = toc.Cecha_Id OR c2.IdArch = toc.Cecha_Id)
									WHERE toc.TypObiektu_ID = @TypObiektuId AND toc.IsDeleted = 0
									GROUP BY ISNULL(c2.IdArch, c2.Cecha_ID)
								) latestWithMaxDate
								ON ISNULL(c.IdArch, c.Cecha_ID) = latestWithMaxDate.RowID AND c.ObowiazujeOd = latestWithMaxDate.MinDate
							) allData
							JOIN dbo.Cechy c ON (c.Cecha_Id = allData.Cecha_Id)
							JOIN dbo.Cecha_Typy ct ON (c.TypId = ct.Id) 
							WHERE allData.Rn = 1
							
--SELECT * FROM #KolumnyTypuObiektu
							
							--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
							IF Cursor_Status('local','curColumns') > 0 
							BEGIN
								 CLOSE curColumns
								 DEALLOCATE curColumns
							END
						
							DECLARE curColumns CURSOR LOCAL FOR 
								SELECT NazwaKolumny, TypKolumny FROM #KolumnyTypuObiektu
							OPEN curColumns
							FETCH NEXT FROM curColumns INTO @NazwaKolumny, @TypKolumny
							WHILE @@FETCH_STATUS = 0
							BEGIN
								
								IF @NazwaKolumny <> 'Id' --AND @NazwaKolumny <> 'Nazwa'
								BEGIN
									SET @UnitTypeColumns += ',[' + @NazwaKolumny + ']';
								END
		
								FETCH NEXT FROM curColumns INTO @NazwaKolumny, @TypKolumny
							END
							CLOSE curColumns;
							DEALLOCATE curColumns;
					
							SET @Query = '
										IF OBJECT_ID(''tempdb..##CechyTabelaryczne_GetOfType'') IS NOT NULL
											DROP TABLE ##CechyTabelaryczne_GetOfType;
										
										SELECT Id' + @UnitTypeColumns + '
										INTO ##CechyTabelaryczne_GetOfType
										FROM [_' + @TableName + '] ob
										WHERE ob.Id IN (SELECT Id FROM #ObiektyMainFinal);' 
										  
							--PRINT @Query
							EXECUTE sp_executesql @Query;
							
--SELECT * FROM ##CechyTabelaryczne_GetOfType						
							--przekopiowanie danych z 1 tabeli globalnej - widocznej w kazdej sesji do tymczasowej dla pojedynczej sesji
							SELECT c.* 
							INTO #CTS_GetOfType
							FROM ##CechyTabelaryczne_GetOfType c
															
							--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
							IF Cursor_Status('local','curObjects') > 0 
							BEGIN
								 CLOSE curObjects
								 DEALLOCATE curObjects
							END	
							
							DECLARE curObjects CURSOR LOCAL FOR 
								SELECT Id FROM #CTS_GetOfType;
							OPEN curObjects
							FETCH NEXT FROM curObjects INTO @ObiektIdDlaCechy
							WHILE @@FETCH_STATUS = 0
							BEGIN			

								DELETE FROM #WartosciCechObiektowTabelarycznych;
							
								SET @Query = '
									INSERT INTO #WartosciCechObiektowTabelarycznych(Id, ObiektId, CechaId, ValString, ValXml)
									SELECT ctab.Id, ' + CAST(@ObiektIdDlaCechy AS varchar) + ', ctab.CechaId, THB.PrepareTableAttributeValues_String(ctab.TypCechy, ctab.Wartosc), THB.PrepareTableAttributeValues_Xml(ctab.TypCechy, ctab.Wartosc)
									FROM
									('
							
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local','curColumns') > 0 
								BEGIN
									 CLOSE curColumns
									 DEALLOCATE curColumns
								END
								
								DECLARE curColumns CURSOR LOCAL FOR 
									SELECT CechaId, NazwaKolumny, TypKolumny FROM #KolumnyTypuObiektu
								OPEN curColumns
								FETCH NEXT FROM curColumns INTO @CechaIdKolumny, @NazwaKolumny, @TypKolumny
								WHILE @@FETCH_STATUS = 0
								BEGIN
					
									SET @Query += '
										SELECT ' + CAST(@CzyTabelaCounter AS varchar) + ' AS Id,' + CAST(@CechaIdKolumny AS varchar) + ' AS CechaId, ''' + @TypKolumny + ''' AS TypCechy, CAST([' + @NazwaKolumny + '] AS nvarchar(MAX)) AS Wartosc 
										FROM #CTS_GetOfType WHERE Id = ' + CAST(@ObiektIdDlaCechy AS varchar) + '
											UNION ALL'
					
									SET @CzyTabelaCounter -= 1;	
		
									FETCH NEXT FROM curColumns INTO @CechaIdKolumny, @NazwaKolumny, @TypKolumny
								END
								CLOSE curColumns;
								DEALLOCATE curColumns;
								
								--usuniecie ostatniego UNION ALL
								SET @Query = SUBSTRING(@Query, 1, LEN(@Query) - 9);
								
								SET @Query += '
									) ctab';
	
								--PRINT @Query;
								EXECUTE sp_executesql @Query;						

--SELECT * FROM #WartosciCechObiektowTabelarycznych order by CechaId
							
								--wstawianie danych do tabeli
								SET @QueryWstawianiaCechTabelarycznych = '																		
									INSERT INTO #CechyObiektu (ObiektId, Id, CechaId, TypCechyId, CzySlownik, SparceValue, ValString,[ObowiazujeOd],[ObowiazujeDo],[IsValid],
										[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
										[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow])
									SELECT ch.Id,wcot.Id,c.Cecha_ID,c.TypID,c.CzySlownik,wcot.ValXml,wcot.ValString,ch.[ObowiazujeOd],ch.[ObowiazujeDo],ch.[IsValid],
										ch.[ValidFrom],ch.[ValidTo],ch.[IsDeleted],ch.[DeletedFrom], ch.[DeletedBy], ch.[CreatedOn],
										ch.[CreatedBy],ch.[LastModifiedOn],ch.[LastModifiedBy], 
										CASE 
											WHEN tobc.ID IS NULL THEN 2
											ELSE ISNULL(tobc.[Priority],0)
										END AS [Priority],
										CASE 
											WHEN tobc.ID IS NULL THEN 100
											ELSE ISNULL(tobc.[UIOrder], 0)
										END AS [UIOrder],
										ch.[IsAlternativeHistory], ch.[IsMainHistFlow]
									FROM [dbo].[_' + @tableName + '] ch
									JOIN #WartosciCechObiektowTabelarycznych wcot ON (ch.Id = wcot.ObiektId)
									JOIN dbo.[Cechy] c ON (c.Cecha_ID = wcot.CechaId)
									LEFT OUTER JOIN dbo.[TypObiektu_Cechy] tobc ON (tobc.Cecha_ID = c.Cecha_ID AND tobc.TypObiektu_ID = ' + CAST(@TypObiektuId AS varchar) + ')
									WHERE tobc.IdArch IS NULL AND tobc.IsDeleted = 0 AND ch.Id = ' + CAST(@ObiektIdDlaCechy AS varchar) + ';'
									
								--PRINT @QueryWstawianiaCechTabelarycznych;
								EXECUTE sp_executesql @QueryWstawianiaCechTabelarycznych;
				
								FETCH NEXT FROM curObjects INTO @ObiektIdDlaCechy
							END
							CLOSE curObjects;
							DEALLOCATE curObjects;

						END
						ELSE
						BEGIN	
				
							--pobranie danych Id pasujacych cech obiektow do tabeli tymczasowej							
							SET @Query = '
								IF OBJECT_ID (N''[_' + @tableName + '_Cechy_Hist]'', N''U'') IS NOT NULL
								BEGIN
									INSERT INTO #CechyObiektuMain (Id, ObiektId)
									SELECT allData.Id, allData.ObiektId FROM
									(
										SELECT ch.Id, ch.ObiektId, ROW_NUMBER() OVER(PARTITION BY ISNULL(ch.IdArch, ch.Id) ORDER BY ch.Id ASC) AS Rn
										FROM [dbo].[_' + @tableName + '_Cechy_Hist] ch
										INNER JOIN
										(
											SELECT ISNULL(ch2.IdArch, ch2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, ch2.' + @DateFromColumnName + ' AS MaxDate
											FROM [dbo].[_' + @tableName + '_Cechy_Hist] ch2								 
											INNER JOIN 
											(
												SELECT ISNULL(ch3.IdArch, ch3.Id) AS RowID, MAX(ch3.' + @DateFromColumnName + ') AS MaxDate
												FROM [dbo].[_' + @tableName + '_Cechy_Hist] ch3															
												JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch3.CechaID)
												WHERE ch3.IsMainHistFlow = 1
												AND ch3.ObiektId IN (SELECT DISTINCT ISNULL(IdArch, Id) FROM #ObiektyMainFinal)'
																	
							--dodanie frazy statusow na filtracje jesli trzeba
							SET @Query += [THB].[PrepareStatusesPhraseForAttributes] ('ch3', @StatusS, @StatusP, @StatusW);
							SET @Query += [THB].[PrepareStatusesPhrase] ('c', @StatusS, @StatusP, @StatusW);
							
							--dodanie frazy na daty
							SET @Query += [THB].[PrepareDatesPhrase] ('ch3', @AppDate);
							SET @Query += [THB].[PrepareDatesPhrase] ('c', @AppDate);
							
							--filtracja po cechach ktore moze widziec uzytkownik
							IF @CechyWidoczneDlaUzytkownika IS NOT NULL
								SET @Query += @CechyWidoczneDlaUzytkownika;																
											
							SET @Query += '
											GROUP BY ISNULL(ch3.IdArch, ch3.Id)
										) latest
										ON ISNULL(ch2.IdArch, ch2.Id) = latest.RowID AND ch2.' + @DateFromColumnName + ' = latest.MaxDate
										WHERE ch2.IsMainHistFlow = 1
										GROUP BY ISNULL(ch2.IdArch, ch2.Id), ch2.' + @DateFromColumnName + '					
									) latestWithMaxDate
									ON  ISNULL(ch.IdArch, ch.Id) = latestWithMaxDate.RowID AND ch.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND ch.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
									WHERE ch.IsMainHistFlow = 1
								) allData
								WHERE allData.Rn = 1
							END'
			
							--PRINT @Query;
							EXECUTE sp_executesql @Query;					
							
							SET @Query = N'
								INSERT INTO #CechyObiektu(ObiektId, Id, CechaId, TypCechyId, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
									[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
									[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
									[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
									[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow])
								SELECT ch.ObiektId, ch.Id, ch.CechaID, c.TypID, c.CzySlownik, THB.GetAttributeValueFromSparseXML(ch.ColumnsSet), ch.ValString, ch.[IsStatus], ch.[StatusS], ch.[StatusSFrom],
									ch.[StatusSTo], ch.[StatusSFromBy], ch.[StatusSToBy], ch.[StatusW], ch.[StatusWFrom], ch.[StatusWTo], ch.[StatusWFromBy], ch.[StatusWToBy], ch.[StatusP],
									ch.[StatusPFrom], ch.[StatusPTo], ch.[StatusPFromBy], ch.[StatusPToBy], ch.[ObowiazujeOd], ch.[ObowiazujeDo], ch.[IsValid],
									ch.[ValidFrom], ch.[ValidTo], ch.[IsDeleted], ch.[DeletedFrom], ch.[DeletedBy], ch.[CreatedOn],
									ch.[CreatedBy], ch.[LastModifiedOn], ch.[LastModifiedBy], 
									CASE 
										WHEN tobc.ID IS NULL THEN 2
										ELSE ISNULL(tobc.[Priority], 0)
									END AS [Priority],
									CASE 
										WHEN tobc.ID IS NULL THEN 100
										ELSE ISNULL(tobc.[UIOrder], 0)
									END AS [UIOrder],
									ch.[IsAlternativeHistory], ch.[IsMainHistFlow]
								FROM [dbo].[_' + @tableName + '_Cechy_Hist] ch
								JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch.CechaID)
								LEFT OUTER JOIN dbo.[TypObiektu_Cechy] tobc ON (tobc.Cecha_ID = c.Cecha_ID AND tobc.TypObiektu_ID = ' + CAST(@TypObiektuId AS varchar) + ')
								WHERE tobc.IdArch IS NULL AND ch.Id IN (SELECT Id FROM #CechyObiektuMain)'
								
							SET @Query += [THB].[PrepareDatesPhrase] ('tobc', @AppDate); 
													
							--print @query
							EXECUTE sp_executesql @Query;
						END	

--SELECT * FROM #CechyObiektuMain	
--SELECT * FROM #CechyObiektu
						
						EXEC [THB].[GetUserAttributeTypes]
							@NazwaKolumnyZCecha = 'Cecha_ID',
							@DataProgramu = @DataProgramu,
							@UserId = @UzytkownikID,
							@BranchId = @BranzaId,
							@AtributeTypesWhere = @CechyWidoczneDlaUzytkownika OUTPUT							
	
						--pobranie danych Id pasujacych cech typu obiektu do tabeli tymczasowej							
						SET @Query = '
								INSERT INTO #CechyTypuObiektuWspolne(CechaId, [Priority], UIOrder)
								SELECT DISTINCT allData.Cecha_ID, allData.[Priority], allData.UIOrder
								FROM
								(
									SELECT o.Cecha_ID, o.[Priority], o.UIOrder, ROW_NUMBER() OVER(PARTITION BY ISNULL(o.IdArch, o.Id) ORDER BY o.Id ASC) AS Rn
									FROM [dbo].[TypObiektu_Cechy] o
									INNER JOIN
									(
										SELECT ISNULL(o2.IdArch, o2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, o2.' + @DateFromColumnName + ' AS MaxDate
										FROM [dbo].[TypObiektu_Cechy] o2								 
										INNER JOIN 
										(
											SELECT ISNULL(o3.IdArch, o3.Id) AS RowID, MAX(o3.' + @DateFromColumnName + ') AS MaxDate
											FROM [dbo].[TypObiektu_Cechy] o3
											WHERE TypObiektu_ID = ' + CAST(@TypObiektuId AS varchar);
											
						--dodanie frazy statusow na filtracje jesli trzeba
						SET @Query += [THB].[PrepareStatusesPhrase] ('o3', @StatusS, @StatusP, @StatusW);
						
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhrase] ('o3', @AppDate);
						
						--filtracja po cechach ktore moze widziec uzytkownik
						IF @CechyWidoczneDlaUzytkownika IS NOT NULL
							SET @Query += @CechyWidoczneDlaUzytkownika;																
										
						SET @Query += '
											GROUP BY ISNULL(o3.IdArch, o3.Id)
										) latest
										ON ISNULL(o2.IdArch, o2.Id) = latest.RowID AND o2.' + @DateFromColumnName + ' = latest.MaxDate
										GROUP BY ISNULL(o2.IdArch, o2.Id), o2.' + @DateFromColumnName + '					
									) latestWithMaxDate
									ON  ISNULL(o.IdArch, o.Id) = latestWithMaxDate.RowID AND o.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND o.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
								) allData
								WHERE allData.Rn = 1'
			
						--PRINT @Query;
						EXECUTE sp_executesql @Query;	
					
					END
					
					IF @stronicowanieWl = 1
					BEGIN
						--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
						SELECT @IloscRekordow = COUNT(Id) FROM #ObiektyMain;

					END
					
					IF Cursor_Status('local','cur2') > 0 
					BEGIN
						 CLOSE cur2
						 DEALLOCATE cur2
					END
					
					DECLARE cur2 CURSOR LOCAL FOR 
						SELECT Id, ISNULL(IdArch, Id) FROM #Obiekty ORDER BY Rn
					OPEN cur2
					FETCH NEXT FROM cur2 INTO @ObiektId, @IdArchObiektu
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						SET @query = N' SET @xmlOutVar = (';
						
						IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
						BEGIN
							SET @Query += ' SELECT ISNULL(obj.[IdArch], obj.[Id]) AS "@Id"
								, ' + CAST(@TypObiektuId AS varchar) + ' AS "@TypeId"
								,obj.[Nazwa] AS "@Name"
								,ISNULL(obj.[LastModifiedOn], obj.[CreatedOn]) AS "@LastModifiedOn"'
							
							IF @RozwijajPodwezly = 1
							BEGIN
						
								IF Cursor_Status('local','cur3') > 0 
								BEGIN
									 CLOSE cur3
									 DEALLOCATE cur3
								END
								
								--pobieranie danych podwezlow, cech obiektu
								DECLARE cur3 CURSOR LOCAL FOR 
									SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory FROM #CechyObiektu WHERE ObiektId = @IdArchObiektu ORDER BY Id --@ObiektId
								OPEN cur3
								FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory 
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
					
									--SET @QueryDlaCechy += [THB].[PrepareStatusesPhraseForAttributes] (NULL, @StatusS, @StatusP, @StatusW);
										
									SET @QueryDlaCechy += '
										ORDER BY ValidFrom DESC';
											
									--PRINT @query;
									EXECUTE sp_executesql @QueryDlaCechy, N'@CechaStatusS int OUTPUT, @CechaCzyDanaOsobowa bit OUTPUT, @CechaIsStatus bit OUTPUT', 
										@CechaStatusS = @CechaStatusS OUTPUT, @CechaCzyDanaOsobowa = @CechaCzyDanaOsobowa OUTPUT, @CechaIsStatus = @CechaIsStatus OUTPUT
									
									IF @CzyTabela = 1
									BEGIN
										SET @Query += ', 
										(SELECT obj.[Id] AS "@Id"'
									END
									ELSE
									BEGIN
										SET @Query += ', 
										(SELECT c.[Id] AS "@Id"'
									END									
									
									SET @Query += '
										,c.[CechaID] AS "@TypeId"
										,c.[Priority] AS "@Priority"
										,c.[UIOrder] AS "@UIOrder"
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
		------------------	
											--podmiana daty na format znany dla XMLa
											IF @CechaTyp = 'ValDatetime'
											BEGIN		
												SELECT @CechaWartosc = [THB].[ConvertDatetimeToXmlFormat](@CechaWartosc);
											END
									
											IF @CzySlownik = 0 AND @CechaTyp <> 'ValDictionary' 
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
																	FROM #CechyObiektu c2
																	WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) 
																		+ ' AND c2.ObiektId = ' + CAST(@IdArchObiektu AS varchar) + ' AND c.[CechaId] = c2.[CechaId]
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
											ELSE
											BEGIN
										
												-- pobranie nazwy slownika skojarzonego z cecha
												SET @NazwaSlownika = (SELECT Nazwa FROM [Slowniki] WHERE Id = @CechaTypId);
												
												IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
												BEGIN
													SET @Query += ', ' + CAST(@CechaWartosc AS varchar) + ' AS "ValDictionary/@ElementId"    --@CechaId
															, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"'
															
													IF @NazwaSlownika IS NOT NULL
														SET @Query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "ValDictionary/@DisplayValue"';
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
																	FROM #CechyObiektu c2
																		WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar)
																		+ ' AND c2.ObiektId = ' + CAST(@IdArchObiektu AS varchar) + ' AND c.[CechaId] = c2.[CechaId]
																	FOR XML PATH(''History''), TYPE)
																)
																FOR XML PATH(''ValDictionary''), TYPE)'										
												
												END
											END
										END								
									END								
									
									SET @Query += '	
										FROM #CechyObiektu c
										WHERE c.[Id] = ' + CAST(@CechaObiektuId AS varchar) + 'AND ObiektId = ' + CAST(@IdArchObiektu AS varchar) + ' 
										FOR XML PATH(''Attribute''), TYPE
										)'
										
									FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory								
								END
								CLOSE cur3;
								DEALLOCATE cur3;															
							END
						END
						ELSE -- pobierz wszystkie dane
						BEGIN
							SET @Query += ' SELECT ISNULL(obj.[IdArch], obj.[Id]) AS "@Id"
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
								
							IF @RozwijajPodwezly = 1
							BEGIN
							
								IF Cursor_Status('local','cur3') > 0 
								BEGIN
									 CLOSE cur3
									 DEALLOCATE cur3
								END
								
								--pobieranie danych podwezlow, cech obiektu
								DECLARE cur3 CURSOR LOCAL FOR 
									SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory FROM #CechyObiektu WHERE ObiektId = @IdArchObiektu ORDER BY Id
								OPEN cur3
								FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory 
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
					
									--SET @QueryDlaCechy += [THB].[PrepareStatusesPhraseForAttributes] (NULL, @StatusS, @StatusP, @StatusW);
										
									SET @QueryDlaCechy += '
										ORDER BY ValidFrom DESC';
											
									--PRINT @query;
									EXECUTE sp_executesql @QueryDlaCechy, N'@CechaStatusS int OUTPUT, @CechaCzyDanaOsobowa bit OUTPUT, @CechaIsStatus bit OUTPUT', 
										@CechaStatusS = @CechaStatusS OUTPUT, @CechaCzyDanaOsobowa = @CechaCzyDanaOsobowa OUTPUT, @CechaIsStatus = @CechaIsStatus OUTPUT
									
									IF @CzyTabela = 1
									BEGIN
										SET @Query += ', 
										(SELECT obj.[Id] AS "@Id"'
									END
									ELSE
									BEGIN
										SET @Query += ', 
										(SELECT c.[Id] AS "@Id"'
									END
									
									SET @Query += '
										,c.[CechaID] AS "@TypeId"
										,c.[Priority] AS "@Priority"
										,c.[UIOrder] AS "@UIOrder"								
										,c.[IsDeleted] AS "@IsDeleted"
										,c.[DeletedFrom] AS "@DeletedFrom"
										,c.[DeletedBy] AS "@DeletedBy"
										,c.[CreatedOn] AS "@CreatedOn"
										,c.[CreatedBy] AS "@CreatedBy"
										,c.[LastModifiedBy] AS "@LastModifiedBy"
										,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"'
									
									--te dane wyciagamy tylko dla zwyklych, bo dla tabelarycznych sa identyczne jak dane w obiektach	
									IF @CzyTabela = 0
									BEGIN
										SET @Query += '
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
									END
										
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
											
											--podmiana daty na format znany dla XMLa
											IF @CechaTyp = 'ValDatetime'
											BEGIN		
												SELECT @CechaWartosc = [THB].[ConvertDatetimeToXmlFormat](@CechaWartosc);
											END
											
											--czy cecha nie ma wartosci slownikowej			
											IF @CzySlownik = 0 AND @CechaTyp <> 'ValDictionary'
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
																	FROM #CechyObiektu c2
																	WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar)
																		+ ' AND c2.ObiektId = ' + CAST(@IdArchObiektu AS varchar) + ' AND c.[CechaId] = c2.[CechaId]
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
											ELSE
											BEGIN
												-- pobranie nazwy slownika skojarzonego z cecha
												SET @NazwaSlownika = (SELECT TOP 1 Nazwa FROM [Slowniki] WHERE Id = @CechaTypId);
												
												IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
												BEGIN
													SET @Query += ', ' + CAST(@CechaWartosc AS varchar) + ' AS "ValDictionary/@ElementId"   
															, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"'
															
													IF @NazwaSlownika IS NOT NULL
														SET @Query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "ValDictionary/@DisplayValue"';
												END
												ELSE
												BEGIN
													SET @Query += ', ( SELECT' + CAST(@CechaWartosc AS varchar) + ' AS "@ElementId"   
																, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"'
																
													IF @NazwaSlownika IS NOT NULL
														SET @query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "@DisplayValue"'
														
													SET @Query += ', (SELECT TOP 1 ISNULL(c2.[ZmianaOd], c2.[CreatedOn]) AS "@ChangeFrom"
																	,c2.[ZmianaDo] AS "@ChangeTo"
																	,ISNULL(c2.[ObowiazujeOd], c2.[CreatedOn]) AS "@EffectiveFrom"
																	,c2.[ObowiazujeDo] AS "@EffectiveTo"
																	,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																	FROM #CechyObiektu c2
																		WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) 
																		+ ' AND c2.ObiektId = ' + CAST(@IdArchObiektu AS varchar) + ' AND c.[CechaId] = c2.[CechaId]
																	FOR XML PATH(''History''), TYPE)
																)
																FOR XML PATH(''ValDictionary''), TYPE)'											
												END
											END
										END																								
									END								
							-- koniec wartosci cech	
									SET @Query += '	
										FROM #CechyObiektu c
										WHERE c.[Id] = ' + CAST(@CechaObiektuId AS varchar) + ' AND ObiektId = ' + CAST(@IdArchObiektu AS varchar) + '
										FOR XML PATH(''Attribute''), TYPE
										)'
										
									FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory								
								END
								CLOSE cur3;
								DEALLOCATE cur3;				
							END
						END
						
						--dodanie do Response Cech wynikajacych z typu obiektu, ktorych obiekt instancji nie posiada
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @query += '
								, (SELECT 0 AS "@Id"
										,bez.[CechaID] AS "@TypeId"
										,bez.[Priority] AS "@Priority"
										,bez.[UIOrder] AS "@UIOrder"								
										,''1753-12-31T00:00:00.000'' AS "@LastModifiedOn"
										FROM #CechyTypuObiektuWspolne bez
										WHERE bez.[CechaID] NOT IN (SELECT CechaId FROM #CechyObiektu c WHERE ObiektId = ' + CAST(@IdArchObiektu AS varchar) + ') 
										FOR XML PATH(''Attribute''), TYPE
										)'
						END
						
						SET @query += ' 
							FROM #Obiekty obj 						 
							 WHERE obj.Id = ' + CAST(@ObiektId AS varchar) + '
							 FOR XML PATH(''Unit'')
							)' 							
						
						--PRINT @query
						EXECUTE sp_executesql @query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT
								
						SET @xmlVar += ISNULL(CAST(@xmlOut AS nvarchar(MAX)), '');
						SET @xmlOut = NULL;		
						
						FETCH NEXT FROM cur2 INTO @ObiektId, @IdArchObiektu
					END
					CLOSE cur2;
					DEALLOCATE cur2;
					
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'UNIT_TYPE_NOT_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = @TypObiektuId, @Wiadomosc = @ERRMSG OUTPUT 			
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Units_GetOfType', @Wiadomosc = @ERRMSG OUTPUT 
		
			COMMIT TRANSACTION T_Units_GetOfType
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
				
				ROLLBACK TRANSACTION T_Units_GetOfType
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Units_GetOfType', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Units_GetOfType"'
	
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
		SET @xmlVar = THB.PrepareXMLRefValue(@xmlVar);
		
		--SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		SET @XMLDataOut += @xmlVar;
	END
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
		DROP TABLE #Obiekty
		
	IF OBJECT_ID('tempdb..#CechyObiektu') IS NOT NULL
		DROP TABLE #CechyObiektu
		
	IF OBJECT_ID('tempdb..#CechyObiektuMain') IS NOT NULL
		DROP TABLE #CechyObiektuMain
			
	IF OBJECT_ID('tempdb..#CechyTypuObiektuWspolne') IS NOT NULL
		DROP TABLE #CechyTypuObiektuWspolne
		
	IF OBJECT_ID('tempdb..#ObiektyMain') IS NOT NULL
		DROP TABLE #ObiektyMain
		
	IF OBJECT_ID('tempdb..#ObiektyMainFinal') IS NOT NULL
		DROP TABLE #ObiektyMainFinal
		
	IF OBJECT_ID('tempdb..#KolumnyTypuObiektu') IS NOT NULL
		DROP TABLE #KolumnyTypuObiektu
		
	IF OBJECT_ID('tempdb..#CTS_GetOfType') IS NOT NULL
		DROP TABLE #CTS_GetOfType
		
	IF OBJECT_ID('tempdb..#WartosciCechObiektowTabelarycznych') IS NOT NULL
		DROP TABLE #WartosciCechObiektowTabelarycznych
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
