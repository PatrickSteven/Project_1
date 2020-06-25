-- GENERAR RECIBOS --
CREATE PROCEDURE SPI_GenerarRecibos
@fecha date
AS
BEGIN
	-- TABLAS TEMPORALES --
	DECLARE @ConceptoCobro_DeDia table (id INT IDENTITY(1,1),idPropiedad int,idConcptoCobro int) 
	
	-- GET DIA DE FECHA --
	DECLARE @dia int;
	SET @dia = DAY(@fecha);

	-- INSERTAR FILAS DE @ConceptoCobro_DeDia --
	INSERT INTO @ConceptoCobro_DeDia([idPropiedad], [idConcptoCobro])
	SELECT Propiedad.[id], Concepto_Cobro.[id] FROM dbo.[Concepto_Cobro_en_Propiedad]
	INNER JOIN Propiedad ON [idPropiedad] = Propiedad.[id]
	INNER JOIN Concepto_Cobro ON [idConeceptoCobro] = Concepto_Cobro.[id]
	WHERE (Concepto_Cobro.[DiaDeCobro] = @dia)

	SELECT * FROM @ConceptoCobro_DeDia;

	-- ITERACION MASIVA PARA GENERAR RECIBOS --
	IF EXISTS(SELECT [id] FROM @ConceptoCobro_DeDia)
		BEGIN
			DECLARE @idPropiedad int, @idConceptoCobro int, @id int = 1;
			WHILE @id IS NOT NULL
					BEGIN
						SELECT @idPropiedad = T.[idPropiedad], @idConceptoCobro = T.[idConcptoCobro]
						FROM @ConceptoCobro_DeDia AS T WHERE T.[id] = @id;

						EXEC dbo.SPI_Recibos @idConceptoCobro, @idPropiedad, @fecha;

						SELECT @id = MIN(id) FROM @ConceptoCobro_DeDia WHERE id > @id;
					END
				-- al terminar el dia hay que borrar los datos --
				 DELETE FROM @ConceptoCobro_DeDia
		 END



END

DROP PROCEDURE SPI_GenerarRecibos

















--Insert
CREATE PROCEDURE SPI_Recibos
@idConceptoCobro int,
@idPropiedad int,
@fechaGenerado date
AS
BEGIN
	-- DATOS CONCEPTO DE COBRO ( y herencias )--
	DECLARE @qDiaVencimiento int, @monto int, @esFijo varchar(10), @retValue int;
	-- DATOS CALCULADOS PARA RECIBO --
	DECLARE @fechaVencimineto date; 

	SELECT @qDiaVencimiento = [qDiasVencidos] FROM dbo.[Concepto_Cobro] WHERE @idConceptoCobro = [id];
	SELECT @esFijo = [EsFijo] FROM dbo.[Concepto_Cobro] WHERE @idConceptoCobro = [id];
	
	-- GET ID DE HERENCIA --
	IF ( @esFijo = 'Si')
		BEGIN
			SELECT @monto = [monto] FROM dbo.[CC_Fijo] WHERE @idConceptoCobro = [id];
		END
	-- ES CONSUMO --
	ELSE
		BEGIN
			SELECT @monto = [monto] FROM dbo.[CC_Consumo] WHERE @idConceptoCobro = [id];
		END
	
	-- CALULAR LA FECHA DE VENCIMIENTO --
	SELECT @fechaVencimineto = DATEADD(day, @qDiaVencimiento, @fechaGenerado);

	INSERT INTO dbo.Recibo ([idPropiedad], [idConceptoCobro], [monto], [fecha], [fechaVencimiendo], 
							[estado], [activo])
	VALUES(@idPropiedad, @idConceptoCobro, @monto, @fechaGenerado, @fechaVencimineto, 0, 1);
	SET @retValue = SCOPE_IDENTITY();




END

DROP PROCEDURE SPI_Recibos


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

--Delete
CREATE PROCEDURE SPD_Recibos
@idPropiedad int
AS
BEGIN
	DELETE FROM dbo.Recibos WHERE idPropiedad = @idPropiedad
END

--Select


--PRueba

EXECUTE SPI_Recibos 4,4,'2020-05-19'
EXECUTE SPI_GenerarRecibos '2020-06-1'
select * from dbo.[Recibo]
select * from Comprobante_Pago
EXECUTE SP_Pagar_Recibos 1, '2020-05-16', 10005
DROP PROCEDURE dbo.SP_Pagar_Recibos