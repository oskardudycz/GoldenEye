
-------------------------------------------------
-- Aktualizacja danych cech linkowych
CREATE PROCEDURE [Tmp].[UpdateAttributeTypeLinks]
(
	@SourceDatabaseName nvarchar(200),		--nazwa zrodlowej bazy danych na serwerze (pelnej bazy do importu)
	@TargetDatabaseName nvarchar(200),		--nazwa docelowej bazy na serwerze (pustej bazy grafow)
	@TableName nvarchar(500)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query nvarchar(MAX),
		@UnitTypeId int,
		@ColumnName nvarchar(500),
		@UnitTypeName nvarchar(500)

	IF OBJECT_ID('tempdb..#DaneKluczyObcych') IS NOT NULL
		DROP TABLE #DaneKluczyObcych
		
	CREATE TABLE #DaneKluczyObcych(TableName nvarchar(500), ColumnName nvarchar(500));	
	
	--sprawdzenie czy obie bazy istnieja na serwerze (docelowa i zrodlowa).Jesli nie ma to konczymy
	IF DB_ID(@SourceDatabaseName) IS NULL 
	BEGIN
		RAISERROR ('Nie można wykonać skryptu. Baza źródłowa nie istnieje!', 16, 1, 2)
		RETURN;
	END
	
	IF DB_ID(@TargetDatabaseName) IS NULL 
	BEGIN
		RAISERROR ('Nie można wykonać skryptu. Baza docelowa nie istnieje!', 16, 1, 2)
		RETURN;
	END
	
	SET @Query = '
		INSERT INTO #DaneKluczyObcych(TableName, ColumnName)
		SELECT t.name, c.name
		FROM ' + @SourceDatabaseName + '.sys.foreign_key_columns AS fk
		INNER JOIN ' + @SourceDatabaseName + '.sys.tables as t on fk.referenced_object_id = t.object_id
		INNER JOIN ' + @SourceDatabaseName + '.sys.columns as c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id
		WHERE fk.parent_object_id = (SELECT object_id FROM ' + @SourceDatabaseName + '.sys.tables WHERE name = ''' + @TableName + ''')';

		--PRINT @Query;	
		EXECUTE sp_executesql @Query
		
		--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
		IF Cursor_Status('local','cur_Links') > 0 
		BEGIN
			 CLOSE cur_Links;
			 DEALLOCATE cur_Links;
		END
			
		--petla po wszystkich podanych tabelach
		DECLARE cur_Links CURSOR LOCAL FOR 
		SELECT TableName, ColumnName FROM #DaneKluczyObcych 
		OPEN cur_Links
		FETCH NEXT FROM cur_Links INTO @TableName, @ColumnName
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			SELECT @UnitTypeId = TypObiekt_ID
			FROM dbo.TypObiektu
			WHERE Nazwa = @TableName;
			
			DISABLE TRIGGER dbo.[WartoscZmiany_Cechy_UPDATE] ON dbo.Cechy;
			
			UPDATE dbo.Cechy SET
			UnitTypeId = @UnitTypeId
			WHERE Nazwa = @ColumnName;
		
			ENABLE TRIGGER dbo.[WartoscZmiany_Cechy_UPDATE] ON dbo.Cechy;
		
			FETCH NEXT FROM cur_Links INTO @TableName, @ColumnName
		END
		CLOSE cur_Links;	
		DEALLOCATE cur_Links;
		
	IF OBJECT_ID('tempdb..#DaneKluczyObcych') IS NOT NULL
		DROP TABLE #DaneKluczyObcych
END














