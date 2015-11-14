
-- =============================================
-- Author:		DW
-- Create date: 2011-12-08
-- Description:	zwraca listę obiektów dla wartości cech z danego zakresu
-- oraz określonego typu relacji
-- =============================================
CREATE PROCEDURE [dbo].[Relacje_CechyWartosci_Pobierz]
(
	@xml xml
	,@xml_output xml OUTPUT
)AS
BEGIN

DECLARE @TypRelacjaID INT = (
		SELECT 
			C.value('./@id','int') 
		FROM @xml.nodes('/root/TypRelacja') T(C)
)

SELECT 
	C.value('./@id','int') as ID
	,C.value('./@valMin','nvarchar(MAX)') as valMin
	,C.value('./@valMax','nvarchar(MAX)') as valMax
INTO #Cechy
FROM @xml.nodes('/root/Cecha') T(C)

select C.Cecha_ID, CC.valMax,CC.valMin
, CASE T.NazwaSQL
	WHEN 'bit' THEN '[ValBit]'
	WHEN 'int' THEN '[ValInt]'
	WHEN 'float' THEN '[ValFloat]'
	WHEN 'decimal(18,5)' THEN '[ValDecimal]'
	WHEN 'date' THEN '[ValDate]'
	WHEN 'datetime' THEN '[ValDatetime]'
	WHEN 'time' THEN '[ValTime]'
	ELSE '[ValString]'
END as typ_kol
INTO #VAL
FROM Cechy C JOIN Cecha_Typy T
ON C.TypID = T.Id
JOIN #Cechy CC ON CC.ID  =C.Cecha_ID


DECLARE @cechaID INT, @valMax nvarchar(max), @valMin nvarchar(max), @typKol nvarchar(50)
declare @sql nvarchar(MAX)=''

DECLARE cur CURSOR FOR
SELECT Cecha_ID,valMax,valMin, typ_kol 
FROM #VAL V
OPEN cur
FETCH NEXT FROM CUR  into @cechaID,@valMax,@valMin,@typKol
WHILE @@FETCH_STATUS=0
BEGIN
	SET @sql = @Sql+  '
	SELECT  RCH.RelacjaID
	FROM Relacje R JOIN Relacja_Cecha_Hist RCH ON RCH.RelacjaID = R.Id
	WHERE CechaID= '+CAST(@cechaID as varchar)+'
	AND '+@typKol+' BETWEEN '''+@valMin+''' AND '''+@valMax+'''
	AND R.[IdArch] IS NULL AND RCH.[IdArch] IS NULL 
	UNION ALL'

	FETCH NEXT FROM CUR  into @cechaID,@valMax,@valMin,@typKol
END

SET @SQL = SUBSTRING(@sql, 1 ,LEN(@sql)-9)
SET @SQL = 'SELECT DISTINCT RelacjaID FROM ('+@SQL+')X FOR XML AUTO, ROOT(''root'')'
SET @SQL = 'SET @xmlOutVar=('+@SQL+')'

DECLARE @ParamDefinition nvarchar(512)
DECLARE @xmlOut xml
	
SET @ParamDefinition = N'@xmlOutVar xml OUTPUT'
print(@SQL)

EXECUTE sp_executesql @SQL, @ParamDefinition, @xmlOutVar=@xmlOut OUTPUT
SET @xml_output = CAST(@xmlOut as nvarchar(MAX))


DROP TABLE #Cechy
drop table #VAL


END

