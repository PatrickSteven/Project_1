USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]

DECLARE @x xml;

Select @x = P
FROM OPENROWSET (BULK 'C:\Users\alega\Documents\GitHub\BD-Proyecto-1\XML\CC_Prueba.xml', SINGLE_BLOB) AS Products(P);

DECLARE @hdoc int;

EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

-- Prueba temporal
SELECT *
FROM OPENXML (@hdoc, '/note/conceptocobro', 1)
WITH(
		id int, 
		Nombre varchar(100),
		DiaCobro int, 
		QDiasVencimiento int,
		EsImpuesto varchar(10),
		EsRecurrente varchar(10),
		EsFijo varchar(10),  
		TipoCC varchar(100),
		Monto int, 
		ValorM3 int,
		ValorPorcentaje int)



SET IDENTITY_INSERT dbo.Concepto_Cobro ON
INSERT INTO dbo.Concepto_Cobro (  id, nombre, tasaInteresesMoratorios, qDiasVencidos )
SELECT *
FROM OPENXML (@hdoc, '/note/conceptocobro', 1)
WITH(
		id int, 
		Nombre varchar(100), 
		QDiasVencimiento int,
		ValorPorcentaje int)

SELECT * FROM dbo.Concepto_Cobro

EXEC sp_xml_removedocument @hdoc

SELECT @x