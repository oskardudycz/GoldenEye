-- =============================================
-- Author:		DK
-- Create date: 2012-04-24
-- Last modified on: 2013-02-14
-- Description:	Zwraca historie typow cech o podanych ID.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="DataTypes_GetHistory" UserId="1" AppDate="2012-02-09T22:11:23" xsi:noNamespaceSchemaLocation="../Request_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="DataType" />
	--	<Ref Id="2" EntityType="DataType" />
	--	<Ref Id="3" EntityType="DataType" />
	--	<Ref Id="4" EntityType="DataType" />
	--	<Ref Id="5" EntityType="DataType" />
	--	<Ref Id="6" EntityType="DataType" />
	--	<Ref Id="7" EntityType="DataType" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="DataTypes_GetHistory" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="../Response_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	--	<HistoryOf Id="5" TypeId="56" EntityType="DataType">
	--		<DataType Id="1"  IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" Name="Structure_1" IsUserAttribute="false" SQLName="1"  UIName="1">		
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		</DataType>
	--	</HistoryOf>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[DataTypes_GetHistory]
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
		@StatusS varchar(20),
		@StatusP varchar(20),
		@StatusW varchar(20),
		@DataProgramu datetime,
		@UzytkownikID int = NULL,
		@BranzaID int,
		@xmlVar nvarchar(MAX) = '',
		@MaUprawnienia bit = 0,
		@ERRMSG nvarchar(255),
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@IdTypuCechy int,
		@AppDate datetime
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DoPobrania') IS NOT NULL
		DROP TABLE #DoPobrania
		
	IF OBJECT_ID('tempdb..#DoPobraniaTypyCech') IS NOT NULL
		DROP TABLE #DoPobraniaTypyCech
		
	CREATE TABLE #DoPobrania(Id int);
	CREATE TABLE #DoPobraniaTypyCech(Id int);
	
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
				,@StatusS =  C.value('./@StatusS','varchar(20)') 
				,@StatusP = C.value('./@StatusP','varchar(20)') 
				,@StatusW = C.value('./@StatusW','varchar(20)') 
		FROM @xml_data.nodes('/Request') T(C) 
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #DoPobrania
		SELECT	C.value('./@Id', 'int')
		FROM @xml_data.nodes('/Request/Ref') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'DataType'

--SELECT * FROM #DoPobrania;
		
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1;

		IF @RequestType = 'DataTypes_GetHistory'
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
				
				--ustalenie branz ktore istnialy faktycznie na podana date						
				INSERT INTO #DoPobraniaTypyCech
				SELECT DISTINCT Id
				FROM #DoPobrania;				
				
				SET @Query = N' SET @xmlOutVar = (
							SELECT dp.Id AS "@Id"
								, 0 AS "@TypeId"	
								, ''DataType'' AS "@EntityType"';
				
				IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
				BEGIN
					SET @query += '
								, (SELECT ct.[Id] AS "@Id"
								, ct.[Nazwa] AS "@Name"
								, ct.[NazwaSQL] AS "@SQLName"
								, ct.[Nazwa_UI] AS "@UIName"
								, ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
								,ISNULL(ct.[LastModifiedBy], ct.[CreatedBy]) AS "@LastModifiedBy"
								,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"'
					
				END -- pobranie wszystkich danych
				ELSE
				BEGIN
					SET @query += '						
								, (SELECT ct.[Id] AS "@Id"
									, ct.[Nazwa] AS "@Name"
									, ct.[NazwaSQL] AS "@SQLName"
									, ct.[Nazwa_UI] AS "@UIName"
									, ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
									,ct.[IsDeleted] AS "@IsDeleted"
									,ct.[DeletedFrom] AS "@DeletedFrom"
									,ct.[DeletedBy] AS "@DeletedBy"
									,ct.[CreatedOn] AS "@CreatedOn"
									,ct.[CreatedBy] AS "@CreatedBy"
									,ISNULL(ct.[LastModifiedBy], ct.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
									,ct.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,ct.[ObowiazujeDo] AS "History/@EffectiveTo"
									,ct.[IsStatus] AS "Statuses/@IsStatus"
									,ct.[StatusS] AS "Statuses/@StatusS"
									,ct.[StatusSFrom] AS "Statuses/@StatusSFrom"
									,ct.[StatusSTo] AS "Statuses/@StatusSTo"
									,ct.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									,ct.[StatusSToBy] AS "Statuses/@StatusSToBy"
									,ct.[StatusW] AS "Statuses/@StatusW"
									,ct.[StatusWFrom] AS "Statuses/@StatusWFrom"
									,ct.[StatusWTo] AS "Statuses/@StatusWTo"
									,ct.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									,ct.[StatusWToBy] AS "Statuses/@StatusWToBy"
									,ct.[StatusP] AS "Statuses/@StatusP"
									,ct.[StatusPFrom] AS "Statuses/@StatusPFrom"
									,ct.[StatusPTo] AS "Statuses/@StatusPTo"
									,ct.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									,ct.[StatusPToBy] AS "Statuses/@StatusPToBy"'						
					END
					
					SET @Query += ' 
						 FROM dbo.[Cecha_Typy] ct
						 WHERE (dp.Id = ct.Id OR dp.Id = ct.IdArch)' 

					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('ct', @StatusS, @StatusP, @StatusW);
						
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhraseForHistory] ('ct', @AppDate); 

 
					SET @Query += ' 
						 FOR XML PATH(''DataType''), TYPE
						)
						FROM #DoPobraniaTypyCech dp
						FOR XML PATH(''HistoryOf''))' 
					
					--PRINT @query
					EXECUTE sp_executesql @query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT
					
					SET @xmlVar += ISNULL(CAST(@xmlOut AS nvarchar(MAX)), '');			
					
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'DataTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'DataTypes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="DataTypes_GetHistory"';
	
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
		
	IF OBJECT_ID('tempdb..#DoPobraniaTypyCech') IS NOT NULL
		DROP TABLE #DoPobraniaTypyCech
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
