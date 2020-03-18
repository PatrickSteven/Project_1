USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO
--Insert
CREATE PROCEDURE SPI_Propietario
@nombre NVARCHAR(50),
@valorDocId int,
@idDocId int
AS 
BEGIN TRY
	IF NOT EXISTS (SELECT * FROM dbo.Propietario WHERE valorDocId = @valorDocId)
		INSERT INTO Propietario(nombre, valorDocId, idDocId) VALUES (@nombre,@valorDocId,@idDocId)

	ELSE 
		RAISERROR('Propietario ya registrado en la base de datos', 10, 1)
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
CREATE PROCEDURE [dbo].[SPD_Propietario]
@valorDocId BIGINT 
AS
BEGIN
	DECLARE @idPropietario int;
	SELECT @idPropietario = id from dbo.Propietario WHERE valorDocId = @valorDocId
	EXECUTE dbo.SPD_Propiedad_Del_Propietario null, @valorDocId
	EXECUTE dbo.SPD_Propietario_Juridico null, @idPropietario
	DELETE FROM Propietario WHERE valorDocId = @valorDocId
END

--Update
CREATE PROCEDURE [dbo].[SPU_Propietario]
@nombre NVARCHAR(50),
@valorDocId int
AS
BEGIN
UPDATE dbo.Propietario
	SET nombre = @nombre
	WHERE valorDocId = @valorDocId
END

--Select
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
END

--Pruebas--
EXECUTE SPI_Propietario "Carlos", 2021, 1
Select * from dbo.Propietario
EXECUTE SPU_Propietario "Ramón", 2020
EXECUTE SPS_Propietario
EXECUTE SPD_Propietario 2021
DROP PROCEDURE SPD_Propietario


