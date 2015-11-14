-- =============================================
-- Author:		DK
-- Create date: 2012-03-30
-- Last modified on: 2013-04-15
-- Description:	Zwraca historie obiektow o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Units_GetHistory" UserId="1" AppDate="2012-09-09T12:34:33">
		--<ObjectRef Id="1" TypeId="4" EntityType="Unit" />
		--<ObjectRef Id="2" TypeId="3" EntityType="Unit" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Units_GetHistory" AppDate="2012-09-09">

	--<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	 
	-- <HistoryOf Id="1" TypeId="20" EntityType="Unit">
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
	--			<ValDecimal Value="43.008">
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />
	--			</ValDecimal>
	--		</Attribute>
	--		<Unit Id="1" TypeId="20" Name="21323123" Version="12"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--		<Attribute Id="1" TypeId="12" Priority="1" UIOrder="2"
	--			IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--			<ValDictionary Id="12" ElementId="23">
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />                
	--			</ValDictionary>
	--		</Attribute>
	--	</Unit>    
	-- </HistoryOf> 
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Units_GetHistory]
(	
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@TableName nvarchar(256),
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
		@ObiektId int,
		@MaUprawnienia bit = 0,
		@ERRMSG nvarchar(255),
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
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
		@CechaHasAlternativeHistory bit = 0,
		@CechyWidoczneDlaUzytkownika nvarchar(MAX),
		@NazwaSlownika nvarchar(500),
		@CechaStatusS int,
		@CechaCzyDanaOsobowa bit,
		@CechaIsStatus bit,
		@QueryDlaCechy nvarchar(MAX) = '',
		@AppDate datetime,
		@DateFromColumnName nvarchar(100),
		
		@CzyTabela bit,
		@TypKolumny varchar(100),
		@NazwaKolumny nvarchar(150),
		@CechaIdKolumny int,
		@UnitTypeColumns nvarchar(MAX) = '',
		@ObiektIdDlaCechy int,
		@WartoscCechy nvarchar(MAX),
		@WartoscCechyString nvarchar(MAX),
		@WartoscCechyXml nvarchar(MAX),
		@CzyTabelaCounter int = 0
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DoPobrania') IS NOT NULL
		DROP TABLE #DoPobrania
		
	IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
		DROP TABLE #Obiekty
		
	IF OBJECT_ID('tempdb..#CechyObiektu') IS NOT NULL
		DROP TABLE #CechyObiektu
		
	IF OBJECT_ID('tempdb..#KolumnyTypuObiektu') IS NOT NULL
		DROP TABLE #KolumnyTypuObiektu
		
	CREATE TABLE #Obiekty(MainId int, TypObiektuId int, Id int, Wersja int, Nazwa nvarchar(256), IsStatus bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,[StatusSFromBy] int,
		[StatusSToBy] int, [StatusW] int, [StatusWFrom] datetime, [StatusWTo] datetime, [StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,[StatusPTo] datetime,
		[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,[ValidFrom] datetime,[ValidTo] datetime,
		[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,[CreatedBy] int,[LastModifiedOn] datetime,
		[LastModifiedBy] int,[IsAlternativeHistory] bit,[IsMainHistFlow] bit);	
	
	CREATE TABLE #CechyObiektu(TypObiektuId int, ObiektId int, Id int, CechaId int, TypCechyId int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), [IsStatus] bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,
		[StatusSFromBy] int,[StatusSToBy] int,[StatusW] int,[StatusWFrom] datetime,[StatusWTo] datetime,[StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,
		[StatusPTo] datetime,[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,
		[ValidFrom] datetime,[ValidTo] datetime,[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,
		[CreatedBy] int,[LastModifiedOn] datetime,[LastModifiedBy] int,[Priority] smallint,[UIOrder] smallint,[IsAlternativeHistory] bit,[IsMainHistFlow] bit);
		
	CREATE TABLE #DoPobrania(Id int, TypObiektuId int);
	CREATE TABLE #KolumnyTypuObiektu(CechaId int, NazwaKolumny nvarchar(150), TypKolumny varchar(50));
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Units_GetHistory', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

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
				,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
				,@BranzaId = C.value('./@BranchId', 'int')
				--,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
				--,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@StatusS =  C.value('./@StatusS','int') 
				,@StatusP = C.value('./@StatusP','int') 
				,@StatusW = C.value('./@StatusW','int')
		FROM @xml_data.nodes('/Request') T(C)
		
		--ustawienie na stale pobieranie wszystkich danych i rozwijanie podwezlow
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1; 
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #DoPobrania
		SELECT	C.value('./@Id', 'int')
			,C.value('./@TypeId', 'int')
		FROM @xml_data.nodes('/Request/ObjectRef') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Unit'

		IF @RequestType = 'Units_GetHistory'
		BEGIN
			BEGIN TRY
			
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
				--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
				IF Cursor_Status('local','cur') > 0 
				BEGIN
					 CLOSE cur
					 DEALLOCATE cur
				END
		
				-- pobranie daty na podstawie przekazanego AppDate
				SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
				
				--pobranie nazwy kolumny po ktorej filtrowane sa daty
				SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();
				
				DECLARE cur CURSOR LOCAL FOR 
					SELECT DISTINCT TypObiektuId FROM #DoPobrania
				OPEN cur
				FETCH NEXT FROM cur INTO @TypObiektuId
				WHILE @@FETCH_STATUS = 0
				BEGIN
					--pobranie nazwy typu obiektu po Id typu
					SELECT @tableName = t.Nazwa, @CzyTabela = Tabela 
					FROM dbo.TypObiektu t 
					WHERE t.TypObiekt_ID = @TypObiektuId
--select @TypObiektuId AS Id, @tableName AS Tabela, @CzyTabela			
					--pobieranie danych obiektow to tabel tymczasowych
					SET @query = N'
						INSERT INTO #Obiekty (MainId, TypObiektuId, Id, Wersja, Nazwa, IsStatus,[StatusS],[StatusSFrom],[StatusSTo],[StatusSFromBy],
							[StatusSToBy], [StatusW], [StatusWFrom], [StatusWTo], [StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],[StatusPTo],
							[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],[ValidFrom],[ValidTo],
							[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],[CreatedBy],[LastModifiedOn],
							[LastModifiedBy],[IsAlternativeHistory],[IsMainHistFlow])
						SELECT ISNULL(IdArch, Id),' + CAST(@TypObiektuId AS varchar) + ', Id, Wersja, Nazwa, IsStatus,[StatusS],[StatusSFrom],[StatusSTo],[StatusSFromBy],
							[StatusSToBy], [StatusW], [StatusWFrom], [StatusWTo], [StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],[StatusPTo],
							[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],[ValidFrom],[ValidTo],
							[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],[CreatedBy],[LastModifiedOn],
							[LastModifiedBy],[IsAlternativeHistory],[IsMainHistFlow]
						FROM [dbo].[_' + @tableName + '] 
						WHERE (Id IN (SELECT Id FROM #DoPobrania WHERE TypObiektuId = ' + CAST(@TypObiektuId AS varchar) + ') OR IdArch IN (SELECT Id FROM #DoPobrania WHERE TypObiektuId = ' + CAST(@TypObiektuId AS varchar) + '))';
					
						--dodanie frazy statusow na filtracje jesli trzeba
						SET @Query += [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);
						
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhraseForHistory] (NULL, @AppDate);
					
						PRINT @query
						EXECUTE sp_executesql @Query;			
					
					-- jesli typ obiektu zdefiniownay jako tabelaryczny (cechy wprost w tabeli)			
						IF @CzyTabela = 1
						BEGIN
										
							SET @CzyTabelaCounter = 0;
							SET @UnitTypeColumns = '';
						
							DELETE FROM #KolumnyTypuObiektu;
						
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
						
							--pobranie nazw i typow kolumn/cech
							--INSERT INTO #KolumnyTypuObiektu (NazwaKolumny, TypKolumny, CechaId)
							--SELECT c.Nazwa, ct.NazwaSql, c.Cecha_Id
							--FROM dbo.TypObiektu_Cechy toc
							--JOIN dbo.Cechy c ON (c.Cecha_Id = toc.Cecha_Id)
							--JOIN dbo.Cecha_Typy ct ON (c.TypId = ct.Id)
							--WHERE toc.TypObiektu_ID = @TypObiektuId AND toc.IsDeleted = 0;
							
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
								
								IF @NazwaKolumny <> 'Id' --AND @NazwaKolumny <> 'Nazwa'
									SET @UnitTypeColumns += ', [' + @NazwaKolumny + ']';
		
								FETCH NEXT FROM curColumns INTO @CechaIdKolumny, @NazwaKolumny, @TypKolumny
							END
							CLOSE curColumns;
							DEALLOCATE curColumns;
							
							SET @Query = '
										IF OBJECT_ID(''tempdb..##CechyTabelaryczne'') IS NOT NULL
											DROP TABLE ##CechyTabelaryczne;

										SELECT Id' + @UnitTypeColumns + '
										INTO ##CechyTabelaryczne
										FROM [_' + @TableName + '] ob
										WHERE ob.Id IN (SELECT Id FROM #ObiektyMain);' 
										  
							--PRINT @Query
							EXECUTE sp_executesql @Query;
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
							IF Cursor_Status('local','curObjects') > 0 
							BEGIN
								 CLOSE curObjects
								 DEALLOCATE curObjects
							END	
							
							DECLARE curObjects CURSOR LOCAL FOR 
								SELECT Id FROM ##CechyTabelaryczne;
							OPEN curObjects
							FETCH NEXT FROM curObjects INTO @ObiektIdDlaCechy
							WHILE @@FETCH_STATUS = 0
							BEGIN				
							
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
						
									SET @Query = '
										SELECT @WartoscCechy = [' + @NazwaKolumny + ']
										FROM ##CechyTabelaryczne
										WHERE Id = ' + CAST(@ObiektIdDlaCechy AS varchar);
										
									EXECUTE sp_executesql @Query, N'@WartoscCechy nvarchar(MAX) OUTPUT', @WartoscCechy = @WartoscCechy OUTPUT

									--pobrnaie danych cechy
									EXEC [THB].[PrepareTableAttributeValues]
										@DataType = @TypKolumny,
										@DataValue = @WartoscCechy,
										@StringValue = @WartoscCechyString OUTPUT,
										@XmlValue = @WartoscCechyXml OUTPUT
			

									SET @Query = '
										INSERT INTO #CechyObiektu(TypObiektuId, ObiektId, Id, CechaId, TypCechyId, CzySlownik, SparceValue, ValString,[ObowiazujeOd],[ObowiazujeDo],[IsValid],
											[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
											[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow])
										SELECT ' + CAST(@TypObiektuId AS varchar) + ', ch.Id, ' + CAST(@CzyTabelaCounter AS varchar) + ', c.Cecha_ID, c.TypID, c.CzySlownik, ' + @WartoscCechyXml + ', ''' + @WartoscCechyString + ''', ch.[ObowiazujeOd], ch.[ObowiazujeDo], ch.[IsValid],
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
										FROM [dbo].[_' + @tableName + '] ch
										JOIN dbo.[Cechy] c ON (c.Cecha_ID = ' + CAST(@CechaIdKolumny AS varchar) + ')
										LEFT OUTER JOIN dbo.[TypObiektu_Cechy] tobc ON (tobc.Cecha_ID = c.Cecha_ID AND tobc.TypObiektu_ID = ' + CAST(@TypObiektuId AS varchar) + ')
										WHERE tobc.IdArch IS NULL AND ch.Id = ' + CAST(@ObiektIdDlaCechy AS varchar)
										
										SET @CzyTabelaCounter -= 1;
									
									--PRINT @Query;
									EXECUTE sp_executesql @Query;
			
									FETCH NEXT FROM curColumns INTO @CechaIdKolumny, @NazwaKolumny, @TypKolumny
								END
								CLOSE curColumns;
								DEALLOCATE curColumns;
							
								FETCH NEXT FROM curObjects INTO @ObiektIdDlaCechy
							END					
							CLOSE curObjects;
							DEALLOCATE curObjects;
						END	
						ELSE
						BEGIN					
					
							SET @Query = N'
								INSERT INTO #CechyObiektu(TypObiektuId, ObiektId, Id, CechaId, TypCechyId, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
									[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
									[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
									[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
									[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow])
								SELECT ' + CAST(@TypObiektuId AS varchar) + ', ch.ObiektId, ch.Id, ch.CechaID, c.TypID, c.CzySlownik, THB.GetAttributeValueFromSparseXML(ch.ColumnsSet), ch.ValString, ch.[IsStatus], ch.[StatusS], ch.[StatusSFrom],
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
								WHERE tobc.IdArch IS NULL AND ObiektId IN (SELECT Id FROM #DoPobrania WHERE TypObiektuId = ' + CAST(@TypObiektuId AS varchar) + ') 				
							'
							
							--dodanie frazy statusow na filtracje jesli trzeba
							SET @Query += [THB].[PrepareStatusesPhraseForAttributes] ('ch', @StatusS, @StatusP, @StatusW);					
							
							--dodanie frazy na daty
							SET @Query += [THB].[PrepareDatesPhraseForHistory] ('ch', @AppDate);

							--filtracja po cechach ktore moze widziec uzytkownik
							IF @CechyWidoczneDlaUzytkownika IS NOT NULL
								SET @Query += @CechyWidoczneDlaUzytkownika;
												
							--PRINT @query
							EXECUTE sp_executesql @query;
						END 

					FETCH NEXT FROM cur INTO @TypObiektuId
				END
				CLOSE cur;
				DEALLOCATE cur;
				
				--SELECT * FROM #DoPobrania;
				--SELECT * FROM #Obiekty
				--SELECT * FROM #CechyObiektu
				
				IF Cursor_Status('local','cur2') > 0 
				BEGIN
					 CLOSE cur2
					 DEALLOCATE cur2
				END
				
				DECLARE cur2 CURSOR LOCAL FOR 
					SELECT DISTINCT Id, TypObiektuId FROM #DoPobrania
				OPEN cur2
				FETCH NEXT FROM cur2 INTO @ObiektId, @TypObiektuId
				WHILE @@FETCH_STATUS = 0
				BEGIN
		
					SET @Query = N' SET @xmlOutVar = (
								SELECT ' + CAST(@ObiektId AS varchar) + ' AS "@Id"
									, ' + CAST(@TypObiektuId AS varchar) + ' AS "@TypeId"
									, ''Unit'' AS "@EntityType"';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @Query += '	
										, (SELECT obj.[Id] AS "@Id"
										, ' + CAST(@TypObiektuId AS varchar) + ' AS "@TypeId"
										,obj.[Nazwa] AS "@Name"
										,obj.[Wersja] AS "@Version"
										,ISNULL(obj.[LastModifiedBy], obj.[CreatedBy]) AS "@LastModifiedBy"
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
								SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory  FROM #CechyObiektu WHERE TypObiektuId = @TypObiektuId AND ObiektId = @ObiektId ORDER BY Id 
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
								
								SET @QueryDlaCechy = '
									SELECT TOP 1 @CechaStatusS = StatusS, @CechaCzyDanaOsobowa = CzyJestDanaOsobowa, @CechaIsStatus = IsStatus
									FROM Cechy
									WHERE (Cecha_ID = ' + CAST(@CechaId AS varchar) + ' OR IdArch = ' + CAST(@CechaId AS varchar) + ')';
								
								--dodanie frazy na daty
								SET @QueryDlaCechy += [THB].[PrepareDatesPhrase] (NULL, @AppDate);

								SET @QueryDlaCechy += '
									ORDER BY ' + @DateFromColumnName + ' DESC';
										
								--PRINT @query;
								EXECUTE sp_executesql @QueryDlaCechy, N'@CechaStatusS int OUTPUT, @CechaCzyDanaOsobowa bit OUTPUT, @CechaIsStatus bit OUTPUT', 
									@CechaStatusS = @CechaStatusS OUTPUT, @CechaCzyDanaOsobowa = @CechaCzyDanaOsobowa OUTPUT, @CechaIsStatus = @CechaIsStatus OUTPUT
								
								
								IF @CzyTabela = 1
								BEGIN
									SET @Query += ' 
									,(SELECT obj.[Id] AS "@Id"'
								END
								ELSE
								BEGIN
									SET @Query += ' 
									,(SELECT c.[Id] AS "@Id"'
								END
								
								SET @Query += '
									,c.[CechaID] AS "@TypeId"
									,c.[Priority] AS "@Priority"
									,c.[UIOrder] AS "@UIOrder"
									,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"'
									
								--sprawdzenie czy cecha zawiera dane osobowe i ma status wiekszy niz status usera
								IF @CechaIsStatus = 1 AND @CechaCzyDanaOsobowa = 1 AND @CechaStatusS > @StatusS
								BEGIN
									SET @Query += ', ''' + THB.GetHiddenValue() + ''' AS "ValHidden/@Value"'
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
											SET @CechaWartosc = [THB].[PrepareCodedXML](@CechaWartoscRef);
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
										-- czy cecha nie posiada wartosci slownikowej
										IF @CzySlownik = 0 AND @CechaTyp <> 'ValDictionary'
										BEGIN
											
											--podmiana daty na format znany dla XMLa
											IF @CechaTyp = 'ValDatetime'
											BEGIN		
												SELECT @CechaWartosc = [THB].[ConvertDatetimeToXmlFormat](@CechaWartosc);
											END
											
											IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
											BEGIN
												SET @Query += ', ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "' + @CechaTyp + '/@Value"'
											END
											ELSE
											BEGIN
											
												SET @Query += ', ( SELECT ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "@Value"
															,( SELECT c2.[ZmianaOd] AS "@ChangeFrom"
																,c2.[ZmianaDo] AS "@ChangeTo"
																,c2.[ObowiazujeOd] AS "@EffectiveFrom"
																,c2.[ObowiazujeDo] AS "@EffectiveTo"
																,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																FROM #CechyObiektu c2
																WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																	+ ' AND c2.ObiektId = ' + CAST(@ObiektId AS varchar) + '  
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
												SET @Query += ', ' + CAST(@CechaWartosc AS varchar) + ' AS "ValDictionary/@ElementId" 
														, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"'
														
												IF @NazwaSlownika IS NOT NULL
													SET @Query += '	, (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "ValDictionary/@DisplayValue"';
											END
											ELSE
											BEGIN
												SET @Query += ', ( SELECT' + CAST(@CechaWartosc AS varchar) + ' AS "@ElementId"   
															, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"'
															
												IF @NazwaSlownika IS NOT NULL
													SET @Query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "@DisplayValue"'
													
												SET @Query += ', (SELECT c2.[ZmianaOd] AS "@ChangeFrom"
																,c2.[ZmianaDo] AS "@ChangeTo"
																,c2.[ObowiazujeOd] AS "@EffectiveFrom"
																,c2.[ObowiazujeDo] AS "@EffectiveTo"
																,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																FROM #CechyObiektu c2
																	WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																	+ ' AND c2.ObiektId = ' + CAST(@ObiektId AS varchar) + '
																FOR XML PATH(''History''), TYPE)
															)
															FOR XML PATH(''ValDictionary''), TYPE)'								
											END
										END
									END																		
								END								
								
								SET @Query += '	
									FROM #CechyObiektu c
									WHERE c.[Id] = ' + CAST(@CechaObiektuId AS varchar) + '
									AND c.ValidFrom <= obj.ValidFrom AND (c.ValidTo IS NULL OR ISNULL(obj.ValidTo, ''1900-01-01'') <= c.ValidTo)
									FOR XML PATH(''Attribute''), TYPE
									)'
									
								FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory								
							END
							CLOSE cur3;
							DEALLOCATE cur3;																						
						END
					END -- pobranie wszystkich danych
					ELSE
					BEGIN
						SET @Query += '							
									, (SELECT obj.[Id] AS "@Id"
										, ' + CAST(@TypObiektuId AS varchar) + ' AS "@TypeId"
										,obj.[Nazwa] AS "@Name"
										,obj.[Wersja] AS "@Version"
										,obj.[IsDeleted] AS "@IsDeleted"
										,obj.[DeletedFrom] AS "@DeletedFrom"
										,obj.[DeletedBy] AS "@DeletedBy"
										,obj.[CreatedOn] AS "@CreatedOn"
										,obj.[CreatedBy] AS "@CreatedBy"
										,ISNULL(obj.[LastModifiedBy], obj.[CreatedBy]) AS "@LastModifiedBy"
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
								SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory  FROM #CechyObiektu WHERE TypObiektuId = @TypObiektuId AND ObiektId = @ObiektId ORDER BY Id 
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
								
								SET @QueryDlaCechy = '
									SELECT TOP 1 @CechaStatusS = StatusS, @CechaCzyDanaOsobowa = CzyJestDanaOsobowa, @CechaIsStatus = IsStatus
									FROM Cechy
									WHERE (Cecha_ID = ' + CAST(@CechaId AS varchar) + ' OR IdArch = ' + CAST(@CechaId AS varchar) + ')';
								
								--dodanie frazy na daty
								SET @QueryDlaCechy += [THB].[PrepareDatesPhrase] (NULL, @AppDate);

								SET @QueryDlaCechy += '
									ORDER BY ' + @DateFromColumnName + ' DESC';
										
								--PRINT @query;
								EXECUTE sp_executesql @QueryDlaCechy, N'@CechaStatusS int OUTPUT, @CechaCzyDanaOsobowa bit OUTPUT, @CechaIsStatus bit OUTPUT', 
									@CechaStatusS = @CechaStatusS OUTPUT, @CechaCzyDanaOsobowa = @CechaCzyDanaOsobowa OUTPUT, @CechaIsStatus = @CechaIsStatus OUTPUT
								
								IF @CzyTabela = 1
								BEGIN
									SET @Query += '
									,(SELECT obj.[Id] AS "@Id"'
								END
								ELSE
								BEGIN
									SET @Query += ' 
									,(SELECT c.[Id] AS "@Id"'
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
										,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
										,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
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
									SET @Query += ', ''' + THB.GetHiddenValue() + ''' AS "ValHidden/@Value"'
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
											SET @CechaWartosc = [THB].[PrepareCodedXML](@CechaWartoscRef);
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
										
										-- czy cecha nie posiada wartosci slownikowej
										IF @CzySlownik = 0 AND @CechaTyp <> 'ValDictionary'
										BEGIN
											IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
												SET @Query += ', ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "' + @CechaTyp + '/@Value"'
											ELSE
											BEGIN
											
												SET @Query += ', ( SELECT ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "@Value"
															,( SELECT c2.[ZmianaOd] AS "@ChangeFrom"
																,c2.[ZmianaDo] AS "@ChangeTo"
																,c2.[ObowiazujeOd] AS "@EffectiveFrom"
																,c2.[ObowiazujeDo] AS "@EffectiveTo"
																,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																FROM #CechyObiektu c2
																WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																	+ ' AND c2.ObiektId = ' + CAST(@ObiektId AS varchar) + ' 
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
												SET @Query += ', ' + CAST(@CechaWartosc AS varchar) + ' AS "ValDictionary/@ElementId"   
														, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"'
														
												IF @NazwaSlownika IS NOT NULL
													SET @Query += '	, (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "ValDictionary/@DisplayValue"';
											END
											ELSE
											BEGIN
												SET @Query += ', ( SELECT' + CAST(@CechaWartosc AS varchar) + ' AS "@ElementId"    
															, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"'
															
												IF @NazwaSlownika IS NOT NULL
													SET @Query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "@DisplayValue"'
													
												SET @Query += ', (SELECT c2.[ZmianaOd] AS "@ChangeFrom"
																,c2.[ZmianaDo] AS "@ChangeTo"
																,c2.[ObowiazujeOd] AS "@EffectiveFrom"
																,c2.[ObowiazujeDo] AS "@EffectiveTo"
																,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
																FROM #CechyObiektu c2
																	WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																	+ ' AND c2.ObiektId = ' + CAST(@ObiektId AS varchar) + '  
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
									WHERE c.[Id] = ' + CAST(@CechaObiektuId AS varchar) + '
									AND c.ValidFrom <= obj.ValidFrom AND (c.ValidTo IS NULL OR ISNULL(obj.ValidTo, ''1900-01-01'') <= c.ValidTo)
									FOR XML PATH(''Attribute''), TYPE
									)
								'
									
								FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory								
							END
							CLOSE cur3;
							DEALLOCATE cur3;							
						
						END		
					END
					
					SET @Query += ' 
						 FROM #Obiekty obj 
						 WHERE obj.MainId = ' + CAST(@ObiektId AS varchar) + ' AND TypObiektuId = ' + CAST(@TypObiektuId AS varchar) + '  
						 FOR XML PATH(''Unit''), TYPE
						)
						FOR XML PATH(''HistoryOf''))' 
					
					--PRINT @query
					EXECUTE sp_executesql @query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT			
					
					SET @xmlVar += CONVERT(nvarchar(MAX), @xmlOut);

					FETCH NEXT FROM cur2 INTO @ObiektId, @TypObiektuId
				END
				CLOSE cur2;
				DEALLOCATE cur2;					
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Units_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Units_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Units_GetHistory"'
	
	IF @DataProgramu IS NOT NULL	
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>'

	IF @ERRMSG iS NULL OR @ERRMSG = ''
	BEGIN		
		--SET @XMLDataOut += ISNULL(CAST(@xmlVar AS nvarchar(MAX)), '');
		SET @XMLDataOut += CONVERT(nvarchar(MAX), @xmlVar);	
	END
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';		

		--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DoPobrania') IS NOT NULL
		DROP TABLE #DoPobrania
		
	IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
		DROP TABLE #Obiekty
		
	IF OBJECT_ID('tempdb..#CechyObiektu') IS NOT NULL
		DROP TABLE #CechyObiektu
		
	IF OBJECT_ID('tempdb..#KolumnyTypuObiektu') IS NOT NULL
		DROP TABLE #KolumnyTypuObiektu
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
