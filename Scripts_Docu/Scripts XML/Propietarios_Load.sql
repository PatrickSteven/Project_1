USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO


--Este documento carga Varios-Propietarios (XML)
-- Orden de lectura del XML
--#1: codigoDoc (id)
--#2: descipcion (nombre)

DECLARE @x xml;
Select @x = XMLData FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\Varios.xml', SINGLE_BLOB) AS Products(XMLData);
	

DECLARE @hdoc int;
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

--Inserta la informacion que pertenece a Propietario 
INSERT INTO dbo.Propietario(nombre,idDocId,valorDocId)
SELECT * FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/Propietario', 0)
WITH(
		Nombre nvarchar(50),
		TipoDocIdentidad int,
		identificacion bigInt
	
)
UPDATE dbo.Propietario SET activo = 1;

SELECT * FROM dbo.Propietario;
SELECT * FROM dbo.Tipo_DocId;