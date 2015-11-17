-- =============================================
-- Author:		DK
-- Create date: 2012-03-14
-- Last modified on: 2013-05-20
-- Description:	Zapisuje dane typow obiektu w bazie. Aktualizuje istniejacy lub wstawia nowy rekord.

-- XML Wejsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Request RequestType="ObjectTypes_Save" UserId="1" AppDate="2012-02-09T12:56:23">
		
	--	<UnitType Id="1" Name="?" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<CouplerAttributeType Id="0" AttributeTypeId="3" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3"/>
	--		<CouplerAttributeType Id="0" AttributeTypeId="5" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3"/>
	--		<CouplerAttributeType Id="0" AttributeTypeId="23" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3"/>
	--		<CouplerAttributeType Id="0" AttributeTypeId="56" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3"/>
	--	</UnitType>
		
	--	<UnitType Id="0" Name="?" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<CouplerAttributeType Id="0" AttributeTypeId="3" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3"/>
	--		<CouplerAttributeType Id="0" AttributeTypeId="5" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3"/>
	--		<CouplerAttributeType Id="0" AttributeTypeId="23" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3"/>
	--		<CouplerAttributeType Id="0" AttributeTypeId="56" LastModifiedOn="2012-02-09T12:12:12.121Z" Priority="1" UIOrder="3"/>
	--	</UnitType>
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="ObjectTypes_Save" AppDate="2012-03-19" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file:///C:/Users/dkral/Desktop/THB/THB_XSD_Ver9/trunk/4.UnitTypes/4.3.Response.xsd">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitTypes_Save]
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
		@Id int,
		@Nazwa nvarchar(50),
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@ERRMSG nvarchar(255),
		@xmlOk bit = 0,
		@xml_data xml,
		@IsArchive bit,
		@ArchivedBy int,
		@IsStatus bit,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@IsAlternativeHistory bit,
		@Importance smallint,
		@IsMainHistFlow bit,
		@PrzetwarzanyRekordId int,
		@LastModifiedOn datetime,
		@Priority int,
		@UIOrder int,
		@IsTable bit,
		@CechaId int,
		@Skip bit = 0,
		@MaUprawnienia bit = 0,
		@TypObiektuCechaId int,
		@TypObiektuCechaLastModifiedOn datetime,
		@Index int,
		@Commit bit = 1,
		@Query nvarchar(MAX) = '',
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacyTypObiektuId int,
		@ZmianaNazwyTypuObiektu bit = 0,
		@ObecnaNazwaTypuObiektu nvarchar(256),
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@SaNoweCechy bit = 0,
		@OldNazwa nvarchar(256),
		@OldIsStatus bit,
		@OldStatusS int,
		@OldStatusW int,
		@OldStatusP int,
		@Counter int,
		@IloscTypowObiektow int,
		@CouplerIndex int,
		@ColumnType nvarchar(100),
		@ColumnName nvarchar(100),
		@ZablokowanyDoEdycji bit = 0

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#TypyObiektowDoZapisania') IS NOT NULL
			DROP TABLE #TypyObiektowDoZapisania
			
		IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
			DROP TABLE #Statusy
			
		IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
			DROP TABLE #Historia
			
		IF OBJECT_ID('tempdb..#CechyTypuObiektu') IS NOT NULL
			DROP TABLE #CechyTypuObiektu
			
		IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
			DROP TABLE #IDZmienionych
			
		IF OBJECT_ID('tempdb..#TypyObiektowKonfliktowe') IS NOT NULL
			DROP TABLE #TypyObiektowKonfliktowe
				
		IF OBJECT_ID('tempdb..#TypyObiektowNieUnikalne') IS NOT NULL
			DROP TABLE #TypyObiektowNieUnikalne
			
		IF OBJECT_ID('tempdb..#StatusyCechTypuObiektu') IS NOT NULL
			DROP TABLE #StatusyCechTypuObiektu	
			
		IF OBJECT_ID('tempdb..#HistoriaCechTypuObiektu') IS NOT NULL
			DROP TABLE #HistoriaCechTypuObiektu			
				
		CREATE TABLE #TypyObiektowKonfliktowe(ID int);	
		CREATE TABLE #TypyObiektowNieUnikalne(ID int);		
		CREATE TABLE #IDZmienionych (ID int);		
		CREATE TABLE #CechyTypuObiektu(RootIndex int, CouplerIndex int, Id int, Cecha_ID int, [Priority] smallint, UIOrder smallint, Importance smallint, LastModifiedOn datetime);
		
		CREATE TABLE #StatusyCechTypuObiektu (RootIndex int, CouplerIndex int, IsStatus bit, StatusP int, StatusPFrom datetime, StatusPTo datetime,
			StatusPFromBy int, StatusPToBy int, StatusS int, StatusSFrom datetime, StatusSTo datetime, StatusSFromBy int, StatusSToBy int,
			StatusW int, StatusWFrom datetime, StatusWTo datetime, StatusWFromBy int, StatusWToBy int);
		
		CREATE TABLE #HistoriaCechTypuObiektu (RootIndex int, CouplerIndex int, ZmianaOd datetime, ZmianaDo datetime, DataObowiazywaniaOd datetime, DataObowiazywaniaDo datetime,
			IsAlternativeHistory bit, IsMainHistFlow bit);		
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_UnitTypes_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN			
			SET @ERRMSG = @ERRMSG
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
							
			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C);
			
			--pobranie ilosci typow obiektow
			SELECT @IloscTypowObiektow = @xml_data.value('count(/Request/UnitType)','int'); 
			
			--odczytywanie danych obiektow		
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowObiektow
			)
			SELECT j AS 'Index'
				,C.value('./@Id','int') AS Id
				,C.value('./@Name', 'nvarchar(200)') AS Nazwa
				,C.value('./@IsTable', 'bit') AS Tabela
				,C.value('./@IsArchiveFrom', 'datetime') AS IsArchiveFrom
				,C.value('./@IsArchive', 'bit') AS IsArchive
				,C.value('./@ArchivedBy', 'int') AS ArchivedBy
				,C.value('./@IsDeleted', 'bit') AS IsDeleted
				,C.value('./@DeletedFrom', 'datetime') AS DeletedFrom
				,C.value('./@DeletedBy', 'int') AS DeletedBy
				,C.value('./@CreatedOn', 'datetime') AS CreatedOn
				,C.value('./@CreatedBy', 'int') AS CreatedBy				
				,C.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				,C.value('./@LastModifiedBy', 'int') AS LastModifiedBy
			INTO #TypyObiektowDoZapisania
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/UnitType[position()=sql:column("j")]')  e(C);
			
			--pobranie statusow i historii dla typow obiektu
			;WITH Num(i)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT i + 1
			   FROM Num
			   WHERE i < @IloscTypowObiektow
			)
			SELECT i AS 'RootIndex'
				,C.value('./@ChangeFrom', 'datetime') AS ZmianaOd 
				,C.value('./@ChangeTo', 'datetime') AS ZmianaDo
				,C.value('./@EffectiveFrom', 'datetime') AS DataObowiazywaniaOd
				,C.value('./@EffectiveTo', 'datetime') AS DataObowiazywaniaDo
				,C.value('./@IsAlternativeHistory', 'bit') AS IsAlternativeHistory
				,C.value('./@IsMainHistFlow', 'bit') AS IsMainHistFlow
			INTO #Historia
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/UnitType[position()=sql:column("i")]/History') e(C);
			
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowObiektow
			)
			SELECT j AS 'RootIndex'
				,C.value('./@IsStatus', 'bit') AS IsStatus
				,C.value('./@StatusP', 'int') AS StatusP  
				,C.value('./@StatusPFrom', 'datetime') AS StatusPFrom 
				,C.value('./@StatusPTo', 'datetime') AS StatusPTo
				,C.value('./@StatusPFromBy', 'int') AS StatusPFromBy
				,C.value('./@StatusPToBy', 'int') AS StatusPToBy
				,C.value('./@StatusS', 'int') AS StatusS
				,C.value('./@StatusSFrom', 'datetime') AS StatusSFrom
				,C.value('./@StatusSTo', 'datetime') AS StatusSTo
				,C.value('./@StatusSFromBy', 'int') AS StatusSFromBy
				,C.value('./@StatusSToBy', 'int') AS StatusSToBy
				,C.value('./@StatusW', 'int') AS StatusW
				,C.value('./@StatusWFrom', 'datetime') AS StatusWFrom 
				,C.value('./@StatusWTo', 'datetime') AS StatusWTo
				,C.value('./@StatusWFromBy', 'int') AS StatusWFromBy
				,C.value('./@StatusWToBy', 'int') AS StatusWToBy
			INTO #Statusy
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/UnitType[position()=sql:column("j")]/Statuses') e(C);			
			
			SET @Counter = 0;
			
			WHILE @Counter <= @IloscTypowObiektow
			BEGIN
				--statusy dla relacji struktury
				SET @Query = '
					;WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/UnitType[position()=' + CAST(@Counter AS varchar) + ']/CouplerAttributeType)'', ''int'') )
					)	
						
					INSERT INTO #StatusyCechTypuObiektu (RootIndex, CouplerIndex, IsStatus, StatusP, StatusPFrom, StatusPTo, StatusPFromBy, StatusPToBy, StatusS, StatusSFrom, 
						StatusSTo, StatusSFromBy, StatusSToBy, StatusW, StatusWFrom, StatusWTo, StatusWFromBy, StatusWToBy)
					SELECT ' + CAST(@Counter AS varchar) + '
							, j
							,x.value(''./@IsStatus'', ''bit'')
							,x.value(''./@StatusP'', ''int'')  
							,x.value(''./@StatusPFrom'', ''datetime'')  
							,x.value(''./@StatusPTo'', ''datetime'')
							,x.value(''./@StatusPFromBy'', ''int'')
							,x.value(''./@StatusPToBy'', ''int'')
							,x.value(''./@StatusS'', ''int'')
							,x.value(''./@StatusSFrom'', ''datetime'')
							,x.value(''./@StatusSTo'', ''datetime'') 
							,x.value(''./@StatusSFromBy'', ''int'')
							,x.value(''./@StatusSToBy'', ''int'') 
							,x.value(''./@StatusW'', ''int'')
							,x.value(''./@StatusWFrom'', ''datetime'')
							,x.value(''./@StatusWTo'', ''datetime'')
							,x.value(''./@StatusWFromBy'', ''int'') 
							,x.value(''./@StatusWToBy'', ''int'')	
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/UnitType[position()=' + CAST(@counter AS varchar) + ']/CouplerAttributeType[position()=sql:column("j")]/Statuses'')  e(x);	
					';
					
				--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data	

				--cechy powiazane z typem obiektu
				SET @Query = '
					WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/UnitType[position()=' + CAST(@Counter AS varchar) + ']/CouplerAttributeType)'', ''int'') )
					)
					INSERT INTO #CechyTypuObiektu(RootIndex, CouplerIndex, Id,  Cecha_ID, [Priority], UIOrder, Importance, LastModifiedOn)
					SELECT ' + CAST(@Counter AS varchar) + '
						,j
						,x.value(''./@Id'', ''int'')
						,x.value(''./@AttributeTypeId'', ''int'')
						,x.value(''./@Priority'', ''smallint'')
						,x.value(''./@UIOrder'', ''smallint'')
						,x.value(''./@Importance'', ''smallint'')
						,x.value(''./@LastModifiedOn'', ''datetime'')
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/UnitType[position()=' + CAST(@counter AS varchar) + ']/CouplerAttributeType[position()=sql:column("j")]'')  e(x);'
			
				--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				--odczytywanie danych zmian dla typu obiektu
				SET @Query = '
					WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < (SELECT @xml_data.value(''count(/Request/UnitType[position()=' + CAST(@Counter AS varchar) + ']/CouplerAttributeType)'', ''int'') )
					)	
						
					INSERT INTO #HistoriaCechTypuObiektu (RootIndex, CouplerIndex, ZmianaOd, ZmianaDo, DataObowiazywaniaOd, DataObowiazywaniaDo, IsAlternativeHistory, IsMainHistFlow)
					SELECT ' + CAST(@Counter AS varchar) + '
							, j
							,x.value(''./@ChangeFrom'', ''datetime'') 
							,x.value(''./@ChangeTo'', ''datetime'')
							,x.value(''./@EffectiveFrom'', ''datetime'')
							,x.value(''./@EffectiveTo'', ''datetime'')
							,x.value(''./@IsAlternativeHistory'', ''bit'')
							,x.value(''./@IsMainHistFlow'', ''bit'')
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/UnitType[position()=' + CAST(@Counter AS varchar) + ']/CouplerAttributeType[position()=sql:column("j")]/History'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data	
				
				SET @Counter = @Counter + 1; 				
			END	
			
			--SELECT * FROM #TypyObiektowDoZapisania;
			--SELECT * FROM #Historia;
			--SELECT * FROM #Statusy;
			--SELECT * FROM #CechyTypuObiektu;
			--SELECT * FROM #StatusyCechTypuObiektu
			--SELECT * FROM #HistoriaCechTypuObiektu
						
			IF @RequestType = 'UnitTypes_Save'
			BEGIN
			
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					BEGIN TRANSACTION T1_UnitTypes_Save

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
				
					DECLARE cur CURSOR LOCAL FOR 
						SELECT [Index], Id, dbo.Trim(Nazwa), Tabela, IsArchive, ArchivedBy, LastModifiedOn FROM #TypyObiektowDoZapisania
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @IsTable, @IsArchive, @ArchivedBy, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN					

						--wyzerowanie zmiennych
						SET @Skip = 0;
						SET @ZmianaNazwyTypuObiektu = 0;
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL, @IsAlternativeHistory = 0, @IsMainHistFlow = 0;
						
						--pobranie danych historii
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
						@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
						FROM #Historia WHERE RootIndex = @Index 
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index

--poki co rezygnacja z uzywania kolumny
SET @DataObowiazywaniaDo = NULL;
						SET @ZablokowanyDoEdycji = 0;

						IF @Id > 0
						BEGIN
							SELECT @ZablokowanyDoEdycji = IsBlocked
							FROM dbo.TypObiektu
							WHERE typObiekt_ID = @Id;
						END
						
						--zapisujemy dane tylko jesli obiekt nie zablokowany do edycji
						IF @ZablokowanyDoEdycji = 0
						BEGIN
							SET @IstniejacyTypObiektuId = (SELECT TOP 1 TypObiekt_ID FROM [TypObiektu] WHERE LOWER(Nazwa) = LOWER(@Nazwa) AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0 AND TypObiekt_ID <> @Id)
						
							IF @IstniejacyTypObiektuId IS NULL
							BEGIN
											
								--sprawdzenie czy sa nowe cechy dla typu obiektu
								--nowo dodawane cechy maja w polu Id wartosc 0
								IF EXISTS (SELECT Id FROM #CechyTypuObiektu WHERE Id = 0 AND RootIndex = @Index)
									SET @SaNoweCechy = 1;
								ELSE
									SET @SaNoweCechy = 0;	
						
								--sprawdzenie czy zmienila sie nazwa typu obiektu
								SET @ObecnaNazwaTypuObiektu = (SELECT Nazwa FROM dbo.[TypObiektu] WHERE TypObiekt_ID = @Id);
								
								--jesli nie znaleziono nazwy to znaczy ze wstawianie nowego obiektu
								IF @ObecnaNazwaTypuObiektu IS NULL
									SET @ObecnaNazwaTypuObiektu = @Nazwa;
								
								--pobranie aktualnych danych relacji by sprawdzic czy zmienila sie jakas dana
								SELECT @OldNazwa = Nazwa, @OldIsStatus = IsStatus, @OldStatusS = StatusS, @OldStatusW = StatusW, @OldStatusP = StatusP
								FROM dbo.[TypObiektu] WHERE TypObiekt_ID = @Id;

								--jesli typ obiektu o podanym ID juz istnieje to jego aktualizacja
								IF EXISTS (SELECT TypObiekt_ID FROM [TypObiektu] WHERE TypObiekt_ID = @Id)
								BEGIN
								
									--sprawdzenie czy zmienily sie dane relacji i czy sa nowe relacje
									IF (LOWER(@OldNazwa) = LOWER(@Nazwa) AND @OldIsStatus = ISNULL(@IsStatus, 0) AND CAST(ISNULL(@OldStatusS, 0) AS varchar) = CAST(ISNULL(@StatusS, 0) AS varchar) AND
										CAST(ISNULL(@OldStatusW, 0) AS varchar) = CAST(ISNULL(@StatusW, 0) AS varchar) AND CAST(ISNULL(@OldStatusP, 0) AS varchar) = CAST(ISNULL(@StatusP, 0) AS varchar) AND @SaNoweCechy = 0)
									BEGIN
										IF EXISTS(SELECT TypObiekt_ID FROM dbo.TypObiektu WHERE TypObiekt_ID = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn)))
										BEGIN
											--brak zmian danych i brak nowych relacji, ustalamy tylko Id dla przetwarzanego rekordu
											SET @PrzetwarzanyRekordId = @Id;
											INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanyRekordId);
											
											--zmieniamy tylko daty ostatnich modyfikacji przy wylaczonych triggerach
											DISABLE TRIGGER [WartoscZmiany_TypObiektu_UPDATE] ON dbo.[TypObiektu];
											
											UPDATE dbo.[TypObiektu] SET
											LastModifiedOn = @DataModyfikacjiApp,
											RealLastModifiedOn = @DataModyfikacji
											WHERE TypObiekt_ID = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
											
											ENABLE TRIGGER [WartoscZmiany_TypObiektu_UPDATE] ON dbo.[TypObiektu];
										END
										ELSE
										BEGIN
											INSERT INTO #TypyObiektowKonfliktowe(ID)
											VALUES(@Id);
												
											EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
											SET @Commit = 0;
											SET @Skip = 1;
										END
									END
									ELSE
									BEGIN
										--aktualizacja danych typu obiektu
										UPDATE [TypObiektu] SET
										Nazwa = @Nazwa,
									--	Tabela = @IsTable,
										StatusP = @StatusP,								
										StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
										StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
										StatusS = @StatusS,								
										StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
										StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
										StatusW = @StatusW,
										StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
										StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
										IsStatus = ISNULL(@IsStatus, 0),
										LastModifiedOn = @DataModyfikacjiApp,
										LastModifiedBy = @UzytkownikID,
										ValidFrom = @DataModyfikacjiApp,
										RealLastModifiedOn = @DataModyfikacji,
										ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
										ObowiazujeDo = @DataObowiazywaniaDo
										WHERE TypObiekt_ID = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn))
																
										IF @@ROWCOUNT > 0
										BEGIN
											INSERT INTO #IDZmienionych
											VALUES(@Id);
											
											IF @ObecnaNazwaTypuObiektu <> @Nazwa
												SET @ZmianaNazwyTypuObiektu = 1;
											
											SET @PrzetwarzanyRekordId = @Id;
										END
										ELSE
										BEGIN	
											--wystapil konflikt konkurencji - data ostaniej modyfikacji sie nie zgadza										
											INSERT INTO #TypyObiektowKonfliktowe(ID)
											VALUES(@Id);
												
											EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
											SET @Commit = 0;
											SET @Skip = 1;
										END
									END
								END
								ELSE
								--jesli nie istnieje to jej wstawienie do bazy
								BEGIN
									
									INSERT INTO [TypObiektu] (Nazwa, Tabela, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy, 
										CreatedBy, CreatedOn, ValidFrom, IsStatus, RealCreatedOn, ObowiazujeOd, ObowiazujeDo)
									VALUES(
										@Nazwa, 
										@IsTable,
										@StatusP, 
										CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
										CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
										@StatusS,
										CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
										CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
										@StatusW, 
										CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
										CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END, 
										@UzytkownikID,
										@DataModyfikacjiApp,
										@DataModyfikacjiApp,
										ISNULL(@IsStatus, 0),
										@DataModyfikacji,
										ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
										@DataObowiazywaniaDo
									);

									IF @@ROWCOUNT > 0
									BEGIN
										SET @PrzetwarzanyRekordId = @@IDENTITY;
										
										INSERT INTO #IDZmienionych
										VALUES(@PrzetwarzanyRekordId);
									END
									ELSE
										SET @Skip = 1;
								END
			
								IF @Skip = 0
								BEGIN
									--pobranie cech dla typu obiektu
									--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
									IF Cursor_Status('local','cur2') > 0 
									BEGIN
										 CLOSE cur2
										 DEALLOCATE cur2
									END
								
									DECLARE cur2 CURSOR LOCAL FOR 
										SELECT CouplerIndex, Id, Cecha_ID, [Priority], UIOrder, Importance, LastModifiedOn FROM #CechyTypuObiektu WHERE RootIndex = @Index
									OPEN cur2
									FETCH NEXT FROM cur2 INTO @CouplerIndex, @TypObiektuCechaId, @CechaID, @Priority, @UIOrder, @Importance, @TypObiektuCechaLastModifiedOn
									WHILE @@FETCH_STATUS = 0
									BEGIN
																	
										--pobranie IsTable z bazy! potrzebne
										SELECT @IsTable = Tabela
										FROM dbo.TypObiektu
										WHERE TypObiekt_ID = @PrzetwarzanyRekordId;
									
										--wyzerowanie zmiennych
										SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
										SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL, @IsAlternativeHistory = 0, @IsMainHistFlow = 0;						
											
										--pobranie danych statusow dla cech typu obiektu
										SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
										FROM #StatusyCechTypuObiektu WHERE RootIndex = @Index AND CouplerIndex = @CouplerIndex	
										
										--pobranie danych histori
										SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
										@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
										FROM #HistoriaCechTypuObiektu WHERE RootIndex = @Index AND CouplerIndex = @CouplerIndex

	--poki co rezygnacja z uzywania kolumny
	SET @DataObowiazywaniaDo = NULL;
													
										IF NOT EXISTS (SELECT Id FROM [TypObiektu_Cechy] WHERE ID <> @TypObiektuCechaId AND Cecha_ID = @CechaID AND TypObiektu_ID = @PrzetwarzanyRekordId AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0)
										BEGIN
											--jesli typ obiektu jako tabela to dodawanie tez odpowiednich kolumn do tabeli na obiekty
											IF @IsTable = 1
											BEGIN									
												--SELECT @ColumnType = ct.NazwaSQL, @ColumnName = dbo.Trim(c.Nazwa)
												--FROM dbo.Cechy c
												--JOIN dbo.Cecha_Typy ct ON (c.TypID = ct.Id)
												--WHERE c.Cecha_ID = @CechaID;			
												
												--pobranie danych cechy z jakimi zostala stworzona (by pozwolic na kolejne zmiany jej nazwy)
												SELECT DISTINCT @ColumnName = THB.[GetAllowedAttributeTypeName](c.Nazwa), @ColumnType = ct.NazwaSql --TOP1  
												FROM
												(
													SELECT o.Cecha_ID, o.IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(o.IdArch, o.Cecha_ID) ORDER BY o.Cecha_ID ASC) AS Rn
													FROM [dbo].[Cechy] o
													INNER JOIN
													(
														SELECT ISNULL(c2.IdArch, c2.Cecha_ID) AS RowID, MIN(c2.ObowiazujeOd) AS MinDate
														FROM [dbo].[Cechy] c2							 
														WHERE (c2.Cecha_Id = @CechaID OR c2.IdArch = @CechaID) AND c2.IsDeleted = 0
														GROUP BY ISNULL(c2.IdArch, c2.Cecha_ID)
													) latestWithMaxDate
													ON ISNULL(o.IdArch, o.Cecha_ID) = latestWithMaxDate.RowID AND o.ObowiazujeOd = latestWithMaxDate.MinDate
												) allData
												JOIN dbo.Cechy c ON (c.Cecha_Id = allData.Cecha_Id)
												JOIN dbo.Cecha_Typy ct ON (c.TypId = ct.Id) 
												WHERE allData.Rn = 1
												
												--jesli kolumna nie istnieje to jej dodanie do tabeli
												SET @Query = '
													IF [THB].[ColumnExists] (''_' + @ObecnaNazwaTypuObiektu + ''', ''' + @ColumnName + ''') = 0
													BEGIN
														ALTER TABLE [_' + @ObecnaNazwaTypuObiektu + ']
														ADD [' + @ColumnName + '] ' + @ColumnType + ' NULL
														
														PRINT ''dodano kolumne'';
													END'
													
												--PRINT @Query
												EXECUTE sp_executesql @Query;
											END
										
											--jesli typ obiektu o podanym ID juz istnieje to jego aktualizacja
											IF EXISTS (SELECT Id FROM [TypObiektu_Cechy] WHERE Id = @TypObiektuCechaId)
											BEGIN
												UPDATE TypObiektu_Cechy SET
												Cecha_ID = @CechaID,
												[Priority] = @Priority,
												UIOrder = @UiOrder,
												Importance = @Importance,
												--CzyPrzechowujeHistorie = @CzyPrzechowujeHistorie,
												LastModifiedOn = @DataModyfikacjiApp,
												LastModifiedBy = @UzytkownikID,
												ValidFrom = @DataModyfikacjiApp,
												StatusP = @StatusP,								
												StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
												StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
												StatusS = @StatusS,								
												StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
												StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
												StatusW = @StatusW,
												StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
												StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
												IsStatus = ISNULL(@IsStatus, 0),
												RealLastModifiedOn = @DataModyfikacji,
												ObowiazujeOd = @DataModyfikacjiApp, --ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
												ObowiazujeDo = @DataObowiazywaniaDo
												WHERE Id = @TypObiektuCechaId AND (LastModifiedOn = @TypObiektuCechaLastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @TypObiektuCechaLastModifiedOn));
												
												IF @@ROWCOUNT < 1
												BEGIN
													----wystapil konflikt konkurencji - data ostaniej modyfikacji sie nie zgadza												
													INSERT INTO #TypyObiektowKonfliktowe(ID)
													VALUES(@Id);
														
													EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
													SET @Commit = 0;
												END
											END
											ELSE
											BEGIN
												INSERT INTO [TypObiektu_Cechy] (TypObiektu_ID, Cecha_ID, Importance, [Priority], UIOrder, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, 
													StatusW, StatusWFrom, StatusWFromBy, CreatedBy, CreatedOn, ValidFrom, RealCreatedOn, ObowiazujeOd, ObowiazujeDo, IsAlternativeHistory, IsMainHistFlow)
												VALUES(
													@PrzetwarzanyRekordId,
													@CechaId,
													@Importance,
													@Priority,
													@UIOrder,
													@StatusP, 
													CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
													CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
													@StatusS,
													CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
													CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
													@StatusW, 
													CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
													CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END, 
													@UzytkownikID,
													@DataModyfikacjiApp,
													@DataModyfikacjiApp,
													@DataModyfikacji,
													ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
													@DataObowiazywaniaDo,
													0,
													1
												);
											END
										END
										ELSE
										BEGIN
											--cecha dla typ obieku juz istnieje - dodanie danych do wartosci nieunikalnych										
											INSERT INTO #TypyObiektowNieUnikalne(ID)
											VALUES(@IstniejacyTypObiektuId);
												
											EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Cecha dla typu obiektu' , @Wiadomosc = @ERRMSG OUTPUT
											SET @Commit = 0;
										END
								
										FETCH NEXT FROM cur2 INTO @CouplerIndex, @TypObiektuCechaId, @CechaID, @Priority, @UIOrder, @Importance, @TypObiektuCechaLastModifiedOn
									END
									CLOSE cur2
									DEALLOCATE cur2
								END
							END
							ELSE
							BEGIN
								--typ obieku o podanej nazwie juz istnieje - dodanie danych do wartosci nieunikalnych						
								INSERT INTO #TypyObiektowNieUnikalne(ID)
								VALUES(@IstniejacyTypObiektuId);
									
								EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Typ obiektu' , @Wiadomosc = @ERRMSG OUTPUT
								SET @Commit = 0;
							END

--SELECT @ZmianaNazwyTypuObiektu AS ZmianaNazwy
						
							--zmiana nazwy tabel i triggerow jesli zieniono nazwe slownika
							IF @ZmianaNazwyTypuObiektu = 1 AND @Commit = 1
							BEGIN
								--zmiana nazwy tabeli
								DECLARE @OldN nvarchar(500) = '_' + @ObecnaNazwaTypuObiektu;
								DECLARE @NewN nvarchar(500) = '_' + @Nazwa;
								
								IF @OldN <> @NewN
									EXEC sp_rename @OldN, @NewN
														
								IF OBJECT_ID('[_' + @ObecnaNazwaTypuObiektu + '_Cechy_Hist]') IS NOT NULL
								BEGIN
									SET @OldN = '_' + @ObecnaNazwaTypuObiektu + '_Cechy_Hist'
									SET @NewN = '_' + @Nazwa + '_Cechy_Hist'
									
									IF @OldN <> @NewN
										EXEC sp_rename @OldN, @NewN
								END	
									
								IF OBJECT_ID('[_' + @ObecnaNazwaTypuObiektu + '_Relacje_Hist]') IS NOT NULL
								BEGIN	
									SET @OldN = '_' + @ObecnaNazwaTypuObiektu + '_Relacje_Hist'
									SET @NewN = '_' + @Nazwa + '_Relacje_Hist'
									
									IF @OldN <> @NewN
										EXEC sp_rename @OldN, @NewN
								END
					
								--zmiana trigerow jesli zmienila sie nazwa typu obiektu	
								EXEC [THB].[UpdateTriggersForUnitType] 
									@OldName = @ObecnaNazwaTypuObiektu, 
									@NewName = @Nazwa, 
									@UnitTypeId = @PrzetwarzanyRekordId
						
							END
						
							IF @IsTable = 1 AND @Commit = 1 AND @SaNoweCechy = 1
							BEGIN
		
								--zmiana trigera na update jesli typ tabelaryczny
								EXEC [THB].[UpdateTriggerForTableUnitType]
									@UnitTypeId = @PrzetwarzanyRekordId,
									@OldName = @ObecnaNazwaTypuObiektu,
									@NewName = @Nazwa
										
							END
						END
						ELSE
						BEGIN
							SET @ERRMSG = 'Błąd. Nie można zmienić typu obiektu zablokowanego do edycji.';
							BREAK;
						END	
					
						FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @IsTable, @IsArchive, @ArchivedBy, @LastModifiedOn				
					END
					CLOSE cur
					DEALLOCATE cur
				
					IF (SELECT COUNT(1) FROM #TypyObiektowKonfliktowe) > 0
					BEGIN						
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT tob.[TypObiekt_ID] AS "@Id"
										  ,tob.[Nazwa] AS "@Name"
										  ,tob.[IsBlocked] AS "@IsBlocked"
										  ,tob.[IsDeleted] AS "@IsDeleted"
										  ,tob.[DeletedFrom] AS "@DeletedFrom"
										  ,tob.[DeletedBy] AS "@DeletedBy"
										  ,tob.[CreatedOn] AS "@CreatedOn"
										  ,tob.[CreatedBy] AS "@CreatedBy"
										  ,ISNULL(tob.[LastModifiedOn], tob.[CreatedOn]) AS "@LastModifiedOn"
										  ,tob.[LastModifiedBy] AS "@LastModifiedBy"
										  ,tob.[ObowiazujeOd] AS "History/@EffectiveFrom"
										  ,tob.[ObowiazujeDo] AS "History/@EffectiveTo"
										  ,tob.[CzyPrzechowujeHistorie] AS "History/@IsMainHistFlow"
										  ,tob.[IsStatus] AS "Statuses/@IsStatus"
										  ,tob.[StatusS] AS "Statuses/@StatusS"
										  ,tob.[StatusSFrom] AS "Statuses/@StatusSFrom"
										  ,tob.[StatusSTo] AS "Statuses/@StatusSTo"
										  ,tob.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
										  ,tob.[StatusSToBy] AS "Statuses/@StatusSToBy"
										  ,tob.[StatusW] AS "Statuses/@StatusW"
										  ,tob.[StatusWFrom] AS "Statuses/@StatusWFrom"
										  ,tob.[StatusWTo] AS "Statuses/@StatusWTo"
										  ,tob.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
										  ,tob.[StatusWToBy] AS "Statuses/@StatusWToBy"
										  ,tob.[StatusP] AS "Statuses/@StatusP"
										  ,tob.[StatusPFrom] AS "Statuses/@StatusPFrom"
										  ,tob.[StatusPTo] AS "Statuses/@StatusPTo"
										  ,tob.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
										  ,tob.[StatusPToBy] AS "Statuses/@StatusPToBy"
										  , (SELECT toc.[Id] AS "@Id"
												,toc.[Cecha_ID] AS "@AttributeTypeId"
												,ISNULL(toc.[LastModifiedOn], toc.[CreatedOn]) AS "@LastModifiedOn"
												,toc.[Importance] AS "@Importance"
												,toc.[Priority] AS "@Priority"
												,toc.[UIOrder] AS "@UIOrder"
												FROM [TypObiektu_Cechy] toc
												WHERE toc.[TypObiektu_ID] = tob.[TypObiekt_ID]
												FOR XML PATH('CouplerAttributeType'), TYPE
												)							
									FROM [TypObiektu] tob
									WHERE TypObiekt_Id IN (SELECT DISTINCT ID FROM #TypyObiektowKonfliktowe)
									FOR XML PATH('UnitType')
								) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #TypyObiektowNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT tob.[TypObiekt_ID] AS "@Id"
										  ,tob.[Nazwa] AS "@Name"
										  ,tob.[IsBlocked] AS "@IsBlocked"
										  ,tob.[IsDeleted] AS "@IsDeleted"
										  ,tob.[DeletedFrom] AS "@DeletedFrom"
										  ,tob.[DeletedBy] AS "@DeletedBy"
										  ,tob.[CreatedOn] AS "@CreatedOn"
										  ,tob.[CreatedBy] AS "@CreatedBy"
										  ,ISNULL(tob.[LastModifiedOn], tob.[CreatedOn]) AS "@LastModifiedOn"
										  ,tob.[LastModifiedBy] AS "@LastModifiedBy"
										  ,tob.[ObowiazujeOd] AS "History/@EffectiveFrom"
										  ,tob.[ObowiazujeDo] AS "History/@EffectiveTo"
										  ,tob.[CzyPrzechowujeHistorie] AS "History/@IsMainHistFlow"
										  ,tob.[IsStatus] AS "Statuses/@IsStatus"
										  ,tob.[StatusS] AS "Statuses/@StatusS"
										  ,tob.[StatusSFrom] AS "Statuses/@StatusSFrom"
										  ,tob.[StatusSTo] AS "Statuses/@StatusSTo"
										  ,tob.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
										  ,tob.[StatusSToBy] AS "Statuses/@StatusSToBy"
										  ,tob.[StatusW] AS "Statuses/@StatusW"
										  ,tob.[StatusWFrom] AS "Statuses/@StatusWFrom"
										  ,tob.[StatusWTo] AS "Statuses/@StatusWTo"
										  ,tob.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
										  ,tob.[StatusWToBy] AS "Statuses/@StatusWToBy"
										  ,tob.[StatusP] AS "Statuses/@StatusP"
										  ,tob.[StatusPFrom] AS "Statuses/@StatusPFrom"
										  ,tob.[StatusPTo] AS "Statuses/@StatusPTo"
										  ,tob.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
										  ,tob.[StatusPToBy] AS "Statuses/@StatusPToBy"
										  , (SELECT toc.[Id] AS "@Id"
												,toc.[Cecha_ID] AS "@AttributeTypeId"
												,ISNULL(toc.[LastModifiedOn], toc.[CreatedOn]) AS "@LastModifiedOn"
												,toc.[Importance] AS "@Importance"
												,toc.[Priority] AS "@Priority"
												,toc.[UIOrder] AS "@UIOrder"
												FROM [TypObiektu_Cechy] toc
												WHERE toc.[TypObiektu_ID] = tob.[TypObiekt_ID]
												FOR XML PATH('CouplerAttributeType'), TYPE
												)							
										FROM [TypObiektu] tob
										WHERE TypObiekt_Id IN (SELECT DISTINCT Id FROM #TypyObiektowNieUnikalne)
										FOR XML PATH('UnitType')
									) AS nvarchar(MAX)), '');
					END
					
					IF @Commit = 1
						COMMIT TRAN T1_UnitTypes_Save
					ELSE
						ROLLBACK TRAN T1_UnitTypes_Save
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_UnitTypes_Save
		END
	END CATCH 
	
	--przygotowanie XMLa wyjsciowego		
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitTypes_Save"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
		
	IF @ERRMSG iS NULL OR @ERRMSG = '' 	
	BEGIN
		IF (SELECT COUNT(1) FROM #IdZmienionych) > 0
		BEGIN
				SET @XMLDataOut += ISNULL(CAST( 
				(SELECT TOP 1
					(SELECT ID AS '@Id',
					'UnitType' AS '@EntityType'
					FROM #IDZmienionych
					FOR XML PATH('Ref'), ROOT('Value'), TYPE
					)
				FROM #IDZmienionych
				FOR XML PATH('Result')
				) AS nvarchar(MAX)), '');
		END
		ELSE
			SET @XMLDataOut += '<Result><Value/></Result>';
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '">'

		--dodawanie danych rekordow nie zapisanych z powodu konkurencji
		IF @xmlErrorConcurrency IS NOT NULL AND LEN(@xmlErrorConcurrency) > 3
		BEGIN
			SET @XMLDataOut += '<ConcurrencyConflicts>' + @xmlErrorConcurrency + '</ConcurrencyConflicts>';
		END
		
		--dodawanie danych rekordow nie zapisanych z powodu konfliktow
		IF @xmlErrorsUnique IS NOT NULL AND LEN(@xmlErrorsUnique) > 3
		BEGIN
			SET @XMLDataOut += '<UniquenessConflicts>' + @xmlErrorsUnique + '</UniquenessConflicts>';
		END
		
		SET @XMLDataOut += '</Error></Result>';
	END		
	
	SET @XMLDataOut += '</Response>';	
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#TypyObiektowDoZapisania') IS NOT NULL
		DROP TABLE #TypyObiektowDoZapisania
		
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
		
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
		
	IF OBJECT_ID('tempdb..#CechyTypuObiektu') IS NOT NULL
		DROP TABLE #CechyTypuObiektu
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#TypyObiektowKonfliktowe') IS NOT NULL
		DROP TABLE #TypyObiektowKonfliktowe
			
	IF OBJECT_ID('tempdb..#TypyObiektowNieUnikalne') IS NOT NULL
		DROP TABLE #TypyObiektowNieUnikalne
		
	IF OBJECT_ID('tempdb..#StatusyCechTypuObiektu') IS NOT NULL
		DROP TABLE #StatusyCechTypuObiektu	
		
	IF OBJECT_ID('tempdb..#HistoriaCechTypuObiektu') IS NOT NULL
		DROP TABLE #HistoriaCechTypuObiektu	
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
			
END
