
------------------------------------------------------------------------------
CREATE PROCEDURE [Tmp].[CreateUnit]
(
	@AppDate date,
	@UserId int,
	@UnitTypeName nvarchar(500),
	@Number int,
	@Id int OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query nvarchar(MAX)
	
	SET @Query = '
		--DISABLE TRIGGER [WartoscZmiany_' + @UnitTypeName + '_UPDATE] ON dbo.[_' + @UnitTypeName + '];
		SET IDENTITY_INSERT dbo.[_' + @UnitTypeName + '] ON;
		
		DECLARE @Ids TableForIds;
		
		MERGE dbo.[_' + @UnitTypeName + '] AS target
		USING (SELECT ''' + @UnitTypeName + '_' + CAST(@Number AS varchar) + ''', ' + CAST(@Id AS varchar) + ') AS source (Nazwa, Id)
		ON (target.Nazwa = source.Nazwa AND target.Id = source.Id)
		WHEN MATCHED THEN 
			UPDATE SET 
			Nazwa = source.Nazwa,
			LastModifiedOn = ''' + CONVERT(nvarchar(50), @AppDate, 109) + ''',
			LastModifiedBy = ' + CAST(@UserId AS varchar) + ',   
			RealLastModifiedOn = GETDATE()
		WHEN NOT MATCHED THEN	
			INSERT (Id, Nazwa, CreatedOn, CreatedBy, IsValid, ValidFrom, ObowiazujeOd, IsStatus, IsDeleted, RealCreatedOn)
			VALUES (source.Id, source.Nazwa, ''' + CONVERT(nvarchar(50), @AppDate, 109) + ''', ' + CAST(@UserId AS varchar) + ', 1, ' + CAST(@UserId AS varchar) + ', ' + CAST(@UserId AS varchar) + ', 0, 0, GETDATE())
		OUTPUT inserted.Id INTO @Ids(Id);
		
		SET IDENTITY_INSERT dbo.[_' + @UnitTypeName + '] OFF;
		--ENABLE TRIGGER [WartoscZmiany_' + @UnitTypeName + '_UPDATE] ON dbo.[_' + @UnitTypeName + '];
		
		--pobranie Id zmienionej cechy
		SELECT TOP 1 @Id = Id 
		FROM @Ids;'
		
		--PRINT @Query;
		EXECUTE sp_executesql @Query, N'@Id int OUTPUT', @Id = @Id OUTPUT
				
END;

