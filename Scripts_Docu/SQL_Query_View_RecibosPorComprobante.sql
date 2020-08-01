CREATE VIEW ReciboPorComprobante
AS 
SELECT 
CC.nombre 'Nombre',
CC.DiaDeCobro 'Dia de cobro',
R.fecha 'Fecha',
CC.tasaInteresesMoratorios 'Tasa intereses moratorios',
R.monto 'Monto', 
RxC.tipoRecibo 'Tipo de recibo', 
R.fechaVencimiendo 'Fecha vencimiento'

FROM dbo.[Recibo_por_ComprobantePago] RxC
JOIN dbo.[Recibo] R ON RxC.idRecibo = R.id
JOIN dbo.[Comprobante_Pago] CP ON RxC.idComprobante_Pago = CP.id 
JOIN dbo.[Concepto_Cobro] CC ON R.idConceptoCobro = CC.id

--Solo puede visualizar los recibos pagados
WHERE R.estado = 1 and R.activo = 1 


--Prueba
select * from ReciboPorComprobante
