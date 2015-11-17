-- =============================================
-- Author:		DK
-- Create date: 2012-03-20
-- Last modified on: 2013-02-14
-- Description:	Pobiera dane z tabeli TypRelacji z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="RelationTypes_Get" GetFullColumnsData="true" UserId="1" StatusS="" StatusP="" StatusW="" AppDate="2012-02-09T11:34:23" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<CompositeFilterDescriptor LogicalOperator="AND" xsi:noNamespaceSchemaLocation="GenericFilter.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--		<FilterDescriptor PropertyName="Id" Operator="IsGreaterThanOrEqualTo" Value="1" />
	--	</CompositeFilterDescriptor>
	--	<SortDescriptors>
	--		<SortDescriptor PropertyName="Nazwa" Direction="Descending"></SortDescriptor>
	--	</SortDescriptors>
	--	<Paging PageSize="5" PageIndex="1" />
	--</Request>

-- XM wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="RelationTypes_Get" AppDate="2012-02-09T13:23:22">

	--<!-- przy <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../> -->
	--	<RelationType Id="1" Name="efew" TypeId="45" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121" ChangeTo="2012-02-09T12:12:12.121" EffectiveFrom="2012-02-09T12:12:12.121" EffectiveTo="2012-02-09T12:12:12.121" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121" StatusSTo="2012-02-09T12:12:12.121" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121" StatusWTo="2012-02-09T12:12:12.121" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121" StatusPTo="2012-02-09T12:12:12.121" StatusPFromBy="1" StatusPToBy="1"/>
	--		<RelationBaseType Id="45" Name="weqwee" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121" LastModifiedBy="1"/>
	--		<CouplerAttributeType Id="1" Importance="2" AttributeTypeId="3" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="0" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="0" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="0" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="0" Priority="1" UIOrder="3">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			<AttributeType Id="1" Name="?" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" 
	--			IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0" IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z"/>
	--		</CouplerAttributeType>
	--	</RelationType>		

	--<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="true" ../> -->
	--	<RelationType Id="1" Name="?" TypeId="45" LastModifiedOn="2012-02-09T12:12:12.121">
	--		<CouplerAttributeType Id="1" Importance="2" AttributeTypeId="3" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3"/>
	--	</RelationType>		
		
	--<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="false" ../> -->
	--	<RelationType Id="1" Name="?" TypeId="45" LastModifiedOn="2012-02-09T12:12:12.121"/>

	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[RelationTypes_Get]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@stronicowanieWl bit = 0,
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
		@StandardWhere nvarchar(300) = '',
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DateFromColumnName nvarchar(100)
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_StandardRequest', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			BEGIN TRY
			
			--usuwanie tabel tymczasowych, jesli istnieja				
			IF OBJECT_ID('tempdb..#TypyRelacjiFinal') IS NOT NULL
				DROP TABLE #TypyRelacjiFinal
				
			IF OBJECT_ID('tempdb..#TypyRelacji') IS NOT NULL
				DROP TABLE #TypyRelacji
				
			IF OBJECT_ID('tempdb..#TypyRelacjiCechy') IS NOT NULL
				DROP TABLE #TypyRelacjiCechy
				
			CREATE TABLE #TypyRelacjiFinal (Id int, IdArch int);			
			CREATE TABLE #TypyRelacji (Id int, IdArch int);		
			CREATE TABLE #TypyRelacjiCechy (Id int);			
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
	
			IF @RequestType = 'RelationTypes_Get'
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
						@WhereClause = @WhereClause OUTPUT,
						@OrderByClause = @OrderByClause OUTPUT,
						@PageSize = @RozmiarStrony OUTPUT,
						@PageIndex = @NumerStrony OUTPUT,
						@ERRMSG = @ERRMSG OUTPUT
										
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @StandardWhere += [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @StandardWhere += [THB].[PrepareDatesPhrase] (NULL, @AppDate);	
											
					IF @WhereClause IS NOT NULL
						SET @StandardWhere += [THB].PrepareSafeQuery(@WhereClause);	
						
				--	SELECT 	@WhereClause, @OrderByClause, @RozmiarStrony, @NumerStrony, @ERRMSG		

					IF @NumerStrony IS NOT NULL AND @NumerStrony > 0 AND @RozmiarStrony IS NOT NULL AND @RozmiarStrony > 0
					BEGIN
						SET @from = ((@NumerStrony - 1) * @RozmiarStrony);	
						SET @to = ((@NumerStrony) * @RozmiarStrony);			
						SET @stronicowanieWl = 1;
					END
			
					--ustawienie sortowania dla funkcji rankingowych
					IF @OrderByClause IS NULL OR @OrderByClause = ''
						SET @OrderByClause = 'TypRelacji_ID ASC';	
						
					--pobranie danych Id pasujacych typow relacji do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #TypyRelacji (Id, IdArch)
							SELECT allData.TypRelacji_Id, allData.IdArch FROM
							(
								SELECT tr.TypRelacji_Id, tr.IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(tr.IdArch, tr.TypRelacji_Id) ORDER BY tr.TypRelacji_Id ASC) AS Rn
								FROM [dbo].[TypRelacji] tr
								INNER JOIN
								(
									SELECT ISNULL(tr2.IdArch, tr2.TypRelacji_Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, tr2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[TypRelacji] tr2								 
									INNER JOIN 
									(
										SELECT ISNULL(tr3.IdArch, tr3.TypRelacji_Id) AS RowID, MAX(tr3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[TypRelacji] tr3
										WHERE 1=1' + @StandardWhere;							
									
					SET @Query += '
										GROUP BY ISNULL(tr3.IdArch, tr3.TypRelacji_Id)
									) latest
									ON ISNULL(tr2.IdArch, tr2.TypRelacji_Id) = latest.RowID AND tr2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(tr2.IdArch, tr2.TypRelacji_Id), tr2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(tr.IdArch, tr.TypRelacji_Id) = latestWithMaxDate.RowID AND tr.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND tr.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;									
---						
					
					--posortowanie i wybranie przedzialu stronicowego pasujacych branz
					SET @Query = 'INSERT INTO #TypyRelacjiFinal (Id, IdArch)
						SELECT TypRelacji_ID, IdArch FROM
						(
							SELECT TypRelacji_ID, IdArch, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [TypRelacji] 
							WHERE TypRelacji_ID IN (SELECT Id FROM #TypyRelacji)
						) X
						WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @query
					
					IF @RozwijajPodwezly = 1
					BEGIN						
						
						--pobranie danych Id pasujacych relacji do tabeli tymczasowej							
						SET @Query = '
								INSERT INTO #TypyRelacjiCechy (Id)
								SELECT allData.Id FROM
								(
									SELECT trc.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(trc.IdArch, trc.Id) ORDER BY trc.Id ASC) AS Rn
									FROM [dbo].[TypRelacji_Cechy] trc
									INNER JOIN
									(
										SELECT ISNULL(trc2.IdArch, trc2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, trc2.' + @DateFromColumnName + ' AS MaxDate
										FROM [dbo].[TypRelacji_Cechy] trc2								 
										INNER JOIN 
										(
											SELECT ISNULL(trc3.IdArch, trc3.Id) AS RowID, MAX(trc3.' + @DateFromColumnName + ') AS MaxDate
											FROM [dbo].[TypRelacji_Cechy] trc3
											WHERE TypRelacji_ID IN (SELECT ISNULL(IdArch, Id) FROM #TypyRelacjiFinal)' + @StandardWhere;							
										
						SET @Query += '
											GROUP BY ISNULL(trc3.IdArch, trc3.Id)
										) latest
										ON ISNULL(trc2.IdArch, trc2.Id) = latest.RowID AND trc2.' + @DateFromColumnName + ' = latest.MaxDate
										GROUP BY ISNULL(trc2.IdArch, trc2.Id), trc2.' + @DateFromColumnName + '					
									) latestWithMaxDate
									ON  ISNULL(trc.IdArch, trc.Id) = latestWithMaxDate.RowID AND trc.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND trc.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
								) allData
								WHERE allData.Rn = 1'
			
						--PRINT @Query;
						EXECUTE sp_executesql @Query;
						
					END												  
---					
					SET @query = 'SET @xmlTemp = (';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @query += 'SELECT ISNULL(tr.[IdArch], tr.[TypRelacji_ID]) AS "@Id"
										,tr.[Nazwa] AS "@Name"
										,tr.[BazowyTypRelacji_Id] AS "@TypeId"
										,ISNULL(tr.[LastModifiedBy], ISNULL(tr.[CreatedBy], '''')) AS "@LastModifiedBy"
										,ISNULL(tr.[LastModifiedOn], ISNULL(tr.[CreatedOn], '''')) AS "@LastModifiedOn"'
											
						--pobieranie danych podwezlow - cech typu relacji		
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @query += ', (SELECT rt.[Id] AS "@Id"
												,rt.[Nazwa] AS "@Name"
												,ISNULL(rt.[LastModifiedBy], ISNULL(rt.[CreatedBy], '''')) AS "@LastModifiedBy"
												,ISNULL(rt.[LastModifiedOn], rt.[CreatedOn]) AS "@LastModifiedOn"
												FROM [Relacja_Typ] rt
												WHERE rt.Id = tr.BazowyTypRelacji_Id
												FOR XML PATH(''RelationBaseType''), TYPE
											)'
							
							SET @query += '
											, (SELECT trc.[Id] AS "@Id"
												,trc.[Cecha_ID] AS "@AttributeTypeId"
												,trc.[Priority] AS "@Priority"
												,trc.[UIOrder] AS "@UIOrder"
												,trc.[Importance] AS "@Importance"
												,ISNULL(trc.[LastModifiedBy], ISNULL(trc.[CreatedBy], '''')) AS "@LastModifiedBy"
												,ISNULL(trc.[LastModifiedOn], ISNULL(trc.[CreatedOn], '''')) AS "@LastModifiedOn"
												FROM [TypRelacji_Cechy] trc
												WHERE (trc.TypRelacji_ID = tr.TypRelacji_ID OR trc.TypRelacji_ID = tr.IdArch) AND trc.ID IN (SELECT Id FROM #TypyRelacjiCechy)
												FOR XML PATH(''CouplerAttributeType''), TYPE
												)'		
						END
					END
					ELSE --pobranie wszystkich danych
					BEGIN
						SET @query += 'SELECT ISNULL(tr.[IdArch], tr.[TypRelacji_ID]) AS "@Id"
										  ,tr.[Nazwa] AS "@Name"
										  ,tr.[BazowyTypRelacji_Id] AS "@TypeId"
										  ,tr.[IsDeleted] AS "@IsDeleted"
										  ,tr.[DeletedFrom] AS "@DeletedFrom"
										  ,tr.[DeletedBy] AS "@DeletedBy"
										  ,tr.[CreatedOn] AS "@CreatedOn"
										  ,tr.[CreatedBy] AS "@CreatedBy"
										  ,ISNULL(tr.[LastModifiedBy], ISNULL(tr.[CreatedBy], '''')) AS "@LastModifiedBy"
										  ,ISNULL(tr.[LastModifiedOn], ISNULL(tr.[CreatedOn], '''')) AS "@LastModifiedOn"
										  ,tr.[ObowiazujeOd] AS "History/@EffectiveFrom"
										  ,tr.[ObowiazujeDo] AS "History/@EffectiveTo"
										  ,tr.[IsMainHistFlow] AS "History/@IsMainHistFlow"
										  ,tr.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
										  ,tr.[IsStatus] AS "Statuses/@IsStatus"
										  ,tr.[StatusS] AS "Statuses/@StatusS"
										  ,tr.[StatusSFrom] AS "Statuses/@StatusSFrom"
										  ,tr.[StatusSTo] AS "Statuses/@StatusSTo"
										  ,tr.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
										  ,tr.[StatusSToBy] AS "Statuses/@StatusSToBy"
										  ,tr.[StatusW] AS "Statuses/@StatusW"
										  ,tr.[StatusWFrom] AS "Statuses/@StatusWFrom"
										  ,tr.[StatusWTo] AS "Statuses/@StatusWTo"
										  ,tr.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
										  ,tr.[StatusWToBy] AS "Statuses/@StatusWToBy"
										  ,tr.[StatusP] AS "Statuses/@StatusP"
										  ,tr.[StatusPFrom] AS "Statuses/@StatusPFrom"
										  ,tr.[StatusPTo] AS "Statuses/@StatusPTo"
										  ,tr.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
										  ,tr.[StatusPToBy] AS "Statuses/@StatusPToBy"';
										  
						--pobieranie danych podwezlow - cech typu relacji			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @query += ', (SELECT rt.[Id] AS "@Id"
												,rt.[Nazwa] AS "@Name"
												,rt.[IsDeleted] AS "@IsDeleted"
												,rt.[DeletedFrom] AS "@DeletedFrom"
												,rt.[DeletedBy] AS "@DeletedBy"
												,rt.[CreatedOn] AS "@CreatedOn"
												,rt.[CreatedBy] AS "@CreatedBy"
												,ISNULL(rt.[LastModifiedBy], ISNULL(rt.[CreatedBy], '''')) AS "@LastModifiedBy"
												,ISNULL(rt.[LastModifiedOn], rt.[CreatedOn]) AS "@LastModifiedOn"
												,rt.[ObowiazujeOd] AS "History/@EffectiveFrom"
												,rt.[ObowiazujeDo] AS "History/@EffectiveTo"
												,rt.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
												,rt.[IsMainHistFlow] AS "History/@IsMainHistFlow"
												,rt.[IsStatus] AS "Statuses/@IsStatus"
												,rt.[StatusS] AS "Statuses/@StatusS"
												,rt.[StatusSFrom] AS "Statuses/@StatusSFrom"
												,rt.[StatusSTo] AS "Statuses/@StatusSTo"
												,rt.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
												,rt.[StatusSToBy] AS "Statuses/@StatusSToBy"
												,rt.[StatusW] AS "Statuses/@StatusW"
												,rt.[StatusWFrom] AS "Statuses/@StatusWFrom"
												,rt.[StatusWTo] AS "Statuses/@StatusWTo"
												,rt.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
												,rt.[StatusWToBy] AS "Statuses/@StatusWToBy"
												,rt.[StatusP] AS "Statuses/@StatusP"
												,rt.[StatusPFrom] AS "Statuses/@StatusPFrom"
												,rt.[StatusPTo] AS "Statuses/@StatusPTo"
												,rt.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
												,rt.[StatusPToBy] AS "Statuses/@StatusPToBy"
												FROM [Relacja_Typ] rt
												WHERE rt.Id = tr.BazowyTypRelacji_Id
												FOR XML PATH(''RelationBaseType''), TYPE
											)'						
						
								SET @query += '
											, (SELECT trc.[Id] AS "@Id"
												,trc.[Cecha_ID] AS "@AttributeTypeId"
												,trc.[Priority] AS "@Priority"
												,trc.[UIOrder] AS "@UIOrder"
												,trc.[Importance] AS "@Importance"
												,trc.[IsDeleted] AS "@IsDeleted"
												,trc.[DeletedFor] AS "@DeletedFrom"
												,trc.[DeletedBy] AS "@DeletedBy"
												,trc.[CreatedOn] AS "@CreatedOn"
												,trc.[CreatedBy] AS "@CreatedBy"
												,ISNULL(trc.[LastModifiedOn], trc.[CreatedOn]) AS "@LastModifiedOn"
												,ISNULL(trc.[LastModifiedBy], ISNULL(trc.[CreatedBy], '''')) AS "@LastModifiedBy"
												,trc.[ObowiazujeOd] AS "History/@EffectiveFrom"
												,trc.[ObowiazujeDo] AS "History/@EffectiveTo"
												,trc.[IsMainHistFlow] AS "History/@IsMainHistFlow"
												,trc.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
												,trc.[IsStatus] AS "Statuses/@IsStatus"
												,trc.[StatusS] AS "Statuses/@StatusS"
												,trc.[StatusSFrom] AS "Statuses/@StatusSFrom"
												,trc.[StatusSTo] AS "Statuses/@StatusSTo"
												,trc.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
												,trc.[StatusSToBy] AS "Statuses/@StatusSToBy"
												,trc.[StatusW] AS "Statuses/@StatusW"
												,trc.[StatusWFrom] AS "Statuses/@StatusWFrom"
												,trc.[StatusWTo] AS "Statuses/@StatusWTo"
												,trc.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
												,trc.[StatusWToBy] AS "Statuses/@StatusWToBy"
												,trc.[StatusP] AS "Statuses/@StatusP"
												,trc.[StatusPFrom] AS "Statuses/@StatusPFrom"
												,trc.[StatusPTo] AS "Statuses/@StatusPTo"
												,trc.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
												,trc.[StatusPToBy] AS "Statuses/@StatusPToBy"'
												
									SET @query += '											
												, (SELECT c.[Cecha_ID] AS "@Id"
															,c.[Nazwa] AS "@Name"
															,c.[NazwaSkrocona] AS "@ShortName"
															,c.[Hint] AS "@Hint"
															,c.[Opis] AS "@Description"
															,c.[TypID] AS "@TypeId"
															,c.[CzySlownik] AS "@IsDictionary"
															,c.[CzyWymagana] AS "@IsRequired"
															,c.[CzyPusta] AS "@IsEmpty"
															,c.[CzyWyliczana] AS "@IsQuantifiable"
															,c.[CzyPrzetwarzana] AS "@IsProcessed"
															,c.[CzyFiltrowana] AS "@IsFiltered"
															,c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
															,c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
															,c.[CharakterChwilowy] AS "@TemporaryValue"
									    					,c.[PrzedzialCzasowyId] AS "@TimeIntervalId"
															,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
															,ISNULL(c.[LastModifiedBy], ISNULL(c.[CreatedBy], '''')) AS "@LastModifiedBy"
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
															,c.[StatusPToBy] AS "Statuses/@StatusPToBy"
															FROM [Cechy] c
															WHERE c.Cecha_ID = trc.Cecha_ID
															FOR XML PATH(''AttributeType''), TYPE
													)
												FROM [TypRelacji_Cechy] trc
												WHERE (trc.TypRelacji_ID = tr.TypRelacji_ID OR trc.TypRelacji_ID = tr.IdArch) AND trc.ID IN (SELECT Id FROM #TypyRelacjiCechy)
												FOR XML PATH(''CouplerAttributeType''), TYPE
												)'					
						END					  
					END
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 13) = 'TypRelacji_ID'
						SET @OrderByClause = REPLACE(@OrderByClause, 'TypRelacji_ID', '1');
					
					SET @Query += ' FROM [TypRelacji] tr
									WHERE TypRelacji_ID IN (SELECT ID FROM #TypyRelacjiFinal)
									ORDER BY ' + @OrderByClause + ' FOR XML PATH(''RelationType'') )';	
			
					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
					SELECT @IloscRekordow = COUNT(1) FROM #TypyRelacji;

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'RelationTypes_Get', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'RelationTypes_Get', @Wiadomosc = @ERRMSG OUTPUT
			
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH	
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="RelationTypes_Get"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
	--dodanie do odpowiedzi informacji o stronach
	IF @stronicowanieWl = 1
	BEGIN
		SET @XMLDataOut += '<TotalPages PageIndex="' + CAST(@NumerStrony AS varchar) + '" PageSize="' + CAST(@RozmiarStrony AS varchar) + '" ItemCount="' + CAST(ISNULL(@IloscRekordow, 0) AS varchar) + '"/>'; 
	END

	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), ''); 
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>'; 
	
	--usuwanie tabel tymczasowych, jesli istnieja		
	IF OBJECT_ID('tempdb..#TypyRelacjiFinal') IS NOT NULL
		DROP TABLE #TypyRelacjiFinal
		
	IF OBJECT_ID('tempdb..#TypyRelacji') IS NOT NULL
		DROP TABLE #TypyRelacji
		
	IF OBJECT_ID('tempdb..#TypyRelacjiCechy') IS NOT NULL
		DROP TABLE #TypyRelacjiCechy
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
