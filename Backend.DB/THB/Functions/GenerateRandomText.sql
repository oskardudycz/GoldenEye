-- =============================================
-- Author:		DK
-- Create date: 2012-09-07
-- Description:	Funckja zwraca losowy tekst.
-- =============================================
CREATE FUNCTION [THB].[GenerateRandomText]
(
    @Length int = 256
)
RETURNS nvarchar(255)
AS
BEGIN
	DECLARE @text nvarchar(255)

	--CONVERT(varchar(255), NEWID())
   -- SET @text = CAST(CRYPT_GEN_RANDOM(@Length) AS varchar(255))

	 DECLARE @pool nvarchar(100)
	 DECLARE @counter int
	 DECLARE @rand float
	 DECLARE @pos int

	 SET @pool = 'abcdefghijklmnopqrstuvwxyząęćłóżźńABCDEFGHIJKLMNOPQRSTUVWXYZĄĘŁÓŃŚŻŹĆ1234567890@#$%^&*()-_[]'
	 SET @counter = 1
	 SET @text = ''

	 WHILE @counter <= @length
	 BEGIN
	 SET @counter = @counter + 1
	 SET @rand = (SELECT random FROM RandomNumberView)
	 SET @pos = ceiling(@rand *(len(@pool)))
	 SET @text +=  substring(@pool, @pos, 1)
	 END

	RETURN @text;
END

