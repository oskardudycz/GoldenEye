-- =============================================
-- Author:		DK
-- Create date: <Create Date, ,>
-- Description:	Funckja sprawdza czy w tekscie filtru wystepuja znaki/slowa nie pozadane.
-- =============================================
CREATE FUNCTION [dbo].PrepareSafeQuery
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
		SET @safeQuery = REPLACE(@query, ' GO ', '');
		SET @safeQuery = REPLACE(@query, ' go ', '');
		SET @safeQuery = REPLACE(@query, ' Go ', '');
		SET @safeQuery = REPLACE(@query, ' gO ', '');
	END
	
	--sprawdzenie czy w komendzie wystepuje slowo delete
	SET @index = CHARINDEX(' delete ' , LOWER(@safeQuery));
	
	IF @index > 0
	BEGIN
		SET @safeQuery = REPLACE(@query, ' delete ', '');
		SET @safeQuery = REPLACE(@query, ' DELETE ', '');
		SET @safeQuery = REPLACE(@query, ' Delete ', '');
		--itp
	END
	
	--sprawdzenie czy w komendzie wystepuje slowo update
	SET @index = CHARINDEX(' update ' , LOWER(@safeQuery));
	
	IF @index > 0
	BEGIN
		SET @safeQuery = REPLACE(@query, ' update ', '');
		SET @safeQuery = REPLACE(@query, ' UPDATE ', '');
		SET @safeQuery = REPLACE(@query, ' Update ', '');
		--itp
	END
	
	RETURN @safeQuery

END
