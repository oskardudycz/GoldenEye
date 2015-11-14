-- =============================================
-- Author:		DK
-- Create date: 2012-03-14
-- Last modified on: 2013-02-12
-- Description:	Pobiera dane slowników o podanych ID.

-- XML wejsciowy w postaci:

	--<Request RequestType="Dictionary_GetByIds" UserId="1" AppDate="2012-09-09T12:55:11">

	--	<Ref Id="1" EntityType="Dictionary"/>
	--	<Ref Id="2" EntityType="Dictionary"/>
	--	<Ref Id="3" EntityType="Dictionary"/>
		
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Dictionary_GetByIds" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="9.1.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	--<!-- przy <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../> -->
	--	<Dictionary Id="2" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" 
	--	DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<Entries TypeId="3">
	--			<DictionaryEntry Id="1" Name="eweewwrwwe" ShortName="ewfwe" Comment="eweewrer" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--				<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			</DictionaryEntry>
	--			<DictionaryEntry Id="2" Name="eweewwrwwe2" ShortName="ewfwe2" Comment="eweewrer" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--				<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			</DictionaryEntry>
	--			<DictionaryEntry Id="3" Name="eweewwrwwe3" ShortName="ewfwe3" Comment="eweewrer" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--				<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			</DictionaryEntry>
	--			<DictionaryEntry Id="4" Name="eweewwrwwe4" ShortName="ewfwe4" Comment="eweewrer" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--				<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			</DictionaryEntry>
	--			<DictionaryEntry Id="5" Name="eweewwrwwe5" ShortName="ewfwe5" Comment="eweewrer" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--				<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			</DictionaryEntry>
	--		</Entries>
	--	</Dictionary>
		
	--	<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="true" ../> -->
	--	<Dictionary Id="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<Entries TypeId="3">
	--			<DictionaryEntry Id="1" Name="eweewwrwwe" ShortName="ewfwe" Comment="eweewrer" LastModifiedOn="2012-02-09T12:12:12.121Z"/>
	--			<DictionaryEntry Id="2" Name="eweewwrwwe2" ShortName="ewfwe2" Comment="eweewrer" LastModifiedOn="2012-02-09T12:12:12.121Z"/>
	--		</Entries>
	--	</Dictionary>
		
	--	<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="false" ../> -->
	--	<Dictionary Id="4" Name="KodyPocztowe" LastModifiedOn="2012-02-09T12:12:12.121Z"/>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Dictionary_GetByIds]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@PobierzWszystieDane bit = 0,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@RozwijajPodwezly bit = 0,
		@Response nvarchar(MAX) = '',
		@Id int,
		@Nazwa nvarchar(255),
		@TypId int,
		@MaUprawnienia bit = 0,
		@StandardWhere nvarchar(MAX) = '',
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@IdArch int,
		@DateFromColumnName nvarchar(100),
		@TypDanychId int
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_GetByIds', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN
			BEGIN TRY
			
			--usuwanie tabel tymczasowych, jesli istnieja			
			IF OBJECT_ID('tempdb..#Slowniki') IS NOT NULL
				DROP TABLE #Slowniki
				
			IF OBJECT_ID('tempdb..#WpisySlownika') IS NOT NULL
				DROP TABLE #WpisySlownika
				
			IF OBJECT_ID('tempdb..#NazwySlownikow') IS NOT NULL
				DROP TABLE #NazwySlownikow
				
			IF OBJECT_ID('tempdb..#IDDoPobrania') IS NOT NULL
				DROP TABLE #IDDoPobrania
				
			CREATE TABLE #IDDoPobrania (ID int);							
			CREATE TABLE #Slowniki (Id int, IdArch int);
			CREATE TABLE #WpisySlownika (Id int);
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
			
			--wyciaganie ID slownikow do pobrania
			INSERT INTO #IDDoPobrania(Id)
			SELECT	C.value('./@Id', 'int')
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'varchar(30)') = 'Dictionary'
			
			--SELECT * FROM #NazwySlownikow
			--SELECT * FROM #IDDoPobrania	 
		
			IF @RequestType = 'Dictionary_GetByIds'
			BEGIN	
				
				-- pobranie daty na podstawie przekazanego AppDate
				SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);				

				--pobranie nazwy kolumny po ktorej filtrowane sa daty
				SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();			
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'GET',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					--dodanie frazy na daty
					SET @StandardWhere = [THB].[PrepareDatesPhrase] (NULL, @AppDate);	
					
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @StandardWhere += [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);
						
						
					--pobranie danych Id pasujacych slownikow do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Slowniki (Id, IdArch)
							SELECT allData.Id, allData.IdArch FROM
							(
								SELECT s.Id, s.IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(s.IdArch, s.Id) ORDER BY s.Id ASC) AS Rn
								FROM [dbo].[Slowniki] s
								INNER JOIN
								(
									SELECT ISNULL(s2.IdArch, s2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, s2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Slowniki] s2								 
									INNER JOIN 
									(
										SELECT ISNULL(s3.IdArch, s3.Id) AS RowID, MAX(s3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Slowniki] s3
										WHERE (s3.Id IN (SELECT DISTINCT Id FROM #IDDoPobrania) OR s3.IdArch IN (SELECT DISTINCT Id FROM #IDDoPobrania)) ' + @StandardWhere;						
									
					SET @Query += '
										GROUP BY ISNULL(s3.IdArch, s3.Id)
									) latest
									ON ISNULL(s2.IdArch, s2.Id) = latest.RowID AND s2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(s2.IdArch, s2.Id), s2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(s.IdArch, s.Id) = latestWithMaxDate.RowID AND s.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND s.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;									
			
					--pobranie nazw slownikow ktorych dane bedziemy pobierac		
					SELECT s.Id, s.Nazwa 
					INTO #NazwySlownikow
					FROM [Slowniki] s
					WHERE Id IN (SELECT ISNULL(IdArch, Id) FROM #Slowniki);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
							
					--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
					DECLARE cur CURSOR LOCAL FOR 
						SELECT Id, Nazwa FROM #NazwySlownikow
					OPEN cur
					FETCH NEXT FROM cur INTO @Id, @Nazwa
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--zabezpieczenie sie przed pobieraniem danych ktore i tak by nie byly zwracane
						IF @RozwijajPodwezly = 1
						BEGIN
							--usuniecie poprzednich danych
							DELETE FROM #WpisySlownika;							
							
							--pobranie danych Id pasujacych wpisow do tabeli tymczasowej							
							SET @Query = '
									INSERT INTO #WpisySlownika (Id)
									SELECT allData.Id FROM
									(
										SELECT sw.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(sw.IdArch, sw.Id) ORDER BY sw.Id ASC) AS Rn
										FROM [dbo].[_Slownik_' + @Nazwa + '] sw
										INNER JOIN
										(
											SELECT ISNULL(sw2.IdArch, sw2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, sw2.' + @DateFromColumnName + ' AS MaxDate
											FROM [dbo].[_Slownik_' + @Nazwa + ']  sw2								 
											INNER JOIN 
											(
												SELECT ISNULL(sw3.IdArch, sw3.Id) AS RowID, MAX(sw3.' + @DateFromColumnName + ') AS MaxDate
												FROM [dbo].[_Slownik_' + @Nazwa + ']  sw3
												WHERE 1=1 ' + @StandardWhere;						
											
							SET @Query += '
												GROUP BY ISNULL(sw3.IdArch, sw3.Id)
											) latest
											ON ISNULL(sw2.IdArch, sw2.Id) = latest.RowID AND sw2.' + @DateFromColumnName + ' = latest.MaxDate
											GROUP BY ISNULL(sw2.IdArch, sw2.Id), sw2.' + @DateFromColumnName + '					
										) latestWithMaxDate
										ON  ISNULL(sw.IdArch, sw.Id) = latestWithMaxDate.RowID AND sw.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND sw.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
									) allData
									WHERE allData.Rn = 1'
				
							--PRINT @Query;
							EXECUTE sp_executesql @Query;
							
							
							--pobranie typu danych slownika
							SET @Query = '
									SELECT @TypDanychId = allData.Id FROM
									(
										SELECT ct.Id, ISNULL(ct.IdArch, ct.Id) AS IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(ct.IdArch, ct.Id) ORDER BY ct.Id ASC) AS Rn
										FROM [dbo].[Cecha_Typy] ct
										INNER JOIN
										(
											SELECT ISNULL(ct2.IdArch, ct2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, ct2.' + @DateFromColumnName + ' AS MaxDate
											FROM [dbo].[Cecha_Typy] ct2								 
											INNER JOIN 
											(
												SELECT ISNULL(ct3.IdArch, ct3.Id) AS RowID, MAX(ct3.' + @DateFromColumnName + ') AS MaxDate
												FROM [dbo].[Cecha_Typy] ct3
												WHERE ISNULL(ct3.IdArch, ct3.Id) IN (SELECT TypId FROM dbo.Slowniki s WHERE s.Id = ' + CAST(@Id AS varchar) + ')'									
											
							--dodanie frazy statusow na filtracje jesli trzeba
							SET @Query += [THB].[PrepareStatusesPhrase] ('ct3', @StatusS, @StatusP, @StatusW);
							
							--dodanie frazy na daty
							SET @Query += [THB].[PrepareDatesPhrase] ('ct3', @AppDate);					
										
							SET @Query += '
												GROUP BY ISNULL(ct3.IdArch, ct3.Id)
											) latest
											ON ISNULL(ct2.IdArch, ct2.Id) = latest.RowID AND ct2.' + @DateFromColumnName + ' = latest.MaxDate
											GROUP BY ISNULL(ct2.IdArch, ct2.Id), ct2.' + @DateFromColumnName + '					
										) latestWithMaxDate
										ON  ISNULL(ct.IdArch, ct.Id) = latestWithMaxDate.RowID AND ct.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND ct.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
									) allData
									WHERE allData.Rn = 1'
									
							--PRINT @query;
							EXECUTE sp_executesql @Query, N'@TypDanychId int OUTPUT', @TypDanychId = @TypDanychId OUTPUT									
						END		

						
						SET @query = 'SET @xmlTemp = (';
						
						IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
						BEGIN
							SET @Query += 'SELECT ISNULL(s.[IdArch], s.[Id]) AS "@Id"
											,s.[Nazwa] AS "@Name"
											,s.[TypId] AS "@DataTypeId"
											,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"'
											
							--pobieranie danych podwezlow			
							IF @RozwijajPodwezly = 1
							BEGIN
								
								SET @Query += '			
											, (SELECT ISNULL(ct.[IdArch], ct.[Id]) AS "@Id"
												,ct.[Nazwa] AS "@Name"
												,ct.[NazwaSQL] AS "@SQLName"
												,ct.[Nazwa_UI] AS "@UIName"
												,CASE ct.[CzyCechaUzytkownika] WHEN 1 THEN ''true'' ELSE ''false'' END AS "@IsUserAttribute"
												,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
												FROM dbo.Cecha_Typy ct
												WHERE ct.[Id] = ' + CAST(@TypDanychId AS varchar) + '
												FOR XML PATH (''DataType''), TYPE)'	
								
								SET @Query += '
											--, (SELECT TOP 1 sr.[TypId] AS "@TypeId"
												, (SELECT ISNULL(sr.[IdArch], sr.[Id]) AS "@Id"
													,sr.[Nazwa] AS "@Name"
													,sr.[NazwaSkrocona] AS "@ShortName"
													,sr.[NazwaPelna] AS "@FullName"
													,sr.[Uwagi] AS "@Comment"
													,ISNULL(sr.[LastModifiedOn], sr.[CreatedOn]) AS "@LastModifiedOn"
													FROM [_Slownik_' + @Nazwa + '] sr
													WHERE sr.ID IN (SELECT ID FROM #WpisySlownika)
													FOR XML PATH(''DictionaryEntry''), ROOT(''Entries''), TYPE
													)
												--FROM [_Slownik_' + @Nazwa + '] sr
												--FOR XML PATH(''Entries''), TYPE)'																
							END					
						END
						ELSE
						BEGIN
							SET @Query += 'SELECT ISNULL(s.[IdArch], s.[Id]) AS "@Id"
										,s.[Nazwa] AS "@Name"
										,s.[TypId] AS "@DataTypeId"
										,s.[IsDeleted] AS "@IsDeleted"
										,s.[DeletedFrom] AS "@DeletedFrom"
										,s.[DeletedBy] AS "@DeletedBy"
										,s.[CreatedOn] AS "@CreatedOn"
										,s.[CreatedBy] AS "@CreatedBy"
										,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
										,s.[LastModifiedBy] AS "@LastModifiedBy"
										,s.[ObowiazujeOd] AS "History/@EffectiveFrom"
										,s.[ObowiazujeDo] AS "History/@EffectiveTo"
										,s.[CzyPrzechowujeHistorie] AS "History/@IsMainHistFlow"
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
										,s.[StatusPToBy] AS "Statuses/@StatusPToBy"';
									  
							--pobieranie danych podwezlow			
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
											  ,ct.[LastModifiedBy] AS "@LastModifiedBy"
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
											WHERE ct.[Id] = ' + CAST(@TypDanychId AS varchar) + '
											FOR XML PATH (''DataType''), TYPE)'
							
								SET @Query += '--, (SELECT TOP 1 sr.[TypId] AS "@TypeId"
												, (SELECT ISNULL(sr.[IdArch], sr.[Id]) AS "@Id"
													,sr.[Nazwa] AS "@Name"
													,sr.[NazwaSkrocona] AS "@ShortName"
													,sr.[NazwaPelna] AS "@FullName"
													,sr.[Uwagi] AS "@Comment"
													,ISNULL(sr.[LastModifiedOn], sr.[CreatedOn]) AS "@LastModifiedOn"
													,sr.[IsDeleted] AS "@IsDeleted"
													,sr.[DeletedFrom] AS "@DeletedFrom"
													,sr.[DeletedBy] AS "@DeletedBy"
													,sr.[CreatedOn] AS "@CreatedOn"
													,sr.[CreatedBy] AS "@CreatedBy"
													,sr.[LastModifiedBy] AS "@LastModifiedBy"
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
													FROM [_Slownik_' + @Nazwa + '] sr
													WHERE sr.ID IN (SELECT ID FROM #WpisySlownika)
													FOR XML PATH(''DictionaryEntry''), ROOT(''Entries''), TYPE
												)
												--FROM [_Slownik_' + @Nazwa + '] sr
												--FOR XML PATH(''Entries''), TYPE)'						
							END	
						END	
						
						--weryfikacja czy Id ma byc aktualnego rekordu czy jego wartosc IdArch
						IF NOT EXISTS (SELECT Id FROM #Slowniki WHERE Id = @Id)
							SELECT TOP 1 @Id = Id FROM #Slowniki WHERE IdArch = @Id;
				
						SET @query += ' 
								FROM [Slowniki] s
								WHERE Id = ' + CAST(@Id AS varchar) + '							
								FOR XML PATH(''Dictionary''))';				  
			
						--PRINT @query;
						EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
										
						SET @Response += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
						
						FETCH NEXT FROM cur INTO @Id, @Nazwa
						
					END
					CLOSE cur
					DEALLOCATE cur
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Dictionary_GetByIds', @Wiadomosc = @ERRMSG OUTPUT						
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Dictionary_GetByIds', @Wiadomosc = @ERRMSG OUTPUT	
				
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
		END CATCH	
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Dictionary_GetByIds"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"'; 
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		--SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		SET @XMLDataOut += @Response;
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
			
	SET @XMLDataOut += '</Response>';
	
	--usuwanie tabel tymczasowych, jesli istnieja		
	IF OBJECT_ID('tempdb..#Slowniki') IS NOT NULL
		DROP TABLE #Slowniki
		
	IF OBJECT_ID('tempdb..#WpisySlownika') IS NOT NULL
		DROP TABLE #WpisySlownika
		
	IF OBJECT_ID('tempdb..#NazwySlownikow') IS NOT NULL
		DROP TABLE #NazwySlownikow
		
	IF OBJECT_ID('tempdb..#IDDoPobrania') IS NOT NULL
		DROP TABLE #IDDoPobrania
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
