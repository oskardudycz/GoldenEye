-- =============================================
-- Author:		DK
-- Create date: 2013-03-14
-- Last modified on: 2013-03-18
-- Description:	Pobiera dane z tabeli Struktura_Obiekt dla struktur o podanych ID.

-- XML wejsciowy w postaci:

	--<Request RequestType="Structures_GetWithSubstructures" UserId="1" AppDate="2012-02-09T11:54:34" MaxLevel="2" GetFullColumnsData="true">
	--	<Ref Id="1" EntityType="Structure" />
	--	<Ref Id="2" EntityType="Structure" />
	--	<Ref Id="3" EntityType="Structure" />
	--	<Ref Id="4" EntityType="Structure" />
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Structures_GetOfType" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="14.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">	    
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ExpandNestedValues="false" ..   ../> -->
	--	<Structure Id="1" Name="ewrerrwerwe" ShortName="ewr" StructureTypeId="10" ObjectId="50" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--	<Structure Id="2" Name="ewrerrwerwe2" ShortName="ewr2" StructureTypeId="10" ObjectId="51" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--	<Structure Id="3" Name="ewrerrwerwe3" ShortName="ewr3" StructureTypeId="10" ObjectId="52" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	        
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Structures_GetWithSubstructures]
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
		@xmlAll nvarchar(MAX) = '',
		@RozwijajPodwezly bit = 0,
		@MaUprawnienia bit = 0,
		@AppDate datetime,
		@StandardWhere nvarchar(MAX) = '',
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DateFromColumnName nvarchar(100),
		@MaxLevel int,
		@IdStruktury int,
		@xmlResponse xml
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#IDDoPobrania') IS NOT NULL
			DROP TABLE #IDDoPobrania
			
		IF OBJECT_ID('tempdb..#Struktury') IS NOT NULL
			DROP TABLE #Struktury
			
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..##LinkiStruktur') IS NOT NULL
			DROP TABLE ##LinkiStruktur
			
		IF OBJECT_ID('tempdb..##LinkiStrukturNieistniejace') IS NOT NULL
			DROP TABLE ##LinkiStrukturNieistniejace
		
		CREATE TABLE ##LinkiStrukturNieistniejace(Id int);
		CREATE TABLE ##LinkiStruktur([Level] int, RelacjaId int, StrukturaObiektId int, StrukturaLinkId int);				
		CREATE TABLE #Struktury (Id int);	
		CREATE TABLE #IDDoPobrania (ID int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Structures_GetWithSubstructures', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN
			BEGIN TRY
			
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
					,@MaxLevel = C.value('./@MaxLevel', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
			
			--wyciaganie ID elenentow do pobrania
			INSERT INTO #IDDoPobrania(Id)
			SELECT	C.value('./@Id', 'int')
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Structure' 
		
			IF @RequestType =  'Structures_GetWithSubstructures'
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
				
				IF @MaUprawnienia = 1
				BEGIN
				
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @StandardWhere = [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);
						
					--dodanie frazy zwiazanej z filtracja na appDate
					SET @StandardWhere += [THB].[PrepareDatesPhrase](NULL, @AppDate);
					
					--pobranie danych Id pasujacych typow relacji do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Struktury (Id)
							SELECT allData.Id FROM
							(
								SELECT s.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(s.IdArch, s.Id) ORDER BY s.Id ASC) AS Rn
								FROM [dbo].[Struktura_Obiekt] s
								INNER JOIN
								(
									SELECT ISNULL(s2.IdArch, s2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, s2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Struktura_Obiekt] s2								 
									INNER JOIN 
									(
										SELECT ISNULL(s3.IdArch, s3.Id) AS RowID, MAX(s3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Struktura_Obiekt] s3
										WHERE (Id IN (SELECT Id FROM #IDDoPobrania) OR IdArch IN (SELECT Id FROM #IDDoPobrania))' + @StandardWhere

					SET @Query += '
										GROUP BY ISNULL(s3.IdArch, s3.Id)
									) latest
									ON ISNULL(s2.IdArch, s2.Id) = latest.RowID AND s2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(s2.IdArch, s2.Id), s2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(s.IdArch, s.Id) = latestWithMaxDate.RowID AND s.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND s.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curStructures') > 0 
					BEGIN
						 CLOSE curStructures
						 DEALLOCATE curStructures
					END
					
					DECLARE curStructures CURSOR LOCAL FOR 
						SELECT Id FROM #Struktury
					OPEN curStructures
					FETCH NEXT FROM curStructures INTO @IdStruktury
					WHILE @@FETCH_STATUS = 0
					BEGIN									
					
						SET @Query = 'SET @xmlTemp = (';
						
						IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
						BEGIN
							SET @Query += 'SELECT ISNULL(so.[IdArch], so.[Id]) AS "@Id"
											,so.[Nazwa] AS "@Name"
											,so.[NazwaSkrocona] AS "@ShortName"
											,so.[TypStruktury_Obiekt_Id] AS "@StructureTypeId"
											,so.[Obiekt_Id] AS "@ObjectId"
											,ISNULL(so.[LastModifiedOn], so.[CreatedOn]) AS "@LastModifiedOn"'
											
							--pobieranie danych podwezlow			
							IF @RozwijajPodwezly = 1
							BEGIN							
							
							SET @Query += ', (SELECT sa.[Algorytm] AS "Algorithm"
											  FROM dbo.[Struktura_Algorytmy] sa
											  WHERE sa.StrukturaId = ISNULL(so.[IdArch], so.[Id])
											  FOR XML PATH(''''))					
												,(SELECT tso.[Id] AS "@Id"
												,tso.[Nazwa] AS "@Name"
												,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"
												,ISNULL(tso.[LastModifiedBy], tso.[CreatedBy]) AS "@LastModifiedBy"
												,tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
												,tso.[StructureKind] AS "@StructureKind"
												, (SELECT ts.[Id] AS "@Id"
													,ts.[TypObiektuId_L] AS "@LObjectTypeId"
													,ts.[TypObiektuId_R] AS "@RObjectTypeId"
													,ts.[TypRelacjiId] AS "@RelationTypeId"
													,ts.[IsStructure] AS "@IsTree"
													,ISNULL(ts.[LastModifiedOn], ts.[CreatedOn]) AS "@LastModifiedOn"
													,ISNULL(ts.[LastModifiedBy], ts.[CreatedBy]) AS "@LastModifiedBy"
													FROM [TypStruktury] ts
													WHERE ts.[TypStruktury_Obiekt_Id] = tso.[Id] AND ts.IdArch IS NULL AND ts.IsDeleted = 0 AND ts.IsValid = 1
													FOR XML PATH(''CouplerStructureType''), TYPE
													)
												FROM [TypStruktury_Obiekt] tso
												WHERE tso.Id = so.TypStruktury_Obiekt_Id
												FOR XML PATH(''StructureType''), TYPE)'				
					
								SET @Query += ', (SELECT s.[StrukturaObiektId] AS "@StructureId"
													,s.[RelacjaId] AS "@RelationId"
													,s.[IsMain] AS "@IsMain"
													,s.[StrukturaLinkId] AS "@StructureLinkId"
													,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
													,ISNULL(s.[LastModifiedBy], s.[CreatedBy]) AS "@LastModifiedBy"
													, (SELECT r.[Id] AS "@Id"
															,r.[TypRelacji_ID] AS "@TypeId"
															,r.[SourceId] AS "@SourceId"
															,r.[IsOuter] AS "@IsOuter"
															,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
															,ISNULL(r.[LastModifiedBy], r.[CreatedBy]) AS "@LastModifiedBy"
															,r.[TypObiektuID_L] AS "ObjectLeft/@TypeId"
															,r.[ObiektID_L] AS "ObjectLeft/@Id"
															,r.[TypObiektuID_R] AS "ObjectRight/@TypeId"
															,r.[ObiektID_R] AS "ObjectRight/@Id"
															FROM [Relacje] r
															WHERE r.[Id] = s.[RelacjaId]' + @StandardWhere		
								SET @Query += '							
														
														FOR XML PATH (''Relation''), TYPE
												)
												FROM [Struktura] s
												WHERE (so.[Id] = s.[StrukturaObiektId] OR so.[IdArch] = s.[StrukturaObiektId]) ' + @StandardWhere
								
								--jesli podano poziom zaglebienia to dodajemy kolejny warunek			
								--IF @MaxLevel > 0
								--	SET @Query += ' AND s.StrukturaLinkId IS NULL'
								
								SET @Query += '				
												FOR XML PATH(''RelationLink''), TYPE
												)'					
							END
							--ELSE
							--BEGIN
							--	SET @query += ', (SELECT tso.[Id] AS "@Id"
							--			,tso.[Nazwa] AS "@Name"
							--			,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"
							--			,tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
							--			FROM [TypStruktury_Obiekt] tso
							--		WHERE tso.Id = so.TypStruktury_Obiekt_Id
							--		FOR XML PATH(''StructureType''), TYPE)'
							--END					
						END
						ELSE -- pobranie wszystkich danych
						BEGIN
							SET @Query += 'SELECT ISNULL(so.[IdArch], so.[Id]) AS "@Id"
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
										    ,ISNULL(so.[LastModifiedBy], so.[CreatedBy]) AS "@LastModifiedBy"
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
										    ,so.[StatusPToBy] AS "Statuses/@StatusPToBy"';
								  
							--pobieranie danych podwezlow			
							IF @RozwijajPodwezly = 1
							BEGIN
								
								SET @Query += '
											, (SELECT sa.[Algorytm] AS "Algorithm"
												  FROM dbo.[Struktura_Algorytmy] sa
												  WHERE sa.StrukturaId = ISNULL(so.[IdArch], so.[Id])
												  FOR XML PATH(''''))'
												  
								SET @Query += '						
											,(SELECT tso.[Id] AS "@Id"
											,tso.[Nazwa] AS "@Name"
											,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"
											,ISNULL(tso.[LastModifiedBy], tso.[CreatedBy]) AS "@LastModifiedBy"
											,tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
											,tso.[StructureKind] AS "@StructureKind"
											, (SELECT ts.[Id] AS "@Id"
												,ts.[TypObiektuId_L] AS "@LObjectTypeId"
												,ts.[TypObiektuId_R] AS "@RObjectTypeId"
												,ts.[TypRelacjiId] AS "@RelationTypeId"
												,ts.[IsStructure] AS "@IsTree"
												,ISNULL(ts.[LastModifiedOn], ts.[CreatedOn]) AS "@LastModifiedOn"
												,ISNULL(ts.[LastModifiedBy], ts.[CreatedBy]) AS "@LastModifiedBy"
												,ts.[ObowiazujeOd] AS "History/@EffectiveFrom"
												,ts.[ObowiazujeDo] AS "History/@EffectiveTo"
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
												FOR XML PATH(''CouplerStructureType''), TYPE
												)
												FROM [TypStruktury_Obiekt] tso
										WHERE tso.Id = so.TypStruktury_Obiekt_Id
										FOR XML PATH(''StructureType''), TYPE)'
							
								SET @Query += ', (SELECT s.[StrukturaObiektId] AS "@StructureId"
													,s.[RelacjaId] AS "@RelationId"
													,s.[IsMain] AS "@IsMain"
													,s.[StrukturaLinkId] AS "@StructureLinkId"
													,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
													,ISNULL(s.[LastModifiedBy], s.[CreatedBy]) AS "@LastModifiedBy"
													, (SELECT r.[Id] AS "@Id"
														,r.[TypRelacji_ID] AS "@TypeId"
														,r.[SourceId] AS "@SourceId"
														,r.[IsOuter] AS "@IsOuter"
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
														,r.[ObiektID_R] AS "ObjectRight/@Id"
														FROM [Relacje] r
														WHERE r.[Id] = s.[RelacjaId]' + @StandardWhere
													
								SET @Query += '
														FOR XML PATH (''Relation''), TYPE
												)
												FROM [Struktura] s
												WHERE (so.[Id] = s.[StrukturaObiektId] OR so.[IdArch] = s.[StrukturaObiektId]) ' + @StandardWhere
													
								--jesli podano poziom zaglebienia to dodajemy kolejny warunek			
								--IF @MaxLevel > 0
								--	SET @Query += ' AND s.StrukturaLinkId IS NULL'
								
								SET @Query += '				
												FOR XML PATH(''RelationLink''), TYPE
												)'					
							END
							--ELSE
							--BEGIN
							--	SET @query += ', (SELECT tso.[Id] AS "@Id"
							--			,tso.[Nazwa] AS "@Name"
							--			,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"
							--			,tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
							--			FROM [TypStruktury_Obiekt] tso
							--		WHERE tso.Id = so.TypStruktury_Obiekt_Id
							--		FOR XML PATH(''StructureType''), TYPE)'
							--END		
						END	 						
					
						SET @Query += ' FROM [Struktura_Obiekt] so
								WHERE Id = ' + CAST(@IdStruktury AS varchar) + '
								FOR XML PATH(''Structure''))';
								
						--PRINT @query;
						EXECUTE sp_executesql @Query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT

						--pobranie danych podstruktur
						IF @MaxLevel > 0 AND @RozwijajPodwezly = 1
						BEGIN
							EXEC [THB].[GetRelationLinksForStructures]
								@WhereClause = @StandardWhere,
								@GetAllData = @PobierzWszystieDane,
								@StructureId = @IdStruktury,
								@MaxLevel = @MaxLevel,
								@RootLevel = 1,
								@Xml = @xmlResponse OUTPUT

						END

						IF @xmlResponse IS NOT NULL
							SET @xmlAll += CAST(@xmlResponse AS nvarchar(MAX));
						
						SET @xmlResponse = NULL;
						
						FETCH NEXT FROM curStructures INTO @IdStruktury						
					END
					CLOSE curStructures;
					DEALLOCATE curStructures;

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Structures_GetWithSubstructures', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Structures_GetWithSubstructures', @Wiadomosc = @ERRMSG OUTPUT
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Structures_GetWithSubstructures"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';	
	
	SET @XMLDataOut += '>';
		
	IF @ERRMSG iS NULL OR @ERRMSG = ''	
		--zamiana znakow specjalnych na ich XMLowe odpowiedniki	
		--SET @XMLDataOut += [THB].[PrepareXMLValue](ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), ''));	
		SET @XMLDataOut += @xmlAll; --ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#IDDoPobrania') IS NOT NULL
		DROP TABLE #IDDoPobrania
		
	IF OBJECT_ID('tempdb..#Struktury') IS NOT NULL
		DROP TABLE #Struktury
		
	IF OBJECT_ID('tempdb..##LinkiStruktur') IS NOT NULL
		DROP TABLE ##LinkiStruktur
		
	IF OBJECT_ID('tempdb..##LinkiStrukturNieistniejace') IS NOT NULL
		DROP TABLE ##LinkiStrukturNieistniejace
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
