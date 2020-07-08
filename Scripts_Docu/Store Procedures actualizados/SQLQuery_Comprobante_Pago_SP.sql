--Insert
CREATE PROCEDURE SPI_Comprobante_Pago_XML
@fecha date, 
@total int
AS 
BEGIN
	BEGIN TRY
		DECLARE @retValue int, @idPropiedad int, @estadoPropiedad int;
		DECLARE @activo int = 1;
	
		IF NOT EXISTS (SELECT * FROM dbo.Comprobante_Pago WHERE (fecha = @fecha AND total = @total))
			BEGIN
				INSERT INTO dbo.Comprobante_Pago(fecha, total, activo) VALUES(@fecha, @total, @activo)
				RETURN SET  @retValue = SCOPE_IDENTITY()
			END
		ELSE IF EXISTS(SELECT * FROM dbo.Comprobante_Pago WHERE (fecha = @fecha AND total = @total) AND dbo.Comprobante_Pago.activo = 0)
			BEGIN
				UPDATE dbo.Comprobante_Pago SET activo = 1 WHERE (fecha = @fecha AND total = @total);
				SET @retvalue = 1;
			END
		ELSE
			BEGIN
				RAISERROR('Comprobante ya registrado',10,1)
				SET  @retValue =  -11
			END
		RETURN @retValue
	END TRY
	BEGIN CATCH
		DECLARE 
			@Message varchar(MAX) = ERROR_MESSAGE(),
			@Severity int = ERROR_SEVERITY(),
			@State smallint = ERROR_STATE()
 
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE SPI_Comprobante_Pago_XML

-- INSERT NON-XML

CREATE PROCEDURE SPI_Comprobante_Pago
@total int
AS 
BEGIN
	BEGIN TRY
		DECLARE @retValue int, @fecha date = GETDATE(), @estadoPropiedad int;
		DECLARE @activo int = 1;
	
		IF NOT EXISTS (SELECT * FROM dbo.Comprobante_Pago WHERE (fecha = @fecha AND total = @total))
			BEGIN
				INSERT INTO dbo.Comprobante_Pago(fecha, total, activo) VALUES(@fecha, @total, @activo)
				RETURN SET  @retValue = SCOPE_IDENTITY()
			END
		ELSE IF EXISTS(SELECT * FROM dbo.Comprobante_Pago WHERE (fecha = @fecha AND total = @total) AND dbo.Comprobante_Pago.activo = 0)
			BEGIN
				UPDATE dbo.Comprobante_Pago SET activo = 1 WHERE (fecha = @fecha AND total = @total);
				SET @retvalue = 1;
			END
		ELSE
			BEGIN
				RAISERROR('Comprobante ya registrado',10,1)
				SET  @retValue =  -11
			END
		RETURN @retValue
	END TRY
	BEGIN CATCH
		DECLARE 
			@Message varchar(MAX) = ERROR_MESSAGE(),
			@Severity int = ERROR_SEVERITY(),
			@State smallint = ERROR_STATE()
 
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END

DROP PROCEDURE SPI_Comprobante_Pago

--Delete (Viejo)
CREATE PROCEDURE SPD_Comprobante_Pago
@idPropiedad int
AS
BEGIN TRY
	DECLARE @retValue int;
	IF EXISTS (SELECT * FROM dbo.Comprobante_Pago WHERE idPropiedad = @idPropiedad)
		BEGIN
			SET @retValue =  (SELECT id FROM dbo.Comprobante_Pago WHERE idPropiedad = @idPropiedad);
			DELETE FROM dbo.Comprobante_Pago WHERE idPropiedad = @idPropiedad
		END
	ELSE
		BEGIN
			RAISERROR('Numero de finca ya registrado', 10, 1)
			SET @retValue =  -14;
		END
	RETURN  @retValue;
END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
END CATCH

--Delete (Nuevo)
CREATE PROCEDURE SPD_Comprobante_Pago
@numeroFinca int
AS
BEGIN TRY
	DECLARE @retValue int, @idPropiedad int;
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca;
	IF EXISTS (SELECT * FROM dbo.Comprobante_Pago WHERE idPropiedad = @idPropiedad)
		BEGIN
			UPDATE dbo.Comprobante_Pago SET activo = 0 WHERE idPropiedad = @idPropiedad;
			SET @retValue =  1;
		END
	ELSE
		BEGIN
			RAISERROR('Numero de finca no registrado', 10, 1)
			SET @retValue =  -14;
		END
	RETURN  @retValue;
END TRY
BEGIN CATCH
	DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
 
	RAISERROR( @Message, @Severity, @State) 
END CATCH

--Prueba
DECLARE @id int
EXECUTE SPI_Comprobante_Pago_XML '2020-03-20', 100000
EXECUTE SPI_Comprobante_Pago 100001
EXECUTE SPD_Comprobante_Pago 456
PRINT @id
select * from Propiedad
select * from Comprobante_Pago
DROP PROCEDURE SPD_Comprobante_Pago