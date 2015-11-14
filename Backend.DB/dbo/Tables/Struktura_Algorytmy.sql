CREATE TABLE [dbo].[Struktura_Algorytmy] (
    [StrukturaId]    INT                                                             NOT NULL,
    [Algorytm]       XML(CONTENT [dbo].[Schema_CompositeArithmeticOperation_Column]) NOT NULL,
    [CreatedOn]      DATETIME                                                        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      INT                                                             DEFAULT ((1)) NOT NULL,
    [LastModifiedOn] DATETIME                                                        NULL,
    [LastModifiedBy] INT                                                             NULL,
    CONSTRAINT [PK_Struktura_Algorytmy] PRIMARY KEY CLUSTERED ([StrukturaId] ASC),
    CONSTRAINT [FK_Struktura_Algorytmy_Struktura] FOREIGN KEY ([StrukturaId]) REFERENCES [dbo].[Struktura_Obiekt] ([Id])
);

