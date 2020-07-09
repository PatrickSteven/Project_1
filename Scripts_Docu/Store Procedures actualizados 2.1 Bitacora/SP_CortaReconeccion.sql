USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

SELECT Propiedad.[id] FROM dbo.[Propiedad] 
INNER JOIN dbo.[Concepto_Cobro_en_Propiedad] ON Propiedad.[id] = dbo.[Concepto_Cobro_en_Propiedad].[idPropiedad]
INNER JOIN dbo.Concepto_Cobro ON dbo.[Concepto_Cobro_en_Propiedad].idConeceptoCobro = dbo.Concepto_Cobro.[id]
WHERE (dbo.Concepto_Cobro.[nombre] = 'Agua')

-- GENERAR RECIBOS DE CORTA --
CREATE PROCEDURE SPI_GenerarRecibosCorte
@fecha date
AS
BEGIN
	-- TABLAS TEMPORALES --
	DECLARE @Propiedades_Agua table (id INT IDENTITY(1,1), idPropiedad int)

	-- INSERTAR DATOS EN @Propiedad_Agua --
	-- INSERTA DATOS: relacionados a agua y con recibos comprobante de pago no pagados --
	INSERT INTO @Propiedades_Agua([idPropiedad])
	SELECT dbo.Concepto_Cobro_en_Propiedad.idPropiedad FROM dbo.[Concepto_Cobro_en_Propiedad]
	INNER JOIN dbo.Concepto_Cobro AS CC ON dbo.[Concepto_Cobro_en_Propiedad].idConeceptoCobro = CC.[id]
	WHERE CC.[nombre] = 'Agua'
	GROUP BY dbo.[Concepto_Cobro_en_Propiedad].idPropiedad

	-- ITERACION MASIVA PARA GENERAR CORTES DE AGUA --
	IF EXISTS(SELECT [id] FROM @Propiedades_Agua)
		BEGIN
			DECLARE @idPropiedad int, @id int = 1;
			WHILE @id IS NOT NULL
				BEGIN
					SELECT @idPropiedad = T.[idPropiedad]
					FROM @Propiedades_Agua AS T WHERE T.[id] = @id;
					-- Si tiene recibos de agua pendientes
					IF EXISTS (SELECT [id] FROM dbo.Recibo AS R WHERE R.[idPropiedad] = @idPropiedad AND R.[estado] = 0) -- PRUEBA cambiar estado a 1
						BEGIN
							-- Si todavia no se ha generado un recibo de reconexion de corte
							IF NOT EXISTS( SELECT [id] FROM dbo.Recibo AS R WHERE R.[idPropiedad] = @idPropiedad AND (R.idConceptoCobro = 10 AND R.[estado] = 0))
								BEGIN
									print('Cara me lote')
									EXEC dbo.SPI_ReciboReconexion @fecha, @idPropiedad
								END
							
						END
					

					SELECT @id = MIN(id) FROM @Propiedades_Agua WHERE id > @id;
				END
			DELETE FROM @Propiedades_Agua
		END
END

DROP PROCEDURE SPI_GenerarRecibosCorte

-- INSERTAR UN RECIBO RECONEXION DE CORTE --
CREATE PROCEDURE SPI_ReciboReconexion
@fecha date,
@idPropiedad int
AS
BEGIN
	-- DECLARACION DE VARIABLES --
	DECLARE @idConceptoReconexion int, @identity int;
	SELECT @idConceptoReconexion = [id] FROM dbo.[Concepto_Cobro] AS CC WHERE CC.nombre = 'Reconexion de agua' 

	-- SPI_RECIBO --
	EXEC dbo.SPI_Recibos @idConceptoReconexion, @idPropiedad, @fecha
	-- INSERT HERENCIA RECONEXION -- 
	SET @identity = @@IDENTITY
	INSERT INTO ReciboReconexion ([id], [fecha], [activo]) 
	VALUES(@identity, @fecha, 1)
	-- INSERT RECONEXION EN CORTE --
	INSERT INTO Corte([idPropiedad], [idReciboReconexion], [fecha],[activo])
	VALUES(@idPropiedad, @identity, @fecha, 1)


END

DROP PROCEDURE SPI_ReciboReconexion

-- INSERTAR UNA ORDEN DE RECONEXION --
CREATE PROCEDURE SPI_OrdenesReconexion
@fecha date,
@idPropiedad int
AS 
BEGIN
	-- DECLARACION DE VARIABLES --
	DECLARE @idConceptoReconexion int, @identity int;
	SELECT @idConceptoReconexion = [id] FROM dbo.[Concepto_Cobro] AS CC WHERE CC.nombre = 'Reconexion de agua' 

	-- SPI_RECIBO --






-- PRUEBAS --

EXEC SPI_GenerarRecibosCorte '2020-05-19'

SELECT * FROM dbo.Propiedad where dbo.Propiedad.id = 6051
SELECT * FROM dbo.Recibo where dbo.Recibo.idPropiedad = 6406
SELECT * FROM dbo.Recibo where dbo.Recibo.id = 45
SELECT * FROM dbo.Recibo where dbo.Recibo.[idConceptoCobro] = 10

DELETE FROM dbo.[Recibo] where dbo.Recibo.[id] = 1348

SELECT * FROM dbo.Corte
SELECT * FROM dbo.ReciboReconexion
