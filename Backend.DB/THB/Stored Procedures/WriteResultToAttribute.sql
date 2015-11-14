-- =============================================
-- Author:		DK
-- Create date: 2012-11-22
-- Description:	Przepisuje wynik obliczen do wskazanej cechy relacji/obiektu
-- =============================================
CREATE PROCEDURE [THB].[WriteResultToAttribute]
(
	@AppDate datetime,
	@UserId int,
	@ResultValue varchar(100),
	@AttributeId int,
	@ObjectId int,
	@ObjectTypeId int,
	@RelationId int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@Query nvarchar(MAX),
		@NazwaTypuObiektu nvarchar(500),
		@ColumnName varchar(30),
		@TypCechy nvarchar(200),
		@TableName nvarchar(200),
		@ErrorText nvarchar(200),
		@RecordId int,
		@CreateAttributeForResult bit = 0,
		@ObjectColumnName nvarchar(50) = '',
		@RelatedObjectId int = 0;
		
		--jesli brak danych to koncz
		IF @AttributeId IS NULL OR (@RelationId IS NULL AND @ObjectId IS NULL AND @ObjectTypeId IS NULL)
			RETURN;

--select @RelationId as relationId, @ObjectId AS ObjectId, @ObjectTypeId as objecTTypeId

		IF @RelationId IS NOT NULL
		BEGIN
		
			--pobranie typu danych dla cechy relacji
			SELECT @TypCechy = ct.NazwaSQL
			FROM dbo.[Cecha_Typy] ct
			JOIN dbo.[Cechy] c ON c.TypID = ct.Id
			JOIN dbo.[Relacja_Cecha_Hist] rch ON (c.Cecha_Id = rch.CechaId)
			WHERE rch.Id = @AttributeId
			
			SET @TableName = 'dbo.[Relacja_Cecha_Hist]';
			
			--jesli nie istnieje cecha relacji o podanym Id to rzuc bledem
			SELECT @RecordId = Id FROM dbo.[Relacja_Cecha_Hist] WHERE CechaId = @AttributeId AND IdArch IS NULL;
			
			IF @RecordId IS NULL
			BEGIN			
				SET @CreateAttributeForResult = 1;
				
				--SET @ErrorText = 'Błąd! Nie można przypisać wyniku obliczeń do cechy. Dla relacji nie istnieje cecha typu o podanym Id (' + CAST(@AttributeId AS varchar) + ').';				
				--RAISERROR (@ErrorText, 16, 1);
            END
            
        	SET @ObjectColumnName = 'RelacjaId';
			SET @RelatedObjectId = @RelationId;  
		
		END	--przypisanie wyniku do cechy obiektu
		ELSE IF @ObjectId IS NOT NULL AND @ObjectTypeId IS NOT NULL
		BEGIN
		
			--pobranie nazwy typu obiektu
			SELECT @NazwaTypuObiektu = Nazwa
			FROM dbo.TypObiektu
			WHERE TypObiekt_ID = @ObjectTypeId
			
			SET @TableName = 'dbo.[_' + @NazwaTypuObiektu + '_Cechy_Hist]';
			
			SELECT @TypCechy = ct.NazwaSQL
			FROM dbo.[Cecha_Typy] ct
			JOIN dbo.[Cechy] c ON c.TypID = ct.Id
			WHERE c.Cecha_Id = @AttributeId
			
			--pobranie typu danych dla cechy obiektu
			SET @Query = '
				SELECT @RecordId = och.Id
				FROM dbo.[_' + @NazwaTypuObiektu + '_Cechy_Hist] och
				WHERE och.IdArch IS NULL AND och.CechaId = ' + CAST(@AttributeId AS varchar) + ' AND och.ObiektId = ' + CAST(@ObjectId AS varchar)
		
			--PRINT @Query
			EXECUTE sp_executesql @Query, N'@TypCechy nvarchar(200) OUTPUT, @RecordId int OUTPUT', @TypCechy = @TypCechy OUTPUT, @RecordId = @RecordId OUTPUT

--select @RecordId as recordId	
		
			--jesli nie istnieje cecha obiektu o podanym Id to rzuc bledem			
			IF @RecordId IS NULL
			BEGIN			
				SET @CreateAttributeForResult = 1;
				
				--SET @ErrorText = 'Błąd! Nie można przypisać wyniku obliczeń do cechy. Dla obiektu nie istnieje cecha typu o podanym Id (' + CAST(@AttributeId AS varchar) + ').';				
				--RAISERROR (@ErrorText, 16, 1);
            END 
            
            SET @ObjectColumnName = 'ObiektId';
			SET @RelatedObjectId = @ObjectId;
		END

		--ustalenie nazwy kolumny w ktora bedzie wpisana wartosc wyliczen (na podstawie typu)
		SELECT @ColumnName = 
			CASE 
				WHEN LOWER(@TypCechy) = 'int' THEN 'ValInt'
				WHEN LOWER(@TypCechy) = 'float' THEN 'ValFloat'
				WHEN LEFT(LOWER(@TypCechy), 7) = 'decimal' THEN 'ValDecimal'
			END	
	
		--przypisanie wartosci cech
		IF @CreateAttributeForResult = 0
		BEGIN

			SET @Query = '
				IF OBJECT_ID (N''' + @TableName + ''', N''U'') IS NOT NULL
				BEGIN

					UPDATE ' + @TableName + ' SET	
					ValString = NULL,		
					' + @ColumnName + ' = ' + @ResultValue + ',
					IsValidForAlgorithm = 1,
					LastModifiedBy = ' + CAST(@UserId AS varchar) + ',
					LastModifiedOn = ''' + CONVERT(varchar, @AppDate, 109) + ''',
					RealLastModifiedOn = GETDATE(),
					ValidFrom = ''' + CONVERT(varchar, @AppDate, 109) + '''
					WHERE Id = ' + CAST(@RecordId AS varchar) + '
				END'
		END
		ELSE
		BEGIN
		
			SET @Query = '
				IF OBJECT_ID (N''' + @TableName + ''', N''U'') IS NOT NULL
				BEGIN

					INSERT INTO ' + @TableName + ' (' + @ObjectColumnName + ', CechaId, ' + @ColumnName + ', IsValidForAlgorithm, CreatedBy, CreatedOn, ValidFrom, ObowiazujeOd, Priority, UIOrder) VALUES	
					(' + CAST(@RelatedObjectId AS varchar) + ', ' + CAST(@AttributeId AS varchar) + ', ' + @ResultValue + ',1, ' + CAST(@UserId AS varchar) + ', ''' + CONVERT(varchar, @AppDate, 109) + ''', '''
						+ CONVERT(varchar, @AppDate, 109) + ''', ''' + CONVERT(varchar, @AppDate, 109) + ''', 0, 0)
				END'
		
		END

		--PRINT @Query
		EXECUTE sp_executesql @Query					

END
