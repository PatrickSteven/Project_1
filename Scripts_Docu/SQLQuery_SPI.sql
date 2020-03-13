USE TEST
GO
CREATE PROCEDURE SPIalumnos
@nombre VARCHAR(30),
@ApPaterno VARCHAR(30),
@ApMaterno VARCHAR(30),
@Email VARCHAR(30)
AS 
BEGIN
	INSERT INTO Alumno (Nombre, ApPaterno, ApMaterno, Email)
				VALUES (@nombre,@ApPaterno,@ApMaterno,@Email);
END

SELECT * FROM Alumno

EXEC SPIalumnos 'Roberto','Lopez','Hernandez','rlh@gmail.com'