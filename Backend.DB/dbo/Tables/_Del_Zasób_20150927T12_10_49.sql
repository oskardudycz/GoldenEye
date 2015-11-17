CREATE TABLE [dbo].[_Del_Zasób_20150927T12:10:49] (
    [Id]                                      INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]                                  INT             NULL,
    [IdArchLink]                              INT             NULL,
    [Nazwa]                                   NVARCHAR (256)  NOT NULL,
    [IsAlternativeHistory]                    BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]                          BIT             DEFAULT ((1)) NULL,
    [IsStatus]                                BIT             DEFAULT ((0)) NOT NULL,
    [StatusS]                                 INT SPARSE      NULL,
    [StatusSFrom]                             DATETIME SPARSE NULL,
    [StatusSTo]                               DATETIME SPARSE NULL,
    [StatusSFromBy]                           INT SPARSE      NULL,
    [StatusSToBy]                             INT SPARSE      NULL,
    [StatusW]                                 INT SPARSE      NULL,
    [StatusWFrom]                             DATETIME SPARSE NULL,
    [StatusWTo]                               DATETIME SPARSE NULL,
    [StatusWFromBy]                           INT SPARSE      NULL,
    [StatusWToBy]                             INT SPARSE      NULL,
    [StatusP]                                 INT SPARSE      NULL,
    [StatusPFrom]                             DATETIME SPARSE NULL,
    [StatusPTo]                               DATETIME SPARSE NULL,
    [StatusPFromBy]                           INT SPARSE      NULL,
    [StatusPToBy]                             INT SPARSE      NULL,
    [ObowiazujeOd]                            DATETIME        NULL,
    [ObowiazujeDo]                            DATETIME SPARSE NULL,
    [IsValid]                                 BIT             DEFAULT ((1)) NOT NULL,
    [ValidFrom]                               DATETIME        DEFAULT (getdate()) NOT NULL,
    [ValidTo]                                 DATETIME SPARSE NULL,
    [IsDeleted]                               BIT             DEFAULT ((0)) NOT NULL,
    [DeletedFrom]                             DATETIME SPARSE NULL,
    [DeletedBy]                               INT SPARSE      NULL,
    [CreatedOn]                               DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                               INT             NULL,
    [LastModifiedOn]                          DATETIME SPARSE NULL,
    [LastModifiedBy]                          INT SPARSE      NULL,
    [RealCreatedOn]                           DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]                      DATETIME SPARSE NULL,
    [RealDeletedFrom]                         DATETIME SPARSE NULL,
    [Zasób - Nazwa]                           NVARCHAR (100)  NULL,
    [zasób - Typ]                             BIT             NULL,
    [Zasób - Miejsce występowania]            DATETIME        NULL,
    [Zasób - Czy Zasób jest stały]            INT             NULL,
    [Czy Zasób dostępny w dni wolne]          INT             NULL,
    [Zasób - Maz. dostępność]                 INT             NULL,
    [Zasób - Gdy brak na magazynie to :]      TIME (7)        NULL,
    [Zasób - Śr.czas oczekiwania  na dostawę] INT             NULL,
    CONSTRAINT [PK2_Del_Zasób_20150927T12:10:49] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Del_Zasób_20150927T12:10:49_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[_Del_Zasób_20150927T12:10:49] ([Id]),
    CONSTRAINT [FK_Del_Zasób_20150927T12:10:49_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[_Del_Zasób_20150927T12:10:49] ([Id])
);


GO
CREATE CLUSTERED INDEX [PK_Del_Zasób_20150927T12:10:49]
    ON [dbo].[_Del_Zasób_20150927T12:10:49]([Id] ASC);


GO

		CREATE TRIGGER [dbo].[WartoscZmiany_Del_Zasób_20150927T12:10:49_UPDATE]
		   ON  [dbo].[_Del_Zasób_20150927T12:10:49] 
		   AFTER UPDATE
		AS 
		BEGIN
			SET NOCOUNT ON;

			DECLARE @ID int, @Nazwa nvarchar(64), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int,@Wersja int
			,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOd datetime, @ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
			,@NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int
			,@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSFromBy int, @StatusPFromBy int, @StatusWFromBy int 
			,@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @CreateNewRowForHistory bit, @CreatedOn datetime, @Czy_Zasób_dostępny_w_dni_wolne int, @Zasób___Czy_Zasób_jest_stały int, @Zasób___Gdy_brak_na_magazynie_to__ Time, @Zasób___Maz_dostępność int, @Zasób___Miejsce_występowania datetime, @Zasób___Nazwa nvarchar(100), @Zasób___Śrczas_oczekiwania__na_dostawę int, @zasób___Typ bit
			SET @CreateNewRowForHistory = 0;
	
			DECLARE cur_TypObiektuInst_UPDATE CURSOR FOR
				SELECT Id, Nazwa, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, CreatedOn, 
					IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, [Czy Zasób dostępny w dni wolne], [Zasób - Czy Zasób jest stały], [Zasób - Gdy brak na magazynie to :], [Zasób - Maz. dostępność], [Zasób - Miejsce występowania], [Zasób - Nazwa], [Zasób - Śr.czas oczekiwania  na dostawę], [zasób - Typ]
				FROM deleted
			OPEN cur_TypObiektuInst_UPDATE 
			FETCH NEXT FROM cur_TypObiektuInst_UPDATE INTO @ID, @Nazwa, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @CreatedOn,
				@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSFromBy, @StatusPFromBy, @StatusWFromBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @Czy_Zasób_dostępny_w_dni_wolne, @Zasób___Czy_Zasób_jest_stały, @Zasób___Gdy_brak_na_magazynie_to__, @Zasób___Maz_dostępność, @Zasób___Miejsce_występowania, @Zasób___Nazwa, @Zasób___Śrczas_oczekiwania__na_dostawę, @zasób___Typ
			WHILE @@fetch_status = 0
			BEGIN
	
				SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa,
					@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
				FROM inserted WHERE ID = @ID
			
				IF @CzyWaznyNEW = 1
				BEGIN
				
					IF @CreateNewRowForHistory = 1
					BEGIN
						INSERT INTO [dbo].[_Zasób]
						   ([IdArch], IdArchLink, Nazwa, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], 
							ObowiazujeOD, ObowiazujeDo, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
							StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy, [Czy Zasób dostępny w dni wolne], [Zasób - Czy Zasób jest stały], [Zasób - Gdy brak na magazynie to :], [Zasób - Maz. dostępność], [Zasób - Miejsce występowania], [Zasób - Nazwa], [Zasób - Śr.czas oczekiwania  na dostawę], [zasób - Typ]) 
						SELECT @ID,ISNULL(@IdArchLink,@ID), @Nazwa, 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW, 
							@ObowiazujeOD, @ObowiazujeDo, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSFromBy, @StatusPFromBy, @StatusWFromBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
							CASE
								WHEN @StatusSFrom IS NOT NULL THEN @DataModyfikacjiApp ELSE NULL
							END,
							CASE
								WHEN @StatusPFrom IS NOT NULL THEN @DataModyfikacjiApp ELSE NULL
							END,
							CASE
								WHEN @StatusWFrom IS NOT NULL THEN @DataModyfikacjiApp ELSE NULL
							END,
							CASE
								WHEN @StatusSFrom IS NOT NULL THEN @UtworzonyPrzezNEW ELSE NULL
							END,
							CASE
								WHEN @StatusPFrom IS NOT NULL THEN @UtworzonyPrzezNEW ELSE NULL
							END,
							CASE
								WHEN @StatusWFrom IS NOT NULL THEN @UtworzonyPrzezNEW ELSE NULL
							END, @Czy_Zasób_dostępny_w_dni_wolne, @Zasób___Czy_Zasób_jest_stały, @Zasób___Gdy_brak_na_magazynie_to__, @Zasób___Maz_dostępność, @Zasób___Miejsce_występowania, @Zasób___Nazwa, @Zasób___Śrczas_oczekiwania__na_dostawę, @zasób___Typ				

						SELECT @hist = @@IDENTITY

						UPDATE [dbo].[_Zasób]
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
					ELSE
					BEGIN
						UPDATE [dbo].[_Zasób] SET
							CreatedOn = @CreatedOn
							,CreatedBy = @UtworzonyPrzez
							,ObowiazujeOd = @ObowiazujeOD
						WHERE ID = @ID
					END
				END
			
				FETCH NEXT FROM cur_TypObiektuInst_UPDATE INTO @ID, @Nazwa, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @CreatedOn,
					@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSFromBy, @StatusPFromBy, @StatusWFromBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @Czy_Zasób_dostępny_w_dni_wolne, @Zasób___Czy_Zasób_jest_stały, @Zasób___Gdy_brak_na_magazynie_to__, @Zasób___Maz_dostępność, @Zasób___Miejsce_występowania, @Zasób___Nazwa, @Zasób___Śrczas_oczekiwania__na_dostawę, @zasób___Typ
			END
			
			CLOSE cur_TypObiektuInst_UPDATE
			DEALLOCATE cur_TypObiektuInst_UPDATE	
		END	
GO
DISABLE TRIGGER [dbo].[WartoscZmiany_Del_Zasób_20150927T12:10:49_UPDATE]
    ON [dbo].[_Del_Zasób_20150927T12:10:49];


GO
			
CREATE TRIGGER [dbo].[WartoscZmiany_Del_Zasób_20150927T12:10:49_INSERT]
   ON  [dbo].[_Del_Zasób_20150927T12:10:49] 
   AFTER INSERT
AS 
BEGIN
	DECLARE @ID int, @Nazwa nvarchar(64)
	,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @Wersja int
	,@ObowiazujeOD datetime, @ObowiazujeDo datetime

	DECLARE @maxDt date = '9999-12-31'
	
	select @ID = ID, @IdArchLink = IdArchLink
	FROM inserted

	IF (@IdArchLink IS NULL)
	BEGIN
		IF EXISTS(
			SELECT S1.Nazwa,
			  S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
			  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
			FROM inserted AS S1
			  JOIN [dbo].[_Zasób] AS S2
				ON  S2.Nazwa = S1.Nazwa
				AND (COALESCE(S2.ObowiazujeDo, @maxDt) >= COALESCE(S1.ObowiazujeOd, @maxDt)
					 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo, @maxDt))
			WHERE S1.Id = @id AND S1.ID <> S2.ID
		)	
		BEGIN						
		
			UPDATE [dbo].[_Zasób] 
			SET IsAlternativeHistory=1
			, IsMainHistFlow=0
			WHERE Id = @id						
		END
	END
END	
GO
DISABLE TRIGGER [dbo].[WartoscZmiany_Del_Zasób_20150927T12:10:49_INSERT]
    ON [dbo].[_Del_Zasób_20150927T12:10:49];

