--Insert
CREATE PROCEDURE SPI_Usuario
@nombre NVARCHAR(50),
@password NVARCHAR(50),
@tipoUsuario NVARCHAR(50)
AS 
BEGIN TRY
	IF NOT EXISTS (SELECT * FROM dbo.Usuario WHERE nombre = @nombre)
	BEGIN
		INSERT INTO dbo.Usuario(nombre, password, tipoUsuario)
			VALUES (@nombre, @password, @tipoUsuario);
	END
	
	ELSE 
		RAISERROR('Usuario ya registrado',10,1)
	
END TRY

BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE()
 
   RAISERROR( @Message, @Severity, @State) 
END CATCH

--Delete	
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Usuario]
@nombre NVARCHAR(50) 
AS
BEGIN
	EXECUTE dbo.SPD_Usuario_De_Propiedad @nombre
	DELETE FROM dbo.Usuario WHERE nombre = @nombre
END

--Update
CREATE PROCEDURE [dbo].[SPU_Usuario]
@nombre NVARCHAR(50),
@password NVARCHAR(50)
AS
BEGIN
UPDATE dbo.Usuario
	SET password = @password
	WHERE nombre = @nombre
END

--Select
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPS_Usuario]
AS 
BEGIN
	SELECT 
	nombre 'Nombre',
	password 'Password',
	tipoUsuario 'Tipo'
	FROM dbo.Usuario
END

--Prueba
EXECUTE SPI_Usuario "Pepe", "123", "Usuario"
EXECUTE SPD_Usuario "Pepe"
EXECUTE SPU_Usuario "Pepe", "hola"
SELECT * FROM dbo.Usuario
EXECUTE SPS_Usuario
DROP PROCEDURE SPD_Usuario