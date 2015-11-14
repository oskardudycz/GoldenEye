CREATE TABLE [dbo].[Algorytmy_Uruchomienia] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [AlgorytmId]   SMALLINT       NOT NULL,
    [LastRunTime]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastRunId]    INT            NOT NULL,
    [ExecutedBy]   INT            NOT NULL,
    [Succeeded]    BIT            DEFAULT ((0)) NOT NULL,
    [ErrorMessage] NVARCHAR (500) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([AlgorytmId]) REFERENCES [dbo].[Algorytmy] ([Id]),
    FOREIGN KEY ([ExecutedBy]) REFERENCES [dbo].[Uzytkownicy] ([Id])
);

