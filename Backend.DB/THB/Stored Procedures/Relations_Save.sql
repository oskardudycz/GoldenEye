-- =============================================
-- Author:		DK
-- Create date: 2012-04-01
-- Last modified on: 2013-02-12
-- Description:	Zapisuje dane relacji. Aktualizuje istniejacy lub wstawia nowy rekord.

-- Przykladowy plik XML wejsciowy:
	--<?xml version="1.0"?>
	--<Request RequestType="Relations_Save" UserId="1" AppDate="2012-02-09T11:23:22">
	--	<Relation Id="1" TypeId="23" IsOuter="false" SourceId="0" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<ObjectLeft Id="3" TypeId="5"/>
	--		<ObjectRight Id="5" TypeId="2"/>
	--	</Relation>
	--	<Relation Id="2" TypeId="3" IsOuter="false" SourceId="0" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<ObjectLeft Id="3" TypeId="5"/>
	--		<ObjectRight Id="5" TypeId="2"/>
	--		<Attribute Id="4" TypeId="66" Priority="0" UIOrder="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<ValDecimal Value="46.09"/>
	--		</Attribute>
	--		<Attribute Id="5" TypeId="68" Priority="0" UIOrder="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<ValDictionary Id="5" ElementId="23"/>
	--		</Attribute>
	--	</Relation>
	--</Request>
	
-- Przykladowy plik XML wyjsciowy:
	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Relations_Save" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="2.4.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="Relation" />
	--			<Ref Id="2" EntityType="Relation" />
	--			<Ref Id="3" EntityType="Relation" />
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Relations_Save]
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
		@Query nvarchar(MAX) = '',
		@xml_data xml,
		@BranzaID int,
		@Id int,
		@TypRelacjiId int,
		@Index int,
		@IsOuter bit,
		@SourceId int,
		@LastModifiedOn datetime,
		@Uwagi nvarchar(MAX),
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@PrzetwarzanaRelacjaId int,
		@Skip bit = 0,
		@MaUprawnienia bit = 0,
		@Counter int = 0,
		@IloscRelacji int = 0,
		@CechaId int,
		@WartoscCechy nvarchar(MAX),
		@WartoscCechyQuery nvarchar(MAX),
		@CechaIndex int,
		@IdCechyRelacji int,
		@UIOrder smallint,
		@Priority smallint,
		@CechaWartoscXML xml,
		@TypWartosciCechy varchar(20),
		@IdSlownika int,
		@IdElementuSlownika int,
		@CounterCechRelacji int,
		@LObiektId int,
		@PObiektId int,
		@LObiektTypId int,
		@PObiektTypId int,		
		@JestNowaWartoscCechy bit = 0,
		@Commit bit = 1,
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacaRelacjaId int,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@DataObowiazywaniaOdStr varchar(30),
		@DataObowiazywaniaDoStr varchar(30),
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@IsStatus bit,
		@StatusSStr varchar(7),
		@StatusPStr varchar(7),
		@StatusWStr varchar(7),
		@OldTypStrukturyObiektId int,
		@OldTypObiektuID_L int,
		@OldTypObiektuID_R int,
		@OldObiektID_L int,
		@OldObiektID_R int,
		@OldTypRelacjiId int,
		@OldSourceId int,
		@OldIsStatus bit,
		@OldStatusS int,
		@OldStatusW int,
		@OldStatusP int,
		@OldIsOuter bit,
		@SaNoweCechy bit,
		@AttributeIndex int,
		--@PrzedzialCzasowyId int,
		@PrzedzialMinDate datetime,
		@PrzedzialMaxDate datetime			

	BEGIN TRY
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Relations_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
				
			--usuwanie tabel tymczasowych, jesli istnieja
			IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
				DROP TABLE #Relacje
				
			IF OBJECT_ID('tempdb..#LeweObiektyRelacji') IS NOT NULL
				DROP TABLE #LeweObiektyRelacji
				
			IF OBJECT_ID('tempdb..#PraweObiektyRelacji') IS NOT NULL
				DROP TABLE #PraweObiektyRelacji
				
			IF OBJECT_ID('tempdb..#CechyRelacji') IS NOT NULL
				DROP TABLE #CechyRelacji
				
			IF OBJECT_ID('tempdb..#WartosciCech') IS NOT NULL
				DROP TABLE #WartosciCech
				
			IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
				DROP TABLE #IDZmienionych
				
			IF OBJECT_ID('tempdb..#RelacjeKonfliktowe') IS NOT NULL
				DROP TABLE #RelacjeKonfliktowe
			
			IF OBJECT_ID('tempdb..#RelacjeNieUnikalne') IS NOT NULL
				DROP TABLE #RelacjeNieUnikalne
				
			IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
				DROP TABLE #Historia
			
			IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
				DROP TABLE #Statusy	
				
			IF OBJECT_ID('tempdb..#HistoriaCech') IS NOT NULL
				DROP TABLE #HistoriaCech
			
			IF OBJECT_ID('tempdb..#StatusyCech') IS NOT NULL
				DROP TABLE #StatusyCech
				
			CREATE TABLE #RelacjeKonfliktowe(ID int);	
			CREATE TABLE #RelacjeNieUnikalne(ID int);
				
			CREATE TABLE #IDZmienionych (ID int);
			CREATE TABLE #WartosciCech (RootIndex int, [AttributeIndex] int, Value xml);
			CREATE TABLE #LeweObiektyRelacji (RootIndex int, ObiektId int, TypObiektuId int);
			CREATE TABLE #PraweObiektyRelacji (RootIndex int, ObiektId int, TypObiektuId int);
			
			CREATE TABLE #CechyRelacji (RootIndex int, AttributeIndex int, Id int, CechaId int, [Priority] smallint,
				UIOrder smallint, LastModifiedOn datetime);
			
			CREATE TABLE #StatusyCech (RootIndex int, AttributeIndex int, IsStatus bit, StatusP int, StatusPFrom datetime, StatusPTo datetime,
				StatusPFromBy int, StatusPToBy int, StatusS int, StatusSFrom datetime, StatusSTo datetime, StatusSFromBy int, StatusSToBy int,
				StatusW int, StatusWFrom datetime, StatusWTo datetime, StatusWFromBy int, StatusWToBy int);
		
			CREATE TABLE #HistoriaCech (RootIndex int, AttributeIndex int, ZmianaOd datetime, ZmianaDo datetime, DataObowiazywaniaOd datetime, DataObowiazywaniaDo datetime,
				IsAlternativeHistory bit, IsMainHistFlow bit);
			
			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);
		
			SET @IloscRelacji = (SELECT @xml_data.value('count(/Request/Relation)','int'));
		
			--odczytywanie danych relacji
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscRelacji
			)
			SELECT 	j AS 'Index'
				   ,x.value('./@Id', 'int') AS ID
				   ,x.value('./@TypeId', 'int') AS TypRelacjiId
				   ,x.value('./@IsOuter', 'bit') AS IsOuter
				   ,x.value('./@SourceId', 'int') AS SourceId
				   ,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
			INTO #Relacje
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Relation[position()=sql:column("j")]')  e(x);
			
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscRelacji
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
			CROSS APPLY @xml_data.nodes('/Request/Relation[position()=sql:column("j")]/Statuses')  e(x);
			
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscRelacji
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
			CROSS APPLY @xml_data.nodes('/Request/Relation[position()=sql:column("j")]/History')  e(x);
			
			--odczytywanie danych lewych obiektow relacji
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscRelacji
			)
			INSERT INTO #LeweObiektyRelacji (RootIndex, ObiektId, TypObiektuId)
			SELECT 	j
				   ,x.value('./@Id', 'int')
				   ,x.value('./@TypeId', 'int')
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Relation[position()=sql:column("j")]/ObjectLeft')  e(x);
			
			--odczytywanie danych prawych obiektow relacji
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscRelacji
			)
			INSERT INTO #PraweObiektyRelacji (RootIndex, ObiektId, TypObiektuId)
			SELECT 	j
				   ,x.value('./@Id', 'int')
				   ,x.value('./@TypeId', 'int')
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Relation[position()=sql:column("j")]/ObjectRight')  e(x);				
			
			--pobieranie wartosci cech dla relacji i innych danych podrzednych
			SET @Counter = 0;
			
			WHILE @Counter <= @IloscRelacji
			BEGIN
				
				SET @Query = '	
					;WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Relation[position()=' + CAST(@Counter AS varchar) + ']/Attribute)'', ''int'') )
					)
					INSERT INTO #CechyRelacji (RootIndex, AttributeIndex, Id, CechaId, [Priority], UIOrder, LastModifiedOn)
					SELECT ' + CAST(@Counter AS varchar) + '
						,j
						,x.value(''./@Id'', ''int'')
						,x.value(''./@TypeId'', ''int'')
						,x.value(''./@Priority'', ''smallint'')
						,x.value(''./@UIOrder'', ''smallint'')
						,x.value(''./@LastModifiedOn'', ''datetime'')					
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/Relation[position()=' + CAST(@Counter AS varchar) + ']/Attribute[position()=sql:column("j")]'')  e(x);'
				
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
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Relation[position()=' + CAST(@Counter AS varchar) + ']/Attribute)'', ''int'') )
					)	
						
					INSERT INTO #WartosciCech (RootIndex, AttributeIndex, Value)
					SELECT ' + CAST(@Counter AS varchar) + '
							, j
							,x.query(''.'')	
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/Relation[position()=' + CAST(@Counter AS varchar) + ']/Attribute[position()=sql:column("j")]/*[not(self::History) and not(self::Statuses)]'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				--statusy dla relacji struktury
				SET @Query = '
					;WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Relation[position()=' + CAST(@Counter AS varchar) + ']/Attribute)'', ''int'') )
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
					CROSS APPLY @xml_data.nodes(''/Request/Relation[position()=' + CAST(@Counter AS varchar) + ']/Attribute[position()=sql:column("j")]/Statuses'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				--historia cech relacji
				SET @Query = '
					;WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Relation[position()=' + CAST(@Counter AS varchar) + ']/Attribute)'', ''int'') )
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
					CROSS APPLY @xml_data.nodes(''/Request/Relation[position()=' + CAST(@Counter AS varchar) + ']/Attribute[position()=sql:column("j")]/History'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
			
				SET @Counter = @Counter + 1; 
			END	
			
			--SELECT * FROM #Relacje;
			--SELECT * FROM #CechyRelacji
			--SELECT * FROM #WartosciCech
			--SELECT * FROM #PraweObiektyRelacji;
			--SELECT * FROM #LeweObiektyRelacji
			--SELECT * FROM #STATUSY;
			--SELECT * FROM #Historia;
			--SELECT * FROM #StatusyCech
			--SELECT * FROM #HistoriaCech

			IF @RequestType = 'Relations_Save'
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
						
					BEGIN TRAN T1_Relations_SAVE
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local', 'cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
					
					DECLARE cur CURSOR LOCAL FOR 
						SELECT [Index], Id, TypRelacjiId, IsOuter, SourceId, LastModifiedOn FROM #Relacje
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @TypRelacjiId, @IsOuter, @SourceId, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--wyzerowanie zmiennych, potrzebne!
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL;
						SET @Skip = 0;
						
						SELECT @OldTypStrukturyObiektId = NULL, @OldTypObiektuID_L = NULL, @OldTypObiektuID_R = NULL, @OldObiektID_L = NULL, @OldObiektID_R = NULL,
							@OldTypRelacjiId = NULL, @OldSourceId = NULL, @OldIsStatus = NULL, @OldStatusS = NULL, @OldStatusW = NULL, @OldStatusP = NULL, @OldIsOuter = NULL
						
						--pobranie danych historii
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd, @DataObowiazywaniaDo = DataObowiazywaniaDo
						FROM #Historia WHERE RootIndex = @Index
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index
						
						--pobranie danych lewego i prawego obiektu relacji
						SELECT @LObiektId = ObiektId, @LObiektTypId = TypObiektuId 
						FROM #LeweObiektyRelacji
						WHERE RootIndex = @Index;
						
						SELECT @PObiektId = ObiektId, @PObiektTypId = TypObiektuId 
						FROM #PraweObiektyRelacji
						WHERE RootIndex = @Index;
						
-- pole obecnie nie uzywane		
SET @DataObowiazywaniaDo = NULL;
						
						--sprawdzenie czy s anowe cechy dla relacji
						--nowo dodawane cechy maja w polu Id wartosc 0
					    IF EXISTS (SELECT Id FROM #CechyRelacji WHERE Id = 0 AND RootIndex = @Index)
							SET @SaNoweCechy = 1;
						ELSE
							SET @SaNoweCechy = 0;
						
						-- sprawdzenie czy istnieje relacja o podanych danych obiektow i typie relacji
						SET @IstniejacaRelacjaId = (SELECT TOP 1 Id FROM dbo.[Relacje] WHERE Id <> @Id AND TypRelacji_ID = @TypRelacjiId 
							AND TypObiektuID_L = @LObiektTypId AND TypObiektuID_R = @PObiektTypId AND ObiektID_L = @LObiektId AND ObiektID_R = @PObiektId AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0
							AND ISNULL(SourceId, -1) = ISNULL(@SourceId, -1) )
						
						IF @IstniejacaRelacjaId IS NULL
						BEGIN
							
							--pobranie aktualnych danych relacji by sprawdzic czy zmienila sie jakas dana
							SELECT @OldTypStrukturyObiektId = TypStruktury_Obiekt_Id, @OldTypObiektuID_L = TypObiektuID_L, @OldTypObiektuID_R = TypObiektuID_R,
								@OldObiektID_L = ObiektID_L, @OldObiektID_R = ObiektID_R, @OldTypRelacjiId = TypRelacji_ID, @OldSourceId = SourceId,
								@OldIsStatus = IsStatus, @OldStatusS = StatusS, @OldStatusW = StatusW, @OldStatusP = StatusP, @OldIsOuter = IsOuter
							FROM dbo.[Relacje] WHERE Id = @Id							
							
							--jesli istnieje relacja o podanym ID
							IF @OldTypObiektuID_L IS NOT NULL
							BEGIN
								--sprawdzenie czy zmienily sie dane relacji i czy sa nowe relacje
								IF (@OldTypObiektuID_L = @LObiektTypId AND @OldTypObiektuID_R = @PObiektTypId AND @OldObiektID_L = @LObiektId AND @OldObiektID_R = @PObiektId AND
									@OldTypRelacjiId = @TypRelacjiId AND ISNULL(@OldSourceId, -5) = ISNULL(@SourceId, -5) AND @OldIsStatus = ISNULL(@IsStatus, 0) AND CAST(ISNULL(@OldStatusS, 0) AS varchar) = CAST(ISNULL(@StatusS, 0) AS varchar) AND
									CAST(ISNULL(@OldStatusW, 0) AS varchar) = CAST(ISNULL(@StatusW, 0) AS varchar) AND CAST(ISNULL(@OldStatusP, 0) AS varchar) = CAST(ISNULL(@StatusP, 0) AS varchar) AND @OldIsOuter = @IsOuter AND @SaNoweCechy = 0)
								BEGIN
									IF EXISTS(SELECT Id FROM dbo.Relacje WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn)))
									BEGIN
										--brak zmian danych i brak nowych relacji, ustalamy tylko Id dla przetwarzanego rekordu
										SET @PrzetwarzanaRelacjaId = @Id;
										INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaRelacjaId);		
						
										--zmieniamy tylko daty ostatnich modyfikacji przy wylaczonych triggerach
										DISABLE TRIGGER [WartoscZmiany_Relacje_UPDATE] ON dbo.[Relacje];
										
										UPDATE dbo.[Relacje] SET
										LastModifiedOn = @DataModyfikacjiApp,
										RealLastModifiedOn = @DataModyfikacji
										WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
										
										ENABLE TRIGGER [WartoscZmiany_Relacje_UPDATE] ON dbo.[Relacje];
									END
									ELSE
									BEGIN
										INSERT INTO #RelacjeKonfliktowe(ID)
										VALUES(@Id);
										
										EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
										SET @Commit = 0;
										SET @Skip = 1;
									END
								END
								ELSE
								BEGIN
									--byly zmiany danych wiec probujemy zrobic update
									UPDATE dbo.[Relacje] SET
									TypObiektuID_L = @LObiektTypId,
									TypObiektuID_R = @PObiektTypId,
									ObiektID_L = @LObiektId,
									ObiektID_R = @PObiektId,
									TypRelacji_ID = @TypRelacjiId,
									IsOuter = @IsOuter,
									SourceId = @SourceId,
									ValidFrom = @DataModyfikacjiApp,
									LastModifiedOn = @DataModyfikacjiApp,
									LastModifiedBy = @UzytkownikId,
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
										SET @PrzetwarzanaRelacjaId = @Id;
										INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaRelacjaId);

									END
									ELSE
									BEGIN
										INSERT INTO #RelacjeKonfliktowe(ID)
										VALUES(@Id);
											
										EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
										SET @Commit = 0;
										SET @Skip = 1;
									END
								END
							END
							ELSE
							BEGIN
													
								INSERT INTO dbo.[Relacje] (TypObiektuID_L, TypObiektuID_R, ObiektID_L, ObiektID_R, TypRelacji_ID, IsOuter, SourceId, CreatedOn, CreatedBy, ValidFrom,
								RealCreatedOn, ObowiazujeOd, ObowiazujeDo, IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, 
								StatusWFrom, StatusWFromBy, IsAlternativeHistory, IsMainHistFlow) 
								VALUES (@LObiektTypId, @PObiektTypId, @LObiektId, @PObiektId, @TypRelacjiId, @IsOuter, @SourceId,  @DataModyfikacjiApp, @UzytkownikId, @DataModyfikacjiApp,
									@DataModyfikacji, @DataModyfikacjiApp, @DataObowiazywaniaDo, ISNULL(@IsStatus, 0),
									--@DataModyfikacji, @ZmianaOd, @ZmianaDo, ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp), @DataObowiazywaniaDo, ISNULL(@IsStatus, 0),
									@StatusP, 
									CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
									CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
									@StatusS,
									CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
									CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
									@StatusW, 
									CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
									CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
									0,
									1
								);
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanaRelacjaId = @@IDENTITY;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaRelacjaId);
								END
								ELSE
									SET @Skip = 1;
							END
							
							--przetwarzanie danych cech obiektu
							IF @Skip = 0
							BEGIN
								SET @Query = '';
								--SET @IloscCechObiektu = (SELECT COUNT(1) FROM #CechyObiektow WHERE RootIndex = @Index;
								SET @CounterCechRelacji = 1;
							
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local','cur2') > 0 
								BEGIN
									 CLOSE cur2
									 DEALLOCATE cur2
								END

								DECLARE cur2 CURSOR LOCAL FOR 
									SELECT AttributeIndex, Id, CechaId, [Priority], UIOrder, LastModifiedOn FROM #CechyRelacji WHERE RootIndex = @Index
								OPEN cur2
								FETCH NEXT FROM cur2 INTO @AttributeIndex, @IdCechyRelacji, @CechaId, @Priority, @UIOrder, @LastModifiedOn
								WHILE @@FETCH_STATUS = 0
								BEGIN
								
									--wyzerowanie zmiennych, potrzebne!
									SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
									SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL;						
									
									--pobranie danych historii
									SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd, @DataObowiazywaniaDo = DataObowiazywaniaDo
									FROM #HistoriaCech WHERE RootIndex = @Index AND AttributeIndex = @AttributeIndex;
									
									--pobranie danych statusow
									SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
									FROM #StatusyCech WHERE RootIndex = @Index AND AttributeIndex = @AttributeIndex;
															
--poki co kolumna niezuwayana, zawsze NULL
SET @DataObowiazywaniaDo = NULL;
			
									--ustalenie dat obowiazywania na podstawie granic czasowych przedzialow
									--SELECT @PrzedzialCzasowyId = PrzedzialCzasowyId
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
			
								
									----zabezpieczenie sie przed dodawaniem nulla do stringa co da w wyniku null									
									IF @DataObowiazywaniaDo IS NOT NULL
										SET @DataObowiazywaniaDoStr = '''' + CONVERT(varchar, @DataObowiazywaniaDo, 109) + '''';
									ELSE
										SET @DataObowiazywaniaDoStr = 'NULL';									

									--IF @DataObowiazywaniaOd IS NOT NULL
									--	SET @DataObowiazywaniaOdStr = '''' + CONVERT(varchar, @DataObowiazywaniaOd, 109) + '''';
									--ELSE
									--	SET @DataObowiazywaniaOdStr = '''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + '''';
									
									IF @PrzedzialMinDate IS NOT NULL
										SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @PrzedzialMinDate, 109) + '''';
									ELSE
										SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + '''';	
										
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
										
									-- pobranie wartosci dla cechy i odczytanie odpowiedniego typu na jak bedzie konwertowane
									SELECT @CechaWartoscXML = Value
									FROM #WartosciCech
									WHERE RootIndex = @Index AND [AttributeIndex] = @CounterCechRelacji; --{Index]

									IF @CechaWartoscXML IS NOT NULL
									BEGIN
										SELECT @TypWartosciCechy = c.value('local-name(.)', 'varchar(max)'),
											   @WartoscCechy = c.value('./@Value', 'nvarchar(MAX)'),
											   @IdSlownika = c.value('./@Id', 'int'),
											   @IdElementuSlownika = c.value('./@ElementId', 'int')
										FROM @CechaWartoscXML.nodes('/*') AS t(c)
										
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
									END																					
									
									--SELECT @WartoscCechyQuery, @TypWartosciCechy AS TYPWartosci, @WartoscCechy AS WartoscCechy, @IdSlownika AS IdSlownika, @IdElementuSlownika AS IdElementuSlownika
									
									SET @Query = '
										IF NOT EXISTS (SELECT Id FROM [Relacja_Cecha_Hist] WHERE Id <> ' + CAST(@IdCechyRelacji AS varchar) + ' AND RelacjaId = ' + CAST(@PrzetwarzanaRelacjaId AS varchar) +
											' AND CechaId = ' + CAST(@CechaId AS varchar) + ' AND IsDeleted = 0 AND IdArch IS NULL AND IsValid = 1)
										BEGIN
											--jesli cecha dla podanego Id istnieje
											IF EXISTS (SELECT Id FROM [Relacja_Cecha_Hist] WHERE Id = ' + CAST(@IdCechyRelacji AS varchar) + ')
											BEGIN
												--weryfikacja daty ostatniej modyfikacji
												IF EXISTS (SELECT Id FROM [Relacja_Cecha_Hist] WHERE Id = ' + CAST(@IdCechyRelacji AS varchar) + ' AND (LastModifiedOn = ''' + CONVERT(varchar, @LastModifiedOn, 109) + ''' OR (LastModifiedOn IS NULL AND CreatedOn = ''' + CONVERT(varchar, @LastModifiedOn, 109) + ''' )))
												BEGIN'
												
											--		IF @TypWartosciCechy <> 'ValDictionary'
													BEGIN			
														SET @JestNowaWartoscCechy = 1;
						
														IF @TypWartosciCechy <> 'ValXml' AND @TypWartosciCechy <> 'ValRef'
														BEGIN													
														--	SET @Query += '												
														--		IF (SELECT ' + @TypWartosciCechy + ' FROM [Relacja_Cecha_Hist] WHERE Id = ' + CAST(@IdCechyRelacji AS varchar) + ') <> ' + @WartoscCechyQuery + '
														--		BEGIN'
														--END
														--ELSE
														--BEGIN
															SET @Query += '									
																IF (SELECT ' + @TypWartosciCechy + ' FROM [Relacja_Cecha_Hist] WHERE Id = ' + CAST(@IdCechyRelacji AS varchar) + ') <> ' + @WartoscCechyQuery + '
																BEGIN'
														END 
													END
													
													SET @Query += '
																	UPDATE [Relacja_Cecha_Hist] SET
																	UIOrder = ' + CAST(@UIOrder AS varchar) + ',
																	[Priority] = ' + CAST(@Priority AS varchar) + ', ';												
												
											--	IF @TypWartosciCechy <> 'ValDictionary'
												BEGIN
													SET @Query += '
																	' + @TypWartosciCechy + ' = ' + @WartoscCechyQuery + ','
												END												
														
												SET @Query += '
																	CechaId = ' + CAST(@CechaId AS varchar) + ',
																	LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + ',
																	ValidFrom = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
																	LastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
																	RealLastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacji, 109) + ''',
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
																	WHERE Id = ' + CAST(@IdCechyRelacji AS varchar) + ' AND (LastModifiedOn = ''' + CONVERT(varchar, @LastModifiedOn, 109) + ''' OR (LastModifiedOn IS NULL AND CreatedOn = ''' + CONVERT(varchar, @LastModifiedOn, 109) + ''' ))
																	
																	IF @@ROWCOUNT < 1
																	BEGIN
																		INSERT INTO #RelacjeKonfliktowe(ID)
																		VALUES(' + CAST(@PrzetwarzanaRelacjaId AS varchar) + ');
																		
																		EXEC [THB].[GetErrorMessage] @Nazwa = N''CONCURRENCY_ERROR'', @Grupa = N''PROC_RESULT'', @Wiadomosc = @ERRMSGTmp OUTPUT
																		SET @CommitTmp = 0;
																	END'
																	
														IF @JestNowaWartoscCechy = 1 AND @TypWartosciCechy <> 'ValXml' AND @TypWartosciCechy <> 'ValRef'
														BEGIN
															SET @Query += '
															END
															ELSE
																PRINT ''Cecha nie ma nowej wartosci cechy'''
														END
													
										
										SET @Query += '
												END
												ELSE
												BEGIN
													--nie zgadza sie data ostatniej modyfiacji
													INSERT INTO #RelacjeKonfliktowe(ID)
													VALUES(' + CAST(@PrzetwarzanaRelacjaId AS varchar) + ');
													
													EXEC [THB].[GetErrorMessage] @Nazwa = N''CONCURRENCY_ERROR'', @Grupa = N''PROC_RESULT'', @Wiadomosc = @ERRMSGTmp OUTPUT
													SET @CommitTmp = 0;
												END																					
											END
											ELSE
											BEGIN
												INSERT INTO [Relacja_Cecha_Hist] (RelacjaId, CechaId, [Priority], UIOrder, CreatedOn, CreatedBy, ValidFrom, RealCreatedOn,
												ObowiazujeOd, ObowiazujeDo, IsStatus, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy, 
												StatusP, StatusPFrom, StatusPFromBy, IsAlternativeHistory, IsMainHistFlow'
											
											--	IF @TypWartosciCechy <> 'ValDictionary'
													SET @Query += ', ' + @TypWartosciCechy + ') '										
											--	ELSE
											--		SET @Query += ')'	
												
												SET @Query += ' VALUES (' + CAST(@PrzetwarzanaRelacjaId AS varchar) + ', ' + CAST(@CechaId AS varchar) + ', ' + CAST(@Priority AS varchar) + ', ' 
													+ CAST(@UIOrder AS varchar) + ', ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''', ' + CAST(@UzytkownikId AS varchar) + ', ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''', '''
													 + CONVERT(varchar, @DataModyfikacji, 109) + ''', ' + @DataObowiazywaniaOdStr + ', ' + @DataObowiazywaniaDoStr + ', '
													 + CAST(ISNULL(@IsStatus, 0) AS varchar) + ', ' + @StatusSStr + ', 
														CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END,
														CASE WHEN ' + @StatusSStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusSStr + ' IS NULL THEN NULL END, ' + @StatusWStr + ', 
														CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END,
														CASE WHEN ' + @StatusWStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusWStr + ' IS NULL THEN NULL END, ' + @StatusPStr + ',
														CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + ''' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END,
														CASE WHEN ' + @StatusPStr + ' IS NOT NULL THEN ' + CAST(@UzytkownikID AS varchar) + ' WHEN ' + @StatusPStr + ' IS NULL THEN NULL END, 0, 1'
													
											--	IF @TypWartosciCechy <> 'ValDictionary'
													SET @Query += ', ' + @WartoscCechyQuery + ') '										
											--	ELSE
											--		SET @Query += ');'
											
										SET @Query += '
												END
											--END
										END
										ELSE
										BEGIN
											--relacja o podanym typie i obiektach juz istnieje
											INSERT INTO #RelacjeNieUnikalne(ID)
											VALUES(' + CAST(@PrzetwarzanaRelacjaId AS varchar) + ');
								
											EXEC [THB].[GetErrorMessage] @Nazwa = N''RECORD_EXISTS'', @Grupa = N''PROC_RESULT'', @Val1 = ''Cecha dla relacji'' , @Wiadomosc = @ERRMSGTmp OUTPUT
											SET @CommitTmp = 0;
										END													
										'
								
									--PRINT @Query
									EXECUTE sp_executesql @Query, N'@ERRMSGTmp nvarchar(MAX) OUTPUT, @CommitTmp bit OUTPUT', @ERRMSGTmp = @ERRMSG OUTPUT, @CommitTmp = @Commit OUTPUT
								
									SET @CounterCechRelacji += 1;
									FETCH NEXT FROM cur2 INTO @AttributeIndex, @IdCechyRelacji, @CechaId, @Priority, @UIOrder, @LastModifiedOn
								END
								CLOSE cur2
								DEALLOCATE cur2
	
							END
						END
						ELSE
						BEGIN
							INSERT INTO #RelacjeNieUnikalne(ID)
							VALUES(@IstniejacaRelacjaId);
							
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Relacja' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
						END
					
						FETCH NEXT FROM cur INTO @Index, @Id, @TypRelacjiId, @IsOuter, @SourceId, @LastModifiedOn
					
					END
					CLOSE cur
					DEALLOCATE cur
					
					--SELECT * FROM #IDZmienionych
										
					IF (SELECT COUNT(1) FROM #RelacjeKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT r.[Id] AS "@Id"
											,r.[TypRelacji_ID] AS "@TypeId"
											,r.[IsOuter] AS "@IsOuter"
											,r.[SourceId] AS "@SourceId"
											,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
											,r.[TypObiektuID_L] AS "ObjectLeft/@TypeId"
											,r.[ObiektID_L] AS "ObjectLeft/@Id"
											,r.[TypObiektuID_R] AS "ObjectRight/@TypeId"
											,r.[ObiektID_R] AS "ObjectRight/@Id"						
										FROM [Relacje] r
										WHERE r.Id IN (SELECT ID FROM #RelacjeKonfliktowe)
										FOR XML PATH('Relation')
						) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #RelacjeNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT r.[Id] AS "@Id"
											,r.[TypRelacji_ID] AS "@TypeId"
											,r.[IsOuter] AS "@IsOuter"
											,r.[SourceId] AS "@SourceId"
											,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
											,r.[TypObiektuID_L] AS "ObjectLeft/@TypeId"
											,r.[ObiektID_L] AS "ObjectLeft/@Id"
											,r.[TypObiektuID_R] AS "ObjectRight/@TypeId"
											,r.[ObiektID_R] AS "ObjectRight/@Id"						
							FROM [Relacje] r
							WHERE r.Id IN (SELECT ID FROM #RelacjeNieUnikalne)
							FOR XML PATH('Relation')
					) AS nvarchar(MAX)), '');
					END
					
					SET @xmlResponse = (SELECT TOP 1
						(SELECT ID AS '@Id',
							'Relation' AS '@EntityType'
							FROM #IDZmienionych sl
							FOR XML PATH('Ref'), ROOT('Value'), TYPE
							)
						FROM #IDZmienionych
						FOR XML PATH('Result'));
						
					IF @Commit = 1
						COMMIT TRAN T1_Relations_SAVE
					ELSE
						ROLLBACK TRAN T1_Relations_SAVE
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Relations_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Relations_Save', @Wiadomosc = @ERRMSG OUTPUT	
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_Relations_SAVE
		END
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Relations_Save"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += + '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = '' 	
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
	IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
		DROP TABLE #Relacje
		
	IF OBJECT_ID('tempdb..#LeweObiektyRelacji') IS NOT NULL
		DROP TABLE #LeweObiektyRelacji
		
	IF OBJECT_ID('tempdb..#PraweObiektyRelacji') IS NOT NULL
		DROP TABLE #PraweObiektyRelacji
		
	IF OBJECT_ID('tempdb..#CechyRelacji') IS NOT NULL
		DROP TABLE #CechyRelacji
		
	IF OBJECT_ID('tempdb..#WartosciCech') IS NOT NULL
		DROP TABLE #WartosciCech
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#RelacjeKonfliktowe') IS NOT NULL
		DROP TABLE #RelacjeKonfliktowe
	
	IF OBJECT_ID('tempdb..#RelacjeNieUnikalne') IS NOT NULL
		DROP TABLE #RelacjeNieUnikalne
		
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
	
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy	
		
	IF OBJECT_ID('tempdb..#HistoriaCech') IS NOT NULL
		DROP TABLE #HistoriaCech
	
	IF OBJECT_ID('tempdb..#StatusyCech') IS NOT NULL
		DROP TABLE #StatusyCech
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
