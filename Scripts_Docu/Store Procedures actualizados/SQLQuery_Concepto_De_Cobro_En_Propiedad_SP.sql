USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

--Entrada: Fecha de Inicio, Fecha de Fin, Nombre de Concepto de Cobro, Numero de Finca
--Salida exitosa: Id del ultimo elemento insertado 
--Salida fallida: Codigo -20 || Codigo -21
--Descripcion: Selecciona el Id de [Propiedad,Concepto_de_Cobro] y si existen los relaciona
--como tiene dos FK entonces una se refiere a [0] y la otra [1]
CREATE PROCEDURE SPI_Concepto_Cobro_En_Propiedad
@fechaInicio date,
@fechaFin date,
@nombreCC NVARCHAR(50),
@numeroFinca int
AS 
BEGIN TRY
	
	DECLARE @idConceptoCobro int, @idPropiedad int, @retValue int,@estadoPropiedad int;
	DECLARE @activo int = 1;
	SELECT @idConceptoCobro = id from dbo.Concepto_Cobro WHERE nombre = @nombreCC
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca
	SELECT @estadoPropiedad = dbo.Propiedad.activo from dbo.Propiedad WHERE numeroFinca = @numeroFinca;

	IF (@idConceptoCobro is null OR @idPropiedad is null OR @estadoPropiedad = 0)
		BEGIN
			RAISERROR('Propiedad o Concepto de Cobro no encontrado',10,1)
			SET @retValue = -20;
		END
	ELSE IF EXISTS (SELECT * from dbo.Concepto_Cobro_en_Propiedad WHERE idPropiedad = @idPropiedad AND idConeceptoCobro = @idConceptoCobro 
					AND Concepto_Cobro_en_Propiedad.activo = 1)
		BEGIN
			RAISERROR('Concepto de Cobro en Propiedad ya registrado', 10, 1)
			SET @retValue = -21;
		END
	ELSE IF EXISTS (SELECT * from dbo.Concepto_Cobro_en_Propiedad WHERE idPropiedad = @idPropiedad AND idConeceptoCobro = @idConceptoCobro
					AND Concepto_Cobro_en_Propiedad.activo = 0)
		BEGIN
			UPDATE dbo.Concepto_Cobro_en_Propiedad SET activo = 1 WHERE idPropiedad = @idPropiedad AND idConeceptoCobro = @idConceptoCobro 
			SET @retValue = 1;
		END
	ELSE 
		BEGIN
			INSERT INTO dbo.Concepto_Cobro_en_Propiedad(fechaInicio, fechaFin, idConeceptoCobro, idPropiedad, activo) VALUES(@fechaInicio, @fechaFin, @idConceptoCobro, @idPropiedad, @activo)
			SET @retValue = SCOPE_IDENTITY();
		END
	RETURN @retValue;
END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
END CATCH

--
--Entrada: Numero de Finca, Nombre de Concepto de Cobro
--Salida exitosa: No tiene retorno
--Salida fallida: No tiene retorno
--Descripcion: Borra la relacion entre una propiedad y un concepto de cobro

--Delete (Actulizado)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPD_Concepto_De_Cobro_En_Propiedad]
@numeroFinca int,
@nombreCC NVARCHAR(50) = null
AS
BEGIN
	DECLARE @idConceptoCobro int, @idPropiedad int, @estadoPropiedad int;
	SELECT @estadoPropiedad = dbo.Propiedad.activo from dbo.Propiedad WHERE numeroFinca = @numeroFinca;
	IF @nombreCC is null
		BEGIN
		SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca

		IF (@idPropiedad is null OR @estadoPropiedad = 0)
			RAISERROR('Propiedad no encontrada',10,1)
		ELSE IF NOT EXISTS (SELECT * from dbo.Concepto_Cobro_en_Propiedad WHERE idPropiedad = @idPropiedad )
			RAISERROR('Propiedad no registrada', 10, 1)
		ELSE 
			UPDATE dbo.Concepto_Cobro_en_Propiedad SET activo = 0 WHERE idPropiedad = @idPropiedad
		END
	ELSE
		BEGIN
			SELECT @idConceptoCobro = id from dbo.Concepto_Cobro WHERE nombre = @nombreCC
			SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca

			IF @idConceptoCobro is null OR @idPropiedad is null OR @estadoPropiedad = 0
				RAISERROR('Propiedad o Concepto de Cobro no encontrado',10,1)
			ELSE IF NOT EXISTS (SELECT * from dbo.Concepto_Cobro_en_Propiedad WHERE idPropiedad = @idPropiedad AND idConeceptoCobro = @idConceptoCobro)
				RAISERROR('Concepto de Cobro en Propiedad no registrado', 10, 1)
			ELSE 
				UPDATE dbo.Concepto_Cobro_en_Propiedad SET activo = 0 WHERE idPropiedad = @idPropiedad AND idConeceptoCobro = @idConceptoCobro
		END

END

--Delete (Viejo)
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

--Entrada: Nombre de Concepto de Cobro, Numero de Finca, Fecha final
--Salida exitosa: No tiene retorno
--Salida fallida: No tiene retorno
--Descripcion: Este update se SOLAMENTE para cambiar la fecha final del CC
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

--Entrada: Numero de Finca, Tipo de Concepto de Cobro
--Salida Exitosa: No hay retorno
--Salida Fallida: No hay retorno
--Descripcion: Dependiendo del tipo de Concepto de Cobro
--el SPU selecciona la tabla de una propiedad con el tipo
--de Concepto de Cobro [CC_Fijo, CC_Consumo, Intereses Moratorios]
CREATE PROCEDURE [dbo].[SPS_Concepto_De_Cobro_En_Propiedad]
@numeroFinca int,
@TipoCC varchar(100)
AS
BEGIN
	DECLARE @idPropiedad int, @retValue int, @estadoPropiedad int;
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca
	SELECT @estadoPropiedad = dbo.Propiedad.activo from dbo.Propiedad WHERE numeroFinca = @numeroFinca;
	IF (@idPropiedad is null OR @estadoPropiedad = 0)
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
					c2.DiaDeCobro,
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
					c2.DiaDeCobro,
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
					c2.DiaDeCobro,
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
select * from Concepto_Cobro_En_Propiedad
EXECUTE dbo.SPS_Concepto_De_Cobro_En_Propiedad '1176180','CC_Fijo'
EXECUTE dbo.SPI_Concepto_Cobro_En_Propiedad '2019-03-12', '2020-05-15', 'Agua', '1176180'
EXECUTE dbo.SPD_Concepto_De_Cobro_En_Propiedad '456', 'Electricidad'
EXECUTE dbo.SPU_Concepto_De_Cobro_En_Propiedad 'Electricidad', '1', '2021-08-15'
DROP PROCEDURE SPD_Concepto_De_Cobro_En_Propiedad