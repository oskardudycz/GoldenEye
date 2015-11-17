CREATE TABLE [dbo].[Algorytmy] (
    [Id]        SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Nazwa]     NVARCHAR (100) NOT NULL,
    [CreatedOn] DATETIME       DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Algorytmy] PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Nazwa] ASC)
);

