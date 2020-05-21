USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

--Este documento carga Administradores (XML)
-- Orden de lectura del XML
--#1: codigoDoc (id)
--#2: descipcion (nombre)

DECLARE @x xml;
Select @x = XMLData FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\Administradores.xml', SINGLE_BLOB) AS Products(XMLData);
	

DECLARE @hdoc int;
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

--Inserta la informacion que pertenece a Tipo_DocId 
INSERT INTO dbo.Usuario(nombre,password)
SELECT * FROM OPENXML (@hdoc, '/Administrador/UsuarioAdmi', 0)
WITH(
		users varchar(50),
		password varchar(50)
	
)
UPDATE dbo.Usuario SET tipoUsuario = 'Administrador';
UPDATE dbo.Usuario SET activo = 1;

SELECT * FROM dbo.Usuario;
