CREATE TABLE [dbo].[Alg_ObiektyCechy] (
    [SesjaId]               INT                                   NOT NULL,
    [ObiektId]              BIGINT                                NOT NULL,
    [CechaId]               INT                                   NOT NULL,
    [ValString]             NVARCHAR (200)                        NULL,
    [ValInt]                INT SPARSE                            NULL,
    [ValBit]                BIT SPARSE                            NULL,
    [ValFloat]              FLOAT (53) SPARSE                     NULL,
    [ValDecimal]            DECIMAL (12, 5) SPARSE                NULL,
    [ValDate]               DATE SPARSE                           NULL,
    [ValDateTime]           DATETIME SPARSE                       NULL,
    [ColumnsSet]            XML COLUMN_SET FOR ALL_SPARSE_COLUMNS,
    [CreatedOn]             DATETIME                              DEFAULT (getdate()) NOT NULL,
    [Id]                    INT                                   IDENTITY (1, 1) NOT NULL,
    [VirtualTypeId]         SMALLINT                              NOT NULL,
    [IsValidForAlgorithm]   BIT                                   NULL,
    [CalculatedByAlgorithm] INT                                   NULL,
    [AlgorithmRun]          INT                                   NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([ObiektId]) REFERENCES [dbo].[Alg_Obiekty] ([Id]),
    FOREIGN KEY ([SesjaId]) REFERENCES [dbo].[SesjeObliczen] ([Id]),
    CONSTRAINT [FK_Alg_ObiektyCechy] FOREIGN KEY ([CechaId]) REFERENCES [dbo].[Alg_Cechy] ([Id])
);

