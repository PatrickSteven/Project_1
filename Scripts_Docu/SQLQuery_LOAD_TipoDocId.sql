USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]

DECLARE @x xml;

Select @x = P
FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\TipoDocID_Prueba.xml', SINGLE_BLOB) AS Products(P);

DECLARE @hdoc int;

EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

SELECT *
FROM OPENXML (@hdoc, '/note/TipoDoc', 1)
WITH(
		IdcodigoDoc int, 
		descripcion varchar(100))

SET IDENTITY_INSERT dbo.Tipo_DocId ON
INSERT INTO dbo.Tipo_DocId (  id, nombre )
SELECT *
FROM OPENXML (@hdoc, '/note/TipoDoc', 1)
WITH(
		IdcodigoDoc int, 
		descripcion varchar(100))
SELECT * FROM dbo.Tipo_DocId

EXEC sp_xml_removedocument @hdoc

SELECT @x