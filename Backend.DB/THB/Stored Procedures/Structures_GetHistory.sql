-- =============================================
-- Author:		DK
-- Create date: 2012-04-24
-- Last modified on: 2013-03-13
-- Description:	Zwraca historie struktur o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Structures_GetHistory" UserId="1" AppDate="2012-02-09T11:09:45" xsi:noNamespaceSchemaLocation="../Request_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="Structure" />
	--	<Ref Id="2" EntityType="Structure" />
	--	<Ref Id="3" EntityType="Structure" />
	--	<Ref Id="4" EntityType="Structure" />
	--	<Ref Id="5" EntityType="Structure" />
	--	<Ref Id="6" EntityType="Structure" />
	--	<Ref Id="7" EntityType="Structure" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Structures_GetHistory" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="../Response_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	--	<HistoryOf Id="5" TypeId="56" EntityType="Structure">
	--		<Structure Id="1" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" Name="Structure_1" ObjectId="1" ShortName="O_1" StructureTypeId="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>	
				
	--			<StructureType Id="1" RootObjectTypeId="2"  IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" Name="StructType_1" />
	--			<RelationLink StructureId="1" RelationId="1" IsMain="false" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1"/>
	--		</Structure>
	--	</HistoryOf>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Structures_GetHistory]
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
		@xmlVar nvarchar(MAX) = '',
		@ObiektId int,
		@MaUprawnienia bit = 0,
		@ERRMSG nvarchar(255),
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@IdStrukturaObiekt int,
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
				,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
				,@StatusS = C.value('./@StatusS', 'int')
				,@StatusP = C.value('./@StatusP', 'int')
				,@StatusW = C.value('./@StatusW', 'int') 
		FROM @xml_data.nodes('/Request') T(C) 
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #DoPobrania
		SELECT	C.value('./@Id', 'int')
		FROM @xml_data.nodes('/Request/Ref') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Structure'

		--SELECT * FROM #DoPobrania;
		
		--ystawione na sztywno pobieranie wszystkich danych i rozwijanie podwezlow
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1;

		IF @RequestType = 'Structures_GetHistory'
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
								, ''Structure'' AS "@EntityType"';
				
				IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
				BEGIN
					SET @Query += '
									, (SELECT so.[Id] AS "@Id"
									, so.[Nazwa] AS "@Name"
									, so.[NazwaSkrocona] AS "@ShortName"
									, so.[Obiekt_Id] AS "@ObjectId"
									, so.[TypStruktury_Obiekt_Id] AS "@StructureTypeId"
									,ISNULL(so.[LastModifiedBy], so.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(so.[LastModifiedOn], so.[CreatedOn]) AS "@LastModifiedOn"'
					
					IF @RozwijajPodwezly = 1
					BEGIN

						SET @Query += ', (SELECT tso.[Id] AS "@Id"
							,tso.[Nazwa] AS "@Name"
							,tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
							,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"
							,ISNULL(tso.[LastModifiedBy], tso.[CreatedBy]) AS "@LastModifiedBy"
							FROM dbo.[TypStruktury_Obiekt] tso
							WHERE (tso.[Id] = so.[TypStruktury_Obiekt_Id] OR so.[TypStruktury_Obiekt_Id] = tso.[IdArch]) AND tso.[ValidFrom] <= so.[ValidFrom] AND (tso.[ValidTo] IS NULL OR (tso.[ValidTo] IS NOT NULL AND tso.[ValidTo] >= so.[ValidTo])) 
							FOR XML PATH(''StructureType''), TYPE
							)
							
							, (SELECT s.[StrukturaObiektId] AS "@StructureId"
							,s.[RelacjaId] AS "@RelationId"
							,s.[IsMain] AS "@IsMain"
							,s.[StrukturaLinkId] AS "@StructureLinkId"
							,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
							,ISNULL(s.[LastModifiedBy], s.[CreatedBy]) AS "@LastModifiedBy"
							FROM dbo.[Struktura] s
							WHERE s.[StrukturaObiektId] = so.[Id] AND s.[ValidFrom] <= so.[ValidFrom] AND (s.[ValidTo] IS NULL OR (s.[ValidTo] IS NOT NULL AND s.[ValidTo] >= so.[ValidTo]))'
							
						SET @Query += [THB].[PrepareStatusesPhrase] ('s', @StatusS, @StatusP, @StatusW); 
						
						SET @Query += '
							FOR XML PATH(''RelationLink''), TYPE
							)'																															
					END
				END -- pobranie wszystkich danych
				ELSE
				BEGIN
					SET @Query += '							
								, (SELECT so.[Id] AS "@Id"
									,so.[Nazwa] AS "@Name"
									,so.[NazwaSkrocona] AS "@ShortName"
									,so.[Obiekt_Id] AS "@ObjectId"
									,so.[TypStruktury_Obiekt_Id] AS "@StructureTypeId"
									,so.[IsDeleted] AS "@IsDeleted"
									,so.[DeletedFrom] AS "@DeletedFrom"
									,so.[DeletedBy] AS "@DeletedBy"
									,so.[CreatedOn] AS "@CreatedOn"
									,so.[CreatedBy] AS "@CreatedBy"
									,ISNULL(so.[LastModifiedBy], so.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(so.[LastModifiedOn], so.[CreatedOn]) AS "@LastModifiedOn"
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
									,so.[StatusPToBy] AS "Statuses/@StatusPToBy"'					
						
					IF @RozwijajPodwezly = 1
					BEGIN
						
						 SET @Query += '
									, (SELECT tso.[Id] AS "@Id"
											,tso.[Nazwa] AS "@Name"
											,tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"						
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
											,tso.[StatusPToBy] AS "Statuses/@StatusPToBy"
										FROM dbo.[TypStruktury_Obiekt] tso
										WHERE (tso.[Id] = so.[TypStruktury_Obiekt_Id] OR so.[TypStruktury_Obiekt_Id] = tso.[IdArch]) AND tso.[ValidFrom] <= so.[ValidFrom] AND (tso.[ValidTo] IS NULL OR (tso.[ValidTo] IS NOT NULL AND tso.[ValidTo] >= so.[ValidTo])) 
										FOR XML PATH(''StructureType''), TYPE
										)'
																				
						SET @Query += '
									, (SELECT s.[StrukturaObiektId] AS "@StructureId"
											,s.[RelacjaId] AS "@RelationId"
											,s.[IsMain] AS "@IsMain"
											,s.[StrukturaLinkId] AS "@StructureLinkId"						
											,s.[IsDeleted] AS "@IsDeleted"
											,s.[DeletedFrom] AS "@DeletedFrom"
											,s.[DeletedBy] AS "@DeletedBy"
											,s.[CreatedOn] AS "@CreatedOn"
											,s.[CreatedBy] AS "@CreatedBy"
											,ISNULL(s.[LastModifiedBy], s.[CreatedBy]) AS "@LastModifiedBy"
											,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
											,s.[ObowiazujeOd] AS "History/@EffectiveFrom"
											,s.[ObowiazujeDo] AS "History/@EffectiveTo"
											,s.[IsStatus] AS "Statuses/@IsStatus"
											,s.[StatusS] AS "Statuses/@StatusS"
											,s.[StatusSFrom] AS "Statuses/@StatusSFrom"
											,s.[StatusSTo] AS "Statuses/@StatusSTo"
											,s.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
											,s.[StatusSToBy] AS "Statuses/@StatusSToBy"
											,s.[StatusW] AS "Statuses/@StatusW"
											,s.[StatusWFrom] AS "Statuses/@StatusWFrom"
											,s.[StatusWTo] AS "Statuses/@StatusWTo"
											,s.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
											,s.[StatusWToBy] AS "Statuses/@StatusWToBy"
											,s.[StatusP] AS "Statuses/@StatusP"
											,s.[StatusPFrom] AS "Statuses/@StatusPFrom"
											,s.[StatusPTo] AS "Statuses/@StatusPTo"
											,s.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
											,s.[StatusPToBy] AS "Statuses/@StatusPToBy"
										FROM dbo.[Struktura] s
										WHERE s.[StrukturaObiektId] = so.[Id] AND s.[ValidFrom] <= so.[ValidFrom] AND (s.[ValidTo] IS NULL OR (s.[ValidTo] IS NOT NULL AND s.[ValidTo] >= so.[ValidTo]))'
										
						SET @Query += [THB].[PrepareStatusesPhrase] ('s', @StatusS, @StatusP, @StatusW);				
										 
						SET @Query += '
										FOR XML PATH(''RelationLink''), TYPE
										)
									'					
					END		
				END
					
				SET @Query += ' 
					 FROM dbo.[Struktura_Obiekt] so
					 WHERE (so.Id = dp.[Id] OR so.IdArch = dp.[Id])';
					 
				--dodanie frazy statusow na filtracje jesli trzeba
				SET @Query += [THB].[PrepareStatusesPhrase] ('so', @StatusS, @StatusP, @StatusW);

				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('so', @AppDate);

				SET @Query += '
					 FOR XML PATH(''Structure''), TYPE
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
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Structures_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Structures_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Structures_GetHistory"';
	
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
