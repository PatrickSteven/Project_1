USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

--Entrada: Numero de Finca, Valor de la Propiedad, Direccion de la propiedad --
--Salida Exitosa: El id de la ultima Propiedad agregada --
--Salida Fallida: Codigo de error [-13] --
--Descripcion: Inserta una propiedad si esa propiedad no se ha insertado --

--Insert Actualizado --
CREATE PROCEDURE dbo.[SPI_Propiedad]
@numeroFinca int,
@valor money,
@direccion VARCHAR(50)
AS 
BEGIN TRY
	DECLARE @retValue int = 1, @activo int = 1;

	IF NOT EXISTS (SELECT * FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca)
		BEGIN
			-- Begin transaction --
			BEGIN TRANSACTION
				INSERT INTO Propiedad ([numeroFinca], [valor], [direccion] , [activo], [fechaLeido], [m3Acumulados], [m3AcumuladosUR]) 
				VALUES (@numeroFinca,@valor,@direccion,@activo, GETDATE(), 0 ,0);
				SET @retValue = SCOPE_IDENTITY();
			COMMIT TRANSACTION
		END
	ELSE IF EXISTS(SELECT * FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca AND P.[activo] = 0)
		BEGIN
			-- Begin transaction --
			BEGIN TRANSACTION propiedad;
				UPDATE dbo.Propiedad SET activo = 1 WHERE numeroFinca = @numeroFinca;
				EXECUTE SPU_Propiedad @numeroFinca, @valor, @direccion;
				SET @retvalue = 1;
			COMMIT TRANSACTION propiedad;
		END
	ELSE
		BEGIN
			RAISERROR('Numero de finca ya registrado', 10, 1)
			SET @retValue = -13;
		END
	RETURN  @retValue;
END TRY 
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
	ROLLBACK TRANSACTION;
END CATCH

DROP PROCEDURE [SPI_Propiedad]


CREATE PROCEDURE dbo.[SPI_Propiedad_XML]
@numeroFinca int,
@valor money,
@direccion VARCHAR(50),
@fecha date
AS 
BEGIN TRY
	DECLARE @retValue int = 1, @activo int = 1;

	IF NOT EXISTS (SELECT * FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca)
		BEGIN
			-- Transaction --
			BEGIN TRANSACTION
				INSERT INTO Propiedad ([numeroFinca], [valor], [direccion] , [activo], [fechaLeido], [m3Acumulados], [m3AcumuladosUR]) 
				VALUES (@numeroFinca,@valor,@direccion,@activo, @fecha, 0 ,0);
				SET @retValue = SCOPE_IDENTITY();
			COMMIT TRANSACTION
		END
	ELSE IF EXISTS(SELECT * FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca AND P.[activo] = 0)
		BEGIN
			-- Transaction --
			BEGIN TRANSACTION
				UPDATE dbo.Propiedad SET activo = 1 WHERE numeroFinca = @numeroFinca;
				EXECUTE SPU_Propiedad @numeroFinca, @valor, @direccion;
				SET @retvalue = 1;
			COMMIT TRANSACTION
		END
	ELSE
		BEGIN
			RAISERROR('Numero de finca ya registrado', 10, 1)
			SET @retValue = -13;
		END
	RETURN  @retValue;
END TRY 
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State)
	ROLLBACK TRANSACTION;
END CATCH

DROP PROCEDURE dbo.[SPI_Propiedad_XML]





--Entrada: Numero de Finca
--Salida Exitosa: Valor de retorno del id del elemento eliminado
--Salida Fallida: Codigo de error [-14]
--Descripcion: Elimina una propiedad
--Cascada:
-- Propiedad_del_Propietario : Borra la relacion entre propiedad y propietario
-- Recibos: Borra los recibos de una propiedad
-- Comprobante_de_Pago: Borra los comprobantes de pago de una propiedad
-- CC_en_Propiedad: Borra los comporbantes de pago con esa propiedad
-- Usuario_de_Propiedad: 

--Delete Nuevo (Actualizado)
CREATE PROCEDURE dbo.[SPD_Propiedad]
@numeroFinca BIGINT 
AS
BEGIN 
	BEGIN TRY
		DECLARE @retValue1 int, @idPropiedad int
		-- tabla temporal para manejar valores de retorno no deseados --
		DECLARE @tmpNewValue TABLE (newvalue int);
		IF EXISTS (SELECT  * FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca )
			BEGIN
				BEGIN TRANSACTION
					SELECT @idPropiedad = id FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca
					INSERT INTO @tmpNewValue  EXEC dbo.SPD_Propiedad_Del_Propietario @idPropiedad
					--INSERT INTO @tmpNewValue  EXEC dbo.SPD_Comprobante_Pago @idPropiedad
					INSERT INTO @tmpNewValue  EXEC dbo.SPD_Concepto_De_Cobro_En_Propiedad @numeroFinca
					INSERT INTO @tmpNewValue  EXEC dbo.[SPD_Usuario_De_Propiedad] null, @numeroFinca
					UPDATE dbo.[Propiedad] SET activo = 0 WHERE numeroFinca = @numeroFinca;
					-- PRINT @retValue1
					SET @retValue1 =  (SELECT [id] FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca);		
					SET @retValue1 = 1; -- success --
				COMMIT TRANSACTION
			END
		ELSE
			BEGIN
				RAISERROR('Propiedad no registrado en la base de datos', 10, 1)
				SET @retValue1 = -14;
			END
		RETURN @retValue1
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

DROP PROCEDURE [SPD_Propiedad]

-- UPDATE Actualizado
CREATE PROCEDURE SPU_Propiedad
@numeroFinca int,
@valor int,
@direccion VARCHAR(50)
AS
BEGIN TRY
	DECLARE @retValue1 int = 1;
	IF EXISTS (SELECT  * FROM dbo.[Propiedad] AS P WHERE P.[numeroFinca] = @numeroFinca )
		BEGIN
			BEGIN TRANSACTION
				UPDATE Propiedad
				SET [valor] = @valor, [direccion] = @direccion WHERE [numeroFinca] = @numeroFinca
			COMMIT TRANSACTION
		END
	ELSE
		BEGIN
			RAISERROR('Propiedad no registrado en la base de datos', 10, 1)
			SET @retValue1 = -14;
		END
	RETURN @retValue1
END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
	ROLLBACK TRANSACTION;
END CATCH

DROP PROCEDURE SPU_Propiedad

-- SELECT Actualizado
CREATE PROCEDURE [dbo].[SPS_Propiedad]
AS 
BEGIN
	SELECT [numeroFinca] 'Numero de Finca' , [valor] 'Valor' , [direccion] 'Direccion'
	FROM Propiedad AS P WHERE P.[activo] = 1;

END

CREATE PROCEDURE [dbo].[SPS_Propiedad_Detail]
@numeroFinca int
AS
BEGIN
	SELECT [numeroFinca] , [valor] ,[direccion]
	FROM Propiedad AS P WHERE P.[numeroFinca] = @numeroFinca;
END


--- PRUEBAS DE LOS STATE PROCEDURES
SELECT * FROM Propiedad
EXEC SPI_Propiedad '126944','120.00','Upala'

SELECT * FROM Propiedad
EXEC SPD_Propiedad 126944

SELECT * FROM Propiedad

EXEC SPU_Propiedad '1244' ,'500','Upala'
EXEC [dbo].[SPU_ValorPropiedad] '126344' ,'500'

SELECT * FROM Propiedad
EXEC SPS_Propiedad

EXEC SPS_Propiedad_Detail 456

