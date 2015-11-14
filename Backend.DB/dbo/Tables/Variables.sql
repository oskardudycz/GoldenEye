CREATE TABLE [dbo].[Variables] (
    [Var_ID]    INT            IDENTITY (1, 1) NOT NULL,
    [VarName]   NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [VarType]   VARCHAR (20)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [VarValue]  NVARCHAR (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [VarGroup]  VARCHAR (20)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ValidFrom] DATETIME       DEFAULT (getdate()) NOT NULL,
    [ValidTo]   DATETIME       NULL,
    [IsValid]   BIT            DEFAULT ((1)) NULL,
    CONSTRAINT [PK_Variables_1] PRIMARY KEY CLUSTERED ([VarGroup] ASC, [VarName] ASC)
);

