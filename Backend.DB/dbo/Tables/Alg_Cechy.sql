CREATE TABLE [dbo].[Alg_Cechy] (
    [SesjaId]   INT            NOT NULL,
    [Id]        INT            IDENTITY (1, 1) NOT NULL,
    [CechaId]   INT            NOT NULL,
    [Typ]       NVARCHAR (20)  NULL,
    [Opis]      NVARCHAR (200) NOT NULL,
    [CreatedOn] DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([SesjaId]) REFERENCES [dbo].[SesjeObliczen] ([Id])
);

