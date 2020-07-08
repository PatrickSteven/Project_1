-- Trigger para tabla propiedad --
USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

CREATE TRIGGER TR_Propiedad_Insert
ON dbo.[Propiedad]
FOR INSERT
AS
BEGIN
	BEGIN TRY
		PRINT ('UPSI')
		DECLARE @tipoEntidad int = 1, @activo int = 1;
		DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
		-- Generate json --
		SET @jsonDespues = (
			SELECT P.[numeroFinca], P.[valor], P.[direccion], P.[m3Acumulados], P.[m3AcumuladosUR], P.[activo]
			FROM Propiedad AS P WHERE P.[id] IN (SELECT id FROM inserted) FOR JSON AUTO
		);
		-- Insert transaction --
		BEGIN TRANSACTION
			INSERT INTO Bitacora ([idTipoEntidad] , [idEntidad] , [jsonAntes], [jsonDespues], 
								  [insertedAt] , [insertedby], [insertedIn], [activo])
			VALUES (@tipoEntidad,@@IDENTITY, @jsonAntes, @jsonDespues, GETDATE(), 'Usuario', '192.168.1.152', @activo)
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

DROP TRIGGER TR_Propiedad_Insert

CREATE TRIGGER TR_Propiedad_Update
ON dbo.[Propiedad]
FOR UPDATE
AS
BEGIN
		BEGIN TRY
		PRINT ('HOLA MUNDO')
		-- Declaracion de variables --
		DECLARE @tipoEntidad int = 1, @activo int, @id int, @idI int;
		DECLARE @jsonDespues nvarchar(500), @jsonAntes nvarchar(500);
		-- Get valores de datos --
		SET @id = (SELECT id from deleted);
		SET @idI = (SELECT id from inserted);
		IF @idI is null print ('papu')
		IF @idI is null print ('papuletos')
		SELECT @activo = [activo] FROM dbo.Propiedad AS P WHERE P.[id] = @id;

		-- Case_01 : if activo = 0 se borro el dato --
		IF (@activo = 0)
			BEGIN 
				SET @jsonAntes = (
					SELECT P.[numeroFinca], P.[valor], P.[direccion], P.[m3Acumulados], P.[m3AcumuladosUR], P.[activo]
					FROM Propiedad AS P WHERE P.[id]  IN (SELECT id FROM inserted) FOR JSON AUTO
				);
			END
		-- Case_02 : if activo = 1 se updateo el dato --
		ELSE
			BEGIN
				SET @jsonAntes = (
					SELECT P.[numeroFinca], P.[valor], P.[direccion], P.[m3Acumulados], P.[m3AcumuladosUR], P.[activo]
					FROM Propiedad AS P WHERE P.[id]  IN (SELECT id FROM inserted) FOR JSON AUTO
				);
				SET @jsonDespues = (
					SELECT P.[numeroFinca], P.[valor], P.[direccion], P.[m3Acumulados], P.[m3AcumuladosUR], P.[activo]
					FROM Propiedad AS P WHERE P.[id]  IN (SELECT id FROM inserted) FOR JSON AUTO
				);
			END

		-- Insert transaction --
		BEGIN TRANSACTION
			IF @idI is null
				BEGIN 
					PRINT ('BRIOSH')
					INSERT INTO Bitacora ([idTipoEntidad] , [idEntidad] , [jsonAntes], [jsonDespues], 
					[insertedAt] , [insertedby], [insertedIn], [activo])
					VALUES (1, @id, @jsonAntes, @jsonDespues, GETDATE(), 'Usuario', '192.168.1.152', @activo)
					PRINT ('BRIOSH2')
				END
			ELSE
				BEGIN 
					PRINT ('TOSTADAS')
					INSERT INTO Bitacora ([idTipoEntidad] , [idEntidad] , [jsonAntes], [jsonDespues], 
					[insertedAt] , [insertedby], [insertedIn], [activo])
					VALUES (1, @id, @jsonAntes, @jsonDespues, GETDATE(), 'Usuario', '192.168.1.152', @activo)
					PRINT ('TOSTADAS2')
				END
				
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

-- Commandos del script extra --
DROP TRIGGER TR_Propiedad_Update
DROP TRIGGER TR_Propiedad_Insert

DELETE FROM dbo.Bitacora
SELECT * FROM dbo.Bitacora WHERE dbo.Bitacora.[idTipoEntidad] = 1