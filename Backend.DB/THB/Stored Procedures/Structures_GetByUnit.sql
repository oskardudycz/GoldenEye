-- =============================================
-- Author:		DK
-- Create date: 2012-06-18
-- Last modified on: 2013-03-13
-- Description:	Pobiera dane z tabeli Struktura_Obiekt dla podanego obiektu (Id typu obiektu i Id obiektu) będącego korzeniem struktury.

-- XML wejsciowy w postaci:

	--<Request RequestType="Structures_GetByUnit" UserId="1" AppDate="2012-02-09T07:23:33" GetFullColumnsData="true"
	--	xsi:noNamespaceSchemaLocation="14.5.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<ObjectRef Id="1" TypeId="13" EntityType="Unit" />
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Structures_GetByUnit" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="14.5.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">	    
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ExpandNestedValues="false" ..   ../> -->
	--	<Structure Id="1" Name="ewrerrwerwe" ShortName="ewr" StructureTypeId="10" ObjectId="50" LastModifiedOn="2012-02-09T12:12:12.121Z" />    
	        
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Structures_GetByUnit]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@TypObiektuId int,
		@ObiektId int,
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
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@StandardWhere nvarchar(MAX) = '',
		@DateFromColumnName nvarchar(100)
		
		--walidacja poprawnosci XMLa Schema_Structures_GetByUnit
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Structures_GetByUnit', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN
			BEGIN TRY
			
			--usuniecie tabel roboczych		
			IF OBJECT_ID('tempdb..#Struktury') IS NOT NULL
				DROP TABLE #Struktury
					
			CREATE TABLE #Struktury (Id int);
			
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
		
			SELECT @ObiektId = C.value('./@Id', 'int')
					,@TypObiektuId = C.value('./@TypeId', 'int')
			FROM @xml_data.nodes('/Request/ObjectRef') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Unit'
		
			IF @RequestType = 'Structures_GetByUnit'
			BEGIN
				--SELECT @ObiektId ,@TypObiektuId			
				--SET @PobierzWszystieDane = 0;
				--SET @RozwijajPodwezly = 0;
				
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
										JOIN [TypStruktury_Obiekt] tso ON (tso.Id = s3.TypStruktury_Obiekt_Id)
										WHERE s3.Obiekt_Id = ' + CAST(@ObiektId AS varchar) + ' AND tso.TypObiektuIdRoot = ' + CAST(@TypObiektuId AS varchar);											
										
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('s3', @StatusS, @StatusP, @StatusW);
						
					--dodanie frazy zwiazanej z filtracja na appDate
					SET @Query += [THB].[PrepareDatesPhrase]('s3', @AppDate);																							

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
					
--					
					SET @Query = 'SET @xmlTemp = (';
				
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @Query += 'SELECT ISNULL(so.[IdArch], so.[Id]) AS "@Id"
										,so.[Nazwa] AS "@Name"
										,so.[NazwaSkrocona] AS "@ShortName"
										,so.[TypStruktury_Obiekt_Id] AS "@StructureTypeId"
										,so.[Obiekt_Id] AS "@ObjectId"
										,ISNULL(so.[LastModifiedOn], so.[CreatedOn]) AS "@LastModifiedOn"
										,ISNULL(so.[LastModifiedBy], so.[CreatedBy]) AS "@LastModifiedBy"'
										
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
							--SET @query += ', (SELECT sa.[Algorytm] AS "Algorithm"
							--				  FROM dbo.[Struktura_Algorytmy] sa
							--				  WHERE sa.StrukturaId = ISNULL(so.[IdArch], so.[Id])
							--				  FOR XML PATH(''''))'
							
							SET @Query += '
								, (SELECT tso.[Id] AS "@Id"
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
														WHERE r.[Id] = s.[RelacjaId]' + @StandardWhere --AND r.[IdArch] IS NULL AND r.[IsValid] = 1
														
							----dodanie frazy statusow na filtracje jesli trzeba
							--SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
							
							----dodanie frazy zwiazanej z filtracja na appDate
							--SET @Query += [THB].[PrepareDatesPhrase]('r', @AppDate);							
														
							SET @Query += '
														FOR XML PATH (''Relation''), TYPE
												)
												FROM [Struktura] s
												WHERE so.[Id] = s.[StrukturaObiektId] ' + @StandardWhere --AND s.IsValid = 1 AND s.IsDeleted = 0
							
							----dodanie frazy statusow na filtracje jesli trzeba
							--SET @Query += [THB].[PrepareStatusesPhrase] ('s', @StatusS, @StatusP, @StatusW);
							
							----dodanie frazy zwiazanej z filtracja na appDate
							--SET @Query += [THB].[PrepareDatesPhrase]('s', @AppDate);											
												
							SET @Query += '
												FOR XML PATH(''RelationLink''), TYPE
												)'					
						END					
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
							
							--SET @query += ', (SELECT sa.[Algorytm] AS "Algorithm"
							--				  FROM dbo.[Struktura_Algorytmy] sa
							--				  WHERE sa.StrukturaId = ISNULL(so.[IdArch], so.[Id])
							--				  FOR XML PATH(''''))'
							
							SET @query += '
									, (SELECT tso.[Id] AS "@Id"
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
							
							SET @query += ', (SELECT s.[StrukturaObiektId] AS "@StructureId"
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
														WHERE r.[Id] = s.[RelacjaId]' + @StandardWhere --AND r.[IdArch] IS NULL AND r.[IsValid] = 1
														
							----dodanie frazy statusow na filtracje jesli trzeba
							--SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
							
							----dodanie frazy zwiazanej z filtracja na appDate
							--SET @Query += [THB].[PrepareDatesPhrase]('r', @AppDate);
														
							SET @Query += '
														FOR XML PATH (''Relation''), TYPE
												)
												FROM [Struktura] s
												WHERE so.[Id] = s.[StrukturaObiektId] ' + @StandardWhere --AND s.IsValid = 1 AND s.IsDeleted = 0
							
							----dodanie frazy statusow na filtracje jesli trzeba
							--SET @Query += [THB].[PrepareStatusesPhrase] ('s', @StatusS, @StatusP, @StatusW);
							
							----dodanie frazy zwiazanej z filtracja na appDate
							--SET @Query += [THB].[PrepareDatesPhrase]('s', @AppDate);
								
							SET @Query += '
												FOR XML PATH(''RelationLink''), TYPE
												)'						
						END	
					END	 
			
					SET @query += ' 							
								FROM [Struktura_Obiekt] so
								WHERE so.Id IN (SELECT Id FROM #Struktury)					
								ORDER BY so.Id FOR XML PATH(''Structure''))';

					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Structures_GetByUnit', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Structures_GetByUnit', @Wiadomosc = @ERRMSG OUTPUT 
				
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Structures_GetByUnit"' 
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"'
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG IS NULL OR @ERRMSG = ''
		--zamiana znakow specjalnych na ich XMLowe odpowiedniki	
		--SET @XMLDataOut += [THB].[PrepareXMLValue](ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '')); 
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), ''); 
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>'; 
	
	--usuniecie tabel roboczych	
	IF OBJECT_ID('tempdb..#Struktury') IS NOT NULL
		DROP TABLE #Struktury
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
