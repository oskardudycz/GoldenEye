-- =============================================
-- Author:		DK
-- Create date: 2012-04-24
-- Last modified on: 2013-02-14
-- Description:	Zwraca historie slownikow o podanych ID.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Dictionary_GetHistory" UserId="1" AppDate="2012-02-09T12:45:33" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="Dictionary" />
	--	<Ref Id="2" EntityType="Dictionary" />
	--	<Ref Id="3" EntityType="Dictionary" />
	--	<Ref Id="4" EntityType="Dictionary" />
	--	<Ref Id="5" EntityType="Dictionary" />
	--	<Ref Id="6" EntityType="Dictionary" />
	--	<Ref Id="7" EntityType="Dictionary" />
	--</Request>

-- XML wyjsciowy:

	--<Response ResponseType="Dictionary_GetHistory" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="../Response_GetHistory.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	--	<HistoryOf Id="5" TypeId="56" EntityType="Dictionary">
	--		<Dictionary Id="1"  IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" Name="Structure_1" >		
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			<Entries TypeId="1" />
	--		</Dictionary>
	--	</HistoryOf>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Dictionary_GetHistory]
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
		@DataProgramu datetime,
		@UzytkownikID int = NULL,
		@BranzaID int,
		@xmlVar nvarchar(MAX) = '',
		@MaUprawnienia bit = 0,
		@ERRMSG nvarchar(255),
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@IdSlownika int,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@AppDate datetime
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DoPobrania') IS NOT NULL
		DROP TABLE #DoPobrania
		
	IF OBJECT_ID('tempdb..#Slowniki') IS NOT NULL
		DROP TABLE #Slowniki
		
	CREATE TABLE #Slowniki(MainId int, TypObiektuId int, Id int, Wersja int, Nazwa nvarchar(256), IsStatus bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,[StatusSFromBy] int,
		[StatusSToBy] int, [StatusW] int, [StatusWFrom] datetime, [StatusWTo] datetime, [StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,[StatusPTo] datetime,
		[StatusPFromBy] int,[StatusPToBy] int,[ZmianaOd] datetime,[ZmianaDo] datetime,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,[ValidFrom] datetime,[ValidTo] datetime,
		[IsArchive] bit,[ArchivedFrom] datetime,[ArchivedBy] int,[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,[CreatedBy] int,[LastModifiedOn] datetime,
		[LastModifiedBy] int,[IsAlternativeHistory] bit,[IsMainHistFlow] bit);
		
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
		
		--ustawienie na sztywno pobieranie wszystkich danych i pobieranie podwezlow
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1;
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #DoPobrania
		SELECT	C.value('./@Id', 'int')
		FROM @xml_data.nodes('/Request/Ref') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(30)') = 'Dictionary'

		IF @RequestType = 'Dictionary_GetHistory'
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
				
				--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
				IF Cursor_Status('local','cur') > 0 
				BEGIN
					 CLOSE cur
					 DEALLOCATE cur
				END
				
				DECLARE cur CURSOR LOCAL FOR 
					SELECT DISTINCT Id FROM #DoPobrania
				OPEN cur
				FETCH NEXT FROM cur INTO @IdSlownika
				WHILE @@FETCH_STATUS = 0
				BEGIN
					--pobranie nazwy typu obiektu po Id typu
					SELECT @tableName = s.[Nazwa]
					FROM dbo.[Slowniki] s 
					WHERE s.[Id] = @IdSlownika					
					
					SET @Query = N' SET @xmlOutVar = (';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @Query += 'SELECT ' + CAST(@IdSlownika AS varchar) + ' AS "@Id"
									, 0 AS "@TypeId"
									, ''Dictionary'' AS "@EntityType"	
										, (SELECT s.[Id] AS "@Id"
										,s.[Nazwa] AS "@Name"
										,s.[TypId] AS "@DataTypeId"
										,ISNULL(s.[LastModifiedBy], s.[CreatedBy]) AS "@LastModifiedBy"
										,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"'
						
						IF @RozwijajPodwezly = 1
						BEGIN
							
							SET @Query += '			
											, (SELECT ISNULL(ct.[IdArch], ct.[Id]) AS "@Id"
												,ct.[Nazwa] AS "@Name"
												,ct.[NazwaSQL] AS "@SQLName"
												,ct.[Nazwa_UI] AS "@UIName"
												,CASE ct.[CzyCechaUzytkownika] WHEN 1 THEN ''true'' ELSE ''false'' END AS "@IsUserAttribute"
												,ISNULL(ct.[LastModifiedBy], ct.[CreatedBy]) AS "@LastModifiedBy"
												,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
												FROM dbo.Cecha_Typy ct
												WHERE ISNULL(ct.[IdArch], ct.[Id]) = s.[TypId] AND ct.[ValidFrom] <= s.[ValidFrom] AND (ct.[ValidTo] IS NULL OR (ct.[ValidTo] IS NOT NULL AND ct.[ValidTo] >= s.[ValidTo]))
												FOR XML PATH (''DataType''), TYPE)'	
							
							IF OBJECT_ID (N'_Slownik_' + @tableName, N'U') IS NOT NULL
							BEGIN
								-- pobranie wpisow slownika o ile tabela slownika istnieje			
								SET @Query += '
												--, (SELECT TOP 1 sr.[TypId] AS "@TypeId"
													, (SELECT sr.[Id] AS "@Id"
														,sr.[Nazwa] AS "@Name"
														,sr.[NazwaSkrocona] AS "@ShortName"
														,sr.[NazwaPelna] AS "@FullName"
														,sr.[Uwagi] AS "@Comment"
														,ISNULL(sr.[LastModifiedBy], sr.[CreatedBy]) AS "@LastModifiedBy"
														,ISNULL(sr.[LastModifiedOn], sr.[CreatedOn]) AS "@LastModifiedOn"
														FROM [_Slownik_' + @tableName + '] sr
														WHERE sr.[ValidFrom] <= s.[ValidFrom] AND (sr.[ValidTo] IS NULL OR (sr.[ValidTo] IS NOT NULL AND sr.[ValidTo] >= s.[ValidTo]))'
														
								--dodanie frazy statusow na filtracje jesli trzeba
								SET @Query += [THB].[PrepareStatusesPhrase] ('sr', @StatusS, @StatusP, @StatusW);	
						
								SET @Query += '
														FOR XML PATH(''DictionaryEntry''), ROOT(''Entries''), TYPE
														)
													--FROM [Slowniki] s2 WHERE Id = ' + CAST(@IdSlownika AS varchar) + '
													--FOR XML PATH(''Entries''), TYPE)'
													
													--FROM [_Slownik_' + @tableName + '] sr
													--FOR XML PATH(''Entries''), TYPE)
							END
						END
					END
					ELSE --pobranie wszystkich danych slownikow
					BEGIN
						SET @Query += 'SELECT ' + CAST(@IdSlownika AS varchar) + ' AS "@Id"
									, 0 AS "@TypeId"
									, ''Dictionary'' AS "@EntityType"							
									, (SELECT s.[Id] AS "@Id"
										,s.[Nazwa] AS "@Name"
										,s.[TypId] AS "@DataTypeId"
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
										,s.[StatusPToBy] AS "Statuses/@StatusPToBy"'
										
						IF @RozwijajPodwezly = 1
						BEGIN
						
							SET @Query += '			
										, (SELECT ISNULL(ct.[IdArch], ct.[Id]) AS "@Id"
											  ,ct.[Nazwa] AS "@Name"
											  ,ct.[NazwaSQL] AS "@SQLName"
											  ,ct.[Nazwa_UI] AS "@UIName"
											  ,CASE ct.[CzyCechaUzytkownika] WHEN 1 THEN ''true'' ELSE ''false'' END AS "@IsUserAttribute"
											  ,ct.[IsDeleted] AS "@IsDeleted"
											  ,ct.[DeletedFrom] AS "@DeletedFrom"
											  ,ct.[DeletedBy] AS "@DeletedBy"
											  ,ct.[CreatedOn] AS "@CreatedOn"
											  ,ct.[CreatedBy] AS "@CreatedBy"
											  ,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
											  ,ISNULL(ct.[LastModifiedBy], ct.[CreatedBy]) AS "@LastModifiedBy"
											  ,ct.[ObowiazujeOd] AS "History/@EffectiveFrom"
											  ,ct.[ObowiazujeDo] AS "History/@EffectiveTo"
											  ,ct.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
											  ,ct.[IsMainHistFlow] AS "History/@IsMainHistFlow"
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
											  ,ct.[StatusPToBy] AS "Statuses/@StatusPToBy"
											FROM dbo.Cecha_Typy ct
											WHERE ISNULL(ct.[IdArch], ct.[Id]) = s.[TypId] AND ct.[ValidFrom] <= s.[ValidFrom] AND (ct.[ValidTo] IS NULL OR (ct.[ValidTo] IS NOT NULL AND ct.[ValidTo] >= s.[ValidTo]))
											FOR XML PATH (''DataType''), TYPE)'
						
							IF OBJECT_ID (N'_Slownik_' + @tableName, N'U') IS NOT NULL
							BEGIN
								-- pobranie wpisow slownika
								SET @Query += '
												--, (SELECT TOP 1 s2.[TypId] AS "@TypeId"
													, (SELECT sr.[Id] AS "@Id"
														,sr.[Nazwa] AS "@Name"
														,sr.[NazwaSkrocona] AS "@ShortName"
														,sr.[NazwaPelna] AS "@FullName"
														,sr.[Uwagi] AS "@Comment"
														,sr.[IsDeleted] AS "@IsDeleted"
														,sr.[DeletedFrom] AS "@DeletedFrom"
														,sr.[DeletedBy] AS "@DeletedBy"
														,sr.[CreatedOn] AS "@CreatedOn"
														,sr.[CreatedBy] AS "@CreatedBy"
														,ISNULL(sr.[LastModifiedOn], sr.[CreatedOn]) AS "@LastModifiedOn"
														,ISNULL(sr.[LastModifiedBy], sr.[CreatedBy]) AS "@LastModifiedBy"
														,sr.[ObowiazujeOd] AS "History/@EffectiveFrom"
														,sr.[ObowiazujeDo] AS "History/@EffectiveTo"
														,sr.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
														,sr.[IsMainHistFlow] AS "History/@IsMainHistFlow"
														,sr.[IsStatus] AS "Statuses/@IsStatus"
														,sr.[StatusS] AS "Statuses/@StatusS"
														,sr.[StatusSFrom] AS "Statuses/@StatusSFrom"
														,sr.[StatusSTo] AS "Statuses/@StatusSTo"
														,sr.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
														,sr.[StatusSToBy] AS "Statuses/@StatusSToBy"
														,sr.[StatusW] AS "Statuses/@StatusW"
														,sr.[StatusWFrom] AS "Statuses/@StatusWFrom"
														,sr.[StatusWTo] AS "Statuses/@StatusWTo"
														,sr.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
														,sr.[StatusWToBy] AS "Statuses/@StatusWToBy"
														,sr.[StatusP] AS "Statuses/@StatusP"
														,sr.[StatusPFrom] AS "Statuses/@StatusPFrom"
														,sr.[StatusPTo] AS "Statuses/@StatusPTo"
														,sr.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
														,sr.[StatusPToBy] AS "Statuses/@StatusPToBy"
														FROM [_Slownik_' + @tableName + '] sr
														WHERE sr.[ValidFrom] <= s.[ValidFrom] AND (sr.[ValidTo] IS NULL OR (sr.[ValidTo] IS NOT NULL AND sr.[ValidTo] >= s.[ValidTo]))'
														
								--dodanie frazy statusow na filtracje jesli trzeba
								SET @Query += [THB].[PrepareStatusesPhrase] ('sr', @StatusS, @StatusP, @StatusW);	
						
								SET @Query += '
														FOR XML PATH(''DictionaryEntry''), ROOT(''Entries''), TYPE
														)
													--FROM [Slowniki] s2 WHERE Id = ' + CAST(@IdSlownika AS varchar) + '
													--FOR XML PATH(''Entries''), TYPE)'
							END
						END
					END
					
					SET @Query += ' 
						 FROM dbo.[Slowniki] s 
						 WHERE (s.Id = ' + CAST(@IdSlownika AS varchar) + ' OR s.IdArch = ' + CAST(@IdSlownika AS varchar) + ')';
						 
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('s', @StatusS, @StatusP, @StatusW);	
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhraseForHistory] ('s', @AppDate);
				 
					SET @Query += '
						 FOR XML PATH(''Dictionary''), TYPE
						)
						FOR XML PATH(''HistoryOf''))' 
						
					--PRINT @query
					EXECUTE sp_executesql @query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT
						
					SET @xmlVar += ISNULL(CAST(@xmlOut AS nvarchar(MAX)), '')					

					FETCH NEXT FROM cur INTO @IdSlownika
				END
				CLOSE cur;
				DEALLOCATE cur;
				
				--SELECT * FROM #Obiekty
				--SELECT * FROM #CechyObiektu						
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Dictionary_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Dictionary_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Dictionary_GetHistory"'
	
	IF @DataProgramu IS NOT NULL	
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>'
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		--SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		SET @XMLDataOut += @xmlVar;
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';		

	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DoPobrania') IS NOT NULL
		DROP TABLE #DoPobrania		
		
	IF OBJECT_ID('tempdb..#Slowniki') IS NOT NULL
		DROP TABLE #Slowniki
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
