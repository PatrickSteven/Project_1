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
@idPropiedad int
AS
BEGIN
	BEGIN TRY
		-- DECLARACION DE VARIABLES --
		DECLARE @fechaActual date = GETDATE(); -- inserted At --
		DECLARE @ReciboIntereses table (id INT IDENTITY(1,1),idRecibo int) 
		DECLARE @montoAcumulado int, @montoOriginal int, @saldo int = 0;
		DECLARE @tasaIneteres decimal (4,2), @plazoResta int = 0, @cuota money;
		DECLARE @tempCasting nvarchar(50);

		-- CASTING DE "Tasa Interes AP" --
		print('d')
		SELECT @tasaIneteres = convert(decimal(4,2), [valor]) FROM dbo.[ValoresConfiguracion] AS VC WHERE VC.[nombre] = 'TasaInteres_AP'
		print('d')

		SELECT * FROM @ReciboSelect

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

		SELECT * FROM @ReciboIntereses

		print('a')
		-- CALCULAR EL MONTO ORIGINAL -- 
		SELECT @montoOriginal = SUM(monto) FROM dbo.Recibo
		INNER JOIN @ReciboIntereses AS R ON R.[idRecibo] = dbo.Recibo.[id]

		--CALCULAR LA CUOTA--
		print('a')
		SET @cuota = @montoOriginal*((@tasaIneteres*POWER((1+@tasaIneteres),@meses))/(POWER((1+@tasaIneteres),@meses)-1))
		print('a')

		-- MOSTRAR AP GENERADO -- (Todavia no se genera comprobante hasta que se cree el AP)
		INSERT INTO dbo.AP ([idPropiedad],[montoOriginal],[saldo],[tasaIneteres],[plazoOriginal],[plazoResta],[cuota],[insertAt],[activo])
		VALUES(@idPropiedad,@montoOriginal,@montoOriginal,@tasaIneteres,@meses,@plazoResta,@cuota,@fechaActual,0) -- no es activo hasta que se crea --

		SELECT AP.[montoOriginal], AP.[montoOriginal], AP.[tasaIneteres], AP.[plazoOriginal], AP.[plazoResta], AP.[cuota], AP.[insertAt]
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
@idPropiedad int
AS
BEGIN
	BEGIN TRY
		DECLARE @fechaActual date = GETDATE();
		DECLARE @ReciboIntereses table (id INT IDENTITY(1,1),idRecibo int) 
		DECLARE @montoAcumulado int;
		DECLARE @ultimoAP int = @@IDENTITY;
		DECLARE @comprobanteGenerado int;

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
-- PAGAR LOS RECIBOS COMO AP --
-------------------------------
-------------------------------

CREATE PROCEDURE SP_PagarRecibosAP
@ReciboSelect ReciboSelect READONLY, -- Recibos seleccionados --
@meses int, -- plazo de meses para pagar el AP --
@idPropiedad int
AS
BEGIN
	BEGIN TRY
		DECLARE @fechaActual date = GETDATE();
		DECLARE @ReciboIntereses table (id INT IDENTITY(1,1),idRecibo int) 
		DECLARE @montoAcumulado int;

		-- GENERAR COMPROBANTE DE AP --

		-- GENERAR UN MOVIMIENTO DE DEBITO -- (SPI_Movimient)

	END TRY
	BEGIN CATCH
		DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

-----------------------------------
-----------------------------------
--  NO PAGAR LOS RECIBOS COMO AP --
-----------------------------------
-----------------------------------

-- SP_AnularIntereses 

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
	
	SELECT * FROM @ReciboSelect
	EXEC SPS_AP @ReciboSelect, 3, 17368
	EXEC SP_CrearAP @ReciboSelect, 3, 17368
	

END

DROP PROCEDURE SP_Pruebilla01
EXEC SP_Pruebilla01 32914

SELECT * FROM dbo.[Propiedad]
SELECT * FROM dbo.[Recibo] WHERE dbo.[Recibo].[idConceptoCobro] = 11 AND dbo.[Recibo].[estado] = 0)
SELECT * FROM dbo.[AP]


SELECT * FROM [ValoresConfiguracion]
UPDATE dbo.[Recibo] SET [estado] = 0 WHERE [id] = 32913;