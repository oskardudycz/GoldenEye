-- =============================================
-- Author:		DK
-- Create date: 2012-03-23
-- Last modified on: 2013-04-04
-- Description:	Pobiera dane z tabeli Struktura_Obiekt dla danego typu struktury z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="Structures_GetOfType" StructureTypeId="50" UserId="1"  StatusW="" AppDate="2012-02-09T08:34:23" GetFullColumnsData="true" ExpandNestedValues="true"
	--	xsi:noNamespaceSchemaLocation="14.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<CompositeFilterDescriptor LogicalOperator="AND">
	--		<FilterDescriptor PropertyName="zz" Operator="IsGreaterThanOrEqualTo" Value="12" />
	--		<FilterDescriptor PropertyName="yy" Operator="IsEqualTo" Value="4" />
	--		<CompositeFilterDescriptor LogicalOperator="OR">
	--			<FilterDescriptor PropertyName="dvcdfv" Operator="IsLessThan" Value="12" />
	--			<FilterDescriptor PropertyName="vfefve" Operator="IsEqualTo" Value="012E98243ED884C4B58D250D7F6AE8E6" />
	--		</CompositeFilterDescriptor>
	--	</CompositeFilterDescriptor>
	--	<Paging PageIndex="5" PageSize="20" />
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Structures_GetOfType" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="14.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		
	--	<!-- przy <Request .. GetFullColumnsData="true" ExpandNestedValues="true" ..  ../> -->
	--	<Structure Id="1" Name="ewrerrwerwe" ShortName="ewr" StructureTypeId="10" ObjectId="50" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<StructureType Id="10" Name="21323" RootObjectTypeId="15" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		<RelationLink StructureId="1" RelationId="10" IsMain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<Relation Id="1" TypeId="12" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--				<ObjectLeft Id="1" TypeId="12" />
	--				<ObjectRight Id="12" TypeId="50" />
	--			</Relation>
	--		</RelationLink>
	--		<RelationLink StructureId="1" RelationId="11" IsMain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<Relation Id="2" TypeId="12" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--				<ObjectLeft Id="2" TypeId="12" />
	--				<ObjectRight Id="13" TypeId="50" />
	--			</Relation>
	--		</RelationLink>
	--		<RelationLink StructureId="1" RelationId="12" IsMain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<Relation Id="3" TypeId="12" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--				<ObjectLeft Id="2" TypeId="12" />
	--				<ObjectRight Id="14" TypeId="50" />
	--			</Relation>
	--		</RelationLink>
	--		<RelationLink StructureId="1" RelationId="13" IsMain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<Relation Id="4" TypeId="12" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--				<ObjectLeft Id="2" TypeId="12" />
	--				<ObjectRight Id="15" TypeId="50" />
	--			</Relation>
	--		</RelationLink>
	--		<RelationLink StructureId="1" RelationId="14" IsMain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--			<Relation Id="5" TypeId="12" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--				<ObjectLeft Id="2" TypeId="12" />
	--				<ObjectRight Id="16" TypeId="50" />
	--			</Relation>
	--		</RelationLink>
	--	</Structure>
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ExpandNestedValues="false" ..   ../> -->
	--	<Structure Id="1" Name="ewrerrwerwe" ShortName="ewr" StructureTypeId="10" ObjectId="50" LastModifiedOn="2012-02-09T12:12:12.121Z" />                
	        
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Structures_GetOfType]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@stronicowanieWl bit = 0,
		@TypStrukturyId int,
		@from int,
		@to int,
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@NumerStrony int = NULL,
		@RozmiarStrony int = NULL,
		@PobierzWszystieDane bit = 0,
		@WhereClause nvarchar(MAX),
		@OrderByClause nvarchar(255),
		@IloscRekordow int,
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
		@DateFromColumnName nvarchar(100),
		@StandardWhere nvarchar(MAX) = ''
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Structures_GetOfType', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
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
				
			IF OBJECT_ID('tempdb..#StrukturyFinal') IS NOT NULL
				DROP TABLE #StrukturyFinal
					
			CREATE TABLE #Struktury (Id int);
			CREATE TABLE #StrukturyFinal (Id int);
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@TypStrukturyId = C.value('./@StructureTypeId', 'int')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)
		
			IF @RequestType = 'Structures_GetOfType'
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
				
					--pobranie danych filtrow, sortowania, stronicowania
					EXEC [THB].[PrepareFilters]
						@XMLDataIn = @XMLDataIn,
						--@Alias = 's',
						@WhereClause = @WhereClause OUTPUT,
						@OrderByClause = @OrderByClause OUTPUT,
						@PageSize = @RozmiarStrony OUTPUT,
						@PageIndex = @NumerStrony OUTPUT,
						@ERRMSG = @ERRMSG OUTPUT
						
--SELECT @WhereClause, @OrderByClause, @RozmiarStrony, @NumerStrony, @ERRMSG			

					IF @NumerStrony IS NOT NULL AND @NumerStrony > 0 AND @RozmiarStrony IS NOT NULL AND @RozmiarStrony > 0
					BEGIN
						SET @from = ((@NumerStrony - 1) * @RozmiarStrony);		
						SET @to = ((@NumerStrony) * @RozmiarStrony);			
						SET @stronicowanieWl = 1;
					END		
			
					--ustawienie sortowania dla funkcji rankingowych
					IF @OrderByClause IS NULL OR @OrderByClause = ''
						SET @OrderByClause = 'Id ASC';			
						
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
										WHERE TypStruktury_Obiekt_Id = ' + CAST(@TypStrukturyId AS varchar);
										
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('s3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy zwiazanej z filtracja na appDate
					SET @Query += [THB].[PrepareDatesPhrase]('s3', @AppDate);
					
					--IF @WhereClause IS NOT NULL
					--	SET @Query += dbo.PrepareSafeQuery(@WhereClause);

					SET @Query += '
										GROUP BY ISNULL(s3.IdArch, s3.Id)
									) latest
									ON ISNULL(s2.IdArch, s2.Id) = latest.RowID AND s2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(s2.IdArch, s2.Id), s2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(s.IdArch, s.Id) = latestWithMaxDate.RowID AND s.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND s.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							WHERE 1=1'
						
					IF @WhereClause IS NOT NULL
						SET @Query += dbo.PrepareSafeQuery(@WhereClause);
					
					SET @Query += '		
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;																	
---										
					--posortowanie i wybranie przedzialu stronicowego pasujacych branz
					SET @Query = 'INSERT INTO #StrukturyFinal (Id)
						SELECT Id FROM
						(
							SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [Struktura_Obiekt] 
							WHERE Id IN (SELECT Id FROM #Struktury)
						) X
						WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @Query									
							  
---					
					SET @Query = 'SET @xmlTemp = (';
				
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @query += 'SELECT ISNULL(so.[IdArch], so.[Id]) AS "@Id"
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
							
							SET @query += '
											, (SELECT s.[StrukturaObiektId] AS "@StructureId"
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
														WHERE r.[Id] = s.[RelacjaId]' + @StandardWhere -- AND r.[IdArch] IS NULL AND r.[IsValid] = 1
														
							----dodanie frazy statusow na filtracje jesli trzeba
							--SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
							
							----dodanie frazy zwiazanej z filtracja na appDate
							--SET @Query += [THB].[PrepareDatesPhrase]('r', @AppDate);
														
							SET @Query += '
														FOR XML PATH (''Relation''), TYPE
												)
												FROM [Struktura] s
												WHERE so.[Id] = s.[StrukturaObiektId]' + @StandardWhere;
							
							----dodanie frazy statusow na filtracje jesli trzeba
							--SET @Query += [THB].[PrepareStatusesPhrase] ('s', @StatusS, @StatusP, @StatusW);
							
							----dodanie frazy zwiazanej z filtracja na appDate
							--SET @Query += [THB].[PrepareDatesPhrase]('s', @AppDate);					
												
							SET @Query += '					
												FOR XML PATH(''RelationLink''), TYPE
												)'					
						END					
					END
					ELSE --pobranie wszystkich danych
					BEGIN
						SET @query += 'SELECT ISNULL(so.[IdArch], so.[Id]) AS "@Id"
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
											, (SELECT s.[StrukturaObiektId] AS "@StructureId"
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
														WHERE r.[Id] = s.[RelacjaId]' + @StandardWhere -- AND r.[IdArch] IS NULL AND r.[IsValid] = 1
														
							----dodanie frazy statusow na filtracje jesli trzeba
							--SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
							
							----dodanie frazy zwiazanej z filtracja na appDate
							--SET @Query += [THB].[PrepareDatesPhrase]('r', @AppDate);
														
							SET @Query += '
														FOR XML PATH (''Relation''), TYPE
												)
												FROM [Struktura] s
												WHERE so.[Id] = s.[StrukturaObiektId]' + @StandardWhere;
												
							----dodanie frazy statusow na filtracje jesli trzeba
							--SET @Query += [THB].[PrepareStatusesPhrase] ('s', @StatusS, @StatusP, @StatusW);
							
							----dodanie frazy zwiazanej z filtracja na appDate
							--SET @Query += [THB].[PrepareDatesPhrase]('s', @AppDate);					
							
							SET @Query += '					
												FOR XML PATH(''RelationLink''), TYPE
												)'						
						END	
					END	
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Id', '1');
							
					SET @query += ' FROM [Struktura_Obiekt] so
									WHERE so.Id IN (SELECT Id FROM #StrukturyFinal)
									ORDER BY ' + @OrderByClause + ' FOR XML PATH(''Structure''))'			  
					
					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
					SELECT @IloscRekordow = COUNT(1) FROM #Struktury;		
					
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Structures_GetOfType', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Structures_GetOfType', @Wiadomosc = @ERRMSG OUTPUT 		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Structures_GetOfType"' 
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"'
	
	SET @XMLDataOut += '>';
	
	--dodanie do odpowiedzi informacji o stronach
	IF @stronicowanieWl = 1
	BEGIN
		SET @XMLDataOut += '<TotalPages PageIndex="' + CAST(@NumerStrony AS varchar) + '" PageSize="' + CAST(@RozmiarStrony AS varchar) + '" ItemCount="' + CAST(ISNULL(@IloscRekordow, 0) AS varchar) + '"/>'; --'" TotalPagesCount="' + CAST(ISNULL(@IloscStron, 0) AS varchar) + '"/>'
	END
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		--SET @XMLDataOut += [THB].[PrepareXMLValue](ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), ''));
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	--usuniecie tabel roboczych	
	IF OBJECT_ID('tempdb..#Struktury') IS NOT NULL
		DROP TABLE #Struktury
		
	IF OBJECT_ID('tempdb..#StrukturyFinal') IS NOT NULL
		DROP TABLE #StrukturyFinal
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
