CREATE TABLE [dbo].[Relacja_Typ] (
    [TableID]              INT             NULL,
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [Nazwa]                NVARCHAR (50)   NOT NULL,
    [IsValid]              BIT             DEFAULT ((1)) NULL,
    [ValidFrom]            DATETIME        DEFAULT (getdate()) NOT NULL,
    [ValidTo]              DATETIME SPARSE NULL,
    [IsAlternativeHistory] BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]       BIT             DEFAULT ((0)) NULL,
    [ObowiazujeOd]         DATETIME        NULL,
    [ObowiazujeDo]         DATETIME SPARSE NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [IsDeleted]            BIT             DEFAULT ((0)) NOT NULL,
    [DeletedFrom]          DATETIME SPARSE NULL,
    [DeletedBy]            INT SPARSE      NULL,
    [CreatedOn]            DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT             NULL,
    [LastModifiedOn]       DATETIME SPARSE NULL,
    [LastModifiedBy]       INT SPARSE      NULL,
    [IsStatus]             BIT             DEFAULT ((0)) NOT NULL,
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
    [RealCreatedOn]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]   DATETIME SPARSE NULL,
    [RealDeletedFrom]      DATETIME SPARSE NULL,
    CONSTRAINT [PK_Relacja_Typ] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Relacja_Typ_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[Relacja_Typ] ([Id]),
    CONSTRAINT [FK_Relacja_Typ_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[Relacja_Typ] ([Id])
);


GO
-- =============================================
-- Author:		DK
-- Create date: 2012-03-20
-- Last modified on: 2013-01-25
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[WartoscZmiany_Relacja_Typ_UPDATE]
ON [dbo].[Relacja_Typ] AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

		declare @ID int, @Nazwa varchar(50)
		,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
		,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
		,@ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit,
		@DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int,
		@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
		@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime	
		
		DECLARE cur CURSOR FOR
			SELECT ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, Nazwa,
				IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
			FROM deleted
		OPEN cur 
			FETCH NEXT FROM cur INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Nazwa,
				@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
		WHILE @@fetch_status = 0
		BEGIN		
			SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
			FROM inserted WHERE ID = @ID
		
			IF(@CzyWaznyNEW = 1)
			BEGIN						
			
				SET @ObowiazujeDo = NULL;
				
				INSERT INTO dbo.Relacja_Typ
				   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy]
				   , ObowiazujeOD, ObowiazujeDo, Nazwa, RealCreatedOn, RealLastModifiedOn,
				   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
		    
				SELECT @ID,ISNULL(@IdArchLink,@ID), 0, @WaznyOd, @WaznyodNEW, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW
					, @ObowiazujeOD, @ObowiazujeDo, @Nazwa, @RealCreatedOn, @RealLastModifiedOn,
					@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

				UPDATE dbo.Relacja_Typ
				SET ValidFrom = @WaznyodNEW
				,[CreatedBy] = @UtworzonyPrzezNEW
				,LastModifiedOn = NULL
				,LastModifiedBy = NULL
				,CreatedOn = @DataModyfikacjiApp
				,RealCreatedOn = @RealLastModifiedOn
				,RealDeletedFrom = NULL
				,RealLastModifiedOn = NULL
				,IdArchLink = @hist
				,IdArch = NULL
				WHERE ID = @ID
			END
		
			FETCH NEXT FROM cur INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @Nazwa,
				@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	END
				
	CLOSE cur
	DEALLOCATE cur	
	
END
