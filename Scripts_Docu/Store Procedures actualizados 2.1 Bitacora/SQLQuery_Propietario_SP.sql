USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO
--Insert (Actualizado 2.0) --
CREATE PROCEDURE [dbo].[SPI_Propietario]
@nombre NVARCHAR(50),
@valorDocId bigInt,
@idDocId int
AS 
BEGIN
	BEGIN TRY
		DECLARE @retValue int, @estado int = 1, @docId int;
		DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
		DECLARE @id int;
		SELECT @docId = [id] FROM dbo.[Tipo_DocId] AS T WHERE @idDocId = T.[codigoDoc]
		IF NOT EXISTS (SELECT * FROM dbo.[Propietario] AS P WHERE P.[valorDocId] = @valorDocId)
			BEGIN
				-- Inserta datos si este propietario no esta registrado --
				INSERT INTO Propietario([nombre], [valorDocId], [idDocId],  [activo], [fechaLeido]) 
				VALUES (@nombre,@valorDocId,@docId, @estado, GETDATE())
				SET @retValue = SCOPE_IDENTITY();
				-- Insertar datos en bitacora --
				-- AQUI --
				SET @jsonDespues = (
					SELECT P.[nombre], P.[valorDocId], P.[idDocId],  P.[activo], P.[fechaLeido]
					FROM [Propietario] AS P WHERE P.[valorDocId] = @valorDocId
					FOR JSON AUTO
				)
				EXEC dbo.[SPI_Bitacora] 2, @retValue, 1, @jsonDespues, null

			END

		ELSE IF EXISTS(SELECT * FROM dbo.[Propietario] AS P WHERE P.valorDocId = @valorDocId AND P.activo = 0)
			BEGIN
				SET @id = (SELECT [id] FROM dbo.[Propietario] AS P WHERE P.valorDocId = @valorDocId);
				-- Guardar datos antes de update --
				SET @jsonAntes = (
					SELECT P.[nombre], P.[valorDocId], P.[idDocId],  P.[activo], P.[fechaLeido]
					FROM [Propietario] AS P WHERE P.[valorDocId] = @valorDocId
					FOR JSON AUTO
				)

				UPDATE dbo.Propietario SET dbo.Propietario.activo = 1 WHERE valorDocId = @valorDocId;
				EXECUTE [dbo].[SPU_Propietario] @nombre, @valorDocId 
				SET @retvalue = 1;

				-- Guardar datos antes luego de  update --
			   SET @jsonDespues = (
					SELECT P.[nombre], P.[valorDocId], P.[idDocId],  P.[activo], P.[fechaLeido]
					FROM [Propietario] AS P WHERE P.[valorDocId] = @valorDocId
					FOR JSON AUTO
				)
				-- Insertar dato en bitacora --
				EXEC dbo.[SPI_Bitacora] 2, @id, 1, @jsonDespues, @jsonAntes
			END
		ELSE
			BEGIN
				RAISERROR('Propietario ya registrado en la base de datos', 10, 1)
				SET @retValue = -11;
			END
	
		RETURN @retValue

	END TRY
	BEGIN CATCH
		DECLARE 
			@Message varchar(MAX) = ERROR_MESSAGE(),
			@Severity int = ERROR_SEVERITY(),
			@State smallint = ERROR_STATE()
 
	   RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE [SPI_Propietario]

-- Insert XML
CREATE PROCEDURE [dbo].[SPI_Propietario_XML]
@nombre NVARCHAR(50),
@valorDocId bigInt,
@idDocId int,
@fechaLeido date
AS 
BEGIN
	BEGIN TRY
		DECLARE @retValue int, @estado int = 1, @docId int, @id int;
		DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
		SELECT @docId = [id] FROM dbo.[Tipo_DocId] AS T WHERE @idDocId = T.[codigoDoc]
		IF NOT EXISTS (SELECT * FROM dbo.[Propietario] AS P WHERE P.[valorDocId] = @valorDocId)
			BEGIN
				-- Inserta datos si este propietario no esta registrado --
				INSERT INTO Propietario([nombre], [valorDocId], [idDocId],  [activo], [fechaLeido]) 
				VALUES (@nombre,@valorDocId,@docId, @estado, @fechaLeido)
				SET @retValue = SCOPE_IDENTITY();
				-- Insertar datos en bitacora --
				-- AQUI --
				SET @jsonDespues = (
					SELECT P.[nombre], P.[valorDocId], P.[idDocId],  P.[activo], P.[fechaLeido]
					FROM [Propietario] AS P WHERE P.[valorDocId] = @valorDocId
					FOR JSON AUTO
				)
				EXEC dbo.[SPI_Bitacora] 2, @retValue, 1, @jsonDespues, null
			END

		ELSE IF EXISTS(SELECT * FROM dbo.[Propietario] AS P WHERE P.valorDocId = @valorDocId AND P.activo = 0)
			BEGIN
				SET @id = (SELECT [id] FROM dbo.[Propietario] AS P WHERE P.valorDocId = @valorDocId);
				-- Guardar datos antes de update --
				SET @jsonAntes = (
					SELECT P.[nombre], P.[valorDocId], P.[idDocId],  P.[activo], P.[fechaLeido]
					FROM [Propietario] AS P WHERE P.[valorDocId] = @valorDocId
					FOR JSON AUTO
				)

				UPDATE dbo.Propietario SET dbo.Propietario.activo = 1 WHERE valorDocId = @valorDocId;
				EXECUTE [dbo].[SPU_Propietario] @nombre, @valorDocId 
				SET @retvalue = 1;

				-- Guardar datos antes luego de  update --
			   SET @jsonDespues = (
					SELECT P.[nombre], P.[valorDocId], P.[idDocId],  P.[activo], P.[fechaLeido]
					FROM [Propietario] AS P WHERE P.[valorDocId] = @valorDocId
					FOR JSON AUTO
				)
				-- Insertar dato en bitacora --
				EXEC dbo.[SPI_Bitacora] 2, @id, 1, @jsonDespues, @jsonAntes
			END
		ELSE
			BEGIN
				RAISERROR('Propietario ya registrado en la base de datos', 10, 1)
				SET @retValue = -11;
			END
	
		RETURN @retValue

	END TRY
	BEGIN CATCH
		DECLARE 
			@Message varchar(MAX) = ERROR_MESSAGE(),
			@Severity int = ERROR_SEVERITY(),
			@State smallint = ERROR_STATE()
 
	   RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE [SPI_Propietario_XML]

--Delete (Actualizado Nuevo)
CREATE PROCEDURE [dbo].[SPD_Propietario]
@valorDocId bigInt 
AS
BEGIN
	DECLARE @retValue int, @idPropietario int, @id int;
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	
	IF EXISTS (SELECT * FROM dbo.[Propietario] AS P WHERE P.valorDocId = @valorDocId)
		BEGIN
			SELECT @idPropietario = id from dbo.[Propietario] AS P WHERE P.[valorDocId] = @valorDocId
			EXECUTE dbo.[SPD_Propiedad_Del_Propietario] null, @valorDocId
			EXECUTE dbo.[SPD_Propietario_Juridico] null, @idPropietario
			SET @retValue =  (SELECT id FROM dbo.Propietario AS P WHERE P.valorDocId = @valorDocId);
			
			-- Guardar datos antes de update --
			SET @jsonAntes = (
				SELECT P.[nombre], P.[valorDocId], P.[idDocId],  P.[activo], P.[fechaLeido]
				FROM [Propietario] AS P WHERE P.[valorDocId] = @valorDocId
				FOR JSON AUTO
			)
			-- DELETE --
			UPDATE dbo.Propietario SET activo = 0  WHERE valorDocId = @valorDocId 
			-- Insertar dato en bitacora --
			EXEC dbo.[SPI_Bitacora] 2, @idPropietario, 0, null, @jsonAntes
			
		END
			
	ELSE 
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = -12;
		END
	RETURN  @retValue;
END

DROP PROCEDURE [dbo].[SPD_Propietario]


--Delete (Viejo)
CREATE PROCEDURE [dbo].[SPD_Propietario]
@valorDocId BIGINT 
AS
BEGIN
	DECLARE @retValue int;
	DECLARE @idPropietario int;
	IF EXISTS (SELECT * FROM dbo.Propietario WHERE valorDocId = @valorDocId)
		BEGIN
			SELECT @idPropietario = id from dbo.Propietario WHERE valorDocId = @valorDocId
			EXECUTE dbo.SPD_Propiedad_Del_Propietario null, @valorDocId
			EXECUTE dbo.SPD_Propietario_Juridico null, @idPropietario
			SET @retValue =  (SELECT id FROM dbo.Propietario WHERE valorDocId = @valorDocId);
			DELETE FROM Propietario WHERE valorDocId = @valorDocId 
		END
			
	ELSE 
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = -12;
		END
	RETURN  @retValue;
END
 
--Update (Actualizado 1.0)
CREATE PROCEDURE [dbo].[SPU_Propietario]
@nombre NVARCHAR(50),
@valorDocId bigInt
AS 
BEGIN
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500), @id int;
	BEGIN TRY
		DECLARE @retValue int;
		IF EXISTS (SELECT * FROM dbo.Propietario AS P WHERE P.[valorDocId] = @valorDocId)
			BEGIN 
				SET @id = (SELECT [id] FROM dbo.[Propietario] AS P WHERE P.valorDocId = @valorDocId);
				-- Guardar datos antes de update --
				SET @jsonAntes = (
					SELECT P.[nombre], P.[valorDocId], P.[idDocId],  P.[activo], P.[fechaLeido]
					FROM [Propietario] AS P WHERE P.[valorDocId] = @valorDocId
					FOR JSON AUTO
				)

				UPDATE dbo.[Propietario] SET [nombre] = @nombre WHERE [valorDocId] = @valorDocId
				SET @retValue =  (SELECT id FROM dbo.Propietario AS P WHERE P.[valorDocId] = @valorDocId);
				
				-- Guardar datos antes luego de  update --
				SET @jsonDespues = (
					SELECT P.[nombre], P.[valorDocId], P.[idDocId],  P.[activo], P.[fechaLeido]
					FROM [Propietario] AS P WHERE P.[valorDocId] = @valorDocId
					FOR JSON AUTO
				)

				-- Insertar dato en bitacora --
				EXEC dbo.[SPI_Bitacora] 2, @id, 1, @jsonDespues, @jsonAntes

			END
		ELSE
			BEGIN
				RAISERROR('Propietario no registrado en la base de datos', 10, 1)
				SET @retValue = -12
			END
		RETURN @retValue

	END TRY
	BEGIN CATCH
		DECLARE 
			@Message varchar(MAX) = ERROR_MESSAGE(),
			@Severity int = ERROR_SEVERITY(),
			@State smallint = ERROR_STATE()
 
	   RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE [dbo].[SPU_Propietario]


--Select (Actualizado)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPS_Propietario]
AS 
BEGIN
	SELECT P.[nombre], P.[valorDocId], dbo.[Tipo_DocId].nombre FROM dbo.[Propietario] AS P
	JOIN dbo.[Tipo_DocId] ON dbo.Tipo_DocId.[id] = P.[idDocId]
	WHERE P.activo = 1;
END

DROP PROCEDURE [SPS_Propietario]

--Select Propietario (Actualizado 1.0)
CREATE PROCEDURE [dbo].[SPS_Propietario_Detail]
@valorDocId bigInt
AS
BEGIN
	SELECT P.[idDocId], P.[nombre], P.[ValorDocId], Tipo_DocId.[nombre] FROM dbo.[Propietario] AS P
	JOIN dbo.[Tipo_DocId] ON P.[idDocId] = dbo.Tipo_DocId.[id]
	WHERE P.valorDocId = @valorDocId
END

DROP PROCEDURE [SPS_Propietario_Detail]

--Pruebas-- (Actualizado 1.0)
EXECUTE SPI_Propietario 'C', 20000000, 1
Select * from dbo.Propietario
EXECUTE SPU_Propietario "Ramón", 20000000001
EXECUTE [SPS_Propietario_Detail] 20000000001
EXECUTE SPD_Propietario 20000000
EXECUTE [SPI_Propietario_XML] 'C', 20000000001, 1, '2020-01-29'
SELECT * FROM dbo.Tipo_DocId



