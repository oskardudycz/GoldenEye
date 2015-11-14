CREATE TABLE [dbo].[Migration]
(
    [Id]	  INT            IDENTITY (1, 1) NOT NULL,
    [Name]	  NVARCHAR (255) NOT NULL,
    [RunDate] DATETIME		 DEFAULT GETDATE() 

    CONSTRAINT [PK_Migration] PRIMARY KEY CLUSTERED ([Id] ASC)
)
