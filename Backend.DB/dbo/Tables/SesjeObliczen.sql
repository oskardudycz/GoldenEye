CREATE TABLE [dbo].[SesjeObliczen] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [NazwaObliczen] NVARCHAR (100) NOT NULL,
    [DataObliczen]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [UserId]        INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

