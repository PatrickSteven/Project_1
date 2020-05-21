USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

DECLARE @x xml;
Select @x = XMLData FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\Varios.xml', SINGLE_BLOB) AS Products(XMLData);
	

DECLARE @hdoc int;
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

--Inserta la informacion que pertenece a Tipo_DocId 
INSERT INTO dbo.Usuario(nombre,password)
SELECT * FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/Usuario', 0)
WITH(
		Nombre nvarchar(50),
		password nvarchar(50)
	
)
UPDATE dbo.Usuario SET tipoUsuario = 'Usuario' WHERE tipoUsuario IS NULL
UPDATE dbo.Usuario SET activo = 1;

SELECT * FROM dbo.Usuario;