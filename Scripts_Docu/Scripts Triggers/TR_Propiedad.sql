-- Trigger para tabla propiedad --
USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

CREATE TRIGGER TR_Propiedad_Insert
ON dbo.[Propiedad]
FOR INSERT
AS
print 'Hola soy el primer pendejo trigger de tu vida'