--Insert
CREATE PROCEDURE SPI_Usuario_De_Propiedad
@nombre NVARCHAR(50),
@numeroFinca int
AS 
BEGIN
	DECLARE @idPropiedad int;
	DECLARE @idUsuario int;
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca;
	SELECT @idUsuario = id from dbo.Usuario WHERE nombre = @nombre;

	INSERT INTO dbo.Usuario_de_Propiedad(idPropiedad, idUsuario)
		VALUES (@idPropiedad, @idUsuario);
END

--Delete 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Usuario_De_Propiedad]
@nombre NVARCHAR(50),
@numeroFinca int
AS
BEGIN
	DECLARE @idPropiedad int;
	DECLARE @idUsuario int;
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca;
	SELECT @idUsuario = id from dbo.Usuario WHERE nombre = @nombre;
	DELETE FROM dbo.Usuario_de_Propiedad WHERE idPropiedad = @idPropiedad AND idUsuario = @idUsuario 
END

--Select 

--Prueba
SELECT * FROM Propiedad
EXECUTE SPI_Usuario_De_Propiedad "Pepe", 0
SELECT * FROM Usuario_de_Propiedad
EXECUTE SPD_Usuario_De_Propiedad "Pepe", 0