-------------------------------
-------------------------------
	-- GENERAR RECIBOS --
-------------------------------
-------------------------------


CREATE PROCEDURE SPI_GenerarRecibos
@fecha date
AS
BEGIN TRY
	-- TABLAS TEMPORALES --
	DECLARE @ConceptoCobro_DeDia table (id INT IDENTITY(1,1),idPropiedad int,idConcptoCobro int) 
	
	-- GET DIA DE FECHA --
	DECLARE @dia int;
	SET @dia = DAY(@fecha);

	-- INSERTAR FILAS DE @ConceptoCobro_DeDia --
	INSERT INTO @ConceptoCobro_DeDia([idPropiedad], [idConcptoCobro])
	SELECT Propiedad.[id], Concepto_Cobro.[id] FROM dbo.[Concepto_Cobro_en_Propiedad]
	INNER JOIN Propiedad ON [idPropiedad] = Propiedad.[id]
	INNER JOIN Concepto_Cobro ON [idConeceptoCobro] = Concepto_Cobro.[id]
	WHERE (Concepto_Cobro.[DiaDeCobro] = @dia)

	SELECT * FROM @ConceptoCobro_DeDia;

	-- ITERACION MASIVA PARA GENERAR RECIBOS --
	IF EXISTS(SELECT [id] FROM @ConceptoCobro_DeDia)
		BEGIN
		BEGIN TRANSACTION
			DECLARE @idPropiedad int, @idConceptoCobro int, @id int = 1;
			WHILE @id IS NOT NULL
					BEGIN
						SELECT @idPropiedad = T.[idPropiedad], @idConceptoCobro = T.[idConcptoCobro]
						FROM @ConceptoCobro_DeDia AS T WHERE T.[id] = @id;

						EXEC dbo.SPI_Recibos @idConceptoCobro, @idPropiedad, @fecha;

						SELECT @id = MIN(id) FROM @ConceptoCobro_DeDia WHERE id > @id;
					END
				-- al terminar el dia hay que borrar los datos --
				 DELETE FROM @ConceptoCobro_DeDia
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

DROP PROCEDURE SPI_GenerarRecibos

-------------------------------
-------------------------------
		--Insert--
-------------------------------
-------------------------------


CREATE PROCEDURE SPI_Recibos
@idConceptoCobro int,
@idPropiedad int,
@fechaGenerado date
AS
BEGIN TRY
	-- DATOS CONCEPTO DE COBRO ( y herencias )--
	DECLARE @qDiaVencimiento int, @monto int, @esFijo varchar(10), @retValue int;
	DECLARE @nombreCC nvarchar(50);
	-- DATOS CALCULADOS PARA RECIBO --
	DECLARE @fechaVencimineto date; 

	SELECT @qDiaVencimiento = [qDiasVencidos] FROM dbo.[Concepto_Cobro] WHERE @idConceptoCobro = [id];
	SELECT @esFijo = [EsFijo] FROM dbo.[Concepto_Cobro] WHERE @idConceptoCobro = [id];
	SELECT @nombreCC = [nombre] FROM dbo.[Concepto_Cobro] WHERE @idConceptoCobro = [id]
	
	-- GET ID DE HERENCIA --
	IF ( @esFijo = 'Si')
		BEGIN
			SELECT @monto = [monto] FROM dbo.[CC_Fijo] WHERE @idConceptoCobro = [id];
		END
	-- ES CONSUMO AGUA--
	ELSE IF (@nombreCC = 'Agua')
		BEGIN
			-- Variables de tabla Propiedad --
			DECLARE @AcumuladoActualM3 int, @AcumuladoUltimoRecibo int, @ValorM3 int, @MontoMinimo int;

			SELECT @AcumuladoActualM3 = [m3Acumulados] FROM dbo.[Propiedad] WHERE @idPropiedad = [id]
			SELECT @AcumuladoUltimoRecibo = [m3AcumuladosUR] FROM dbo.[Propiedad] WHERE @idPropiedad = [id]
			SELECT @ValorM3 = [valorM3] FROM dbo.[CC_Consumo] WHERE @idConceptoCobro = [id]
			SELECT @MontoMinimo = [montoMinimoRecibo] FROM dbo.[CC_Consumo] WHERE @idConceptoCobro = [id]
			
			-- Calculo del recibo -- 
			IF((@AcumuladoActualM3 - @AcumuladoUltimoRecibo) * @ValorM3 > @MontoMinimo)
				SET @monto = (@AcumuladoActualM3 - @AcumuladoUltimoRecibo) * @ValorM3
			ELSE
				SET @monto = @MontoMinimo

		END
	-- ES PORCENTUAL (EsImpuesto)--
	ELSE
		BEGIN
			-- Calculate porcentaje sobre la poblacion --
			DECLARE @impuesto int, @valorPropiedad int;
			-- Aqui esta el error --
			SELECT @impuesto = [ValorPorcentaje] FROM dbo.[CC_Porcentual]  WHERE @idConceptoCobro = [id];
			SELECT @valorPropiedad = [valor] FROM dbo.[Propiedad] WHERE @idPropiedad = [id];

			SET @monto = @valorPropiedad * @impuesto;
		END
		
	
	-- CALULAR LA FECHA DE VENCIMIENTO --
	SELECT @fechaVencimineto = DATEADD(day, @qDiaVencimiento, @fechaGenerado);

	INSERT INTO dbo.Recibo ([idComprobanteDePago],[idPropiedad], [idConceptoCobro], [monto], [fecha], [fechaVencimiendo], 
							[estado], [activo])
	VALUES(null,@idPropiedad, @idConceptoCobro, @monto, @fechaGenerado, @fechaVencimineto, 0, 1);
	SET @retValue = SCOPE_IDENTITY();

END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
END CATCH

DROP PROCEDURE SPI_Recibos

-------------------------------------------
-------------------------------------------
-- INSERT DE RECIBO INTERESES MORATORIOS --
--------------------------------------------
--------------------------------------------


CREATE PROCEDURE SPI_ReciboIntereses
@fechaActual date,
@idRecibo int
AS 
BEGIN TRY

	-- DECLARACION DE VARIABLES --
	DECLARE @fechaMax date, @montoRecibo int, @monto int, @intereses float, @tipoRecibo int, @fechaVencimineto date;
	SELECT @montoRecibo = [monto] FROM dbo.[Recibo] AS R WHERE R.[id] = @idRecibo
	SELECT @tipoRecibo = [idConceptoCobro] FROM dbo.[Recibo] AS R WHERE R.[id] = @idRecibo
	SELECT @intereses = [tasaInteresesMoratorios] FROM dbo.Concepto_Cobro AS C WHERE C.[id] = @tipoRecibo
	SELECT @fechaMax = [fechaVencimiendo] FROM dbo.[Recibo] AS R WHERE R.[id] = @idRecibo 

	DECLARE @idPropiedad int, @retValue int;
	SELECT @idPropiedad = [idPropiedad] FROM dbo.[Recibo] AS R WHERE R.[id] = @idRecibo

	--CALCULO DE MONTO DE RECIBO --
	DECLARE @fechaDif int;
	SET @fechaDif = ABS(DATEDIFF(day, @fechaMax, @fechaActual))
	SET @monto = (@montoRecibo*@intereses/365)*@fechaDif -- dividido entre 365

	-- CALCULAR FECHA DE VENICIMIENTO --
	DECLARE @qDiaVencimiento int;
	SELECT @qDiaVencimiento = [qDiasVencidos] FROM dbo.[Concepto_Cobro] AS CC WHERE  CC.nombre = 'Interes Moratorio';
	SELECT @fechaVencimineto = DATEADD(day, @qDiaVencimiento, @fechaActual);

	--INSERTAR RECIBO INTERES --
	INSERT INTO dbo.Recibo ([idComprobanteDePago],[idPropiedad], [idConceptoCobro], [monto], [fecha], [fechaVencimiendo], 
							[estado], [activo])
	VALUES(null,@idPropiedad, 11, @monto, @fechaActual, @fechaVencimineto, 0, 1);
	SET @retValue = SCOPE_IDENTITY();
END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
END CATCH

DROP PROCEDURE SPI_ReciboIntereses


-- GENERAR INTERESES MORATORIOS
CREATE PROCEDURE SP_GenerarRecibosIntereses
@idRecibo int,
@fecha date
AS
BEGIN TRY
	-- DECLARACION DE VARIABLES --
	DECLARE @fechaVencimiento date, @retValue int = 1, @idPropiedad int;
	SELECT @fechaVencimiento = [fechaVencimiendo] FROM dbo.[Recibo] AS R WHERE R.[id] = @idRecibo
	SELECT @idPropiedad = [idPropiedad] FROM dbo.[Recibo] AS R WHERE R.[id] = @idRecibo

	IF (@fecha >= @fechaVencimiento)
		BEGIN
			print('hola')
			-- INSERTAR INTERES MORATORIO --
			EXECUTE SPI_ReciboIntereses @fecha, @idRecibo
			SET @retvalue = 1;
		END
		print('hola2')
	RETURN  @retValue;

END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
END CATCH

DROP PROCEDURE SP_GenerarRecibosIntereses


-------------------------------
-------------------------------
--Pagado multiple de recibos --
-------------------------------
-------------------------------


CREATE PROCEDURE SP_Pagado_Multiple
@numFinca int,
@tipoRecibo int, -- idConceptoCobro --
@fecha date = null -- GET DATE PARA WEB --
AS 
BEGIN TRY
	-- DECLARACION DE VARIABLES --
	-- Tabla con los recibos a pagar que son de tipoRecibo y NumFinca --
	DECLARE @RecibosDelDia table (id INT IDENTITY(1,1),idRecibo int) 
	DECLARE @RecibosAPagar table (id INT IDENTITY(1,1),idRecibo int, tipoRecibo int,monto int) 
	DECLARE @montoAcumulado int;
	IF(@fecha is Null)
		BEGIN 
			SET @fecha = GETDATE();
		END

	-- INSERT MASIVO DE PROPIEDADES EN TABLA --
	IF (@tipoRecibo = 10) -- Pago a reconexion de agua --
		BEGIN
			INSERT INTO @RecibosDelDia([idRecibo])
			SELECT Recibo.[id] FROM dbo.Recibo
			INNER JOIN dbo.Propiedad ON Propiedad.[id] = dbo.Recibo.[idPropiedad]
			WHERE(dbo.Propiedad.[numeroFinca] = @numFinca 
				 AND (dbo.Recibo.[idConceptoCobro] = 10 OR dbo.Recibo.[idConceptoCobro] = 1)
				 AND dbo.Recibo.[estado] = 0)
		END
	ELSE -- Sino es un pago a reconexion --
		BEGIN
			INSERT INTO @RecibosDelDia([idRecibo])
			SELECT Recibo.[id] FROM dbo.Recibo
			INNER JOIN dbo.Propiedad ON Propiedad.[id] = dbo.Recibo.[idPropiedad]
			WHERE(dbo.Propiedad.[numeroFinca] = @numFinca AND dbo.Recibo.[idConceptoCobro] = @tipoRecibo AND dbo.Recibo.[estado] = 0)
		END

	SELECT * FROM @RecibosDelDia

	-- GENERAR RECIBOS DE INTERESES MORATORIOS -- (MASIVO ITERATIVO)
	IF EXISTS (SELECT [id] FROM @RecibosDelDia)
		BEGIN
		BEGIN TRANSACTION INTERESES;
			DECLARE @idRecibo int, @id int = 1;
			WHILE @id IS NOT NULL
				BEGIN
					SELECT @idRecibo = T.[idRecibo]
					FROM @RecibosDelDia AS T WHERE T.[id] = @id;

					EXECUTE SP_GenerarRecibosIntereses @idRecibo, @fecha -- tipo idCC = 11 --
					SELECT @id = MIN(id) FROM @RecibosDelDia WHERE id > @id;
				END
				DELETE FROM @RecibosDelDia
		COMMIT TRANSACTION INTERESES;
		END

	-- INSERT MASIVO DE PROPIEDADES EN TABLA Y RECIBOS POR INTERESES MORATORIOS --
	IF (@tipoRecibo = 10) -- Pago a reconexion de agua --
		BEGIN
			INSERT INTO @RecibosAPagar([idRecibo], [monto], [tipoRecibo])
			SELECT Recibo.[id], Recibo.[monto], Recibo.[idConceptoCobro] FROM dbo.Recibo
			INNER JOIN dbo.Propiedad ON Propiedad.[id] = dbo.Recibo.[idPropiedad]
			WHERE(dbo.Propiedad.[numeroFinca] = @numFinca 
			AND (dbo.Recibo.[idConceptoCobro] = 10 OR dbo.Recibo.[idConceptoCobro] = 11 OR dbo.Recibo.[idConceptoCobro] = 1) 
			AND dbo.Recibo.[estado] = 0)
		END
	ELSE -- Sino es un pago a reconexion --
		BEGIN
			INSERT INTO @RecibosAPagar([idRecibo], [monto], [tipoRecibo])
			SELECT Recibo.[id], Recibo.[monto], Recibo.[idConceptoCobro] FROM dbo.Recibo
			INNER JOIN dbo.Propiedad ON Propiedad.[id] = dbo.Recibo.[idPropiedad]
			WHERE(dbo.Propiedad.[numeroFinca] = @numFinca AND 
			(dbo.Recibo.[idConceptoCobro] = @tipoRecibo OR dbo.Recibo.[idConceptoCobro] = 11) AND dbo.Recibo.[estado] = 0)
		END

	-- CALCULAR EL MONTO ACUMULADO PARA TODOS LOS RECIBOS -- (MASIVO)
	SELECT @montoAcumulado = SUM(monto) FROM @RecibosAPagar;

	print(@montoAcumulado)

	-- GENERAR ORDENES DE RECONEXION --
	DECLARE @idReconexion int;

	IF (@tipoRecibo = 10)
		BEGIN
		BEGIN TRANSACTION RECONEXIONES;
			-- select de recibo de reconexion --
			SELECT @idReconexion = [idRecibo] FROM @RecibosAPagar AS R WHERE R.tipoRecibo = 10
			print(@idReconexion)
			-- si hay un atributo de reconexion que se va a pagar --
			IF(@idReconexion IS NOT NULL)
				BEGIN
					INSERT INTO dbo.Reconexion([idPropiedad], [idReciboReconexion], [activo],[fecha])
					SELECT Recibo.[idPropiedad], Recibo.[id], 1, @fecha FROM dbo.Recibo
					WHERE Recibo.[id] = @idReconexion
				END
		COMMIT TRANSACTION RECONEXIONES;
		END

	-- GENERAR LOS COMPROMBANTES DE LOS RECIBOS -- (MASIVO ITERATIVO)
	IF EXISTS (SELECT [id] FROM @RecibosAPagar)
		BEGIN
		BEGIN TRANSACTION PAGOS;
			DECLARE @idReciboPagar int, @idPagar int = 1;
			WHILE @idPagar IS NOT NULL
				BEGIN
					SELECT @idRecibo = T.[idRecibo]
					FROM @RecibosAPagar AS T WHERE T.[id] = @idPagar;

					EXECUTE Generar_Comprobante @idRecibo, @fecha, @montoAcumulado

					SELECT @idPagar = MIN(id) FROM @RecibosAPagar WHERE id > @idPagar;
				END
				DELETE FROM @RecibosAPagar
		COMMIT TRANSACTION PAGOS;
		END



END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH

DROP PROCEDURE SP_Pagado_Multiple

-------------------------------
-------------------------------
-- SELECT PARA CONSULTAS WEB ---
-------------------------------
-------------------------------

CREATE PROCEDURE SPS_Recibos
@numeroFinca int,
@nombreConceptoCobro varchar(30) = null, -- idConceptoCobro --
@estado int
AS 
BEGIN
	BEGIN TRY
		IF @nombreConceptoCobro is not null
		BEGIN 
			DECLARE @idPropiedad int, @idConceptoCobro int
			-- Obtener id's --
			SELECT @idPropiedad = id FROM dbo.[Propiedad] WHERE numeroFinca = @numeroFinca and activo = 1
			SELECT @idConceptoCobro = id FROM dbo.[Concepto_Cobro] WHERE nombre = @nombreConceptoCobro and activo = 1

			-- Consulta principal ---
			SELECT CC.nombre, R.idConceptoCobro, R.monto, R.fecha, R.fechaVencimiendo, R.id
			FROM dbo.[Recibo] R
			JOIN dbo.[Concepto_Cobro] CC ON CC.id = R.idConceptoCobro
			WHERE R.idPropiedad = @idPropiedad and R.idConceptoCobro = @idConceptoCobro and R.estado = @estado and R.activo = 1
		END

		ELSE
		BEGIN
			-- Obtener id's --
			SELECT @idPropiedad = id FROM dbo.[Propiedad] WHERE numeroFinca = @numeroFinca and activo = 1
			-- Consulta principal ---

			SELECT CC.nombre, R.idConceptoCobro, R.monto, R.fecha, R.fechaVencimiendo, R.id
			FROM dbo.[Recibo] R
			JOIN dbo.[Concepto_Cobro] CC ON CC.id = R.idConceptoCobro
			WHERE R.idPropiedad = @idPropiedad and R.estado = @estado and R.activo = 1
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

DROP PROCEDURE SPS_Recibos
------------------------------------
------------------------------------
-- SELECT PARA CONSULTAS WEB 2.0 ---
------------------------------------
------------------------------------

CREATE PROCEDURE SPS_RecibosIntereses
@ReciboSelect ReciboSelect READONLY 
AS
BEGIN
	BEGIN TRY
		-- DECLARACION DE VARIABLES --
		DECLARE @fechaActual date = GETDATE();
		DECLARE @ReciboIntereses table (id INT IDENTITY(1,1),idRecibo int) 
	

		-- GENERAR RECIBOS DE INTERESES MORATORIOS -- (MASIVO ITERATIVO)
		IF EXISTS (SELECT [id] FROM @ReciboSelect)
			BEGIN
			--BEGIN TRANSACTION INTERESES;
				DECLARE @idRecibo int, @id int = 1;
				WHILE @id IS NOT NULL
					BEGIN
						SELECT @idRecibo = T.[idRecibo]
						FROM @ReciboSelect AS T WHERE T.[id] = @id;

						EXECUTE SP_GenerarRecibosIntereses @idRecibo, @fechaActual -- tipo idCC = 11 --
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

		-- MOSTRAR TABLA GENERADA -- (ESTE ES EL SELECT)
		SELECT CC.nombre, R.monto, R.fecha, R.fechaVencimiendo
		FROM dbo.[Recibo] R
		JOIN dbo.[Concepto_Cobro] CC ON CC.id = R.idConceptoCobro
		INNER JOIN @ReciboIntereses AS T ON T.idRecibo = R.id

	-- GENERACION DE INTERESES --
	END TRY
	BEGIN CATCH
		DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE SPS_RecibosIntereses 

--------------------------------------
--------------------------------------
-- NO PAGAR PARA CONSULTAS WEB 2.0 ---
--------------------------------------
--------------------------------------

CREATE PROCEDURE SP_AnularIntereses
AS
BEGIN
	-- ANULA LOS ARCHIVOS PENDIENTES --
	UPDATE dbo.[Recibo]
	SET [estado] = 3
	FROM dbo.[Recibo]
	WHERE (dbo.Recibo.idConceptoCobro = 11 AND dbo.Recibo.estado = 0)
END

DROP PROCEDURE SP_AnularIntereses

--------------------------------------
--------------------------------------
-- SI PAGAR PARA CONSULTAS WEB 2.0 ---
--------------------------------------
--------------------------------------

CREATE PROCEDURE SP_PagarSeleccion
@ReciboSelect ReciboSelect READONLY 
AS
BEGIN
	BEGIN TRY
		-- DECLARACION DE VARIABLES --
		DECLARE @fechaActual date = GETDATE();
		DECLARE @ReciboIntereses table (id INT IDENTITY(1,1),idRecibo int) 
		DECLARE @montoAcumulado int;

		--
		--INSERT MASIVO RECIBOS SELECCIONADOS --
		INSERT INTO @ReciboIntereses (idRecibo) 
		SELECT  idRecibo AS R FROM @ReciboSelect

		-- INSERT MASIVO RECIBOS INTERESES PENDIENTES --
		INSERT INTO @ReciboIntereses (idRecibo)
		SELECT R.[id] FROM dbo.Recibo AS R
		WHERE (R.estado = 0 AND R.idConceptoCobro = 11)


		-- CALCULAR EL MONTO ACUMULADO PARA TODOS LOS RECIBOS -- (MASIVO)
		SELECT @montoAcumulado = SUM(monto) FROM dbo.Recibo
		INNER JOIN @ReciboIntereses AS R ON R.[idRecibo] = dbo.Recibo.[id]

		print(@montoAcumulado)


		-- GENERAR COMPROBANTES DE PAGO --

		IF EXISTS (SELECT [id] FROM @ReciboIntereses)
			BEGIN
			--BEGIN TRANSACTION INTERESES;
				DECLARE @idRecibo int, @id int = 1;
				WHILE @id IS NOT NULL
					BEGIN
						SELECT @idRecibo = T.[idRecibo]
						FROM @ReciboIntereses AS T WHERE T.[id] = @id;

						EXECUTE Generar_Comprobante @idRecibo, @fechaActual, @montoAcumulado -- tipo idCC = 11 --
						SELECT @id = MIN(id) FROM @ReciboIntereses WHERE id > @id;
					END
			--COMMIT TRANSACTION INTERESES;
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

DROP PROC SP_PagarSeleccion

-------------
-- PRUEBAS --
-------------

select * from Concepto_Cobro

EXECUTE SPI_Recibos 10,45,'2020-05-20'
EXECUTE SPI_GenerarRecibos '2020-01-5'
select * from dbo.[Recibo]
select * from Comprobante_Pago
EXECUTE SP_Pagar_Recibos 1, '2020-05-16', 10005
DROP PROCEDURE dbo.SP_Pagar_Recibos


SELECT * FROM dbo.Concepto_Cobro_en_Propiedad where idConeceptoCobro = 10
SELECT * FROM dbo.CC_Fijo
SELECT * FROM dbo.CC_Consumo
SELECT * FROM dbo.Concepto_Cobro

SELECT * FROM dbo.Recibo where id = 31699
SELECT * FROM dbo.Recibo where idPropiedad = 6406
SELECT * FROM dbo.Propiedad where numeroFinca = 3151260
SELECT * FROM dbo.Propiedad where id = 6406

UPDATE dbo.Recibo SET estado = 1 where dbo.Recibo.id = 1350
print(GETDATE())
DECLARE @fechaActual date = GETDATE();
EXEC SP_GenerarRecibosIntereses 1,@fechaActual
SELECT [idPropiedad] FROM dbo.[Recibo] AS R WHERE (R.idConceptoCobro = 11 AND R.estado = 0)
SELECT * FROM dbo.Propiedad where [id] = 5160

EXEC SPI_ReciboIntereses '2020-02-20', 9936
EXEC SP_Pagado_Multiple 2407485, 3, '2020-04-21'

EXEC SP_Pagado_Multiple 3099309, 10, '2020-04-22'

SELECT * FROM dbo.Comprobante_Pago
SELECT * FROM dbo.Recibo_por_ComprobantePago
SELECT * FROM dbo.Reconexion


-- SP DE PRUEBAS --

CREATE PROCEDURE SP_Pruebilla
@num int
AS 
BEGIN
	DECLARE @ReciboSelect ReciboSelect;

	INSERT INTO @ReciboSelect (idRecibo) 
	SELECT R.[id] FROM dbo.Recibo AS R
	WHERE (R.[id] < @num AND R.estado = 0) 
	
	--SELECT * FROM @ReciboSelect

	--EXEC SPS_RecibosIntereses @ReciboSelect
	EXEC SP_PagarSeleccion @ReciboSelect

END

DROP PROCEDURE SP_Pruebilla
EXEC SP_Pruebilla 31326


