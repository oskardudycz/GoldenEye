-- =============================================
-- Author:		DK
-- Create date: 2012-06-04
-- Last modified on: 2013-02-25
-- Description:	Zwraca historie cech o podanych ID.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="AttributeTypes_GetHistory" UserId="1" AppDate="2012-09-09T12:45:33" xsi:noNamespaceSchemaLocation="16.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="AttributeType" />
	--	<Ref Id="2" EntityType="AttributeType" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="AttributeTypes_GetHistory" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="../Response_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	--	<HistoryOf Id="5" TypeId="56" EntityType="AttributeType">
	--		<AttributeType IsFiltered="false" IsDictionary="false" TypeId="1" IsRequired="true" IsPersonalData="false" Id="1"  IsArchive="false" 
	--		ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" 
	--		CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" Name="Structure_1" 
	--		ControlSize="1" DefaultValue="1" Description="Desciption_1" Format="" Hint="Test_Hint" IsEmpty="false" IsProcessed="false" IsQuantifiable="false" 
	--		IsUserAttribute="false" ListOfLimitValues="" ShortName="ShorName_1" UnitOfMeasureId="1" Visibility="true" TimeIntervalId="2" TemporaryValue="true">
			
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			<DataType LastModifiedOn="2012-02-09T12:12:12.121Z" Id="1" SQLName="1" UIName="10" IsUserAttribute="false" ArchivedBy="1" ArchivedFrom="2012-02-09T12:12:12.121Z" CreatedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" DeletedBy="1" DeletedFrom="2012-02-09T12:12:12.121Z" IsArchive="false" IsDeleted="false" LastModifiedBy="1" Name="DataType_1" />
	--			<UnitOfMeasure LastModifiedOn="2012-02-09T12:12:12.121Z" Id="1" ShortName="UOM_1" ArchivedBy="1" ArchivedFrom="2012-02-09T12:12:12.121Z" CreatedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" DeletedBy="1" DeletedFrom="2012-02-09T12:12:12.121Z" IsArchive="false" IsDeleted="false" LastModifiedBy="1" Comment="Comment_1" Name="UnitOfMeasure_1"/>
	--		</AttributeType>
	--	</HistoryOf>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[AttributeTypes_GetHistory]
(	
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@RequestType nvarchar(100),
		@xml_data xml,
		@xmlOk bit = 0,
		@xmlOut xml,
		@DataProgramu datetime,
		@UzytkownikID int = NULL,
		@BranzaID int,
		@MaUprawnienia bit = 0,
		@ERRMSG nvarchar(255),
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@AppDate datetime
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DoPobrania') IS NOT NULL
		DROP TABLE #DoPobrania
		
	CREATE TABLE #DoPobrania(Id int);
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_GetHistory', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

	IF @xmlOk = 0
	BEGIN
		-- co zrobic jak nie poprawna walidacja XML
		SET @ERRMSG = @ERRMSG;
	END
	ELSE
	BEGIN
		--poprawny XML wejsciowy
		SET @xml_data = CAST(@XMLDataIn AS xml);
		
		--wyciaganie daty i typu zadania
		SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
				,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
				,@BranzaId = C.value('./@BranchId', 'int')
				--,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
				--,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@StatusS = C.value('./@StatusS', 'int')
				,@StatusP = C.value('./@StatusP', 'int')
				,@StatusW = C.value('./@StatusW', 'int')
		FROM @xml_data.nodes('/Request') T(C)
		
		--ustawienie flag na 1 - pobieranie w histrii wszystkich danych
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1; 
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #DoPobrania(Id)
		SELECT	C.value('./@Id', 'int')
		FROM @xml_data.nodes('/Request/Ref') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'AttributeType' 

		--SELECT * FROM #DoPobrania;

		IF @RequestType = 'AttributeTypes_GetHistory'
		BEGIN
			BEGIN TRY
			
			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
			
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			EXEC [THB].[CheckUserPermission]
				@Operation = N'GET',
				@UserId = @UzytkownikID,
				@BranchId = @BranzaId,
				@Result = @MaUprawnienia OUTPUT
			
			IF @MaUprawnienia = 1
			BEGIN				
				
				SET @Query = N' SET @xmlOutVar = (
							SELECT dp.[Id] AS "@Id"
								, 0 AS "@TypeId"
								, ''AttributeType'' AS "@EntityType"';
					
				IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
				BEGIN
					SET @Query += '	
									, (SELECT c.[Cecha_ID] AS "@Id"
									, c.[Nazwa] AS "@Name"
									, c.[NazwaSkrocona] AS "@ShortName"
									, c.[IsBlocked] AS "@IsBlocked"
									, c.[Hint] AS "@Hint"
									, c.[Opis] AS "@Description"
									, c.[TypId] AS "@TypeId"
									, c.[Format] AS "@Format"
									, c.[CzyWymagana] AS "@IsRequired"
									, c.[CzyPusta] AS "@IsEmpty"
									, c.[CzyWyliczana] AS "@IsQuantifiable"
									, c.[CzyPrzetwarzana] AS "@IsProcessed"
									, c.[CzyFiltrowana] AS "@IsFiltered"
									, c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
									, c.[WartoscDomyslna] AS "@DefaultValue"
									, c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
									, c.[ListaWartosciDopuszczalnych] AS "@ListOfLimitValues"
									, c.[Widocznosc] AS "@Visibility"
									, c.[JednostkaMiary] AS "@UnitOfMeasureId"
									, c.[CzySlownik] AS "@IsDictionary"
									,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
									,c.[CharakterChwilowy] AS "@TemporaryValue"
									,c.[Sledzona] AS "@IsTraced"
								    ,c.[PrzedzialCzasowyId] AS "@TimeIntervalId"
								    ,c.[UnitTypeId] AS "@UnitTypeId"
									,c.[RelationTypeId] AS "@RelationTypeId"'		
										
					--pobieranie danych podwezlow			
					IF @RozwijajPodwezly = 1
					BEGIN
						SET @Query += ', (SELECT ct.[Id] AS "@Id"
											,ct.[Nazwa] AS "@Name"
											,ct.[NazwaSQL] AS "@SQLName"
											,ct.[Nazwa_UI] AS "@UIName"
											,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
											,ISNULL(ct.[LastModifiedBy], ct.[CreatedBy]) AS "@LastModifiedBy"
											,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
											FROM [Cecha_Typy] ct
											WHERE (ct.[Id] = c.[TypID] OR c.[TypId] = ct.[IdArch]) AND ct.[ValidFrom] <= c.[ValidFrom] AND (ct.[ValidTo] IS NULL OR (ct.[ValidTo] IS NOT NULL AND ct.[ValidTo] >= c.[ValidTo])) 
											FOR XML PATH(''DataType''), TYPE
											)
											
										,(SELECT jm.[Id] AS "@Id"
											,jm.[Nazwa] AS "@Name"
											,jm.[NazwaSkrocona] AS "@ShortName"
											,jm.[Uwagi] AS "@Comment"
											,ISNULL(jm.[LastModifiedBy], jm.[CreatedBy]) AS "@LastModifiedBy"
											,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
											FROM [JednostkiMiary] jm
											WHERE (jm.[Id] = c.[JednostkaMiary] OR c.[JednostkaMiary] = jm.[IdArch]) AND jm.[ValidFrom] <= c.[ValidFrom] AND (jm.[ValidTo] IS NULL OR (jm.[ValidTo] IS NOT NULL AND jm.[ValidTo] >= c.[ValidTo])) 
											FOR XML PATH(''UnitOfMeasure''), TYPE
											)'					
					END	
					
				END -- pobranie wszystkich danych
				ELSE
				BEGIN
					SET @Query += '							
								, (SELECT c.[Cecha_ID] AS "@Id"
									, c.[Nazwa] AS "@Name"
									, c.[NazwaSkrocona] AS "@ShortName"
									, c.[IsBlocked] AS "@IsBlocked"
									, c.[Hint] AS "@Hint"
									, c.[Opis] AS "@Description"
									, c.[TypId] AS "@TypeId"
									, c.[Format] AS "@Format"
									, c.[CzyWymagana] AS "@IsRequired"
									, c.[CzyPusta] AS "@IsEmpty"
									, c.[CzyWyliczana] AS "@IsQuantifiable"
									, c.[CzyPrzetwarzana] AS "@IsProcessed"
									, c.[CzyFiltrowana] AS "@IsFiltered"
									, c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
									, c.[WartoscDomyslna] AS "@DefaultValue"
									, c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
									, c.[ListaWartosciDopuszczalnych] AS "@ListOfLimitValues"
									, c.[Widocznosc] AS "@Visibility"
									, c.[JednostkaMiary] AS "@UnitOfMeasureId"
									, c.[CzySlownik] AS "@IsDictionary"
									,c.[IsDeleted] AS "@IsDeleted"
									,c.[DeletedFrom] AS "@DeletedFrom"
									,c.[DeletedBy] AS "@DeletedBy"
									,c.[CreatedOn] AS "@CreatedOn"
									,c.[CreatedBy] AS "@CreatedBy"
									,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
									,c.[CharakterChwilowy] AS "@TemporaryValue"
									,c.[Sledzona] AS "@IsTraced"
								    ,c.[PrzedzialCzasowyId] AS "@TimeIntervalId"
								    ,c.[UnitTypeId] AS "@UnitTypeId"
									,c.[RelationTypeId] AS "@RelationTypeId"
									,c.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,c.[ObowiazujeDo] AS "History/@EffectiveTo"
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
									,c.[StatusPToBy] AS "Statuses/@StatusPToBy"'
										
					--pobieranie danych podwezlow			
					IF @RozwijajPodwezly = 1
					BEGIN
						SET @Query += ', (SELECT ct.[Id] AS "@Id"
											,ct.[Nazwa] AS "@Name"
											,ct.[NazwaSQL] AS "@SQLName"
											,ct.[Nazwa_UI] AS "@UIName"
											,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
											,ISNULL(ct.[LastModifiedBy], ct.[CreatedBy]) AS "@LastModifiedBy"
											,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
											FROM [Cecha_Typy] ct
											WHERE (ct.[Id] = c.[TypID] OR c.[TypId] = ct.[IdArch]) AND ct.[ValidFrom] <= c.[ValidFrom] AND (ct.[ValidTo] IS NULL OR (ct.[ValidTo] IS NOT NULL AND ct.[ValidTo] >= c.[ValidTo])) 
											FOR XML PATH(''DataType''), TYPE
											)
											
										, (SELECT jm.[Id] AS "@Id"
											,jm.[Nazwa] AS "@Name"
											,jm.[NazwaSkrocona] AS "@ShortName"
											,jm.[Uwagi] AS "@Comment"
											,ISNULL(jm.[LastModifiedBy], jm.[CreatedBy]) AS "@LastModifiedBy"
											,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
											FROM [JednostkiMiary] jm
											WHERE (jm.[Id] = c.[JednostkaMiary] OR c.[JednostkaMiary] = jm.[IdArch]) AND jm.[ValidFrom] <= c.[ValidFrom] AND (jm.[ValidTo] IS NULL OR (jm.[ValidTo] IS NOT NULL AND jm.[ValidTo] >= c.[ValidTo])) 
											FOR XML PATH(''UnitOfMeasure''), TYPE
											)
											'					
					END							
				END
				
				SET @Query += ' 
					 FROM dbo.[Cechy] c 
					 WHERE (c.Cecha_ID = dp.[Id] OR c.IdArch = dp.[Id])'
					 
				--dodanie frazy statusow na filtracje jesli trzeba
				SET @Query += [THB].[PrepareStatusesPhrase] ('c', @StatusS, @StatusP, @StatusW);	
				
				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('c', @AppDate);
			 
				SET @Query += '
					 FOR XML PATH(''AttributeType''), TYPE
					)
					FROM
					(
						SELECT DISTINCT Id FROM #DoPobrania
					) dp
					FOR XML PATH(''HistoryOf''))' 
				
				--PRINT @query
				EXECUTE sp_executesql @query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT	
				
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'AttributeTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'AttributeTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="AttributeTypes_GetHistory"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlOut AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';		

	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DoPobrania') IS NOT NULL
		DROP TABLE #DoPobrania
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
