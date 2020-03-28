USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

-- INSERT
CREATE PROCEDURE SPI_Propiedad
@numeroFinca int,
@valor int,
@direccion VARCHAR(50)
AS 
BEGIN
	IF NOT EXISTS (SELECT * FROM dbo.Propiedad WHERE numeroFinca = @numeroFinca)
		INSERT INTO Propiedad (numeroFinca, valor, direccion )
				VALUES (@numeroFinca,@valor,@direccion);
	ELSE
		RAISERROR('Numero de finca ya registrado', 10, 1)
END




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- DELETE
CREATE PROCEDURE SPD_Propiedad
@numeroFinca BIGINT 
AS
BEGIN
	DECLARE @idPropiedad int
	SELECT @idPropiedad = id FROM dbo.Propiedad WHERE numeroFinca = @numeroFinca
	EXECUTE dbo.SPD_Propiedad_Del_Propietario @numeroFinca
	EXECUTE dbo.SPD_Recibos @idPropiedad
	EXECUTE dbo.SPD_Comprobante_Pago @idPropiedad
	EXECUTE dbo.SPD_Concepto_De_Cobro_En_Propiedad @numeroFinca
	EXECUTE dbo.SPD_Usuario_De_Propiedad null, @numeroFinca
	DELETE FROM Propiedad WHERE numeroFinca = @numeroFinca
END
GO

-- UPDATE
CREATE PROCEDURE SPU_Propiedad
@numeroFinca int,
@valor int,
@direccion VARCHAR(50)
AS
BEGIN
UPDATE Propiedad
	SET valor = @valor,
		direccion = @direccion
	WHERE numeroFinca = @numeroFinca
END
GO

-- SELECT 
CREATE PROCEDURE [dbo].[SPS_Propiedad]
AS 
BEGIN
	SELECT numeroFinca 'Numero de Finca'
	,valor 'Valor'
	,direccion 'Direccion'
	FROM Propiedad

END

CREATE PROCEDURE [dbo].[SPS_Propiedad_Detail]
@numeroFinca int
AS
BEGIN
	SELECT numeroFinca
	,valor
	,direccion
	FROM Propiedad 
	WHERE numeroFinca = @numeroFinca;
END


--- PRUEBAS DE LOS STATE PROCEDURES
SELECT * FROM Propiedad
EXEC SPI_Propiedad '252','000','Upala'

SELECT * FROM Propiedad
EXEC SPD_Propiedad '252'

SELECT * FROM Propiedad
EXEC SPU_Propiedad '000' ,'500','Upala'

SELECT * FROM Propiedad
EXEC SPS_Propiedad

EXEC SPS_Propiedad_Detail 456

