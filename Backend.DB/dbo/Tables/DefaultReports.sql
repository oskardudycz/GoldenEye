CREATE TABLE [dbo].[DefaultReports] (
    [Id]               NVARCHAR (36)   NOT NULL,
    [ReportName]       NVARCHAR (100)  NOT NULL,
    [ReportBinaryData] VARBINARY (MAX) NOT NULL,
    [ReportType]       INT             NOT NULL,
    CONSTRAINT [PK_DefaultReports] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_DefaultReports_DefaultReports] FOREIGN KEY ([Id]) REFERENCES [dbo].[DefaultReports] ([Id])
);

