USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

-- SUBIR TIPOS DE dbo.[TipoMov]
INSERT INTO dbo.TipoMov VALUES (1, 'Consumo')
INSERT INTO dbo.TipoMov VALUES (2, 'Ajuste debito') -- (+)
INSERT INTO dbo.TipoMov VALUES (3, 'Ajuste credito') -- (-)
SELECT * FROM dbo.TipoMov

-- SP_MOVIMIENTO
CREATE PROCEDURE [dbo].[SPI_Consumo]
@numeroFinca bigInt,
@lecturaMedidor int
AS
BEGIN 
	BEGIN TRY
		DECLARE @idPropiedad int, @m3AcumuladosPropiedad int, @montoM3 int, @newSaldoAcumulado int , @estadoPropiedad int;
		DECLARE @retValue int, @idTipoMov int;

		SELECT @idPropiedad = [id] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @estadoPropiedad = P.[activo] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @m3AcumuladosPropiedad = [m3Acumulados] FROM dbo.Propiedad AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @idTipoMov = [id] FROM dbo.[TipoMov] AS M WHERE M.[codigo] = 1;

		-- @lecturaMedidor > @m3AcumuladosPropiedad (siempre)
		SET @montoM3 = (@lecturaMedidor - @m3AcumuladosPropiedad);
		SET @newSaldoAcumulado = (@m3AcumuladosPropiedad + @montoM3);

		-- INSERT DE TABLA MOVIMIENTO --
		IF(@idPropiedad is null OR @estadoPropiedad = 0)
			BEGIN
				RAISERROR('Propiedad no encontrada', 10, 1)
				SET	@retValue = -17;
			END
		-- Propiedad existe --	
		ELSE
			BEGIN
				BEGIN TRANSACTION
				-- insertar movimeinto en MovConsumo --
				INSERT INTO dbo.MovConsumo([montoM3], [lecturaConsumo], [newM3Consumo], [idPropiedad], [idTipoMov],
											[fecha], [activo])
				VALUES (@montoM3, @lecturaMedidor, @newSaldoAcumulado, @idPropiedad, @idTipoMov, GETDATE(), 1);
				-- update informacion en propiedad --
				UPDATE dbo.[Propiedad] SET [m3Acumulados] = @newSaldoAcumulado WHERE [id] = @idPropiedad 
				COMMIT TRANSACTION
			END


	END TRY
	BEGIN CATCH
			DECLARE 
				@Message varchar(MAX) = ERROR_MESSAGE(),
				@Severity int = ERROR_SEVERITY(),
				@State smallint = ERROR_STATE()
 
		   RAISERROR( @Message, @Severity, @State) 
		   ROLLBACK TRANSACTION;
	END CATCH
END

DROP PROCEDURE  [dbo].[SPI_Consumo]

CREATE PROCEDURE [dbo].[SPI_Consumo_XML]
@numeroFinca bigInt,
@lecturaMedidor int,
@fecha date
AS
BEGIN
	BEGIN TRY
		DECLARE @idPropiedad int, @m3AcumuladosPropiedad int, @montoM3 int, @newSaldoAcumulado int , @estadoPropiedad int;
		DECLARE @retValue int, @idTipoMov int;

		SELECT @idPropiedad = [id] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @estadoPropiedad = P.[activo] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @m3AcumuladosPropiedad = [m3Acumulados] FROM dbo.Propiedad AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @idTipoMov = [id] FROM dbo.[TipoMov] AS M WHERE M.[codigo] = 1;

		-- @lecturaMedidor > @m3AcumuladosPropiedad (siempre)
		SET @montoM3 = (@lecturaMedidor - @m3AcumuladosPropiedad);
		SET @newSaldoAcumulado = (@m3AcumuladosPropiedad + @montoM3);

		-- INSERT DE TABLA MOVIMIENTO --
		IF(@idPropiedad is null OR @estadoPropiedad = 0)
			BEGIN
				RAISERROR('Propiedad no encontrada', 10, 1)
				SET	@retValue = -17;
			END
		-- Propiedad existe --	
		ELSE
			BEGIN
			BEGIN TRANSACTION
				-- insertar movimeinto en MovConsumo --
				INSERT INTO dbo.MovConsumo([montoM3], [lecturaConsumo], [newM3Consumo], [idPropiedad], [idTipoMov],
											[fecha], [activo])
				VALUES (@montoM3, @lecturaMedidor, @newSaldoAcumulado, @idPropiedad, @idTipoMov, @fecha, 1);
				-- update informacion en propiedad --
				UPDATE dbo.[Propiedad] SET [m3Acumulados] = @newSaldoAcumulado WHERE [id] = @idPropiedad 
			COMMIT TRANSACTION
			END


	END TRY
	BEGIN CATCH
			DECLARE 
				@Message varchar(MAX) = ERROR_MESSAGE(),
				@Severity int = ERROR_SEVERITY(),
				@State smallint = ERROR_STATE()
 
		   RAISERROR( @Message, @Severity, @State) 
		   ROLLBACK TRANSACTION;
	END CATCH
END

DROP PROCEDURE [dbo].[SPI_Consumo_XML]

CREATE PROCEDURE [dbo].[SPI_AjusteConsumo]
@numeroFinca bigInt,
@montoM3 int
AS
BEGIN
	BEGIN TRY
		DECLARE @idPropiedad int, @m3AcumuladosPropiedad int, @lecturaMedidor int, @newSaldoAcumulado int , @estadoPropiedad int;
		DECLARE @retValue int, @idTipoMov int, @signoMonto int;

		IF(@montoM3 >= 0) BEGIN SET @signoMonto = 3 END
		ELSE BEGIN SET @signoMonto = 2 END

		SELECT @idPropiedad = [id] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @estadoPropiedad = P.[activo] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @m3AcumuladosPropiedad = [m3Acumulados] FROM dbo.Propiedad AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @idTipoMov = [id] FROM dbo.[TipoMov] AS M WHERE M.[codigo] = @signoMonto;

		-- @lecturaMedidor > @m3AcumuladosPropiedad (siempre
		SET @lecturaMedidor = (@m3AcumuladosPropiedad + @montoM3);
		SET @m3AcumuladosPropiedad = (@lecturaMedidor - @montoM3);
		SET @newSaldoAcumulado = (@m3AcumuladosPropiedad + @montoM3);

		-- INSERT DE TABLA MOVIMIENTO --
		IF(@idPropiedad is null OR @estadoPropiedad = 0)
			BEGIN
				RAISERROR('Propiedad no encontrada', 10, 1)
				SET	@retValue = -17;
			END
		-- Propiedad existe --	
		ELSE
			BEGIN
			BEGIN TRANSACTION
				-- insertar movimeinto en MovConsumo --
				INSERT INTO dbo.MovConsumo([montoM3], [lecturaConsumo], [newM3Consumo], [idPropiedad], [idTipoMov],
											[fecha], [activo])
				VALUES (@montoM3, @lecturaMedidor, @newSaldoAcumulado, @idPropiedad, @idTipoMov, GETDATE(), 1);
				-- update informacion en propiedad --
				UPDATE dbo.[Propiedad] SET [m3Acumulados] = @newSaldoAcumulado WHERE [id] = @idPropiedad 
			COMMIT TRANSACTION
			END


	END TRY
	BEGIN CATCH
			DECLARE 
				@Message varchar(MAX) = ERROR_MESSAGE(),
				@Severity int = ERROR_SEVERITY(),
				@State smallint = ERROR_STATE()
 
		   RAISERROR( @Message, @Severity, @State) 
		   ROLLBACK TRANSACTION;
	END CATCH
END

DROP PROCEDURE  [dbo].[SPI_AjusteConsumo]

CREATE PROCEDURE [dbo].[SPI_AjusteConsumo_XML]
@numeroFinca bigInt,
@montoM3 int,
@fecha date
AS
BEGIN
	BEGIN TRY
		DECLARE @idPropiedad int, @m3AcumuladosPropiedad int, @lecturaMedidor int, @newSaldoAcumulado int , @estadoPropiedad int;
		DECLARE @retValue int, @idTipoMov int, @signoMonto int;

		IF(@montoM3 >= 0) BEGIN SET @signoMonto = 3 END
		ELSE BEGIN SET @signoMonto = 2 END

		SELECT @idPropiedad = [id] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @estadoPropiedad = P.[activo] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @m3AcumuladosPropiedad = [m3Acumulados] FROM dbo.Propiedad AS P WHERE P.[numeroFinca] = @numeroFinca;
		SELECT @idTipoMov = [id] FROM dbo.[TipoMov] AS M WHERE M.[codigo] = @signoMonto;

		-- @lecturaMedidor > @m3AcumuladosPropiedad (siempre
		SET @lecturaMedidor = (@m3AcumuladosPropiedad + @montoM3);
		SET @m3AcumuladosPropiedad = (@lecturaMedidor - @montoM3);
		SET @newSaldoAcumulado = (@m3AcumuladosPropiedad + @montoM3);

		-- INSERT DE TABLA MOVIMIENTO --
		IF(@idPropiedad is null OR @estadoPropiedad = 0)
			BEGIN
				RAISERROR('Propiedad no encontrada', 10, 1)
				SET	@retValue = -17;
			END
		-- Propiedad existe --	
		ELSE
			BEGIN
			BEGIN TRANSACTION
				-- insertar movimeinto en MovConsumo --
				INSERT INTO dbo.MovConsumo([montoM3], [lecturaConsumo], [newM3Consumo], [idPropiedad], [idTipoMov],
											[fecha], [activo])
				VALUES (@montoM3, @lecturaMedidor, @newSaldoAcumulado, @idPropiedad, @idTipoMov,@fecha, 1);
				-- update informacion en propiedad --
				UPDATE dbo.[Propiedad] SET [m3Acumulados] = @newSaldoAcumulado WHERE [id] = @idPropiedad 
			COMMIT TRANSACTION
			END


	END TRY
	BEGIN CATCH
			DECLARE 
				@Message varchar(MAX) = ERROR_MESSAGE(),
				@Severity int = ERROR_SEVERITY(),
				@State smallint = ERROR_STATE()
 
		   RAISERROR( @Message, @Severity, @State) 
		   ROLLBACK TRANSACTION;
	END CATCH
END

DROP PROCEDURE [dbo].[SPI_AjusteConsumo_XML]

CREATE PROCEDURE [dbo].[SPI_MovimientoAgua_XML]
@idNumber int,
@lecturM3 int,
@descripcion nvarchar(50),
@numFinca int,
@fecha date
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		IF (@idNumber = 1) EXECUTE [dbo].[SPI_Consumo_XML] @numFinca, @lecturM3, @fecha
		ELSE IF( @idNumber = 2) EXECUTE [dbo].[SPI_AjusteConsumo_XML] @numFinca, @lecturM3, @fecha;
		ELSE EXECUTE [dbo].[SPI_AjusteConsumo_XML] @numFinca, @lecturM3, @fecha; -- @idNumber = 3 --
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
			DECLARE 
				@Message varchar(MAX) = ERROR_MESSAGE(),
				@Severity int = ERROR_SEVERITY(),
				@State smallint = ERROR_STATE()
 
		   RAISERROR( @Message, @Severity, @State) 
		   ROLLBACK TRANSACTION;
	END CATCH
END




SELECT * FROM Propiedad
SELECT * FROM dbo.MovConsumo
EXECUTE [dbo].[SPI_Consumo] 460, 1025
EXECUTE [dbo].[SPI_Consumo] 460, 1050

EXECUTE [dbo].[SPI_AjusteConsumo] 458, -5
