--Insert
CREATE PROCEDURE SPI_Comprobante_Pago
@fecha date, 
@total int,
@idPropiedad int
AS 
BEGIN TRY
	DECLARE @retValue int;
	IF @idPropiedad is null
		BEGIN
			RAISERROR('Propiedad no encontrada',10,1)
			SET  @retValue =  -10
		END
	ELSE 
		BEGIN
			INSERT INTO dbo.Comprobante_Pago(fecha, total, idPropiedad) 
			VALUES(@fecha, @total, @idPropiedad)
			RETURN SET  @retValue = SCOPE_IDENTITY()
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

--Delete
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

--Prueba
DECLARE @id int
EXECUTE @id = SPI_Comprobante_Pago '2020-03-20', 100000, 2
PRINT @id
select * from Comprobante_Pago
DROP PROCEDURE SPI_Comprobante_Pago