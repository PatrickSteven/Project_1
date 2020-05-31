USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

--DROP TABLE Propiedad_del_Propietario
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
	valorDocId bigInt not null
)

--Inserta la informacion que pertenece a Propietario 
INSERT INTO #tempTableRelacion(numeroFinca,valorDocId)
SELECT * FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/PropiedadVersusPropietario', 0)
WITH(
		NumFinca int,
		identificacion bigInt
	
)

declare @numeroFinca int
declare @identificacion bigInt
DECLARE @id INT = 1;

WHILE @id IS NOT NULL
BEGIN
    SELECT @numeroFinca = numeroFinca, @identificacion = valorDocId 
        FROM #tempTableRelacion WHERE id = @id;

    EXEC SPI_Propiedad_Del_Propietario @numeroFinca, @identificacion;

    SELECT @id = MIN(id) FROM #tempTableRelacion WHERE id > @id;
END

SELECT * FROM #tempTableRelacion;
DROP TABLE #tempTableRelacion;

SELECT * FROM Propiedad
SELECT * FROM dbo.Propiedad_del_Propietario

