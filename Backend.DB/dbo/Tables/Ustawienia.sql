CREATE TABLE [dbo].[Ustawienia] (
    [Klucz]          VARCHAR (100)  NOT NULL,
    [Wartosc]        NVARCHAR (100) NOT NULL,
    [CreatedOn]      DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      INT            NOT NULL,
    [LastModifiedOn] DATETIME       NULL,
    [LastModifiedBy] INT            NULL,
    [TypPola]        SMALLINT       DEFAULT ((3)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Klucz] ASC),
    FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Uzytkownicy] ([Id]),
    FOREIGN KEY ([LastModifiedBy]) REFERENCES [dbo].[Uzytkownicy] ([Id])
);

