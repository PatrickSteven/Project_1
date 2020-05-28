--Insert
CREATE PROCEDURE SPI_Usuario_De_Propiedad
@nombre NVARCHAR(50),
@numeroFinca int
AS 
BEGIN TRY
	DECLARE @idPropiedad int, @activo int = 1,@retValue int;
	DECLARE @idUsuario int;
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca;
	SELECT @idUsuario = id from dbo.Usuario WHERE nombre = @nombre;

	IF NOT EXISTS (SELECT * FROM dbo.Usuario WHERE nombre = @nombre)
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = -16;
		END
	ELSE IF NOT EXISTS (SELECT * FROM dbo.Propiedad WHERE @numeroFinca = numeroFinca)
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = -12;
		END
	ELSE IF EXISTS( SELECT * FROM dbo.Usuario_de_Propiedad WHERE @idPropiedad = idPropiedad  AND dbo.Usuario_de_Propiedad.activo = 1 )
		BEGIN
			RAISERROR('Usuario ya registrado', 10, 1)
			SET @retValue = -15;
		END
	ELSE IF EXISTS( SELECT * FROM dbo.Usuario_de_Propiedad WHERE @idPropiedad = idPropiedad  AND dbo.Usuario_de_Propiedad.activo = 0 )
		BEGIN
			UPDATE dbo.Usuario_De_Propiedad SET activo = 1 WHERE @idPropiedad = idPropiedad;
			SET @retValue = 1;
		END
	ELSE
		BEGIN
			INSERT INTO dbo.Usuario_de_Propiedad(idPropiedad, idUsuario, activo) VALUES (@idPropiedad, @idUsuario, @activo);
			SET @retValue = SCOPE_IDENTITY();
		END
	RETURN  @retValue;
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
CREATE PROCEDURE [dbo].[SPD_Usuario_De_Propiedad]
@nombre NVARCHAR(50),
@numeroFinca int
AS
BEGIN TRY
	DECLARE @retvalue int;
	IF NOT EXISTS (SELECT * FROM dbo.Usuario WHERE nombre = @nombre)
		BEGIN
			RAISERROR('Usuario no registrado',10,1)
			SET @retvalue = -16  -- nombre de usuario ya existe en la base de datos
		END
	ELSE IF NOT EXISTS (SELECT * FROM dbo.Propiedad WHERE @numeroFinca = numeroFinca)
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = -12;
		END
	ELSE
		BEGIN
			DECLARE @idPropiedad int;
			DECLARE @idUsuario int;
			SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca;
			SELECT @idUsuario = id from dbo.Usuario WHERE nombre = @nombre;
			UPDATE dbo.Usuario_De_Propiedad SET activo = 0 WHERE  @idPropiedad = idPropiedad;
			SET @retvalue = 1;
		END
	RETURN @retvalue;
END TRY

BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
END CATCH



--Delete (Viejo)
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

--Delete with optional parameters
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Usuario_De_Propiedad]
@nombre NVARCHAR(50) = null,
@numeroFinca int = null
AS
BEGIN
	DECLARE @idPropiedad int, @idUsuario int;
	DECLARE @retval int

	IF @nombre is null and @numeroFinca is null
		BEGIN
		SET @retval = -1
		END

	ELSE IF @nombre is null and @numeroFinca is not null
		BEGIN
		SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca;
		DELETE FROM dbo.Usuario_de_Propiedad WHERE idPropiedad = @idPropiedad
		END

	ElSE IF @numeroFinca is null and @nombre is not null
		BEGIN
		SELECT @idUsuario = id from dbo.Usuario WHERE nombre = @nombre;
		DELETE FROM dbo.Usuario_de_Propiedad WHERE idUsuario = @idUsuario
		END
	ELSE
		BEGIN
		SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca;
		SELECT @idUsuario = id from dbo.Usuario WHERE nombre = @nombre;
		DELETE FROM dbo.Usuario_de_Propiedad WHERE idPropiedad = @idPropiedad AND idUsuario = @idUsuario
		END	 
END
--Select Propiedades de un usuario
CREATE PROCEDURE [dbo].[SPS_Usuario_De_Propiedad_Detail_Propiedad]
@numeroFinca int
AS
BEGIN
	DECLARE @idPropiedad int
	SELECT @idPropiedad = id from dbo.Propiedad WHERE dbo.Propiedad.numeroFinca = @numeroFinca
	
	SELECT nombre, tipoUsuario from dbo.Usuario_de_Propiedad
	JOIN dbo.Usuario ON dbo.Usuario_de_Propiedad.idUsuario = dbo.Usuario.id
	WHERE dbo.Usuario_de_Propiedad.idPropiedad = @idPropiedad AND dbo.Usuario_de_Propiedad.activo = 1;
END

--Select Usuarios de una propiedad
CREATE PROCEDURE [dbo].[SPS_Usuario_De_Propiedad_Detail_Usuario]
@nombre NVARCHAR(50)
AS
BEGIN
	DECLARE @idUsuario int
	SELECT @idUsuario = id from dbo.Usuario WHERE dbo.Usuario.nombre = @nombre
	SELECT numeroFinca, valor, direccion FROM dbo.Usuario_de_Propiedad
	JOIN dbo.Propiedad ON dbo.Usuario_de_Propiedad.idPropiedad = dbo.Propiedad.id
	WHERE dbo.Usuario_de_Propiedad.idUsuario = @idUsuario AND dbo.Usuario_de_Propiedad.activo = 1;
END

--Prueba
DROP PROCEDURE SPD_Usuario_De_Propiedad
SELECT * FROM Propiedad
EXECUTE SPI_Usuario_De_Propiedad Jquiros, 1394522
SELECT * FROM Usuario
select * from Usuario_de_Propiedad
EXECUTE [SPD_Usuario_De_Propiedad] Jquiros, 1394522
EXECUTE SPS_Usuario_De_Propiedad_Detail_Usuario "admin"
