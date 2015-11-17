-- =============================================
-- Author:		DK
-- Create date: 2012-08-30
-- Description:	Zwraca minimalny i maksymalny czas dla podanego przedzialu czasowego na podstawie podanej daty.
-- =============================================
CREATE PROCEDURE [THB].[PrepareTimePeriods]
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
			@IloscDniWMiesiacu varchar(2)

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
			--pobranie aktualnej godziny
			SET @Godzina = DATEPART(hour, @AppDate);
			SET @Minuta = DATEPART(minute, @AppDate);
			
			IF LEN(@Godzina) = 1
				SET @Godzina = '0' + @Godzina;
				
			IF LEN(@Minuta) = 1
				SET @Minuta = '0' + @Minuta;
			
			SET @MinDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' ' + @Godzina + ':' + @Minuta + ':00'));
			SET @MaxDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' ' + @Godzina + ':' + @Minuta + ':59'));
        END		
		ELSE IF	@NazwaPrzedzialu = 'godzina'
        BEGIN
			--pobranie aktualnej godziny
			SET @Godzina = DATEPART(hour, @AppDate);
			
			IF LEN(@Godzina) = 1
				SET @Godzina = '0' + @Godzina;
			
			SET @MinDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' ' + @Godzina + ':00:00'));
			SET @MaxDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' ' + @Godzina + ':59:59'));
        END
        ELSE IF	@NazwaPrzedzialu = 'zmiana' --8h zmiana robocza
        BEGIN
			--pobranie aktualnej godziny
			SET @Kwartal = DATEPART(hour, @AppDate);
			
			IF @Kwartal >= 0 AND @Kwartal < 8 -- I zmiana
			BEGIN
				SET @MinDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' 00:00:00'));
				SET @MaxDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' 07:59:59'));
			END
			ELSE IF @Kwartal > 7 AND @Kwartal < 16 -- II zmiana
			BEGIN
				SET @MinDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' 08:00:00'));
				SET @MaxDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' 15:59:59'));
			END
			ELSE IF @Kwartal > 16 AND @Kwartal < 24 -- III zmiana
			BEGIN
				SET @MinDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' 16:00:00'));
				SET @MaxDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' 23:59:59'));
			END
        END
        ELSE IF	@NazwaPrzedzialu = 'doba'
        BEGIN
			SET @MinDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' 00:00:00'));
			SET @MaxDate = CONVERT(datetime, (CONVERT(varchar, @AppDate, 112) + ' 23:59:59'));
        END        
        ELSE IF @NazwaPrzedzialu = 'tydzień'
        BEGIN
			--SET @Tydzien = DATEPART(week, @AppDate); 
			--SET @Rok = DATEPART(YEAR, @AppDate);
			SET @Dzien = DATEPART(weekday, @AppDate);
			
			-- obliczenie zakresu dat na podstawie numeru aktualnego tygodnia i 7 dni
			SET @MinDate = CONVERT(datetime, (CONVERT(varchar, DATEADD(day, ((@Dzien-1) * -1), @AppDate), 112) + ' 00:00:00'));
			SET @MaxDate = CONVERT(datetime, (CONVERT(varchar, DATEADD(day, 6, @MinDate), 112) + ' 23:59:59')); 

			--SET @MinDate = DATEADD(week, DATEDIFF(week, 6, '1/1/' + @Rok) + (@Tydzien - 1), 6);
			--SET @MaxDate = CONVERT(datetime, (CONVERT(varchar, DATEADD(week, DATEDIFF(week, 5, '1/1/' + @Rok) + (@Tydzien - 1), 5), 112) + ' 23:59:59'));    
        END        
        ELSE IF @NazwaPrzedzialu = 'miesiąc'
        BEGIN
			--pobranie aktualnego roku i miesiaca
			SET @Rok = DATEPART(YEAR, @AppDate);
			SET @Miesiac = DATEPART(MONTH, @AppDate);
			
			IF LEN(@Miesiac) = 1
				SET @Miesiac = '0' + @Miesiac;
				
			SET @MinDate = CONVERT(datetime, (@Rok + '-' + @Miesiac + '-01 00:00:00'));
			SET @MaxDate = CONVERT(datetime, (@Rok + '-' + @Miesiac + '-' + CAST(THB.GetNumberOfDaysInMonth(@AppDate) AS varchar) + ' 23:59:59'));
			
        END
        ELSE IF @NazwaPrzedzialu = 'rok'
        BEGIN
			--pobranie aktualnego roku i miesiaca
			SET @Rok = DATEPART(YEAR, @AppDate);
				
			SET @MinDate = CONVERT(datetime, (@Rok + '-' + '01-01 00:00:00'));
			SET @MaxDate = CONVERT(datetime, (@Rok + '-' + '12-31 23:59:59'));			
        END
        ELSE IF @NazwaPrzedzialu = 'kwartał'
        BEGIN
			--pobranie roku i kwartału
			SET @Rok = DATEPART(YEAR, @AppDate);
			SET @Kwartal = DATEPART(quarter, @AppDate);
			
			--ustawienie dat w zaleznosci od kwartalu
			IF @Kwartal = 1
			BEGIN
				SET @MinDate = CONVERT(datetime, (@Rok + '-01-01 00:00:00'));
				SET @MaxDate = CONVERT(datetime, (@Rok + '-03-31 23:59:59'));
			END
			ELSE IF @Kwartal = 2
			BEGIN
				SET @MinDate = CONVERT(datetime, (@Rok + '-04-01 00:00:00'));
				SET @MaxDate = CONVERT(datetime, (@Rok + '-06-30 23:59:59'));
			END
			ELSE IF @Kwartal = 3
			BEGIN
				SET @MinDate = CONVERT(datetime, (@Rok + '-07-01 00:00:00'));
				SET @MaxDate = CONVERT(datetime, (@Rok + '-09-30 23:59:59'));
			END
			ELSE IF @Kwartal = 4
			BEGIN
				SET @MinDate = CONVERT(datetime, (@Rok + '-10-01 00:00:00'));
				SET @MaxDate = CONVERT(datetime, (@Rok + '-12-31 23:59:59'));
			END
        END
	
	END
	ELSE
	BEGIN
		SET @MinDate = CONVERT(datetime, ('1900-01-01 00:00:00'));
		SET @MaxDate = CONVERT(datetime, ('1900-01-01 23:59:59'));
	END				
	 
END
