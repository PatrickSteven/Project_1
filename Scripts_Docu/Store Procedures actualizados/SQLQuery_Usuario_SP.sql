--Insert
CREATE PROCEDURE SPI_Usuario
@nombre NVARCHAR(50),
@password NVARCHAR(50),
@tipoUsuario NVARCHAR(50)
AS 
BEGIN TRY
	DECLARE @retvalue int, @activo int = 1;
	IF NOT EXISTS (SELECT * FROM dbo.Usuario WHERE nombre = @nombre)
	BEGIN
		INSERT INTO dbo.Usuario(nombre, password, tipoUsuario, activo) VALUES (@nombre, @password, @tipoUsuario, @activo);
		SET @retvalue = SCOPE_IDENTITY();
	END
	IF EXISTS (SELECT * FROM dbo.Usuario WHERE nombre = @nombre AND dbo.Usuario.activo = 0 )
	BEGIN
		UPDATE dbo.Usuario SET dbo.Usuario.activo = 1 WHERE nombre = @nombre;
	END
	ELSE 
		BEGIN
		RAISERROR('Usuario ya registrado',10,1)
		SET @retvalue = -15  -- nombre de usuario ya existe en la base de datos
		END

	RETURN @retvalue
	
END TRY

BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE()
 
   RAISERROR( @Message, @Severity, @State) 
END CATCH

--Delete (Nuevo)	
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Usuario]
@nombre NVARCHAR(50) 
AS
BEGIN TRY
	DECLARE @retvalue int, @activo int = 1;
	IF NOT EXISTS (SELECT * FROM dbo.Usuario WHERE nombre = @nombre)
		BEGIN
			RAISERROR('Usuario no registrado',10,1)
			SET @retvalue = -16  -- nombre de usuario ya existe en la base de datos
		END
	ELSE
		BEGIN
			EXECUTE dbo.SPD_Usuario_De_Propiedad @nombre
			UPDATE dbo.Usuario SET dbo.Usuario.activo = 0 WHERE nombre = @nombre;
			SET @retvalue = 1
		END
	
	RETURN @retvalue
END TRY

BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE()
 
   RAISERROR( @Message, @Severity, @State) 
END CATCH

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
	nombre,
	password,
	tipoUsuario
	FROM dbo.Usuario
	WHERE activo = 1;
END

--Select Usuario Unico
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPS_Usuario_Detail]
@nombre nvarchar(50),
@password nvarchar(50)
AS 
BEGIN
	SELECT 
	nombre, 
	password,
	tipoUsuario
	FROM dbo.Usuario
	WHERE nombre = @nombre AND password = @password
END

--Validate User Credentials
CREATE PROCEDURE [dbo].[SPS_Usuario_Validate]
@nombre nvarchar(50),
@password nvarchar(50)
AS 
BEGIN
	DECLARE @retvalue int, @userId int
	SELECT @userId = id FROM dbo.Usuario WHERE nombre = @nombre AND password = @password
	IF (@userId is not null)
		SET @retvalue = @userId
	ELSE 
		SET @retvalue = -100 --Usuario o contraseña incorrecta

	Return @retvalue
END

--Prueba
EXECUTE SPI_Usuario "admin", "password", "Administrador"
EXECUTE SPD_Usuario "admin"
EXECUTE SPI_Usuario "Pepe", "hola", "Administrador"
EXECUTE SPD_Usuario "Pepe"
SELECT * FROM dbo.Usuario
EXECUTE SPS_Usuario
DROP PROCEDURE SPD_Usuario
DECLARE @ret int
EXECUTE SPS_Usuario_Validate "Pepe", "12"
