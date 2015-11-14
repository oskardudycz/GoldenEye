-- Zmienia nazwy tabel i skojarzonych z nia obiektow.
CREATE PROCEDURE [THB].[ChangeUnitTypeTableName]
(
	@UnitTypeName nvarchar(255),
	@DeletedFrom datetime
)  
AS 
BEGIN
	SET NOCOUNT ON;
	
	--jelsi nie podano nazwy typu obiektu lub pusta to konczymy
	IF @UnitTypeName IS NULL OR LEN(@UnitTypeName) = 0
		RETURN

	DECLARE @Query nvarchar(MAX) = '',
			@UniTypeCurrentTableName nvarchar(300) = '_' + @UnitTypeName,
			@DeletedTime varchar(100),
			@NewTableName nvarchar(300),
			@TriggerInsertNameCurrent nvarchar(300),
			@TriggerUpdateNameCurrent nvarchar(300),
			@TriggerInsertName nvarchar(300),
			@TriggerUpdateName nvarchar(300),
			@CurrentConstrintName nvarchar(300),
			@NewConstraintName nvarchar(300),
			@Prefix nvarchar(300),
			@FullTableName nvarchar(350)

	--BEGIN TRY
		-- transakcja jestw  metodzie nadrzednej
		--BEGIN TRANSACTION ChangeTables
		
			SET @DeletedTime = REPLACE(SUBSTRING(CONVERT(varchar, @DeletedFrom, 126), 1, 19), '-', '');
			SET @NewTableName = '_Del_' + @UnitTypeName + '_' + @DeletedTime;
			SET @Prefix = 'dbo.' + @UniTypeCurrentTableName + '.';
				
			--zmiana nazwy tabeli z danymi jesli istnieje
			IF OBJECT_ID (@UniTypeCurrentTableName, N'U') IS NOT NULL
			BEGIN
				--zmiana nazw kluczy i indeksow
				SET @CurrentConstrintName = 'PK2' + @UniTypeCurrentTableName
				SET @NewConstraintName = 'PK2' + @NewTableName
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName		
				
				SET @CurrentConstrintName = 'FK' + @UniTypeCurrentTableName + '_IdArch';
				SET @NewConstraintName = 'FK' + @NewTableName + '_IdArch';
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				
				SET @CurrentConstrintName = 'FK' + @UniTypeCurrentTableName + '_IdArchLink';
				SET @NewConstraintName = 'FK' + @NewTableName + '_IdArchLink';
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				
				SET @CurrentConstrintName = @Prefix + 'PK' + @UniTypeCurrentTableName
				SET @NewConstraintName = 'PK' + @NewTableName
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName --, N'Index';
				
				--zmiana nazwy trigerow i ich wylaczenie
				SET @TriggerInsertNameCurrent = 'WartoscZmiany' + @UniTypeCurrentTableName + '_INSERT';
				SET @TriggerUpdateNameCurrent = 'WartoscZmiany' + @UniTypeCurrentTableName + '_UPDATE';
				SET @TriggerUpdateName = 'WartoscZmiany' + @NewTableName + '_UPDATE';
				SET @TriggerInsertName = 'WartoscZmiany' + @NewTableName + '_INSERT';
				
				--triger na update
				IF (SELECT name FROM sys.triggers WHERE name = @TriggerUpdateNameCurrent) IS NOT NULL
				BEGIN		
					SET @Query = 'DISABLE TRIGGER dbo.[' + @TriggerUpdateNameCurrent + '] ON dbo.[' + @UniTypeCurrentTableName + ']'
					--PRINT @Query;
					EXEC sp_executesql @Query

					--zmiana nazwy triggera
					EXEC sp_rename @TriggerUpdateNameCurrent, @TriggerUpdateName;
				END
				
				--triger na insert
				IF (SELECT name FROM sys.triggers WHERE name = @TriggerInsertNameCurrent) IS NOT NULL
				BEGIN		
					SET @Query = 'DISABLE TRIGGER dbo.[' + @TriggerInsertNameCurrent + '] ON dbo.[' + @UniTypeCurrentTableName + ']'
					--PRINT @Query;
					EXEC sp_executesql @Query

					--zmiana nazwy triggera
					EXEC sp_rename @TriggerInsertNameCurrent, @TriggerInsertName;
				END
				
				--zmiana nazwy tabeli
				EXEC sp_rename @UniTypeCurrentTableName, @NewTableName
			END
		
			--zmiana tabeli z cechami jesli taka jest
			SET @UniTypeCurrentTableName = '_' + @UnitTypeName + '_Cechy_Hist';
			SET @NewTableName = '_Del_' + @UnitTypeName + '_Cechy_Hist_' + @DeletedTime;
			SET @Prefix = 'dbo.' + @UniTypeCurrentTableName + '.';
			
			
			IF OBJECT_ID (@UniTypeCurrentTableName, N'U') IS NOT NULL
			BEGIN
				--zmiana nazw kluczy i indeksow
				SET @CurrentConstrintName = 'PK2' + @UniTypeCurrentTableName
				SET @NewConstraintName = 'PK2' + @NewTableName
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				
				SET @CurrentConstrintName = 'FK' + @UniTypeCurrentTableName + '_IdArch';
				SET @NewConstraintName = 'FK' + @NewTableName + '_IdArch]';
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				
				SET @CurrentConstrintName = 'FK' + @UniTypeCurrentTableName + '_IdArchLink';
				SET @NewConstraintName = 'FK' + @NewTableName + '_IdArchLink';
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				
				--TODO kolejne kolumny: CechaId, ObiektId, CalculatedByAlgorithm
				SET @FullTableName = 'dbo.[' + @UniTypeCurrentTableName + ']';
				SET @CurrentConstrintName = 'FK' + @UniTypeCurrentTableName + '_CechaId';
				SET @NewConstraintName = 'FK' + @NewTableName + '_CechaId';
				
				--wykonanie polecenia jesli dany klucz istnieje
				IF EXISTS (SELECT name FROM sys.foreign_keys WHERE name = @CurrentConstrintName AND parent_object_id = OBJECT_ID(@FullTableName))
				BEGIN
					EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				END
				
				SET @CurrentConstrintName = 'FK' + @UniTypeCurrentTableName + '_ObiektId';
				SET @NewConstraintName = 'FK' + @NewTableName + '_ObiektId';
				
				--wykonanie polecenia jesli dany klucz istnieje
				IF EXISTS (SELECT name FROM sys.foreign_keys WHERE name = @CurrentConstrintName AND parent_object_id = OBJECT_ID(@FullTableName))
				BEGIN
					EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				END
				
				SET @CurrentConstrintName = 'FK' + @UniTypeCurrentTableName + '_CalculatedByAlgorithm';
				SET @NewConstraintName = 'FK' + @NewTableName + '_CalculatedByAlgorithm';
				
				--wykonanie polecenia jesli dany klucz istnieje
				IF EXISTS (SELECT name FROM sys.foreign_keys WHERE name = @CurrentConstrintName AND parent_object_id = OBJECT_ID(@FullTableName))
				BEGIN
					EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				END				
				
				
				SET @CurrentConstrintName = @Prefix + 'PK' + @UniTypeCurrentTableName
				SET @NewConstraintName = 'PK' + @NewTableName
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName --, N'Index';
				
				--zmiana nazwy trigerow i ich wylaczenie
				SET @TriggerInsertNameCurrent = 'WartoscZmiany' + @UniTypeCurrentTableName + '_INSERT';
				SET @TriggerUpdateNameCurrent = 'WartoscZmiany' + @UniTypeCurrentTableName + '_UPDATE';
				SET @TriggerUpdateName = 'WartoscZmiany' + @NewTableName + '_UPDATE';
				SET @TriggerInsertName = 'WartoscZmiany' + @NewTableName + '_INSERT';
				
				--triger na update
				IF (SELECT name FROM sys.triggers WHERE name = @TriggerUpdateNameCurrent) IS NOT NULL
				BEGIN		
					SET @Query = 'DISABLE TRIGGER dbo.[' + @TriggerUpdateNameCurrent + '] ON dbo.[' + @UniTypeCurrentTableName + ']'
					--PRINT @Query;
					EXEC sp_executesql @Query

					--zmiana nazwy triggera
					EXEC sp_rename @TriggerUpdateNameCurrent, @TriggerUpdateName;
				END
				
				--triger na insert
				IF (SELECT name FROM sys.triggers WHERE name = @TriggerInsertNameCurrent) IS NOT NULL
				BEGIN		
					SET @Query = 'DISABLE TRIGGER dbo.[' + @TriggerInsertNameCurrent + '] ON dbo.[' + @UniTypeCurrentTableName + ']'
					--PRINT @Query;
					EXEC sp_executesql @Query

					--zmiana nazwy triggera
					EXEC sp_rename @TriggerInsertNameCurrent, @TriggerInsertName;
				END
				
				--zmiana nazwy tabeli
				EXEC sp_rename @UniTypeCurrentTableName, @NewTableName
			END
		
			--COMMIT TRANSACTION ChangeTables;				
	
		--END TRY
		--BEGIN CATCH
			--ROLLBACK TRANSACTION ChangeTables;
		--	PRINT ERROR_MESSAGE();
		--END CATCH
END


