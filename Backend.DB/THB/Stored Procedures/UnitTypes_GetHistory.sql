-- =============================================
-- Author:		DK
-- Create date: 2012-04-23
-- Last modified on: 2013-02-12
-- Description:	Zwraca historie typow obiektu o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Request RequestType="UnitTypes_GetHistory" UserId="1" AppDate="2012-09-19T12:54:23">
	--	<Ref Id="1" EntityType="UnitType" />
	--	<Ref Id="2" EntityType="UnitType" />
	--	<Ref Id="3" EntityType="UnitType" />
	--	<Ref Id="4" EntityType="UnitType" />
	--	<Ref Id="5" EntityType="UnitType" />
	--	<Ref Id="6" EntityType="UnitType" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="UnitTypes_GetHistory" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="../Response_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	--	<HistoryOf Id="5" TypeId="56" EntityType="UnitType">
	--		<UnitType Id="1"  IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			<CouplerAttributeType LastModifiedOn="2012-02-09T12:12:12.121Z" Id="1" AttributeTypeId="1" Priority="1" UIOrder="20" Importance="5" ArchivedBy="1" ArchivedFrom="2012-02-09T12:12:12.121Z" CreatedBy="1" 
	--			CreatedOn="2012-02-09T12:12:12.121Z" DeletedBy="1" DeletedFrom="2012-02-09T12:12:12.121Z" IsArchive="false" IsDeleted="false" LastModifiedBy="1" />
	--		</UnitType>
	--	</HistoryOf>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitTypes_GetHistory]
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
		
		--ustawienie na sztywno pobieranie wszystkich danych i rozwijanie podwezlow
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1; 
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #DoPobrania
		SELECT	C.value('./@Id', 'int')
		FROM @xml_data.nodes('/Request/Ref') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'UnitType'

		--SELECT * FROM #DoPobrania;

		IF @RequestType = 'UnitTypes_GetHistory'
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
								, ''UnitType'' AS "@EntityType"	';
				
				IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
				BEGIN
					SET @Query += '
									, (SELECT t.[TypObiekt_ID] AS "@Id"
									, t.[Nazwa] AS "@Name"
									, t.[Tabela] AS "@IsTable"
									,t.[IsBlocked] AS "@IsBlocked"
									,ISNULL(t.[LastModifiedBy], t.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(t.[LastModifiedOn], t.[CreatedOn]) AS "@LastModifiedOn"'
					
					IF @RozwijajPodwezly = 1
					BEGIN

						SET @Query += ', (SELECT toc.[Id] AS "@Id"
							,toc.[Cecha_ID] AS "@AttributeTypeId"
							,toc.[Priority] AS "@Priority"
							,toc.[UIOrder] AS "@UIOrder"
							,toc.[Importance] AS "@Importance"
							,ISNULL(toc.[LastModifiedBy], toc.[CreatedBy]) AS "@LastModifiedBy"
							,ISNULL(toc.[LastModifiedOn], toc.[CreatedOn]) AS "@LastModifiedOn"
							FROM dbo.[TypObiektu_Cechy] toc
							WHERE toc.[TypObiektu_ID] = dp.[Id] AND toc.[ValidFrom] <= t.[ValidFrom] AND (toc.[ValidTo] IS NULL OR (toc.[ValidTo] IS NOT NULL AND toc.[ValidTo] >= t.[ValidTo])) 
							FOR XML PATH(''CouplerAttributeType''), TYPE
							)'																															
					END
				END -- pobranie wszystkich danych
				ELSE
				BEGIN
					SET @Query += '							
								, (SELECT t.[TypObiekt_ID] AS "@Id"
									,t.[Nazwa] AS "@Name"
									,t.[Tabela] AS "@IsTable"
									,t.[IsBlocked] AS "@IsBlocked"
									,t.[IsDeleted] AS "@IsDeleted"
									,t.[DeletedFrom] AS "@DeletedFrom"
									,t.[DeletedBy] AS "@DeletedBy"
									,t.[CreatedOn] AS "@CreatedOn"
									,t.[CreatedBy] AS "@CreatedBy"
									,ISNULL(t.[LastModifiedBy], t.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(t.[LastModifiedOn], t.[CreatedOn]) AS "@LastModifiedOn"
									,t.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,t.[ObowiazujeDo] AS "History/@EffectiveTo"
									,t.[IsStatus] AS "Statuses/@IsStatus"
									,t.[StatusS] AS "Statuses/@StatusS"
									,t.[StatusSFrom] AS "Statuses/@StatusSFrom"
									,t.[StatusSTo] AS "Statuses/@StatusSTo"
									,t.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									,t.[StatusSToBy] AS "Statuses/@StatusSToBy"
									,t.[StatusW] AS "Statuses/@StatusW"
									,t.[StatusWFrom] AS "Statuses/@StatusWFrom"
									,t.[StatusWTo] AS "Statuses/@StatusWTo"
									,t.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									,t.[StatusWToBy] AS "Statuses/@StatusWToBy"
									,t.[StatusP] AS "Statuses/@StatusP"
									,t.[StatusPFrom] AS "Statuses/@StatusPFrom"
									,t.[StatusPTo] AS "Statuses/@StatusPTo"
									,t.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									,t.[StatusPToBy] AS "Statuses/@StatusPToBy"'					
						
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
											,ISNULL(toc.[LastModifiedBy], toc.[CreatedBy]) AS "@LastModifiedBy"
											,ISNULL(toc.[LastModifiedOn], toc.[CreatedOn]) AS "@LastModifiedOn"
											,toc.[ObowiazujeOd] AS "History/@EffectiveFrom"
											,toc.[ObowiazujeDo] AS "History/@EffectiveTo"
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
										FROM dbo.[TypObiektu_Cechy] toc
										WHERE toc.[TypObiektu_ID] = dp.[Id] AND toc.[ValidFrom] <= t.[ValidFrom] AND (toc.[ValidTo] IS NULL OR (toc.[ValidTo] IS NOT NULL AND toc.[ValidTo] >= t.[ValidTo])) 
										FOR XML PATH(''CouplerAttributeType''), TYPE
										)
									'						
					END		
				END
					
				SET @Query += ' 
					 FROM dbo.[TypObiektu] t
					 WHERE (t.TypObiekt_ID = dp.[Id] OR t.IdArch = dp.[Id])';
					 
				--dodanie frazy statusow na filtracje jesli trzeba
				SET @Query += [THB].[PrepareStatusesPhrase] ('t', @StatusS, @StatusP, @StatusW);
				
				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('t', @AppDate);

				SET @Query += '
					 FOR XML PATH(''UnitType''), TYPE
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
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitTypes_GetHistory"';
	
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
