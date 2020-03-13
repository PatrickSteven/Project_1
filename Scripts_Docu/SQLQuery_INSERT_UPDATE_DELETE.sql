USE TEST

CREATE TABLE Alumno(IdAlumno INT PRIMARY KEY NOT NULL IDENTITY(1,1),
					ApPaterno NVARCHAR(30),
					ApMaterno NVARCHAR(30),
					Nombre NVARCHAR(30))

CREATE TABLE Domicilio(	IdDomicilio INT PRIMARY KEY NOT NULL IDENTITY (1,1),
						IdAlumno INT CONSTRAINT FK_IdAlumno FOREIGN KEY (IdAlumno) REFERENCES Alumno(IdAlumno),
						Calle NVARCHAR(30))

--MALA PRACTICA
ALTER TABLE Alumno 
ADD	Email NVARCHAR(30);


INSERT INTO Alumno (ApPaterno,ApMaterno,Nombre)
VALUES('Martinez','Espinoza','Fernando'),
('Martinez','Torres','Carlos'),
('Martinez','Teran','Alfonso')

INSERT INTO Domicilio (IdAlumno,Calle) VALUES('1','Insurgente Sur')

UPDATE Alumno SET ApPaterno = 'Duran' WHERE IdAlumno = 2

DELETE FROM Alumno WHERE IdAlumno =1 --ERROR PORQUE ES UNA LLAVE FORANEA

SELECT * FROM Alumno
SELECT * FROM Domicilio