-- =============================================
-- Author:		DK
-- Create date: 2012-04-02
-- Last modified on: 2013-02-14
-- Description:	Zwraca historie jednostek miary o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="UnitsOfMeasure_GetHistory" UserId="1" AppDate="2012-09-09T11:09:12" xsi:noNamespaceSchemaLocation="10.3.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="UnitOfMeasure" />
	--	<Ref Id="2" EntityType="UnitOfMeasure" />
	--	<Ref Id="3" EntityType="UnitOfMeasure" />
	--	<Ref Id="4" EntityType="UnitOfMeasure" />
	--	<Ref Id="5" EntityType="UnitOfMeasure" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="UnitsOfMeasure_Get" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="10.3.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	--<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	 
	-- <HistoryOf Id="1" EntityType="UnitOfMeasure">
	--	<UnitOfMeasure Id="1" Name="centymetr" ShortName="cm" Comment="??" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<Conversions>
	--			<UnitsOfMeasureConversion UOMId="2" Ratio="0.01"/>
	--		</Conversions>
	--	</UnitOfMeasure>
	--	<UnitOfMeasure Id="1" Name="centymetr" ShortName="cm" Comment="??" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<Conversions>
	--			<UnitsOfMeasureConversion UOMId="2" Ratio="0.01"/>
	--		</Conversions>
	--	</UnitOfMeasure>
	--	<UnitOfMeasure Id="1" Name="centymetr" ShortName="cm" Comment="??" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<Conversions>
	--			<UnitsOfMeasureConversion UOMId="2" Ratio="0.01"/>
	--		</Conversions>
	--	</UnitOfMeasure>
	-- </HistoryOf>
	 
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitsOfMeasure_GetHistory]
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
		
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1;
		
		--wyciaganie daty i typu zadania
		SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
				,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
				,@BranzaId = C.value('./@BranchId', 'int')
				--,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
				--,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@StatusS =  C.value('./@StatusS','int') 
				,@StatusP = C.value('./@StatusP','int') 
				,@StatusW = C.value('./@StatusW','int') 
		FROM @xml_data.nodes('/Request') T(C) 
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #DoPobrania
		SELECT	C.value('./@Id', 'int')
		FROM @xml_data.nodes('/Request/Ref') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'UnitOfMeasure'

		--SELECT * FROM #DoPobrania;

		IF @RequestType = 'UnitsOfMeasure_GetHistory'
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
								, ''UnitOfMeasure'' AS "@EntityType"';
				
				IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
				BEGIN
					SET @Query += '	
									, (SELECT jm.[Id] AS "@Id"
									, jm.[Nazwa] AS "@Name"
									, jm.[NazwaSkrocona] AS "@ShortName"
									, jm.[Uwagi] AS "@Comment"
									,ISNULL(jm.[LastModifiedBy], jm.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"'
					
					IF @RozwijajPodwezly = 1
					BEGIN

						SET @query += ', (SELECT jmp.[IdTo] AS "@UOMId"
							,jmp.[Przelicznik] AS "@Ratio"
							FROM dbo.[JednostkiMiary_Przeliczniki] jmp
							WHERE jmp.[IdFrom] = dp.[Id] AND jmp.[ValidFrom] <= jm.[ValidFrom] AND (jmp.[ValidTo] IS NULL OR (jmp.[ValidTo] IS NOT NULL AND jmp.[ValidTo] >= jm.[ValidTo]))';
						
						--dodanie frazy statusow na filtracje jesli trzeba
						SET @Query += [THB].[PrepareStatusesPhrase] ('jmp', @StatusS, @StatusP, @StatusW);	
				
						SET @Query += '
										FOR XML PATH(''UnitsOfMeasureConversion''), ROOT(''Conversions''), TYPE
										)
									'																															
					END
				END -- pobranie wszystkich danych
				ELSE
				BEGIN
					SET @query += '							
								, (SELECT jm.[Id] AS "@Id"
									,jm.[Nazwa] AS "@Name"
									,jm.[NazwaSkrocona] AS "@ShortName"
									,jm.[Uwagi] AS "@Comment"
									,jm.[IsDeleted] AS "@IsDeleted"
									,jm.[DeletedFrom] AS "@DeletedFrom"
									,jm.[DeletedBy] AS "@DeletedBy"
									,jm.[CreatedOn] AS "@CreatedOn"
									,jm.[CreatedBy] AS "@CreatedBy"
									,ISNULL(jm.[LastModifiedBy], jm.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
									,jm.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,jm.[ObowiazujeDo] AS "History/@EffectiveTo"
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
									,jm.[StatusPToBy] AS "Statuses/@StatusPToBy"'					
						
					IF @RozwijajPodwezly = 1
					BEGIN
							
						SET @query += ', (SELECT jmp.[IdTo] AS "@UOMId"
											,jmp.[Przelicznik] AS "@Ratio"							
											,jmp.[IsDeleted] AS "@IsDeleted"
											,jmp.[DeletedFrom] AS "@DeletedFrom"
											,jmp.[DeletedBy] AS "@DeletedBy"
											,jmp.[CreatedOn] AS "@CreatedOn"
											,jmp.[CreatedBy] AS "@CreatedBy"
											,ISNULL(jmp.[LastModifiedBy], jmp.[CreatedBy]) AS "@LastModifiedBy"
											,ISNULL(jmp.[LastModifiedOn], jmp.[CreatedOn]) AS "@LastModifiedOn"
											,jmp.[ObowiazujeOd] AS "History/@EffectiveFrom"
											,jmp.[ObowiazujeDo] AS "History/@EffectiveTo"
											,jmp.[IsStatus] AS "Statuses/@IsStatus"
											,jmp.[StatusS] AS "Statuses/@StatusS"
											,jmp.[StatusSFrom] AS "Statuses/@StatusSFrom"
											,jmp.[StatusSTo] AS "Statuses/@StatusSTo"
											,jmp.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
											,jmp.[StatusSToBy] AS "Statuses/@StatusSToBy"
											,jmp.[StatusW] AS "Statuses/@StatusW"
											,jmp.[StatusWFrom] AS "Statuses/@StatusWFrom"
											,jmp.[StatusWTo] AS "Statuses/@StatusWTo"
											,jmp.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
											,jmp.[StatusWToBy] AS "Statuses/@StatusWToBy"
											,jmp.[StatusP] AS "Statuses/@StatusP"
											,jmp.[StatusPFrom] AS "Statuses/@StatusPFrom"
											,jmp.[StatusPTo] AS "Statuses/@StatusPTo"
											,jmp.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
											,jmp.[StatusPToBy] AS "Statuses/@StatusPToBy"
										FROM dbo.[JednostkiMiary_Przeliczniki] jmp
										WHERE jmp.[IdFrom] = dp.[Id] AND jmp.[ValidFrom] <= jm.[ValidFrom] AND (jmp.[ValidTo] IS NULL OR (jmp.[ValidTo] IS NOT NULL AND jmp.[ValidTo] >= jm.[ValidTo]))'
										
						--dodanie frazy statusow na filtracje jesli trzeba
						SET @Query += [THB].[PrepareStatusesPhrase] ('jmp', @StatusS, @StatusP, @StatusW);	
					
						SET @Query += '
										FOR XML PATH(''UnitsOfMeasureConversion''), ROOT(''Conversions''), TYPE
										)
									'						
					END		
				END
				
				SET @query += ' 
					 FROM dbo.[JednostkiMiary] jm 
					 WHERE (jm.Id = dp.[Id] OR jm.IdArch = dp.[Id])' 
						 
				--dodanie frazy statusow na filtracje jesli trzeba
				SET @Query += [THB].[PrepareStatusesPhrase] ('jm', @StatusS, @StatusP, @StatusW);	
				
				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('jm', @AppDate);
			
				SET @query += '
					 FOR XML PATH(''UnitOfMeasure''), TYPE
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
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitsOfMeasure_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitsOfMeasure_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitsOfMeasure_GetHistory"';
	
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
