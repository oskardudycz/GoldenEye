
----------------------------------
-- Funkcja split
CREATE FUNCTION [Tmp].[Split]
(    
    @String nvarchar(max), 
    @Delimiter nvarchar(max) = ','
)
RETURNS TABLE AS
RETURN

   WITH csvtbl(start, stop) AS (
     SELECT start = convert(bigint, 1),
            stop = charindex(@Delimiter, @String + @Delimiter)
     UNION ALL
     SELECT start = stop + 1,
            stop = charindex(@Delimiter,
                             @String + @Delimiter, stop + 1)
     FROM   csvtbl
     WHERE  stop > 0
  )

  SELECT dbo.Trim(substring(@String, start, CASE WHEN stop > 0 THEN stop - start ELSE 0 END)) AS Item
  FROM   csvtbl
  WHERE  stop > 0;

