-- Store procedure insert en bitacora --
USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

-- Insert en Bitacora --
-- Este insert es para procesos internos de la base de datos --

CREATE PROCEDURE dbo.[SPI_Bitacora]
@idTipoEntidad int,
@idEntidad int, 
@activo int,
@jsonDespues nvarchar(500),
@jsonAntes nvarchar(500)
AS
BEGIN
	BEGIN TRY
		-- Variables --
		DECLARE @retValue int = 1;
		DECLARE @inserteby nvarchar(50) = 'Usuario', @insertedIn nvarchar(50) = '192.168.1.152';
		-- INSERT --
		BEGIN TRANSACTION
			INSERT INTO Bitacora ([idTipoEntidad] , [idEntidad] , [jsonAntes], [jsonDespues], 
								[insertedAt] , [insertedby], [insertedIn], [activo])
			VALUES (@idTipoEntidad, @idEntidad, @jsonAntes, @jsonDespues, GETDATE(), 'Usuario', '192.168.1.152', @activo)
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		DECLARE 
			@Message varchar(MAX) = ERROR_MESSAGE(),
			@Severity int = ERROR_SEVERITY(),
			@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
		ROLLBACK TRANSACTION;
	END CATCH
END


CREATE PROCEDURE dbo.[SPS_Bitacora]
@idTipoEntidad int
AS
BEGIN 
	BEGIN TRY
		SElECT B.idEntidad, B.insertedAt, B.insertedby, B.insertedIn, ISNULL(B.jsonAntes,'') as jsonAntes, ISNULL(B.jsonDespues,'') as jsonDespues
		FROM Bitacora B
		WHERE B.activo = 1 and B.idTipoEntidad = @idTipoEntidad
		ORDER BY B.insertedAt DESC
	END TRY

	BEGIN CATCH
			DECLARE 
			@Message varchar(MAX) = ERROR_MESSAGE(),
			@Severity int = ERROR_SEVERITY(),
			@State smallint = ERROR_STATE()
		RAISERROR( @Message, @Severity, @State) 
	END CATCH
END
EXECUTE SPI_Usuario "admin", "admin", "Administrador"
SELECT * from Usuario
EXECUTE dbo.SPS_Bitacora 1
DROP PROCEDURE dbo.SPS_Bitacora
SELECT * FROM dbo.Bitacora WHERE dbo.Bitacora.[idTipoEntidad] = 1

9677981