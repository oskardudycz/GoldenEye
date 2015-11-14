CREATE TABLE [dbo].[Alg_Obiekty] (
    [Id]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [SesjaId]         INT            NOT NULL,
    [ObiektId]        INT            NOT NULL,
    [TypObiektuId]    INT            NOT NULL,
    [OpisGeneric]     NVARCHAR (50)  NULL,
    [Opis]            NVARCHAR (200) NOT NULL,
    [InstanceId]      INT            NOT NULL,
    [CreatedOn]       DATETIME       DEFAULT (getdate()) NOT NULL,
    [KorzenStruktury] BIT            DEFAULT ((0)) NOT NULL,
    [LiscStruktury]   BIT            DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([SesjaId]) REFERENCES [dbo].[SesjeObliczen] ([Id])
);

