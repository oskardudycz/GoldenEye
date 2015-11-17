-- =============================================
-- Author:		DK
-- Create date: 2012-04-23
-- Last modified on: 2013-02-14
-- Description:	Zwraca historie branz o podanych ID.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Branches_GetHistory" UserId="1" AppDate="2012-02-09T12:32:11">
	--	<Ref Id="1" EntityType="Branch" />
	--	<Ref Id="2" EntityType="Branch" />
	--	<Ref Id="3" EntityType="Branch" />
	--	<Ref Id="4" EntityType="Branch" />
	--	<Ref Id="5" EntityType="Branch" />
	--	<Ref Id="6" EntityType="Branch" />
	--	<Ref Id="7" EntityType="Branch" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Relations_GetHistory" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="../Response_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	--	<HistoryOf Id="5" TypeId="56" EntityType="Branch">
	--		<Branch Id="1" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>			
	--		</Branch>
	--	</HistoryOf>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Branches_GetHistory]
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
		@AppDate datetime,
		@BranzeZDostepem nvarchar(MAX) = ''
	
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
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Branch'

		--SELECT * FROM #DoPobrania;

		IF @RequestType = 'Branches_GetHistory'
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
			
				--pobranie Id branz do ktorych uzytkownik ma uprawnienia
				SET @BranzeZDostepem = THB.GetUserBranchesIds(@UzytkownikId, @AppDate);
				
				SET @Query = N' SET @xmlOutVar = (
							SELECT dp.Id AS "@Id"
									, ''Branch'' AS "@EntityType"
									, 0 AS "@TypeId"';
					
				IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
				BEGIN
					SET @Query += '
								, (SELECT b.[Id] AS "@Id"
									, b.[Nazwa] AS "@Name"
									,ISNULL(b.[LastModifiedBy], b.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(b.[LastModifiedOn], b.[CreatedOn]) AS "@LastModifiedOn"'
				END 
				ELSE -- pobranie wszystkich danych
				BEGIN
					SET @Query += '							
								, (SELECT b.[Id] AS "@Id"
									,b.[Nazwa] AS "@Name"
									,b.[IsDeleted] AS "@IsDeleted"
									,b.[DeletedFrom] AS "@DeletedFrom"
									,b.[DeletedBy] AS "@DeletedBy"
									,b.[CreatedOn] AS "@CreatedOn"
									,b.[CreatedBy] AS "@CreatedBy"
									,ISNULL(b.[LastModifiedBy], b.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(b.[LastModifiedOn], b.[CreatedOn]) AS "@LastModifiedOn"
									,b.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,b.[ObowiazujeDo] AS "History/@EffectiveTo"
									,b.[IsStatus] AS "Statuses/@IsStatus"
									,b.[StatusS] AS "Statuses/@StatusS"
									,b.[StatusSFrom] AS "Statuses/@StatusSFrom"
									,b.[StatusSTo] AS "Statuses/@StatusSTo"
									,b.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									,b.[StatusSToBy] AS "Statuses/@StatusSToBy"
									,b.[StatusW] AS "Statuses/@StatusW"
									,b.[StatusWFrom] AS "Statuses/@StatusWFrom"
									,b.[StatusWTo] AS "Statuses/@StatusWTo"
									,b.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									,b.[StatusWToBy] AS "Statuses/@StatusWToBy"
									,b.[StatusP] AS "Statuses/@StatusP"
									,b.[StatusPFrom] AS "Statuses/@StatusPFrom"
									,b.[StatusPTo] AS "Statuses/@StatusPTo"
									,b.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									,b.[StatusPToBy] AS "Statuses/@StatusPToBy"'						
				END
				
				SET @Query += ' 
							FROM dbo.[Branze] b
							WHERE (dp.Id = b.Id OR dp.Id = b.IdArch)'
						 
				--dodanie frazy statusow na filtracje jesli trzeba
				SET @Query += [THB].[PrepareStatusesPhrase] ('b', @StatusS, @StatusP, @StatusW);
					
				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('b', @AppDate);
				
				IF @BranzeZDostepem IS NOT NULL
					SET @Query = ' AND b.Id IN (' + @BranzeZDostepem + ' ) '; 		 
				
				SET @Query += '
							FOR XML PATH(''Branch''), TYPE
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
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Branches_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Branches_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Branches_GetHistory"';
	
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
