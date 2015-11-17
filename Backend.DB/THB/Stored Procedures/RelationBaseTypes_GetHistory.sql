-- =============================================
-- Author:		DK
-- Create date: 2012-04-24
-- Last modified on: 2013-02-14
-- Description:	Zwraca historie bazowych typow relacji o podanych ID.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="RelationBaseTypes_GetHistory" UserId="1" AppDate="2012-02-09T11:56:13">
	--	<Ref Id="1" EntityType="RelationBaseType" />
	--	<Ref Id="2" EntityType="RelationBaseType" />
	--	<Ref Id="3" EntityType="RelationBaseType" />
	--	<Ref Id="4" EntityType="RelationBaseType" />
	--	<Ref Id="5" EntityType="RelationBaseType" />
	--	<Ref Id="6" EntityType="RelationBaseType" />
	--	<Ref Id="7" EntityType="RelationBaseType" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="RelationBaseTypes_GetHistory" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="../Response_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	--	<HistoryOf Id="5" TypeId="56" EntityType="RelationBaseType">
	--		<RelationBaseType Id="1" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" Name="Relation_1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>			
	--		</RelationBaseType>
	--	</HistoryOf>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[RelationBaseTypes_GetHistory]
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
		
	IF OBJECT_ID('tempdb..#DoPobraniaBazoweTypyRelacjiZHistoria') IS NOT NULL
		DROP TABLE #DoPobraniaBazoweTypyRelacjiZHistoria
		
	CREATE TABLE #DoPobrania(Id int);
	CREATE TABLE #DoPobraniaBazoweTypyRelacjiZHistoria(Id int);
	
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
		
		--ustalenie na sztywno pobieranie wszystkich danych i rozwijanie podwezlow
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1;
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #DoPobrania
		SELECT	C.value('./@Id', 'int')
		FROM @xml_data.nodes('/Request/Ref') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'RelationBaseType'

		--SELECT * FROM #DoPobrania;

		IF @RequestType = 'RelationBaseTypes_GetHistory'
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
			
				--ustalenie bazowych typow relacji ktore istnialy faktycznie na podana date						
				INSERT INTO #DoPobraniaBazoweTypyRelacjiZHistoria
				SELECT DISTINCT Id
				FROM #DoPobrania	

				SET @Query = N' SET @xmlOutVar = (
									SELECT btr.Id AS "@Id"
									, 0 AS "@TypeId"	
									, ''RelationBaseType'' AS "@EntityType"'
					
				IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
				BEGIN
					SET @query += '
									, (SELECT rt.[Id] AS "@Id"
									,rt.[Nazwa] AS "@Name"
									,ISNULL(rt.[LastModifiedBy], rt.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(rt.[LastModifiedOn], rt.[CreatedOn]) AS "@LastModifiedOn"'
					
				END -- pobranie wszystkich danych
				ELSE
				BEGIN
					SET @Query += '						
								, (SELECT rt.[Id] AS "@Id"
									,rt.[Nazwa] AS "@Name"
									,rt.[IsDeleted] AS "@IsDeleted"
									,rt.[DeletedFrom] AS "@DeletedFrom"
									,rt.[DeletedBy] AS "@DeletedBy"
									,rt.[CreatedOn] AS "@CreatedOn"
									,rt.[CreatedBy] AS "@CreatedBy"
									,ISNULL(rt.[LastModifiedBy], rt.[CreatedBy]) AS "@LastModifiedBy"
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
									,rt.[StatusPToBy] AS "Statuses/@StatusPToBy"'						
					END
					
					SET @Query += ' 
						 FROM dbo.[Relacja_Typ] rt 
						 WHERE (rt.Id = btr.Id OR rt.IdArch = btr.Id)'
					
					SET @Query += [THB].[PrepareStatusesPhrase] ('rt', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhraseForHistory] ('rt', @AppDate);

					SET @Query += ' 	 
						 FOR XML PATH(''RelationBaseType''), TYPE
						)
					FROM #DoPobraniaBazoweTypyRelacjiZHistoria btr
					FOR XML PATH(''HistoryOf''))' 
					
					--PRINT @query
					EXECUTE sp_executesql @query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT		
					
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'RelationBaseTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'RelationBaseTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="RelationBaseTypes_GetHistory"';
	
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
		
	IF OBJECT_ID('tempdb..#DoPobraniaBazoweTypyRelacjiZHistoria') IS NOT NULL
		DROP TABLE #DoPobraniaBazoweTypyRelacjiZHistoria
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
