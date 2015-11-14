-- =============================================
-- Author:		DK
-- Create date: 2012-10-03
-- Last modified on: 2013-02-25
-- Description:	Pobiera dane z tabeli Cechy dla cech o podanych Id.

-- XML wejsciowy w postaci:

	--<Request RequestType="AttributeTypes_GetByIds" UserId="1" AppDate="2012-09-09T12:55:11" GetFullColumnsData="true" ExpandNestedValues="true">
	--	<Ref Id="1" EntityType="AttributeType"/>
	--	<Ref Id="2" EntityType="AttributeType"/>		
	--</Request>

-- XM wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="AttributeTypes_GetByIds" AppDate="2012-09-09"> 

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
	--		IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z" TimeIntervalId="4" TemporaryValue="true">
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
CREATE PROCEDURE [THB].[AttributeTypes_GetByIds]
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
		@xmlResponse xml,
		@RozwijajPodwezly bit = 0,
		@MaUprawnienia bit = 0,
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DateFromColumnName nvarchar(100),
		@StandardWhere nvarchar(MAX)
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#IDCechDoPobrania') IS NOT NULL
			DROP TABLE #IDCechDoPobrania
		
		IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
			DROP TABLE #Cechy;
		
		CREATE TABLE #IDCechDoPobrania (Id int);
		CREATE TABLE #Cechy (Id int, IdArch int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_GetByIds', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
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
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
		
			IF @RequestType = 'AttributeTypes_GetByIds'
			BEGIN
			
				--wyciaganie ID cech do pobrania
				INSERT INTO #IDCechDoPobrania(Id)
				SELECT	C.value('./@Id', 'int')
				FROM @xml_data.nodes('/Request/Ref') T(C)
				WHERE C.value('./@EntityType', 'varchar(30)') = 'AttributeType'
				
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
				
					SET @StandardWhere = [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);					
					
					--dodanie frazy na daty
					SET @StandardWhere += [THB].[PrepareDatesPhrase] (NULL, @AppDate);						
---										
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
									(
										SELECT ISNULL(c3.IdArch, c3.Cecha_Id) AS RowID, MAX(c3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Cechy] c3
										WHERE (Cecha_Id IN (SELECT Id FROM #IDCechDoPobrania) OR IdArch IN (SELECT Id FROM #IDCechDoPobrania))' + @StandardWhere;									 
									
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

--SELECT * FROM #Cechy;												  
---					
					SET @Query = 'SET @xmlTemp = (';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @Query += 'SELECT ISNULL(c.IdArch, c.[Cecha_ID]) AS "@Id"
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
									    ,c.[ListaWartosciDopuszczalnych] AS "@ListOfLimitValues"
									    ,c.[CharakterChwilowy] AS "@TemporaryValue"
									    ,c.[PrzedzialCzasowyId] AS "@TimeIntervalId"
									    ,c.[Sledzona] AS "@IsTraced"
									    ,c.[UnitTypeId] AS "@UnitTypeId"
									    ,c.[RelationTypeId] AS "@RelationTypeId"'
										
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN				
					
							SET @Query += '
												, (SELECT ct.[Id] AS "@Id"
												,ct.[Nazwa] AS "@Name"
												,ct.[NazwaSQL] AS "@SQLName"
												,ct.[Nazwa_UI] AS "@UIName"
												,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
												,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
												FROM [Cecha_Typy] ct
												WHERE ct.[Id] = c.[TypID]
												FOR XML PATH(''DataType''), TYPE
												)
												
												, (SELECT jm.[Id] AS "@Id"
												,jm.[Nazwa] AS "@Name"
												,jm.[NazwaSkrocona] AS "@ShortName"
												,jm.[Uwagi] AS "@Comment"
												,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
												FROM [JednostkiMiary] jm
												WHERE jm.[Id] = c.[JednostkaMiary] 
												FOR XML PATH(''UnitOfMeasure''), TYPE
												)'
												
							SET @Query += '
												, (SELECT bc.[BranzaId] AS "@Id"
												, ''Branch'' AS "@EntityType"
												FROM [Branze_Cechy]	bc
												WHERE (bc.[CechaId] = c.[Cecha_ID] OR bc.[CechaId] = c.[IdArch])' 
												
							SET @Query += @StandardWhere;
				
							SET @Query += '
												FOR XML PATH(''Ref''), ROOT(''LinkedBranches''), TYPE
												)'
																	
						END																		
					END
					ELSE --pobranie wszystkich danych
					BEGIN
						SET @Query += 'SELECT ISNULL(c.IdArch, c.[Cecha_ID]) AS "@Id"
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
										,c.[IsDeleted] AS "@IsDeleted"
										,c.[DeletedFrom] AS "@DeletedFrom"
										,c.[DeletedBy] AS "@DeletedBy"
										,c.[CreatedOn] AS "@CreatedOn"
										,c.[CreatedBy] AS "@CreatedBy"
										,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
										,c.[LastModifiedBy] AS "@LastModifiedBy"									  
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
							SET @Query += ', (SELECT ct.[Id] AS "@Id"
												,ct.[Nazwa] AS "@Name"
												,ct.[NazwaSQL] AS "@SQLName"
												,ct.[Nazwa_UI] AS "@UIName"
												,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
												,ct.[IsDeleted] AS "@IsDeleted"
												,ct.[DeletedFrom] AS "@DeletedFrom"
												,ct.[DeletedBy] AS "@DeletedBy"
												,ct.[CreatedOn] AS "@CreatedOn"
												,ct.[CreatedBy] AS "@CreatedBy"
												,ct.[LastModifiedBy] AS "@LastModifiedBy"
												,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
												,ct.[ObowiazujeOd] AS "History/@EffectiveFrom"
												,ct.[ObowiazujeDo] AS "History/@EffectiveTo"
												,ct.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
												,ct.[IsMainHistFlow] AS "History/@IsMainHistFlow"
												,ct.[IsStatus] AS "Statuses/@IsStatus"
												,ct.[StatusS] AS "Statuses/@StatusS"
												,ct.[StatusSFrom] AS "Statuses/@StatusSFrom"
												,ct.[StatusSTo] AS "Statuses/@StatusSTo"
												,ct.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
												,ct.[StatusSToBy] AS "Statuses/@StatusSToBy"
												,ct.[StatusW] AS "Statuses/@StatusW"
												,ct.[StatusWFrom] AS "Statuses/@StatusWFrom"
												,ct.[StatusWTo] AS "Statuses/@StatusWTo"
												,ct.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
												,ct.[StatusWToBy] AS "Statuses/@StatusWToBy"
												,ct.[StatusP] AS "Statuses/@StatusP"
												,ct.[StatusPFrom] AS "Statuses/@StatusPFrom"
												,ct.[StatusPTo] AS "Statuses/@StatusPTo"
												,ct.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
												,ct.[StatusPToBy] AS "Statuses/@StatusPToBy"
												FROM [Cecha_Typy] ct
												WHERE ct.[Id] = c.[TypID]
												FOR XML PATH(''DataType''), TYPE
												)'
							SET @Query += '					
												,(SELECT jm.[Id] AS "@Id"
												,jm.[Nazwa] AS "@Name"
												,jm.[NazwaSkrocona] AS "@ShortName"
												,jm.[Uwagi] AS "@Comment"
												,jm.[IsDeleted] AS "@IsDeleted"
												,jm.[DeletedFrom] AS "@DeletedFrom"
												,jm.[DeletedBy] AS "@DeletedBy"
												,jm.[CreatedOn] AS "@CreatedOn"
												,jm.[CreatedBy] AS "@CreatedBy"
												,jm.[LastModifiedBy] AS "@LastModifiedBy"	
												,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
												,jm.[ObowiazujeOd] AS "History/@EffectiveFrom"
												,jm.[ObowiazujeDo] AS "History/@EffectiveTo"
												--,jm.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
												--,jm.[IsMainHistFlow] AS "History/@IsMainHistFlow"
												,jm.[IsStatus] AS "Statuses/@IsStatus"
												,jm.[StatusS] AS "Statuses/@StatusS"
												,jm.[StatusSFrom] AS "Statuses/@StatusSFrom"
												,jm.[StatusSTo] AS "Statuses/@StatusSTo"
												,jm.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
												,jm.[StatusSToBy] AS "Statuses/@StatusSToBy"
												,jm.[StatusW] AS "Statuses/@StatusW"
												,jm.[StatusWFrom] AS "Statuses/@StatusWFrom"
												,jm.[StatusWTo] AS "Statuses/@StatusWTo"
												,jm.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
												,jm.[StatusWToBy] AS "Statuses/@StatusWToBy"
												,jm.[StatusP] AS "Statuses/@StatusP"
												,jm.[StatusPFrom] AS "Statuses/@StatusPFrom"
												,jm.[StatusPTo] AS "Statuses/@StatusPTo"
												,jm.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
												,jm.[StatusPToBy] AS "Statuses/@StatusPToBy"
												FROM [JednostkiMiary] jm
												WHERE jm.[Id] = c.[JednostkaMiary] 
												FOR XML PATH(''UnitOfMeasure''), TYPE
												)'
												
							SET @Query += '
												, (SELECT bc.[BranzaId] AS "@Id"
												, ''Branch'' AS "@EntityType"
												FROM [Branze_Cechy]	bc
												WHERE (bc.[CechaId] = c.[Cecha_ID] OR bc.[CechaId] = c.[IdArch])'
												
							SET @Query += @StandardWhere;

							SET @Query += '
												FOR XML PATH(''Ref''), ROOT(''LinkedBranches''), TYPE
												)'					
						END				  					  
					END	
			
					SET @query += 'FROM [Cechy] c
								   WHERE c.Cecha_ID IN (SELECT Id FROM #Cechy)
								   ORDER BY 1
								   FOR XML PATH(''AttributeType'') )';

					--PRINT @query;
					EXECUTE sp_executesql @Query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'AttributeTypes_GetByIds', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'AttributeTypes_GetByIds', @Wiadomosc = @ERRMSG OUTPUT			
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = CAST(@@ERROR AS varchar);
				SET @ERRMSG += ' '
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="AttributeTypes_GetByIds"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>'
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#IDCechDoPobrania') IS NOT NULL
		DROP TABLE #IDCechDoPobrania
	
	IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
		DROP TABLE #Cechy;
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
