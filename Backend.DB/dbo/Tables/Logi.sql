CREATE TABLE [dbo].[Logi] (
    [Id]      INT      IDENTITY (1, 1) NOT NULL,
    [Date]    DATETIME DEFAULT (getdate()) NOT NULL,
    [XmlIn]   XML      NOT NULL,
    [XmlOut]  XML      NOT NULL,
    [IsError] BIT      NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

