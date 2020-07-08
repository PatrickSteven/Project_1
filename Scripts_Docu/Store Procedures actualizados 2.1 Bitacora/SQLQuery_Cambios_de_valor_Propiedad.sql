USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

-- SP MASIVO ITERATIVO POR LA BITACORA --
CREATE PROC [dbo].[SPU_ValorPropiedad]
@numFinca int,
@nuevoValor money
AS 
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE Propiedad 
			SET [valor] = @nuevoValor
			FROM [dbo].[Propiedad]
			WHERE Propiedad.[numeroFinca] = @numFinca
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE 
			@Message varchar(MAX) = ERROR_MESSAGE(),
			@Severity int = ERROR_SEVERITY(),
			@State smallint = ERROR_STATE()
 
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END



-- PROCESO MASIVO PERO NO SIRVE CON BITACOTA --
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

DROP PROCEDURE [dbo].[SPU_ValorPropiedad]