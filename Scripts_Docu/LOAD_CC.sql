USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

--Este documento carga Concepto de Cobro (XML)
-- Orden de lectura del XML
-- #1: id (int)
-- #2: Nombre (nvarchar(50))
-- #3: DiaCobro (int)
-- #4: QDiasVencimiento (int)
-- #5: EsImpuesto (nvarchar(10))
-- #6: EsRecurrente (nvarchar(10))
-- #7: esFijo (nvarchar(10))
-- #8: TasaDeInteresMoratorio (int)

-- Dependiendo de TipoCC
-- #1: Monto (int)
-- #1: ValorM3 (int)
-- #1: ValorPorcentaje (int) -> no se a que clase pertenece

DECLARE @x xml;
Select @x = XMLData FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\Concepto_de_Cobro.xml', SINGLE_BLOB) AS Products(XMLData);

DECLARE @hdoc int;
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

--Inserta la informacion que pertenece a Concepto_Cobro (sin la herencia, todavia)
INSERT INTO dbo.Concepto_Cobro(id, nombre, DiaDeCobro, qDiasVencidos, EsImpuesto, EsRecurrente, EsFijo, tasaInteresesMoratorios)
SELECT * FROM OPENXML (@hdoc, '/Conceptos_de_Cobro/conceptocobro', 0)
WITH(
		id int, 
		Nombre varchar(100), 
		DiaCobro int,
		QDiasVencimiento int,
		EsImpuesto varchar(10),
		EsRecurrente varchar(10),
		EsFijo varchar(10),
		TasaInteresMoratoria float
)
UPDATE dbo.Concepto_Cobro SET activo = 1;

--Inserta la informacion que pertenece a CC_Fijo (con la herencia a Concepto_Cobro)
INSERT INTO dbo.CC_Fijo ( id,Monto,valor)
SELECT id,monto,valorporcentaje  FROM OPENXML (@hdoc, '/Conceptos_de_Cobro/conceptocobro', 0)
WITH(	
		id int,
		Monto int,
		ValorPorcentaje float,
		TipoCC varchar(50)
)
WHERE TipoCC = 'CC Fijo';
UPDATE dbo.CC_Fijo SET activo = 1;


--Inserta la informacion que pertenece a CC_Consumo (con la herencia a Concepto_Cobro)
INSERT INTO dbo.CC_Consumo ( id,monto, valorM3)
SELECT id,monto,valorM3 FROM OPENXML (@hdoc, '/Conceptos_de_Cobro/conceptocobro', 0)
WITH(	
		id int,
		Monto int,
		ValorM3 int,
		TipoCC varchar(50)
)
WHERE TipoCC = 'CC Consumo';
UPDATE dbo.CC_Consumo SET activo = 1;

--Inserta la informacion que pertenece a CC_Intereses_Moratorios (con la herencia a Concepto_Cobro)
INSERT INTO dbo.CC_Intereses_Moratorios (id)
SELECT id FROM OPENXML (@hdoc, 'Conceptos_de_Cobro/conceptocobro', 0)
WITH(	
		id int,
		TipoCC varchar(50)
)
WHERE TipoCC = 'CC Intereses Moratorios';
UPDATE dbo.CC_Intereses_Moratorios SET activo = 1;



SELECT * FROM dbo.Concepto_Cobro
SELECT * FROM dbo.CC_Fijo
SELECT * FROM dbo.CC_Consumo
DROP TABLE dbo.CC_Consumo
DROP TABLE dbo.CC_Intereses_Moratorios
DROP TABLE dbo.CC_Fijo
DROP TABLE dbo.Concepto_Cobro_en_Propiedad
DROP TABLE Concepto_Cobro