CREATE TABLE [dbo].[UserReports] (
    [Id]               NVARCHAR (36)   NOT NULL,
    [Createor]         NVARCHAR (MAX)  NOT NULL,
    [ReportName]       NVARCHAR (100)  NOT NULL,
    [CreateData]       DATETIME        NOT NULL,
    [IdDefaultReports] NVARCHAR (36)   NULL,
    [ReportBinaryData] VARBINARY (MAX) NOT NULL,
    [UpdateData]       DATETIME        NULL,
    CONSTRAINT [PK_UserReports] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_UserReports_DefaultReports] FOREIGN KEY ([IdDefaultReports]) REFERENCES [dbo].[DefaultReports] ([Id])
);

