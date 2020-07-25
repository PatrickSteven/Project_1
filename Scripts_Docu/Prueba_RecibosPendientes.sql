select U.nombre, U.password, P.numeroFinca, CC.nombre 
from Usuario_de_Propiedad UP
join Usuario U On U.id = UP.idUsuario
join Propiedad P ON P.id = UP.idPropiedad 
join Recibo R ON R.idPropiedad = P.id
join Concepto_Cobro CC ON CC.id = R.idConceptoCobro
where R.estado = 0
select * from Recibo where estado = 0 and idConceptoCobro = 11

select P.numeroFinca, CC.nombre,  R.id
from Propiedad P
join Recibo R ON R.idPropiedad = P.id
join Concepto_Cobro CC ON CC.id = R.idConceptoCobro
where R.estado = 1 and CC.id = 12

select * from MovimientosAP
select * from RecibosAP
select * from Recibo_por_ComprobantePago where idRecibo =18683
UPDATE Recibo SET estado = 0 where id = 18684