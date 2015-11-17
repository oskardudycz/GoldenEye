-- =============================================
-- Author:		DK
-- Create date: 2012-08-31
-- Description:	Zwraca ilość dni w danym miesiacu i roku.
-- =============================================
CREATE FUNCTION [THB].[GetNumberOfDaysInMonth] (@date datetime)
RETURNS int
AS
BEGIN
	DECLARE @daysNumber int
 
	SET @daysNumber = 
		CASE 
			WHEN MONTH(@date) IN (1, 3, 5, 7, 8, 10, 12) THEN 31
			WHEN MONTH(@date) IN (4, 6, 9, 11) THEN 30
			ELSE 
				CASE 
					WHEN (YEAR(@date) % 4 = 0 AND YEAR(@date) % 100 != 0)
						OR (YEAR(@date) % 400 = 0) THEN 29
					ELSE 28 
				END
		END
	
	RETURN @daysNumber
END