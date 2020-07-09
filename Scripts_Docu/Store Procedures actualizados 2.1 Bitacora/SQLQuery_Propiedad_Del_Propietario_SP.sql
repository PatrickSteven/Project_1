--Entrada: Numero de Finca de la propiedad, Valor del Id del Propietario
--Salida exitosa: Id del ultimo dato insertado en Propiedad_del_Propietario
--Salida fallida: Codigo de error [-17,-12,-16]
--Descripcion: Utiliza [NumeroDeFinca,valorDocId] y si ambos inputs existen
--entonces crea una relacion entre propietario y propiedad
CREATE PROCEDURE [dbo].[SPI_Propiedad_Del_Propietario]
@numeroFinca bigInt,
@valorDocId bigInt
AS 
BEGIN
	DECLARE @idPropietario bigInt, @idPropiedad bigInt, @retValue int, @estadoPropiedad int, @estadoPropietario int, @activo int = 1;
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	DECLARE @id int;
	
	SELECT @idPropiedad = [id] FROM dbo.[Propiedad]  AS P WHERE P.[numeroFinca] = @numeroFinca;
	SELECT @estadoPropiedad = P.[activo] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
	SELECT @idPropietario = P.[id] FROM dbo.[Propietario] AS P WHERE P.[valorDocId] = @valorDocId;
	SELECT @estadoPropietario = P.[activo] FROM dbo.[Propietario] AS P WHERE P.[valorDocId] = @valorDocId;

	IF(@idPropiedad is null OR @estadoPropiedad = 0)
		BEGIN
			RAISERROR('Propiedad no encontrada', 10, 1)
			SET	@retValue = -17;
		END									
	ELSE IF(@idPropietario is null OR @estadoPropietario = 0)
		BEGIN
			RAISERROR('Propietario no encontrado', 10, 1)
			SET @retValue = -12;
		END
	ELSE IF EXISTS(SELECT * from dbo.Propiedad_del_Propietario AS PP WHERE PP.[idPropietario] = @idPropietario AND PP.[idPropiedad] = @idPropiedad  
					AND PP.activo = 1 )
		BEGIN
			RAISERROR('El propietario ya posee esta propiedad', 10, 1)
			SET @retValue = -16;
		END
	ELSE IF EXISTS(SELECT * from dbo.Propiedad_del_Propietario WHERE idPropietario = @idPropietario AND idPropiedad = @idPropiedad 
					AND Propiedad_Del_Propietario.activo = 0)
		BEGIN
			SET @id = (SELECT [id] FROM [Propiedad_del_Propietario] AS PP WHERE PP.[idPropiedad] = @idPropiedad);
			SET @jsonAntes = (
				SELECT PP.[idPropiedad] , PP.[idPropietario] ,  PP.[activo], PP.[fechaLeido]
				FROM [Propiedad_del_Propietario] AS PP WHERE PP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- UPDATE --
			UPDATE dbo.Propiedad_del_Propietario SET activo = 1 WHERE idPropiedad = @idPropiedad AND idPropietario = @idPropietario
			SET @retvalue = 1;
			-- Creacion de json despues --
			SET @jsonDespues = (
				SELECT PP.[idPropiedad] , PP.[idPropietario] ,  PP.[activo], PP.[fechaLeido]
				FROM [Propiedad_del_Propietario] AS PP WHERE PP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- Insertar dato en bitacora --
			EXEC dbo.[SPI_Bitacora] 2, @id, 1, @jsonDespues, @jsonAntes
		END
	ELSE
		BEGIN
			INSERT INTO dbo.[Propiedad_del_Propietario] ( [idPropiedad], [idPropietario], [activo], [fechaLeido]) 
			VALUES (@idPropiedad, @idPropietario, 1, GETDATE())
			SET @retValue = SCOPE_IDENTITY();

			-- Creacion de json despues --
			SET @jsonDespues = (
				SELECT PP.[idPropiedad] , PP.[idPropietario] ,  PP.[activo], PP.[fechaLeido]
				FROM [Propiedad_del_Propietario] AS PP WHERE PP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- Insertar dato en bitacora --
			EXEC dbo.[SPI_Bitacora] 2, @retValue, 1, @jsonDespues, null
		END
	RETURN @retValue
END

DROP PROCEDURE [dbo].[SPI_Propiedad_Del_Propietario]

-- INSERT DE XML --
CREATE PROCEDURE [dbo].[SPI_Propiedad_Del_Propietario_XML]
@numeroFinca bigInt,
@valorDocId bigInt,
@fechaLeida date
AS 
BEGIN
	DECLARE @idPropietario bigInt, @idPropiedad bigInt, @retValue int, @estadoPropiedad int, @estadoPropietario int, @activo int = 1;
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	DECLARE @id int;
	
	SELECT @idPropiedad = [id] FROM dbo.[Propiedad]  AS P WHERE P.[numeroFinca] = @numeroFinca;
	SELECT @estadoPropiedad = P.[activo] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
	SELECT @idPropietario = P.[id] FROM dbo.[Propietario] AS P WHERE P.[valorDocId] = @valorDocId;
	SELECT @estadoPropietario = P.[activo] FROM dbo.[Propietario] AS P WHERE P.[valorDocId] = @valorDocId;

	IF(@idPropiedad is null OR @estadoPropiedad = 0)
		BEGIN
			RAISERROR('Propiedad no encontrada', 10, 1)
			SET	@retValue = -17;
		END									
	ELSE IF(@idPropietario is null OR @estadoPropietario = 0)
		BEGIN
			RAISERROR('Propietario no encontrado', 10, 1)
			SET @retValue = -12;
		END
	ELSE IF EXISTS(SELECT * from dbo.Propiedad_del_Propietario AS PP WHERE PP.[idPropietario] = @idPropietario AND PP.[idPropiedad] = @idPropiedad  
					AND PP.activo = 1 )
		BEGIN
			RAISERROR('El propietario ya posee esta propiedad', 10, 1)
			SET @retValue = -16;
		END
	ELSE IF EXISTS(SELECT * from dbo.Propiedad_del_Propietario WHERE idPropietario = @idPropietario AND idPropiedad = @idPropiedad 
					AND Propiedad_Del_Propietario.activo = 0)
		BEGIN
			SET @id = (SELECT [id] FROM [Propiedad_del_Propietario] AS PP WHERE PP.[idPropiedad] = @idPropiedad);
			SET @jsonAntes = (
				SELECT PP.[idPropiedad] , PP.[idPropietario] ,  PP.[activo], PP.[fechaLeido]
				FROM [Propiedad_del_Propietario] AS PP WHERE PP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- UPDATE --
			UPDATE dbo.Propiedad_del_Propietario SET activo = 1 WHERE idPropiedad = @idPropiedad AND idPropietario = @idPropietario
			SET @retvalue = 1;
			-- Creacion de json despues --
			SET @jsonDespues = (
				SELECT PP.[idPropiedad] , PP.[idPropietario] ,  PP.[activo], PP.[fechaLeido]
				FROM [Propiedad_del_Propietario] AS PP WHERE PP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- Insertar dato en bitacora --
			EXEC dbo.[SPI_Bitacora] 2, @id, 1, @jsonDespues, @jsonAntes
		END
	ELSE
		BEGIN
			-- INSERT XML --
			INSERT INTO dbo.[Propiedad_del_Propietario] ( [idPropiedad], [idPropietario], [activo], [fechaLeido]) 
			VALUES (@idPropiedad, @idPropietario, 1, @fechaLeida)
			SET @retValue = SCOPE_IDENTITY();

			-- Creacion de json despues --
			SET @jsonDespues = (
				SELECT PP.[idPropiedad] , PP.[idPropietario] ,  PP.[activo], PP.[fechaLeido]
				FROM [Propiedad_del_Propietario] AS PP WHERE PP.[idPropiedad] = @idPropiedad
				FOR JSON AUTO
			)
			-- Insertar dato en bitacora --
			EXEC dbo.[SPI_Bitacora] 2, @retValue, 1, @jsonDespues, null
		END
	RETURN @retValue
END

drop procedure [SPI_Propiedad_Del_Propietario_XML]

--Entrada: Numero de Finca (opcional), Valor doc Id (opcional)
--Salida Exitosa: Id del dato borrado
--Salida Fallida: Codigo de error[-12,-14]
--Descripcion: Borra la relacion del propietario y la propiedad
--puede aceptar entradas [0],[1],[0][1] 

--Delete (Nuevo)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Propiedad_Del_Propietario]
@numeroFinca int = null,
@valorDocId bigInt = null
AS
BEGIN
	DECLARE @idPropietario int, @idPropiedad int, @retValue int
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	DECLARE @id int;

	IF (@numeroFinca is null AND @valorDocId is not null)
		BEGIN
			SELECT  @idPropietario = id from dbo.Propietario WHERE valorDocId = @valorDocId
			IF(@idPropietario is null)
				BEGIN
					RAISERROR('Propietario no encontrado', 10, 1)
					SET @retValue = -12;
				END
			ELSE
				BEGIN
					SET @id = (SELECT [id] FROM [Propiedad_del_Propietario] AS PP WHERE idPropietario = @idPropietario );
					-- cargar atributos al json --
					SET @jsonAntes = (
						SELECT PP.[idPropiedad] , PP.[idPropietario] ,  PP.[activo], PP.[fechaLeido]
						FROM [Propiedad_del_Propietario] AS PP WHERE idPropietario = @idPropietario 
						FOR JSON AUTO
					)
					-- Linea de delete
					SET @retValue =  (SELECT  id FROM dbo.Propiedad_del_Propietario WHERE idPropietario = @idPropietario );
					UPDATE dbo.Propiedad_del_Propietario SET activo = 0 WHERE idPropietario = @idPropietario 
					-- Insertar dato en bitacora --
					EXEC dbo.[SPI_Bitacora] 4, @id, 1, null, @jsonAntes

				END
		END
	ELSE IF (@valorDocId is null AND @numeroFinca is not null)
		BEGIN
		SELECT  @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca
		IF(@idPropiedad is null)
			BEGIN
				RAISERROR('Propiedad no encontrada', 10, 1)
				SET @retValue = -14;
			END
		ELSE
			BEGIN
				SET @id = (SELECT [id] FROM [Propiedad_del_Propietario] AS PP WHERE PP.[idPropiedad] = @idPropiedad);
				-- cargar atributos al json --
				SET @jsonAntes = (
					SELECT PP.[idPropiedad] , PP.[idPropietario] ,  PP.[activo], PP.[fechaLeido]
					FROM [Propiedad_del_Propietario] AS PP WHERE PP.[idPropiedad] = @idPropiedad
					FOR JSON AUTO
				)
				-- Linea de delete
				SET @retValue =  (SELECT  id FROM dbo.Propiedad_del_Propietario  WHERE idPropiedad = @idPropiedad  );
				UPDATE dbo.Propiedad_del_Propietario SET activo = 0 WHERE idPropiedad = @idPropiedad 
				-- Insertar dato en bitacora --
				EXEC dbo.[SPI_Bitacora] 4, @id, 1, null, @jsonAntes
			END
		END
	ELSE
		BEGIN
		SELECT  @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca
		SELECT  @idPropietario = id from dbo.Propietario WHERE valorDocId = @valorDocId
		IF(@idPropiedad is null)
			BEGIN
				RAISERROR('Propiedad no encontrado', 10, 1)
				SET @retValue = -14;
			END
		ELSE IF(@idPropietario is null)
			BEGIN
				RAISERROR('Propietario no encontrado', 10, 1)
				SET @retValue = -12;
			END
		ELSE
			BEGIN
				SET @id = (SELECT [id] FROM [Propiedad_del_Propietario] AS PP WHERE idPropiedad = @idPropiedad AND idPropietario = @idPropietario);
				-- cargar atributos al json --
				SET @jsonAntes = (
					SELECT PP.[idPropiedad] , PP.[idPropietario] ,  PP.[activo], PP.[fechaLeido]
					FROM [Propiedad_del_Propietario] AS PP WHERE idPropiedad = @idPropiedad AND idPropietario = @idPropietario
					FOR JSON AUTO
				)
				-- Linea de delete
				SET @retValue =  (SELECT  id FROM dbo.Propiedad_del_Propietario WHERE idPropiedad = @idPropiedad AND idPropietario = @idPropietario  );
				UPDATE dbo.Propiedad_del_Propietario SET activo = 0 WHERE idPropiedad = @idPropiedad AND idPropietario = @idPropietario 
				-- Insertar dato en bitacora --
				EXEC dbo.[SPI_Bitacora] 4, @id, 1, null, @jsonAntes
			END
		END
	RETURN @retValue
		
END

DROP PROCEDURE [dbo].[SPD_Propiedad_Del_Propietario]

--Entrada: Numero de Finca (opcional), Valor doc Id (opcional)
--Salida Exitosa: Id del dato borrado
--Salida Fallida: Codigo de error[-12,-14]
--Descripcion: Borra la relacion del propietario y la propiedad
--puede aceptar entradas [0],[1],[0][1] 

--Delete (Viejo)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Propiedad_Del_Propietario]
@numeroFinca int = null,
@valorDocId bigInt = null
AS
BEGIN
	DECLARE @idPropietario int, @idPropiedad int, @retValue int
	IF (@numeroFinca is null AND @valorDocId is not null)
		BEGIN
			SELECT  @idPropietario = id from dbo.Propietario WHERE valorDocId = @valorDocId
			IF(@idPropietario is null)
				BEGIN
					RAISERROR('Propietario no encontrado', 10, 1)
					SET @retValue = -12;
				END
			ELSE
				BEGIN
					SET @retValue =  (SELECT  id FROM dbo.Propiedad_del_Propietario WHERE idPropietario = @idPropietario );
					DELETE FROM dbo.Propiedad_del_Propietario WHERE idPropietario = @idPropietario 
				END
		END
	ELSE IF (@valorDocId is null AND @numeroFinca is not null)
		BEGIN
		SELECT  @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca
		IF(@idPropiedad is null)
			BEGIN
				RAISERROR('Propiedad no encontrada', 10, 1)
				SET @retValue = -14;
			END
		ELSE
			BEGIN
				SET @retValue =  (SELECT  id FROM dbo.Propiedad_del_Propietario  WHERE idPropiedad = @idPropiedad  );
				DELETE FROM dbo.Propiedad_del_Propietario WHERE idPropiedad = @idPropiedad 
			END
		END
	ELSE
		BEGIN
		SELECT  @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca
		SELECT  @idPropietario = id from dbo.Propietario WHERE valorDocId = @valorDocId
		IF(@idPropiedad is null)
			BEGIN
				RAISERROR('Propiedad no encontrado', 10, 1)
				SET @retValue = -14;
			END
		ELSE IF(@idPropietario is null)
			BEGIN
				RAISERROR('Propietario no encontrado', 10, 1)
				SET @retValue = -12;
			END
		ELSE
			BEGIN
				SET @retValue =  (SELECT  id FROM dbo.Propiedad_del_Propietario WHERE idPropiedad = @idPropiedad AND idPropietario = @idPropietario  );
				DELETE FROM dbo.Propiedad_del_Propietario WHERE idPropiedad = @idPropiedad AND idPropietario = @idPropietario 
			END
		END
	RETURN @retValue
		
END

--Entrada: Valor Doc Id , Numero de Finca (opcinal)
--Salida Exitosa: No tiene valor de retorno
--Salida Fallida: No tiene valor de retorno
--Descripcion: Devuelve las porpiedades de un propietarios
--se puede o no especificar una propiedad en especifico
--Nota: No tiene valores de error ni de retorno

--ESTE STATE PROCEDURE NO SIRVE
CREATE PROCEDURE [dbo].[SPS_Propiedad_Del_Propietario_Detail]
@valorDocId bigInt = null,
@numeroFinca int = null

AS
BEGIN
	IF (@valorDocId is not null AND @numeroFinca is null)
		BEGIN
			SELECT dbo.Propiedad.[numeroFinca], dbo.Propiedad.[valor], dbo.Propiedad.[direccion]
			FROM dbo.[Propiedad_del_Propietario]
			JOIN dbo.[Propiedad] ON dbo.Propiedad_del_Propietario.[idPropiedad] = dbo.Propiedad.[id]
			JOIN dbo.[Propietario] ON dbo.Propiedad_del_Propietario.[idPropietario] = dbo.Propietario.[id]
			WHERE dbo.Propietario.[valorDocId] = @valorDocId AND dbo.Propiedad_del_Propietario.[activo] = 1;
		END
	ELSE IF (@valorDocId is null AND @numeroFinca is not null)
		BEGIN
			SELECT dbo.Propietario.[nombre], dbo.Propietario.[valorDocId], dbo.Tipo_DocId.[nombre]
			FROM dbo.[Propiedad_del_Propietario]
			JOIN dbo.[Propiedad] ON dbo.Propiedad_del_Propietario.[idPropiedad] = dbo.Propiedad.[id]
			JOIN dbo.[Propietario] ON dbo.Propiedad_del_Propietario.[idPropietario] = dbo.Propietario.[id]
			JOIN dbo.[Tipo_DocId] ON dbo.Propietario.[idDocId] = dbo.Tipo_DocId.[id]
			WHERE dbo.Propiedad.[numeroFinca] = @numeroFinca AND dbo.Propiedad_del_Propietario.[activo] = 1;
		END
END

DROP PROCEDURE [SPS_Propiedad_Del_Propietario_Detail]



--Pruebas
select * from propiedad
select * from dbo.Propietario
select * from dbo.Propiedad_del_Propietario
EXECUTE SPD_Propiedad_Del_Propietario 1176180, 304110067
EXECUTE SPI_Propiedad_Del_Propietario 1176180, 304110067
EXECUTE SPD_Propiedad_Del_Propietario null, 201
EXECUTE SPD_Propiedad_Del_Propietario 15590
EXECUTE SPS_Propiedad_Del_Propietario_Detail 304110067