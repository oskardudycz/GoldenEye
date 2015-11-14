-- =============================================
-- Author:		DK
-- Create date: 2012-10-19
-- Description:	Zwraca minimalny i maksymalny czas dla następnego przedziału czasowego na podstawie podanej daty.
-- =============================================
CREATE PROCEDURE [THB].[PrepareTimeForNextPeriod]
(
	@AppDate datetime,
	@TimeIntervalId int,
	@MinDate datetime OUTPUT,
	@MaxDate datetime OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @NazwaPrzedzialu nvarchar(50),
			@Rok char(4),
			@Miesiac varchar(2),
			@Godzina varchar(2),
			@Minuta varchar(2),
			@Dzien int,
			@Kwartal int,
			@IloscDniWMiesiacu varchar(2),
			@PrevPeriodMinDate datetime,
			@PrevPeriodMaxDate datetime

	IF @AppDate IS NULL OR @AppDate = '9999-12-31'
		RETURN;
	
	--pobranie dat aktualnego przedzialu	
	EXEC [THB].[PrepareTimePeriods]
		@AppDate = @AppDate,
		@TimeIntervalId = @TimeIntervalId,
		@MinDate = @PrevPeriodMinDate OUTPUT,
		@MaxDate = @PrevPeriodMaxDate OUTPUT

	--pobranie nazwy przedzalu na podstawie jego ID
	SELECT @NazwaPrzedzialu = LOWER(Nazwa)
	FROM Cecha_PrzedzialCzasowy
	WHERE Id = @TimeIntervalId
	
	--ustawienie poniedzialku jako 1 dzien tygodnia
	SET DATEFIRST 1;
	
	--jesli istnieje przedzial czasu o podanym id to wyznaczamy okresy
	IF	@NazwaPrzedzialu IS NOT NULL
	BEGIN
		IF	@NazwaPrzedzialu = 'minuta'
        BEGIN			
			SET @MinDate = DATEADD(mi, 1, @PrevPeriodMinDate);
			SET @MaxDate = DATEADD(mi, 1, @PrevPeriodMaxDate);
        END		
		ELSE IF	@NazwaPrzedzialu = 'godzina'
        BEGIN			
			SET @MinDate = DATEADD(hh, 1, @PrevPeriodMinDate);
			SET @MaxDate = DATEADD(hh, 1, @PrevPeriodMaxDate);
        END
        ELSE IF	@NazwaPrzedzialu = 'zmiana' --8h zmiana robocza
        BEGIN
			SET @MinDate = DATEADD(hh, 8, @PrevPeriodMinDate);
			SET @MaxDate = DATEADD(hh, 8, @PrevPeriodMaxDate);
        END
        ELSE IF	@NazwaPrzedzialu = 'doba'
        BEGIN
			SET @MinDate = DATEADD(dd, 1, @PrevPeriodMinDate);
			SET @MaxDate = DATEADD(dd, 1, @PrevPeriodMaxDate);
        END        
        ELSE IF @NazwaPrzedzialu = 'tydzień'
        BEGIN
			SET @MinDate = DATEADD(wk, 1, @PrevPeriodMinDate);
			SET @MaxDate = DATEADD(wk, 1, @PrevPeriodMaxDate);    
        END        
        ELSE IF @NazwaPrzedzialu = 'miesiąc'
        BEGIN
			SET @MinDate = DATEADD(mm, 1, @PrevPeriodMinDate);
			SET @MaxDate = DATEADD(mm, 1, @PrevPeriodMaxDate); 
        END
        ELSE IF @NazwaPrzedzialu = 'rok'
        BEGIN
			SET @MinDate = DATEADD(yy, 1, @PrevPeriodMinDate);
			SET @MaxDate = DATEADD(yy, 1, @PrevPeriodMaxDate); 		
        END
        ELSE IF @NazwaPrzedzialu = 'kwartał'
        BEGIN
			SET @MinDate = DATEADD(qq, 1, @PrevPeriodMinDate);
			SET @MaxDate = DATEADD(qq, 1, @PrevPeriodMaxDate); 
        END
	
	END
	ELSE
	BEGIN
		SET @MinDate = CONVERT(datetime, ('1900-01-01 00:00:00'));
		SET @MaxDate = CONVERT(datetime, ('1900-01-01 23:59:59'));
	END				
	 
END
