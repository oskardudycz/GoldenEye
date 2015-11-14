-- =============================================
-- Author:		DK
-- Create date: 2012-04-11
-- Last modified on: 2012-09-16
-- Description:	Pobiera dane z widoku TypyObiektow_Branze.

-- przykladowy plik XML wejsciowy:
	--<?xml version="1.0"?>
	--<Request RequestType="UnitTypes_Branches_Get" UserId="1" AppDate="2012-09-09T12:23:11"/>

-- przykładowy plik XML wyjsciowy:
	--<?xml version="1.0" encoding="UTF-8"?>
	--<Response ResponseType="UnitTypes_Branches_Get">
	--	<Ref Id="1" EntityType="Branch">
	--		<Ref Id="12" EntityType="UnitType"/>
	--		<Ref Id="13" EntityType="UnitType"/>
	--	</Ref>
	--	<Ref Id="2" EntityType="Branch">
	--		<Ref Id="20" EntityType="UnitType"/>
	--		<Ref Id="30" EntityType="UnitType"/>
	--	</Ref>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitTypes_Branches_Get] 
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @DataProgramu datetime,
	@RequestType nvarchar(100),
	@UzytkownikID int,
	@BranzaID int,
	@xml_data xml,
	@xmlOk bit = 0,
	@ERRMSG nvarchar(255),
	@xmlResponse xml,
	@MaUprawnienia bit = 0,
	@StandardWhere nvarchar(MAX) = '',
	@BranzeZDostepem nvarchar(MAX) = '',
	@Query nvarchar(MAX),
	@AppDate datetime,
	@ActualDate bit,
	@StatusS int,
	@StatusW int,
	@StatusP int
		
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_StandardRequest', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

	IF @xmlOk = 0
	BEGIN
		-- co zrobic jak nie poprawna walidacja XML
		SET @ERRMSG = @ERRMSG;
	END
	ELSE
	BEGIN
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#TypyDlaBranz') IS NOT NULL
			DROP TABLE #TypyDlaBranz;
		
		CREATE TABLE #TypyDlaBranz (Branza_Id int, TypObiektu_Id int);
		
		--poprawny XML wejsciowy
		SET @xml_data = CAST(@XMLDataIn AS xml);
		
		--wyciaganie daty i typu zadania
		SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
				,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
				,@BranzaId = C.value('./@BranchId', 'int')
				,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
				,@StatusS = C.value('./@StatusS', 'int')
				,@StatusP = C.value('./@StatusP', 'int')
				,@StatusW = C.value('./@StatusW', 'int')
		FROM @xml_data.nodes('/Request') T(C) 
		
		IF @RequestType = 'UnitTypes_Branches_Get'
		BEGIN
		
			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
			SELECT @ActualDate = THB.IsActualDate(@AppDate);
			
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
				
				SET @Query = '
					INSERT INTO #TypyDlaBranz (Branza_Id, TypObiektu_Id)
					SELECT DISTINCT b.Id, t.TypObiekt_ID
					FROM dbo.Branze AS b 
					INNER JOIN dbo.Branze_Cechy AS bc ON (b.Id = bc.BranzaId)
					INNER JOIN dbo.TypObiektu_Cechy AS tc ON (tc.Cecha_ID = bc.CechaId)
					INNER JOIN dbo.TypObiektu AS t ON (t.TypObiekt_ID = tc.TypObiektu_ID)
					WHERE 1=1'
				
				--dodanie frazy statusow na filtracje jesli trzeba
				SET @Query += [THB].[PrepareStatusesPhrase] ('t', @StatusS, @StatusP, @StatusW);
				SET @Query += [THB].[PrepareStatusesPhrase] ('tc', @StatusS, @StatusP, @StatusW);
				SET @Query += [THB].[PrepareStatusesPhrase] ('bc', @StatusS, @StatusP, @StatusW);
				
				IF @AppDate IS NOT NULL
					SET @Query += ' AND (bc.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (bc.ValidTo IS NULL OR bc.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00''))
						AND (tc.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (tc.ValidTo IS NULL OR tc.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00''))
						AND (t.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (t.ValidTo IS NULL OR t.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00''))
						AND (b.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (b.ValidTo IS NULL OR b.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00''))';
			
				IF @ActualDate = 1
					SET @Query += ' AND bc.IsDeleted = 0 AND b.IsDeleted = 0 AND tc.IsDeleted = 0 AND t.IsDeleted = 0';
						
				--PRINT @Query;
				EXECUTE sp_executesql @Query;	
				
				--pobranie danych z wykorzytsaniem widoku, ktory jednak nie uwzglednia daty aplikacji i usunietych rekordow
				--SET @Query = '
				--	SET @xmlTemp = (SELECT [Branza_Id] AS "@Id"
				--					,''Branch'' AS "@EntityType"				
				--					, (SELECT tob2.[TypObiektu_Id] AS "@Id"
				--							,''UnitType'' AS "@EntityType"
				--							FROM [dbo].[TypyObiektow_Branze] tob2
				--							WHERE tob2.[Branza_Id] = tob.[Branza_Id]
				--							FOR XML PATH(''Ref''), TYPE
				--						)	
				--				FROM [dbo].[TypyObiektow_Branze] tob'
				
				--pobranie danych z wykorzystaniem daty aplikacji i usuniecia rekordow
				SET @Query = '
				SET @xmlTemp = (SELECT [Branza_Id] AS "@Id"
								,''Branch'' AS "@EntityType"				
								, (SELECT tob2.[TypObiektu_Id] AS "@Id"
										,''UnitType'' AS "@EntityType"
										FROM [dbo].[TypyObiektow_Branze] tob2
										WHERE tob2.[Branza_Id] = tob.[Branza_Id]
										FOR XML PATH(''Ref''), TYPE
									)	
							FROM #TypyDlaBranz tob';											
								
				IF @BranzeZDostepem IS NOT NULL
						SET @Query += ' WHERE tob.Branza_Id Id IN (' + @BranzeZDostepem + ' ) ';
								
				SET @Query += '	
								GROUP BY tob.[Branza_Id]
								FOR XML PATH(''Ref'')
								)';
				
				--PRINT @query;			
				EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitTypes_Branches_Get', @Wiadomosc = @ERRMSG OUTPUT
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitTypes_Branches_Get', @Wiadomosc = @ERRMSG OUTPUT
	END
	
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitTypes_Branches_Get"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>'	
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	IF OBJECT_ID('tempdb..#TypyDlaBranz') IS NOT NULL
		DROP TABLE #TypyDlaBranz;
END
