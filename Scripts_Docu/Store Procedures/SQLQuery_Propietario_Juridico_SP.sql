--Entrada: idPropietario, Responsable, ValorDocId (no existente), idDocId 
--Salida Exitosa: Ultimo dato insertado en la tabla de Porpietario_Juridico
--Salida Fallida: Codigo de error [-14]
--Descripcion: Inserta un Propietario Juridico  a la tabla si no existe el
--valorDocId de los elementos ingresados
CREATE PROCEDURE [dbo].[SPI_Propietario_Juridico]
@idPropietario int,
@responsable NVARCHAR(50),
@valorDocId int,
@idDocId int
AS 
BEGIN TRY
	DECLARE @retValue int;
	IF NOT EXISTS (SELECT * FROM dbo.Propietario WHERE valorDocId = @valorDocId)
	OR NOT EXISTS (SELECT * FROM dbo.Propietario_Juridico WHERE valorDocId = @valorDocId)
		BEGIN
			INSERT INTO Propietario_Juridico(idPropietario, responsable, valorDocId, idDocId) 
			VALUES (@idPropietario, @responsable, @valorDocId, @idDocId)
			SET @retValue = SCOPE_IDENTITY();
		END

	ELSE 
		BEGIN
			RAISERROR('Responsable Juridico ya registrado en la base de datos', 10, 1)
			SET @retValue = -14;
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

--Entrada: Valor Doc Id (opcional), Id Propietario (opcional)
--Salida Exitosa: No retorna nada
--Salida Fallida: No retorna nada
--Descripcion: Dependiendo del input borra buscando dicho input
--el elemnto en la tablaque lo contenga
--Nota: este metodo no tiene implementado error handling 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Propietario_Juridico]
@valorDocId int = null,
@idPropietario int = null
AS
BEGIN
	IF @idPropietario is null
		DELETE FROM dbo.Propietario_Juridico WHERE valorDocId = @valorDocId
	ELSE 
		DELETE FROM dbo.Propietario_Juridico WHERE idPropietario = @idPropietario
END

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
	IF EXISTS (SELECT * FROM dbo.Propietario_Juridico WHERE valorDocId = @valorDocId)
		BEGIN
			UPDATE dbo.Propietario_Juridico
				SET responsable = @responsable
				WHERE valorDocId = @valorDocId
			SET @retValue =  (SELECT id FROM dbo.Propietario_Juridico WHERE valorDocId = @valorDocId);
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
	DECLARE @ValorDocIdPropietario int
	SELECT 
	responsable 'Responsable',
	dbo.Propietario_Juridico.valorDocId 'Documento_Id',
	dbo.Propietario.valorDocId 'Propietario Docuento_Id'
	FROM dbo.Propietario_Juridico 
	JOIN dbo.Propietario ON dbo.Propietario_Juridico.idPropietario = dbo.Propietario.id
END

--Entrada: Valor Doc Id
--Salida Exitosa: No retorna un valor
--Salida Fallida: No retorna un valor
--Descripcion: Solamente selecciona el propietario juridico que se 
--indica en el input ValorDocId
CREATE PROCEDURE [dbo].[SPS_Propietario_Juridico_Detail]
@valorDocId int
AS 
BEGIN
	DECLARE @idPropietario int
	SELECT @idPropietario = id from Propietario WHERE valorDocId = @valorDocId
	IF @idPropietario is not null
		BEGIN
			SELECT responsable, dbo.Propietario_Juridico.valorDocId, dbo.Propietario_Juridico.idDocId
			FROM dbo.Propietario_Juridico 
			WHERE idPropietario = @idPropietario
		END
END


--Prueba
EXECUTE SPI_Propietario_Juridico "Diego", 1919, 1, 2020
SELECT * from Propietario_Juridico
SELECT * from Propietario
EXECUTE SPD_Propietario_Juridico null, 1
EXECUTE SPU_Propietario_Juridico "Manuel", 1919
EXECUTE SPS_Propietario_Juridico_Detail 124135
DROP PROCEDURE SPD_Propietario_Juridico
