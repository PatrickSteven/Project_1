USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

--Este documento carga Concepto_de_Cobro (XML)
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

DELETE FROM  dbo.CC_Fijo
DELETE FROM  dbo.CC_Consumo
DELETE FROM  dbo.CC_Porcentual
DELETE FROM dbo.[Concepto_Cobro]

DECLARE @x xml;
Select @x = XMLData FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\Concepto_de_Cobro.xml', SINGLE_BLOB) AS Products(XMLData);

DECLARE @hdoc int;
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

--Inserta la informacion que pertenece a Concepto_Cobro (sin la herencia, todavia)
INSERT INTO dbo.[Concepto_Cobro] ([id], [nombre], [DiaDeCobro], [qDiasVencidos], [EsImpuesto], [EsRecurrente], [EsFijo], [tasaInteresesMoratorios],[fechaInicio], [activo] )
--Insertar con activo == 1
SELECT [id], [Nombre], [DiaCobro], [QDiasVencimiento], [EsImpuesto], [EsRecurrente], [EsFijo], [TasaInteresMoratoria], GETDATE(), 1
FROM OPENXML (@hdoc, '/Conceptos_de_Cobro/conceptocobro', 0)
WITH(
		[id] int, 
		[Nombre] varchar(100), 
		[DiaCobro] int,
		[QDiasVencimiento] int,
		[EsImpuesto] varchar(10),
		[EsRecurrente] varchar(10),
		[EsFijo] varchar(10),
		[TasaInteresMoratoria] float
)


DELETE FROM dbo.[CC_Fijo]
--Inserta la informacion que pertenece a CC_Fijo (con la herencia a Concepto_Cobro)
INSERT INTO dbo.[CC_Fijo] ( [id] ,[Monto] ,[valor],[fechaInicio], [activo])
SELECT [id] , [Monto] , [ValorPorcentaje], GETDATE(), 1 
FROM OPENXML (@hdoc, '/Conceptos_de_Cobro/conceptocobro', 0)
WITH(	
		[id] int,
		[Monto] int,
		[ValorPorcentaje] float,
		[TipoCC] varchar(50)
)
--Pregunta por el tipo de dato para saber la tabla a la que inserta
WHERE TipoCC = 'CC Fijo';


DELETE FROM dbo.[CC_Consumo]
--Inserta la informacion que pertenece a CC_Consumo (con la herencia a Concepto_Cobro)
INSERT INTO dbo.[CC_Consumo] ( [id] ,[monto] , [valorM3],[fechaInicio], [activo])
SELECT [id], [Monto] ,[ValorM3], GETDATE(), 1
FROM OPENXML (@hdoc, '/Conceptos_de_Cobro/conceptocobro', 0)
WITH(	
		[id] int,
		[Monto] int,
		[ValorM3] int,
		[TipoCC] varchar(50)
)
--Pregunta por el tipo de dato para saber la tabla a la que inserta
WHERE TipoCC = 'CC Consumo';

DELETE FROM dbo.[CC_Intereses_Moratorios]
--Inserta la informacion que pertenece a CC_Intereses_Moratorios (con la herencia a Concepto_Cobro)
INSERT INTO dbo.[CC_Intereses_Moratorios] ([id],[fechaInicio], [activo])
SELECT [id], GETDATE(), 1 
FROM OPENXML (@hdoc, 'Conceptos_de_Cobro/conceptocobro', 0)
WITH(	
		id int,
		TipoCC varchar(50)
)
--Pregunta por el tipo de dato para saber la tabla a la que inserta
WHERE TipoCC = 'CC Intereses Moratorios';

DELETE FROM dbo.[CC_Porcentual]
--Inserta la informacion que pertenece a CC_Intereses_Moratorios (con la herencia a Concepto_Cobro)
INSERT INTO dbo.[CC_Porcentual] ([id],[ValorPorcentaje] ,[fechaInicio], [activo])
SELECT [id], [ValorPorcentaje] ,GETDATE(), 1 
FROM OPENXML (@hdoc, 'Conceptos_de_Cobro/conceptocobro', 0)
WITH(	
		[id] int,
		[ValorPorcentaje] float,
		[TipoCC] varchar(50)
)
--Pregunta por el tipo de dato para saber la tabla a la que inserta
WHERE TipoCC = 'CC Porcentual';



SELECT * FROM dbo.Concepto_Cobro
SELECT * FROM dbo.CC_Fijo
SELECT * FROM dbo.CC_Consumo
SELECT * FROM dbo.CC_Porcentual