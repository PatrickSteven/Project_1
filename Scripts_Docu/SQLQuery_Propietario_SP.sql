USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO
--Insert
CREATE PROCEDURE SPI_Propietario
@nombre NVARCHAR(50),
@valorDocId int,
@idDocId int
AS 
BEGIN
	INSERT INTO Propietario(nombre, valorDocId, idDocId)
				VALUES (@nombre,@valorDocId,@idDocId);
END

--Delete
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Propietario]
@valorDocId BIGINT 
AS
BEGIN
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
EXECUTE SPI_Propietario "Carlos", 2020, 1
Select * from dbo.Propietario
EXECUTE SPU_Propietario "Ramón", 2020
EXECUTE SPS_Propietario

