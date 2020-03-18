--Insert
CREATE PROCEDURE SPI_Recibos
@fecha date,
@fechaVencimiento date,
@monto int,
@esPendiente bit,
@nombreCC NVARCHAR(50),
@numeroFinca int,
@idComprobantePago int = null
AS
BEGIN
	DECLARE @idConceptoCobro int, @idPropiedad int;
	SELECT @idConceptoCobro = id from dbo.Concepto_Cobro WHERE nombre = @nombreCC
	SELECT @idPropiedad = id from dbo.Propiedad WHERE numeroFinca = @numeroFinca

	IF @idConceptoCobro is null OR @idPropiedad is null
		BEGIN
		RAISERROR('Propiedad o Concepto de Cobro no encontrado',10,1)
		END
	ELSE 
		INSERT INTO dbo.Recibos(fecha, fechaVencimiendo, monto, esPendiente, idConeceptoCobro, idPropiedad, idComprobanteDePago)
		VALUES(@fecha, @fechaVencimiento, @monto, @esPendiente, @idConceptoCobro, @idPropiedad, @idComprobantePago)
END

--Pagar
CREATE PROCEDURE SP_Pagar_Recibos
@id int,
@fecha date,
@total int
AS
BEGIN
	DECLARE @idPropiedad int, @idComprobantePago int
	SELECT @idPropiedad = idPropiedad from dbo.Recibos WHERE id = @id
	IF @id is null
		BEGIN
		RAISERROR('Recibo no encontrado',10,1)
		END
	ELSE 
		BEGIN
		EXECUTE @idComprobantePago = dbo.SPI_Comprobante_Pago @fecha, @total, @idPropiedad
		UPDATE dbo.Recibos SET esPendiente = 0, idComprobanteDePago = @idComprobantePago
		WHERE id = @id 
		END
END

--PRueba

EXECUTE SPI_Recibos '2020-05-19', '2020-06-19', 10000, 1, 'Electricidad', 0 
select * from Recibos
select * from Comprobante_Pago
EXECUTE SP_Pagar_Recibos 1, '2020-05-16', 10005
DROP PROCEDURE dbo.SP_Pagar_Recibos