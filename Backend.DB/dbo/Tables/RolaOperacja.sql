CREATE TABLE [dbo].[RolaOperacja] (
    [Rola]               INT             NOT NULL,
    [Operacja]           INT             NOT NULL,
    [Branza]             INT             NOT NULL,
    [ObowiazujeOd]       DATETIME        NULL,
    [ObowiazujeDo]       DATETIME SPARSE NULL,
    [CreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          INT             NULL,
    [LastModifiedOn]     DATETIME SPARSE NULL,
    [LastModifiedBy]     INT SPARSE      NULL,
    [RealCreatedOn]      DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn] DATETIME SPARSE NULL,
    CONSTRAINT [PK_RolaOperacja] PRIMARY KEY CLUSTERED ([Rola] ASC, [Operacja] ASC, [Branza] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_RolaOperacja_Branza] FOREIGN KEY ([Branza]) REFERENCES [dbo].[Branze] ([Id]),
    CONSTRAINT [FK_RolaOperacja_Operacja] FOREIGN KEY ([Operacja]) REFERENCES [dbo].[Operacje] ([Id]),
    CONSTRAINT [FK_RolaOperacja_Rola] FOREIGN KEY ([Rola]) REFERENCES [dbo].[Role] ([Id])
);

