
------------------------------------------------------------------------------
-- tworzy wartosc cechy dla podanego obiektu
CREATE PROCEDURE [Tmp].[CreateUnitAttributeValue]
(
	@AppDate date,
	@UserId int,
	@UnitTypeName nvarchar(500),
	@ColumnValue nvarchar(MAX),
	@ColumnType nvarchar(50),
	@QuotaValue varchar(4),
	@UnitId int,
	@AttributeTypeId int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query nvarchar(MAX),
			@ValueColumnName varchar(30);
			
			
	--okreslenei kolumny na wartosc cechy
	SELECT @ValueColumnName = 
		CASE
			WHEN @ColumnType = 'bit' THEN 'ValBit'
			WHEN @ColumnType LIKE '%int' THEN 'ValInt'
			WHEN @ColumnType = 'float' THEN 'ValFloat'
			WHEN @ColumnType LIKE 'decimal%' THEN 'ValDecimal'
			WHEN @ColumnType LIKE '%char%' THEN 'ValString'
			WHEN @ColumnType LIKE 'datetime%' THEN 'ValDatetime'
			WHEN @ColumnType LIKE 'date%' THEN 'ValDate'
			WHEN @ColumnType = 'timestamp' THEN 'ValString'
		--	WHEN @ColumnType LIKE 'varbinary%' THEN 11
			WHEN @ColumnType LIKE 'time%' THEN 'ValTime'
			WHEn @ColumnType = 'uniqueidentifier' THEN 'ValString'
		END;

	--zastapienie specjalnego znaku apostrofem
	SET @ColumnValue = REPLACE(@ColumnValue, @QuotaValue, '''''');
		
	--dodanie apostrofow dla wartosci tekstowych i dat
	IF @ValueColumnName = 'ValString' OR @ValueColumnName = 'ValDatetime' OR @ValueColumnName = 'ValDate' OR @ValueColumnName = 'ValTime'
		SET @ColumnValue = '''' + @ColumnValue + '''';
	
	SET @Query = '
		IF OBJECT_ID (N''[_' + @UnitTypeName + '_Cechy_Hist]'', N''U'') IS NOT NULL
		BEGIN
			--DISABLE TRIGGER [WartoscZmiany_' + @UnitTypeName + '_Cechy_Hist_UPDATE] ON dbo.[_' + @UnitTypeName + '_Cechy_Hist];
			
			MERGE dbo.[_' + @UnitTypeName + '_Cechy_Hist] AS target
			USING (SELECT ' + CAST(@AttributeTypeId AS varchar) + ', ' + CAST(@UnitId AS varchar) + ') AS source (CechaId, ObiektId)
			ON (target.CechaId = source.CechaId AND target.ObiektId = source.ObiektId)
			WHEN MATCHED THEN 
				UPDATE SET 
				' + @ValueColumnName + ' = ' + @ColumnValue + ',
				LastModifiedOn = ''' + CONVERT(nvarchar(50), @AppDate, 109) + ''',
				LastModifiedBy = ' + CAST(@UserId AS varchar) + ',
				RealLastModifiedOn = GETDATE()
			WHEN NOT MATCHED THEN	
				INSERT (CechaId, ObiektId, ' + @ValueColumnName + ', CreatedOn, CreatedBy, IsValid, ValidFrom, ObowiazujeOd, Priority, UIOrder, IsStatus, IsDeleted, IsMainHistFlow, IsAlternativeHistory, RealCreatedOn)
				VALUES (source.CechaId, source.ObiektId, ' + @ColumnValue + ', ''' + CONVERT(nvarchar(50), @AppDate, 109) + ''', ' + CAST(@UserId AS varchar) + 
				', 1, ''' + CONVERT(nvarchar(50), @AppDate, 109) +  ''', ''' + CONVERT(nvarchar(50), @AppDate, 109) + ''', 0, 0, 0, 0, 1, 0, GETDATE());
			
			--ENABLE TRIGGER [WartoscZmiany_' + @UnitTypeName + '_Cechy_Hist_UPDATE] ON dbo.[_' + @UnitTypeName + '_Cechy_Hist];
		END'
		
		--PRINT @Query;
		EXECUTE sp_executesql @Query;				
END;

