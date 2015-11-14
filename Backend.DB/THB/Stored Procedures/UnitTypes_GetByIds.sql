-- =============================================
-- Author:		DK
-- Create date: 2012-03-14
-- Last modified on: 2013-02-12
-- Description:	Pobiera dane z tabeli TypObiektu dla obiektow o podanych ID.

-- XML wejsciowy w postaci:

	--<Request RequestType="UnitTypes_GetByIds" UserId="1" AppDate="2012-09-19T12:54:22" GetFullColumnsData="false"
	--	xsi:noNamespaceSchemaLocation="4.1.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="UnitType" />
	--	<Ref Id="2" EntityType="UnitType" />
	--	<Ref Id="3" EntityType="UnitType" />
	--	<Ref Id="4" EntityType="UnitType" />
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="UnitTypes_GetByIds" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="4.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		
	--	<!-- przy <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../> -->
	--	<UnitType Id="1" Name="?" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<CouplerAttributeType Id="1" AttributeTypeId="3" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="0" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="0" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="0" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="0" Priority="1" UIOrder="3" Importance="3">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			<AttributeType Id="1" Name="?" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0" IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z"/>
	--		</CouplerAttributeType>
	--	</UnitType>
		
	--	<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="true" ../> -->
	--	<UnitType Id="1" Name="?" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<CouplerAttributeType Id="1" AttributeTypeId="3" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3" Importance="1"/>
	--		<CouplerAttributeType Id="1" AttributeTypeId="5" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3"/>
	--	</UnitType>
		
	--	<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="false" ../> -->
	--	<UnitType Id="1" Name="?" LastModifiedOn="2012-02-09T12:12:12.121Z"/>
		
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitTypes_GetByIds]
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
		@BranchId int,
		@PobierzWszystieDane bit = 0,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@RozwijajPodwezly bit = 0,
		@MaUprawnienia bit = 0,
		@IdDozwolonychTypowObiektow nvarchar(MAX),
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@StandardWhere nvarchar(MAX) = '',
		@DateFromColumnName nvarchar(100)
		
		IF OBJECT_ID('tempdb..#IDDoPobrania') IS NOT NULL
			DROP TABLE #IDDoPobrania
						
		IF OBJECT_ID('tempdb..#TypyObiektowDoPobrania') IS NOT NULL
			DROP TABLE #TypyObiektowDoPobrania
			
		IF OBJECT_ID('tempdb..#CechyTypyObiektu') IS NOT NULL
			DROP TABLE #CechyTypyObiektu
			
		IF OBJECT_ID('tempdb..#CechyDlaBranzy') IS NOT NULL
			DROP TABLE #CechyDlaBranzy
		
		CREATE TABLE #TypyObiektowDoPobrania (Id int, IdArch int);
		CREATE TABLE #CechyDlaBranzy(CechaId int);
		CREATE TABLE #IDDoPobrania (Id int);
		CREATE TABLE #CechyTypyObiektu (Id int);
		
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
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@BranchId = C.value('./@BranchId', 'int')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
			
			--wyciaganie ID elenentow do pobrania
			INSERT INTO #IDDoPobrania(Id)
			SELECT	C.value('./@Id', 'int')
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'varchar(30)') = 'UnitType'
	
			IF @RequestType = 'UnitTypes_GetByIds'
			BEGIN		
--SELECT 	@WhereClause, @OrderByClause, @RozmiarStrony, @NumerStrony, @ERRMSG			

				-- pobranie daty na podstawie przekazanego AppDate
				SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);

				--pobranie nazwy kolumny po ktorej filtrowane sa daty
				SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji save
				EXEC [THB].[CheckUserPermission]
					@Operation = N'GET',
					@UserId = @UzytkownikID,
					@BranchId = @BranchId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @StandardWhere += [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @StandardWhere += [THB].[PrepareDatesPhrase] (NULL, @AppDate);
					
					-- pobranie id typow obiektow jakie uzytkownik moze pobrac na podstawie branz
					SET @IdDozwolonychTypowObiektow = [THB].[GetUnitTypesIdsForUserBranches](@UzytkownikId)
					
					--pobranie cech dla podanej branzy - jesli podano
					IF @BranchId IS NOT NULL
					BEGIN

						INSERT INTO #CechyDlaBranzy (CechaId)
						EXEC [THB].[AttributeTypes_GetByBranch] 
							@AppDate = @AppDate,
							@BranchId = @BranchId
					END
					ELSE
					BEGIN

						--pobranie cech na podstawie branz do jakich ma prawa uzytkownik
						SET @Query = 'INSERT INTO #CechyDlaBranzy (CechaId)
									SELECT DISTINCT Cecha_ID
									FROM dbo.[Cechy]
									WHERE 1=1 ' + @StandardWhere;
						
						--PRINT @Query;	
						EXECUTE sp_executesql @query;	
					END					
					
					--pobranie danych Id pasujacych typow obiektow do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #TypyObiektowDoPobrania (Id)
							SELECT allData.TypObiekt_ID FROM
							(
								SELECT to1.TypObiekt_ID, ROW_NUMBER() OVER(PARTITION BY ISNULL(to1.IdArch, to1.TypObiekt_ID) ORDER BY to1.TypObiekt_ID ASC) AS Rn
								FROM [dbo].[TypObiektu] to1
								INNER JOIN
								(
									SELECT ISNULL(to2.IdArch, to2.TypObiekt_ID) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, to2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[TypObiektu] to2								 
									INNER JOIN 
									(
										SELECT ISNULL(to3.IdArch, to3.TypObiekt_ID) AS RowID, MAX(to3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[TypObiektu] to3
										WHERE (to3.TypObiekt_Id IN (SELECT Id FROM #IDDoPobrania) OR to3.IdArch IN (SELECT Id FROM #IDDoPobrania))' + @StandardWhere;																		
						
					IF @IdDozwolonychTypowObiektow IS NOT NULL AND LEN(@IdDozwolonychTypowObiektow) > 0
						SET @Query += ' AND TypObiekt_ID IN (' + @IdDozwolonychTypowObiektow + ')'; 							
									
					SET @Query += '
										GROUP BY ISNULL(to3.IdArch, to3.TypObiekt_ID)
									) latest
									ON ISNULL(to2.IdArch, to2.TypObiekt_ID) = latest.RowID AND to2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(to2.IdArch, to2.TypObiekt_ID), to2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(to1.IdArch, to1.TypObiekt_ID) = latestWithMaxDate.RowID AND to1.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND to1.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;					
					

					--pobranie danych Id pasujacych cech dla typow obiektow do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #CechyTypyObiektu (Id)
							SELECT allData.Id FROM
							(
								SELECT toc.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(toc.IdArch, toc.Id) ORDER BY toc.Id ASC) AS Rn
								FROM [dbo].[TypObiektu_Cechy] toc
								INNER JOIN
								(
									SELECT ISNULL(toc2.IdArch, toc2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, toc2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[TypObiektu_Cechy] toc2								 
									INNER JOIN 
									(
										SELECT ISNULL(toc3.IdArch, toc3.Id) AS RowID, MAX(toc3.' + @DateFromColumnName + ') AS MaxDate
										FROM [TypObiektu_Cechy] toc3
										JOIN [TypObiektu] tob ON (tob.TypObiekt_ID = toc3.TypObiektu_ID OR tob.IdArch = toc3.TypObiektu_ID)
										WHERE tob.TypObiekt_ID IN (SELECT ID FROM #TypyObiektowDoPobrania) AND toc3.Cecha_ID IN (SELECT CechaId FROM #CechyDlaBranzy)';										
										
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('toc3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('toc3', @AppDate);							
									
					SET @Query += '
										GROUP BY ISNULL(toc3.IdArch, toc3.Id)
									) latest
									ON ISNULL(toc2.IdArch, toc2.Id) = latest.RowID AND toc2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(toc2.IdArch, toc2.Id), toc2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(toc.IdArch, toc.Id) = latestWithMaxDate.RowID AND toc.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND toc.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
					
---	zapytanie zwracajace dane jako XML			
					SET @Query = 'SET @xmlTemp = (';
					
					IF @PobierzWszystieDane = 0
					BEGIN
						SET @Query += 'SELECT ISNULL(tob.[IdArch], tob.[TypObiekt_ID]) AS "@Id"
										,tob.[Nazwa] AS "@Name"
										,tob.[Tabela] AS "@IsTable"
										,tob.[IsBlocked] AS "@IsBlocked"
										,ISNULL(tob.[LastModifiedOn], tob.[CreatedOn]) AS "@LastModifiedOn"'
										
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @Query += ', (SELECT toc.[Id] AS "@Id"
												,toc.[Cecha_ID] AS "@AttributeTypeId"
												,ISNULL(toc.[LastModifiedOn], toc.[CreatedOn]) AS "@LastModifiedOn"
												,toc.[Priority] AS "@Priority"
												,toc.[UIOrder] AS "@UIOrder"
												,toc.[Importance] AS "@Importance"
												FROM [TypObiektu_Cechy] toc
												WHERE (toc.[TypObiektu_ID] = tob.[TypObiekt_ID] OR toc.[TypObiektu_ID] = tob.[IdArch]) --AND toc.IdArch IS NULL AND toc.IsValid = 1 AND toc.IsDeleted = 0
												AND toc.Id IN (SELECT Id FROM #CechyTypyObiektu)
												FOR XML PATH(''CouplerAttributeType''), TYPE
												)'					
						END					
					END
					ELSE --pobranie wszystkich danych
					BEGIN
						SET @Query += 'SELECT ISNULL(tob.[IdArch], tob.[TypObiekt_ID]) AS "@Id"
								  ,tob.[Nazwa] AS "@Name"
								  ,tob.[Tabela] AS "@IsTable"
								  ,tob.[IsBlocked] AS "@IsBlocked"
								  ,tob.[IsDeleted] AS "@IsDeleted"
								  ,tob.[DeletedFrom] AS "@DeletedFrom"
								  ,tob.[DeletedBy] AS "@DeletedBy"
								  ,tob.[CreatedOn] AS "@CreatedOn"
								  ,tob.[CreatedBy] AS "@CreatedBy"
								  ,ISNULL(tob.[LastModifiedOn], tob.[CreatedOn]) AS "@LastModifiedOn"
								  ,tob.[LastModifiedBy] AS "@LastModifiedBy"
								  ,tob.[ObowiazujeOd] AS "History/@EffectiveFrom"
								  ,tob.[ObowiazujeDo] AS "History/@EffectiveTo"
								  ,tob.[CzyPrzechowujeHistorie] AS "History/@IsMainHistFlow"
								  ,tob.[IsStatus] AS "Statuses/@IsStatus"
								  ,tob.[StatusS] AS "Statuses/@StatusS"
								  ,tob.[StatusSFrom] AS "Statuses/@StatusSFrom"
								  ,tob.[StatusSTo] AS "Statuses/@StatusSTo"
								  ,tob.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
								  ,tob.[StatusSToBy] AS "Statuses/@StatusSToBy"
								  ,tob.[StatusW] AS "Statuses/@StatusW"
								  ,tob.[StatusWFrom] AS "Statuses/@StatusWFrom"
								  ,tob.[StatusWTo] AS "Statuses/@StatusWTo"
								  ,tob.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
								  ,tob.[StatusWToBy] AS "Statuses/@StatusWToBy"
								  ,tob.[StatusP] AS "Statuses/@StatusP"
								  ,tob.[StatusPFrom] AS "Statuses/@StatusPFrom"
								  ,tob.[StatusPTo] AS "Statuses/@StatusPTo"
								  ,tob.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
								  ,tob.[StatusPToBy] AS "Statuses/@StatusPToBy"';
							  
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @Query += ', (SELECT toc.[Id] AS "@Id"
									,toc.[Cecha_ID] AS "@AttributeTypeId"
									,toc.[Priority] AS "@Priority"
									,toc.[UIOrder] AS "@UIOrder"
									,toc.[Importance] AS "@Importance"
									,toc.[IsDeleted] AS "@IsDeleted"
									,toc.[DeletedFrom] AS "@DeletedFrom"
									,toc.[DeletedBy] AS "@DeletedBy"
									,toc.[CreatedOn] AS "@CreatedOn"
									,toc.[CreatedBy] AS "@CreatedBy"
									,ISNULL(toc.[LastModifiedOn], toc.[CreatedOn]) AS "@LastModifiedOn"
									,toc.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,toc.[ObowiazujeDo] AS "History/@EffectiveTo"
									,toc.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
									,toc.[IsMainHistFlow] AS "History/@IsMainHistFlow"
									,toc.[IsStatus] AS "Statuses/@IsStatus"
									,toc.[StatusS] AS "Statuses/@StatusS"
									,toc.[StatusSFrom] AS "Statuses/@StatusSFrom"
									,toc.[StatusSTo] AS "Statuses/@StatusSTo"
									,toc.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									,toc.[StatusSToBy] AS "Statuses/@StatusSToBy"
									,toc.[StatusW] AS "Statuses/@StatusW"
									,toc.[StatusWFrom] AS "Statuses/@StatusWFrom"
									,toc.[StatusWTo] AS "Statuses/@StatusWTo"
									,toc.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									,toc.[StatusWToBy] AS "Statuses/@StatusWToBy"
									,toc.[StatusP] AS "Statuses/@StatusP"
									,toc.[StatusPFrom] AS "Statuses/@StatusPFrom"
									,toc.[StatusPTo] AS "Statuses/@StatusPTo"
									,toc.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									,toc.[StatusPToBy] AS "Statuses/@StatusPToBy"
									FROM [TypObiektu_Cechy] toc
									WHERE (toc.[TypObiektu_ID] = tob.[TypObiekt_ID] OR toc.[TypObiektu_ID] = tob.[IdArch])  --AND toc.IdArch IS NULL AND toc.IsValid = 1 AND toc.IsDeleted = 0
									AND toc.Id IN (SELECT Id FROM #CechyTypyObiektu)
									FOR XML PATH(''CouplerAttributeType''), TYPE
									)'						
						END	
					END	 
			
					SET @Query += ' FROM [TypObiektu] tob
							WHERE TypObiekt_ID IN (SELECT Id FROM #TypyObiektowDoPobrania)
							FOR XML PATH(''UnitType''))' 
							
					--PRINT @query;
					EXECUTE sp_executesql @Query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitTypes_GetByIds', @Wiadomosc = @ERRMSG OUTPUT	
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitTypes_GetByIds', @Wiadomosc = @ERRMSG OUTPUT
				
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH	
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitTypes_GetByIds"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = '' 	
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');	
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	IF OBJECT_ID('tempdb..#IDDoPobrania') IS NOT NULL
		DROP TABLE #IDDoPobrania
		
	IF OBJECT_ID('tempdb..#TypyObiektowDoPobrania') IS NOT NULL
		DROP TABLE #TypyObiektowDoPobrania
		
	IF OBJECT_ID('tempdb..#CechyTypyObiektu') IS NOT NULL
		DROP TABLE #CechyTypyObiektu
		
	IF OBJECT_ID('tempdb..#CechyDlaBranzy') IS NOT NULL
		DROP TABLE #CechyDlaBranzy
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
