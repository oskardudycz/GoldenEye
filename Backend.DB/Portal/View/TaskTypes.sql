CREATE VIEW [Portal].[TaskTypes]
AS 
	SELECT
		c.[Id]        AS [Id],
		c.[Nazwa]     AS [Name],
		c.[IsDeleted] AS [IsDeleted]
	FROM
		dbo._Slownik_Zleceniodawca c;