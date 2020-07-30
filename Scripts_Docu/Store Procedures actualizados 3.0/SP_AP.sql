-- ELEGIR BASE DE DATOS --
USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

--------------------------------
--------------------------------
-- SELECT LOS RECIBOS COMO AP --
--------------------------------
--------------------------------

CREATE PROCEDURE SPS_AP
@ReciboSelect ReciboSelect READONLY,
@meses int,
@numeroFinca int,
@fechaActual date = null
AS
BEGIN
	BEGIN TRY
		-- DECLARACION DE VARIABLES --
		IF(@fechaActual IS NULL)
			SET @fechaActual = GETDATE(); -- inserted At --

		DECLARE @ReciboIntereses table (id INT IDENTITY(1,1),idRecibo int) 
		DECLARE @montoAcumulado bigInt, @montoOriginal bigInt, @saldo bigInt = 0;
		DECLARE @tasaIneteres decimal (4,2), @plazoResta int = 0, @cuota bigInt;
		DECLARE @tempCasting nvarchar(50);
		DECLARE @idPropiedad bigInt;
		DECLARE @interesDelMes bigint;
		DECLARE @amortizacion bigint;

		SELECT @idPropiedad = id FROM Propiedad WHERE numeroFinca = @numeroFinca;

		-- CASTING DE "Tasa Interes AP" --
		SELECT @tasaIneteres = convert(decimal(4,2), [valor]) FROM dbo.[ValoresConfiguracion] AS VC WHERE VC.[nombre] = 'TasaInteres_AP'

		-- GENERAR RECIBOS DE INTERESES MORATORIOS -- (MASIVO ITERATIVO)
		IF EXISTS (SELECT [id] FROM @ReciboSelect)
			BEGIN
			--BEGIN TRANSACTION INTERESES;
				DECLARE @idRecibo int, @id int = 1;
				WHILE @id IS NOT NULL
					BEGIN
						SELECT @idRecibo = T.[idRecibo]
						FROM @ReciboSelect AS T WHERE T.[id] = @id;
						print(@idRecibo)
						print('aaa')
						EXECUTE SP_GenerarRecibosIntereses @idRecibo, @fechaActual -- tipo idCC = 11 --
						print('termine')
						SELECT @id = MIN(id) FROM @ReciboSelect WHERE id > @id;
					END
			--COMMIT TRANSACTION INTERESES;
			END

		--INSERT MASIVO RECIBOS SELECCIONADOS --
		INSERT INTO @ReciboIntereses (idRecibo) 
		SELECT  idRecibo AS R FROM @ReciboSelect

		-- INSERT MASIVO RECIBOS INTERESES PENDIENTES --
		INSERT INTO @ReciboIntereses (idRecibo)
		SELECT R.[id] FROM dbo.Recibo AS R
		WHERE (R.estado = 0 AND R.idConceptoCobro = 11)

		-- CALCULAR EL MONTO ORIGINAL -- 
		SELECT @montoOriginal = SUM(monto) FROM dbo.Recibo
		INNER JOIN @ReciboIntereses AS R ON R.[idRecibo] = dbo.Recibo.[id]

		--CALCULAR LA CUOTA--
		SET @cuota = @montoOriginal*((@tasaIneteres*POWER((1+@tasaIneteres),@meses))/(POWER((1+@tasaIneteres),@meses)-1))

		-- CALCULAR EL SALDO --
		SET @saldo = @montoOriginal

		--CALCULAR INTERES_DEL_MES --
		SET @interesDelMes = @saldo * @tasaIneteres/ 12

		--CALCULAR AMORTIZACION--
		SET @amortizacion = @cuota - @interesDelMes

		--CALCULAR AMORTIZACION --

		-- MOSTRAR AP GENERADO -- (Todavia no se genera comprobante hasta que se cree el AP)
		INSERT INTO dbo.AP ([idPropiedad],[montoOriginal],[saldo],[tasaIneteres],[plazoOriginal],[plazoResta],[cuota],[interesDelMes],[amortizacion],[insertAt],[activo])
		VALUES(@idPropiedad,@montoOriginal,@montoOriginal,@tasaIneteres,@meses,@meses,@cuota,@interesDelMes,@amortizacion,@fechaActual,0) -- no es activo hasta que se crea --

		SELECT AP.[montoOriginal], AP.[saldo], AP.[tasaIneteres], AP.[plazoOriginal], AP.[plazoResta], AP.[cuota], AP.[insertAt]
		FROM AP WHERE AP.[id] = @@IDENTITY

		
	END TRY
	BEGIN CATCH
		DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE SPS_AP

--------------------------------
--------------------------------
--- CREAR LOS RECIBOS COMO AP --
--------------------------------
--------------------------------

CREATE PROCEDURE SP_CrearAP
@ReciboSelect ReciboSelect READONLY, -- Recibos seleccionados --
@meses int, -- plazo de meses para pagar el AP --
@numeroFinca int,
@fechaActual date = null
AS
BEGIN
	BEGIN TRY
		-- DECLARACION DE VARIABLES --
		IF(@fechaActual IS NULL)
			SET @fechaActual = GETDATE(); -- inserted At --

		DECLARE @ReciboIntereses table (id INT IDENTITY(1,1),idRecibo int) 
		DECLARE @montoAcumulado bigInt;
		DECLARE @ultimoAP bigInt;
		DECLARE @comprobanteGenerado bigInt;
		DECLARE @idPropiedad int;

		SELECT @idPropiedad = id FROM Propiedad WHERE numeroFinca = @numeroFinca;
		SELECT @ultimoAP = (SELECT TOP 1 [id] FROM AP ORDER BY ID DESC);
		print('UltimoAP')
		print(@ultimoAP)

		-- SET EL MONTO ACUMULADO PARA EL COMPROBANTE DE PAGO --
		SELECT @montoAcumulado = [montoOriginal] FROM dbo.[AP] WHERE dbo.[AP].[id] = @ultimoAP;

		-- GENERAR COMPROBANTE DE AP --
		-- #1 si ya existe el comprobante con esta fecha y monto --
		IF EXISTS(SELECT [id] FROM dbo.Comprobante_Pago AS CP WHERE (@fechaActual = CP.fecha AND @montoAcumulado = CP.total))
			BEGIN
				DECLARE @idComprobante int;
				SELECT @idComprobante = [id] FROM dbo.Comprobante_Pago AS CP WHERE (CP.total = @montoAcumulado AND CP.fecha = @fechaActual)

				UPDATE dbo.AP SET [idComrpobante] =@idComprobante WHERE [id] = @ultimoAP;
			END
		-- #2 si no existe comprobante --
		ELSE
			BEGIN
				EXEC dbo.SPI_Comprobante_Pago_XML @fechaActual, @montoAcumulado
				UPDATE dbo.AP SET [idComrpobante] =@@IDENTITY WHERE [id] = @ultimoAP;
			END

		-- ACTIVAR AP --
		UPDATE dbo.AP SET [activo] = 1 WHERE [id] = @ultimoAP;
		print('Activando');

		--INSERT MASIVO RECIBOS SELECCIONADOS --
		INSERT INTO @ReciboIntereses (idRecibo) 
		SELECT  idRecibo AS R FROM @ReciboSelect

		-- INSERT MASIVO RECIBOS INTERESES PENDIENTES --
		INSERT INTO @ReciboIntereses (idRecibo)
		SELECT R.[id] FROM dbo.Recibo AS R
		WHERE (R.estado = 0 AND R.idConceptoCobro = 11)

		IF EXISTS (SELECT [id] FROM @ReciboIntereses)
			BEGIN
			--BEGIN TRANSACTION INTERESES;
				DECLARE @idRecibo int, @id int = 1;
				WHILE @id IS NOT NULL
					BEGIN
						SELECT @idRecibo = T.[idRecibo]
						FROM @ReciboIntereses AS T WHERE T.[id] = @id;

						EXECUTE Generar_Comprobante @idRecibo, @fechaActual, @montoAcumulado,1 -- tipo idCC = 11 --
						SELECT @id = MIN(id) FROM @ReciboIntereses WHERE id > @id;
					END
			--COMMIT TRANSACTION INTERESES;
			END

		-- GENERAR UN MOVIMIENTO DE DEBITO -- (SPI_MovimientoAP)

	END TRY
	BEGIN CATCH
		DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE SP_CrearAP

-------------------------------
-------------------------------
--- INSERTAR MOVIMINETOS AP ---
-------------------------------
-------------------------------

CREATE PROCEDURE SPI_Movimiento 
@idAp int,
@tipoMovAp int,
@fecha date = null
AS 
BEGIN
	BEGIN TRY
	-- DECLARACION DE VARIABLES --
	DECLARE @idTipoMov int;
	DECLARE @monto bigInt;
	DECLARE @interesesDelMes bigint;
	DECLARE @plzRest int;
	DECLARE @saldoActual bigint;
	DECLARE @nuevoSaldo bigInt;	-- calcular --
	DECLARE @insertedAt date = GETDATE();
	DECLARE @activo int = 1;
	DECLARE @idPropiedad int;
	DECLARE @ultimoReciboAP int;
	DECLARE @ultimoMovimientoAP int;
	DECLARE @descripcion nvarchar(50);
	DECLARE @cuota bigint;

	-- SET DE VARIABLES --
	IF(@fecha is null)
		SET @fecha = GETDATE();

	SELECT @idTipoMov = [id] FROM dbo.TipoMovAp AS T WHERE T.[codigo] = @tipoMovAp;
	SELECT @monto = [amortizacion] FROM dbo.[AP] AS A WHERE A.[id] = @idAp;
	SELECT @interesesDelMes = [interesDelMes] FROM dbo.[AP] AS A WHERE A.[id] = @idAp;
	SELECT @plzRest = [plazoResta] FROM dbo.[AP] AS A WHERE A.[id] = @idAp;
	SELECT @saldoActual = [saldo] FROM dbo.[AP] AS A WHERE A.[id] = @idAp;
	SELECT @idPropiedad = [idPropiedad] FROM dbo.[AP] AS A WHERE A.[id] = @idAp;
	SELECT @cuota = [cuota] FROM dbo.[AP] AS A WHERE A.[id] = @idAp;

	-- CALCULAR EL NUEVO SALDO --
	SET @nuevoSaldo = @saldoActual - @monto
	IF(@nuevoSaldo < 0)
		SET @nuevoSaldo = 0;

	-- UPDATE DEL NUEVO SALDO --
	UPDATE dbo.AP SET [saldo] = @saldoActual WHERE [id] = @idAp;

	-- REDUCIR EL PLAZO RESTANTE --
	SET @plzRest = @plzRest - 1;
	IF(@plzRest = 0) -- si el plazo termina anule el AP
		BEGIN
			UPDATE dbo.AP SET [activo] = 0 WHERE [id] = @idAp;
		END

	-- UPDATE EL PLAZO RESTANTE --
	UPDATE dbo.AP SET [plazoResta] = @plzRest WHERE [id] = @idAp;

	-- INSERTAR NUEVO MOVIMIENTO --
	INSERT INTO dbo.[MovimientosAP]([idAP], [idTipoMov], [monto], [interesesDelMes], [plazoRest], [nuevoSaldo], [fecha], [insertedAt], [activo])
	VALUES(@idAp, @idTipoMov, @monto, @interesesDelMes, @plzRest, @nuevoSaldo, @fecha, GETDATE(), @activo)
	SELECT @ultimoReciboAP = (SELECT TOP 1 [id] FROM dbo.Recibo ORDER BY ID DESC); -- Guardar recibo --

	print(@cuota)
	-- GENERAR RECIBO DE MOVIMIENTO CON MONTO DE CUOTA --
	EXECUTE SPI_Recibos 12,@idPropiedad,@fecha,@cuota -- codigo 12: AP --
	SELECT @ultimoMovimientoAP = (SELECT TOP 1 [id] FROM dbo.MovimientosAP ORDER BY ID DESC); -- Guardar Movimiento --

	-- HACER DESCRIPCION --
	SET @descripcion = CONCAT('Interes mensual:',@interesesDelMes,', amonestazion:',@monto,', plazo resta:', @plzRest)

	-- INSERTAR RECIBO EN RECIBOS_AP --
	INSERT INTO dbo.[RecibosAP]([id],[idMovimientoAP],[descirpcion],[activo])
	VALUES(@ultimoReciboAP,@ultimoMovimientoAP,@descripcion,1)

	END TRY
	BEGIN CATCH
		DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE SPI_Movimiento



-------------------------------
-------------------------------
--- GENERAR MOVIMINETOS AP ---
-------------------------------
-------------------------------
CREATE PROCEDURE Generar_Moviminetos
@fecha date
AS
BEGIN
	BEGIN TRY
	-- VARIABLES TABLA --
	DECLARE @Movimientos_DeDia table (id INT IDENTITY(1,1),idAp int) 

	-- DECLARACION DE VARIABLES --
	DECLARE @dia int;

	-- GET DIA DE FECHA --
	SET @dia = DAY(@fecha);

	-- INSERTAR AP QUE NECESITAN MOVIMIENTOS GENERADOS ESTA FECHA --
	INSERT INTO @Movimientos_DeDia([idAp])
	SELECT [id] FROM dbo.AP AS A 
	WHERE (DAY(A.[insertAt]) = @dia AND A.activo = 1)

	IF EXISTS(SELECT [id] FROM @Movimientos_DeDia) -- Si hay movimiento que insertar
		BEGIN 
		DECLARE @idAP int, @id int = 1;
		BEGIN TRANSACTION
			WHILE @id IS NOT NULL
				BEGIN
					SELECT @idAP = T.idAp FROM @Movimientos_DeDia AS T 
					WHERE T.[id] = @id;

					EXEC dbo.SPI_Movimiento @idAP,1, @fecha; -- Insertar movimiento de debito

					SELECT @id = MIN(id) FROM @Movimientos_DeDia WHERE id > @id;
				END
			-- al terminar el dia hay que borrar los datos --
			DELETE FROM @Movimientos_DeDia
		COMMIT TRANSACTION
		END
	
	END TRY
	BEGIN CATCH
		DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
		ROLLBACK TRANSACTION;
	END CATCH
END

DROP PROCEDURE Generar_Moviminetos


-----------------------------------
-----------------------------------
--  SELECET AP DE UNA PROPIEDAD  --
-----------------------------------
-----------------------------------


CREATE PROCEDURE SPS_AP_de_Propieadad
@numeroFinca int
AS	
BEGIN
	BEGIN TRY
		DECLARE @idPropiedad int
		SELECT @idPropiedad = id FROM dbo.[Propiedad] WHERE numeroFinca = @numeroFinca;

		SELECT AP.[montoOriginal], AP.[saldo], AP.[tasaIneteres], AP.[plazoOriginal], AP.[plazoResta], AP.[cuota], AP.[insertAt], AP.[idComrpobante], CP.total, AP.id, AP.amortizacion, AP.interesDelMes
		FROM AP 
		JOIN Comprobante_Pago CP ON CP.id = AP.idComrpobante
		WHERE AP.[idPropiedad] = @idPropiedad AND Ap.[activo] = 1
		
	END TRY
	BEGIN CATCH
		DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE SPS_AP_de_Propieadad

CREATE PROCEDURE SPS_MovimientosAP
@idAP int
AS 
BEGIN
	BEGIN TRY
		
		SELECT MAP.nuevoSaldo, AP.amortizacion, AP.interesDelMes, MAP.monto, MAP.fecha, MAP.plazoRest, CP.id, Cp.total, RCP.fechaLeido
		FROM AP
		JOIN MovimientosAP MAP ON MAP.idAP = AP.id
		JOIN RecibosAP RAP ON RAP.idMovimientoAP = MAP.id
		JOIN Recibo_por_ComprobantePago RCP ON RCP.idRecibo = RAP.id
		JOIN Comprobante_Pago CP ON CP.id = RCP.idComprobante_Pago
		WHERE AP.id = @idAP and MAP.activo = 1
		ORDER BY MAP.fecha DESC

	END TRY
	BEGIN CATCH
		DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE SPS_MovimientosAP
EXECUTE SPS_MovimientosAP 1383
EXECUTE SPS_RecibosPorComprobante 11591,'2020-04-10', 1565045
select * from Recibo_por_ComprobantePago where idComprobante_Pago = 11591

select * from Recibo where id = 18683


select R.idPropiedad, AP.idPropiedad FROM RecibosAP RAP
JOIN MovimientosAP M ON M.id = RAP.idMovimientoAP
JOIN Recibo R ON R.id = RAP.id
JOIN AP ON AP.id = M.idAP
JOIN Propiedad P ON P.id = AP.idPropiedad

idPropiedad; 29016
Recibo: 18683
idMov : 132
idCom : 11591
fechaleidO :2020-04-10
idPropiedad ; 28837
numFinca: 1565045

-----------------------------------
-----------------------------------
--  NO PAGAR LOS RECIBOS COMO AP --
-----------------------------------
-----------------------------------

-- SP_AnularIntereses 

-----------------------------------
-----------------------------------
-------  CREAR AP DEL XML ---------
-----------------------------------
-----------------------------------

CREATE PROCEDURE SPI_APXML
@numeroFinca int,
@meses int,
@fecha date
AS
BEGIN
	BEGIN TRY
	
	-- VARIABLES TABLA --
	DECLARE @ReciboSelect ReciboSelect;

	-- DECLARACION DE VARIABLES --
	DECLARE @idPropiedad int;

	-- SET VARIABLES --
	SELECT @idPropiedad = [id] FROM dbo.[Propiedad] WHERE @numeroFinca = [numeroFinca]

	IF NOT EXISTS(SELECT [id] FROM dbo.AP AS A WHERE (A.[idPropiedad] = @idPropiedad AND A.[insertAt] = @fecha))
		BEGIN
			-- INSERTAR RECIBOS PENDIENTES DE PROPIEDAD--
			INSERT INTO @ReciboSelect (idRecibo) 
			SELECT R.[id] FROM dbo.Recibo AS R
			WHERE (R.[idPropiedad] = @idPropiedad AND R.estado = 0)

			-- CREAR AP DE RECIBOS --
			EXEC SPS_AP @ReciboSelect, @meses, @numeroFinca, @fecha
			EXEC SP_CrearAP @ReciboSelect, @meses, @numeroFinca, @fecha
		END

	END TRY
	BEGIN CATCH
		DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE SPI_APXML

-------------------
-- SP DE PRUEBAS --
-------------------

CREATE PROCEDURE SP_Pruebilla01
@num int
AS 
BEGIN
	DECLARE @ReciboSelect ReciboSelect;

	INSERT INTO @ReciboSelect (idRecibo) 
	SELECT R.[id] FROM dbo.Recibo AS R
	WHERE (R.[id] < @num AND R.estado = 0) 
	
	EXEC SPS_AP @ReciboSelect, 3, 17368
	

END


select id from Propiedad where numeroFinca = 4203725
select * from Recibo where idPropiedad = 17496
DROP PROCEDURE SP_Pruebilla01
EXEC SP_Pruebilla01 32914



DECLARE @ReciboSel ReciboSelect;
INSERT INTO @ReciboSel (id, idRecibo)
VALUES(1, 527)
EXEC SPS_AP @ReciboSel, 12, 4203725

DECLARE @ReciboSel ReciboSelect;
INSERT INTO @ReciboSel (id, idRecibo)
VALUES(1, 34381)
EXEC SP_CrearAP @ReciboSel, 12, 4203725


select * from AP
EXECUTE SPS_AP_de_Propieadad 4203725

select numeroFinca FROM Propiedad where id = 19212

select * from Recibo where id = 32913
SELECT * FROM dbo.[Propiedad]
SELECT * FROM dbo.[Recibo] WHERE dbo.[Recibo].[idConceptoCobro] = 11 AND dbo.[Recibo].[estado] = 0)
SELECT * FROM dbo.[AP]


select * from AP
select id From propiedad where numeroFinca = 4203725
SELECT * FROM [ValoresConfiguracion]
UPDATE dbo.[Recibo] SET [estado] = 0 WHERE [id] = 32913;

-- PRUEBAS MOVIMINETO --
SELECT * FROM dbo.[TipoMov]
SELECT * FROM dbo.[RecibosAP]
SELECT * FROM dbo.[MovimientosAP]
SELECT * FROM dbo.[AP]
SELECT * FROM dbo.[Recibo] AS R WHERE R.[idPropiedad] = 26263
SELECT * FROM dbo.[Propiedad] AS P WHERE P.numeroFinca = 1565045

EXEC SPI_Movimiento 2, 1
EXEC Generar_Moviminetos '2020-07-23'

SELECT * FROM dbo.[Propiedad]

EXEC SPI_APXML 1565045,5, '2020-04-02'

