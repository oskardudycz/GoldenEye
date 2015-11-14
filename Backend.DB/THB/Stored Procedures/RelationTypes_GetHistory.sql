-- =============================================
-- Author:		DK
-- Create date: 2012-04-24
-- Last modified on: 2013-02-14
-- Description:	Zwraca historie typow relacji o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="RelationTypes_GetHistory" UserId="1" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="../Request_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="RelationType" />
	--	<Ref Id="2" EntityType="RelationType" />
	--	<Ref Id="3" EntityType="RelationType" />
	--	<Ref Id="4" EntityType="RelationType" />
	--	<Ref Id="5" EntityType="RelationType" />
	--	<Ref Id="6" EntityType="RelationType" />
	--	<Ref Id="7" EntityType="RelationType" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="RelationTypes_GetHistory" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="../Response_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	--	<HistoryOf Id="5" TypeId="56" EntityType="RelationType">
	--		<RelationType TypeId="1" Id="1" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" Name="Relation_1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>	
	--			<RelationBaseType  IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" Id="1" Name="RelationBase_1" />
	--			<CouplerAttributeType Id="1" Importance="3" AttributeTypeId="2" Priority="0" UIOrder="10"  IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" />
	--		</RelationType>
	--	</HistoryOf>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[RelationTypes_GetHistory]
(	
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@tableName nvarchar(256),
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
		@xmlVar nvarchar(MAX) = '',
		@ObiektId int,
		@MaUprawnienia bit = 0,
		@ERRMSG nvarchar(255),
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@IdTypuRelacji int,
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
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'RelationType'
		
		-- ustawienie na sztywno pobieranie wszystkich danych i rozwijanie podwezlow
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1;

		--SELECT * FROM #DoPobrania;

		IF @RequestType = 'RelationTypes_GetHistory'
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
				
				SET @query = N' SET @xmlOutVar = (';
				
				IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
				BEGIN
					SET @query += 'SELECT dp.[Id] AS "@Id"
								, 0 AS "@TypeId"
								, ''RelationType'' AS "@EntityType"	
									, (SELECT tr.[TypRelacji_ID] AS "@Id"
									, tr.[BazowyTypRelacji_ID] AS "@TypeId"
									, tr.[Nazwa] AS "@Name"
									,ISNULL(tr.[LastModifiedOn], tr.[CreatedOn]) AS "@LastModifiedOn"
									,ISNULL(tr.[LastModifiedBy], ISNULL(tr.[CreatedBy], '''')) AS "@LastModifiedBy"'
					
					IF @RozwijajPodwezly = 1
					BEGIN

						SET @query += ', (SELECT trc.[Id] AS "@Id"
							,trc.[Cecha_ID] AS "@AttributeTypeId"
							,trc.[Priority] AS "@Priority"
							,trc.[UIOrder] AS "@UIOrder"
							,trc.[Importance] AS "@Importance"
							,ISNULL(trc.[LastModifiedOn], trc.[CreatedOn]) AS "@LastModifiedOn"
							,ISNULL(trc.[LastModifiedBy], ISNULL(trc.[CreatedBy], '''')) AS "@LastModifiedBy"
							FROM dbo.[TypRelacji_Cechy] trc
							WHERE trc.[TypRelacji_ID] = dp.[Id] AND trc.[ValidFrom] <= tr.[ValidFrom] AND (trc.[ValidTo] IS NULL OR (trc.[ValidTo] IS NOT NULL AND trc.[ValidTo] >= tr.[ValidTo])) 
							FOR XML PATH(''CouplerAttributeType''), TYPE
							)'																															
					END
				END -- pobranie wszystkich danych
				ELSE
				BEGIN
					SET @query += 'SELECT dp.[Id] AS "@Id"
								, 0 AS "@TypeId"
								, ''RelationType'' AS "@EntityType"							
								, (SELECT tr.[TypRelacji_ID] AS "@Id"
									, tr.[BazowyTypRelacji_ID] AS "@TypeId"
									,tr.[Nazwa] AS "@Name"
									,tr.[IsDeleted] AS "@IsDeleted"
									,tr.[DeletedFrom] AS "@DeletedFrom"
									,tr.[DeletedBy] AS "@DeletedBy"
									,tr.[CreatedOn] AS "@CreatedOn"
									,tr.[CreatedBy] AS "@CreatedBy"
									,ISNULL(tr.[LastModifiedBy], tr.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(tr.[LastModifiedOn], tr.[CreatedOn]) AS "@LastModifiedOn"
									,tr.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,tr.[ObowiazujeDo] AS "History/@EffectiveTo"
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
									,tr.[StatusPToBy] AS "Statuses/@StatusPToBy"'					
						
					IF @RozwijajPodwezly = 1
					BEGIN
						
						SET @query += ', (SELECT trc.[Id] AS "@Id"
											,trc.[Cecha_ID] AS "@AttributeTypeId"
											,trc.[Priority] AS "@Priority"
											,trc.[UIOrder] AS "@UIOrder"
											,trc.[Importance] AS "@Importance"						
											,trc.[IsDeleted] AS "@IsDeleted"
											,trc.[DeletedFor] AS "@DeletedFrom"
											,trc.[DeletedBy] AS "@DeletedBy"
											,trc.[CreatedOn] AS "@CreatedOn"
											,trc.[CreatedBy] AS "@CreatedBy"
											,ISNULL(trc.[LastModifiedBy], trc.[CreatedBy]) AS "@LastModifiedBy"
											,ISNULL(trc.[LastModifiedOn], trc.[CreatedOn]) AS "@LastModifiedOn"
											,trc.[ObowiazujeOd] AS "History/@EffectiveFrom"
											,trc.[ObowiazujeDo] AS "History/@EffectiveTo"
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
											,trc.[StatusPToBy] AS "Statuses/@StatusPToBy"
										FROM dbo.[TypRelacji_Cechy] trc
										WHERE trc.[TypRelacji_ID] = dp.[Id] AND trc.[ValidFrom] <= tr.[ValidFrom] AND (trc.[ValidTo] IS NULL OR (trc.[ValidTo] IS NOT NULL AND trc.[ValidTo] >= tr.[ValidTo])) 
										FOR XML PATH(''CouplerAttributeType''), TYPE
										)
									'						
					END
				END		
					
				SET @Query += ' 
					 FROM dbo.[TypRelacji] tr
					 WHERE (tr.TypRelacji_ID = dp.[Id] OR tr.IdArch = dp.[Id])'
					 
				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('tr', @AppDate);

				--dodanie frazy statusow na filtracje jesli trzeba
				SET @Query += [THB].[PrepareStatusesPhrase] ('tr', @StatusS, @StatusP, @StatusW);
				
				SET @Query += '	 
					 FOR XML PATH(''RelationType''), TYPE
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
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'RelationTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'RelationTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="RelationTypes_GetHistory"';
	
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
