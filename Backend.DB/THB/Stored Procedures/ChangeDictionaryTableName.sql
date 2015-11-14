CREATE PROCEDURE [THB].[ChangeDictionaryTableName]
(
	@DictionaryName nvarchar(255),
	@DeletedFrom datetime
)  
AS 
BEGIN
	SET NOCOUNT ON;
	
	--jelsi nie podano nazwy slownika lub pusta to konczymy
	IF @DictionaryName IS NULL OR LEN(@DictionaryName) = 0
		RETURN
	
	DECLARE @Query nvarchar(MAX) = '',
			@DictionaryCurrentTableName nvarchar(300) = '_Slownik_' + @DictionaryName,
			@DeletedTime varchar(100),
			@NewTableName nvarchar(300),
			@TriggerInsertNameCurrent nvarchar(300),
			@TriggerUpdateNameCurrent nvarchar(300),
			@TriggerInsertName nvarchar(300),
			@TriggerUpdateName nvarchar(300),
			@CurrentConstrintName nvarchar(300),
			@NewConstraintName nvarchar(300),
			@Prefix nvarchar(300)

	--BEGIN TRY
		-- transakcja jestw  metodzie nadrzednej
		--BEGIN TRANSACTION ChangeTables
		
			SET @DeletedTime = REPLACE(SUBSTRING(CONVERT(varchar, @DeletedFrom, 126), 1, 19), '-', '');
			SET @NewTableName = '_Del_Slownik_' + @DictionaryName + '_' + @DeletedTime;
			SET @Prefix = 'dbo.' + @DictionaryCurrentTableName + '.';
				
			--zmiana nazwy tabeli jesli istnieje
			IF OBJECT_ID (@DictionaryCurrentTableName, N'U') IS NOT NULL
			BEGIN
				--zmiana nazw kluczy i indeksow
				SET @CurrentConstrintName = 'PK2' + @DictionaryCurrentTableName;
				SET @NewConstraintName = 'PK2' + @NewTableName
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				
				SET @CurrentConstrintName = 'FK' + @DictionaryCurrentTableName + '_IdArch';
				SET @NewConstraintName = 'FK' + @NewTableName + '_IdArch';
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				
				SET @CurrentConstrintName = 'FK' + @DictionaryCurrentTableName + '_IdArchLink';
				SET @NewConstraintName = 'FK' + @NewTableName + '_IdArchLink';
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				
				SET @CurrentConstrintName = 'FK' + @DictionaryCurrentTableName + '_TypId';
				SET @NewConstraintName = 'FK' + @NewTableName + '_TypId';
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName
				
				SET @CurrentConstrintName = @Prefix + 'PK' + @DictionaryCurrentTableName;
				SET @NewConstraintName = 'PK' + @NewTableName;
				
				EXEC sp_rename @CurrentConstrintName, @NewConstraintName --, N'Index';
				
				--zmiana nazwy trigerow i ich wylaczenie
				SET @TriggerInsertNameCurrent = 'WartoscZmiany' + @DictionaryCurrentTableName + '_INSERT';
				SET @TriggerUpdateNameCurrent = 'WartoscZmiany' + @DictionaryCurrentTableName + '_UPDATE';
				SET @TriggerUpdateName = 'WartoscZmiany' + @NewTableName + '_UPDATE';
				SET @TriggerInsertName = 'WartoscZmiany' + @NewTableName + '_INSERT';
				
				--triger na update
				IF (SELECT name FROM sys.triggers WHERE name = @TriggerUpdateNameCurrent) IS NOT NULL
				BEGIN		
					SET @Query = 'DISABLE TRIGGER dbo.[' + @TriggerUpdateNameCurrent + '] ON dbo.[' + @DictionaryCurrentTableName + ']'
					--PRINT @Query;
					EXEC sp_executesql @Query

					--zmiana nazwy triggera
					EXEC sp_rename @TriggerUpdateNameCurrent, @TriggerUpdateName;
				END
				
				--triger na insert
				IF (SELECT name FROM sys.triggers WHERE name = @TriggerInsertNameCurrent) IS NOT NULL
				BEGIN		
					SET @Query = 'DISABLE TRIGGER dbo.[' + @TriggerInsertNameCurrent + '] ON dbo.[' + @DictionaryCurrentTableName + ']'
					--PRINT @Query;
					EXEC sp_executesql @Query

					--zmiana nazwy triggera
					EXEC sp_rename @TriggerInsertNameCurrent, @TriggerInsertName;
				END
				
				--zmiana nazwy tabeli
				EXEC sp_rename @DictionaryCurrentTableName, @NewTableName
			END
		
			--COMMIT TRANSACTION ChangeTables;				
	
		--END TRY
		--BEGIN CATCH
			--ROLLBACK TRANSACTION ChangeTables;
		--	PRINT ERROR_MESSAGE();
		--END CATCH
END


