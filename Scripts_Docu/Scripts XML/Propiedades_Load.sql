USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

--DROP TABLE CC_en_Propiedad
--DROP TABLE Comprobante_de_Pago
--DROP TABLE Recibos
--DROP TABLE Comprobante_Pago
--DROP TABLE Propiedad_del_Propietario 
--DROP TABLE Propiedad;

--Este documento carga Varios-Propiedades (XML)
-- Orden de lectura del XML
--#1: codigoDoc (id)
--#2: descipcion (nombre)

DECLARE @x xml;
Select @x = XMLData FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\Varios.xml', SINGLE_BLOB) AS Products(XMLData);
	

DECLARE @hdoc int;
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

--Inserta la informacion que pertenece a Tipo_DocId 
INSERT INTO dbo.Propiedad(numeroFinca,valor,direccion)
SELECT * FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/Propiedad', 0)
WITH(
		NumFinca int,
		Valor int,
		Direccion nvarchar(50)
	
)
UPDATE dbo.Propiedad SET activo = 1;

SELECT * FROM dbo.Propiedad;