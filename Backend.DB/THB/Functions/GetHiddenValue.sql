-- DK
-- Created on: 2012-09-21
-- Funkcja zwraca tekst który bedzie pokazywany dla cech danych osonowych.
-----------------------------------------
CREATE FUNCTION [THB].[GetHiddenValue]()
RETURNS varchar(5)
AS 
BEGIN
  
	DECLARE @hiddenValue varchar(5) = '*****';

	RETURN @hiddenValue
END