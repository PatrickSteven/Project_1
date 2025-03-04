--Entrada: idPropietario, Responsable, ValorDocId (no existente), idDocId 
--Salida Exitosa: Ultimo dato insertado en la tabla de Porpietario_Juridico
--Salida Fallida: Codigo de error [-14]
--Descripcion: Inserta un Propietario Juridico  a la tabla si no existe el
--valorDocId de los elementos ingresados

--Insert actualizado
CREATE PROCEDURE [dbo].[SPI_Propietario_Juridico]			
@idPropietario int,													
@responsable NVARCHAR(50),														
@valorDocIdResponsable bigInt,
@idDocId int
AS 
BEGIN TRY
	DECLARE @retValue int = 1, @estado int = 1, @docId int;
	SELECT @docId = [id] FROM dbo.[Tipo_DocId] AS T WHERE @idDocId = T.[codigoDoc]
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	DECLARE @id int; 

	IF EXISTS (SELECT * FROM dbo.[Propietario] AS P WHERE P.[id] = @idPropietario AND P.[activo] = 1)
		BEGIN
			IF NOT EXISTS (SELECT * FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario) 
				BEGIN	
				BEGIN TRANSACTION
					-- INSERT --
					INSERT INTO dbo.[Propietario_Juridico] ([id], [responsable], [valorDocId], [idDocId], [activo], [fechaLeido]) 
					VALUES (@idPropietario, @responsable, @valorDocIdResponsable, @docId, @estado, GETDATE())
					SET @retValue = 1;
					-- Convertir la informacion en json --
					SET @jsonDespues = (
						SELECT PJ.valorDocId, PJ.responsable, PJ.idDocId,  PJ.activo, PJ.fechaLeido
						FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario
						FOR JSON AUTO
					)
					SET @id = (SELECT [id] FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario);
					-- Insertar dato en bitacora --
					EXEC dbo.[SPI_Bitacora] 6,  @id , 1, @jsonDespues, null
				COMMIT TRANSACTION
				END
			-- Si el propietario juridico existe pero no esta activado --
			ELSE IF EXISTS(SELECT * FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario AND PJ.[activo] = 0)
				BEGIN 
				BEGIN TRANSACTION
					SET @id = (SELECT [id] FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario);
					-- Si el propietario esta activado entonces el propietario juridico tambien se puede activar --
					-- Convertir la informacion en json --
					SET @jsonAntes = (
						SELECT PJ.valorDocId, PJ.responsable, PJ.idDocId,  PJ.activo, PJ.fechaLeido
						FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario
						FOR JSON AUTO
					)
					-- UPDATE --
					UPDATE dbo.[Propietario_Juridico] SET dbo.Propietario_Juridico.[activo] = 1 WHERE [Propietario_Juridico].id = @idPropietario; 
					EXECUTE [SPU_Propietario_Juridico] @responsable, @valorDocIdResponsable;
					SET @retvalue = 1;
					-- Convertir la informacion en json --
					SET @jsonDespues = (
						SELECT PJ.valorDocId, PJ.responsable, PJ.idDocId,  PJ.activo, PJ.fechaLeido
						FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario
						FOR JSON AUTO
					)
					-- Insertar dato en bitacora --
					EXEC dbo.[SPI_Bitacora] 6, @id, 1, @jsonDespues, @jsonAntes
				COMMIT TRANSACTION
				END
			--Si el propietario juridico existe y esta activo
			ELSE 
				BEGIN
					RAISERROR('Responsable Juridico ya registrado en la base de datos', 10, 1)
					SET @retValue = -14;
				END
		END
	ELSE
		BEGIN
			BEGIN
				RAISERROR('Propietario no registrado en la base de datos', 10, 1)
				SET @retValue = -12;
			END
		END
	
	RETURN @retValue
END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE()
 
   RAISERROR( @Message, @Severity, @State) 
   ROLLBACK TRANSACTION;
END CATCH

DROP PROCEDURE dbo.[SPI_Propietario_Juridico]

--Insert actualizado
CREATE PROCEDURE [dbo].[SPI_Propietario_Juridico_XML]			
@valorDocIdPropietario bigInt,													
@responsable NVARCHAR(50),														
@valorDocIdResponsable bigInt,
@idDocId int,
@fechaLeido date
AS 
BEGIN TRY
	DECLARE @retValue int = 1, @estado int = 1, @idPropietario int, @docId int;
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	DECLARE @id int; 

	SELECT @docId = [id] FROM dbo.[Tipo_DocId] AS T WHERE @idDocId = T.[codigoDoc]
	SELECT @idPropietario = [id] FROM dbo.[Propietario] AS P WHERE @valorDocIdPropietario = P.[valorDocId]

	IF EXISTS (SELECT * FROM dbo.[Propietario] AS P WHERE P.[id] = @idPropietario AND P.[activo] = 1)
		BEGIN
			IF NOT EXISTS (SELECT * FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario) 
				BEGIN	
				BEGIN TRANSACTION	
					-- INSERT --		
					INSERT INTO dbo.[Propietario_Juridico] ([id], [responsable], [valorDocId], [idDocId], [activo], [fechaLeido]) 
					VALUES (@idPropietario, @responsable, @valorDocIdResponsable, @docId, @estado, @fechaLeido)
					SET @retValue = 1;
					-- Convertir la informacion en json --
					SET @jsonDespues = (
						SELECT PJ.valorDocId, PJ.responsable, PJ.idDocId,  PJ.activo, PJ.fechaLeido
						FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario
						FOR JSON AUTO
					)
					SET @id = (SELECT [id] FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario);
					-- Insertar dato en bitacora --
					EXEC dbo.[SPI_Bitacora] 6, @id, 1, @jsonDespues, null
				COMMIT TRANSACTION
				END
			-- Si el propietario juridico existe pero no esta activado --
			ELSE IF EXISTS(SELECT * FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario AND PJ.[activo] = 0)
				BEGIN 
				BEGIN TRANSACTION
					-- Si el propietario esta activado entonces el propietario juridico tambien se puede activar --
					SET @id = (SELECT [id] FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario);
					-- Si el propietario esta activado entonces el propietario juridico tambien se puede activar --
					-- Convertir la informacion en json --
					SET @jsonAntes = (
						SELECT PJ.valorDocId, PJ.responsable, PJ.idDocId,  PJ.activo, PJ.fechaLeido
						FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario
						FOR JSON AUTO
					)
					-- UPDATE --
					UPDATE dbo.[Propietario_Juridico] SET dbo.Propietario_Juridico.[activo] = 1 WHERE [Propietario_Juridico].id = @idPropietario; 
					EXECUTE [SPU_Propietario_Juridico] @responsable, @valorDocIdResponsable;
					SET @retvalue = 1;
					-- Convertir la informacion en json --
					SET @jsonDespues = (
						SELECT PJ.valorDocId, PJ.responsable, PJ.idDocId,  PJ.activo, PJ.fechaLeido
						FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario
						FOR JSON AUTO
					)
					-- Insertar dato en bitacora --
					EXEC dbo.[SPI_Bitacora] 6, @id, 1, @jsonDespues, @jsonAntes	
				COMMIT TRANSACTION
				END
			--Si el propietario juridico existe y esta activo
			ELSE 
				BEGIN
					RAISERROR('Responsable Juridico ya registrado en la base de datos', 10, 1)
					SET @retValue = -14;
				END
		END
	ELSE
		BEGIN
			BEGIN
				RAISERROR('Propietario no registrado en la base de datos', 10, 1)
				SET @retValue = -12;
			END
		END
	
	RETURN @retValue
END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE()
 
   RAISERROR( @Message, @Severity, @State) 
   ROLLBACK TRANSACTION;
END CATCH

DROP PROCEDURE dbo.[SPI_Propietario_Juridico_XML]

--Delete nuevo
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Propietario_Juridico]
@valorDocId bigInt = null,
@idPropietario int = null
AS
BEGIN TRY
	DECLARE @retValue int;
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	DECLARE @id int; 

	IF EXISTS (SELECT * FROM dbo.[Propietario] AS P WHERE P.[valorDocId] = @valorDocId)
		BEGIN
		BEGIN TRANSACTION
			SET @id = (SELECT [id] FROM dbo.[Propietario_Juridico] AS PJ WHERE [valorDocId] = @valorDocId);
			-- guardar datos en un json --
			SET @jsonAntes = (
				SELECT PJ.valorDocId, PJ.responsable, PJ.idDocId,  PJ.activo, PJ.fechaLeido
				FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[id] = @idPropietario
				FOR JSON AUTO
			)
			UPDATE dbo.[Propietario_Juridico] SET [activo] = 0  WHERE [valorDocId] = @valorDocId 
			SET @retValue = 1;
			-- Insertar dato en bitacora --
			EXEC dbo.[SPI_Bitacora] 6, @id, 0, null, @jsonAntes	
		COMMIT TRANSACTION
		END
	ELSE 
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
		    SET @retValue = -12;
		END
	RETURN @retValue;
END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE()
 
   RAISERROR( @Message, @Severity, @State) 
   ROLLBACK TRANSACTION;
END CATCH
	
DROP PROCEDURE [SPD_Propietario_Juridico]

--Entrada: Responsable (existente), Valor Doc Id (Existente)
--Salida Exitosa: Id del valor modificado en la tabla propietario juridico
--Salida Fallida: Codigo de error [-24]
--Descripcion: Si se logra buscar el valor en la tabla de Porpietario Juridico
--Entonces cambia elresponsable basado en el valor doc id que busco
CREATE PROCEDURE [dbo].[SPU_Propietario_Juridico]
@responsable NVARCHAR(50),
@valorDocId int
AS
BEGIN TRY 
	DECLARE @retValue int;
	DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
	DECLARE @id int; 

	IF EXISTS (SELECT * FROM dbo.Propietario_Juridico AS PJ WHERE PJ.[valorDocId] = @valorDocId)
		BEGIN
		BEGIN TRANSACTION
			-- guardar datos en un json --
			SET @jsonAntes = (
				SELECT PJ.valorDocId, PJ.responsable, PJ.idDocId,  PJ.activo, PJ.fechaLeido
				FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[valorDocId] = @valorDocId
				FOR JSON AUTO
			)
			-- UPDATE -- 
			UPDATE dbo.[Propietario_Juridico] SET [responsable] = @responsable WHERE [valorDocId] = @valorDocId
			SET @retValue =  (SELECT [id] FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[valorDocId] = @valorDocId);
			-- guardar datos en un json --
			SET @jsonDespues = (
				SELECT PJ.valorDocId, PJ.responsable, PJ.idDocId,  PJ.activo, PJ.fechaLeido
				FROM dbo.[Propietario_Juridico] AS PJ WHERE PJ.[valorDocId] = @valorDocId
				FOR JSON AUTO
			)
			EXEC dbo.[SPI_Bitacora] 6, @id, 1, @jsonDespues, @jsonAntes		
		COMMIT TRANSACTION
		END
	ELSE
		BEGIN
				RAISERROR('ValorDocId no encontrado en Propietario Juridico', 10, 1)
				SET @retValue = -24
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

DROP PROCEDURE [SPU_Propietario_Juridico]

--Entrada: No tiene entrada
--Salida Exitosa: No retorna nada
--Salida Fallida: No retorna nada
--Descripcion: Solamente hace un select de toda la tabla
--y une la tabla del [Porpietario,Propietario Juridico]
--basado en los id's que comparten
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPS_Propietario_Juridico]
AS 
BEGIN
	DECLARE @ValorDocIdPropietario bigInt SELECT  responsable 'Responsable', dbo.Propietario_Juridico.[valorDocId] 'Documento_Id', dbo.Propietario.[valorDocId] 'Propietario Docuento_Id'
	FROM dbo.[Propietario_Juridico] 
	JOIN dbo.[Propietario] ON dbo.Propietario_Juridico.[id] = dbo.Propietario.[id]
END

DROP PROCEDURE [SPS_Propietario_Juridico]

--Entrada: Valor Doc Id
--Salida Exitosa: No retorna un valor
--Salida Fallida: No retorna un valor
--Descripcion: Solamente selecciona el propietario juridico que se 
--indica en el input ValorDocId
CREATE PROCEDURE [dbo].[SPS_Propietario_Juridico_Detail]
@valorDocId bigInt
AS 
BEGIN
	DECLARE @idPropietario int, @valorId int;
	SELECT @idPropietario = [id] from dbo.Propietario AS P WHERE P.[valorDocId] = @valorDocId
	IF @idPropietario is not null
		BEGIN
			SELECT responsable, PJ.[valorDocId], dbo.Tipo_DocId.codigoDoc
			FROM dbo.Propietario_Juridico AS PJ 
			INNER JOIN dbo.Tipo_DocId ON PJ.idDocId = dbo.Tipo_DocId.id
			WHERE PJ.[id] = @idPropietario
		END
END

DROP PROCEDURE [SPS_Propietario_Juridico_Detail]

--Prueba
EXECUTE SPI_Propietario_Juridico 38014,"Diego", 3, 1

EXECUTE SPI_Propietario_Juridico "Di", 110060884, 1
SELECT * from Propietario_Juridico
SELECT * from Propietario
SELECT * from Tipo_DocId
EXECUTE SPD_Propietario_Juridico 110060884, 110060884
EXECUTE SPU_Propietario_Juridico "Manuel", 110060884
EXECUTE SPS_Propietario_Juridico_Detail 110201818
EXECUTE [SPS_Propietario_Juridico]
EXECUTE [SPI_Propietario_Juridico_XML] 3101250683, 'FABIO JOSUE CALDERON TORRES', 417552185, 4, '2020-01-30'

DROP PROCEDURE SPD_Propietario_Juridico
DROP PROCEDURE SPU_Propietario_Juridico
DROP PROCEDURE SPI_Propietario_Juridico
DROP PROCEDURE [SPS_Propietario_Juridico] 

SELECT * FROM dbo.Bitacora
