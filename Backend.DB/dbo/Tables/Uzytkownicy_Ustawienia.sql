CREATE TABLE [dbo].[Uzytkownicy_Ustawienia] (
    [UzytkownikId]   INT            NOT NULL,
    [Klucz]          NVARCHAR (20)  NOT NULL,
    [Wartosc]        NVARCHAR (300) NOT NULL,
    [CreatedOn]      DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastModifiedOn] DATETIME       NULL,
    [DeletedFrom]    DATETIME       NULL,
    [IsValid]        BIT            DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([UzytkownikId] ASC, [Klucz] ASC),
    CONSTRAINT [CHK_Uzytkownicy_Ustawienia_NiePuste] CHECK ([Klucz]<>'' AND [Wartosc]<>''),
    FOREIGN KEY ([UzytkownikId]) REFERENCES [dbo].[Uzytkownicy] ([Id])
);

