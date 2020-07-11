CREATE PROCEDURE Generar_Comprobante
@idRecibo int,
@fecha date,
@montoAcumulado int = null
AS
BEGIN TRY
	DECLARE @monto int, @estado int, @retValue int;

	IF(@montoAcumulado IS NULL)
		BEGIN 
			SELECT @monto = monto from dbo.[Recibo] AS R WHERE R.[id] = @idRecibo;
		END
	ELSE
		BEGIN 
			SELECT @monto = @montoAcumulado
		END
	
	SELECT @estado = estado FROM dbo.[Recibo] AS R WHERE R.[id] = @idRecibo; 

	-- #1 Recibo nulo --
	IF(@idRecibo is null)
		BEGIN
			RAISERROR('Recibo nulo',10,1)
			SET @retValue = -25;
		END
	-- #1 Recibo ya existe --
	IF EXISTS(SELECT [id] FROM dbo.Recibo_por_ComprobantePago AS RC WHERE @idRecibo = RC.idRecibo)
		BEGIN
			RAISERROR('Recibo ya registrado',10,1)
			SET @retValue = -26;
		END
	-- #3 Recibo no existe y Comprobante existe--
	ELSE IF EXISTS(SELECT [id] FROM dbo.Comprobante_Pago AS CP WHERE (@fecha = CP.fecha AND @monto = CP.total))
		BEGIN
			BEGIN TRANSACTION
				DECLARE @idComprobante int;
				SELECT @idComprobante = [id] FROM dbo.Comprobante_Pago AS CP WHERE (CP.total = @monto AND CP.fecha = @fecha)

				INSERT INTO dbo.Recibo_por_ComprobantePago ([fechaLeido], [idRecibo], [idComprobante_Pago],[activo]) 
				VALUES(@fecha, @idRecibo, @idComprobante, 1)
				SET @retValue = SCOPE_IDENTITY();
				-- Activo = 0 porque se paga el recibo --
				UPDATE dbo.Recibo SET estado = 1 WHERE [id] = @idRecibo;
			COMMIT TRANSACTION
		END
	-- #4 Recibo no existe y Comprobante no existe--
	ELSE
		BEGIN
			BEGIN TRANSACTION
				-- Crear un nuevo comprobante de pago
				EXEC dbo.SPI_Comprobante_Pago_XML @fecha, @monto
				-- Insertar recibo en comprobante de pago
				INSERT INTO dbo.Recibo_por_ComprobantePago ([fechaLeido], [idRecibo], [idComprobante_Pago],[activo]) 
				VALUES(@fecha, @idRecibo, @@IDENTITY, 1)
				SET @retValue = SCOPE_IDENTITY();
				-- Activo = 0 porque se paga el recibo --
				UPDATE dbo.Recibo SET estado = 1 WHERE [id] = @idRecibo;
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


CREATE PROCEDURE SPS_ComprobanteDePago
@numeroFinca int,
@nombreConceptoCobro varchar(30) -- idConceptoCobro --
AS 
BEGIN
	BEGIN TRY
		DECLARE @idPropiedad int, @idConceptoCobro int
		-- Obtener id's --
		SELECT @idPropiedad = id FROM dbo.[Propiedad] WHERE numeroFinca = @numeroFinca and activo = 1
		SELECT @idConceptoCobro = id FROM dbo.[Concepto_Cobro] WHERE nombre = @nombreConceptoCobro and activo = 1

		-- Consulta principal ---
		SELECT DISTINCT(CP.id), CP.fecha, CP.total
		FROM dbo.[Recibo] R
		JOIN dbo.[Recibo_por_ComprobantePago] RCP ON R.id = RCP.idRecibo
		JOIN dbo.[Comprobante_Pago] CP ON RCP.idComprobante_Pago = CP.id
		WHERE R.idPropiedad = @idPropiedad and R.idConceptoCobro = @idConceptoCobro and R.estado = 1 and R.activo = 1

	END TRY
	BEGIN CATCH
		DECLARE 
		@Message varchar(MAX) = ERROR_MESSAGE(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END




select * from Recibo_por_ComprobantePago
select * from Recibo where id = 22265
select * from Propiedad where id = 11942
EXECUTE SPS_ComprobanteDePago 4158692, "Mantenimiento de Parques"
select * from Concepto_Cobro where id = 5


DROP PROCEDURE Generar_Comprobante


--- PRUEBAS DEL STATE PROCEDURE --

SELECT * FROM Recibo
EXECUTE Generar_Comprobante 22271, '2020-03-21', 5000

SELECT * FROM dbo.Comprobante_Pago 
SELECT * FROM dbo.Recibo_por_ComprobantePago AS RC WHERE RC.[idRecibo] = 22271
