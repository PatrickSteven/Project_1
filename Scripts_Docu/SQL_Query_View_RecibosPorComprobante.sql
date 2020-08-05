CREATE VIEW ViewReciboPorComprobante
AS 
	SELECT 
	CC.nombre, 
	CC.DiaDeCobro, 
	R.fecha,
	CC.tasaInteresesMoratorios,
	R.monto,
	RxC.tipoRecibo,
	R.fechaVencimiendo,
	R.id,
	R.activo,
	R.estado,
	RxC.fechaLeido,
	RxC.idComprobante_Pago,
	R.idPropiedad

	FROM dbo.[Recibo_por_ComprobantePago] RxC
	JOIN dbo.[Recibo] R ON RxC.idRecibo = R.id
	JOIN dbo.[Comprobante_Pago] CP ON RxC.idComprobante_Pago = CP.id 
	JOIN dbo.[Concepto_Cobro] CC ON R.idConceptoCobro = CC.id

