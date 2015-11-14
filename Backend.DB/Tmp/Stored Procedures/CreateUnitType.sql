
--------------------------------------------------------------
-- tworzy typ obiektu i zwraca jego Id
CREATE PROCEDURE [Tmp].[CreateUnitType]
(
	@AppDate date,
	@UserId int,
	@UnitTypeName nvarchar(500),
	@Table bit,
	@Id int OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Ids TableForIds;
		
	DISABLE TRIGGER [WartoscZmiany_TypObiektu_UPDATE] ON dbo.TypObiektu;
	
	MERGE dbo.TypObiektu AS target
	USING (SELECT @UnitTypeName) AS source (Nazwa)
	ON (target.Nazwa = source.Nazwa)
	WHEN MATCHED THEN 
		UPDATE SET 
		Nazwa = source.Nazwa,
		--ObowiazujeOd = @AppDate,
		LastModifiedOn = @AppDate,
		LastModifiedBy = @UserId,
		RealLastModifiedOn = GETDATE()
	WHEN NOT MATCHED THEN	
		INSERT (Nazwa, Tabela, CreatedOn, CreatedBy, IsValid, ValidFrom, ObowiazujeOd, IsStatus, IsDeleted, RealCreatedOn, CzyPrzechowujeHistorie)
		VALUES (source.Nazwa, @Table, @AppDate, @UserId, 1, @AppDate, @AppDate, 0, 0, GETDATE(), 1)
	OUTPUT inserted.TypObiekt_ID INTO @Ids(Id);
			
	ENABLE TRIGGER [WartoscZmiany_TypObiektu_UPDATE] ON dbo.TypObiektu;
		
	--pobranie Id zmienionej cechy
	SELECT TOP 1 @Id = Id 
	FROM @Ids;
	
END;

