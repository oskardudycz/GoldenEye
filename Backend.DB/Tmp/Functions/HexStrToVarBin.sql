-----------------------------------------------------
----zamienia string na varbinary
CREATE FUNCTION [Tmp].HexStrToVarBin(@hexstr VARCHAR(8000))  
RETURNS varbinary(8000)  
AS  
BEGIN  
   DECLARE @hex CHAR(2), @i INT, @count INT, @b varbinary(8000), @odd BIT, @start bit 
   SET @count = LEN(@hexstr)  
   SET @start = 1 
   SET @b = CAST('' AS varbinary(1))  
   IF SUBSTRING(@hexstr, 1, 2) = '0x'  
       SET @i = 3  
   ELSE  
       SET @i = 1  
   SET @odd = CAST(LEN(SUBSTRING(@hexstr, @i, LEN(@hexstr))) % 2 AS BIT) 
   WHILE (@i <= @count)  
    BEGIN  
       IF @start = 1 AND @odd = 1 
       BEGIN 
           SET @hex = '0' + SUBSTRING(@hexstr, @i, 1) 
       END 
       ELSE 
       BEGIN 
           SET @hex = SUBSTRING(@hexstr, @i, 2) 
       END 
       SET @b = @b +  
               CAST(CASE WHEN SUBSTRING(@hex, 1, 1) LIKE '[0-9]'  
                   THEN CAST(SUBSTRING(@hex, 1, 1) AS INT)  
                   ELSE CAST(ASCII(UPPER(SUBSTRING(@hex, 1, 1)))-55 AS INT)  
               END * 16 +  
               CASE WHEN SUBSTRING(@hex, 2, 1) LIKE '[0-9]'  
                   THEN CAST(SUBSTRING(@hex, 2, 1) AS INT)  
                   ELSE CAST(ASCII(UPPER(SUBSTRING(@hex, 2, 1)))-55 AS INT)  
               END AS binary(1))  
       SET @i = @i + (2 - (CAST(@start AS INT) * CAST(@odd AS INT))) 
       IF @start = 1 
       BEGIN 
           SET @start = 0 
       END 
    END  
    RETURN @b  
END  

