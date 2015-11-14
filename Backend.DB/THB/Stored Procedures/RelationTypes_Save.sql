-- =============================================
-- Author:		DK
-- Create date: 2012-03-19
-- Last modified on: 2013-02-14
-- Description:	Zapisuje dane typu relacji (tabela typ relacji). Aktualizuje istniejacy rekord lub wstawia nowy rekord.

-- XML wejsciowy w postaci:

	--<Request RequestType="RelationTypes_Save" UserId="1" AppDate="2012-02-09T12:45:22"
	--	xsi:noNamespaceSchemaLocation="11.3.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		
	--	<RelationType Id="1" Name="efew" TypeId="45"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121" ChangeTo="2012-02-09T12:12:12.121" EffectiveFrom="2012-02-09T12:12:12.121" EffectiveTo="2012-02-09T12:12:12.121" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121" StatusSTo="2012-02-09T12:12:12.121" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121" StatusWTo="2012-02-09T12:12:12.121" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121" StatusPTo="2012-02-09T12:12:12.121" StatusPFromBy="1" StatusPToBy="1" />
	--		<RelationBaseType Id="45" Name="weqwee" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121" LastModifiedBy="1" />
	--		<CouplerAttributeType Id="1" Importance="1" AttributeTypeId="3" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="0" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="0" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="0" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="0" Priority="1" UIOrder="3">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			<AttributeType Id="1" Name="?" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0" IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z"/>
	--		</CouplerAttributeType>
	--	</RelationType>
		
	--	<RelationType Id="2" Name="efew2" TypeId="45"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121" ChangeTo="2012-02-09T12:12:12.121" EffectiveFrom="2012-02-09T12:12:12.121" EffectiveTo="2012-02-09T12:12:12.121" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121" StatusSTo="2012-02-09T12:12:12.121" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121" StatusWTo="2012-02-09T12:12:12.121" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121" StatusPTo="2012-02-09T12:12:12.121" StatusPFromBy="1" StatusPToBy="1" />
	--		<RelationBaseType Id="45" Name="weqwee" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121" LastModifiedBy="1" />
	--		<CouplerAttributeType Id="1" Importance="2" AttributeTypeId="3" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121" ArchivedBy="0" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121" DeletedBy="0" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="0" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="0" Priority="1" UIOrder="3">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--			<AttributeType Id="1" Name="?" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0" IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z"/>
	--		</CouplerAttributeType>
	--	</RelationType>
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="RelationTypes_Save" AppDate="2012-02-09" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="RelationType" />
	--			<Ref Id="2" EntityType="RelationType" />
	--			<Ref Id="3" EntityType="RelationType" />
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[RelationTypes_Save]
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
		@xmlOk bit,
		@xml_data xml,
		@BranzaID int,
		@Id int,
		@Nazwa nvarchar(64),
		@Index int,
		@BazowyTypRelacjiId int,
		@LastModifiedOn datetime,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@PrzetwarzanyTypRelacjiId int,
		@Skip bit = 0,
		@TypRelacji_CechaId int,
		@CechaId int,
		@Priority int,
		@UIOrder int,	
		@IsArchive bit,
		@ArchivedBy int,	
		@IloscTypowRelacji int = 0,
		@LicznikTypowRelacji int = 0,
		@IloscCechRelacji int = 0,
		@Query nvarchar(MAX) = '',
		@MaUprawnienia bit = 0,
		@Commit bit = 1,
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacyTypRelacjiId int,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@IsStatus bit,
		@StatusP int,
		@StatusW int,
		@StatusS int,
		@IsAlternativeHistory bit,
		@IsMainHistFlow bit,
		@CouplerIndex int,
		@Importance smallint

	BEGIN TRY
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_RelationTypes_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
				
			--usuwanie tabel tymczasowych, jesli istnieja
			IF OBJECT_ID('tempdb..#TypyRelacji') IS NOT NULL
				DROP TABLE #TypyRelacji
				
			IF OBJECT_ID('tempdb..#TypyBazowe') IS NOT NULL
				DROP TABLE #TypyBazowe
				
			IF OBJECT_ID('tempdb..#CechyTypuRelacji') IS NOT NULL
				DROP TABLE #CechyTypuRelacji
				
			IF OBJECT_ID('tempdb..#DaneCechyTypuRelacji') IS NOT NULL
				DROP TABLE #DaneCechyTypuRelacji
				
			IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
				DROP TABLE #Historia
			
			IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
				DROP TABLE #Statusy
				
			IF OBJECT_ID('tempdb..#HistoriaCech') IS NOT NULL
				DROP TABLE #HistoriaCech
			
			IF OBJECT_ID('tempdb..#StatusyCech') IS NOT NULL
				DROP TABLE #StatusyCech
				
			IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
				DROP TABLE #IDZmienionych
				
			IF OBJECT_ID('tempdb..#TypyRelacjiKonfliktowe') IS NOT NULL
				DROP TABLE #TypyRelacjiKonfliktowe
			
			IF OBJECT_ID('tempdb..#TypyRelacjiNieUnikalne') IS NOT NULL
				DROP TABLE #TypyRelacjiNieUnikalne
				
			CREATE TABLE #TypyRelacjiKonfliktowe(ID int);	
			CREATE TABLE #TypyRelacjiNieUnikalne(ID int);				
			CREATE TABLE #IDZmienionych (ID int);
			
			CREATE TABLE #StatusyCech (RootIndex int, CouplerIndex int, IsStatus bit, StatusP int, StatusPFrom datetime, StatusPTo datetime,
				StatusPFromBy int, StatusPToBy int, StatusS int, StatusSFrom datetime, StatusSTo datetime, StatusSFromBy int, StatusSToBy int,
				StatusW int, StatusWFrom datetime, StatusWTo datetime, StatusWFromBy int, StatusWToBy int);
			
			CREATE TABLE #HistoriaCech (RootIndex int, CouplerIndex int, ZmianaOd datetime, ZmianaDo datetime, DataObowiazywaniaOd datetime, DataObowiazywaniaDo datetime,
				IsAlternativeHistory bit, IsMainHistFlow bit);
				
			CREATE TABLE #CechyTypuRelacji (RootIndex int, [Index] int, Id int, Cecha_ID int, IsArchive bit, ArchivedFrom datetime, ArchivedBy int, IsDeleted bit, DeletedFrom datetime,
					DeletedBy int, CreatedOn datetime, [Priority] int, UIOrder int, Importance smallint, LastModifiedOn datetime);
					
			CREATE TABLE #DaneCechyTypuRelacji(RootIndex int, [Index] int, Id int, Nazwa nvarchar(50), NazwaSkrocona nvarchar(50), Hint nvarchar(200), Opis nvarchar(500), TypID int,
					CzySlownik bit, CzyWymagana bit, CzyPusta bit, CzyWyliczana bit, CzyPrzetwarzana bit, CzyFiltrowana bit, CzyJestDanaOsobowa bit, CzyCechaUzytkownika bit, LastModifiedOn datetime);
			
			
			--pobranie ilosci typow relacji do zapisu
			SET @IloscTypowRelacji = (SELECT @xml_data.value('count(/Request/RelationType)','int') )

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);
		
			--odczytywanie danych typow relacji
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowRelacji
			)
			SELECT 	j AS 'Index'
				   ,x.value('./@Id', 'int') AS Id
				   ,x.value('./@Name', 'nvarchar(256)') AS Nazwa
				   ,x.value('./@TypeId', 'int') AS BazowyTypRelacji_Id
				   ,x.value('./@IsArchive', 'bit') AS IsArchive
				   ,x.value('./@ArchivedFrom', 'datetime') AS ArchivedFrom
				   ,x.value('./@ArchivedBy', 'int') AS ArchivedBy
				   ,x.value('./@DeletedFrom', 'datetime') AS DeletedFrom
				   ,x.value('./@DeletedBy', 'int') AS DeletedBy
				   ,x.value('./@IsDeleted', 'bit') AS IsDeleted
				   ,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				  -- ,x.value('./@LastModifiedBy', 'int') AS LastModifiedBy
				   --,x.value('./@CreatedOn', 'datetime') AS CreatedOn
				   --,x.value('./@CreatedBy', 'int') AS CreatedBy
			INTO #TypyRelacji
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/RelationType[position()=sql:column("j")]')  e(x);
				
			--odczytywanie danych typu bazowego dla typu relacji	
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowRelacji
			)
			SELECT j AS 'RootIndex'
				,x.value('./@Id','int') AS Id
				,x.value('./@Name', 'nvarchar(64)') AS Nazwa
				,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
			INTO #TypyBazowe
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/RelationType[position()=sql:column("j")]/RelationBaseType')  e(x);
			
			--odczytywanie statusow
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowRelacji
			)
			SELECT j AS 'RootIndex'
				,x.value('../@Id','int') AS Id
				,x.value('./@IsStatus', 'bit') AS IsStatus
				,x.value('./@StatusP', 'int') AS StatusP  
				,x.value('./@StatusPFrom', 'datetime') AS StatusPFrom 
				,x.value('./@StatusPTo', 'datetime') AS StatusPTo
				,x.value('./@StatusPFromBy', 'int') AS StatusPFromBy
				,x.value('./@StatusPToBy', 'int') AS StatusPToBy
				,x.value('./@StatusS', 'int') AS StatusS
				,x.value('./@StatusSFrom', 'datetime') AS StatusSFrom
				,x.value('./@StatusSTo', 'datetime') AS StatusSTo
				,x.value('./@StatusSFromBy', 'int') AS StatusSFromBy
				,x.value('./@StatusSToBy', 'int') AS StatusSToBy
				,x.value('./@StatusW', 'int') AS StatusW
				,x.value('./@StatusWFrom', 'datetime') AS StatusWFrom 
				,x.value('./@StatusWTo', 'datetime') AS StatusWTo
				,x.value('./@StatusWFromBy', 'int') AS StatusWFromBy
				,x.value('./@StatusWToBy', 'int') AS StatusWToBy
			INTO #Statusy
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/RelationType[position()=sql:column("j")]/Statuses')  e(x);
			
			--odczytywanie historii
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < @IloscTypowRelacji
			)
			SELECT j AS 'RootIndex'
				,x.value('../@Id','int') AS Id
				,x.value('./@ChangeFrom', 'datetime') AS ZmianaOd 
				,x.value('./@ChangeTo', 'datetime') AS ZmianaDo
				,x.value('./@EffectiveFrom', 'datetime') AS DataObowiazywaniaOd
				,x.value('./@EffectiveTo', 'datetime') AS DataObowiazywaniaDo
				,x.value('./@IsAlternativeHistory', 'bit') AS IsAlternativeHistory
				,x.value('./@IsMainHistFlow', 'bit') AS IsMainHistFlow
			INTO #Historia 
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/RelationType[position()=sql:column("j")]/History')  e(x);				
			

			SET @LicznikTypowRelacji = 0;
						
			WHILE @LicznikTypowRelacji <= @IloscTypowRelacji
			BEGIN
							
				SET @Query = 'SET @TmpIloscCechRelacji = (SELECT @xml_data.value(''count(/Request/RelationType[position()=' + CAST(@LicznikTypowRelacji AS varchar) + ']/CouplerAttributeType)'',''int'') )';
				EXEC sp_executesql @Query, N'@xml_data xml, @TmpIloscCechRelacji int OUTPUT', @xml_data = @xml_data, @TmpIloscCechRelacji = @IloscCechRelacji OUTPUT
				
				--odczytywanie danych cechy
				SET @Query = '
					WITH Num2(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num2
					   WHERE j < ' + CAST(@IloscCechRelacji AS varchar) + ' 
					)	
						
					INSERT INTO #CechyTypuRelacji (RootIndex, [Index], Id, Cecha_ID, IsArchive, ArchivedFrom,  ArchivedBy, IsDeleted, DeletedFrom, DeletedBy, CreatedOn, [Priority], UIOrder, Importance, LastModifiedOn)
					SELECT ' + CAST(@LicznikTypowRelacji AS varchar) + '
						,j					
						,x.value(''./@Id'',''int'')
						,x.value(''./@AttributeTypeId'', ''int'')
						,x.value(''./@IsArchive'', ''bit'')
						,x.value(''./@ArchivedFrom'', ''datetime'')
						,x.value(''./@ArchivedBy'', ''int'')
						,x.value(''./@IsDeleted'', ''bit'')				
						,x.value(''./@DeletedFrom'', ''datetime'')
						,x.value(''./@DeletedBy'', ''int'')
						,x.value(''./@CreatedOn'', ''datetime'')
						,x.value(''./@Priority'', ''int'')
						,x.value(''./@UIOrder'', ''int'')
						,x.value(''./@Importance'', ''smallint'')
						,x.value(''./@LastModifiedOn'', ''datetime'')
					FROM Num2
					CROSS APPLY @xml_data.nodes(''/Request/RelationType[position()=' + CAST(@LicznikTypowRelacji AS varchar) + ']/CouplerAttributeType[position()=sql:column("j")]'')  e(x);	
				';

				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				--odczytywanie poddanych cechy - typ cechy				
				SET @Query = '
					WITH Num2(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num2
					   WHERE j < ' + CAST(@IloscCechRelacji AS varchar) + ' 
					)	
					INSERT INTO #DaneCechyTypuRelacji(RootIndex, [Index], Id, Nazwa, NazwaSkrocona, Hint, Opis, TypID, CzySlownik, CzyWymagana, CzyPusta, CzyWyliczana, CzyPrzetwarzana, CzyFiltrowana, CzyJestDanaOsobowa, CzyCechaUzytkownika, LastModifiedOn)
					SELECT ' + CAST(@LicznikTypowRelacji AS varchar) + '
						,j					
						,x.value(''./@Id'',''int'')
						,x.value(''./@Name'', ''nvarchar(50)'')
						,x.value(''./@ShortName'', ''nvarchar(50)'')
						,x.value(''./@Hint'', ''nvarchar(200)'')
						,x.value(''./@Description'', ''nvarchar(500)'')
						,x.value(''./@TypeId'', ''int'')				
						,x.value(''./@IsDictionary'', ''bit'')
						,x.value(''./@IsRequired'', ''bit'')
						,x.value(''./@IsEmpty'', ''bit'')
						,x.value(''./@IsQuantifiable'', ''bit'')
						,x.value(''./@IsProcessed'', ''bit'')							
						,x.value(''./@IsFiltered'', ''bit'')
						,x.value(''./@IsPersonalData'', ''bit'')
						,x.value(''./@IsUserAttribute'', ''bit'')							
						,x.value(''./@LastModifiedOn'', ''datetime'')
					FROM Num2
					CROSS APPLY @xml_data.nodes(''/Request/RelationType[position()=' + CAST(@LicznikTypowRelacji AS varchar) + ']/CouplerAttributeType[position()=sql:column("j")]/AttributeType'')  e(x);	
				';

				--PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
				--pobranie statusow
				SET @Query = '
					WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < ' + CAST(@IloscCechRelacji AS varchar) + '
					)							
					INSERT INTO #StatusyCech (RootIndex, CouplerIndex, IsStatus, StatusP, StatusPFrom, StatusPTo, StatusPFromBy, StatusPToBy, StatusS, StatusSFrom, 
						StatusSTo, StatusSFromBy, StatusSToBy, StatusW, StatusWFrom, StatusWTo, StatusWFromBy, StatusWToBy)
					SELECT ' + CAST(@LicznikTypowRelacji AS varchar) + '
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
					CROSS APPLY @xml_data.nodes(''/Request/RelationType[position()=' + CAST(@LicznikTypowRelacji AS varchar) + ']/CouplerAttributeType[position()=sql:column("j")]/Statuses'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data					
				
				--odczytywanie danych zmian dla typu relacji
				SET @Query = '
					WITH Num(j)
					AS
					(
					   SELECT 1
					   UNION ALL
					   SELECT j + 1
					   FROM Num
					   WHERE j < ' + CAST(@IloscCechRelacji AS varchar) + '
					)	
						
					INSERT INTO #HistoriaCech (RootIndex, CouplerIndex, ZmianaOd, ZmianaDo, DataObowiazywaniaOd, DataObowiazywaniaDo, IsAlternativeHistory, IsMainHistFlow)
					SELECT ' + CAST(@LicznikTypowRelacji AS varchar) + '
							, j
							,x.value(''./@ChangeFrom'', ''datetime'') 
							,x.value(''./@ChangeTo'', ''datetime'')
							,x.value(''./@EffectiveFrom'', ''datetime'')
							,x.value(''./@EffectiveTo'', ''datetime'')
							,x.value(''./@IsAlternativeHistory'', ''bit'')
							,x.value(''./@IsMainHistFlow'', ''bit'')
					FROM Num
					CROSS APPLY @xml_data.nodes(''/Request/RelationType[position()=' + CAST(@LicznikTypowRelacji AS varchar) + ']/CouplerAttributeType[position()=sql:column("j")]/History'')  e(x);	
					';

			--	PRINT @Query
				EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data	
								
			
				SET @LicznikTypowRelacji = @LicznikTypowRelacji + 1; 			
			END					
			
			--SELECT * FROM #TypyRelacji;
			--SELECT * FROM #TypyBazowe;
			--SELECT * FROM #CechyTypuRelacji;
			--SELECT * FROM #DaneCechyTypuRelacji;
			--SELECT * FROM #Statusy;
			--SELECT * FROM #Historia;
			--SELECT * FROM #HistoriaCech;
			--SELECT * FROM #StatusyCech;
			--SELECT @DataProgramu, @UzytkownikID, @RequestType

			IF @RequestType = 'RelationTypes_Save'
			BEGIN 
				
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);				
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji save
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					BEGIN TRAN T1_RelationTypes_Save
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
					
					DECLARE cur CURSOR LOCAL FOR 
						SELECT [Index], Id, Nazwa, BazowyTypRelacji_Id, IsArchive, ArchivedBy, LastModifiedOn FROM #TypyRelacji
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @BazowyTypRelacjiId, @IsArchive, @ArchivedBy, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--wyzerowanie zmiennych, potrzebne!
						SET @Skip = 0;
						SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
						SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL, @IsAlternativeHistory = 0, @IsMainHistFlow = 0;
						
						--pobranie danych historii
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
						@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
						FROM #Historia WHERE RootIndex = @Index;
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index;
						
-- pole obecnie nie uzywane		
SET @DataObowiazywaniaDo = NULL
						
						SET @IstniejacyTypRelacjiId = (SELECT TypRelacji_ID FROM dbo.[TypRelacji] WHERE TypRelacji_ID <> @Id AND Nazwa = @Nazwa AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0)
						
						IF @IstniejacyTypRelacjiId IS NULL
						BEGIN
							IF EXISTS (SELECT TypRelacji_ID FROM dbo.[TypRelacji] WHERE TypRelacji_ID = @Id)
							BEGIN

								--aktualizacja danych typu relacji
								UPDATE dbo.[TypRelacji] SET
								BazowyTypRelacji_Id = @BazowyTypRelacjiId,
								Nazwa = ISNULL(@Nazwa, 'Bez nazwy'),
								--StatusA = CAST(@BazowyTypRelacjiId AS varchar(3)),
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
								LastModifiedBy = @UzytkownikId,
								RealLastModifiedOn = @DataModyfikacji,
								ValidFrom = @DataModyfikacjiApp,
								ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
								ObowiazujeDo = @DataObowiazywaniaDo
								WHERE TypRelacji_ID = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanyTypRelacjiId = @Id;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanyTypRelacjiId);
								END
								ELSE
								BEGIN
									INSERT INTO #TypyRelacjiKonfliktowe(ID)
									VALUES(@Id);
										
									EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
									SET @Commit = 0;
									SET @Skip = 1;
								END
							END
							ELSE
							BEGIN						
							
								--wstawienie nowego typu relacji ile juz taki nie istnieje (o podanej nazwie i typie bazowym)
								IF NOT EXISTS (SELECT TypRelacji_ID FROM dbo.[TypRelacji] WHERE Nazwa = @Nazwa AND IdArch IS NULL AND IsValid = 1 AND BazowyTypRelacji_Id = @BazowyTypRelacjiId)
								BEGIN
									INSERT INTO dbo.[TypRelacji] (IdArch, Nazwa, BazowyTypRelacji_Id, StatusA, CreatedBy, CreatedOn, ValidFrom, IsStatus, 
									StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy,
									RealCreatedOn, ObowiazujeOd, ObowiazujeDo, IsAlternativeHistory, IsMainHistFlow) VALUES 
									(NULL, @Nazwa, @BazowyTypRelacjiId, CAST(@BazowyTypRelacjiId AS varchar(3)), @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacjiApp,
									ISNULL(@IsStatus, 0),							
									@StatusP, 
									CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
									CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
									@StatusS,
									CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
									CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
									@StatusW, 
									CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
									CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
									@DataModyfikacji,
									ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
									@DataObowiazywaniaDo,
									0,
									1);
									
									IF @@ROWCOUNT > 0
									BEGIN
										SET @PrzetwarzanyTypRelacjiId = @@IDENTITY;
										INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanyTypRelacjiId);
									END
								END
								ELSE
								BEGIN
									SET @Skip = 1;
								END
							END
				
							--przetwarzanie cech typu relacji
							IF @Skip = 0
							BEGIN
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local', 'cur2') > 0 
								BEGIN
									 CLOSE cur2
									 DEALLOCATE cur2
								END

								DECLARE cur2 CURSOR LOCAL FOR 
									SELECT [Index], Id, Cecha_ID, IsArchive, ArchivedBy, [Priority], UIOrder, Importance, LastModifiedOn FROM #CechyTypuRelacji WHERE RootIndex = @Index
								OPEN cur2
								FETCH NEXT FROM cur2 INTO @CouplerIndex, @TypRelacji_CechaId, @CechaId, @IsArchive, @ArchivedBy, @Priority, @UIOrder, @Importance, @LastModifiedOn
								WHILE @@FETCH_STATUS = 0
								BEGIN				
									
									--wyzerowanie zmiennych
									SELECT @IsStatus = 0, @StatusP = NULL, @StatusS = NULL, @StatusW = NULL;
									SELECT @ZmianaOd = NULL, @ZmianaDo = NULL, @DataObowiazywaniaOd = NULL, @DataObowiazywaniaDo = NULL, @IsAlternativeHistory = 0, @IsMainHistFlow = 0;
									
									--pobranie danych statusow
									SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
									FROM #StatusyCech WHERE RootIndex = @Index AND CouplerIndex = @CouplerIndex;	
									
									--pobranie danych historii
									SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
									@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
									FROM #HistoriaCech WHERE RootIndex = @Index AND CouplerIndex = @CouplerIndex;
										
									IF NOT EXISTS (SELECT ID FROM TypRelacji_Cechy WHERE IdArch IS NULL AND Id <> @TypRelacji_CechaId AND TypRelacji_Id = @PrzetwarzanyTypRelacjiId AND Cecha_ID = @CechaId AND IsValid = 1)
									BEGIN
										--sprawdzenie czy istnieje cecha o podanym Id i czasie ostatniej aktualizacji - dla wyeliminowania kolizji				
										IF EXISTS (SELECT Id FROM dbo.[TypRelacji_Cechy] WHERE Id = @TypRelacji_CechaId)
										BEGIN
											UPDATE dbo.[TypRelacji_Cechy] SET
											Cecha_ID = @CechaId,
											[Priority] = @Priority,
											UIOrder = @UIOrder,
											Importance = @Importance,
											ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
											ObowiazujeDo = @DataObowiazywaniaDo,
											LastModifiedOn = @DataModyfikacjiApp,
											LastModifiedBy = @UzytkownikId,
											ValidFrom = @DataModyfikacjiApp,
											RealLastModifiedOn = @DataModyfikacji,
											StatusP = @StatusP,								
											StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
											StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
											StatusS = @StatusS,								
											StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
											StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
											StatusW = @StatusW,
											StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
											StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
											IsStatus = ISNULL(@IsStatus, 0)
											WHERE Id = @TypRelacji_CechaId AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
											
											IF @@ROWCOUNT < 1
											BEGIN
												INSERT INTO #TypyRelacjiKonfliktowe(ID)
												VALUES(@PrzetwarzanyTypRelacjiId);
													
												EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
												SET @Commit = 0;
											END
											
										END
										ELSE
										BEGIN								
											INSERT INTO [TypRelacji_Cechy] (TypRelacji_Id, Cecha_ID, [Priority], UIOrder, Importance, ObowiazujeOd, ObowiazujeDo, CreatedBy, IsValid, CreatedOn, ValidFrom,
											IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy, RealCreatedOn, IsAlternativeHistory, IsMainHistFlow)
											VALUES (@PrzetwarzanyTypRelacjiId, @CechaId, @Priority, @UIOrder, @Importance, ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
												@DataObowiazywaniaDo, 
												@UzytkownikId, 1, @DataModyfikacjiApp, @DataModyfikacjiApp,
												ISNULL(@IsStatus, 0),
												@StatusP, 
												CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
												CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
												@StatusS,
												CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
												CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
												@StatusW, 
												CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
												CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
												@DataModyfikacji,
												0,
												1);								
										END
									END
									ELSE
									BEGIN
										INSERT INTO #TypyRelacjiNieUnikalne(ID)
										VALUES(@PrzetwarzanyTypRelacjiId);
										
										EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Cecha dla typu relacji' , @Wiadomosc = @ERRMSG OUTPUT
										SET @Commit = 0;
									END						
									
									FETCH NEXT FROM cur2 INTO @CouplerIndex, @TypRelacji_CechaId, @CechaId, @IsArchive, @ArchivedBy, @Priority, @UIOrder, @Importance, @LastModifiedOn
								END
								CLOSE cur2
								DEALLOCATE cur2
							END
						END
						ELSE
						BEGIN
							INSERT INTO #TypyRelacjiNieUnikalne(ID)
							VALUES(@IstniejacyTypRelacjiId);
							
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Typ relacji' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
						END
						
						FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @BazowyTypRelacjiId, @IsArchive, @ArchivedBy, @LastModifiedOn
						
					END
					CLOSE cur
					DEALLOCATE cur
					
					--	SELECT * FROM #TypyRelacjiKonfliktowe;	
					--	SELECT * FROM #TypyRelacjiNieUnikalne;
					--SELECT * FROM #IDZmienionych
					--SELECT * FROM #IDZmienionychPrzelicznikow
					
					IF (SELECT COUNT(1) FROM #TypyRelacjiKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT tr.[TypRelacji_ID] AS "@Id"
										  ,tr.[Nazwa] AS "@Name"
										  ,tr.[BazowyTypRelacji_Id] AS "@TypeId"
										  ,tr.[IsDeleted] AS "@IsDeleted"
										  ,tr.[DeletedFrom] AS "@DeletedFrom"
										  ,tr.[DeletedBy] AS "@DeletedBy"
										  ,tr.[CreatedOn] AS "@CreatedOn"
										  ,tr.[CreatedBy] AS "@CreatedBy"
										  ,ISNULL(tr.[LastModifiedOn], ISNULL(tr.[CreatedOn], '')) AS "@LastModifiedOn"
										  ,tr.[LastModifiedBy] AS "@LastModifiedBy"
										  ,tr.[ObowiazujeOd] AS "History/@EffectiveFrom"
										  ,tr.[ObowiazujeDo] AS "History/@EffectiveTo"
										  ,tr.[IsMainHistFlow] AS "History/@IsMainHistFlow"
										  ,tr.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
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
										  ,tr.[StatusPToBy] AS "Statuses/@StatusPToBy"
										  , (SELECT rt.[Id] AS "@Id"
												,rt.[Nazwa] AS "@Name"
												,rt.[IsDeleted] AS "@IsDeleted"
												,rt.[DeletedFrom] AS "@DeletedFrom"
												,rt.[DeletedBy] AS "@DeletedBy"
												,rt.[CreatedOn] AS "@CreatedOn"
												,rt.[CreatedBy] AS "@CreatedBy"
												,rt.[LastModifiedBy] AS "@LastModifiedBy"
												,ISNULL(rt.[LastModifiedOn], rt.[CreatedOn]) AS "@LastModifiedOn"
												FROM [Relacja_Typ] rt
												WHERE rt.Id = tr.BazowyTypRelacji_Id
												FOR XML PATH('RelationBaseType'), TYPE
											)				
											, (SELECT trc.[Id] AS "@Id"
												,trc.[Cecha_ID] AS "@AttributeTypeId"
												,trc.[Priority] AS "@Priority"
												,trc.[UIOrder] AS "@UIOrder"
												,trc.[Importance] AS "@Importance"
												,trc.[IsDeleted] AS "@IsDeleted"
												,trc.[DeletedFrom] AS "@DeletedFrom"
												,trc.[DeletedBy] AS "@DeletedBy"
												,trc.[CreatedOn] AS "@CreatedOn"
												,trc.[CreatedBy] AS "@CreatedBy"
												,ISNULL(trc.[LastModifiedOn], ISNULL(trc.[CreatedOn], '')) AS "@LastModifiedOn"
												,trc.[LastModifiedBy] AS "@LastModifiedBy"
												,trc.[ObowiazujeOd] AS "History/@EffectiveFrom"
												,trc.[ObowiazujeDo] AS "History/@EffectiveTo"
												,trc.[IsMainHistFlow] AS "History/@IsMainHistFlow"
												,trc.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
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
												, (SELECT c.[Cecha_ID] AS "@Id"
															,c.[Nazwa] AS "@Name"
															,c.[NazwaSkrocona] AS "@ShortName"
															,c.[Hint] AS "@Hint"
															,c.[Opis] AS "@Description"
															,c.[TypID] AS "@TypeId"
															,c.[CzySlownik] AS "@IsDictionary"
															,c.[CzyWymagana] AS "@IsRequired"
															,c.[CzyPusta] AS "@IsEmpty"
															,c.[CzyWyliczana] AS "@IsQuantifiable"
															,c.[CzyPrzetwarzana] AS "@IsProcessed"
															,c.[CzyFiltrowana] AS "@IsFiltered"
															,c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
															,c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
															,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
															FROM [Cechy] c
															WHERE c.Cecha_ID = trc.Cecha_ID
															FOR XML PATH('AttributeType'), TYPE
													)
												FROM [TypRelacji_Cechy] trc
												WHERE trc.TypRelacji_ID = tr.TypRelacji_ID
												FOR XML PATH('CouplerAttributeType'), TYPE
												)							
							FROM [TypRelacji] tr
							WHERE TypRelacji_ID IN (SELECT ID FROM #TypyRelacjiKonfliktowe)
							FOR XML PATH('RelationType')
						) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #TypyRelacjiNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT tr.[TypRelacji_ID] AS "@Id"
										  ,tr.[Nazwa] AS "@Name"
										  ,tr.[BazowyTypRelacji_Id] AS "@TypeId"
										  ,tr.[IsDeleted] AS "@IsDeleted"
										  ,tr.[DeletedFrom] AS "@DeletedFrom"
										  ,tr.[DeletedBy] AS "@DeletedBy"
										  ,tr.[CreatedOn] AS "@CreatedOn"
										  ,tr.[CreatedBy] AS "@CreatedBy"
										  ,ISNULL(tr.[LastModifiedOn], ISNULL(tr.[CreatedOn], '')) AS "@LastModifiedOn"
										  ,tr.[LastModifiedBy] AS "@LastModifiedBy"
										  ,tr.[ObowiazujeOd] AS "History/@EffectiveFrom"
										  ,tr.[ObowiazujeDo] AS "History/@EffectiveTo"
										  ,tr.[IsMainHistFlow] AS "History/@IsMainHistFlow"
										  ,tr.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
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
										  ,tr.[StatusPToBy] AS "Statuses/@StatusPToBy"
										  , (SELECT rt.[Id] AS "@Id"
												,rt.[Nazwa] AS "@Name"
												,rt.[IsDeleted] AS "@IsDeleted"
												,rt.[DeletedFrom] AS "@DeletedFrom"
												,rt.[DeletedBy] AS "@DeletedBy"
												,rt.[CreatedOn] AS "@CreatedOn"
												,rt.[CreatedBy] AS "@CreatedBy"
												,rt.[LastModifiedBy] AS "@LastModifiedBy"
												,ISNULL(rt.[LastModifiedOn], rt.[CreatedOn]) AS "@LastModifiedOn"
												FROM [Relacja_Typ] rt
												WHERE rt.Id = tr.BazowyTypRelacji_Id
												FOR XML PATH('RelationBaseType'), TYPE
											)				
											, (SELECT trc.[Id] AS "@Id"
												,trc.[Cecha_ID] AS "@AttributeTypeId"
												,trc.[Priority] AS "@Priority"
												,trc.[UIOrder] AS "@UIOrder"
												,trc.[Importance] AS "@Importance"
												,trc.[IsDeleted] AS "@IsDeleted"
												,trc.[DeletedFrom] AS "@DeletedFrom"
												,trc.[DeletedBy] AS "@DeletedBy"
												,trc.[CreatedOn] AS "@CreatedOn"
												,trc.[CreatedBy] AS "@CreatedBy"
												,ISNULL(trc.[LastModifiedOn], ISNULL(trc.[CreatedOn], '')) AS "@LastModifiedOn"
												,trc.[LastModifiedBy] AS "@LastModifiedBy"
												,trc.[ObowiazujeOd] AS "History/@EffectiveFrom"
												,trc.[ObowiazujeDo] AS "History/@EffectiveTo"
												,trc.[IsMainHistFlow] AS "History/@IsMainHistFlow"
												,trc.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
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
												, (SELECT c.[Cecha_ID] AS "@Id"
															,c.[Nazwa] AS "@Name"
															,c.[NazwaSkrocona] AS "@ShortName"
															,c.[Hint] AS "@Hint"
															,c.[Opis] AS "@Description"
															,c.[TypID] AS "@TypeId"
															,c.[CzySlownik] AS "@IsDictionary"
															,c.[CzyWymagana] AS "@IsRequired"
															,c.[CzyPusta] AS "@IsEmpty"
															,c.[CzyWyliczana] AS "@IsQuantifiable"
															,c.[CzyPrzetwarzana] AS "@IsProcessed"
															,c.[CzyFiltrowana] AS "@IsFiltered"
															,c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
															,c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
															,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
															FROM [Cechy] c
															WHERE c.Cecha_ID = trc.Cecha_ID
															FOR XML PATH('AttributeType'), TYPE
													)
												FROM [TypRelacji_Cechy] trc
												WHERE trc.TypRelacji_ID = tr.TypRelacji_ID
												FOR XML PATH('CouplerAttributeType'), TYPE
												)								
						FROM [TypRelacji] tr
						WHERE TypRelacji_ID IN (SELECT ID FROM #TypyRelacjiNieUnikalne)
						FOR XML PATH('RelationType')
					) AS nvarchar(MAX)), '');
					END	
					
					SET @xmlResponse = (
						SELECT TOP 1 NULL AS '@Ids'
						, (
							SELECT Id AS '@Id'
							,'RelationType' AS '@EntityType'
							FROM #IDZmienionych
							FOR XML PATH('Ref'), ROOT('Value'), TYPE
							)
						FROM #IDZmienionych
						FOR XML PATH('Result')
						)
					
					IF @Commit = 1
						COMMIT TRAN T1_RelationTypes_Save
					ELSE
						ROLLBACK TRAN T1_RelationTypes_Save
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'RelationTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'RelationTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_RelationTypes_Save
		END
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="RelationTypes_Save"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';

	SET @XMLDataOut += '>';

	IF @ERRMSG iS NULL OR @ERRMSG = '' 	
	BEGIN
		IF (SELECT COUNT(1) FROM #IdZmienionych) > 0
			SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
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
	IF OBJECT_ID('tempdb..#TypyRelacji') IS NOT NULL
		DROP TABLE #TypyRelacji
		
	IF OBJECT_ID('tempdb..#TypyBazowe') IS NOT NULL
		DROP TABLE #TypyBazowe
		
	IF OBJECT_ID('tempdb..#CechyTypuRelacji') IS NOT NULL
		DROP TABLE #CechyTypuRelacji
		
	IF OBJECT_ID('tempdb..#DaneCechyTypuRelacji') IS NOT NULL
		DROP TABLE #DaneCechyTypuRelacji
		
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
	
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
		
	IF OBJECT_ID('tempdb..#HistoriaCech') IS NOT NULL
		DROP TABLE #HistoriaCech
	
	IF OBJECT_ID('tempdb..#StatusyCech') IS NOT NULL
		DROP TABLE #StatusyCech
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#TypyRelacjiKonfliktowe') IS NOT NULL
		DROP TABLE #TypyRelacjiKonfliktowe
	
	IF OBJECT_ID('tempdb..#TypyRelacjiNieUnikalne') IS NOT NULL
		DROP TABLE #TypyRelacjiNieUnikalne
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut	

END
