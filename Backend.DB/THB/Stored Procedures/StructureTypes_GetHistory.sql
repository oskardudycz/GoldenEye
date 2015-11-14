-- =============================================
-- Author:		DK
-- Create date: 2012-04-23
-- Last modified on: 2013-02-14
-- Description:	Zwraca historie typow struktury dla podanych ID.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="StructureTypes_GetHistory" UserId="1" AppDate="2012-09-09T12:45:22">
	--	<Ref Id="1" EntityType="StructureType" />
	--	<Ref Id="2" EntityType="StructureType" />
	--	<Ref Id="3" EntityType="StructureType" />
	--	<Ref Id="4" EntityType="StructureType" />
	--	<Ref Id="5" EntityType="StructureType" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="StructureTypes_GetHistory" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="../Response_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	--	<HistoryOf Id="5" TypeId="56" EntityType="StructureType">
	--		<StructureType RootObjectTypeId="2" Id="1"  IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" Name="Structure_1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			<CouplerStructureType LastModifiedOn="2012-02-09T12:12:12.121Z" Id="1" ArchivedBy="1" ArchivedFrom="2012-02-09T12:12:12.121Z" CreatedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" 				DeletedBy="1" DeletedFrom="2012-02-09T12:12:12.121Z" IsArchive="false" IsDeleted="false" LastModifiedBy="1"  IsTree="false" LObjectTypeId="1" RelationTypeId="3" RObjectTypeId="3" Name="CST_1"/>
	--		</StructureType>
	--	</HistoryOf>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[StructureTypes_GetHistory]
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
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DataProgramu datetime,
		@UzytkownikID int = NULL,
		@BranzaID int,
		@MaUprawnienia bit = 0,
		@ERRMSG nvarchar(255),
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@AppDate datetime
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#TypyStrukturDoPobrania') IS NOT NULL
		DROP TABLE #TypyStrukturDoPobrania
		
	CREATE TABLE #TypyStrukturDoPobrania(Id int);
	
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
		
		--ustawienie na sztywno pobierania wszystkich danych i rozwijanie podwezlow
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1; 
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #TypyStrukturDoPobrania
		SELECT	C.value('./@Id', 'int')
		FROM @xml_data.nodes('/Request/Ref') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'StructureType'

		--SELECT * FROM #TypyStrukturDoPobrania;

		IF @RequestType = 'StructureTypes_GetHistory'
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
								, ''UnitType'' AS "@EntityType"';
				
				IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
				BEGIN
					SET @Query += '	
									, (SELECT tso.[Id] AS "@Id"
									, tso.[Nazwa] AS "@Name"
									, tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
									,tso.[StructureKind] AS "@StructureKind"
									,ISNULL(tso.[LastModifiedBy], tso.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"'
					
					IF @RozwijajPodwezly = 1
					BEGIN

						SET @Query += ', (SELECT ts.[Id] AS "@Id"
							,ts.[IsStructure] AS "@IsTree"
							,ts.[TypObiektuId_L] AS "@LObjectTypeId"
							,ts.[TypObiektuId_R] AS "@RObjectTypeId"
							,ts.[TypRelacjiId] AS "@RelationTypeId"
							,ISNULL(ts.[LastModifiedBy], ts.[CreatedBy]) AS "@LastModifiedBy"
							,ISNULL(ts.[LastModifiedOn], ts.[CreatedOn]) AS "@LastModifiedOn"
							FROM dbo.[TypStruktury] ts
							WHERE ts.[TypStruktury_Obiekt_Id] = dp.[Id] AND ts.[ValidFrom] <= tso.[ValidFrom] AND (ts.[ValidTo] IS NULL OR (ts.[ValidTo] IS NOT NULL AND ts.[ValidTo] >= tso.[ValidTo]))'
							
						SET @Query += [THB].[PrepareStatusesPhrase] ('ts', @StatusS, @StatusP, @StatusW);
						
						SET @Query += '	
							FOR XML PATH(''CouplerStructureType''), TYPE
							)'																															
					END
				END -- pobranie wszystkich danych
				ELSE
				BEGIN
					SET @Query += '							
								, (SELECT tso.[Id] AS "@Id"
									, tso.[Nazwa] AS "@Name"
									, tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
									,tso.[StructureKind] AS "@StructureKind"
									,tso.[IsDeleted] AS "@IsDeleted"
									,tso.[DeletedFrom] AS "@DeletedFrom"
									,tso.[DeletedBy] AS "@DeletedBy"
									,tso.[CreatedOn] AS "@CreatedOn"
									,tso.[CreatedBy] AS "@CreatedBy"
									,ISNULL(tso.[LastModifiedBy], tso.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"
									,tso.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,tso.[ObowiazujeDo] AS "History/@EffectiveTo"
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
									,tso.[StatusPToBy] AS "Statuses/@StatusPToBy"'					
						
					IF @RozwijajPodwezly = 1
					BEGIN
						
						SET @Query += ', (SELECT ts.[Id] AS "@Id"
											,ts.[IsStructure] AS "@IsTree"
											,ts.[TypObiektuId_L] AS "@LObjectTypeId"
											,ts.[TypObiektuId_R] AS "@RObjectTypeId"
											,ts.[TypRelacjiId] AS "@RelationTypeId"						
											,ts.[IsDeleted] AS "@IsDeleted"
											,ts.[DeletedFrom] AS "@DeletedFrom"
											,ts.[DeletedBy] AS "@DeletedBy"
											,ts.[CreatedOn] AS "@CreatedOn"
											,ts.[CreatedBy] AS "@CreatedBy"
											,ISNULL(ts.[LastModifiedBy], ts.[CreatedBy]) AS "@LastModifiedBy"
											,ISNULL(ts.[LastModifiedOn], ts.[CreatedOn]) AS "@LastModifiedOn"
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
										FROM dbo.[TypStruktury] ts
										WHERE ts.[TypStruktury_Obiekt_Id] = dp.[Id] AND ts.[ValidFrom] <= tso.[ValidFrom] AND (ts.[ValidTo] IS NULL OR (ts.[ValidTo] IS NOT NULL AND ts.[ValidTo] >= tso.[ValidTo]))'
						
						SET @Query += [THB].[PrepareStatusesPhrase] ('ts', @StatusS, @StatusP, @StatusW);
						
						SET @Query += '	
							FOR XML PATH(''CouplerStructureType''), TYPE
							)'									
					END		
				END
				
				SET @Query += ' 
					 FROM dbo.[TypStruktury_Obiekt] tso
					 WHERE (tso.[Id] = dp.[Id] OR tso.IdArch = dp.[Id])';
				
				--dodanie frazy statusow na filtracje jesli trzeba
				SET @Query += [THB].[PrepareStatusesPhrase] ('tso', @StatusS, @StatusP, @StatusW);
				
				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('tso', @AppDate);
					 

				SET @Query += '
					 FOR XML PATH(''StructureType''), TYPE
					)
					FROM
					(
						SELECT DISTINCT Id FROM #TypyStrukturDoPobrania
					) dp
					FOR XML PATH(''HistoryOf''))' 
					
				--PRINT @query
				EXECUTE sp_executesql @query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT	
					
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'StructureTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'StructureTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="StructureTypes_GetHistory"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlOut AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';		

		--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#TypyStrukturDoPobrania') IS NOT NULL
		DROP TABLE #TypyStrukturDoPobrania
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
