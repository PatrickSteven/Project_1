USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

DROP TABLE Usuario_de_Propiedad
-- #1 idea: SELECT DATOS y luego EXECUTE SPI_Propiedad_Del_Propietario
-- #2 idea: SELECT DATOS en table temporal y despues leer la tabla y luego EXECUTE SPI_Propiedad_Del_Propietario por cada elemento de la tabla
DECLARE @x xml;
Select @x = XMLData FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\Varios.xml', SINGLE_BLOB) AS Products(XMLData);
	

DECLARE @hdoc int;
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

--Tabla temporal para luego recorrer con SPI_Propiedad_Del_Propietario(numeroFinca,valorDocId)
CREATE TABLE #tempTableRelacion
(
	id int primary key not null identity(1,1),
	numeroFinca int not null,
	nombreUsuario NVARCHAR(50) not null
)

--Inserta la informacion que pertenece a Propietario 
INSERT INTO #tempTableRelacion(numeroFinca,nombreUsuario)
SELECT * FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/UsuarioVersusPropiedad', 0)
WITH(
		NumFinca int,
		nombreUsuario NVARCHAR(50)
)

declare @numeroFinca int
declare @nombreUsuario NVARCHAR(50)
DECLARE @id INT = 1;

WHILE @id IS NOT NULL
BEGIN
    SELECT @numeroFinca = numeroFinca,
           @nombreUsuario = nombreUsuario 
        FROM #tempTableRelacion WHERE id = @id;

    EXEC SPI_Usuario_De_Propiedad @nombreUsuario,@numeroFinca;

    SELECT @id = MIN(id) FROM #tempTableRelacion WHERE id > @id;
END

SELECT * FROM #tempTableRelacion;
DROP TABLE #tempTableRelacion;

SELECT * FROM Usuario_de_Propiedad