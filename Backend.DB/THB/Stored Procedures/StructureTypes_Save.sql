-- =============================================
-- Author:		DK
-- Create date: 2012-03-05
-- Last modified on: 2013-02-12
-- Description:	Zapisuje dane typu struktury w bazie. Aktualizuje istniejacy lub wstawia nowy rekord.

-- XML wejsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Request RequestType="StructureTypes_Save" UserId="1" AppDate="2012-09-17T12:45:22">
	    
	--	<StructureType Id="0" Name="?" RootObjectTypeId="1"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	        
	--		<ElementOfStructureType Id="0" LObjectTypeId="12" RObjectTypeId="50" RelationTypeId="33" IsTree="false" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		<ElementOfStructureType Id="0" LObjectTypeId="12" RObjectTypeId="51" RelationTypeId="33" IsTree="false" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	        
	--	</StructureType>
	    
	--	<StructureType Id="2" Name="?" RootObjectTypeId="13"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	        
	--		<ElementOfStructureType Id="0" LObjectTypeId="12" RObjectTypeId="50" RelationTypeId="33" IsTree="false" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		<ElementOfStructureType Id="2" LObjectTypeId="12" RObjectTypeId="51" RelationTypeId="33" IsTree="false" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	        
	--	</StructureType>    
	--</Request>
	
--	XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="StructureTypes_Save" AppDate="2012-02-09">
	--	<Result>
	--		<Value>
	--			<Ref Id="3" EntityType="StructureType"/>
	--			<Ref Id="2" EntityType="StructureType"/>
	--			<Ref Id="5" EntityType="StructureType"/>
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[StructureTypes_Save]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@UzytkownikID int,
		@RequestType nvarchar(100),
		@BranzaID int = NULL,
		@TypStrukturyObiektID int,
		@ERRMSG nvarchar(255),
		@xmlOk bit = 0,
		@xml_data xml,		
		@Nazwa nvarchar(50),
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@LastModifiedOn datetime,
		@TypObiektuIdRoot int,
		@Id int,
		@IsArchive bit,
		@IsStatus bit,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@IsAlternativeHistory bit,
		@IsMainHistFlow bit,		
		@IdStruktura int,
		@TypObiektuId_L int,
		@TypObiektuId_R int,
		@TypRelacjiId int,
		@IsStructure bit,
		@StrukturaLastModifiedOn datetime,
		@MaUprawnienia bit = 0,
		@Commit bit = 1,
		@Index int,
		@Query nvarchar(MAX) = '',
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacyTypStrukturyId int,
		@StructureKind smallint,
		@Skip bit = 0,
		@xmlResponse xml,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@IloscTypowStruktur int,
		@Counter int,
		@CouplerIndex int				

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#TypyStruktur') IS NOT NULL
			DROP TABLE #TypyStruktur
			
		IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
			DROP TABLE #Historia
			
		IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
			DROP TABLE #Statusy
			
		IF OBJECT_ID('tempdb..#TypyStrukturObiekty') IS NOT NULL
			DROP TABLE #TypyStrukturObiekty
			
		IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
			DROP TABLE #IDZmienionych
			
		IF OBJECT_ID('tempdb..#StatusyTypow') IS NOT NULL
			DROP TABLE #StatusyTypow
			
		IF OBJECT_ID('tempdb..#HistoriaTypow') IS NOT NULL
			DROP TABLE #HistoriaTypow
			
		IF OBJECT_ID('tempdb..#TypyStrukturKonfliktowe') IS NOT NULL
			DROP TABLE #TypyStrukturKonfliktowe
			
		IF OBJECT_ID('tempdb..#TypyStrukturNieUnikalne') IS NOT NULL
			DROP TABLE #TypyStrukturNieUnikalne
				
		CREATE TABLE #TypyStrukturKonfliktowe(ID int);	
		CREATE TABLE #TypyStrukturNieUnikalne(ID int);			
		CREATE TABLE #IDZmienionych (ID int);
		
		CREATE TABLE #StatusyTypow (RootIndex int, CouplerIndex int, IsStatus bit, StatusP int, StatusPFrom datetime, StatusPTo datetime,
			StatusPFromBy int, StatusPToBy int, StatusS int, StatusSFrom datetime, StatusSTo datetime, StatusSFromBy int, StatusSToBy int,
			StatusW int, StatusWFrom datetime, StatusWTo datetime, StatusWFromBy int, StatusWToBy int);
		
		CREATE TABLE #HistoriaTypow (RootIndex int, CouplerIndex int, ZmianaOd datetime, ZmianaDo datetime, DataObowiazywaniaOd datetime, DataObowiazywaniaDo datetime,
			IsAlternativeHistory bit, IsMainHistFlow bit);
			
		CREATE TABLE #TypyStrukturObiekty (RootIndex int, CouplerIndex int, Id int, TypObiektuId_L int, TypObiektuId_R int, TypRelacjiId int, 
			IsStructure bit, LastModifiedOn datetime)
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_StructureTypes_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co robic na zlej walidacji?			
			SET @ERRMSG = @ERRMSG
		END	
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
							
			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)	
			
			--pobranie ilosci typów struktur w pliku XML
			SELECT @IloscTypowStruktur = @xml_data.value('count(/Request/StructureType)','int'); 
			
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowStruktur
			)
			SELECT j AS 'Index'
				,C.value('./@Id','int') AS Id
				,C.value('./@Name', 'nvarchar(200)') AS Nazwa
				,C.value('./@RootObjectTypeId', 'int') AS TypObiektuIdRoot
				,C.value('./@StructureKind', 'smallint') AS StructureKind
				,C.value('./@IsArchive', 'bit') AS IsArchive
				,C.value('./@ArchivedFrom', 'datetime') AS AchivedFrom
				,C.value('./@ArchivedBy', 'int') AS ArchivedBy
				,C.value('./@IsDeleted', 'bit') AS IsDeleted
				,C.value('./@DeletedFrom', 'datetime') AS DeletedFrom
				,C.value('./@DeletedBy', 'int') AS DeletedBy
				,C.value('./@CreatedOn', 'datetime') AS CreatedOn
				,C.value('./@CreatedBy', 'int') AS CreatedBy				
				,C.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				,C.value('./@LastModifiedBy', 'int') AS LastModifiedBy
			INTO #TypyStruktur 
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/StructureType[position()=sql:column("j")]')  e(C);
			
			;WITH Num(i)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT i + 1
			   FROM Num
			   WHERE i < @IloscTypowStruktur
			)
			SELECT i AS 'RootIndex'
				,C.value('../@Id','int') AS Id
				,C.value('./@ChangeFrom', 'datetime') AS ZmianaOd 
				,C.value('./@ChangeTo', 'datetime') AS ZmianaDo
				,C.value('./@EffectiveFrom', 'datetime') AS DataObowiazywaniaOd
				,C.value('./@EffectiveTo', 'datetime') AS DataObowiazywaniaDo
				,C.value('./@IsAlternativeHistory', 'bit') AS IsAlternativeHistory
				,C.value('./@IsMainHistFlow', 'bit') AS IsMainHistFlow
			INTO #Historia
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/StructureType[position()=sql:column("i")]/History') e(C);
			
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowStruktur
			)
			SELECT j AS 'RootIndex'
				,C.value('../@Id','int') AS Id
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
			CROSS APPLY @xml_data.nodes('/Request/StructureType[position()=sql:column("j")]/Statuses') e(C);
			
			SET @Counter = 0;

			WHILE @Counter <= @IloscTypowStruktur
			BEGIN
			
				--obiekty typow struktury
				SET @Query = '
					;WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/StructureType[position()=' + CAST(@Counter AS varchar) + ']/CouplerStructureType)'', ''int'') )
					)
					INSERT INTO #TypyStrukturObiekty (RootIndex, CouplerIndex, Id, TypObiektuId_L, TypObiektuId_R, TypRelacjiId, IsStructure, LastModifiedOn)  
					SELECT ' + CAST(@Counter AS varchar) + '
						,j
						,C.value(''./@Id'', ''int'')
						,C.value(''./@LObjectTypeId'', ''int'') 
						,C.value(''./@RObjectTypeId'', ''int'') 
						,C.value(''./@RelationTypeId'', ''int'') 
						,C.value(''./@IsTree'', ''bit'')
						,C.value(''./@LastModifiedOn'', ''datetime'')
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/StructureType[position()=' + CAST(@Counter AS varchar) + ']/CouplerStructureType[position()=sql:column("j")]'') e(C)'
	
				--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
			
			
				--statusy dla typow struktury
				SET @Query = '
					;WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/StructureType[position()=' + CAST(@Counter AS varchar) + ']/CouplerStructureType)'', ''int'') )
					)	
						
					INSERT INTO #StatusyTypow (RootIndex, CouplerIndex, IsStatus, StatusP, StatusPFrom, StatusPTo, StatusPFromBy, StatusPToBy, StatusS, StatusSFrom, 
						StatusSTo, StatusSFromBy, StatusSToBy, StatusW, StatusWFrom, StatusWTo, StatusWFromBy, StatusWToBy)
					SELECT ' + CAST(@counter AS varchar) + '
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
					CROSS APPLY @xml_data.nodes(''/Request/StructureType[position()=' + CAST(@counter AS varchar) + ']/CouplerStructureType[position()=sql:column("j")]/Statuses'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				
				--odczytywanie danych zmian dla typow struktury
				SET @Query = '
					WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/StructureType[position()=' + CAST(@Counter AS varchar) + ']/CouplerStructureType)'', ''int'') )
					)	
						
					INSERT INTO #HistoriaTypow (RootIndex, CouplerIndex, ZmianaOd, ZmianaDo, DataObowiazywaniaOd, DataObowiazywaniaDo, IsAlternativeHistory, IsMainHistFlow)
					SELECT ' + CAST(@Counter AS varchar) + '
							, j
							,x.value(''./@ChangeFrom'', ''datetime'') 
							,x.value(''./@ChangeTo'', ''datetime'')
							,x.value(''./@EffectiveFrom'', ''datetime'')
							,x.value(''./@EffectiveTo'', ''datetime'')
							,x.value(''./@IsAlternativeHistory'', ''bit'')
							,x.value(''./@IsMainHistFlow'', ''bit'')
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/StructureType[position()=' + CAST(@Counter AS varchar) + ']/CouplerStructureType[position()=sql:column("j")]/History'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				SET @Counter += 1;
			END
			
			--SELECT * FROM #TypyStrukturObiekty
			--SELECT * FROM #HistoriaTypow;
			--SELECT * FROM #StatusyTypow;
			--SELECT * FROM #TypyStruktur;
			--SELECT * FROM #Historia
			--SELECT * FROM #Statusy
		
			IF @RequestType = 'StructureTypes_Save'
			BEGIN	
			
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji save
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
			
					BEGIN TRAN T1_StructureTypes_Save
					
					IF Cursor_Status('local','curStructureTypes_Save') > 0 
					BEGIN
						 CLOSE curStructureTypes_Save
						 DEALLOCATE curStructureTypes_Save
						 PRINT 'zamknieto cursor'
					END
				
					DECLARE curStructureTypes_Save CURSOR LOCAL FOR 
						SELECT [Index], Id, Nazwa, TypObiektuIdRoot, StructureKind, LastModifiedOn FROM #TypyStruktur
					OPEN curStructureTypes_Save
					FETCH NEXT FROM curStructureTypes_Save INTO @Index, @Id, @Nazwa, @TypObiektuIdRoot, @StructureKind, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
		
						--wyzerowanie zmiennych
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL, @IsAlternativeHistory = 0, @IsMainHistFlow = 0;	
						SET @Skip = 0;
						SET @IstniejacyTypStrukturyId = (SELECT Id FROM dbo.TypStruktury_Obiekt WHERE Id <> @Id AND Nazwa = @Nazwa AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0)
	
						--pobranie danych historii
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
						@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
						FROM #Historia WHERE RootIndex = @Index 
					
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index 

--poki co kolumna nie obslugiwana						
SET @DataObowiazywaniaDo = NULL
	
						--sprawdzenie czy typ struktury o podanej nazwie juz nie istnieje
						IF @IstniejacyTypStrukturyId IS NULL
						BEGIN			
						
							--jesli typ obiektu o podanym ID juz istnieje to jego aktualizacja
							IF EXISTS (SELECT Id FROM [TypStruktury_Obiekt] WHERE Id = @Id)
							BEGIN
								UPDATE [TypStruktury_Obiekt] SET
								ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
								ObowiazujeDo = @DataObowiazywaniaDo,
								Nazwa = @Nazwa,
								TypObiektuIdRoot = @TypObiektuIdRoot,
								StructureKind = @StructureKind,
								IsStatus = ISNULL(@IsStatus, 0),
								StatusP = @StatusP,								
								StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
								StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
								StatusS = @StatusS,								
								StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
								StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
								StatusW = @StatusW,
								StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
								StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
								LastModifiedOn = @DataModyfikacjiApp,
								LastModifiedBy = @UzytkownikID,
								ValidFrom = @DataModyfikacjiApp,
								RealLastModifiedOn = @DataModyfikacji
								WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
							
								--jesli zmieniono dane to wstawienie ID do tablicy tymczasowej
								IF @@ROWCOUNT > 0
								BEGIN
									SET @TypStrukturyObiektID = @Id
									
									INSERT INTO #IDZmienionych
									VALUES(@TypStrukturyObiektID);
								END
								ELSE
								BEGIN								
									INSERT INTO #TypyStrukturKonfliktowe(ID)
									VALUES(@Id);
										
									EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
									SET @Commit = 0;
									SET @Skip = 1;	
								END
							END
							ELSE
							--jesli nie istnieje to jej wstawienie do bazy
							BEGIN
								INSERT INTO [TypStruktury_Obiekt] (ObowiazujeOd, ObowiazujeDo, Nazwa, TypObiektuIdRoot, IsStatus, 
								StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy, CreatedBy, CreatedOn, ValidFrom,
								RealCreatedOn, StructureKind, IsAlternativeHistory, IsMainHistFlow)
								VALUES(
									ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
									@DataObowiazywaniaDo,						
									@Nazwa,
									@TypObiektuIdRoot,							
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
									@UzytkownikID,
									@DataModyfikacjiApp,
									@DataModyfikacjiApp,
									@DataModyfikacji,
									@StructureKind,
									0,
									1
								);
						
								--jesli zmieniono dane to wstawienie ID do tablicy tymczasowej
								IF @@ROWCOUNT > 0
								BEGIN
									SET @TypStrukturyObiektID = @@IDENTITY
									
									INSERT INTO #IDZmienionych
									VALUES(@TypStrukturyObiektID);
								END
								ELSE
									SET @Skip = 1;
							END
							
							IF @Skip = 0
							BEGIN
					
								--weryfikacja typowStruktur dla podanego typuStrukturyObiektu
								IF Cursor_Status('local','cur2_StructureTypes_Save') > 0 
								BEGIN
									 CLOSE cur2_StructureTypes_Save
									 DEALLOCATE cur2_StructureTypes_Save
								END					

								DECLARE cur2_StructureTypes_Save CURSOR LOCAL FOR 
									SELECT Id, CouplerIndex, TypObiektuId_L, TypObiektuId_R, TypRelacjiId, IsStructure, LastModifiedOn
									FROM #TypyStrukturObiekty WHERE RootIndex = @Index
								OPEN cur2_StructureTypes_Save
								FETCH NEXT FROM cur2_StructureTypes_Save INTO @IdStruktura, @CouplerIndex, @TypObiektuId_L, @TypObiektuId_R, @TypRelacjiId, @IsStructure, @StrukturaLastModifiedOn
								WHILE @@FETCH_STATUS = 0
								BEGIN
								
									--wyzerowanie zmiennych, potrzebne!
									SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
									SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL, @IsAlternativeHistory = 0, @IsMainHistFlow = 0;	
						
									--pobranie danych statusow
									SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
									FROM #StatusyTypow WHERE RootIndex = @Index AND CouplerIndex = @CouplerIndex;	
									
									--pobranie danych historii
									SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
									@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
									FROM #HistoriaTypow WHERE RootIndex = @Index AND CouplerIndex = @CouplerIndex;

--poki co kolumna nie obslugiwana						
SET @DataObowiazywaniaDo = NULL
					
									--sprawdzenie czy typStruktury o podanych danych (TypStruktury_Obiekt_Id, TypObiektuId_L, TypObiektuId_R i TypRelacjiId) juz istnieje
									IF NOT EXISTS (SELECT Id FROM TypStruktury WHERE Id <> @IdStruktura AND TypObiektuId_L = @TypObiektuId_L AND TypObiektuId_R = @TypObiektuId_R AND TypRelacjiId = @TypRelacjiId AND TypStruktury_Obiekt_Id = @TypStrukturyObiektID AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0)
									BEGIN
										
										IF EXISTS (SELECT Id FROM TypStruktury WHERE Id = @IdStruktura)
										BEGIN
											UPDATE dbo.[TypStruktury] SET
											TypObiektuId_L = @TypObiektuId_L,
											TypObiektuId_R = @TypObiektuId_R,
											TypStruktury_Klasa_Id = 0,
											TypRelacjiId = @TypRelacjiId,
											IsStructure = @IsStructure,
											LastModifiedOn = @DataModyfikacjiApp,
											ValidFrom = @DataModyfikacjiApp,
											RealLastModifiedOn = @DataModyfikacji,
											ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
											ObowiazujeDo = @DataObowiazywaniaDo,
											IsStatus = ISNULL(@IsStatus, 0),
											StatusP = @StatusP,								
											StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
											StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
											StatusS = @StatusS,								
											StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
											StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
											StatusW = @StatusW,
											StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
											StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END
											WHERE Id = @IdStruktura AND (LastModifiedOn = @StrukturaLastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @StrukturaLastModifiedOn))
											
											IF @@ROWCOUNT < 1
											BEGIN
												INSERT INTO #TypyStrukturKonfliktowe(ID)
												VALUES(@Id);
													
												EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
												SET @Commit = 0;
											END
											 
										END
										ELSE
										BEGIN
											INSERT INTO dbo.[TypStruktury](CreatedOn, ValidFrom, CreatedBy, TypStruktury_Klasa_Id, TypStruktury_Obiekt_Id, TypObiektuId_L, TypObiektuId_R, TypRelacjiId, IsStructure,
											RealCreatedOn, ObowiazujeOd, ObowiazujeDo, IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, 
											StatusWFromBy, IsAlternativeHistory, IsMainHistFlow)
											VALUES (@DataModyfikacjiApp,
												@DataModyfikacjiApp, 
												@UzytkownikId,
												0, --skad wziasc ta wartosc?
												@TypStrukturyObiektID, 
												@TypObiektuId_L, 
												@TypObiektuId_R, 
												@TypRelacjiId, 
												@IsStructure,
												@DataModyfikacji,
												ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
												@DataObowiazywaniaDo,
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
												0,
												1
											);
										END
									END
									ELSE
									BEGIN
										INSERT INTO #TypyStrukturNieUnikalne(ID)
										VALUES(@TypStrukturyObiektID);
										
										EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Typ struktury' , @Wiadomosc = @ERRMSG OUTPUT
										SET @Commit = 0;
									END
							
									FETCH NEXT FROM cur2_StructureTypes_Save INTO @IdStruktura, @CouplerIndex, @TypObiektuId_L, @TypObiektuId_R, @TypRelacjiId, @IsStructure, @StrukturaLastModifiedOn
								
								END
								CLOSE cur2_StructureTypes_Save
								DEALLOCATE cur2_StructureTypes_Save
							END
						END
						ELSE
						BEGIN
							INSERT INTO #TypyStrukturNieUnikalne(ID)
							VALUES(@IstniejacyTypStrukturyId);
							
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Typ struktury - obiekt' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
							SET @Skip = 1;
						END				
						
						FETCH NEXT FROM curStructureTypes_Save INTO @Index, @Id, @Nazwa, @TypObiektuIdRoot, @StructureKind, @LastModifiedOn
					END
					CLOSE curStructureTypes_Save
					DEALLOCATE curStructureTypes_Save
					
					IF (SELECT COUNT(1) FROM #TypyStrukturKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT tso.[Id] AS "@Id"
									  ,tso.[Nazwa] AS "@Name"
									  ,tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
									  ,tso.[IsDeleted] AS "@IsDeleted"
									  ,tso.[DeletedFrom] AS "@DeletedFrom"
									  ,tso.[DeletedBy] AS "@DeletedBy"
									  ,tso.[CreatedOn] AS "@CreatedOn"
									  ,tso.[CreatedBy] AS "@CreatedBy"
									  ,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"
									  ,tso.[LastModifiedBy] AS "@LastModifiedBy"
									  ,tso.[ObowiazujeOd] AS "History/@EffectiveFrom"
									  ,tso.[ObowiazujeDo] AS "History/@EffectiveTo"
									  ,tso.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
									  ,tso.[IsMainHistFlow] AS "History/@IsMainHistFlow"
									  ,tso.[IsStatus] AS "Statuses/@IsStatus"
									  ,tso.[StatusS] AS "Statuses/@StatusS"
									  ,tso.[StatusSFrom] AS "Statuses/@StatusSFrom"
									  ,tso.[StatusSTo] AS "Statuses/@StatusSTo"
									  ,tso.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									  ,tso.[StatusSToBy] AS "Statuses/@StatusSToBy"
									  ,tso.[StatusW] AS "Statuses/@StatusW"
									  ,tso.[StatusWFrom] AS "Statuses/@StatusWFrom"
									  ,tso.[StatusWTo] AS "Statuses/@StatusWTo"
									  ,tso.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									  ,tso.[StatusWToBy] AS "Statuses/@StatusWToBy"
									  ,tso.[StatusP] AS "Statuses/@StatusP"
									  ,tso.[StatusPFrom] AS "Statuses/@StatusPFrom"
									  ,tso.[StatusPTo] AS "Statuses/@StatusPTo"
									  ,tso.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									  ,tso.[StatusPToBy] AS "Statuses/@StatusPToBy"
									  , (SELECT ts.[Id] AS "@Id"
								,ts.[TypObiektuId_L] AS "@LObjectTypeId"
								,ts.[TypObiektuId_R] AS "@RObjectTypeId"
								,ts.[TypRelacjiId] AS "@RelationTypeId"
								,ts.[IsStructure] AS "@IsTree"
								,ts.[IsDeleted] AS "@IsDeleted"
								,ts.[DeletedFrom] AS "@DeletedFrom"
								,ts.[DeletedBy] AS "@DeletedBy"
								,ts.[CreatedOn] AS "@CreatedOn"
								,ts.[CreatedBy] AS "@CreatedBy"
								,ISNULL(ts.[LastModifiedOn], ts.[CreatedOn]) AS "@LastModifiedOn"
								,ts.[LastModifiedBy] AS "@LastModifiedBy"
								,ts.[ObowiazujeOd] AS "History/@EffectiveFrom"
								,ts.[ObowiazujeDo] AS "History/@EffectiveTo"
								,ts.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
								,ts.[IsMainHistFlow] AS "History/@IsMainHistFlow"
								,ts.[IsStatus] AS "Statuses/@IsStatus"
								,ts.[StatusS] AS "Statuses/@StatusS"
								,ts.[StatusSFrom] AS "Statuses/@StatusSFrom"
								,ts.[StatusSTo] AS "Statuses/@StatusSTo"
								,ts.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
								,ts.[StatusSToBy] AS "Statuses/@StatusSToBy"
								,ts.[StatusW] AS "Statuses/@StatusW"
								,ts.[StatusWFrom] AS "Statuses/@StatusWFrom"
								,ts.[StatusWTo] AS "Statuses/@StatusWTo"
								,ts.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
								,ts.[StatusWToBy] AS "Statuses/@StatusWToBy"
								,ts.[StatusP] AS "Statuses/@StatusP"
								,ts.[StatusPFrom] AS "Statuses/@StatusPFrom"
								,ts.[StatusPTo] AS "Statuses/@StatusPTo"
								,ts.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
								,ts.[StatusPToBy] AS "Statuses/@StatusPToBy"
								FROM [TypStruktury] ts
								WHERE ts.[TypStruktury_Obiekt_Id] = tso.[Id] AND ts.IdArch IS NULL AND ts.IsDeleted = 0 AND ts.IsValid = 1
								FOR XML PATH('CouplerStructureType'), TYPE
								)							
							FROM [TypStruktury_Obiekt] tso
							WHERE tso.Id IN (SELECT ID FROM #TypyStrukturKonfliktowe)
							FOR XML PATH('StructureType')
						) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #TypyStrukturNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT tso.[Id] AS "@Id"
									  ,tso.[Nazwa] AS "@Name"
									  ,tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
									  ,tso.[IsDeleted] AS "@IsDeleted"
									  ,tso.[DeletedFrom] AS "@DeletedFrom"
									  ,tso.[DeletedBy] AS "@DeletedBy"
									  ,tso.[CreatedOn] AS "@CreatedOn"
									  ,tso.[CreatedBy] AS "@CreatedBy"
									  ,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"
									  ,tso.[LastModifiedBy] AS "@LastModifiedBy"
									  ,tso.[ObowiazujeOd] AS "History/@EffectiveFrom"
									  ,tso.[ObowiazujeDo] AS "History/@EffectiveTo"
									  ,tso.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
									  ,tso.[IsMainHistFlow] AS "History/@IsMainHistFlow"
									  ,tso.[IsStatus] AS "Statuses/@IsStatus"
									  ,tso.[StatusS] AS "Statuses/@StatusS"
									  ,tso.[StatusSFrom] AS "Statuses/@StatusSFrom"
									  ,tso.[StatusSTo] AS "Statuses/@StatusSTo"
									  ,tso.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									  ,tso.[StatusSToBy] AS "Statuses/@StatusSToBy"
									  ,tso.[StatusW] AS "Statuses/@StatusW"
									  ,tso.[StatusWFrom] AS "Statuses/@StatusWFrom"
									  ,tso.[StatusWTo] AS "Statuses/@StatusWTo"
									  ,tso.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									  ,tso.[StatusWToBy] AS "Statuses/@StatusWToBy"
									  ,tso.[StatusP] AS "Statuses/@StatusP"
									  ,tso.[StatusPFrom] AS "Statuses/@StatusPFrom"
									  ,tso.[StatusPTo] AS "Statuses/@StatusPTo"
									  ,tso.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									  ,tso.[StatusPToBy] AS "Statuses/@StatusPToBy"
									  , (SELECT ts.[Id] AS "@Id"
										,ts.[TypObiektuId_L] AS "@LObjectTypeId"
										,ts.[TypObiektuId_R] AS "@RObjectTypeId"
										,ts.[TypRelacjiId] AS "@RelationTypeId"
										,ts.[IsStructure] AS "@IsTree"
										,ts.[IsDeleted] AS "@IsDeleted"
										,ts.[DeletedFrom] AS "@DeletedFrom"
										,ts.[DeletedBy] AS "@DeletedBy"
										,ts.[CreatedOn] AS "@CreatedOn"
										,ts.[CreatedBy] AS "@CreatedBy"
										,ISNULL(ts.[LastModifiedOn], ts.[CreatedOn]) AS "@LastModifiedOn"
										,ts.[LastModifiedBy] AS "@LastModifiedBy"
										,ts.[ObowiazujeOd] AS "History/@EffectiveFrom"
										,ts.[ObowiazujeDo] AS "History/@EffectiveTo"
										,ts.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
										,ts.[IsMainHistFlow] AS "History/@IsMainHistFlow"
										,ts.[IsStatus] AS "Statuses/@IsStatus"
										,ts.[StatusS] AS "Statuses/@StatusS"
										,ts.[StatusSFrom] AS "Statuses/@StatusSFrom"
										,ts.[StatusSTo] AS "Statuses/@StatusSTo"
										,ts.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
										,ts.[StatusSToBy] AS "Statuses/@StatusSToBy"
										,ts.[StatusW] AS "Statuses/@StatusW"
										,ts.[StatusWFrom] AS "Statuses/@StatusWFrom"
										,ts.[StatusWTo] AS "Statuses/@StatusWTo"
										,ts.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
										,ts.[StatusWToBy] AS "Statuses/@StatusWToBy"
										,ts.[StatusP] AS "Statuses/@StatusP"
										,ts.[StatusPFrom] AS "Statuses/@StatusPFrom"
										,ts.[StatusPTo] AS "Statuses/@StatusPTo"
										,ts.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
										,ts.[StatusPToBy] AS "Statuses/@StatusPToBy"
										FROM [TypStruktury] ts
										WHERE ts.[TypStruktury_Obiekt_Id] = tso.[Id] AND ts.IdArch IS NULL AND ts.IsDeleted = 0 AND ts.IsValid = 1
										FOR XML PATH('CouplerStructureType'), TYPE
										)							
						FROM [TypStruktury_Obiekt] tso								
						WHERE tso.Id IN (SELECT ID FROM #TypyStrukturNieUnikalne)
						FOR XML PATH('StructureType')
					) AS nvarchar(MAX)), '');
					END	
					
					SET @xmlResponse = (SELECT TOP 1
									(SELECT ID AS '@Id',
									'StructureType' AS '@EntityType'
									FROM #IDZmienionych
									FOR XML PATH('Ref'), ROOT('Value'), TYPE
									)
								FROM #IDZmienionych
								FOR XML PATH('Result')
								);
					
					IF @Commit = 1
						COMMIT TRAN T1_StructureTypes_Save
					ELSE
						ROLLBACK TRAN T1_StructureTypes_Save
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'StructureTypes_Save', @Wiadomosc = @ERRMSG OUTPUT	
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'StructureTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
		END
		
	END TRY
	BEGIN CATCH
		--musi byc osobo, jak jest w jednym przypisaniu sie psuje
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_StructureTypes_Save
		END

	END CATCH
	
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="StructureTypes_Save"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
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
	IF OBJECT_ID('tempdb..#TypyStruktur') IS NOT NULL
		DROP TABLE #TypyStruktur
		
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
		
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
		
	IF OBJECT_ID('tempdb..#StatusyTypow') IS NOT NULL
		DROP TABLE #StatusyTypow
		
	IF OBJECT_ID('tempdb..#HistoriaTypow') IS NOT NULL
		DROP TABLE #HistoriaTypow
		
	IF OBJECT_ID('tempdb..#TypyStrukturObiekty') IS NOT NULL
		DROP TABLE #TypyStrukturObiekty
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#TypyStrukturKonfliktowe') IS NOT NULL
		DROP TABLE #TypyStrukturKonfliktowe
		
	IF OBJECT_ID('tempdb..#TypyStrukturNieUnikalne') IS NOT NULL
		DROP TABLE #TypyStrukturNieUnikalne
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 
END
