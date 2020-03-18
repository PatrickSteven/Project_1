USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]

DECLARE @x xml;
DECLARE @tipoCC varchar(20);

Select @x = P
FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\CC_Prueba.xml', SINGLE_BLOB) AS Products(P);

DECLARE @hdoc int;

EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

SET IDENTITY_INSERT dbo.Concepto_Cobro ON
INSERT INTO dbo.Concepto_Cobro (  id, nombre, DiaCobro, qDiasVencidos, EsImpuesto, EsRecurrente, EsFijo)
SELECT *
FROM OPENXML (@hdoc, '/note/conceptocobro', 1)
WITH(
		id int, 
		Nombre varchar(100), 
		DiaCobro int,
		QDiasVencimiento int,
		EsImpuesto varchar(10),
		EsRecurrente varchar(10),
		EsFijo varchar(10))



INSERT INTO dbo.CC_Fijo ( id,Monto)
SELECT id,monto
FROM OPENXML (@hdoc, '/note/conceptocobro', 1)
WITH(	id int,
		Monto int,
		TipoCC varchar(50))
WHERE TipoCC = 'CC Fijo';

INSERT INTO dbo.CC_Consumo ( id,valor)
SELECT id,ValorM3
FROM OPENXML (@hdoc, '/note/conceptocobro', 1)
WITH(	id int,
		ValorM3 int,
		TipoCC varchar(50))
WHERE TipoCC = 'CC Consumo';

INSERT INTO dbo.CC_Intereses_Moratorios (id)
SELECT id
FROM OPENXML (@hdoc, '/note/conceptocobro', 1)
WITH(	id int,
		TipoCC varchar(50))
WHERE TipoCC = 'CC Intereses Moratorios';


SELECT * FROM Concepto_Cobro;
SELECT * FROM dbo.CC_Fijo;
SELECT * FROM dbo.CC_Consumo;




