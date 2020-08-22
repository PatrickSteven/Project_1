select U.nombre, U.password, P.numeroFinca, CC.nombre 
from Usuario_de_Propiedad UP
join Usuario U On U.id = UP.idUsuario
join Propiedad P ON P.id = UP.idPropiedad 
join Recibo R ON R.idPropiedad = P.id
join Concepto_Cobro CC ON CC.id = R.idConceptoCobro
where R.estado = 0

--Sin usuarios
select P.numeroFinca, CC.nombre,  R.id
from Propiedad P
join Recibo R ON R.idPropiedad = P.id
join Concepto_Cobro CC ON CC.id = R.idConceptoCobro
where R.estado = 0


--Con usuarios
select P.numeroFinca, CC.nombre,  R.id, U.nombre, U.password
from Propiedad P
join Recibo R ON R.idPropiedad = P.id
join Concepto_Cobro CC ON CC.id = R.idConceptoCobro
join Usuario_de_Propiedad UP ON UP.idPropiedad = P.id
join Usuario U ON U.id = UP.idUsuario
where R.estado = 0

select * from MovimientosAP
select * from RecibosAP
select * from Recibo_por_ComprobantePago where idRecibo =18683
UPDATE Recibo SET estado = 0 where id = 18684