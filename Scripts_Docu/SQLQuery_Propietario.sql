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


