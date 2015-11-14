-- =============================================
-- Author:		DK
-- Create date: 2012-04-05
-- Last modified on: 2013-02-14
-- Description:	Zwraca historie relacji o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Relations_GetHistory" UserId="1" AppDate="2012-09-20T11:34:23" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="Relation" />
	--	<Ref Id="2" EntityType="Relation" />
	--	<Ref Id="3" EntityType="Relation" />
	--	<Ref Id="4" EntityType="Relation" />
	--	<Ref Id="5" EntityType="Relation" />
	--	<Ref Id="6" EntityType="Relation" />
	--	<Ref Id="7" EntityType="Relation" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="UnitsOfMeasure_Get" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="10.3.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	--<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	 
	-- <HistoryOf Id="1" EntityType="UnitOfMeasure">
	--	<UnitOfMeasure Id="1" Name="centymetr" ShortName="cm" Comment="??" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<Conversions>
	--			<UnitsOfMeasureConversion UOMId="2" Ratio="0.01"/>
	--		</Conversions>
	--	</UnitOfMeasure>
	--	<UnitOfMeasure Id="1" Name="centymetr" ShortName="cm" Comment="??" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<Conversions>
	--			<UnitsOfMeasureConversion UOMId="2" Ratio="0.01"/>
	--		</Conversions>
	--	</UnitOfMeasure>
	--	<UnitOfMeasure Id="1" Name="centymetr" ShortName="cm" Comment="??" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<Conversions>
	--			<UnitsOfMeasureConversion UOMId="2" Ratio="0.01"/>
	--		</Conversions>
	--	</UnitOfMeasure>
	-- </HistoryOf>
	 
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Relations_GetHistory]
(	
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@RequestType nvarchar(100),
		@xml_data xml,
		@xmlOk bit = 0,
		@xmlOut xml,
		@DataProgramu datetime,
		@UzytkownikID int = NULL,
		@BranzaID int,
		@xmlVar nvarchar(MAX) = '',
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
		@CechaRelacjiId int,
		@CechaId int,
		@CechaHasAlternativeHistory bit = 0,
		@IdRelacji int,
		@TypRelacjiId int,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@AppDate datetime,
		@CechaStatusS int,
		@CechaCzyDanaOsobowa bit,
		@CechaIsStatus bit,
		@QueryDlaCechy nvarchar(MAX)
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DoPobrania') IS NOT NULL
		DROP TABLE #DoPobrania
	
	IF OBJECT_ID('tempdb..#CechyRelacji') IS NOT NULL
		DROP TABLE #CechyRelacji
		
	CREATE TABLE #CechyRelacji(Id int, RelacjaId int, CechaId int, TypCechyId int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), [IsStatus] bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,
		[StatusSFromBy] int,[StatusSToBy] int,[StatusW] int,[StatusWFrom] datetime,[StatusWTo] datetime,[StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,
		[StatusPTo] datetime,[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,
		[ValidFrom] datetime,[ValidTo] datetime,[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,
		[CreatedBy] int,[LastModifiedOn] datetime,[LastModifiedBy] int,[Priority] smallint,[UIOrder] smallint);
		
	CREATE TABLE #DoPobrania(Id int);
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_GetHistory', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

	IF @xmlOk = 0
	BEGIN
		-- co zrobic jak nie poprawna walidacja XML
		SET @ERRMSG = @ERRMSG;
	END
	ELSE
	BEGIN
		--poprawny XML wejsciowy
		SET @xml_data = CAST(@XMLDataIn AS xml);
		
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1;
		
		--wyciaganie daty i typu zadania
		SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
				,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
				,@BranzaId = C.value('./@BranchId', 'int')
				--,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
				--,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
				,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
				,@StatusS = C.value('./@StatusS', 'int')
				,@StatusP = C.value('./@StatusP', 'int')
				,@StatusW = C.value('./@StatusW', 'int')
		FROM @xml_data.nodes('/Request') T(C) 
	
		--wyciaganie danych relacji do pobrania
		INSERT INTO #DoPobrania
		SELECT	C.value('./@Id', 'int')
		FROM @xml_data.nodes('/Request/Ref') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Relation'

		--SELECT * FROM #DoPobrania;

		IF @RequestType = 'Relations_GetHistory'
		BEGIN
			BEGIN TRY
			
			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
			
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			EXEC [THB].[CheckUserPermission]
				@Operation = N'GET',
				@UserId = @UzytkownikID,
				@BranchId = @BranzaId,
				@Result = @MaUprawnienia OUTPUT
			
			IF @MaUprawnienia = 1
			BEGIN				
				
				SET @Query = '					
				INSERT INTO #CechyRelacji(Id, RelacjaId, CechaId, TypCechyId, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
					[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
					[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
					[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
					[CreatedBy], [LastModifiedOn], [LastModifiedBy], [Priority], [UIOrder])					
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
						END AS [UIOrder] 
				FROM [dbo].[Relacja_Cecha_Hist] ch
				JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch.CechaID)
				JOIN dbo.[Relacje] r ON (r.Id = ch.RelacjaID)
				LEFT OUTER JOIN dbo.[TypRelacji_Cechy] trc ON (trc.Cecha_ID = c.Cecha_ID AND trc.TypRelacji_ID = r.TypRelacji_ID)
				WHERE ch.RelacjaID IN (SELECT DISTINCT ID FROM #DoPobrania)'
					
				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('ch', @AppDate);
				
				--dodanie frazy statusow na filtracje jesli trzeba
				SET @Query += [THB].[PrepareStatusesPhraseForAttributes] ('ch', @StatusS, @StatusP, @StatusW);
				
				--PRINT @Query;
				EXEC(@Query);
						
--SELECT * FROM #DoPobrania
--SELECT * FROM #CechyRelacji
				
				--sprawdzenie czy kursor istnieje, jesli tak to go usuwa			
				IF Cursor_Status('local','cur') > 0 
				BEGIN
					 CLOSE cur
					 DEALLOCATE cur
				END
				
				DECLARE cur CURSOR LOCAL FOR 
					SELECT DISTINCT Id FROM #DoPobrania
				OPEN cur
				FETCH NEXT FROM cur INTO @IdRelacji
				WHILE @@FETCH_STATUS = 0
				BEGIN
					--wyzerowanie zmiennej
					SET @TypRelacjiId = NULL;
					
					SET @TypRelacjiId = (SELECT TypRelacji_ID FROM dbo.Relacje WHERE Id = @IdRelacji);
				
					SET @query = N' SET @xmlOutVar = (
								SELECT ' + CAST(@IdRelacji AS varchar) + ' AS "@Id"
									, ' + CAST(@TypRelacjiId AS varchar) + ' AS "@TypeId"
									, ''Relation'' AS "@EntityType"';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @query += '	, (SELECT r.[Id] AS "@Id"
										, r.[TypRelacji_ID] AS "@TypeId"
										, r.[TypObiektuID_L] AS "ObjectLeft/@TypeId"
										, r.[ObiektID_L] AS "ObjectLeft/@Id"
										, r.[TypObiektuID_R] AS "ObjectRight/@TypeId"
										, r.[ObiektID_R] AS "ObjectRight/@Id"
										,ISNULL(r.[LastModifiedBy], r.[CreatedBy]) AS "@LastModifiedBy"
										,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"'
						
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
														
							IF Cursor_Status('local','cur2') > 0 
							BEGIN
								 CLOSE cur2
								 DEALLOCATE cur2
							END
						
							--pobieranie danych podwezlow, cech relacji
							DECLARE cur2 CURSOR LOCAL FOR 
								SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId  FROM #CechyRelacji WHERE RelacjaId = @IdRelacji
							OPEN cur2
							FETCH NEXT FROM cur2 INTO @CechaRelacjiId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId 
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
								SET @QueryDlaCechy += [THB].[PrepareDatesPhraseForHistory] (NULL, @AppDate);

								--SET @QueryDlaCechy += [THB].[PrepareStatusesPhraseForAttributes] (NULL, @StatusS, @StatusP, @StatusW);
									
								SET @QueryDlaCechy += '
									ORDER BY ValidFrom DESC';
									
								--PRINT @query;
								EXECUTE sp_executesql @QueryDlaCechy, N'@CechaStatusS int OUTPUT, @CechaCzyDanaOsobowa bit OUTPUT, @CechaIsStatus bit OUTPUT', 
									@CechaStatusS = @CechaStatusS OUTPUT, @CechaCzyDanaOsobowa = @CechaCzyDanaOsobowa OUTPUT, @CechaIsStatus = @CechaIsStatus OUTPUT															
									
								SET @query += ', (SELECT c.[Id] AS "@Id"
									,c.[CechaID] AS "@TypeId"
									,c.[Priority] AS "@Priority"
									,c.[UIOrder] AS "@UIOrder"
									,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"'
									
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
										IF @CzySlownik = 0
											SET @query += ', ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "' + @CechaTyp + '/@Value"'									
										ELSE
											SET @query += ', ' + CAST(@CechaWartosc AS varchar) + ' AS "ValDictionary/@ElementId"   --@CechaId
													, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"';
									END
								END
								
								SET @query += '	
									FROM #CechyRelacji c
									WHERE c.[RelacjaId] = ' + CAST(@IdRelacji AS varchar) + ' AND Id = ' + CAST(@CechaRelacjiId AS varchar) + '
									AND c.ValidFrom <= r.ValidFrom AND (c.ValidTo IS NULL OR c.ValidTo <= r.ValidTo) 
									FOR XML PATH(''Attribute''), TYPE
									)'
									
								FETCH NEXT FROM cur2 INTO @CechaRelacjiId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId
								
							END
							CLOSE cur2;
							DEALLOCATE cur2;
						END
					END 
					ELSE
					BEGIN
						--pobranie wszystkich danych
						SET @query += ', (SELECT r.[Id] AS "@Id"
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
								SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId  FROM #CechyRelacji WHERE RelacjaId = @IdRelacji
							OPEN cur2
							FETCH NEXT FROM cur2 INTO @CechaRelacjiId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId 
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
								SET @QueryDlaCechy += [THB].[PrepareDatesPhraseForHistory] (NULL, @AppDate);

								--SET @QueryDlaCechy += [THB].[PrepareStatusesPhraseForAttributes] (NULL, @StatusS, @StatusP, @StatusW);
									
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
										IF @CzySlownik = 0
											SET @query += ', ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "' + @CechaTyp + '/@Value"'									
										ELSE
											SET @query += ', ' + CAST(@CechaWartosc AS varchar) + ' AS "ValDictionary/@ElementId"   --@CechaId
													, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"';
									END
								END
									
								SET @query += '	
									FROM #CechyRelacji c
									WHERE c.[RelacjaId] = ' + CAST(@IdRelacji AS varchar) + ' AND Id = ' + CAST(@CechaRelacjiId AS varchar) + '
									AND c.ValidFrom <= r.ValidFrom AND (c.ValidTo IS NULL OR c.ValidTo <= r.ValidTo)  
									FOR XML PATH(''Attribute''), TYPE
									)'
									
								FETCH NEXT FROM cur2 INTO @CechaRelacjiId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId
								
							END
							CLOSE cur2;
							DEALLOCATE cur2;
						END	
					END						
						
					SET @Query += ' 
						FROM [Relacje] r
							WHERE (r.Id = ' + CAST(@IdRelacji AS varchar) + ' OR r.IdArch = ' + CAST(@IdRelacji AS varchar) + ')';
							
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhraseForHistory] ('r', @AppDate);

					SET @Query += ' 
							FOR XML PATH(''Relation''), TYPE
						)
						FOR XML PATH(''HistoryOf''))';
					
					--PRINT @query
					EXECUTE sp_executesql @query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT
	
					--SELECT @xmlOut;					
					SET @xmlVar += ISNULL(CAST(@xmlOut AS nvarchar(MAX)), '');
					SET @xmlOut = NULL;			
					
					FETCH NEXT FROM cur INTO @IdRelacji
				END
				CLOSE cur;
				DEALLOCATE cur;					
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Relations_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Relations_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Relations_GetHistory"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		--SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		SET @XMLDataOut += @xmlVar;
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';		

		--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DoPobrania') IS NOT NULL
		DROP TABLE #DoPobrania
		
	IF OBJECT_ID('tempdb..#CechyRelacji') IS NOT NULL
		DROP TABLE #CechyRelacji
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
