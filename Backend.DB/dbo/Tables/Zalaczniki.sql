CREATE TABLE [dbo].[Zalaczniki] (
    [Zalacznik]    VARBINARY (MAX)  NULL,
    [MD5]          NVARCHAR (MAX)   NULL,
    [Nazwa]        NVARCHAR (200)   NULL,
    [Description]  NVARCHAR (MAX)   NULL,
    [Sciezka]      NVARCHAR (MAX)   NULL,
    [Rozszerzenie] VARCHAR (20)     NULL,
    [IsValid]      BIT              CONSTRAINT [DF__Zalacznik__IsVal__0D9B94C5] DEFAULT ((1)) NULL,
    [ValidFrom]    DATETIME         CONSTRAINT [DF__Zalacznik__Valid__0E8FB8FE] DEFAULT (getdate()) NOT NULL,
    [validTo]      DATETIME         NULL,
    [CreatedBy]    INT              NULL,
    [Created]      DATETIME         CONSTRAINT [DF__Zalacznik__Creat__0F83DD37] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]   INT              NULL,
    [ModifiedOn]   DATETIME         NULL,
    [ZalacznikID]  UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_Zalaczniki] PRIMARY KEY CLUSTERED ([ZalacznikID] ASC)
);

