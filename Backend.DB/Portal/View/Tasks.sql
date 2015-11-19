CREATE VIEW [Portal].[Tasks]
AS
SELECT 
      [ObiektId]													   AS [Id]
    , CAST( MIN([TaskName])						    AS NVARCHAR(MAX))  AS [Name]
    , CAST( MIN([Zlecenie - nazwa/nr Zlecenia])	    AS NVARCHAR(MAX))  AS [Number]
    , CAST( MIN([Zlecenie - Zleceniodawca])         AS INT)			   AS [CustomerId]
    , CAST( MIN([Zlecenie - kolor Zleceniodawcy])   AS INT)			   AS [CustomerColor]
    , CAST( MIN([Zlecenie - Data przyjęcia])	    AS DATETIME)	   AS [Date]
    , CAST( MIN([Zlecenie - rodzaj/przedmiot])      AS INT)			   AS [TypeId]
    , CAST( CASE MIN([Zlecenie - Czy wewnętrzne]) 
        WHEN 1 THEN 1 ELSE 0 END			        AS BIT)			   AS [IsInternal]
    , CAST( MIN([Zlecenie - Ilość])				    AS INT)		       AS [Amount]
    , CAST( MIN([Zlecenie - plan czas trwania])	    AS INT)	           AS [PlannedTime]
    , CAST( MIN([Zlecenie - Termin rozp planowany])	AS DATETIME)	   AS [PlannedStartDate]
    , CAST( MIN([Zlecenie - termin zak planowany])	AS DATETIME)	   AS [PlannedEndDate]
    , CAST( MIN([Zlecenie - kolor Zlecenia])		AS INT)			   AS [Color]
    , CAST( MIN([Zlecenie - data zaplanowania])		AS DATETIME)	   AS [PlanningDate]
    , CAST( MIN([Zlecenie - opis])					AS NVARCHAR(MAX))  AS [Description]
    , CAST( MIN([ModificationDate])					AS DATETIME)	   AS [ModificationDate]
FROM																	  
(
  SELECT  
        zc.[Id]       AS [Id]
      , zc.[ObiektId] AS [ObiektId]
      , zc.[CechaId]  AS [CechaId]
      , c.[Nazwa]     AS [Nazwa]
      , z.[Nazwa]     AS [TaskName]
      , z.[ValidFrom] AS [ModificationDate]
      , CAST(
            ISNULL( 
                CAST(zc.[ColumnsSet] AS XML).value('(node())[1]', 'varchar(50)'), 
                ValString
            ) AS VARCHAR(MAX)
        ) AS Value
  FROM 
    [dbo].[_Zlecenie  nietabelaryczne] z
  INNER JOIN [dbo].[_Zlecenie  nietabelaryczne_Cechy_Hist] zc
    ON z.Id = zc.ObiektId
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