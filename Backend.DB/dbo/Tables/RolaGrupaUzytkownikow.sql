CREATE TABLE [dbo].[RolaGrupaUzytkownikow] (
    [GrupaUzytkownikow]  INT             NOT NULL,
    [Rola]               INT             NOT NULL,
    [ObowiazujeOd]       DATETIME        NULL,
    [ObowiazujeDo]       DATETIME SPARSE NULL,
    [IsValid]            BIT             DEFAULT ((1)) NOT NULL,
    [ValidFrom]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [ValidTo]            DATETIME SPARSE NULL,
    [IsDeleted]          BIT             DEFAULT ((0)) NOT NULL,
    [DeletedFrom]        DATETIME SPARSE NULL,
    [DeletedBy]          INT SPARSE      NULL,
    [CreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          INT             NULL,
    [LastModifiedOn]     DATETIME SPARSE NULL,
    [LastModifiedBy]     INT SPARSE      NULL,
    [RealCreatedOn]      DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn] DATETIME SPARSE NULL,
    [RealDeletedFrom]    DATETIME SPARSE NULL,
    [RealArchivedFrom]   DATETIME        NULL,
    CONSTRAINT [PK_RolaGrupaUzytkownikow] PRIMARY KEY CLUSTERED ([GrupaUzytkownikow] ASC, [Rola] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_RolaGrupaUzytkownikow_GrupyUzytkownikow] FOREIGN KEY ([GrupaUzytkownikow]) REFERENCES [dbo].[GrupyUzytkownikow] ([Id]),
    CONSTRAINT [FK_RolaGrupaUzytkownikow_Role] FOREIGN KEY ([Rola]) REFERENCES [dbo].[Role] ([Id])
);

