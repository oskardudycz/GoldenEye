-- =============================================
-- Author:		DK
-- Create date: 2013-03-15
-- Last modified on: 2013-03-18
-- Description:	Zwraca relationLinki dla podanej struktury.
-- =============================================
CREATE PROCEDURE [THB].[GetRelationLinksForStructures]
(
	@WhereClause nvarchar(MAX),
	@GetAllData bit,
	@StructureId int,
	@MaxLevel int,
	@RootLevel bit,
	@Xml xml OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	--zabezpieczenie przez zbyt glebokim zaglebieniem
	IF @MaxLevel > 5
		SET @MaxLevel = 5;

	DECLARE @Query nvarchar(MAX),
		@xmlResponse xml,
		@xmlSubLinks nvarchar(MAX) = '',
		@StructureLinkId int,
		@NewLevel int,
		@RelationId int,
		@StructureObjectId int
	
	--pobranie linkow zwiazanych z struktura
	SET @Query = '
		INSERT INTO ##LinkiStruktur([Level], RelacjaId, StrukturaObiektId, StrukturaLinkId)
		SELECT ' + CAST(@MaxLevel AS varchar) + ', s.RelacjaId, s.StrukturaObiektId, s.StrukturaLinkId
		FROM [Struktura] s
		WHERE s.[StrukturaObiektId] = ' + CAST(@StructureId AS varchar) + @WhereClause;

--SELECT @RootLevel AS RootLevel
		
	IF @RootLevel = 1
	BEGIN
		SET @Query += ' AND s.StrukturaLinkId IS NOT NULL'
	END
	
	--PRINT @Query;
	EXEC sp_executesql @Query

--SELECT * FROM ##LinkiStruktur
	
	--pobieramy normalne linki tylko jesli nie root Level
	--IF @RootLevel = 0
	BEGIN
	
		--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
		IF Cursor_Status('local','curSimpleSubStructures') > 0 
		BEGIN
			 CLOSE curSimpleSubStructures
			 DEALLOCATE curSimpleSubStructures
		END
		
		DECLARE curSimpleSubStructures CURSOR LOCAL FOR 
			SELECT RelacjaId, StrukturaObiektId, StrukturaLinkId FROM ##LinkiStruktur l
			LEFT OUTER JOIN dbo.[Struktura_Obiekt] so ON (l.StrukturaLinkId = so.Id)
			WHERE [Level] = @MaxLevel AND StrukturaObiektId = @StructureId AND ((StrukturaLinkId IS NULL AND @RootLevel = 0) OR so.Id IS NULL OR @MaxLevel = 0)
		OPEN curSimpleSubStructures
		FETCH NEXT FROM curSimpleSubStructures INTO @RelationId, @StructureObjectId, @StructureLinkId
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--jesli podanoId struktury ktora nie istnieje to dodanie na liste
			IF @StructureLinkId IS NOT NULL
			BEGIN
				INSERT INTO ##LinkiStrukturNieistniejace(Id) VALUES(@StructureLinkId);
			END

--SELECT @RelationId AS RelacjaId, @StructureObjectId	AS Obiekt, @StructureLinkId AS StructureLink

			SET @Query = 'SET @xmlTemp = (';
			
			IF @GetAllData = 0
			BEGIN
			
				--pobranie linkow nie posiadajacych odwolania do podstruktur
				SET @Query += 'SELECT s.[StrukturaObiektId] AS "@StructureId"
									,s.[RelacjaId] AS "@RelationId"
									,s.[IsMain] AS "@IsMain"
									,s.[StrukturaLinkId] AS "@StructureLinkId"
									,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
									,ISNULL(s.[LastModifiedBy], s.[CreatedBy]) AS "@LastModifiedBy"
									, (SELECT r.[Id] AS "@Id"
											,r.[TypRelacji_ID] AS "@TypeId"
											,r.[SourceId] AS "@SourceId"
											,r.[IsOuter] AS "@IsOuter"
											,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
											,ISNULL(r.[LastModifiedBy], r.[CreatedBy]) AS "@LastModifiedBy"
											,r.[TypObiektuID_L] AS "ObjectLeft/@TypeId"
											,r.[ObiektID_L] AS "ObjectLeft/@Id"
											,r.[TypObiektuID_R] AS "ObjectRight/@TypeId"
											,r.[ObiektID_R] AS "ObjectRight/@Id"
											FROM [Relacje] r
											WHERE r.[Id] = s.[RelacjaId]' + @WhereClause + '														
											FOR XML PATH (''Relation''), TYPE
										)'
			END
			ELSE
			BEGIN --pobranie wszystkich danych
			
				SET @Query += 'SELECT s.[StrukturaObiektId] AS "@StructureId"
									,s.[RelacjaId] AS "@RelationId"
									,s.[IsMain] AS "@IsMain"
									,s.[StrukturaLinkId] AS "@StructureLinkId"
									,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
									,ISNULL(s.[LastModifiedBy], s.[CreatedBy]) AS "@LastModifiedBy"
									, (SELECT r.[Id] AS "@Id"
									,r.[TypRelacji_ID] AS "@TypeId"
									,r.[SourceId] AS "@SourceId"
									,r.[IsOuter] AS "@IsOuter"
									,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
									,ISNULL(r.[LastModifiedBy], r.[CreatedBy]) AS "@LastModifiedBy"
									,r.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,r.[ObowiazujeDo] AS "History/@EffectiveTo"
									,r.[IsStatus] AS "Statuses/@IsStatus"
									,r.[StatusS] AS "Statuses/@StatusS"
									,r.[StatusSFrom] AS "Statuses/@StatusSFrom"
									,r.[StatusSTo] AS "Statuses/@StatusSTo"
									,r.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									,r.[StatusSToBy] AS "Statuses/@StatusSToBy"
									,r.[StatusW] AS "Statuses/@StatusW"
									,r.[StatusWFrom] AS "Statuses/@StatusWFrom"
									,r.[StatusWTo] AS "Statuses/@StatusWTo"
									,r.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									,r.[StatusWToBy] AS "Statuses/@StatusWToBy"
									,r.[StatusP] AS "Statuses/@StatusP"
									,r.[StatusPFrom] AS "Statuses/@StatusPFrom"
									,r.[StatusPTo] AS "Statuses/@StatusPTo"
									,r.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									,r.[StatusPToBy] AS "Statuses/@StatusPToBy"
									,r.[TypObiektuID_L] AS "ObjectLeft/@TypeId"
									,r.[ObiektID_L] AS "ObjectLeft/@Id"
									,r.[TypObiektuID_R] AS "ObjectRight/@TypeId"
									,r.[ObiektID_R] AS "ObjectRight/@Id"
									FROM [Relacje] r
									WHERE r.[Id] = s.[RelacjaId]' + @WhereClause + '
									FOR XML PATH (''Relation''), TYPE
								)'	
			END	
			
			SET @Query += '
							FROM [Struktura] s
							WHERE s.[StrukturaObiektId] = ' + CAST(@StructureObjectId AS varchar)
									
			IF @MaxLevel > 0 AND @StructureLinkId IS NOT NULL
			BEGIN		
				SET @Query += '	AND s.StrukturaLinkId IS NOT NULL'		
			END							
									
			SET @Query += '						
							FOR XML PATH(''RelationLink''), TYPE
							)'
			
			--PRINT @Query;
			EXECUTE sp_executesql @Query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT

			--dodanie wynikowego linka do XMLa z wynikami
			IF @xmlResponse IS NOT NULL
			BEGIN
				SET @Query = '
					SET @xmlResponse.modify(''insert ' + CAST(@xmlResponse AS nvarchar(MAX)) + '
					as last
					into (/Structure)[1]'')'
				
				--PRINT @Query;
				EXECUTE sp_executesql @Query, N'@xmlResponse xml OUTPUT', @xmlResponse = @Xml OUTPUT
					
				SET @xmlResponse = NULL;
			END			
						
			FETCH NEXT FROM curSimpleSubStructures INTO @RelationId, @StructureObjectId, @StructureLinkId
		END
		CLOSE curSimpleSubStructures;
		DEALLOCATE curSimpleSubStructures;
	END
	
	--sprawdzamy czy mamy pobierac podstruktury
	IF @MaxLevel > 0
	BEGIN	
	
		SET @NewLevel = @MaxLevel - 1;	

		--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
		IF Cursor_Status('local','curSubStructures') > 0 
		BEGIN
			 CLOSE curSubStructures
			 DEALLOCATE curSubStructures
		END
		
		DECLARE curSubStructures CURSOR LOCAL FOR 
			SELECT StrukturaLinkId FROM ##LinkiStruktur WHERE StrukturaLinkId IS NOT NULL AND [Level] = @MaxLevel
		OPEN curSubStructures
		FETCH NEXT FROM curSubStructures INTO @StructureLinkId
		WHILE @@FETCH_STATUS = 0
		BEGIN			
	
			IF NOT EXISTS (SELECT Id FROM ##LinkiStrukturNieistniejace WHERE Id = @StructureLinkId)
			BEGIN
				EXEC [THB].[GetRelationLinksForStructures]
					@WhereClause = @WhereClause,
					@GetAllData = @GetAllData,
					@StructureId = @StructureLinkId,
					@MaxLevel = @NewLevel,
					@RootLevel = 0,
					@Xml = @Xml OUTPUT		

			END
		
			FETCH NEXT FROM curSubStructures INTO @StructureLinkId
		END
		CLOSE curSubStructures;
		DEALLOCATE curSubStructures;
	END
	
END
