
-----------------------------------------------------------------
--Aktualizauje wartosc cechy obiektu
CREATE PROCEDURE [Tmp].[UpdateUnitAttributeValue]
(
	@AppDate date,
	@UserId int,
	@UnitTypeName nvarchar(500),
	@ColumnValue nvarchar(MAX),
	@ColumnType nvarchar(50),
	@QuotaValue varchar(4),
	@UnitId int,
	@ColumnName nvarchar(200)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query nvarchar(MAX),
			@ValueColumnName varchar(30),
			--@UnitId int,
			@AttributeTypeId int,
			@UnitTypeId int
	
	SELECT @UnitTypeId = TypObiekt_ID
	FROM TypObiektu WHERE Nazwa =  @UnitTypeName AND IdArch IS NULL;
	
	--pobranie id cechy
	SELECT TOP 1 @AttributeTypeId = c.Cecha_Id
	FROM dbo.Cechy c
	JOIN dbo.typObiektu_Cechy toc ON (c.Cecha_Id = toc.Cecha_Id)
	WHERE c.Nazwa = @ColumnName;	
			
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
	IF @QuotaValue IS NOT NULL
		SET @ColumnValue = REPLACE(@ColumnValue, @QuotaValue, '''''');
		
	--dodanie apostrofow dla wartosci tekstowych i dat
	IF @ValueColumnName = 'ValString' OR @ValueColumnName = 'ValDatetime' OR @ValueColumnName = 'ValDate' OR @ValueColumnName = 'ValTime'
		SET @ColumnValue = '''' + @ColumnValue + '''';
	
	SET @Query = '
		UPDATE dbo.[_' + @UnitTypeName + '_Cechy_Hist] SET
			' + @ValueColumnName + ' = ' + @ColumnValue + ',
			LastModifiedOn = ''' + CONVERT(nvarchar(50), @AppDate, 109) + ''',
			ObowiazujeOd = ''' + CONVERT(nvarchar(50), @AppDate, 109) + ''',
			LastModifiedBy = ' + CAST(@UserId AS varchar) + ',
			RealLastModifiedOn = GETDATE()
		WHERE CechaId = ' + CAST(@AttributeTypeId AS varchar) + ' AND ObiektId = ' + CAST(@UnitId AS varchar) + ' AND IdArch IS NULL'
		
		--PRINT @Query;
		EXECUTE sp_executesql @Query;
				
END;

