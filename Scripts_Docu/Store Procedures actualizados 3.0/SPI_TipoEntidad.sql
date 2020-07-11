USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

DROP TABLE Bitacora;
DROP TABLE TipoEntidad;

INSERT INTO TipoEntidad([codigo], [nombre] )
VALUES (1, 'Propiedad')

INSERT INTO TipoEntidad([codigo], [nombre] )
VALUES (2, 'Propietario')

INSERT INTO TipoEntidad([codigo], [nombre] )
VALUES (3, 'User')

INSERT INTO TipoEntidad([codigo], [nombre] )
VALUES (4, 'Propiedad vs Propietario')

INSERT INTO TipoEntidad([codigo], [nombre] )
VALUES (5, 'Propiedad vs Usuario')

INSERT INTO TipoEntidad([codigo], [nombre] )
VALUES (6, 'PropietarioJuridico')

INSERT INTO TipoEntidad([codigo], [nombre] )
VALUES (7, 'Concepto de Cobro')

SELECT * FROM dbo.TipoEntidad