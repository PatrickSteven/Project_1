--Insert
CREATE PROCEDURE SPI_Comprobante_Pago
@fecha date, 
@total int,
@idPropiedad int
AS 
BEGIN
	IF @idPropiedad is null
		BEGIN
		RAISERROR('Propiedad no encontrada',10,1)
		RETURN -10
		END
	ELSE 
		BEGIN
		INSERT INTO dbo.Comprobante_Pago(fecha, total, idPropiedad) 
		VALUES(@fecha, @total, @idPropiedad)
		RETURN SCOPE_IDENTITY()
		END
END


--Prueba
DECLARE @id int
EXECUTE @id = SPI_Comprobante_Pago '2020-03-20', 100000, 2
PRINT @id
select * from Comprobante_Pago
DROP PROCEDURE SPI_Comprobante_Pago