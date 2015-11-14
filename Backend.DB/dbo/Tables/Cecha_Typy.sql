CREATE TABLE [dbo].[Cecha_Typy] (
    [TableID]              INT             NULL,
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [Nazwa]                NVARCHAR (50)   NOT NULL,
    [NazwaSQL]             NVARCHAR (50)   NULL,
    [IsValid]              BIT             CONSTRAINT [DF_Cecha_Typy_IsValid] DEFAULT ((1)) NULL,
    [ValidFrom]            DATETIME        CONSTRAINT [DF_TypyCechy_ValidFrom] DEFAULT (getdate()) NOT NULL,
    [ValidTo]              DATETIME SPARSE NULL,
    [Nazwa_UI]             NVARCHAR (50)   NOT NULL,
    [CzyCechaUzytkownika]  BIT             NOT NULL,
    [IsStatus]             BIT             CONSTRAINT [DF_Cecha_Typy_IsStatus] DEFAULT ((0)) NOT NULL,
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
    [IsDeleted]            BIT             CONSTRAINT [DF_Cecha_Typy_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]          DATETIME SPARSE NULL,
    [DeletedBy]            INT SPARSE      NULL,
    [CreatedOn]            DATETIME        CONSTRAINT [DF_Cecha_Typy_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT             NULL,
    [LastModifiedOn]       DATETIME SPARSE NULL,
    [LastModifiedBy]       INT SPARSE      NULL,
    [IsAlternativeHistory] BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]       BIT             DEFAULT ((0)) NULL,
    [RealCreatedOn]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]   DATETIME SPARSE NULL,
    [RealDeletedFrom]      DATETIME SPARSE NULL,
    CONSTRAINT [PK_Cecha_Typy] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Cecha_Typy_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[Cecha_Typy] ([Id]),
    CONSTRAINT [FK_Cecha_Typy_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[Cecha_Typy] ([Id])
);


GO
			
					
					CREATE TRIGGER [dbo].[WartoscZmiany_Cecha_Typy_INSERT]
					   ON  [dbo].[Cecha_Typy] 
					   AFTER INSERT
					AS 
					BEGIN
						declare @ID int, @Nazwa nvarchar(64)
						,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @Wersja int
						,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
						,@ObowiazujeDo datetime

						Declare @maxDt date = '9999-12-31'
						
						select @ID = ID , @IdArchLink = IdArchLink
						FROM inserted

						IF (@IdArchLink IS NULL)
						BEGIN
							IF EXISTS(
								SELECT S1.Nazwa_UI, S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
								  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
								FROM inserted AS S1
								  JOIN [dbo].[Cecha_Typy] AS S2
									ON S1.Nazwa_UI = S2.Nazwa_UI AND (COALESCE(S2.ObowiazujeDo, @maxDt) >= COALESCE(S1.ObowiazujeOd, @maxDt)
										 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo,@maxDt))
								WHERE S1.Id = @id AND S1.ID <> S2.ID AND S2.IsValid = 1
							)	
							BEGIN							
							
								UPDATE [dbo].[Cecha_Typy] SET 
								IsAlternativeHistory = 1
								,IsMainHistFlow=0
								WHERE Id = @id
							
							END
						END
					END	
GO
-- =============================================
-- Author:		DK
-- Create date: 2011-08-23
-- Last modified on: 2012-11-22
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[WartoscZmiany_Cecha_Typy_UPDATE]
ON [dbo].[Cecha_Typy] AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @Nazwa varchar(50), @NazwaSQL varchar(50), @NazwaUI nvarchar(50), @CzyCechaUzytkownika bit, @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
	,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime, @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime,
	@WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
		@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @hist int	
	
	DECLARE cur_CechaTypy_UPDATE cursor for
		SELECT ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, Nazwa, NazwaSQL, Nazwa_UI, CzyCechaUzytkownika,
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
		FROM deleted
	OPEN cur_CechaTypy_UPDATE 
	FETCH NEXT FROM cur_CechaTypy_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Nazwa, @NazwaSQL, 
		@NazwaUI, @CzyCechaUzytkownika, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom 
	while @@fetch_status = 0
	begin				
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
		@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE ID = @ID
	
		IF(@CzyWaznyNEW = 1)
		BEGIN
		
			--wpisywanie NULL w pole obowiazujeDo
			SET @ObowiazujeDo = NULL;						
		
			INSERT INTO dbo.Cecha_Typy
			   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy]
			   ,ObowiazujeOD, ObowiazujeDo, Nazwa, NazwaSQL, Nazwa_UI, CzyCechaUzytkownika,
			   RealCreatedOn, RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
	    
			SELECT @ID, ISNULL(@IdArchLink,@ID), 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW
				,@ObowiazujeOD, ISNULL(@ObowiazujeDo, @DataModyfikacjiApp), @Nazwa, @NazwaSQL, @NazwaUI, @CzyCechaUzytkownika,
				@RealCreatedOn, @RealLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

			UPDATE dbo.Cecha_Typy
			SET ValidFrom = @DataModyfikacjiApp
			,[CreatedBy] = @UtworzonyPrzezNEW
			,LastModifiedOn = NULL
			,LastModifiedBy = NULL
			,CreatedOn = @DataModyfikacjiApp
			,RealCreatedOn = @RealLastModifiedOn
			,ObowiazujeOd = @DataModyfikacjiApp
			,RealLastModifiedOn = NULL
			,IdArchLink = @hist
			,IdArch = NULL
			WHERE ID = @ID

		END
	
		FETCH NEXT FROM cur_CechaTypy_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD,@ObowiazujeDo, @Nazwa, @NazwaSQL, 
			@NazwaUI, @CzyCechaUzytkownika, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom 
	END
				
	CLOSE cur_CechaTypy_UPDATE
	DEALLOCATE cur_CechaTypy_UPDATE	
	
END
