USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

-- INSERT
CREATE PROCEDURE SPI_Propiedad
@numeroFinca int,
@valor int,
@direccion VARCHAR(50)
AS 
BEGIN
	INSERT INTO Propiedad (numeroFinca, valor, direccion )
				VALUES (@numeroFinca,@valor,@direccion);
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


--- PRUEBAS DE LOS STATE PROCEDURES
SELECT * FROM Propiedad
EXEC SPI_Propiedad '000','000','Upala'

SELECT * FROM Propiedad
EXEC SPD_Propiedad '000'

SELECT * FROM Propiedad
EXEC SPU_Propiedad '000' ,'500','Upala'

SELECT * FROM Propiedad
EXEC SPS_Propiedad


