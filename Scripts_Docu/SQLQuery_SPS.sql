USE [TEST]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPSalumnos]
AS 
BEGIN
	SELECT IdAlumno 'Clave Alumno'
	,Nombre 'Nombre'
	,ApPaterno 'Apellido Paterno'
	,ApMaterno 'Apellido Materno'
	,Email 'Correo Electronico'
	FROM Alumno

END


EXEC [SPSalumnos]