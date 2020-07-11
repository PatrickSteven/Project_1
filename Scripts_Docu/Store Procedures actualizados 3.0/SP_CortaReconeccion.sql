USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

-- GENERAR RECIBOS DE CORTA --
CREATE PROCEDURE SPI_GenerarRecibosCorte
@fecha date
AS
BEGIN TRY
	-- TABLAS TEMPORALES --
	DECLARE @Propiedades_Agua table (id INT IDENTITY(1,1), idPropiedad int)

	-- INSERTAR DATOS EN @Propiedad_Agua --
	-- INSERTA DATOS: relacionados a agua y con recibos comprobante de pago no pagados --
	BEGIN TRANSACTION
		INSERT INTO @Propiedades_Agua([idPropiedad])
		SELECT dbo.Concepto_Cobro_en_Propiedad.idPropiedad FROM dbo.[Concepto_Cobro_en_Propiedad]
		INNER JOIN dbo.Concepto_Cobro AS CC ON dbo.[Concepto_Cobro_en_Propiedad].idConeceptoCobro = CC.[id]
		WHERE CC.[nombre] = 'Agua'
		GROUP BY dbo.[Concepto_Cobro_en_Propiedad].idPropiedad
	COMMIT TRANSACTION

	-- GENERAR CORTES DE AGUA -- (ITERACION MASIVA)
	BEGIN TRANSACTION
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
										EXEC dbo.SPI_ReciboReconexion @fecha, @idPropiedad
									END							
							END
						SELECT @id = MIN(id) FROM @Propiedades_Agua WHERE id > @id;
					END
				-- Borrar datos de tabla --
				DELETE FROM @Propiedades_Agua
			END
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
	ROLLBACK TRANSACTION;
END CATCH

DROP PROCEDURE SPI_GenerarRecibosCorte

-- INSERTAR UN RECIBO RECONEXION DE CORTE --
CREATE PROCEDURE SPI_ReciboReconexion
@fecha date,
@idPropiedad int
AS
BEGIN TRY
	-- DECLARACION DE VARIABLES --
	DECLARE @idConceptoReconexion int, @identity int, @retValue1 int;
	SELECT @idConceptoReconexion = [id] FROM dbo.[Concepto_Cobro] AS CC WHERE CC.nombre = 'Reconexion de agua' 

	IF NOT EXISTS (SELECT  [id] FROM dbo.[Propiedad] AS P WHERE P.[id] = @idPropiedad)
		BEGIN
			RAISERROR('Propiedad no registrado en la base de datos', 10, 1)
			SET @retValue1 = -14;
		END
	ELSE
		BEGIN
		BEGIN TRANSACTION
			-- SPI_RECIBO --
			EXEC dbo.SPI_Recibos @idConceptoReconexion, @idPropiedad, @fecha
			-- INSERT HERENCIA RECONEXION -- 
			SET @identity = @@IDENTITY
			INSERT INTO ReciboReconexion ([id], [fecha], [activo]) 
			VALUES(@identity, @fecha, 1)
			-- INSERT RECONEXION EN CORTE --
			INSERT INTO Corte([idPropiedad], [idReciboReconexion], [fecha],[activo])
			VALUES(@idPropiedad, @identity, @fecha, 1)
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

DROP PROCEDURE SPI_ReciboReconexion



-- PRUEBAS --

EXEC SPI_GenerarRecibosCorte '2020-05-19'

SELECT * FROM dbo.Propiedad where dbo.Propiedad.id = 6051
SELECT * FROM dbo.Recibo where dbo.Recibo.idPropiedad = 6406
SELECT * FROM dbo.Recibo where dbo.Recibo.id = 23531
SELECT * FROM dbo.Recibo where dbo.Recibo.[idConceptoCobro] = 10

DELETE FROM dbo.[Recibo] where dbo.Recibo.[id] = 1348

SELECT * FROM dbo.Corte
SELECT * FROM dbo.ReciboReconexion

SPI_ReciboReconexion '2020-05-19', 11931
