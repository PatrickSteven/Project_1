--Insert
CREATE PROCEDURE SPI_Propietario_Juridico
@responsable NVARCHAR(50),
@valorDocId int,
@idDocId int,
@ValorDocPropietario int
AS 
BEGIN
	DECLARE @idPropietario int
	SELECT @idPropietario = id from dbo.Propietario WHERE valorDocId = @ValorDocPropietario;

	INSERT INTO dbo.Propietario_Juridico(responsable, valorDocId, idDocId, idPropietario)
		VALUES (@responsable, @valorDocId, @idDocId, @idPropietario);
END

--Delete 
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

--Update
CREATE PROCEDURE [dbo].[SPU_Propietario_Juridico]
@responsable NVARCHAR(50),
@valorDocId int
AS
BEGIN
UPDATE dbo.Propietario_Juridico
	SET responsable = @responsable
	WHERE valorDocId = @valorDocId
END

--Select
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


--Prueba
EXECUTE SPI_Propietario_Juridico "Diego", 1919, 1, 2020
SELECT * from Propietario_Juridico
EXECUTE SPD_Propietario_Juridico null, 1
EXECUTE SPU_Propietario_Juridico "Manuel", 1919
EXECUTE SPS_Propietario_Juridico
DROP PROCEDURE SPD_Propietario_Juridico
