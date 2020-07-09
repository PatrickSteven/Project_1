DECLARE @fechaMin date, @fechaMax date, @fechaActual date
DECLARE @tempDates table ([date] date);
DECLARE @x xml;

-- INICIO de lectura del XML

Select @x = XMLData FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\pruebaProgra2XML.xml', SINGLE_BLOB) AS Products(XMLData);
DECLARE @hdoc int;
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

-- Lee todos los datos del XML especificamente los nodos de fecha --
INSERT INTO @tempDates ([date])
SELECT CONVERT(date, fecha, 121) fecha
FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia', 0)
WITH(
	fecha VARCHAR(100)
)


-- Selecciona la primera y ultima fecha para tener una condicion de parada --
SELECT @fechaMax = MAX(TD.[date]) FROM  @tempDates AS TD
SELECT @fechaMin = MIN(TD.[date]) FROM @tempDates AS TD
SET @fechaActual = @fechaMin;

-- WHILE fecha no sea la ultima siga iterando --

WHILE(@fechaActual <= @fechaMax)
	BEGIN
		-- INSERT informacion sobre la tabla propiedad --
		declare @PropiedadCambio PropiedadCambio;


		INSERT INTO @PropiedadCambio ([numFinca], [nuevoValor])
		SELECT [NumFinca], [NuevoValor]
		FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/PropiedadCambio', 1)
		WITH(
			[Numfinca] int,
			[NuevoValor] money,
			[fechaLeido] date '../@fecha'
		)
		WHERE [fechaLeido] = @fechaActual ;

		SELECT * FROM @PropiedadCambio;
		SELECT * FROM dbo.Propiedad;
		EXEC [dbo].[SPU_ValorPropiedad] @PropiedadCambio;
		SELECT * FROM dbo.Propiedad;




	    SELECT @fechaActual = DATEADD(DAY,1,@fechaActual);
	END