USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

--DROPS para reconstruir clases

--DROP TABLE CC_en_Propiedad
--DROP TABLE Comprobante_de_Pago
--DROP TABLE Recibos
--DROP TABLE Propiedad_del_Propietario
--DROP TABLE Propietario;
--DROP TABLE Propietario_Juridico;
--DROP TABLE Tipo_DocId;

--Este documento carga TipoDocumentoIdentidad (XML)
-- Orden de lectura del XML
--#1: codigoDoc (id)
--#2: descipcion (nombre)
DELETE FROM dbo.[Tipo_DocId]

DECLARE @x xml;
DECLARE @xx xml;
Select @x = XMLData FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\TipoDocumentoIdentidad.xml', SINGLE_BLOB) AS Products(XMLData);
	

DECLARE @hdoc int;
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x
DELETE FROM dbo.[Tipo_DocId]
--Inserta la informacion que pertenece a Tipo_DocId 
INSERT INTO dbo.Tipo_DocId(codigoDoc,nombre, fechaInicio, activo)
SELECT [codigoDoc], [descripcion], GETDATE(), 1
FROM OPENXML (@hdoc, '/TipoDocIdentidad/TipoDocId', 0)
WITH(
		codigoDoc int,
		descripcion varchar(100)
	
)

SELECT * FROM dbo.Tipo_DocId;

