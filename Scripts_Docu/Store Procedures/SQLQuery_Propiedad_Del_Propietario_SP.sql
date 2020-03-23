--Insert
CREATE PROCEDURE SPI_Propiedad_Del_Propietario
@numeroFinca int,
@valorDocId int
AS 
BEGIN
	DECLARE @idPropietario int, @idPropiedad int
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca
	SELECT @idPropietario = id from dbo.Propietario WHERE valorDocId = @valorDocId
	IF(@idPropiedad is null)
		RAISERROR('Propiedad no encontrada', 10, 1)
	ELSE IF(@idPropietario is null)
		RAISERROR('Propietario no encontrado', 10, 1)
	ELSE
		INSERT INTO dbo.Propiedad_del_Propietario(idPropiedad, idPropietario) VALUES (@idPropiedad, @idPropietario)
END 

--Delete
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Propiedad_Del_Propietario]
@numeroFinca int = null,
@valorDocId int = null
AS
BEGIN
	DECLARE @idPropietario int, @idPropiedad int
	IF (@numeroFinca is null AND @valorDocId is not null)
		BEGIN
		SELECT @idPropietario = id from dbo.Propietario WHERE valorDocId = @valorDocId
		IF(@idPropietario is null)
			RAISERROR('Propietario no encontrado', 10, 1)
		ELSE
			DELETE FROM dbo.Propiedad_del_Propietario WHERE idPropietario = @idPropietario 
		END
	ELSE IF (@valorDocId is null AND @numeroFinca is not null)
		BEGIN
		SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca
		IF(@idPropiedad is null)
			RAISERROR('Propiedad no encontrada', 10, 1)
		ELSE
			DELETE FROM dbo.Propiedad_del_Propietario WHERE idPropiedad = @idPropiedad 
		END
	ELSE
		BEGIN
		SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca
		SELECT @idPropietario = id from dbo.Propietario WHERE valorDocId = @valorDocId
		IF(@idPropiedad is null)
			RAISERROR('Propiedad no encontrada', 10, 1)
		ELSE IF(@idPropietario is null)
			RAISERROR('Propietario no encontrado', 10, 1)
		ELSE
			DELETE FROM dbo.Propiedad_del_Propietario WHERE idPropiedad = @idPropiedad AND idPropietario = @idPropietario 
		END
		
END

CREATE PROCEDURE [dbo].[SPS_Propiedad_Del_Propietario_Detail]
@valorDocId int = null,
@numeroFinca int = null

AS
BEGIN
	IF (@valorDocId is not null AND @numeroFinca is null)
	BEGIN
		SELECT dbo.Propiedad.numeroFinca, dbo.Propiedad.valor, dbo.Propiedad.direccion
		FROM dbo.Propiedad_del_Propietario
		JOIN dbo.Propiedad ON dbo.Propiedad_del_Propietario.idPropiedad = dbo.Propiedad.id
		JOIN dbo.Propietario ON dbo.Propiedad_del_Propietario.idPropietario = dbo.Propietario.id
		WHERE dbo.Propietario.valorDocId = @valorDocId;
	END
	ELSE IF (@valorDocId is null AND @numeroFinca is not null)
	BEGIN
		SELECT dbo.Propietario.nombre, dbo.Propietario.valorDocId, dbo.Tipo_DocId.nombre
		FROM dbo.Propiedad_del_Propietario
		JOIN dbo.Propiedad ON dbo.Propiedad_del_Propietario.idPropiedad = dbo.Propiedad.id
		JOIN dbo.Propietario ON dbo.Propiedad_del_Propietario.idPropietario = dbo.Propietario.id
		JOIN dbo.Tipo_DocId ON dbo.Propietario.idDocId = dbo.Tipo_DocId.id
		WHERE dbo.Propiedad.numeroFinca = @numeroFinca;
	END
END



--Pruebas
select * from propiedad
select * from dbo.Propietario
select * from dbo.Propiedad_del_Propietario
EXECUTE SPI_Propiedad_Del_Propietario 456, 61653
DROP PROCEDURE SPD_Propiedad_Del_Propietario
EXECUTE SPD_Propiedad_Del_Propietario null, 2020
EXECUTE SPS_Propiedad_Del_Propietario_Detail 61653