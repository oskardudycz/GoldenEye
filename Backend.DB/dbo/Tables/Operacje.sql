CREATE TABLE [dbo].[Operacje] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [Nazwa]                NVARCHAR (64)   NOT NULL,
    [Opis]                 NVARCHAR (MAX)  NULL,
    [IsStatus]             BIT             CONSTRAINT [DF_Operacje_IsStatus] DEFAULT ((0)) NOT NULL,
    [StatusS]              INT SPARSE      NULL,
    [StatusSFrom]          DATETIME SPARSE NULL,
    [StatusSTo]            DATETIME SPARSE NULL,
    [StatusSFromBy]        INT SPARSE      NULL,
    [StatusSToBy]          INT SPARSE      NULL,
    [StatusW]              INT SPARSE      NULL,
    [StatusWFrom]          DATETIME SPARSE NULL,
    [StatusWTo]            DATETIME SPARSE NULL,
    [StatusWFromBy]        INT SPARSE      NULL,
    [StatusWToBy]          INT SPARSE      NULL,
    [StatusP]              INT SPARSE      NULL,
    [StatusPFrom]          DATETIME SPARSE NULL,
    [StatusPTo]            DATETIME SPARSE NULL,
    [StatusPFromBy]        INT SPARSE      NULL,
    [StatusPToBy]          INT SPARSE      NULL,
    [ObowiazujeOd]         DATETIME        NULL,
    [ObowiazujeDo]         DATETIME SPARSE NULL,
    [IsValid]              BIT             CONSTRAINT [DF_Operacje_IsValid] DEFAULT ((1)) NOT NULL,
    [ValidFrom]            DATETIME        CONSTRAINT [DF_Operacje_ValidFrom] DEFAULT (getdate()) NOT NULL,
    [ValidTo]              DATETIME SPARSE NULL,
    [IsDeleted]            BIT             CONSTRAINT [DF_Operacje_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]          DATETIME SPARSE NULL,
    [DeletedBy]            INT SPARSE      NULL,
    [CreatedOn]            DATETIME        CONSTRAINT [DF_Operacje_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT             NULL,
    [LastModifiedOn]       DATETIME SPARSE NULL,
    [LastModifiedBy]       INT SPARSE      NULL,
    [IsAlternativeHistory] BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]       BIT             DEFAULT ((0)) NULL,
    [RealCreatedOn]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]   DATETIME SPARSE NULL,
    [RealDeletedFrom]      DATETIME SPARSE NULL,
    CONSTRAINT [PK_Operacje] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Operacje_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[Operacje] ([Id]),
    CONSTRAINT [FK_Operacje_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[Operacje] ([Id])
);


GO
-- =============================================
-- Author:		DW, DK
-- Create date: 2011-08-23
-- Last modified on: 2012-11-23
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[WartoscZmiany_Operacje_UPDATE]
ON [dbo].[Operacje] AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @Nazwa nvarchar(64), @Opis nvarchar(MAX)
	,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
	,@ObowiazujeOD datetime
	,@ObowiazujeDo datetime, @hist int, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
	,@DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int 
	,@StatusPBy int, @StatusWBy int, @StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime	

	DECLARE cur CURSOR FOR
		SELECT ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, Nazwa, Opis,
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
		FROM deleted
	OPEN cur 
	FETCH NEXT FROM cur INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @Nazwa, @Opis,
		@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
		@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE ID = @ID
	 
		IF(@CzyWaznyNEW=1)
		BEGIN	
		
			SET @ObowiazujeDo = NULL;	
					
			INSERT INTO dbo.Operacje ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy]
			   ,ObowiazujeOd, ObowiazujeDo, Nazwa, Opis, RealCreatedOn, 
				   RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
	    
			SELECT @ID, ISNULL(@IdArchLink, @ID), 0, @WaznyOd, ISNULL(@WaznyodNEW, GETDATE()), @WaznyOd, @UtworzonyPrzez, ISNULL(@WaznyodNEW, GETDATE()), @UtworzonyPrzez, @ObowiazujeOd, @ObowiazujeDo
				,@Nazwa, @Opis, ISNULL(@RealCreatedOn, GETDATE()), 
					@RealLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
					CASE
						WHEN @StatusSFrom IS NOT NULL THEN @DataModyfikacjiApp
						ELSE NULL
					END,
					CASE
						WHEN @StatusPFrom IS NOT NULL THEN @DataModyfikacjiApp
						ELSE NULL
					END,
					CASE
						WHEN @StatusWFrom IS NOT NULL THEN @DataModyfikacjiApp
						ELSE NULL
					END,
					CASE
						WHEN @StatusSFrom IS NOT NULL THEN @UtworzonyPrzezNEW
						ELSE NULL
					END,
					CASE
						WHEN @StatusPFrom IS NOT NULL THEN @UtworzonyPrzezNEW
						ELSE NULL
					END,
					CASE
						WHEN @StatusWFrom IS NOT NULL THEN @UtworzonyPrzezNEW
						ELSE NULL
					END 									

			SELECT @hist = @@IDENTITY

			UPDATE dbo.Operacje
			SET ValidFrom = @WaznyodNEW
			,[CreatedBy] = @UtworzonyPrzezNEW
			,LastModifiedOn = NULL
			,LastModifiedBy = NULL
			,CreatedOn = ISNULL(@DataModyfikacjiApp, GETDATE())
			,RealCreatedOn = ISNULL(@RealLastModifiedOn, GETDATE())
			,RealLastModifiedOn = NULL
			,RealDeletedFrom = NULL
			,IdArchLink = @hist
			,IdArch = NULL
			WHERE ID = @ID

		END
	
		FETCH NEXT FROM cur INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @Nazwa, @Opis,
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	END
	
	CLOSE cur
	DEALLOCATE cur	
				
END
