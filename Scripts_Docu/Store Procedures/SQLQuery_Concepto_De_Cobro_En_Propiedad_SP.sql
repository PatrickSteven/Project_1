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

--Select
CREATE PROCEDURE [dbo].[SPS_Concepto_De_Cobro_En_Propiedad]
@numeroFinca int,
@TipoCC varchar(100)
AS
BEGIN
	DECLARE @idPropiedad int, @retValue int;
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca
	IF @idPropiedad is null
		BEGIN
			RAISERROR('Propiedad no encontrada',10,1)
			SET @retValue = -10;
		END
	ELSE
	BEGIN
		BEGIN
			IF(@TipoCC = 'CC_Fijo')
				BEGIN
					select 
					p.fechaInicio,
					p.fechaFin,
					c2.nombre,
					c2.tasaInteresesMoratorios,
					c2.DiaCobro,
					c2.qDiasVencidos,
					c2.EsFijo,
					c2.EsRecurrente,
					c.monto
					from dbo.Concepto_Cobro_en_Propiedad p
					inner join dbo.Concepto_Cobro c2 on p.idConeceptoCobro = c2.id
					inner join dbo.CC_Fijo c on p.idConeceptoCobro = c.id
					WHERE p.idPropiedad = @idPropiedad;
				END
			ELSE IF (@TipoCC = 'CC_Consumo')
				BEGIN
					select 
					p.fechaInicio,
					p.fechaFin,
					c2.nombre,
					c2.tasaInteresesMoratorios,
					c2.DiaCobro,
					c2.qDiasVencidos,
					c2.EsFijo,
					c2.EsRecurrente,
					c.id
					from dbo.Concepto_Cobro_en_Propiedad p
					inner join dbo.Concepto_Cobro c2 on p.idConeceptoCobro = c2.id
					inner join dbo.CC_Consumo c on p.idConeceptoCobro = c.id				
					WHERE p.idPropiedad = @idPropiedad;
				END
			ELSE -- Intereses Moratorios
				BEGIN 
					select 
					p.fechaInicio,
					p.fechaFin,
					c2.nombre,
					c2.tasaInteresesMoratorios,
					c2.DiaCobro,
					c2.qDiasVencidos,
					c2.EsFijo,
					c2.EsRecurrente
					from dbo.Concepto_Cobro_en_Propiedad p
					inner join dbo.Concepto_Cobro c2 on p.idConeceptoCobro = c2.id
					inner join dbo.CC_Intereses_Moratorios c on p.idConeceptoCobro = c.id					
					WHERE p.idPropiedad = @idPropiedad;
				END
		END
	END
END

--Pruebas
select * from Propiedad
select * from Concepto_Cobro
select * from CC_Fijo
select * from Concepto_Cobro_en_Propiedad
EXECUTE dbo.SPS_Concepto_De_Cobro_En_Propiedad '9009','CC_Fijo'
EXECUTE dbo.SPI_Concepto_Cobro_En_Propiedad '2019-03-12', '2020-05-15', 'Electricidad', '9009'
EXECUTE dbo.SPD_Concepto_De_Cobro_En_Propiedad 0, 'Electricidad'
EXECUTE dbo.SPU_Concepto_De_Cobro_En_Propiedad 'Electricidad', '1', '2021-08-15'
DROP PROCEDURE SPD_Concepto_De_Cobro_En_Propiedad