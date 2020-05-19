USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO
--Insert (Actualizado 1.0)
CREATE PROCEDURE [dbo].[SPI_Propietario]
@nombre NVARCHAR(50),
@valorDocId int,
@idDocId int
AS 
BEGIN TRY
	DECLARE @retValue int;
	DECLARE @estado int = 1;
	IF NOT EXISTS (SELECT * FROM dbo.Propietario WHERE valorDocId = @valorDocId)
		BEGIN
			INSERT INTO Propietario(nombre, valorDocId, idDocId,activo) VALUES (@nombre,@valorDocId,@idDocId, @estado)
			SET @retValue = SCOPE_IDENTITY();
		END

	ELSE IF EXISTS(SELECT * FROM dbo.Propietario WHERE valorDocId = @valorDocId AND dbo.Propietario.activo = 0)
		BEGIN
			UPDATE dbo.Propietario SET dbo.Propietario.activo = 1 WHERE valorDocId = @valorDocId;
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

--Delete (Actualizado Nuevo)
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
			--DELETE FROM Propietario WHERE valorDocId = @valorDocId 
			UPDATE dbo.Propietario SET activo = 0  WHERE valorDocId = @valorDocId 
		END
			
	ELSE 
		BEGIN
			RAISERROR('Propietario no registrado en la base de datos', 10, 1)
			SET @retValue = -12;
		END
	RETURN  @retValue;
END

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
@valorDocId int
AS 
BEGIN TRY
	DECLARE @retValue int;
	IF EXISTS (SELECT * FROM dbo.Propietario WHERE valorDocId = @valorDocId)
		BEGIN
			UPDATE dbo.Propietario
				SET nombre = @nombre
				WHERE valorDocId = @valorDocId
			SET @retValue =  (SELECT id FROM dbo.Propietario WHERE valorDocId = @valorDocId);
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

--Select (Actualizado)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPS_Propietario]
AS 
BEGIN
	SELECT 
	nombre 'Nombre',
	valorDocId 'Documento_Id'

	FROM dbo.Propietario
	WHERE activo = 1;
END

--Select Propietario (Actualizado 1.0)
CREATE PROCEDURE [dbo].[SPS_Propietario_Detail]
@valorDocId int
AS
BEGIN
	SELECT Propietario.idDocId, Propietario.nombre, Propietario.ValorDocId, Tipo_DocId.nombre
	FROM dbo.Propietario
	JOIN dbo.Tipo_DocId ON dbo.Propietario.idDocId = dbo.Tipo_DocId.id
	WHERE Propietario.valorDocId = @valorDocId
END

--Pruebas-- (Actualizado 1.0)
EXECUTE SPI_Propietario "Carlos", 201, 1
Select * from dbo.Propietario
EXECUTE SPU_Propietario "Ramón", 2020
EXECUTE SPS_Propietario
EXECUTE SPD_Propietario 201
EXECUTE SPS_Propietario_Detail 124135

