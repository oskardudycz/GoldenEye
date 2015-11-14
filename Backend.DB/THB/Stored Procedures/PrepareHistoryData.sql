-- =============================================
-- Author:		DK
-- Create date: 2013-02-26
-- Description:	Zwraca minimalny i maksymalny czas obowiazywania dla podanej cechy.
-- =============================================
CREATE PROCEDURE [THB].[PrepareHistoryData]
(
	@AppDate datetime,
	@AttributeTypeId int,
	@MinDate datetime OUTPUT,
	@MaxDate datetime OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PrzedzialCzasowyId int,
			@Sledzona bit

	SELECT @PrzedzialCzasowyId = PrzedzialCzasowyId, @Sledzona = Sledzona
	FROM dbo.Cechy
	WHERE Cecha_Id = @AttributeTypeId;
	
	--jesli podano przedzial czasowy to wyznaczamy przedzial obowiazywania
	IF @PrzedzialCzasowyId IS NOT NULL
	BEGIN
		--pobranie dat obowiazywania na podstawie przedzialu czasowego				
		EXEC [THB].[PrepareTimePeriods]
			@AppDate = @AppDate,
			@TimeIntervalId = @PrzedzialCzasowyId,
			@MinDate = @MinDate OUTPUT,
			@MaxDate = @MaxDate OUTPUT
	
	END
	ELSE
	BEGIN
		--jesli nie podano jednostki okresu obowiazywania to tworzony jest za kazdym razem nowy wpis z dokladna data modyfikacji
		SET @MinDate = ISNULL(@AppDate, GETDATE());
	END	
	
	--pole na razie nie uzywane
	SET @MaxDate = NULL;	
	 
END
