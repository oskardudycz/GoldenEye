-- =============================================
-- Author:		DK
-- Create date: 2012-03-23
-- Last modified on: 2013-03-12
-- Description:	Zapisuje dane struktury i podleglych relacji. Aktualizuje istniejacy lub wstawia nowy rekord.

-- XML wejsciowy w postaci:

	--<Request RequestType="Structures_Save" UserId="1" AppDate="2012-02-09T11:45:34"
	--	xsi:noNamespaceSchemaLocation="14.3.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		
	--	<Structure Id="0" Name="ewrerrwerwe" ShortName="ewr" StructureTypeId="10" ObjectId="50" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<RelationLink StructureId="0" RelationId="0" IsMain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<Relation Id="0" TypeId="12" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--				<ObjectLeft Id="1" TypeId="12" />
	--				<ObjectRight Id="12" TypeId="50" />
	--			</Relation>
	--		</RelationLink>
	--		<RelationLink StructureId="0" RelationId="0" IsMain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<Relation Id="0" TypeId="12" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--				<ObjectLeft Id="2" TypeId="12" />
	--				<ObjectRight Id="13" TypeId="50" />
	--			</Relation>
	--		</RelationLink>
	--		<RelationLink StructureId="0" RelationId="0" IsMain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<Relation Id="0" TypeId="12" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--				<ObjectLeft Id="2" TypeId="12" />
	--				<ObjectRight Id="14" TypeId="50" />
	--			</Relation>
	--		</RelationLink>
	--		<RelationLink StructureId="0" RelationId="0" IsMain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<Relation Id="0" TypeId="12" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--				<ObjectLeft Id="2" TypeId="12" />
	--				<ObjectRight Id="15" TypeId="50" />
	--			</Relation>
	--		</RelationLink>
	--	</Structure>
	    
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Structures_Save" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="10.2.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="Structure" />
	--			<Ref Id="2" EntityType="Structure" />
	--			<Ref Id="3" EntityType="Structure" />
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Structures_Save]
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
		@Nazwa nvarchar(200),
		@Index int,
		@LastModifiedOn datetime,
		@NazwaSkrocona nvarchar(32),
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@PrzetwarzanaStrukturaId int,
		@Skip bit = 0,
		@MaUprawnienia bit = 0,
		@IsMain bit,
		@ObiektId int, 
		@TypStruktury_Obiekt_Id int,
		@StrukturaObiektId int,
		@RelacjaId int,
		@Commit bit = 1,
		@Query nvarchar(MAX) = '',
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacaStrukturaId int,
		@IsArchivedFrom datetime, 
		@IsArchivedBy int,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@IsArchive bit,
		@IsStatus bit,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@IsAlternativeHistory bit,
		@IsMainHistFlow bit,
		@IloscStruktur int,
		@Counter int = 0,
		@RelationLinkIndex int,
		@AlgorytmDlaStruktury xml,
		@RelationLinkId int,
		@RelationLinkIsDeleted bit,
		@StructureLinkId int
		
	BEGIN TRY
	
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#Struktury') IS NOT NULL
			DROP TABLE #Struktury
			
		IF OBJECT_ID('tempdb..#RelacjeStruktury') IS NOT NULL
			DROP TABLE #RelacjeStruktury
			
		IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
			DROP TABLE #IDZmienionych
			
		IF OBJECT_ID('tempdb..#IDZmienionychRelacji') IS NOT NULL
			DROP TABLE #IDZmienionychRelacji
			
		IF OBJECT_ID('tempdb..#StrukturyKonfliktowe') IS NOT NULL
			DROP TABLE #StrukturyKonfliktowe
			
		IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
			DROP TABLE #Statusy
			
		IF OBJECT_ID('tempdb..#StatusyPowiazania') IS NOT NULL
			DROP TABLE #StatusyPowiazania
		
		IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
			DROP TABLE #Historia
			
		IF OBJECT_ID('tempdb..#HistoriaPowiazania') IS NOT NULL
			DROP TABLE #HistoriaPowiazania
			
		IF OBJECT_ID('tempdb..#AlgorytmyStruktury') IS NOT NULL
			DROP TABLE #AlgorytmyStruktury
		
	--	IF OBJECT_ID('tempdb..#StrukturyNieUnikalne') IS NOT NULL
	--		DROP TABLE #StrukturyNieUnikalne
			
		CREATE TABLE #StrukturyKonfliktowe(ID int);	
	--	CREATE TABLE #StrukturyNieUnikalne(ID int);
			
		CREATE TABLE #IDZmienionych (ID int);
		CREATE TABLE #IDZmienionychRelacji(RootID int, ID int);
		CREATE TABLE #RelacjeStruktury (RootIndex int, RelationLinkIndex int, StrukturaObiektId int, RelacjaId int, IsMain bit, StructureLinkId int, LastModifiedOn datetime);
		CREATE TABLE #AlgorytmyStruktury (RootIndex int, Algorytm xml);
		CREATE TABLE #StatusyPowiazania (RootIndex int, RelationLinkIndex int, IsStatus bit, StatusP int, StatusPFrom datetime, StatusPTo datetime,
			StatusPFromBy int, StatusPToBy int, StatusS int, StatusSFrom datetime, StatusSTo datetime, StatusSFromBy int, StatusSToBy int,
			StatusW int, StatusWFrom datetime, StatusWTo datetime, StatusWFromBy int, StatusWToBy int);
		
		CREATE TABLE #HistoriaPowiazania (RootIndex int, RelationLinkIndex int, ZmianaOd datetime, ZmianaDo datetime, DataObowiazywaniaOd datetime, DataObowiazywaniaDo datetime,
			IsAlternativeHistory bit, IsMainHistFlow bit);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Structures_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);
			
			SELECT @IloscStruktur = @xml_data.value('count(/Request/Structure)','int'); 
		
			--odczytywanie danych struktur
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscStruktur --(SELECT @xml_data.value('count(/Request/Structure)','int') )
			)
			SELECT 	j AS 'Index'
				   ,x.value('./@Id', 'int') AS Id
				   ,x.value('./@Name', 'nvarchar(256)') AS Nazwa
				   ,x.value('./@ShortName', 'nvarchar(32)') AS NazwaSkrocona
				   ,x.value('./@StructureTypeId', 'int') AS TypStruktury_Obiekt_Id
				   ,x.value('./@ObjectId', 'int') AS ObiektId
				   ,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				   ,x.value('./@IsArchive', 'bit') AS IsArchive
				   ,x.value('./@IsArchivedFrom', 'datetime') AS IsArchivedFrom
				   ,x.value('./@IsArchivedBy', 'int') AS IsArchivedBy
			INTO #Struktury
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Structure[position()=sql:column("j")]')  e(x);
			
			--odczytywanie historii struktur
			;WITH Num(i)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT i + 1
			   FROM Num
			   WHERE i < @IloscStruktur 
			)
			SELECT i AS 'RootIndex'
				,C.value('./@ChangeFrom', 'datetime') AS ZmianaOd 
				,C.value('./@ChangeTo', 'datetime') AS ZmianaDo
				,C.value('./@EffectiveFrom', 'datetime') AS DataObowiazywaniaOd
				,C.value('./@EffectiveTo', 'datetime') AS DataObowiazywaniaDo
				,C.value('./@IsAlternativeHistory', 'bit') AS IsAlternativeHistory
				,C.value('./@IsMainHistFlow', 'bit') AS IsMainHistFlow
			INTO #Historia
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Structure[position()=sql:column("i")]/History') e(C);
			
			--odczytywanie statusów struktur
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscStruktur 
			)
			SELECT j AS 'RootIndex'
				,C.value('./@IsStatus', 'bit') AS IsStatus
				,C.value('./@StatusP', 'int') AS StatusP  
				,C.value('./@StatusPFrom', 'datetime') AS StatusPFrom 
				,C.value('./@StatusPTo', 'datetime') AS StatusPTo
				,C.value('./@StatusPFromBy', 'int') AS StatusPFromBy
				,C.value('./@StatusPToBy', 'int') AS StatusPToBy
				,C.value('./@StatusS', 'int') AS StatusS
				,C.value('./@StatusSFrom', 'datetime') AS StatusSFrom
				,C.value('./@StatusSTo', 'datetime') AS StatusSTo
				,C.value('./@StatusSFromBy', 'int') AS StatusSFromBy
				,C.value('./@StatusSToBy', 'int') AS StatusSToBy
				,C.value('./@StatusW', 'int') AS StatusW
				,C.value('./@StatusWFrom', 'datetime') AS StatusWFrom 
				,C.value('./@StatusWTo', 'datetime') AS StatusWTo
				,C.value('./@StatusWFromBy', 'int') AS StatusWFromBy
				,C.value('./@StatusWToBy', 'int') AS StatusWToBy
			INTO #Statusy
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Structure[position()=sql:column("j")]/Statuses') e(C);
			
			--odczytywanie algorytmow dla struktur
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscStruktur 
			)
			INSERT INTO #AlgorytmyStruktury(RootIndex, Algorytm)
			SELECT j
					,C.query('.')
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/Structure[position()=sql:column("j")]/Algorithm/OperationData') e(C);
			
---			
			SET @Counter = 0;
			
			WHILE @Counter <= @IloscStruktur
			BEGIN
				--statusy dla relacji struktury
				SET @Query = '
					;WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Structure[position()=' + CAST(@Counter AS varchar) + ']/RelationLink)'', ''int'') )
					)	
						
					INSERT INTO #StatusyPowiazania (RootIndex, RelationLinkIndex, IsStatus, StatusP, StatusPFrom, StatusPTo, StatusPFromBy, StatusPToBy, StatusS, StatusSFrom, 
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
					CROSS APPLY @xml_data.nodes(''/Request/Structure[position()=' + CAST(@Counter AS varchar) + ']/RelationLink[position()=sql:column("j")]/Statuses'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data				
				
				--odczytywanie danych relacji dla struktury	
				SET @Query = '
					WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Structure[position()=' + CAST(@Counter AS varchar) + ']/RelationLink)'', ''int'') )
					)	
						
					INSERT INTO #RelacjeStruktury (RootIndex, RelationLinkIndex, StrukturaObiektId, RelacjaId, IsMain, StructureLinkId, LastModifiedOn)
					SELECT ' + CAST(@Counter AS varchar) + '
							, j
							,x.value(''./@StructureId'',''int'')
							,x.value(''./@RelationId'', ''int'')
							,x.value(''./@IsMain'', ''bit'')
							,x.value(''./@StructureLinkId'', ''int'')
							,x.value(''./@LastModifiedOn'', ''datetime'')
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/Structure[position()=' + CAST(@Counter AS varchar) + ']/RelationLink[position()=sql:column("j")]'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				--odczytywanie danych zmian dla relacji struktury
				SET @Query = '
					WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/Structure[position()=' + CAST(@Counter AS varchar) + ']/RelationLink)'', ''int'') )
					)	
						
					INSERT INTO #HistoriaPowiazania (RootIndex, RelationLinkIndex, ZmianaOd, ZmianaDo, DataObowiazywaniaOd, DataObowiazywaniaDo, IsAlternativeHistory, IsMainHistFlow)
					SELECT ' + CAST(@Counter AS varchar) + '
							, j
							,x.value(''./@ChangeFrom'', ''datetime'') 
							,x.value(''./@ChangeTo'', ''datetime'')
							,x.value(''./@EffectiveFrom'', ''datetime'')
							,x.value(''./@EffectiveTo'', ''datetime'')
							,x.value(''./@IsAlternativeHistory'', ''bit'')
							,x.value(''./@IsMainHistFlow'', ''bit'')
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/Structure[position()=' + CAST(@Counter AS varchar) + ']/RelationLink[position()=sql:column("j")]/History'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data				
			
				SET @Counter = @Counter + 1; 
			END	

			--SELECT * FROM #Struktury
			--SELECT * FROM #RelacjeStruktury
			--SELECT * FROM #Statusy
			--SELECT * FROM #Historia
			--SELECT * FROM #StatusyPowiazania
			--SELECT * FROM #HistoriaPowiazania
			--SELECT * FROM #AlgorytmyStruktury

			IF @RequestType = 'Structures_Save'
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
					BEGIN TRAN T1_Structures_Save
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
				
					DECLARE cur CURSOR LOCAL FOR 
						SELECT [Index], Id, Nazwa, NazwaSkrocona, ObiektId, TypStruktury_Obiekt_Id, LastModifiedOn,
						IsArchive, IsArchivedFrom, IsArchivedBy FROM #Struktury
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @NazwaSkrocona, @ObiektId, @TypStruktury_Obiekt_Id, @LastModifiedOn, @IsArchive, @IsArchivedFrom, @IsArchivedBy
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--wyzerowanie zmiennych
						SELECT @Skip = 0, @AlgorytmDlaStruktury = NULL;
						--SET @IstniejacaStrukturaId = (SELECT Id FROM dbo.[Struktura_Obiekt] WHERE Id <> @Id);
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL, @IsAlternativeHistory = 0, @IsMainHistFlow = 0;
			
						--pobranie danych historii
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
						@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
						FROM #Historia 
						WHERE RootIndex = @Index
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy 
						WHERE RootIndex = @Index

-- pole obecnie nie uzywane		
SET @DataObowiazywaniaDo = NULL;
						
						--pobranie algorytmu dla struktury
						SELECT @AlgorytmDlaStruktury = Algorytm
						FROM #AlgorytmyStruktury 
						WHERE RootIndex = @Index
					
						IF EXISTS (SELECT Id FROM dbo.[Struktura_Obiekt] WHERE Id = @Id)
						BEGIN
	
							--aktualizacja danych struktury
							UPDATE dbo.[Struktura_Obiekt] SET
							Nazwa = @Nazwa,
							NazwaSkrocona = @NazwaSkrocona,
							Obiekt_Id = @ObiektId,
							TypStruktury_Obiekt_Id = @TypStruktury_Obiekt_Id,
							LastModifiedOn = @DataModyfikacjiApp,
							LastModifiedBy = @UzytkownikId,
							--IsAlternativeHistory = @IsAlternativeHistory,
							--IsMainHistFlow = @IsMainHistFlow,
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
							RealLastModifiedOn = @DataModyfikacji,
							ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
							ObowiazujeDo = @DataObowiazywaniaDo,
							ValidFrom = @DataModyfikacjiApp
							WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
							
							IF @@ROWCOUNT > 0
							BEGIN
								SET @PrzetwarzanaStrukturaId = @Id;
								INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaStrukturaId);
							END
							ELSE
							BEGIN
								SET @Skip = 1;
								
								INSERT INTO #StrukturyKonfliktowe(ID)
								VALUES(@Id);
									
								EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
								SET @Commit = 0;
							END
						END
						ELSE
						BEGIN						
							--wstawienie nowej struktury o ile juz taki nie istnieje
						--	IF NOT EXISTS (SELECT Id FROM dbo.[Struktura_Obiekt] WHERE Nazwa = @Nazwa AND IdArch IS NULL 
						--		AND TypStruktury_Obiekt_Id = @TypStruktury_Obiekt_Id AND IsValid <> 0)
						--	BEGIN

								INSERT INTO dbo.[Struktura_Obiekt] (Nazwa, NazwaSkrocona, TypStruktury_Obiekt_Id, Obiekt_Id, CreatedBy, ValidFrom, CreatedOn, IsStatus, 
								StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy,
								ObowiazujeOd, ObowiazujeDo, RealCreatedOn, IsAlternativeHistory, IsMainHistFlow) 
								VALUES (@Nazwa, @NazwaSkrocona, @TypStruktury_Obiekt_Id, @ObiektId, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacjiApp,
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
									ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
									@DataObowiazywaniaDo,
									@DataModyfikacji,
									0,
									1
									);
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanaStrukturaId = @@IDENTITY;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaStrukturaId);
								END
						--	END
						--	ELSE
						--		SET @Skip = 1;
						END
				
						--przetwarzanie danych operacji dla rol
						IF @Skip = 0
						BEGIN
							
							IF @AlgorytmDlaStruktury IS NOT NULL
							BEGIN
								--zapis danych algorytmu dla struktury						
								MERGE dbo.[Struktura_Algorytmy] AS target
								USING (SELECT @PrzetwarzanaStrukturaId, @AlgorytmDlaStruktury) AS source (StrukturaId, Algorytm)
								ON (target.StrukturaId = source.StrukturaId)
								WHEN MATCHED THEN 
									UPDATE SET 
										Algorytm = source.Algorytm,
										LastModifiedOn = GETDATE(),
										LastModifiedBy = @UzytkownikID
								WHEN NOT MATCHED THEN	
									INSERT (StrukturaId, Algorytm, CreatedOn, CreatedBy)
									VALUES (source.StrukturaId, source.Algorytm, GETDATE(), @UzytkownikID);
							END
							
							--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
							IF Cursor_Status('local', 'cur2') > 0 
							BEGIN
								 CLOSE cur2
								 DEALLOCATE cur2
							END

							DECLARE cur2 CURSOR LOCAL FOR 
								SELECT RelationLinkIndex, RelacjaId, StrukturaObiektId, IsMain, StructureLinkId, LastModifiedOn FROM #RelacjeStruktury WHERE RootIndex = @Index 
							OPEN cur2
							FETCH NEXT FROM cur2 INTO @RelationLinkIndex, @RelacjaId, @StrukturaObiektId, @IsMain, @StructureLinkId, @LastModifiedOn
							WHILE @@FETCH_STATUS = 0
							BEGIN
								--wyzrowanie zmiennych
								SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
								SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL, @IsAlternativeHistory = 0, @IsMainHistFlow = 0;						
								
								--pobranie danych statusow
								SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
								FROM #StatusyPowiazania WHERE RootIndex = @Index AND RelationLinkIndex = @RelationLinkIndex	
								
								--pobranie danych historii
								SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
								@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
								FROM #HistoriaPowiazania WHERE RootIndex = @Index AND RelationLinkIndex = @RelationLinkIndex							

-- pole obecnie nie uzywane		
SET @DataObowiazywaniaDo = NULL;
		
								--pobranie danych powiazania struktury z relacjami
								SELECT @RelationLinkId = RelacjaId, @RelationLinkIsDeleted = IsDeleted
								FROM dbo.[Struktura] WHERE RelacjaId = @RelacjaId AND StrukturaObiektId = @PrzetwarzanaStrukturaId;
							
								--jesli juz istnieje w bazie powiazanie struktury z relacja
								IF @RelationLinkId IS NOT NULL
								BEGIN
									--jesli juz takie powiazanie jest usuniete to je "reaktywujemy"
									IF @RelationLinkIsDeleted = 1
									BEGIN
									
										UPDATE [Struktura] SET
										IsMain = @IsMain,
										StrukturaLinkId = @StructureLinkId,
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
										CreatedBy = @UzytkownikId,
										CreatedOn = @DataModyfikacjiApp,
										LastModifiedBy = NULL,
										LastModifiedOn = NULL,
										IsDeleted = 0,
										IsValid = 1,
										ValidTo = NULL,
										ValidFrom = @DataModyfikacjiApp,
										DeletedBy = NULL,
										DeletedFrom = NULL,
										RealLastModifiedOn = NULL,
										ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
										ObowiazujeDo = @DataObowiazywaniaDo
										WHERE RelacjaId = @RelacjaId AND StrukturaObiektId = @PrzetwarzanaStrukturaId;
									
									END
									ELSE
									BEGIN
										--"normalna" aktualizacja danych
										UPDATE [Struktura] SET
										IsMain = @IsMain,
										StrukturaLinkId = @StructureLinkId,
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
										LastModifiedBy = @UzytkownikId,
										LastModifiedOn = @DataModyfikacjiApp,
										ValidFrom = @DataModyfikacjiApp,
										RealLastModifiedOn = @DataModyfikacji,
										ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
										ObowiazujeDo = @DataObowiazywaniaDo
										WHERE RelacjaId = @RelacjaId AND StrukturaObiektId = @PrzetwarzanaStrukturaId
										AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
										
									END
									
									IF @@ROWCOUNT < 1
									BEGIN
										INSERT INTO #StrukturyKonfliktowe(ID)
										VALUES(@Id);
									
										EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
										SET @Commit = 0;									
									END
									ELSE
									BEGIN
										INSERT INTO #IDZmienionychRelacji(RootID, ID)
										VALUES (@PrzetwarzanaStrukturaId, @RelacjaId);
									END	
								END
								ELSE
								BEGIN								
									INSERT INTO [Struktura] (RelacjaId, StrukturaObiektId, IsMain, StrukturaLinkId, CreatedBy, CreatedOn, ValidFrom, IsStatus, 
										StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy,
										ObowiazujeOd, ObowiazujeDo, RealCreatedOn, IsAlternativeHistory, IsMainHistFlow)
									VALUES (@RelacjaId, @PrzetwarzanaStrukturaId, @IsMain, @StructureLinkId, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacjiApp, 
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
										ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
										@DataObowiazywaniaDo,
										@DataModyfikacji,
										0,
										1);
									
									IF @@ROWCOUNT > 0
									BEGIN
										INSERT INTO #IDZmienionychRelacji(RootID, ID)
										VALUES (@PrzetwarzanaStrukturaId, @RelacjaId);
									END									
								END			
															
								FETCH NEXT FROM cur2 INTO @RelationLinkIndex, @RelacjaId, @StrukturaObiektId, @IsMain, @StructureLinkId, @LastModifiedOn
							END
							CLOSE cur2
							DEALLOCATE cur2
						END
						
						FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @NazwaSkrocona, @ObiektId, @TypStruktury_Obiekt_Id, @LastModifiedOn, @IsArchive, @IsArchivedFrom, @IsArchivedBy
						
					END
					CLOSE cur
					DEALLOCATE cur
					
					IF (SELECT COUNT(1) FROM #StrukturyKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT so.[Id] AS "@Id"
										,so.[Nazwa] AS "@Name"
										,so.[NazwaSkrocona] AS "@ShortName"
										,so.[TypStruktury_Obiekt_Id] AS "@StructureTypeId"
										,so.[Obiekt_Id] AS "@ObjectId"
									  ,so.[IsDeleted] AS "@IsDeleted"
									  ,so.[DeletedFrom] AS "@DeletedFrom"
									  ,so.[DeletedBy] AS "@DeletedBy"
									  ,so.[CreatedOn] AS "@CreatedOn"
									  ,so.[CreatedBy] AS "@CreatedBy"
									  ,ISNULL(so.[LastModifiedOn], so.[CreatedOn]) AS "@LastModifiedOn"
									  ,so.[LastModifiedBy] AS "@LastModifiedBy"
									  ,so.[ObowiazujeOd] AS "History/@EffectiveFrom"
									  ,so.[ObowiazujeDo] AS "History/@EffectiveTo"
									  ,so.[IsStatus] AS "Statuses/@IsStatus"
									  ,so.[StatusS] AS "Statuses/@StatusS"
									  ,so.[StatusSFrom] AS "Statuses/@StatusSFrom"
									  ,so.[StatusSTo] AS "Statuses/@StatusSTo"
									  ,so.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									  ,so.[StatusSToBy] AS "Statuses/@StatusSToBy"
									  ,so.[StatusW] AS "Statuses/@StatusW"
									  ,so.[StatusWFrom] AS "Statuses/@StatusWFrom"
									  ,so.[StatusWTo] AS "Statuses/@StatusWTo"
									  ,so.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									  ,so.[StatusWToBy] AS "Statuses/@StatusWToBy"
									  ,so.[StatusP] AS "Statuses/@StatusP"
									  ,so.[StatusPFrom] AS "Statuses/@StatusPFrom"
									  ,so.[StatusPTo] AS "Statuses/@StatusPTo"
									  ,so.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									  ,so.[StatusPToBy] AS "Statuses/@StatusPToBy"
									  , (SELECT s.[StrukturaObiektId] AS "@StructureId"
												,s.[RelacjaId] AS "@RelationId"
												,s.[IsMain] AS "@IsMain"
												,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
												, (SELECT r.[Id] AS "@Id"
														,r.[TypRelacji_ID] AS "@TypeId"
														,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
														,r.[TypObiektuID_L] AS "ObjectLeft/@TypeId"
														,r.[ObiektID_L] AS "ObjectLeft/@Id"
														,r.[TypObiektuID_R] AS "ObjectRight/@TypeId"
														,r.[ObiektID_R] AS "ObjectRight/@Id"
														FROM [Relacje] r
														WHERE r.[Id] = s.[RelacjaId] AND r.[IdArch] IS NULL AND r.[IsValid] = 1
														FOR XML PATH ('Relation'), TYPE
												)
												FROM [Struktura] s
												WHERE so.[Id] = s.[StrukturaObiektId] AND s.IsValid = 1 AND s.IsDeleted = 0
												FOR XML PATH('RelationLink'), TYPE
												)							
							FROM [Struktura_Obiekt] so
							WHERE Id IN (SELECT ID FROM #StrukturyKonfliktowe)
							FOR XML PATH('Structure')
						) AS nvarchar(MAX)), '');
					END					
					
					SET @xmlResponse = ( 
						SELECT TOP 1
							(SELECT zs.ID AS '@Id',
							'Structure' AS '@EntityType'
							, (SELECT zr.ID AS '@Id',
								'Relation' AS '@EntityType'
								FROM #IDZmienionychRelacji zr
								WHERE zr.RootId = zs.ID
								FOR XML PATH('Ref'), TYPE
							)
							FROM #IDZmienionych zs
							FOR XML PATH('Ref'), ROOT('Value'), TYPE
							)
						FROM #IDZmienionych
						FOR XML PATH('Result')
						);
					
					IF @Commit = 1	
						COMMIT TRAN T1_Structures_Save
					ELSE
						ROLLBACK TRAN T1_Structures_Save														
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Structures_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Structures_Save', @Wiadomosc = @ERRMSG OUTPUT 
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
	
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN T1_Structures_Save
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Structures_Save"';
	
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
		
		----dodawanie danych rekordow nie zapisanych z powodu konfliktow
		--IF @xmlErrorsUnique IS NOT NULL AND LEN(@xmlErrorsUnique) > 3
		--BEGIN
		--	SET @XMLDataOut += '<UniquenessConflicts>' + @xmlErrorsUnique + '</UniquenessConflicts>';
		--END
		
		SET @XMLDataOut += '</Error></Result>';
	END

	SET @XMLDataOut += '</Response>';	
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#Struktury') IS NOT NULL
		DROP TABLE #Struktury
		
	IF OBJECT_ID('tempdb..#RelacjeStruktury') IS NOT NULL
		DROP TABLE #RelacjeStruktury
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#IDZmienionychRelacji') IS NOT NULL
		DROP TABLE #IDZmienionychRelacji
		
	IF OBJECT_ID('tempdb..#StrukturyKonfliktowe') IS NOT NULL
		DROP TABLE #StrukturyKonfliktowe
		
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
	
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
		
	IF OBJECT_ID('tempdb..#HistoriaPowiazania') IS NOT NULL
		DROP TABLE #HistoriaPowiazania
		
	IF OBJECT_ID('tempdb..#StatusyPowiazania') IS NOT NULL
		DROP TABLE #StatusyPowiazania
		
	IF OBJECT_ID('tempdb..#AlgorytmyStruktury') IS NOT NULL
		DROP TABLE #AlgorytmyStruktury
	
	--IF OBJECT_ID('tempdb..#StrukturyNieUnikalne') IS NOT NULL
	--	DROP TABLE #StrukturyNieUnikalne

	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
		
END
