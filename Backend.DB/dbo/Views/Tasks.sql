CREATE VIEW [dbo].[Tasks]
AS
SELECT 
	  [ObiektId]							  AS [Id]
	, MIN([Zlecenie - nazwa/nr Zlecenia])     AS [TaskName]
	, MIN([Zlecenie - Zleceniodawca])         AS [Customer]
	, MIN([Zlecenie - kolor Zleceniodawcy])   AS [CustomerColor]
	, MIN([Zlecenie - Data przyjęcia])		  AS [Date]
	, MIN([Zlecenie - rodzaj/przedmiot])      AS [Type]
	, MIN([Zlecenie - Czy wewnętrzne])        AS [IsInternal]
	, MIN([Zlecenie - Ilość])                 AS [Amount]
	, MIN([Zlecenie - plan czas trwania])     AS [PlannedTime]
	, MIN([Zlecenie - Termin rozp planowany]) AS [PlannedStartDate]
	, MIN([Zlecenie - termin zak planowany])  AS [PlannedEndDate]
	, MIN([Zlecenie - kolor Zlecenia])	      AS [Color]
	, MIN([Zlecenie - data zaplanowania])     AS [PlanningDate]
	, MIN([Zlecenie - opis])				  AS [Description]
FROM
(
  SELECT  
		zc.[Id]
      , zc.[ObiektId]
      , zc.[CechaId]
	  , c.[Nazwa]
      , CAST(
			ISNULL( 
				CAST(zc.[ColumnsSet] as XML).value('(node())[1]', 'varchar(50)'), 
				ValString
			) as VARCHAR(MAX)
		) as Value
  FROM 
	[dbo].[_Zlecenie  nietabelaryczne_Cechy_Hist] zc
  INNER JOIN [dbo].[Cechy] c
	ON zc.CechaID = c.Cecha_ID
  WHERE zc.IsValid = 1 And zc.IsDeleted = 0
) AS p
PIVOT 
(
	MIN(p.Value)
	FOR Nazwa IN (  [Zlecenie - Zleceniodawca] 
				  , [Zlecenie - kolor Zleceniodawcy] 
				  , [Zlecenie - Data przyjęcia]
				  , [Zlecenie - nazwa/nr Zlecenia]
				  , [Zlecenie - rodzaj/przedmiot]
				  , [Zlecenie - Czy wewnętrzne]
				  , [Zlecenie - Ilość]
				  , [Zlecenie - plan czas trwania]
				  , [Zlecenie - Termin rozp planowany]
				  , [Zlecenie - termin zak planowany]
				  , [Zlecenie - kolor Zlecenia]
				  , [Zlecenie - data zaplanowania]
				  , [Zlecenie - opis])
)
AS pvt
GROUP BY ObiektId