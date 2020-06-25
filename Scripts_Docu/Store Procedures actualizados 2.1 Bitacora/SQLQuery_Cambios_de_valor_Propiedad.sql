USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

CREATE PROC [dbo].[SPU_ValorPropiedad]
@PropiedadCambio PropiedadCambio READONLY
AS
BEGIN
	UPDATE Propiedad 
	SET [valor] = PC.nuevoValor
	FROM [dbo].[Propiedad]
	INNER JOIN @PropiedadCambio PC ON
	Propiedad.[numeroFinca] = PC.numFinca
END