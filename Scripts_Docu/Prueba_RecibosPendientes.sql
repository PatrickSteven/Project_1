select U.nombre, U.password, P.numeroFinca, CC.nombre 
from Usuario_de_Propiedad UP
join Usuario U On U.id = UP.idUsuario
join Propiedad P ON P.id = UP.idPropiedad 
join Recibo R ON R.idPropiedad = P.id
join Concepto_Cobro CC ON CC.id = R.idConceptoCobro
where R.estado = 0

select * from Recibo where estado = 0 and idConceptoCobro = 11

select P.numeroFinca, CC.nombre 
from Propiedad P
join Recibo R ON R.idPropiedad = P.id
join Concepto_Cobro CC ON CC.id = R.idConceptoCobro
where R.estado = 0

select * from AP
select * from Comprobante_Pago where id = 6186


select * from Recibo_por_ComprobantePago