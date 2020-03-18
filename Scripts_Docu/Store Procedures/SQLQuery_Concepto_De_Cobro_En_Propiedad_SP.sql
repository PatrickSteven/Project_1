USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO
--Insert
CREATE PROCEDURE SPI_Concepto_Cobro_En_Propiedad
@fechaInicio date,
@fechaFin date,
@nombreCC NVARCHAR(50),
@numeroFinca int

AS 
BEGIN
	DECLARE @idConceptoCobro int, @idPropiedad int;
	SELECT @idConceptoCobro = id from dbo.Concepto_Cobro WHERE nombre = @nombreCC
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca

	IF @idConceptoCobro is null OR @idPropiedad is null
		RAISERROR('Propiedad o Concepto de Cobro no encontrado',10,1)
	ELSE IF EXISTS (SELECT * from dbo.Concepto_Cobro_en_Propiedad WHERE idPropiedad = @idPropiedad AND idConeceptoCobro = @idConceptoCobro)
		RAISERROR('Concepto de Cobro en Propiedad ya registrado', 10, 1)
	ELSE 
		INSERT INTO dbo.Concepto_Cobro_en_Propiedad(fechaInicio, fechaFin, idConeceptoCobro, idPropiedad)
			VALUES(@fechaInicio, @fechaFin, @idConceptoCobro, @idPropiedad)
END

--Delete
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Concepto_De_Cobro_En_Propiedad]
@numeroFinca int,
@nombreCC NVARCHAR(50) = null
AS
BEGIN
	DECLARE @idConceptoCobro int, @idPropiedad int;
	IF @nombreCC is null
		BEGIN
		SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca

		IF @idPropiedad is null
			RAISERROR('Propiedad no encontrada',10,1)
		ELSE IF NOT EXISTS (SELECT * from dbo.Concepto_Cobro_en_Propiedad WHERE idPropiedad = @idPropiedad)
			RAISERROR('Propiedad no registrada', 10, 1)
		ELSE 
			DELETE FROM dbo.Concepto_Cobro_en_Propiedad WHERE idPropiedad = @idPropiedad
		END
	ELSE
		BEGIN
		SELECT @idConceptoCobro = id from dbo.Concepto_Cobro WHERE nombre = @nombreCC
		SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca

		IF @idConceptoCobro is null OR @idPropiedad is null
			RAISERROR('Propiedad o Concepto de Cobro no encontrado',10,1)
		ELSE IF NOT EXISTS (SELECT * from dbo.Concepto_Cobro_en_Propiedad WHERE idPropiedad = @idPropiedad AND idConeceptoCobro = @idConceptoCobro)
			RAISERROR('Concepto de Cobro en Propiedad no registrado', 10, 1)
		ELSE 
			DELETE FROM dbo.Concepto_Cobro_en_Propiedad WHERE idPropiedad = @idPropiedad AND idConeceptoCobro = @idConceptoCobro
		END

END

--Update FechaFin
CREATE PROCEDURE [dbo].[SPU_Concepto_De_Cobro_En_Propiedad]
@nombreCC NVARCHAR(50),
@numeroFinca int,
@fechaFin date
AS
BEGIN
	DECLARE @idConceptoCobro int, @idPropiedad int;
	SELECT @idConceptoCobro = id from dbo.Concepto_Cobro WHERE nombre = @nombreCC
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca

	IF @idConceptoCobro is null OR @idPropiedad is null
		RAISERROR('Propiedad o Concepto de Cobro no encontrado',10,1)
	ELSE IF NOT EXISTS (SELECT * from dbo.Concepto_Cobro_en_Propiedad WHERE idPropiedad = @idPropiedad AND idConeceptoCobro = @idConceptoCobro)
		RAISERROR('Concepto de Cobro en Propiedad no registrado', 10, 1)
	ELSE 
		UPDATE dbo.Concepto_Cobro_en_Propiedad SET fechaFin = @fechaFin WHERE idPropiedad = @idPropiedad AND idConeceptoCobro = @idConceptoCobro
END


--Pruebas
select * from Propiedad
select * from Concepto_Cobro
select * from Concepto_Cobro_en_Propiedad
EXECUTE dbo.SPI_Concepto_Cobro_En_Propiedad '2019-03-12', '2020-05-15', 'Electricidad', '0'
EXECUTE dbo.SPD_Concepto_De_Cobro_En_Propiedad 0, 'Electricidad'
EXECUTE dbo.SPU_Concepto_De_Cobro_En_Propiedad 'Electricidad', '1', '2021-08-15'
DROP PROCEDURE SPD_Concepto_De_Cobro_En_Propiedad