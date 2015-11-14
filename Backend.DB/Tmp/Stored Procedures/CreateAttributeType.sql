
---------------------------------------------------------------
-- tworzy nowa ceche i zwraca jej id	
CREATE PROCEDURE [Tmp].[CreateAttributeType]
(
	@AppDate date,
	@UserId int,
	@UnitTypeId int,
	@AttributeTypeName nvarchar(500),
	@DataType nvarchar(50),
	@Id int OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @DataTypeId int,
			@Ids TableForIds	
	
	--pobranie Id typu cechy
	SELECT @DataTypeId = 
		CASE
			WHEN @DataType = 'bit' THEN 1
			WHEN @DataType = 'int' OR @DataType = 'smallint' THEN 2
			WHEN @DataType = 'float' THEN 3
			WHEN @DataType LIKE 'decimal%' THEN 4
			WHEN @DataType LIKE '%char%' THEN 5
			WHEN @DataType LIKE 'datetime%' THEN 7
			WHEN @DataType LIKE 'date%' THEN 6
			WHEN @DataType = 'timestamp' THEN 10
			WHEN @DataType LIKE 'time%' THEN 8
			WHEN @DataType LIKE 'varbinary%' THEN 11
			WHEn @DataType = 'uniqueidentifier' THEN 5  --jako string, bo wartosci cech nie wspieraja wprost uniqueidentofier
		END;
		
	DISABLE TRIGGER [WartoscZmiany_Cechy_UPDATE] ON dbo.Cechy;
	
	--zapis dnaych cechy
	MERGE dbo.Cechy AS target
	USING (SELECT @AttributeTypeName, @DataTypeId) AS source (Nazwa, TypId)
	ON (target.Nazwa = source.Nazwa AND target.TypId = source.TypId)
	WHEN MATCHED THEN 
		UPDATE SET 
		Nazwa = source.Nazwa,
		LastModifiedOn = @AppDate,
		LastModifiedBy = @UserId,
		RealLastModifiedOn = GETDATE()
	WHEN NOT MATCHED THEN	
		INSERT (Nazwa, TypId, CreatedOn, CreatedBy, IsValid, IsMainHistFlow, ValidFrom, ObowiazujeOd, IsDeleted, IsStatus, ControlSize, RealCreatedOn, PrzedzialCzasowyId)
		VALUES (source.Nazwa, source.TypId, @AppDate, @UserId, 1, 1, @AppDate, @AppDate, 0, 0, 1, GETDATE(), 4)
	OUTPUT inserted.Cecha_ID INTO @Ids(Id);
	
	ENABLE TRIGGER [WartoscZmiany_Cechy_UPDATE] ON dbo.Cechy;
	
	--pobranie Id zmienionej cechy
	SELECT TOP 1 @Id = Id 
	FROM @Ids;
	
	IF @Id > 0
	BEGIN
		--polaczenie cechy z podanym typem obiektu
		DISABLE TRIGGER [WartoscZmiany_TypObiektu_Cechy_UPDATE] ON dbo.TypObiektu_Cechy;
		
		MERGE dbo.TypObiektu_Cechy AS target
		USING (SELECT @UnitTypeId, @Id) AS source (TypObiektu_ID, Cecha_ID)
		ON (target.TypObiektu_ID = source.TypObiektu_ID AND target.Cecha_ID = source.Cecha_ID)
		WHEN MATCHED THEN 
			UPDATE SET 
			LastModifiedOn = @AppDate,
			LastModifiedBy = @UserId,
			RealLastModifiedOn = GETDATE()
		WHEN NOT MATCHED THEN	
			INSERT (TypObiektu_ID, Cecha_ID, CreatedOn, CreatedBy, IsValid, IsMainHistFlow, ValidFrom, ObowiazujeOd, Priority, UIOrder)
			VALUES (source.TypObiektu_ID, source.Cecha_ID, @AppDate, @UserId, 1, 1, @AppDate, @AppDate, 0, 0);
		
		ENABLE TRIGGER [WartoscZmiany_TypObiektu_Cechy_UPDATE] ON dbo.TypObiektu_Cechy;
		
		--polaczenie cechy z branza glowna (Administracyjna)
		DISABLE TRIGGER [WartoscZmiany_Branze_Cechy_UPDATE] ON dbo.Branze_Cechy;
		
		MERGE dbo.Branze_Cechy AS target
		USING (SELECT 0, @Id) AS source (BranzaId, CechaID)
		ON (target.BranzaId = source.BranzaId AND target.CechaID = source.CechaID)
		WHEN MATCHED THEN 
			UPDATE SET 
			LastModifiedOn = @AppDate,
			LastModifiedBy = @UserId,
			RealLastModifiedOn = GETDATE()
		WHEN NOT MATCHED THEN	
			INSERT (BranzaId, CechaID, CreatedOn, CreatedBy, IsValid, IsMainHistFlow, ValidFrom, ObowiazujeOd)
			VALUES (source.BranzaId, source.CechaID, @AppDate, @UserId, 1, 1, @AppDate, @AppDate);
		
		ENABLE TRIGGER [WartoscZmiany_Branze_Cechy_UPDATE] ON dbo.Branze_Cechy;
		
	END
END

