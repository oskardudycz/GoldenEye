CREATE TABLE [dbo].[Alg_TypyRelacji] (
    [SesjaId]            INT            NOT NULL,
    [Id]                 INT            IDENTITY (1, 1) NOT NULL,
    [TypRelacjiId]       INT            NOT NULL,
    [BazowyTypRelacjiid] INT            NOT NULL,
    [Nazwa]              NVARCHAR (100) NOT NULL,
    [CreatedOn]          DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([SesjaId]) REFERENCES [dbo].[SesjeObliczen] ([Id])
);

