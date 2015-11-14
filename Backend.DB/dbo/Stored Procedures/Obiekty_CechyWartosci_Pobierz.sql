
-- =============================================
-- Author:		DW
-- Create date: 2011-12-05
-- Description:	zwraca listę obiektów dla wartości cech z danego zakresu
-- =============================================
CREATE PROCEDURE [dbo].[Obiekty_CechyWartosci_Pobierz]
(
	@xml xml
	,@xml_output xml OUTPUT
)AS
BEGIN
--declare @xml xml = 
--'<root TypObiektId="10">
--	<Cecha id="5" valMin="0" valMax="10" />
--	<Cecha id="38" valMin="0" valMax="1" />
--</root>'

DECLARE @TypObiektID INT = (
		SELECT 
			C.value('./@id','int') 
		FROM @xml.nodes('/root/TypObiekt') T(C)
)

--select @TypObiektID

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
END as typ_kol, TP.TypObiekt_ID, '[_'+Tp.Nazwa+'_Cechy_Hist]' as TabHist
INTO #VAL
FROM Cechy C JOIN Cecha_Typy T
ON C.TypID = T.Id
CROSS JOIN TypObiektu Tp
JOIN #Cechy CC ON CC.ID  =C.Cecha_ID
WHERE Tp.TypObiekt_ID = @TypObiektID AND @TypObiektID IS NOT NULL OR @TypObiektID IS NULL

--select * from #VAL


DECLARE @Nazwa nvarchar(MAX), @TabHist nvarchar(MAX)
,@cechaID INT, @valMax nvarchar(max), @valMin nvarchar(max), @typKol nvarchar(50)
declare @sql nvarchar(MAX)=''


DECLARE cur CURSOR FOR
	select Cecha_ID, valmax,valMin,typ_kol,TypObiekt_ID,TabHist
	from #VAL 
OPEN cur
FETCH NEXT FROM cur INTO @cechaID,@valMax,@valMin,@typKol, @TypObiektID,  @TabHist
WHILE @@FETCH_STATUS=0
BEGIN
	SET @sql = @Sql+  '
	SELECT ObiektID, '+ CAST(@TypObiektID as varchar)+' as TypObiektID 
	FROM '+@TabHist +'H 
	WHERE CechaID= '+CAST(@cechaID as varchar)+'
	AND '+@typKol+' BETWEEN '''+@valMin+''' AND '''+@valMax+'''
	AND [IdArch] IS NULL
	UNION ALL'

	

	FETCH NEXT FROM cur INTO @cechaID,@valMax,@valMin,@typKol, @TypObiektID,  @TabHist
END
CLOSE cur
DEALLOCATE cur

SET @SQL = SUBSTRING(@sql, 1 ,LEN(@sql)-9)
SET @SQL = 'SELECT DISTINCT ObiektID, TypObiektID FROM ('+@SQL+')X FOR XML AUTO, ROOT(''root'')'
SET @SQL = 'SET @xmlOutVar=('+@SQL+')'

DECLARE @ParamDefinition nvarchar(512)
DECLARE @xmlOut xml
	
SET @ParamDefinition = N'@xmlOutVar xml OUTPUT'
print(@SQL)

EXECUTE sp_executesql @SQL, @ParamDefinition, @xmlOutVar=@xmlOut OUTPUT
	--SET @xmlVar = '<root>'
SET @xml_output = CAST(@xmlOut as nvarchar(MAX))

DROP TABLE #Cechy
drop table #VAL


END

