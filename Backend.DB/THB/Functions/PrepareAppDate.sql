-- =============================================
-- Author:		DK
-- Create date: 18.07.2012
-- Last modified on: 2012-09-06
-- Description:	Funckja tworzy date na podstawie daty aplikacji i aktualnej godziny z serwera.
-- =============================================
CREATE FUNCTION [THB].[PrepareAppDate]
(
	@AppDate datetime
)
RETURNS datetime
AS
BEGIN
	--DECLARE @Time time,
	--	@Date date,
	--	@ValueStr nvarchar(23),
	--	@Value datetime
	
	--SELECT @Time = CAST(GETDATE() AS time);
	--SELECT @Date = CAST(ISNULL(@AppDate, GETDATE()) AS date);
	
	--SET @ValueStr = CAST(@Date AS nvarchar) + ' ' + CAST(@Time AS nvarchar);
	--SET @Value = CAST(@ValueStr AS datetime);
	
	--RETURN @Value
	
	RETURN ISNULL(@AppDate, GETDATE());
END