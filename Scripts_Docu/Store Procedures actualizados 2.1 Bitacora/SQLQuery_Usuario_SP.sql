--Insert
CREATE PROCEDURE SPI_Usuario
@nombre NVARCHAR(50),
@password NVARCHAR(50),
@tipoUsuario NVARCHAR(50)
AS 
BEGIN TRY
	DECLARE @retvalue int, @activo int = 1;
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	DECLARE @id int; 
	IF NOT EXISTS (SELECT * FROM dbo.[Usuario] AS U WHERE U.nombre = @nombre)
	-- INSERT USUARIO --
	BEGIN
		INSERT INTO dbo.[Usuario] ([nombre], [password], [tipoUsuario], [activo], [fechaInicio]) 
		VALUES (@nombre, @password, @tipoUsuario, @activo, GETDATE());
		SET @retvalue = SCOPE_IDENTITY();

		-- Creacion de json despues --
		SET @jsonDespues = (
			SELECT U.[nombre], U.[password], U.[tipoUsuario],  U.[activo], U.[fechaInicio]
			FROM [Usuario] AS U WHERE U.nombre = @nombre
			FOR JSON AUTO
		)
		-- Insertar dato en bitacora --
		EXEC dbo.[SPI_Bitacora] 2, @retValue, 1, @jsonDespues, null

	END
	-- UPDATE ESTADO USUARIO --
	ELSE IF EXISTS (SELECT * FROM dbo.[Usuario] AS U WHERE U.[nombre] = @nombre AND U.[activo] = 0 )
		BEGIN
			SET @id = (SELECT [id] FROM dbo.[Usuario] AS U WHERE U.[nombre] = @nombre);
			-- Guardar datos antes de update --
			SET @jsonAntes = (
				SELECT U.[nombre], U.[password], U.[tipoUsuario],  U.[activo], U.[fechaInicio]
				FROM [Usuario] AS U WHERE U.nombre = @nombre
				FOR JSON AUTO
			)
			BEGIN
				UPDATE dbo.[Usuario] SET dbo.Usuario.[activo] = 1 WHERE [nombre] = @nombre;
				EXECUTE [dbo].[SPU_Usuario] @nombre, @password
				SET @retvalue = 1;
			END
			-- Creacion de json despues --
			SET @jsonDespues = (
				SELECT U.[nombre], U.[password], U.[tipoUsuario],  U.[activo], U.[fechaInicio]
				FROM [Usuario] AS U WHERE U.nombre = @nombre
				FOR JSON AUTO
			)
			-- Insertar dato en bitacora --
			EXEC dbo.[SPI_Bitacora] 3, @id, 1, @jsonDespues, @jsonAntes
		END
	-- ERROR --
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

DROP PROCEDURE SPI_Usuario

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
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	DECLARE @id int; 
	-- ERROR --
	IF NOT EXISTS (SELECT * FROM dbo.Usuario WHERE nombre = @nombre)
		BEGIN
			RAISERROR('Usuario no registrado',10,1)
			SET @retvalue = -16  -- nombre de usuario ya existe en la base de datos
		END
	-- DELETE (update) --
	ELSE
		BEGIN
			SET @id = (SELECT [id] FROM dbo.Usuario WHERE nombre = @nombre)
			-- Guardar datos antes de update --
			SET @jsonAntes = (
				SELECT U.[nombre], U.[password], U.[tipoUsuario],  U.[activo], U.[fechaInicio]
				FROM [Usuario] AS U WHERE U.nombre = @nombre
				FOR JSON AUTO
			)
			-- delete --
			EXECUTE [dbo.SPD_Usuario_De_Propiedad] @nombre 
			UPDATE dbo.[Usuario] SET dbo.Usuario.[activo] = 0 WHERE [nombre] = @nombre;
			SET @retvalue = 1
			-- Insertar datos en bitacora --
			EXEC dbo.[SPI_Bitacora] 3, @id, 0, null, @jsonAntes
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

DROP PROCEDURE [SPD_Usuario]

--Update
CREATE PROCEDURE [dbo].[SPU_Usuario]
@nombre NVARCHAR(50),
@password NVARCHAR(50)
AS
BEGIN TRY
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	DECLARE @acitvo int = (SELECT [activo] FROM dbo.Usuario WHERE nombre = @nombre)
	DECLARE @id int = (SELECT [id] FROM Usuario WHERE [nombre] = @nombre);
	-- Guardar datos antes de update --
	SET @jsonAntes = (
		SELECT U.[nombre], U.[password], U.[tipoUsuario],  U.[activo], U.[fechaInicio]
		FROM [Usuario] AS U WHERE U.nombre = @nombre
		FOR JSON AUTO
	)
	-- Update de los datos --
	UPDATE dbo.Usuario SET [password] = @password WHERE nombre = @nombre
	-- Creacion de json despues --
	SET @jsonDespues = (
		SELECT U.[nombre], U.[password], U.[tipoUsuario],  U.[activo], U.[fechaInicio]
		FROM [Usuario] AS U WHERE U.nombre = @nombre
		FOR JSON AUTO
	)
	-- Insertar dato en bitacora --
	EXEC dbo.[SPI_Bitacora] 3, @id, @acitvo, @jsonDespues, @jsonAntes
END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE()
 
   RAISERROR( @Message, @Severity, @State) 
END CATCH

DROP PROCEDURE [dbo].[SPU_Usuario]

--Select
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPS_Usuario]
AS 
BEGIN
	SELECT U.nombre, password, U.tipoUsuario FROM dbo.Usuario AS U WHERE U.activo = 1;
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
	SELECT nombre, password, tipoUsuario FROM dbo.[Usuario] AS U WHERE U.[nombre] = @nombre AND U.[password] = @password AND  U.[activo] = 1;
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
EXECUTE SPI_Usuario "Pee", "2438", "Administrador"
EXECUTE [SPD_Usuario] "Pepe"
EXECUTE SPI_Usuario "Pepe", "hola", "Administrador"
EXECUTE SPD_Usuario "Pepe"
EXECUTE SPU_Usuario "Pee", "HOLAMUNDO" 
SELECT * FROM dbo.Usuario
EXECUTE SPS_Usuario 
DROP PROCEDURE SPD_Usuario
DECLARE @ret int
EXECUTE SPS_Usuario_Validate "Pepe", "12"

