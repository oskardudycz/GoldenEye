CREATE TABLE [dbo].[Alg_ObiektyRelacje] (
    [SesjaId]      INT      NOT NULL,
    [Id]           BIGINT   IDENTITY (1, 1) NOT NULL,
    [ObiektId_L]   BIGINT   NOT NULL,
    [ObiektId_R]   BIGINT   NOT NULL,
    [TypRelacjiId] INT      NOT NULL,
    [CreatedOn]    DATETIME DEFAULT (getdate()) NOT NULL,
    [RelacjaId]    INT      NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([ObiektId_L]) REFERENCES [dbo].[Alg_Obiekty] ([Id]),
    FOREIGN KEY ([ObiektId_R]) REFERENCES [dbo].[Alg_Obiekty] ([Id]),
    FOREIGN KEY ([SesjaId]) REFERENCES [dbo].[SesjeObliczen] ([Id]),
    FOREIGN KEY ([TypRelacjiId]) REFERENCES [dbo].[Alg_TypyRelacji] ([Id])
);

