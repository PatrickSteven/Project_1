USE [TEST]
GO 
CREATE PROCEDURE [dbo].[SPUalumnos]
@idAlumno BIGINT,
@nombre VARCHAR(30),
@apPaterno VARCHAR(30),
@apMaterno VARCHAR(30),
@email VARCHAR(30)
AS
BEGIN
UPDATE Alumno
	SET Nombre = @nombre,
		ApPaterno = @apPaterno,
		ApMaterno = @apMaterno,
		Email = @email
	WHERE IdAlumno = @idAlumno
END

SELECT * FROM Alumno
EXEC SPUalumnos 2, 'Jose Ramiro','Lopez','Cruz','jrm@hotmail.com'