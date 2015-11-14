-- =============================================
-- Author:		DK
-- Create date: 2012-10-22
-- Last modified on: 2013-02-12
-- Description:	Zapisuje dane obiektow. Aktualizuje istniejacy lub wstawia nowy rekord.

-- Przykladowy plik XML wejsciowy:
	--<?xml version="1.0"?>
	--<Request UserId="1" AppDate="2012-09-09T11:23:22" RequestType="Units_SetMainHistFlowForAttribute" UnitId="1" UnitTypeId="20">
	--	<Attribute Id="23" TypeId="12" Priority="1" UIOrder="2" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" 
	--		EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--	</Attribute>
	--</Request>
	
-- Przykłądowy plik XML wyjściowy:
	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Units_SetMainHistFlowForAttribute" AppDate="2012-02-09">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="Attribute" />
	--			<Ref Id="3" EntityType="Attribute" />
	--		</Value>
	--	</Result>
	--</Response>
-- =============================================
CREATE PROCEDURE [THB].[Units_SetMainHistFlowForAttribute]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@xmlOk bit,
		@Query nvarchar(MAX) = '',
		@xml_data xml,
		@BranzaID int,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@MaUprawnienia bit = 0,
		@TypObiektuId int,
		@ObiektId int,
		@NazwaTypuObiektu nvarchar(MAX),			
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,				
		@DataObowiazywaniaOdStr varchar(30),
		@DataObowiazywaniaDoStr varchar(30),
		@CechaObiektuWartoscId int,
		@maxDate date = '9999-12-31',
		@ActualDate bit,
		--parametry dla zapytania dynamicznego
		@IstniejacyObiektId int,
		@IstniejacaCechaDataModyfikacji datetime,
		@CechaIdRekordu int,
		@CechaLastModifiedOn datetime,
		@CechaId int,
		@NowyLewyPrzedzialObowiazujeDo datetime,
		@NowyLewyPrzedzialObowiazujeOd datetime,
		@NowyPrawyPrzedzialObowiazujeOd datetime,	
		@NowyPrawyPrzedzialObowiazujeDo datetime,
		@IdTmp int,
		@PrzedzialCzasowyId int,
		@PrzedzialObowiazujeTmp datetime,		
		@AktualneIsMainHistFlow bit,
		@NoweIsMainHistFlow bit,
		@NowyPrzedzialIsMainHistFlow bit,
		@DateFromColumnName varchar(30),
		@DateToColumnName varchar(30),
		@IsMainHistFlowDlaWyznaczaniaPrzedzialow bit,
		@IloscPrzedzialow int			

	BEGIN TRY
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Units_SetMainHistFlowForAttribute', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN
			--usuwanie tabel roboczych
			IF OBJECT_ID('tempdb..#CechyZmienione') IS NOT NULL
				DROP TABLE #CechyZmienione
			
			IF OBJECT_ID('tempdb..#PrzedzialyWpisow') IS NOT NULL
				DROP TABLE #PrzedzialyWpisow
				
			IF OBJECT_ID('tempdb..#NowePrzedzialy') IS NOT NULL
				DROP TABLE #NowePrzedzialy
				
			IF OBJECT_ID('tempdb..#PrzedzialySrodkowe') IS NOT NULL
				DROP TABLE #PrzedzialySrodkowe
				
			CREATE TABLE #CechyZmienione (Id int);
			CREATE TABLE #PrzedzialyWpisow (Id int, ObowiazujeOd datetime, ObowiazujeDo datetime, ValidFrom datetime, ValidTo datetime, IsValid bit, LastModifiedOn datetime, ColumnsSet xml, ValString nvarchar(MAX), RealCreatedOn datetime);
			CREATE TABLE #NowePrzedzialy (Id int, ObowiazujeOd datetime, ObowiazujeDo datetime, ValidFrom datetime, ValidTo datetime, IsMainHistFlow bit); 
			CREATE TABLE #PrzedzialySrodkowe (Id int); 
			
			SET @xml_data = CAST(@XMLDataIn AS xml);

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
					,@TypObiektuId = C.value('./@UnitTypeId', 'int')
					,@ObiektId = C.value('./@UnitId', 'int')
			FROM @xml_data.nodes('/Request') T(C);
			
			--wyciagniecie danych cechy bedacej historia alternatywna (niewazna w danym momencie)
			SELECT TOP 1 @CechaIdRekordu = x.value('../@Id','int')
					,@CechaId = x.value('../@TypeId', 'int')
					,@CechaLastModifiedOn = x.value('../@LastModifiedOn', 'datetime')
					,@NoweIsMainHistFlow = x.value('./@IsMainHistFlow', 'bit')
			FROM @xml_data.nodes('/Request/Attribute/History') E(x)
				

	--SELECT @DataProgramu, @UzytkownikID, @RequestType
	--SELECT @TypObiektuId AS TypObiektu, @ObiektId AS ObiektId
	--SELECT @CechaWartoscXML AS WartoscXML, @CechaObiektuId AS Id, @CechaId AS CechaId, @CechaTypId AS TypCechy, @Priority AS Priority, @UIOrder AS UIOrder,@LastModifiedOn AS LastModifiedOn					
	--SELECT @ZmianaOd AS ZmOd, @ZmianaDo	AS ZmDo, @DataObowiazywaniaOd AS ObowOd, @DataObowiazywaniaDo AS ObowDo, @IsAlternativeHistory AS IsAlternative, @IsMainHistFlow AS IsMain						

			IF @RequestType = 'Units_SetMainHistFlowForAttribute'
			BEGIN
			
				--konczymy jesli nie podano wartosci dla IsMainHistFlow
				IF @NoweIsMainHistFlow IS NULL
				BEGIN
					SET @ERRMSG = 'Błąd. Nie podano wartości dla atrybutu IsMainHistFlow.';
					RAISERROR (@ERRMSG, 16, 1, 1) --WITH SETERROR;
				END 
			
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);
				
				--pobranie nazwy kolumny po ktorej filtrowane sa daty
				SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();
				SET @DateToColumnName = [THB].[GetDateToFilterColumn]();
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
					
				--jesli ma uprawnienia do zapisu to sprawdzenie czy nalezy do roli ZmianyHistorii	
				IF @MaUprawnienia = 1
				BEGIN
				
					EXEC [THB].[CheckUserInRole]
						@UserId = @UzytkownikID,
						@RoleRank = 3, --rola dla zmian histori ma niezmienny Rank = 3
						@AppDate = NULL,
						@CheckDate = 0,
						@UserInRole = @MaUprawnienia OUTPUT
				END
		
				IF @MaUprawnienia = 1
				BEGIN			
	
					--pobranie nazwy typu obiektu
					SELECT @NazwaTypuObiektu = Nazwa FROM dbo.[TypObiektu] WHERE TypObiekt_ID = @TypObiektuId AND IsDeleted = 0;
					
					--jesli typ obiektu o podanej nazwie nie istnieje to ustawienie tresci bledu
					IF @NazwaTypuObiektu IS NULL
					BEGIN
						SET @ERRMSG = 'Błąd. Typ obiektu o podanym Id (' + CAST(@TypObiektuId AS varchar) + ') nie istnieje.';
						RAISERROR (@ERRMSG, 16, 1, 2) --WITH SETERROR;
					END

					--sprawdzenie czy obiekt o podanym id istnieje
					SET @Query = 'SELECT @IstniejacyObiektId = Id
									FROM [_' + @NazwaTypuObiektu + ']
									WHERE IsDeleted = 0 AND Id = ' + CAST(@ObiektId AS varchar)
					
					--PRINT @Query;			
					EXECUTE sp_executesql @Query, N'@IstniejacyObiektId int OUTPUT', @IstniejacyObiektId = @IstniejacyObiektId OUTPUT
				
					IF @IstniejacyObiektId IS NULL
					BEGIN
						SET @ERRMSG = 'Błąd. Obiekt o podanym Id (' + CAST(@ObiektId AS varchar) + ') nie istnieje w typie obiektu ' + @NazwaTypuObiektu + '.';
						RAISERROR (@ERRMSG, 16, 1, 3);
					END
					
						
					--sprawdzenie czy cecha o podanym id istnieje
					SET @Query = 'SELECT @CechaIdRekordu = Id, @DataObowiazywaniaOd = ObowiazujeOd, @DataObowiazywaniaDo = ObowiazujeDo,
									@IstniejacaCechaDataModyfikacji = ISNULL(LastModifiedOn, CreatedOn), @AktualneIsMainHistFlow = IsMainHistFlow
									FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist]
									WHERE IsDeleted = 0 AND Id = ' + CAST(@CechaIdRekordu AS varchar)
					
					--PRINT @Query;			
					EXECUTE sp_executesql @Query, N'@CechaIdRekordu int OUTPUT, @DataObowiazywaniaOd datetime OUTPUT, @DataObowiazywaniaDo datetime OUTPUT, @IstniejacaCechaDataModyfikacji datetime OUTPUT, @AktualneIsMainHistFlow bit OUTPUT', 
						@CechaIdRekordu = @CechaIdRekordu OUTPUT, @DataObowiazywaniaOd = @DataObowiazywaniaOd OUTPUT, @DataObowiazywaniaDo = @DataObowiazywaniaDo OUTPUT, 
						@IstniejacaCechaDataModyfikacji = @IstniejacaCechaDataModyfikacji OUTPUT, @AktualneIsMainHistFlow = @AktualneIsMainHistFlow OUTPUT
					
						
--select @IstniejacyObiektId AS istniejacyObiekt,  @DataObowiazywaniaOd as obowOd, @DataObowiazywaniaDo AS ObowaDo, @IstniejacaCechaDataModyfikacji AS Modyf												
					
					IF @CechaIdRekordu IS NULL OR @CechaIdRekordu < 1
					BEGIN
						SET @ERRMSG = 'Błąd. Brak rekordów dla cechy o podanym Id.';
						RAISERROR (@ERRMSG, 16, 1, 4);
					END
					
					--sprawdzenie zgodnosci daty ostatniej modyfikacji
					IF @IstniejacaCechaDataModyfikacji <> @CechaLastModifiedOn
					BEGIN
						SET @ERRMSG = 'Błąd. Niezgodność daty ostatniej modyfikacji wartości cechy.';
						RAISERROR (@ERRMSG, 16, 1, 5);
					END
					
					-- jesli podano nie zmieniony IsMainHistFlow to nic nie robimy
					IF @AktualneIsMainHistFlow = @NoweIsMainHistFlow
					BEGIN
						SET @ERRMSG = 'Nie trzeba modyfikować rekordu. Pozostawiono dane bez zmian.';
						RAISERROR (@ERRMSG, 16, 1, 6);
					END
							
					--ustalenie wartosci granicznych dla przedzialow wg podanych dat obowiazywania
					--pobranie przedzialu czasowego z danych cechy oraz jej charakteru chwilowego
					SELECT @PrzedzialCzasowyId = PrzedzialCzasowyId
					FROM Cechy
					WHERE Cecha_ID = @CechaId;
				
					IF @PrzedzialCzasowyId IS NULL
					BEGIN
						SET @ERRMSG = 'Błąd. Nie istnieje cecha o podanym Id: ' + CAST(@CechaId AS varchar) + '.';
						RAISERROR (@ERRMSG, 16, 1, 7);
					END					

					--przypisanie dat do zmiennych dla zapytan dynamicznego SQL
					IF @DataObowiazywaniaDo IS NULL
						SET @DataObowiazywaniaDo = @MaxDate;							
					
					IF @DataObowiazywaniaOd IS NOT NULL
						SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataObowiazywaniaOd, 109) + '''';
					ELSE
						SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + '''';
						
					IF @DataObowiazywaniaDo IS NOT NULL
						SET @DataObowiazywaniaDoStr = '''' + CONVERT(nvarchar(50), @DataObowiazywaniaDo, 109) + '''';
					ELSE
						SET @DataObowiazywaniaDoStr = 'NULL';
										

			BEGIN TRAN T1_Units_SetIsMainHistFlow
										
					--szukanie przedzialow ktore maja zostac podmienione
					SET @IsMainHistFlowDlaWyznaczaniaPrzedzialow = @NoweIsMainHistFlow; --1
					
					--pobranie przedzialow z wartosciami dla historii glownej, ktore przecinaja sie z wstawianym przedzialem(jesli do nieskonczonosci lub podanej daty)
					SET @Query = '
						INSERT INTO #PrzedzialyWpisow (Id, ObowiazujeOd, ObowiazujeDo, ValidFrom, ValidTo, IsValid, LastModifiedOn, ColumnsSet, ValString, RealCreatedOn)
						SELECT Id, ObowiazujeOd, ObowiazujeDo, ValidFrom, ValidTo, IsValid, ISNULL(LastModifiedOn, CreatedOn), ColumnsSet, ValString, RealCreatedOn
						FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] c
						WHERE ObiektId = ' + CAST(@ObiektId AS varchar) + ' AND CechaID = ' + CAST(@CechaId AS varchar) + ' AND IsMainHistFlow = ' + CAST(@IsMainHistFlowDlaWyznaczaniaPrzedzialow AS varchar) + '
							 AND COALESCE(c.' + @DateFromColumnName + ', @maxDate) <= COALESCE(' + @DataObowiazywaniaDoStr + ', @maxDate)
							AND ( (c.' + @DateToColumnName + ' IS NULL AND COALESCE(c.' + @DateFromColumnName + ', @maxDate) >= COALESCE(' + @DataObowiazywaniaOdStr + ', @maxDate))
								OR (COALESCE(c.' + @DateToColumnName + ', @maxDate) >= COALESCE(' + @DataObowiazywaniaOdStr + ', @maxDate)) )'

					--PRINT @Query;
					EXECUTE sp_executesql @Query, N'@maxDate date', @maxDate = @maxDate				
							
--SELECT * FROM #PrzedzialyWpisow											
					
					--usuniecie znalezionych przedzialow nie rpzecinajacych sie z przedzialem historii
					SET @Query = '
						DELETE FROM #PrzedzialyWpisow
						WHERE ObowiazujeOd <
							(SELECT MAX(ObowiazujeOd) FROM #PrzedzialyWpisow WHERE ObowiazujeOd <= ' + @DataObowiazywaniaOdStr + ')'
					
					--PRINT @Query;	
					EXECUTE sp_executesql @Query
					
--SELECT * FROM #PrzedzialyWpisow					

					--pobranie ilosci przedzialow
					SELECT @IloscPrzedzialow = COUNT(1) FROM #PrzedzialyWpisow;
					
					--jesli znaleziono jakies przedzialy glowne nachodzące na przedział alternatywny					
					IF @IloscPrzedzialow > 0
					BEGIN
					
						IF @IloscPrzedzialow = 1
							SET @NowyPrzedzialIsMainHistFlow = 0;
						ELSE
							SET @NowyPrzedzialIsMainHistFlow = 1;							
							
						--wyznaczenie nowych, mniejszych przedzialow dla wartosci obowiazujacych w tym okresie
						SELECT TOP 1 @IdTmp = Id, @NowyLewyPrzedzialObowiazujeOd = ObowiazujeOd
						FROM #PrzedzialyWpisow
						WHERE ObowiazujeOd = (SELECT MIN(ObowiazujeOd) FROM #PrzedzialyWpisow);
	
						--wyznaczenie nowej wartosci daty obowiazywania Od maksymalnie lewego przedzialu
						EXEC [THB].[PrepareTimePeriods]
							@AppDate = @NowyLewyPrzedzialObowiazujeOd,
							@TimeIntervalId = @PrzedzialCzasowyId,
							@MinDate = @NowyLewyPrzedzialObowiazujeOd OUTPUT,
							@MaxDate = @PrzedzialObowiazujeTmp OUTPUT
						
						--jesli daty sa rozne to wyznaczenie nowych przedziałów	
						IF @DataObowiazywaniaOd <> @NowyLewyPrzedzialObowiazujeOd
						BEGIN				
							--pobranie przedzialu czasowego dla przedzialu czasowego modyfikowanego typu cechy i daty poczatku jej obowiazywania
							EXEC [THB].[PrepareTimeForPrevPeriod]
								@AppDate = @DataObowiazywaniaOd,
								@TimeIntervalId = @PrzedzialCzasowyId,
								@MinDate = @PrzedzialObowiazujeTmp OUTPUT,
								@MaxDate = @NowyLewyPrzedzialObowiazujeDo OUTPUT
						END
						ELSE
						BEGIN
							SET @NowyLewyPrzedzialObowiazujeDo = @DataObowiazywaniaDo
						END																									
	
						--wstawienie danych do tabeli roboczej z przedzialami
						INSERT INTO #NowePrzedzialy(Id, ObowiazujeOd, ObowiazujeDo, IsMainHistFlow)
						VALUES (@IdTmp, @NowyLewyPrzedzialObowiazujeOd, @NowyLewyPrzedzialObowiazujeDo, @NowyPrzedzialIsMainHistFlow);							


						--jesli przedzial historii alternatywnej dokladnie nie pokrywa sie z jednym przedzialem glownym
						-- to aktualziacja tego przedzialu tylko i koniec
						-- ustalenie max daty obowiazywania prawego przedzialu
						IF @IloscPrzedzialow > 1
						BEGIN

							SELECT TOP 1 @IdTmp = Id FROM #PrzedzialyWpisow ORDER BY ObowiazujeOd DESC, RealCreatedOn DESC; --WHERE ObowiazujeDo IS NULL
														
							IF @IdTmp IS NOT NULL AND @IdTmp > 0
							BEGIN
								SET @NowyPrawyPrzedzialObowiazujeDo = NULL;
							END
							ELSE
							BEGIN
								SELECT TOP 1 @IdTmp = Id, @NowyPrawyPrzedzialObowiazujeDo = ObowiazujeDo
								FROM #PrzedzialyWpisow
								WHERE ObowiazujeDo = (SELECT MAX(ObowiazujeDo) FROM #PrzedzialyWpisow);
							END
					
							IF @NowyPrawyPrzedzialObowiazujeDo IS NOT NULL
							BEGIN
								EXEC [THB].[PrepareTimePeriods]
									@AppDate = @NowyPrawyPrzedzialObowiazujeDo,
									@TimeIntervalId = @PrzedzialCzasowyId,
									@MinDate = @PrzedzialObowiazujeTmp OUTPUT,
									@MaxDate = @NowyPrawyPrzedzialObowiazujeDo OUTPUT									
							END	
								
							--pobranie przedzialu czasowego dla przedzialu czasowego modyfikowanego typu cechy i daty poczatku jej obowiazywania
							EXEC [THB].[PrepareTimeForNextPeriod]
								@AppDate = @DataObowiazywaniaDo,
								@TimeIntervalId = @PrzedzialCzasowyId,
								@MinDate = @NowyPrawyPrzedzialObowiazujeOd OUTPUT,
								@MaxDate = @PrzedzialObowiazujeTmp OUTPUT
		
		
	--SELECT @NowyPrawyPrzedzialObowiazujeOd,	@NowyPrawyPrzedzialObowiazujeDo
												
							--wstawienie danych do tabeli roboczej z przedzialami
							INSERT INTO #NowePrzedzialy(Id, ObowiazujeOd, ObowiazujeDo, IsMainHistFlow)
							VALUES (@IdTmp, @NowyPrawyPrzedzialObowiazujeOd, @NowyPrawyPrzedzialObowiazujeDo, @NowyPrzedzialIsMainHistFlow);		
						END				

					END				


					IF @DataObowiazywaniaOd IS NULL
						SET @DataObowiazywaniaOd = @DataModyfikacjiApp;
						
					IF @DataObowiazywaniaOd IS NOT NULL
						SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataObowiazywaniaOd, 109) + '''';
					ELSE
						SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + '''';
						
					IF @DataObowiazywaniaDo IS NOT NULL
						SET @DataObowiazywaniaDoStr = '''' + CONVERT(nvarchar(50), @DataObowiazywaniaDo, 109) + '''';
					ELSE
						SET @DataObowiazywaniaDoStr = 'NULL';																	
					
--SELECT * FROM #NowePrzedzialy

--------- ZMIANA DANYCH --------										
																						
					--aktualizacja wpisu podanej histori alternatywnej
					SET @Query = '
						IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
						BEGIN
							DISABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_Cechy_Hist_UPDATE] ON [_' + @NazwaTypuObiektu + '_Cechy_Hist];
																	
							UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
								IsAlternativeHistory = 1,
								IsMainHistFlow = 1,
								ValidFrom = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
								--ObowiazujeOd = ' + @DataObowiazywaniaOdStr + ',
								--ObowiazujeDo = ' + @DataObowiazywaniaDoStr + ',
								ObowiazujeDo = NULL,
								LastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
								LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + ',
								RealLastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacji, 109) + '''
							WHERE Id = ' + CAST(@CechaIdRekordu AS varchar) + '
							
							IF @@ROWCOUNT > 0
							BEGIN
								INSERT INTO #CechyZmienione(Id)
								VALUES(' + CAST(@CechaIdRekordu AS varchar) + ')
							END;
							
							ENABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_Cechy_Hist_UPDATE] ON [_' + @NazwaTypuObiektu + '_Cechy_Hist];
						END'								
						
					--PRINT @Query;
					EXECUTE sp_executesql @Query --, N'@PrzetwarzanyObiektId int OUTPUT, @ERRMSGTmp nvarchar(MAX) OUTPUT', @PrzetwarzanyObiektId = @ObiektId OUTPUT, @ERRMSGTmp = @ERRMSG OUTPUT							


										
					-- jesli wyznaczono nowe przedzialy robocze na skutek ustawienia wpisu historii alternatywnej na glowna to aktualziacja wpisow
					IF (SELECT COUNT(1) FROM #NowePrzedzialy) > 0
					BEGIN
					
						--wyznaczenie przedzialow srodkowych, w calosi zastepowanych przez historie alternatywna
						INSERT INTO #PrzedzialySrodkowe (Id) 
						SELECT pw.Id FROM #PrzedzialyWpisow pw
						WHERE NOT EXISTS (SELECT np.Id FROM #NowePrzedzialy np WHERE np.Id = pw.Id)
						
						--aktualizacja przedzialow srodkowych tak ze staja sie historia alternatywna
						IF (SELECT COUNT(1) FROM #PrzedzialySrodkowe) > 0
						BEGIN
							
							SET @Query = '
								IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
								BEGIN
									DISABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_Cechy_Hist_UPDATE] ON [_' + @NazwaTypuObiektu + '_Cechy_Hist];
																				
									UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET																
										IsAlternativeHistory = 1,
										IsMainHistFlow = 0,
										ValidFrom = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
										LastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
										LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + ',
										RealLastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacji, 109) + '''												
									WHERE Id IN (SELECT Id FROM #PrzedzialySrodkowe)
									
									IF @@ROWCOUNT > 0
									BEGIN
										INSERT INTO #CechyZmienione(Id)
										SELECT Id FROM #PrzedzialySrodkowe
									END;
									
									ENABLE TRIGGER [WartoscZmiany_' + @NazwaTypuObiektu + '_Cechy_Hist_UPDATE] ON [_' + @NazwaTypuObiektu + '_Cechy_Hist];
								END'
							
							--PRINT @Query;
							EXECUTE sp_executesql @Query
						END
																						
											
						IF Cursor_Status('local','curPrzedzialyObiektow') > 0 
						BEGIN
							 CLOSE curPrzedzialyObiektow
							 DEALLOCATE curPrzedzialyObiektow
						END

						DECLARE curPrzedzialyObiektow CURSOR LOCAL FOR 
							SELECT Id, ObowiazujeOd, ObowiazujeDo FROM #NowePrzedzialy
						OPEN curPrzedzialyObiektow
						FETCH NEXT FROM curPrzedzialyObiektow INTO @IdTmp, @NowyLewyPrzedzialObowiazujeOd, @NowyLewyPrzedzialObowiazujeDo
						WHILE @@FETCH_STATUS = 0
						BEGIN												
						
							IF @NowyLewyPrzedzialObowiazujeOd IS NOT NULL
								SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @NowyLewyPrzedzialObowiazujeOd, 109) + '''';
							ELSE
								SET @DataObowiazywaniaOdStr = '''' + CONVERT(nvarchar(50), @DataModyfikacjiApp, 109) + '''';
								
							IF @NowyLewyPrzedzialObowiazujeDo IS NOT NULL
								SET @DataObowiazywaniaDoStr = '''' + CONVERT(nvarchar(50), @NowyLewyPrzedzialObowiazujeDo, 109) + '''';
							ELSE
								SET @DataObowiazywaniaDoStr = 'NULL';					
														
							SET @Query = '
							 IF OBJECT_ID(''_' + @NazwaTypuObiektu + '_Cechy_Hist'', N''U'') IS NOT NULL
							 BEGIN
								UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
								IsAlternativeHistory = 1,
								IsMainHistFlow = ' + CAST(@NowyPrzedzialIsMainHistFlow AS varchar) + ',
								ValidFrom = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
								ObowiazujeOd = ' + @DataObowiazywaniaOdStr + ',';
							
							--jelsi przedzial wstawiany jest jako historia alternatywna to wpianie daty obowiazywania Do
							IF @NowyPrzedzialIsMainHistFlow = 0
								SET @Query += '
								ObowiazujeDo = ' + @DataObowiazywaniaDoStr + ',';	
								
							SET @Query += '								
								LastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacjiApp, 109) + ''',
								LastModifiedBy = ' + CAST(@UzytkownikId AS varchar) + ',
								RealLastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacji, 109) + '''												
								WHERE Id = ' + CAST(@IdTmp AS varchar) + '
							END'										
						
							--PRINT @Query;	
							EXECUTE sp_executesql @Query
												
							IF @@ROWCOUNT > 0
							BEGIN
								INSERT INTO #CechyZmienione(Id)
								VALUES(@IdTmp);
							END													
						
							FETCH NEXT FROM curPrzedzialyObiektow INTO @IdTmp, @NowyLewyPrzedzialObowiazujeOd, @NowyLewyPrzedzialObowiazujeDo
						END	
						CLOSE curPrzedzialyObiektow;
						DEALLOCATE curPrzedzialyObiektow;											
										
					END										
										
					SET @xmlResponse = (SELECT TOP 1
					(SELECT ID AS '@Id',
						'Attribute' AS '@EntityType'
						FROM #CechyZmienione sl
						FOR XML PATH('Ref'), ROOT('Value'), TYPE
						)
					FROM #CechyZmienione
					FOR XML PATH('Result'));

					COMMIT TRAN T1_Units_SetIsMainHistFlow		

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Units_SetMainHistFlowForAttribute', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Units_SetMainHistFlowForAttribute', @Wiadomosc = @ERRMSG OUTPUT	
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_Units_SetIsMainHistFlow
		END
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Units_SetMainHistFlowForAttribute"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += + '>';
	
	IF @ERRMSG IS NULL OR @ERRMSG = '' 	
	BEGIN
		IF @xmlResponse IS NOT NULL
		BEGIN
			SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		END
		ELSE
			SET @XMLDataOut += '<Result><Value/></Result>';
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>'
	END

	SET @XMLDataOut += '</Response>';	
	
	--usuwanie tabel tymczasowych, jesli istnieja						
	IF OBJECT_ID('tempdb..#CechyZmienione') IS NOT NULL
		DROP TABLE #CechyZmienione
	
	IF OBJECT_ID('tempdb..#PrzedzialyWpisow') IS NOT NULL
		DROP TABLE #PrzedzialyWpisow
		
	IF OBJECT_ID('tempdb..#NowePrzedzialy') IS NOT NULL
		DROP TABLE #NowePrzedzialy
		
	IF OBJECT_ID('tempdb..#PrzedzialySrodkowe') IS NOT NULL
		DROP TABLE #PrzedzialySrodkowe
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut			

END
