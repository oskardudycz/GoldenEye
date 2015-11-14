CREATE TABLE [dbo].[GrupaUzytkownikowUzytkownik] (
    [GrupaUzytkownikow]  INT             NOT NULL,
    [Uzytkownik]         INT             NOT NULL,
    [ObowiazujeOd]       DATETIME        NULL,
    [ObowiazujeDo]       DATETIME SPARSE NULL,
    [LastModifiedOn]     DATETIME SPARSE NULL,
    [LastModifiedBy]     INT SPARSE      NULL,
    [CreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          INT             NULL,
    [IsValid]            BIT             DEFAULT ((1)) NOT NULL,
    [ValidFrom]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [ValidTo]            DATETIME SPARSE NULL,
    [IsDeleted]          BIT             DEFAULT ((0)) NOT NULL,
    [DeletedFrom]        DATETIME SPARSE NULL,
    [DeletedBy]          INT SPARSE      NULL,
    [RealCreatedOn]      DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn] DATETIME SPARSE NULL,
    [RealDeletedFrom]    DATETIME SPARSE NULL,
    [RealArchivedFrom]   DATETIME        NULL,
    CONSTRAINT [PK_GrupaUzytkownikowUzytkownik] PRIMARY KEY CLUSTERED ([GrupaUzytkownikow] ASC, [Uzytkownik] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_GrupaUzytkownikowUzytkownik_Grupa] FOREIGN KEY ([GrupaUzytkownikow]) REFERENCES [dbo].[GrupyUzytkownikow] ([Id]),
    CONSTRAINT [FK_GrupaUzytkownikowUzytkownik_Uzytkownik] FOREIGN KEY ([Uzytkownik]) REFERENCES [dbo].[Uzytkownicy] ([Id])
);

