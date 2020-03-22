CREATE PROCEDURE dbo.SPS_Propietario
AS
BEGIN
select dbo.Propietario.nombre, dbo.Propietario.valorDocId, dbo.Tipo_DocId.nombre from dbo.Propietario
join dbo.Tipo_DocId on dbo.Propietario.idDocId = dbo.Tipo_DocId.id;
END

CREATE PROCEDURE dbo.SPS_Tipo_DocId
AS
BEGIN
select * from dbo.Tipo_DocId
END

select * from Tipo_DocId