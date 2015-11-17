CREATE TABLE [dbo].[Relacja_Cecha_Hist] (
    [Id]                   INT                                                                   IDENTITY (1, 1) NOT NULL,
    [IdArch]               INT                                                                   NULL,
    [IdArchLink]           INT                                                                   NULL,
    [RelacjaID]            INT                                                                   NOT NULL,
    [CechaId]              INT                                                                   NOT NULL,
    [ValString]            NVARCHAR (MAX)                                                        NULL,
    [Priority]             SMALLINT                                                              NOT NULL,
    [UIOrder]              SMALLINT                                                              NULL,
    [IsStatus]             BIT                                                                   CONSTRAINT [DF_Struktura_Relacja_Cecha_IsStatus] DEFAULT ((0)) NOT NULL,
    [StatusS]              INT SPARSE                                                            NULL,
    [StatusSFrom]          DATETIME SPARSE                                                       NULL,
    [StatusSTo]            DATETIME SPARSE                                                       NULL,
    [StatusSFromBy]        INT SPARSE                                                            NULL,
    [StatusSToBy]          INT SPARSE                                                            NULL,
    [StatusW]              INT SPARSE                                                            NULL,
    [StatusWFrom]          DATETIME SPARSE                                                       NULL,
    [StatusWTo]            DATETIME SPARSE                                                       NULL,
    [StatusWFromBy]        INT SPARSE                                                            NULL,
    [StatusWToBy]          INT SPARSE                                                            NULL,
    [StatusP]              INT SPARSE                                                            NULL,
    [StatusPFrom]          DATETIME SPARSE                                                       NULL,
    [StatusPTo]            DATETIME SPARSE                                                       NULL,
    [StatusPFromBy]        INT SPARSE                                                            NULL,
    [StatusPToBy]          INT SPARSE                                                            NULL,
    [ObowiazujeOd]         DATETIME                                                              NULL,
    [ObowiazujeDo]         DATETIME SPARSE                                                       NULL,
    [IsValid]              BIT                                                                   CONSTRAINT [DF_Struktura_Relacja_Cecha_IsValid] DEFAULT ((1)) NULL,
    [ValidFrom]            DATETIME                                                              CONSTRAINT [DF_Struktura_Relacja_Cecha_ValidFrom] DEFAULT (getdate()) NOT NULL,
    [ValidTo]              DATETIME SPARSE                                                       NULL,
    [IsDeleted]            BIT                                                                   CONSTRAINT [DF_Struktura_Relacja_Cecha_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]          DATETIME SPARSE                                                       NULL,
    [DeletedBy]            INT SPARSE                                                            NULL,
    [CreatedOn]            DATETIME                                                              CONSTRAINT [DF_Struktura_Relacja_Cecha_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT                                                                   NULL,
    [LastModifiedOn]       DATETIME SPARSE                                                       NULL,
    [LastModifiedBy]       INT SPARSE                                                            NULL,
    [ColumnsSet]           XML COLUMN_SET FOR ALL_SPARSE_COLUMNS                                ,
    [ValInt]               INT SPARSE                                                            NULL,
    [ValFloat]             FLOAT (53) SPARSE                                                     NULL,
    [ValBit]               BIT SPARSE                                                            NULL,
    [ValDecimal]           DECIMAL (12, 5) SPARSE                                                NULL,
    [ValDatetime]          DATETIME SPARSE                                                       NULL,
    [ValDate]              DATE SPARSE                                                           NULL,
    [ValTime]              TIME (7) SPARSE                                                       NULL,
    [IsAlternativeHistory] BIT                                                                   NULL,
    [IsMainHistFlow]       BIT                                                                   NULL,
    [ValDictionary]        INT SPARSE                                                            NULL,
    [RealCreatedOn]        DATETIME                                                              DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]   DATETIME SPARSE                                                       NULL,
    [RealDeletedFrom]      DATETIME SPARSE                                                       NULL,
    [ValXml]               XML(CONTENT [dbo].[Schema_CompositeArithmeticOperationColumn]) SPARSE NULL,
    [ValRef]               XML SPARSE                                                            NULL,
    CONSTRAINT [PK_Relacja_Cecha_Hist] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Relacja_Cecha_Hist_Cechy] FOREIGN KEY ([CechaId]) REFERENCES [dbo].[Cechy] ([Cecha_ID]),
    CONSTRAINT [FK_Relacja_Cecha_Hist_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[Relacja_Cecha_Hist] ([Id]),
    CONSTRAINT [FK_Relacja_Cecha_Hist_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[Relacja_Cecha_Hist] ([Id]),
    CONSTRAINT [FK_Struktura_Relacja_Cecha_Struktura] FOREIGN KEY ([RelacjaID]) REFERENCES [dbo].[Relacje] ([Id])
);


GO
CREATE TRIGGER [dbo].[WartoscZmiany_Relacja_Cecha_Hist_INSERT]
				   ON  [dbo].[Relacja_Cecha_Hist] 
				   AFTER INSERT
				AS 
				BEGIN
					declare @ID int,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
					,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime

					Declare @maxDt date = '9999-12-31'
					
					select @ID = ID, @IdArchLink = IdArchLink
					FROM inserted

					IF (@IdArchLink IS NULL)
					BEGIN
						IF EXISTS(
							SELECT S1.CechaID, S1.RelacjaID,
							  S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
							  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
							FROM inserted AS S1
							  JOIN [dbo].[Relacja_Cecha_Hist] AS S2
								ON  S2.CechaID = S1.CechaID
								AND S2.RelacjaId = S1.RelacjaId
								--AND S2.VirtualTypeId = S1.VirtualTypeId
								AND (COALESCE(S2.ObowiazujeDo,@maxDt) >= COALESCE(S1.ObowiazujeOd,@maxDt)
									 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo,@maxDt))
							WHERE S1.Id = @id AND S1.ID <> S2.ID --AND S1.VirtualTypeId = S2.VirtualTypeId
						)	
						BEGIN
											
							UPDATE [dbo].[Relacja_Cecha_Hist] 
							SET IsAlternativeHistory = 1
							, IsMainHistFlow = 0
							WHERE Id = @id
						
						END
					END
				END	
GO
-- DK
-- Last modified on: 2013-02-26
---------------------------------------------
CREATE TRIGGER [dbo].[WartoscZmiany_Struktura_Relacja_Cecha__UPDATE]
		 ON  [dbo].[Relacja_Cecha_Hist] AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	IF(UPDATE(IsDeleted)) RETURN;

	DECLARE @ID int,@RelacjaID  INT,@CechaId INT, @ColumnsSet XML, @ValString nvarchar(MAX), @WaznyOd datetime, @UtworzonyPrzez int, 
		@IdArchLink int, @ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOd datetime, @ObowiazujeDo datetime, @Priority smallint, 
		@UIOrder smallint, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, 
		@RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int, @PrzedzialCzasowyId int, @Sledzona bit, 
		@MinDate datetime, @MaxDate datetime, @OldLastModifiedOn datetime, @CechaStatusP int, @IsStatus bit, @StatusS int, @StatusW int, 
		@StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, @StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime,
		@NewObowiazujeDo datetime, @MinDateObowiazuje datetime, @MaxDateObowiazuje datetime, @NewObowiazujeOd datetime, @NewIsMainHistFlow bit,
		@IsAlternativeHistory bit, @IsMainHistFlow bit, @ValInt int, @ValFloat float, @ValBit bit, @ValDecimal decimal(12,5), @ValDatetime datetime, 
		@ValDate date, @ValTime time(7), @ValDictionary int, @ValXml xml, @ValRef xml, @CreatedOn datetime, @LastModifiedOn datetime, @ZmienionyPrzez int

	DECLARE cur_WZRelacjaCecha_Hist_UPDATE CURSOR FOR
		SELECT ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOD, ObowiazujeDo
		,RelacjaID, CechaId, ColumnsSet, ValString, [Priority], UIOrder, ISNULL(LastModifiedOn, CreatedOn),
		IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, IsAlternativeHistory, IsMainHistFlow,
		ValInt, ValFloat, ValBit, ValDecimal, ValDatetime, ValDate, ValTime, ValDictionary, ValXml, ValRef, CreatedOn, LastModifiedOn, LastModifiedBy
		FROM deleted
	OPEN cur_WZRelacjaCecha_Hist_UPDATE 
	FETCH NEXT FROM cur_WZRelacjaCecha_Hist_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @RelacjaID, @CechaId  
		,@ColumnsSet, @ValString, @Priority, @UIOrder, @OldLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, 
		@StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsAlternativeHistory, @IsMainHistFlow,
		@ValInt, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, @ValDictionary, @ValXml, @ValRef, @CreatedOn, @LastModifiedOn, @ZmienionyPrzez
	WHILE @@fetch_status = 0
	BEGIN

		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NewIsMainHistFlow = IsMainHistFlow, @NewObowiazujeOd = ObowiazujeOd,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn, @NewObowiazujeDo = ObowiazujeDo
		FROM inserted WHERE ID = @ID
		
		--pobranie przedzialu czasowego z danych cechy oraz jej charakteru chwilowego
		SELECT @PrzedzialCzasowyId = PrzedzialCzasowyId, @Sledzona = Sledzona, @CechaStatusP = StatusP
		FROM Cechy
		WHERE Cecha_ID = @CechaID;
				
		IF @CzyWaznyNEW = 1
		BEGIN
	
			SET @ObowiazujeDo = NULL;	
		
			--okreslamy granice przedzialu tylko jesli ustawiono typ przedzialu dla cechy
			IF @PrzedzialCzasowyId IS NOT NULL
			BEGIN
				--pobranie przedzialu czasowego dla przedzialu czasowego modyfikowanego typu cechy i daty aplikacji
				EXEC [THB].[PrepareTimePeriods]
					@AppDate = @DataModyfikacjiApp,
					@TimeIntervalId = @PrzedzialCzasowyId,
					@MinDate = @MinDate OUTPUT,
					@MaxDate = @MaxDate OUTPUT
			END
			ELSE
			BEGIN
				--brak jednostki czasu wiec zapisujemy kazda zmiane
				SET @Sledzona = 1;
			END
				
			--kolumna narazie nie uzywana	
			SET @MaxDateObowiazuje = NULL
			
			--jesli ma byc zapisywana kazda zmiana wartosci cechy (charakter chwilowy) lub wartosc nie miesci sie w podanym przedziale czasowym
			IF @NewIsMainHistFlow <> @IsMainHistFlow OR @ObowiazujeOd <> @NewObowiazujeOd OR @Sledzona = 1 OR @CechaStatusP >= 5
				OR @OldLastModifiedOn < @MinDate OR @OldLastModifiedOn > @MaxDate
			BEGIN

				--okreslamy granice przedzialu tylko jesli ustawiono typ przedzialu dla cechy
				--IF @PrzedzialCzasowyId IS NOT NULL
				--BEGIN
				--	EXEC [THB].[PrepareTimeForPrevPeriod]
				--		@AppDate = @DataModyfikacjiApp,
				--		@TimeIntervalId = @PrzedzialCzasowyId,
				--		@MinDate = @MinDateObowiazuje OUTPUT,
				--		@MaxDate = @MaxDateObowiazuje OUTPUT
				--END
					
				--kolumna narazie nie uzywana	
				SET @MaxDateObowiazuje = NULL
				
				--podmiana wartosci daty ostatniej modyfikacji i osoby modyfikujacej
				IF @Sledzona = 1
				BEGIN
					SET @LastModifiedOn = @DataModyfikacjiApp;
					SET @ZmienionyPrzez = @UtworzonyPrzezNEW;
				END		
			
				INSERT INTO dbo.Relacja_Cecha_Hist
				   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy],
				   ObowiazujeOD, ObowiazujeDo, RelacjaID, CechaId, ValString, ValInt, ValFloat, ValBit, ValDecimal, ValDatetime, ValDate, ValTime, ValDictionary, ValXml, ValRef,
				   [Priority], UIOrder, RealCreatedOn, RealLastModifiedOn, IsAlternativeHistory, IsMainHistFlow, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
					StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
		    
				SELECT @ID,ISNULL(@IdArchLink,@ID), 0, @WaznyOd, @DataModyfikacjiApp, @CreatedOn, @UtworzonyPrzez, @LastModifiedOn, @ZmienionyPrzez,
				@ObowiazujeOd, @MaxDateObowiazuje, @RelacjaID, @CechaId, @ValString, @ValInt, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, @ValDictionary, @ValXml, @ValRef,
				@Priority, @UIOrder, @RealCreatedOn, @RealLastModifiedOn, @IsAlternativeHistory, @IsMainHistFlow, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom,
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

				UPDATE dbo.Relacja_Cecha_Hist
				SET ValidFrom = @WaznyodNEW
				,[CreatedBy] = ISNULL(@UtworzonyPrzezNEW, @UtworzonyPrzez)
				--,[ObowiazujeOd] = @MinDate
				--,[ObowiazujeDo] = @NewObowiazujeDo 				
				,[ObowiazujeDo] = @ObowiazujeDo 				
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
			ELSE IF (@ObowiazujeOd = @NewObowiazujeOd AND @OldLastModifiedOn >= @MinDate AND @OldLastModifiedOn <= @MaxDate) --zapis cech na podstawie przedzialow czasowych
			BEGIN
		
				--sprawdzenie czy data ostatniej modyfikacji miesci sie w przedziale czasowym wg nowej daty modyfikacji, jelsi tak to tylko update rekordu
				--bez tworzenia wpisow historycznych
				UPDATE [dbo].[Relacja_Cecha_Hist]
				SET ValidFrom = @DataModyfikacjiApp
				,[LastModifiedBy] = @UtworzonyPrzezNEW
				,[LastModifiedOn] = @DataModyfikacjiApp
				--,[CreatedBy] = @UtworzonyPrzezNEW
				WHERE ID = @ID
			
			END
		END
	
		FETCH NEXT FROM cur_WZRelacjaCecha_Hist_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @RelacjaID, @CechaId  
			,@ColumnsSet, @ValString, @Priority, @UIOrder, @OldLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, 
			@StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsAlternativeHistory, @IsMainHistFlow,
			@ValInt, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, @ValDictionary, @ValXml, @ValRef, @CreatedOn, @LastModifiedOn, @ZmienionyPrzez
	END
	
	CLOSE cur_WZRelacjaCecha_Hist_UPDATE
	DEALLOCATE cur_WZRelacjaCecha_Hist_UPDATE						
					
END
