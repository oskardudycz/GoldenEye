CREATE TABLE [dbo].[TypStruktury_Obiekt] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [Nazwa]                NVARCHAR (256)  NOT NULL,
    [TypObiektuIdRoot]     INT             NOT NULL,
    [IsStatus]             BIT             CONSTRAINT [DF_TypStruktury_Obiekt_IsStatus] DEFAULT ((0)) NOT NULL,
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
    [IsValid]              BIT             CONSTRAINT [DF_TypStruktury_Obiekt_IsValid] DEFAULT ((1)) NULL,
    [ValidFrom]            DATETIME        CONSTRAINT [DF_TypStruktury_Obiekt_ValidFrom] DEFAULT (getdate()) NOT NULL,
    [ValidTo]              DATETIME SPARSE NULL,
    [IsDeleted]            BIT             CONSTRAINT [DF_TypStruktury_Obiekt_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]          DATETIME SPARSE NULL,
    [DeletedBy]            INT SPARSE      NULL,
    [CreatedOn]            DATETIME        CONSTRAINT [DF_TypStruktury_Obiekt_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT             NULL,
    [LastModifiedOn]       DATETIME SPARSE NULL,
    [LastModifiedBy]       INT SPARSE      NULL,
    [IsAlternativeHistory] BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]       BIT             DEFAULT ((0)) NULL,
    [RealCreatedOn]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]   DATETIME SPARSE NULL,
    [RealDeletedFrom]      DATETIME SPARSE NULL,
    [StructureKind]        SMALLINT        NULL,
    [IsBlocked]            BIT             CONSTRAINT [DF_TypStruktury_Obiekt_IsBlocked] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TypStruktury_Obiekt] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TypStruktury_Obiekt_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[TypStruktury_Obiekt] ([Id]),
    CONSTRAINT [FK_TypStruktury_Obiekt_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[TypStruktury_Obiekt] ([Id]),
    CONSTRAINT [FK_TypStruktury_Obiekt_TypObiektu] FOREIGN KEY ([TypObiektuIdRoot]) REFERENCES [dbo].[TypObiektu] ([TypObiekt_ID])
);


GO
-- DK
-- Last modified on: 2013-03-19
----------------------------------------------
CREATE TRIGGER [dbo].[WartoscZmiany_TypStruktura_Obiekt_UPDATE]
   ON [dbo].[TypStruktury_Obiekt]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @Nazwa varchar(256), @TypObiektuIdRoot int, @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOd datetime, 
		@hist int, @ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, 
		@RealLastModifiedOn datetime, @StructureKind smallint, @IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
		@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @IsBlocked bit
	
	DECLARE cur_TypStrukturaObiekt_UPDATE cursor for
		SELECT ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOD, ObowiazujeDo, Nazwa, TypObiektuIdRoot, StructureKind,
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, IsBlocked
		FROM deleted
	OPEN cur_TypStrukturaObiekt_UPDATE 
	FETCH NEXT FROM cur_TypStrukturaObiekt_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @Nazwa, @TypObiektuIdRoot, 
		@StructureKind, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsBlocked
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE ID = @ID
	
		IF(@CzyWaznyNEW = 1)
		BEGIN
		
			--ustawiena daty do na null, narazie nie uzywane
			SET @ObowiazujeDo = NULL;
			
			INSERT INTO dbo.TypStruktury_Obiekt
			   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy],
			   ObowiazujeOD, ObowiazujeDo, Nazwa, TypObiektuIdRoot, RealCreatedOn, RealLastModifiedOn, StructureKind,
			   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, StatusSTo, StatusPTo, StatusWTo, 
			   StatusSToBy, StatusPToBy, StatusWToBy, IsBlocked)
	    
			SELECT @ID, ISNULL(@IdArchLink,@ID), 0, @WaznyOd, @WaznyodNEW, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW
				,@ObowiazujeOD, @ObowiazujeDo, @Nazwa, @TypObiektuIdRoot, @RealCreatedOn, 
				@RealLastModifiedOn, @StructureKind, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, 
				@StatusPFrom, @StatusWFrom, 
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
				END,
				@IsBlocked
			
			SELECT @hist = @@IDENTITY

			UPDATE dbo.TypStruktury_Obiekt
			SET ValidFrom = ISNULL(@WaznyodNEW, GETDATE())
			,[CreatedBy] = @UtworzonyPrzezNEW
			,LastModifiedOn = NULL
			,LastModifiedBy = NULL
			,CreatedOn = ISNULL(@DataModyfikacjiApp, GETDATE())
			,RealCreatedOn = ISNULL(@RealLastModifiedOn, GETDATE())
			,RealDeletedFrom = NULL
			,RealLastModifiedOn = NULL
			,IdArchLink = @hist
			,IdArch = NULL
			WHERE ID = @ID

		END
				
		FETCH NEXT FROM cur_TypStrukturaObiekt_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @Nazwa, @TypObiektuIdRoot, 
			@StructureKind, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsBlocked
	END
	
	CLOSE cur_TypStrukturaObiekt_UPDATE
	DEALLOCATE cur_TypStrukturaObiekt_UPDATE	
END

