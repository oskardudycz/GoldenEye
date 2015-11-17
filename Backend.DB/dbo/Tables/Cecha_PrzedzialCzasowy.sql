CREATE TABLE [dbo].[Cecha_PrzedzialCzasowy] (
    [Id]    INT           NOT NULL,
    [Nazwa] NVARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Nazwa] ASC)
);

