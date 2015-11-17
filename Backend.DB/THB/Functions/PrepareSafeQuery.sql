-- =============================================
-- Author:		DK
-- Create date: <Create Date, ,>
-- Description:	Funckja sprawdza czy w tekscie filtru wystepuja znaki/slowa nie pozadane.
-- =============================================
CREATE FUNCTION [THB].PrepareSafeQuery
(
	@query nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @safeQuery nvarchar(MAX);
	DECLARE @index int;

	SET @safeQuery = REPLACE(@query, ';', '');
	
	--sprawdzenie czy w komendzie wystepuje slowo go
	SET @index = CHARINDEX(' go ' , LOWER(@safeQuery));
	
	IF @index > 0
	BEGIN
		SET @safeQuery = REPLACE(@safeQuery, ' GO ', '');
		SET @safeQuery = REPLACE(@safeQuery, ' go ', '');
		SET @safeQuery = REPLACE(@safeQuery, ' Go ', '');
		SET @safeQuery = REPLACE(@safeQuery, ' gO ', '');
	END
	
	--sprawdzenie czy w komendzie wystepuje slowo delete
	SET @index = CHARINDEX(' delete ' , LOWER(@safeQuery));
	
	IF @index > 0
	BEGIN
		SET @safeQuery = REPLACE(@safeQuery, ' delete ', '');
		SET @safeQuery = REPLACE(@safeQuery, ' DELETE ', '');
		SET @safeQuery = REPLACE(@safeQuery, ' Delete ', '');
		--itp
	END
	
	--sprawdzenie czy w komendzie wystepuje slowo update
	SET @index = CHARINDEX(' update ' , LOWER(@safeQuery));
	
	IF @index > 0
	BEGIN
		SET @safeQuery = REPLACE(@safeQuery, ' update ', '');
		SET @safeQuery = REPLACE(@safeQuery, ' UPDATE ', '');
		SET @safeQuery = REPLACE(@safeQuery, ' Update ', '');
		--itp
	END
	
	RETURN @safeQuery

END
