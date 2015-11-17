CREATE TABLE [dbo].[_Zasób nietabelaryczny] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [Nazwa]                NVARCHAR (256)  NOT NULL,
    [IsAlternativeHistory] BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]       BIT             DEFAULT ((1)) NULL,
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
    [ObowiazujeOd]         DATETIME        NULL,
    [ObowiazujeDo]         DATETIME SPARSE NULL,
    [IsValid]              BIT             DEFAULT ((1)) NOT NULL,
    [ValidFrom]            DATETIME        DEFAULT (getdate()) NOT NULL,
    [ValidTo]              DATETIME SPARSE NULL,
    [IsDeleted]            BIT             DEFAULT ((0)) NOT NULL,
    [DeletedFrom]          DATETIME SPARSE NULL,
    [DeletedBy]            INT SPARSE      NULL,
    [CreatedOn]            DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT             NULL,
    [LastModifiedOn]       DATETIME SPARSE NULL,
    [LastModifiedBy]       INT SPARSE      NULL,
    [RealCreatedOn]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]   DATETIME SPARSE NULL,
    [RealDeletedFrom]      DATETIME SPARSE NULL,
    CONSTRAINT [PK2_Zasób nietabelaryczny] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Zasób nietabelaryczny_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[_Zasób nietabelaryczny] ([Id]),
    CONSTRAINT [FK_Zasób nietabelaryczny_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[_Zasób nietabelaryczny] ([Id])
);


GO
CREATE CLUSTERED INDEX [PK_Zasób nietabelaryczny]
    ON [dbo].[_Zasób nietabelaryczny]([Id] ASC);


GO
CREATE TRIGGER [dbo].[WartoscZmiany_Zasób nietabelaryczny_UPDATE]
				   ON  [dbo].[_Zasób nietabelaryczny] 
				   AFTER UPDATE
				AS 
				BEGIN
					SET NOCOUNT ON;
					
					--IF(UPDATE(IsDeleted)) RETURN;

					DECLARE @ID int, @Nazwa nvarchar(64), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @Wersja int
					,@ObowiazujeOd datetime, @ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
					,@NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int
					,@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int 
					,@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime	

					DECLARE cur_TypObiektuInst_UPDATE CURSOR FOR
						SELECT Id, Nazwa, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo,
							IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
						FROM deleted
					OPEN cur_TypObiektuInst_UPDATE 
					FETCH NEXT FROM cur_TypObiektuInst_UPDATE INTO @ID, @Nazwa, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo,
						@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
					WHILE @@fetch_status = 0
					BEGIN
					
						SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa,
							@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
						FROM inserted WHERE ID = @ID
					
						IF @CzyWaznyNEW = 1 --AND NOT UPDATE(IsAlternativeHistory))
						BEGIN
							
							INSERT INTO [dbo].[_Zasób nietabelaryczny]
							   ([IdArch], IdArchLink, Nazwa, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], 
							   ObowiazujeOD, ObowiazujeDo, RealCreatedOn, RealLastModifiedOn,
							   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
							   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
					    
							SELECT @ID,ISNULL(@IdArchLink,@ID), @Nazwa, 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW, 
								@ObowiazujeOD, @ObowiazujeDo, @RealCreatedOn, @RealLastModifiedOn,
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

							UPDATE [dbo].[_Zasób nietabelaryczny]
							SET ValidFrom = @DataModyfikacjiApp
							,[CreatedBy] = @UtworzonyPrzezNEW
							,LastModifiedOn = NULL
							,LastModifiedBy = NULL
							,CreatedOn = ISNULL(@DataModyfikacjiApp, @WaznyodNEW)
							,RealCreatedOn = ISNULL(@RealLastModifiedOn, @RealCreatedOn)
							,RealDeletedFrom = NULL
							,RealLastModifiedOn = NULL
							,IdArchLink = @hist
							,IdArch = NULL
							WHERE ID = @ID
						END
					
							FETCH NEXT FROM cur_TypObiektuInst_UPDATE INTO @ID, @Nazwa, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo,
								@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
					END
					
					CLOSE cur_TypObiektuInst_UPDATE
					DEALLOCATE cur_TypObiektuInst_UPDATE	
				END	