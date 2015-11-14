CREATE TABLE [dbo].[Wersja] (
    [Id]        INT          IDENTITY (1, 1) NOT NULL,
    [Numer]     VARCHAR (10) NOT NULL,
    [ValidFrom] DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Numer] ASC)
);

