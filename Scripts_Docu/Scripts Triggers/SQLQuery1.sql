-- Trigger para tabla propiedad --
USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

CREATE TRIGGER TR_Propiedad_Insert
ON dbo.[Propiedad]
FOR INSERT
AS
BEGIN
	DECLARE @Json nvarchar(500) = (
		SELECT P.[numeroFinca], P.[valor], P.[direccion]
		FROM Propiedad AS P FOR JSON AUTO
	);
	print @Json
	print 'Hola no se si sirvo'
END

CREATE TRIGGER TR_Propiedad_Update
ON dbo.[Propiedad]
FOR UPDATE
AS
BEGIN
	DECLARE @Json nvarchar(500) = (
		SELECT P.[numeroFinca], P.[valor], P.[direccion]
		FROM Propiedad AS P FOR JSON AUTO
	);
	print @Json
	print 'Hola no se si sirvo'
END

DROP TRIGGER TR_Propiedad_Insert