-- =============================================
-- Author:		DK
-- Create date: 2012-07-05
-- Last modified on: 2013-04-10
-- Description:	Pobiera dane z tabeli Cechy z uwzglednieniem filtrów i branzy.

-- XML wejsciowy w postaci:

	--<Request RequestType="AttributeTypes_GetAvailable" UserId="1" BranchId="8" AppDate="2012-09-09T12:45:22"
	--	xsi:noNamespaceSchemaLocation="7.4.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="2" EntityType="UnitType" />
	
	--		<!-- LUB
	--		<Ref Id="2" EntityType="RelationType" />
	--		-->    
	
	--</Request>

-- XM wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="GetAvailable" AppDate="2012-02-09"> 

	--	<!-- przy <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../> -->	
	--	<AttributeType Id="1" Name="?" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0"
	--		IsUserAttribute="0" TimeIntervalId="2" TemporaryValue="true"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--		<DataType Id="1" Name="rfqrq" SQLName="efrer" UIName="werew" IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z" />
			--<LinkedBranches>
			--	<Ref Id="1" />
			--	<Ref Id="2" />
			--</LinkedBranches>
	--	</AttributeType>    
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="true" ../> -->
	--	<AttributeType Id="1" Name="?" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0"
	--		IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z" TimeIntervalId="2" TemporaryValue="true">
 --       		<DataType Id="1" Name="rfqrq" SQLName="efrer" UIName="werew" IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z" />
 				--<LinkedBranches>
				--	<Ref Id="1" />
				--	<Ref Id="2" />
				--</LinkedBranches>
	--		</AttributeType>    
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="false" ../> -->
	--	<AttributeType Id="1" Name="?" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0"
	--		IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	    
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[AttributeTypes_GetAvailable]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@TypObiektuId int,
		@TypRelacjiId int,
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@PobierzWszystieDane bit = 0,
		@WhereClause nvarchar(MAX),
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@RozwijajPodwezly bit = 0,
		@MaUprawnienia bit = 0,
		@BranzeZDostepem nvarchar(MAX),
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DateFromColumnName nvarchar(100),
		@StandardWhere nvarchar(MAX)
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_AttributeTypes_GetAvailable', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			
			--usuwanie tabel tymczasowych, jesli istnieja			
			IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
				DROP TABLE #Cechy;
			
			IF OBJECT_ID('tempdb..#CechyBranze') IS NOT NULL
				DROP TABLE #CechyBranze;
				
			IF OBJECT_ID('tempdb..#BranzeDlaUzytkownika') IS NOT NULL
				DROP TABLE #BranzeDlaUzytkownika;
			
			CREATE TABLE #BranzeDlaUzytkownika (BranzaId int);
			CREATE TABLE #CechyBranze (CechaId int);
			CREATE TABLE #Cechy (Id int);
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
			
			--wyciaganie danych id typu obiektu/relacji
			SELECT	@TypObiektuId = C.value('./@Id', 'int')
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'varchar(30)') = 'UnitType'
			
			SELECT	@TypRelacjiId = C.value('./@Id', 'int')
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'varchar(30)') = 'RelationType'	
		
			IF @RequestType = 'AttributeTypes_GetAvailable'
			BEGIN
				BEGIN TRY
				
					-- pobranie daty modyfikacji na podstawie przekazanego AppDate
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
						--pobranie Id branz do ktorych uzytkownik ma uprawnienia
						SET @BranzeZDostepem = THB.GetUserBranchesIds(@UzytkownikId, @AppDate);
						
						INSERT INTO #BranzeDlaUzytkownika(BranzaId)
						SELECT Id FROM [THB].[GetUserBranches] (@UzytkownikId)
						
						-- dodanie frazy na statusy
						SET @StandardWhere = [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);					
					
						--dodanie frazy na daty
						SET @StandardWhere += [THB].[PrepareDatesPhrase] (NULL, @AppDate);	
						
						--pobranie danych Id pasujacych cech do tabeli tymczasowej							
						SET @Query = '
								INSERT INTO #Cechy (Id)
								SELECT allData.Cecha_Id FROM
								(
									SELECT c.Cecha_Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(c.IdArch, c.Cecha_Id) ORDER BY c.Cecha_Id ASC) AS Rn
									FROM [dbo].[Cechy] c
									INNER JOIN
									(
										SELECT ISNULL(c2.IdArch, c2.Cecha_Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, c2.' + @DateFromColumnName + ' AS MaxDate
										FROM [dbo].[Cechy] c2								 
										INNER JOIN 
										('
											
						--pobranie cech w zaleznosci od typu relacji/obiektu					
						IF @TypObiektuId IS NOT NULL
						BEGIN
							-- pobranie Id cech powiazanych z typem obiektu
							SET @Query += '
											SELECT ISNULL(c3.IdArch, c3.Cecha_Id) AS RowID, MAX(c3.' + @DateFromColumnName + ') AS MaxDate
											FROM [dbo].[TypObiektu_Cechy] toc
											JOIN [dbo].[Cechy] c3 ON (toc.Cecha_ID = c3.Cecha_ID)
											WHERE toc.[TypObiektu_ID] = ' + CAST(@TypObiektuId AS varchar)
						END
						ELSE IF @TypRelacjiId IS NOT NULL
						BEGIN
							-- pobranie Id cech powiazanych z typem obiektu
							SET @Query += '
											SELECT ISNULL(c3.IdArch, c3.Cecha_Id) AS RowID, MAX(c3.' + @DateFromColumnName + ') AS MaxDate
											FROM [dbo].[TypRelacji_Cechy] toc
											JOIN [dbo].[Cechy] c3 ON (toc.Cecha_ID = c3.Cecha_ID)
											WHERE toc.[TypRelacji_ID] = ' + CAST(@TypRelacjiId AS varchar)
						END				
						
						-- dodanie frazy na statusy
						SET @Query += [THB].[PrepareStatusesPhrase] ('c3', @StatusS, @StatusP, @StatusW);
						SET @Query += [THB].[PrepareStatusesPhrase] ('toc', @StatusS, @StatusP, @StatusW);					
						
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhrase] ('c3', @AppDate);
						SET @Query += [THB].[PrepareDatesPhrase] ('toc', @AppDate);		
										
						SET @Query += '
											GROUP BY ISNULL(c3.IdArch, c3.Cecha_Id)
										) latest
										ON ISNULL(c2.IdArch, c2.Cecha_Id) = latest.RowID AND c2.' + @DateFromColumnName + ' = latest.MaxDate
										GROUP BY ISNULL(c2.IdArch, c2.Cecha_Id), c2.' + @DateFromColumnName + '					
									) latestWithMaxDate
									ON  ISNULL(c.IdArch, c.Cecha_Id) = latestWithMaxDate.RowID AND c.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND c.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
								) allData
								WHERE allData.Rn = 1'
			
						--PRINT @Query;
						EXECUTE sp_executesql @Query;
	
	--SELECT * FROM #Cechy				
	----				
						IF @BranzaId IS NULL
						BEGIN
	
							-- pobranie id cech ktore nie sa zwiazane z zadna branza
							SET @Query = 'INSERT INTO #CechyBranze(CechaId)
								SELECT Id					
								FROM #Cechy
								WHERE Id NOT IN (SELECT CechaId FROM dbo.[Branze_Cechy] bc WHERE 1=1'
								
							--dodanie frazy statusow na filtracje jesli trzeba
							SET @Query += @StandardWhere;		
					
							SET @Query += ')	
								UNION
								-- pobranie cech zwiazanych z branzami dostepnymi dla uzytkownika
								SELECT Id
								FROM #Cechy
								WHERE Id IN (SELECT CechaId FROM dbo.[Branze_Cechy] bc2 WHERE BranzaId IN (SELECT BranzaId FROM #BranzeDlaUzytkownika WHERE 1=1'
							
							--dodanie frazy statusow na filtracje jesli trzeba
							SET @Query += @StandardWhere;
								
							SET @Query += '))';
						END
						ELSE
						BEGIN					
							SET @Query = 'INSERT INTO #CechyBranze(CechaId)
								SELECT Id					
								FROM #Cechy
								WHERE Id NOT IN (SELECT CechaId FROM dbo.[Branze_Cechy] bc WHERE 1=1'
							
							--dodanie frazy statusow na filtracje jesli trzeba
							SET @Query += @StandardWhere;					
					
							SET @Query += ')
								UNION							
								SELECT Id					
								FROM #Cechy
								WHERE Id IN (SELECT CechaId FROM dbo.[Branze_Cechy] bc2 WHERE (BranzaId = ' + CAST(@BranzaId AS varchar) + ' AND BranzaId IN (SELECT BranzaId FROM #BranzeDlaUzytkownika)'
							
							--dodanie frazy statusow na filtracje jesli trzeba
							SET @Query += @StandardWhere; 
	
							SET @Query += '))';
						END
						
						--PRINT @query;
						EXEC(@Query);				
						
						SET @Query = 'SET @xmlTemp = (';
						
						IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
						BEGIN
							SET @query += 'SELECT ISNULL(c.[IdArch], c.[Cecha_ID]) AS "@Id"
											,c.[Nazwa] AS "@Name"
											,c.[NazwaSkrocona] AS "@ShortName"
											,c.[IsBlocked] AS "@IsBlocked"
											,c.[Hint] AS "@Hint"
											,c.[Opis] AS "@Description"
											,c.[TypID] AS "@TypeId"
											--,CASE WHEN c.[WartoscSlownika] IS NULL THEN ''false'' ELSE ''true'' END AS "@IsDictionary"
											,c.[CzySlownik] AS "@IsDictionary"
											,c.[CzyWymagana] AS "@IsRequired"
											,c.[CzyPusta] AS "@IsEmpty"
											,c.[CzyWyliczana] AS "@IsQuantifiable"
											,c.[CzyPrzetwarzana] AS "@IsProcessed"
											,c.[CzyFiltrowana] AS "@IsFiltered"
											,c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
											,c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
											,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
											,c.[ControlSize] AS "@ControlSize"
											,c.[Format] AS "@Format"
											,c.[JednostkaMiary] AS "@UnitOfMeasureId"
											,c.[WartoscDomyslna] AS "@DefaultValue"
											,c.[Sledzona] AS "@IsTraced"
											,c.[ListaWartosciDopuszczalnych] AS "@ListOfLimitValues"
											,c.[CharakterChwilowy] AS "@TemporaryValue"
											,c.[PrzedzialCzasowyId] AS "@TimeIntervalId"
											,c.[UnitTypeId] AS "@UnitTypeId"
											,c.[RelationTypeId] AS "@RelationTypeId"'
											
							--pobieranie danych podwezlow			
							IF @RozwijajPodwezly = 1
							BEGIN				
						
								SET @query += '
													, (SELECT ct.[Id] AS "@Id"
													,ct.[Nazwa] AS "@Name"
													,ct.[NazwaSQL] AS "@SQLName"
													,ct.[Nazwa_UI] AS "@UIName"
													,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
													,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
													FROM [Cecha_Typy] ct
													WHERE ct.[Id] = c.[TypID] AND ct.IsValid = 1 AND ct.IsDeleted = 0'
													
								IF @AppDate IS NOT NULL
									SET @query += ' AND (ct.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (ct.ValidTo IS NULL OR ct.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' )) '
					
								SET @query += '					
													FOR XML PATH(''DataType''), TYPE
													)
													
													, (SELECT jm.[Id] AS "@Id"
													,jm.[Nazwa] AS "@Name"
													,jm.[NazwaSkrocona] AS "@ShortName"
													,jm.[Uwagi] AS "@Comment"
													,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
													FROM [JednostkiMiary] jm
													WHERE jm.[Id] = c.[JednostkaMiary] AND jm.IsValid = 1 AND jm.IsDeleted = 0'
								
								IF @AppDate IS NOT NULL
									SET @query += ' AND (jm.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (jm.ValidTo IS NULL OR jm.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' )) '
													
								SET @query += '
													FOR XML PATH(''UnitOfMeasure''), TYPE
													)'
													
								SET @query += '
													, (SELECT bc.[BranzaId] AS "@Id"
													, ''Branch'' AS "@EntityType"
													FROM [Branze_Cechy]	bc
													WHERE (bc.[CechaId] = c.[Cecha_ID] OR bc.[CechaId] = c.[IdArch]) AND IsDeleted = 0' --AND IdArch IS NULL ANd IsValid = 1
													
								IF @AppDate IS NOT NULL
									SET @query += ' AND (bc.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (bc.ValidTo IS NULL OR bc.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' )) '
					
								SET @query += '
													FOR XML PATH(''Ref''), ROOT(''LinkedBranches''), TYPE
													)'
																	
							END																		
						END
						ELSE  -- pobranie wszystkich danych
						BEGIN
							SET @query += 'SELECT ISNULL(c.[IdArch], c.[Cecha_ID]) AS "@Id"
											,c.[Nazwa] AS "@Name"
											,c.[NazwaSkrocona] AS "@ShortName"
											,c.[IsBlocked] AS "@IsBlocked"
											,c.[Hint] AS "@Hint"
											,c.[Opis] AS "@Description"
											,c.[TypID] AS "@TypeId"
											--,CASE WHEN c.[WartoscSlownika] IS NULL THEN ''false'' ELSE ''true'' END AS "@IsDictionary"
											,c.[CzySlownik] AS "@IsDictionary"
											,c.[CzyWymagana] AS "@IsRequired"
											,c.[CzyPusta] AS "@IsEmpty"
											,c.[CzyWyliczana] AS "@IsQuantifiable"
											,c.[CzyPrzetwarzana] AS "@IsProcessed"
											,c.[CzyFiltrowana] AS "@IsFiltered"
											,c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
											,c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
											,c.[ControlSize] AS "@ControlSize"
											,c.[Format] AS "@Format"
											,c.[JednostkaMiary] AS "@UnitOfMeasureId"
											,c.[WartoscDomyslna] AS "@DefaultValue"
											,c.[ListaWartosciDopuszczalnych] AS "@ListOfLimitValues"
											,c.[CharakterChwilowy] AS "@TemporaryValue"
										    ,c.[Sledzona] AS "@IsTraced"
											,c.[PrzedzialCzasowyId] AS "@TimeIntervalId"
											,c.[UnitTypeId] AS "@UnitTypeId"
									        ,c.[RelationTypeId] AS "@RelationTypeId"
										  ,c.[IsDeleted] AS "@IsDeleted"
										  ,c.[DeletedFrom] AS "@DeletedFrom"
										  ,c.[DeletedBy] AS "@DeletedBy"
										  ,c.[CreatedOn] AS "@CreatedOn"
										  ,c.[CreatedBy] AS "@CreatedBy"
										  ,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
										  ,c.[LastModifiedBy] AS "@LastModifiedBy"
										  ,c.[ObowiazujeOd] AS "History/@EffectiveFrom"
										  ,c.[ObowiazujeDo] AS "History/@EffectiveTo"
										  ,c.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
										  ,c.[IsMainHistFlow] AS "History/@IsMainHistFlow"
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
										  ,c.[StatusPToBy] AS "Statuses/@StatusPToBy"';
									  
							--pobieranie danych podwezlow			
							IF @RozwijajPodwezly = 1
							BEGIN
								SET @query += ', (SELECT ct.[Id] AS "@Id"
													,ct.[Nazwa] AS "@Name"
													,ct.[NazwaSQL] AS "@SQLName"
													,ct.[Nazwa_UI] AS "@UIName"
													,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
													,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
													FROM [Cecha_Typy] ct
													WHERE ct.[Id] = c.[TypID] AND ct.IsValid = 1 AND ct.IsDeleted = 0'
													
								IF @AppDate IS NOT NULL
									SET @query += ' AND (ct.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (ct.ValidTo IS NULL OR ct.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' )) '
					
								SET @query += '
													FOR XML PATH(''DataType''), TYPE
													)
													
													,(SELECT jm.[Id] AS "@Id"
													,jm.[Nazwa] AS "@Name"
													,jm.[NazwaSkrocona] AS "@ShortName"
													,jm.[Uwagi] AS "@Comment"
													,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
													FROM [JednostkiMiary] jm
													WHERE jm.[Id] = c.[JednostkaMiary] AND jm.IsValid = 1 AND jm.IsDeleted = 0'
								
								IF @AppDate IS NOT NULL
									SET @query += ' AND (jm.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (jm.ValidTo IS NULL OR jm.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' )) '
									 
								SET @query += '
													FOR XML PATH(''UnitOfMeasure''), TYPE
													)'
												
								SET @query += '
													, (SELECT bc.[BranzaId] AS "@Id"
													, ''Branch'' AS "@EntityType"
													FROM [Branze_Cechy]	bc
													WHERE (bc.[CechaId] = c.[Cecha_ID] OR bc.[CechaId] = c.[IdArch]) AND IsDeleted = 0' --IsArchive IS NULL
													
								IF @AppDate IS NOT NULL
									SET @query += ' AND (bc.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (bc.ValidTo IS NULL OR bc.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' )) '
					
								SET @query += '
													FOR XML PATH(''Ref''), ROOT(''LinkedBranches''), TYPE
													)'					
							END				  					  
						END	
				
						SET @query += ' FROM [Cechy] c
									WHERE c.Cecha_ID IN (SELECT CechaId FROM #CechyBranze)
									AND c.IsValid = 1 AND c.IsDeleted = 0'
									
						IF @AppDate IS NOT NULL
							SET @query += ' AND (c.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (c.ValidTo IS NULL OR c.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' )) '
					
					
						SET @query += ' FOR XML PATH(''AttributeType'') )';
			
						--PRINT @query;
						EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
		
					END
					ELSE
						EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'AttributeTypes_GetAvailable', @Wiadomosc = @ERRMSG OUTPUT 
			
				END TRY
				BEGIN CATCH
					SET @ERRMSG = CAST(@@ERROR AS varchar);
					SET @ERRMSG += ' '
					SET @ERRMSG += ERROR_MESSAGE();
				END CATCH			
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'AttributeTypes_GetAvailable', @Wiadomosc = @ERRMSG OUTPUT			
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="AttributeTypes_GetAvailable"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>'
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	
	IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
		DROP TABLE #Cechy;
		
	IF OBJECT_ID('tempdb..#CechyTmp') IS NOT NULL
		DROP TABLE #CechyTmp;
	
	IF OBJECT_ID('tempdb..#CechyBranze') IS NOT NULL
		DROP TABLE #CechyBranze;
		
	IF OBJECT_ID('tempdb..#BranzeDlaUzytkownika') IS NOT NULL
		DROP TABLE #BranzeDlaUzytkownika;
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 
END
