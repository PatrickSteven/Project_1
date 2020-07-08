--Insert
CREATE PROCEDURE SPI_Usuario_De_Propiedad
@nombre NVARCHAR(50),
@numeroFinca int
AS 
BEGIN TRY
	DECLARE @idPropiedad int, @activo int = 1,@retValue int, @idUsuario int, @id int;
	SELECT @idPropiedad = [id] from dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
	SELECT @idUsuario = [id] from dbo.[Usuario] AS U WHERE U.[nombre] = @nombre;
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);

	IF NOT EXISTS (SELECT * FROM dbo.[Usuario] AS U WHERE U.[nombre] = @nombre)
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = -16;
		END
	ELSE IF NOT EXISTS (SELECT * FROM dbo.[Propiedad] AS P WHERE @numeroFinca = P.[numeroFinca])
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = -12;
		END
	ELSE IF EXISTS( SELECT * FROM dbo.[Usuario_de_Propiedad] AS UP WHERE @idPropiedad = UP.[idPropiedad]  AND UP.[activo] = 1 )
		BEGIN
			RAISERROR('Usuario ya registrado', 10, 1)
			SET @retValue = -15;
		END
	-- UPDATE --
	ELSE IF EXISTS( SELECT * FROM dbo.[Usuario_de_Propiedad] AS UP WHERE @idPropiedad = UP.[idPropiedad]  AND UP.[activo] = 0 )
		BEGIN
			SET @id = (SELECT [id] FROM dbo.[Usuario_de_Propiedad] AS UP WHERE @idPropiedad = UP.[idPropiedad]);
			-- Cargar json antes --
			SET @jsonAntes = (
				SELECT UP.[idPropiedad], UP.[idUsuario], UP.[activo], UP.[fechaInicio]
				FROM [Usuario_de_Propiedad] AS UP WHERE UP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- Update fila --

			UPDATE dbo.[Usuario_De_Propiedad] SET [activo] = 1 WHERE @idPropiedad = [idPropiedad];
			SET @retValue = 1;

			-- Cargar json despues --
			SET @jsonDespues = (
				SELECT UP.[idPropiedad], UP.[idUsuario], UP.[activo], UP.[fechaInicio]
				FROM [Usuario_de_Propiedad] AS UP WHERE UP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			EXEC dbo.[SPI_Bitacora] 5, @id, 1, @jsonDespues, @jsonAntes

		END
	-- INSERT --
	ELSE
		BEGIN
			-- insertar los datos --
			INSERT INTO dbo.[Usuario_de_Propiedad] ( [idPropiedad] , [idUsuario] , [activo] , [fechaInicio] ) 
			VALUES (@idPropiedad, @idUsuario, @activo, GETDATE());
			SET @retValue = SCOPE_IDENTITY();
			-- Crear json con los datos despues de insertado --
			SET @jsonDespues = (
				SELECT UP.[idPropiedad], UP.[idUsuario], UP.[activo], UP.[fechaInicio]
				FROM [Usuario_de_Propiedad] AS UP WHERE UP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- Guardar los datos en la bitacora --
			EXEC dbo.[SPI_Bitacora] 5, @retValue, 1, @jsonDespues, null
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

DROP PROCEDURE SPI_Usuario_De_Propiedad

--Insert SP para documentos XML --
CREATE PROCEDURE SPI_Usuario_De_Propiedad_XML
@nombre NVARCHAR(50),
@numeroFinca int,
@fecha date
AS 
BEGIN TRY
	DECLARE @idPropiedad int, @activo int = 1,@retValue int, @idUsuario int, @id int;
	SELECT @idPropiedad = [id] from dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
	SELECT @idUsuario = [id] from dbo.[Usuario] AS U WHERE U.[nombre] = @nombre;
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);

	IF NOT EXISTS (SELECT * FROM dbo.[Usuario] AS U WHERE U.[nombre] = @nombre)
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = -16;
		END
	ELSE IF NOT EXISTS (SELECT * FROM dbo.[Propiedad] AS P WHERE @numeroFinca = P.[numeroFinca])
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = -12;
		END
	ELSE IF EXISTS( SELECT * FROM dbo.[Usuario_de_Propiedad] AS UP WHERE @idPropiedad = UP.[idPropiedad]  AND UP.[activo] = 1 )
		BEGIN
			RAISERROR('Usuario ya registrado', 10, 1)
			SET @retValue = -15;
		END
	ELSE IF EXISTS( SELECT * FROM dbo.[Usuario_de_Propiedad] AS UP WHERE @idPropiedad = UP.[idPropiedad]  AND UP.[activo] = 0 )
		BEGIN
			SET @id = (SELECT [id] FROM dbo.[Usuario_de_Propiedad] AS UP WHERE @idPropiedad = UP.[idPropiedad]);
			-- Cargar json antes --
			SET @jsonAntes = (
				SELECT UP.[idPropiedad], UP.[idUsuario], UP.[activo], UP.[fechaInicio]
				FROM [Usuario_de_Propiedad] AS UP WHERE UP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- Update fila --
			UPDATE dbo.[Usuario_De_Propiedad] SET [activo] = 1 WHERE @idPropiedad = [idPropiedad];
			SET @retValue = 1;
			-- Cargar json despues --
			SET @jsonDespues = (
				SELECT UP.[idPropiedad], UP.[idUsuario], UP.[activo], UP.[fechaInicio]
				FROM [Usuario_de_Propiedad] AS UP WHERE UP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			EXEC dbo.[SPI_Bitacora] 5, @id, 1, @jsonDespues, @jsonAntes
		END
	ELSE
		BEGIN
			-- insertar los datos --
			INSERT INTO dbo.[Usuario_de_Propiedad] ( [idPropiedad] , [idUsuario] , [activo] , [fechaInicio] ) 
			VALUES (@idPropiedad, @idUsuario, @activo, @fecha);
			SET @retValue = SCOPE_IDENTITY();
			-- Crear json con los datos despues de insertado --
			SET @jsonDespues = (
				SELECT UP.[idPropiedad], UP.[idUsuario], UP.[activo], UP.[fechaInicio]
				FROM [Usuario_de_Propiedad] AS UP WHERE UP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- Guardar los datos en la bitacora --
			EXEC dbo.[SPI_Bitacora] 5, @retValue, 1, @jsonDespues, null
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

DROP PROCEDURE SPI_Usuario_De_Propiedad_XML

--Delete (Nuevo)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Usuario_De_Propiedad]
@nombre NVARCHAR(50) = null,
@numeroFinca int = null
AS
BEGIN TRY
	DECLARE @idPropiedad int, @idUsuario int, @retvalue int = 1, @id int;
	SELECT @idUsuario = id from dbo.Usuario AS U WHERE U.nombre = @nombre;
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca;
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	
	
	IF NOT EXISTS (SELECT * FROM dbo.Usuario AS U WHERE U.nombre = @nombre)
		BEGIN
			IF @numeroFinca = null
				BEGIN
					RAISERROR('Usuario no registrado',10,1)
					SET @retvalue = -16  -- nombre de usuario ya existe en la base de datos
				END
			ELSE
				BEGIN
					SELECT @id = [id] FROM dbo.[Usuario_de_Propiedad] AS UP WHERE @idPropiedad = UP.[idPropiedad];
					-- Guardar datos antes del delete --
					SET @jsonAntes = (
						SELECT UP.[idPropiedad], UP.[idUsuario], UP.[activo], UP.[fechaInicio]
						FROM [Usuario_de_Propiedad] AS UP WHERE UP.[idPropiedad] = @idPropiedad
						FOR JSON AUTO
					)
					-- DELETE --
					PRINT('VALE')
					UPDATE dbo.Usuario_De_Propiedad SET activo = 0 WHERE  @idPropiedad = idPropiedad;
					SET @retvalue = 1;					
					PRINT('VALE52')
					-- Guardar los datos en la bitacora --
					EXEC dbo.[SPI_Bitacora] 5, @idPropiedad, 0, null, @jsonAntes
					PRINT('VALE3')
				END
		END
	ELSE IF EXISTS(SELECT * FROM dbo.Usuario WHERE nombre = @nombre AND @numeroFinca = null)
		BEGIN
			SET @id = (SELECT [id] FROM dbo.[Usuario_de_Propiedad] AS UP WHERE UP.[idUsuario] = @idUsuario);
			-- Guardar datos antes del delete --
			SET @jsonAntes = (
				SELECT UP.[idPropiedad], UP.[idUsuario], UP.[activo], UP.[fechaInicio]
				FROM [Usuario_de_Propiedad] AS UP WHERE UP.[idUsuario] = @idUsuario
				FOR JSON AUTO
			)
			-- DELETE --
			UPDATE dbo.[Usuario_De_Propiedad] SET activo = 0 WHERE  dbo.Usuario_De_Propiedad.[idUsuario] = @idUsuario;
			SET @retvalue = 1;
			-- Guardar los datos en la bitacora --
			EXEC dbo.[SPI_Bitacora] 5, @id, 0, null, @jsonAntes
		END
	ELSE IF NOT EXISTS (SELECT * FROM dbo.Propiedad WHERE @numeroFinca = numeroFinca)
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = 1;
		END
	ELSE
		BEGIN
			SET @id = (SELECT [id] FROM dbo.[Usuario_de_Propiedad] AS UP WHERE @idPropiedad = UP.[idPropiedad]);
			-- Guardar datos antes del delete --
			SET @jsonAntes = (
				SELECT UP.[idPropiedad], UP.[idUsuario], UP.[activo], UP.[fechaInicio]
				FROM [Usuario_de_Propiedad] AS UP WHERE UP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- DELETE --
			UPDATE dbo.Usuario_De_Propiedad SET activo = 0 WHERE  @idPropiedad = idPropiedad;
			SET @retvalue = 1;					
			-- Guardar los datos en la bitacora --
			EXEC dbo.[SPI_Bitacora] 5, @id, 0, null, @jsonAntes
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

DROP PROCEDURE [SPD_Usuario_De_Propiedad]

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
EXECUTE SPI_Usuario_De_Propiedad Pee, 455
SELECT * FROM Usuario
select * from Usuario_de_Propiedad
EXECUTE [SPD_Usuario_De_Propiedad] null, 455
EXECUTE SPS_Usuario_De_Propiedad_Detail_Usuario LDiaz
