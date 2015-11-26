CREATE VIEW [Portal].[ModelerUsers]
AS 
    SELECT 
       u.[Id]          AS [Id],
       u.[Login]       AS [Login],
       u.[Imie]        AS [FirstName],
       u.[Nazwisko]    AS [LastName],
       u.[Email]       AS [Email],
       u.[Haslo]       AS [Password],
       u.[Aktywny]     AS [IsActive],
       u.[IsValid]     AS [IsValid],
       u.[IsDeleted]   AS [IsDeleted]
   FROM dbo.Uzytkownicy u;
