USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF];
GO

--DROP TABLE CC_en_Propiedad
--DROP TABLE Comprobante_de_Pago
--DROP TABLE Recibos
--DROP TABLE Comprobante_Pago
--DROP TABLE Propiedad_del_Propietario 
--DROP TABLE Propiedad;

--Este documento carga Varios-Propiedades (XML)
-- Orden de lectura del XML
--#1: codigoDoc (id)
--#2: descipcion (nombre)
DELETE FROM dbo.[Bitacora]

DELETE FROM dbo.[Propietario_Juridico]
DELETE FROM dbo.[Propiedad_del_Propietario]
DELETE FROM dbo.[Concepto_Cobro_en_Propiedad]
DELETE FROM dbo.[Recibo]
DELETE FROM dbo.[MovConsumo]
DELETE FROM dbo.[Propiedad]
DELETE FROM dbo.[Propietario_Juridico]
DELETE FROM dbo.[Propietario]
DELETE FROM dbo.[Usuario_De_Propiedad]
DELETE FROM dbo.[Usuario]


DECLARE @fechaMin date, @fechaMax date, @fechaActual date
DECLARE @tempDates table ([date] date);
DECLARE @x xml;

DECLARE @tempCobroPropiedad table (
	id int primary key not null identity(1,1),
	numeroFinca int not null,
	idcobro int not null,
	activo int not null,
	fechaLeido date not null
)

DECLARE @tempPropietario table (
	id int primary key not null identity(1,1),
	Nombre NVARCHAR(50) not null,
	valorDocId bigInt not null,
	idDocId int not null,
	fechaLeido date not null
)

DECLARE @tempPropiedadPropietario table (
	id int primary key not null identity(1,1),
	numeroFinca int not null,
	valorDocId bigInt not null,
	activo int not null,
	fechaLeido date not null
)

DECLARE @tempPropiedadUsuario table (
	id int primary key not null identity(1,1),
	numeroFinca int not null,
	nombreUsuario NVARCHAR(50) not null,
	fechaLeido date not null
)

DECLARE @tempPropietarioJuridico table(
	id int primary key not null identity(1,1),
	valorDocIdPropietario bigInt not null,
	responsable NVARCHAR(50),
	valorDocIdResponsable bigInt,
	idDocId int,
	fechaLeido date
)

DECLARE @tempPropiedades table (
	id int primary key not null identity(1,1),
	numFinca int,
	valor money,
	direccion nvarchar(50),
	fechaLeido date
)

-- INICIO de lectura del XML

Select @x = XMLData FROM OPENROWSET (BULK 'D:\Documentos\GitHub\Project_1\XML\Operaciones.xml', SINGLE_BLOB) AS Products(XMLData);
DECLARE @hdoc int;
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

-- Lee todos los datos del XML especificamente los nodos de fecha --
INSERT INTO @tempDates ([date])
SELECT CONVERT(date, fecha, 121) fecha
FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia', 0)
WITH(
	fecha VARCHAR(100)
)

SELECT * FROM @tempDates;


-- Selecciona la primera y ultima fecha para tener una condicion de parada --
SELECT @fechaMax = MAX(TD.[date]) FROM  @tempDates AS TD
SELECT @fechaMin = MIN(TD.[date]) FROM @tempDates AS TD
SET @fechaActual = @fechaMin;

-- WHILE fecha no sea la ultima siga iterando --

WHILE(@fechaActual < @fechaMax)
	BEGIN
		-- INSERT informacion sobre la tabla propiedad --

		INSERT INTO @tempPropiedades ([numFinca], [valor], [direccion], [fechaLeido])
		SELECT [NumFinca], [Valor], [Direccion], @fechaActual
		FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/Propiedad', 1)
		WITH(
			[NumFinca] int,
			[Valor] money,
			[Direccion] nvarchar(50),
			[fechaLeido] date '../@fecha'
	
		)
		WHERE [fechaLeido] = @fechaActual ;

		declare @numeroFincaPropiedad int, @valorPropiedad money,@fechaLeidoPropiedad date, @idDePropiedad int = 1;
		declare @direcconPropiedad varchar(50);
		
		WHILE @idDePropiedad IS NOT NULL
			BEGIN
				SELECT @numeroFincaPropiedad = T.[numFinca], @valorPropiedad = T.[valor], @fechaLeidoPropiedad = T.[fechaLeido],
						@direcconPropiedad = T.direccion
				FROM @tempPropiedades AS T WHERE T.[id] = @idDePropiedad;

				EXEC dbo.[SPI_Propiedad_XML] @numeroFincaPropiedad, @valorPropiedad,@direcconPropiedad, @fechaActual;

				SELECT @idDePropiedad = MIN(id) FROM @tempPropiedades WHERE id > @idDePropiedad;
			END
		-- al terminar el dia hay que borrar los datos --
		 DELETE FROM @tempPropiedades


		--  INSERT informacion de la tabla ConceptoCobroVersusPropiedad

		INSERT INTO @tempCobroPropiedad ([idcobro], [numeroFinca], [activo], [fechaLeido])
		SELECT [idcobro], [NumFinca], 1, @fechaActual
		FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/ConceptoCobroVersusPropiedad', 0)
		WITH(
			[idcobro] int,
			[NumFinca] int,
			[fechaLeido] date '../@fecha'
	
		)
		WHERE [fechaLeido] = @fechaActual ;

		declare @numeroFinca int, @idcobro int,@fechaLeido date, @id int = 1;

		WHILE @id IS NOT NULL
			BEGIN
				SELECT @numeroFinca = T.[numeroFinca], @idcobro = T.[idcobro], @fechaLeido = T.[fechaLeido]
				FROM @tempCobroPropiedad AS T WHERE T.[id] = @id;

				EXEC SPI_Concepto_Cobro_En_Propiedad_XML @idcobro, @numeroFinca, @fechaActual;

				SELECT @id = MIN(id) FROM @tempCobroPropiedad WHERE id > @id;
			END
		-- al terminar el dia hay que borrar los datos --
		 DELETE FROM @tempCobroPropiedad

		
		-- INSERT informacion sobre la tabla propietarios --

		INSERT INTO @tempPropietario ([nombre], [idDocId], [valorDocId], [fechaLeido])
		SELECT [Nombre] , [TipoDocIdentidad], [identificacion], [fechaLeido]
		FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/Propietario', 0)
		WITH(
				[Nombre] nvarchar(50),
				[TipoDocIdentidad] int,
				[identificacion] bigInt,
				[fechaLeido] date '../@fecha'
	
		)
		WHERE [fechaLeido] = @fechaActual ;

		declare @nombrePR nvarchar(50), @idDocIdPR int ,@identificacionPR bigInt,@fechaLeidoPR date, @idPR INT = 1;

		WHILE @idPR IS NOT NULL
			BEGIN
				SELECT @nombrePR = PR.[Nombre], @idDocIdPR = PR.idDocId , @identificacionPR = PR.[valorDocId], @fechaLeidoPR = PR.[fechaLeido]
					FROM @tempPropietario AS PR WHERE PR.[id] = @idPR;

				EXEC [SPI_Propietario_XML] @nombrePR, @identificacionPR,@idDocIdPR, @fechaLeidoPR;

				SELECT @idPR = MIN(id) FROM @tempPropietario WHERE id > @idPR;
			END
		-- al terminar el dia hay que borrar los datos --
		 DELETE FROM @tempPropietario


		 --INSERT informacion sobre la tabla PropiedadVersusPropietario --

		INSERT INTO @tempCobroPropiedad ([idcobro], [numeroFinca], [activo], [fechaLeido])
		SELECT [idcobro], [NumFinca], 1, @fechaActual
		FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/ConceptoCobroVersusPropiedad', 0)
		WITH(
			[idcobro] int,
			[NumFinca] int,
			[fechaLeido] date '../@fecha'
	
		)
		WHERE [fechaLeido] = @fechaActual ;


		INSERT INTO @tempPropiedadPropietario ([numeroFinca], [valorDocId], [activo], [fechaLeido])
		SELECT [NumFinca], [identificacion], 1, [fechaLeido]
		FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/PropiedadVersusPropietario', 0)
		WITH(
			[NumFinca] int,
			[identificacion] bigInt,
			[fechaLeido] date '../@fecha'
		)
		WHERE [fechaLeido] = @fechaActual ;

		declare @numeroFincaPP int, @identificacionPP bigInt,@fechaLeidoPP date, @idPP INT = 1;

		WHILE @idPP IS NOT NULL
			BEGIN
				SELECT @numeroFincaPP = TPP.[numeroFinca] , @identificacionPP = TPP.[valorDocId], @fechaLeidoPP = TPP.[fechaLeido]
					FROM @tempPropiedadPropietario AS TPP WHERE TPP.[id] = @idPP;

				EXEC SPI_Propiedad_Del_Propietario_XML @numeroFincaPP, @identificacionPP, @fechaLeidoPP;

				SELECT @idPP = MIN(id) FROM @tempPropiedadPropietario WHERE id > @idPP;
			END
		-- al terminar el dia hay que borrar los datos --
		 DELETE FROM @tempPropiedadPropietario

		-- INSERT informacion sobre la tabla de usuario --

		INSERT INTO dbo.[Usuario] ([nombre], [password], [tipoUsuario],[fechaInicio], [activo])
		SELECT [Nombre] , [password] , 'Propietario', [fechaLeido], 1
		FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/Usuario', 0)
		WITH(
				[Nombre] nvarchar(50),
				[password] nvarchar(50),
				[fechaLeido] date '../@fecha'
	
		)
		WHERE [fechaLeido] = @fechaActual ;

		-- INSERT informacion sobre la tabla de usuario propiedad

		INSERT INTO @tempPropiedadUsuario ([numeroFinca] ,[nombreUsuario], [fechaLeido])
		SELECT [NumFinca], [nombreUsuario], [fechaLeido]
		FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/UsuarioVersusPropiedad', 0)
		WITH(
			[NumFinca] int,
			[nombreUsuario] NVARCHAR(50),
			[fechaLeido] date '../@fecha'
		)
		WHERE [fechaLeido] = @fechaActual ;

		declare @numeroFincaUP int, @nombreUsuarioUP NVARCHAR(50), @idUP INT = 1;

		WHILE @idUP IS NOT NULL
			BEGIN
				SELECT @numeroFincaUP = PU.[numeroFinca] , @nombreUsuarioUP = PU.[nombreUsuario], @fechaLeidoPP = PU.[fechaLeido]
					FROM @tempPropiedadUsuario AS PU WHERE PU.[id] = @idUP;

				EXEC dbo.SPI_Usuario_De_Propiedad_XML @nombreUsuarioUP, @numeroFincaUP, @fechaLeidoPP;

				SELECT @idUP = MIN(id) FROM @tempPropiedadUsuario WHERE id > @idUP;
			END
		-- al terminar el dia hay que borrar los datos --
		 DELETE FROM @tempPropiedadUsuario


		-- INSERT informacion sobre la tabla propietarios juridico --

		INSERT INTO @tempPropietarioJuridico  ([valorDocIdPropietario], [responsable], [valorDocIdResponsable], [idDocId], [fechaLeido])
		SELECT [docidPersonaJuridica], [Nombre], [DocidRepresentante], 4, [fechaLeido]
		FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/PersonaJuridica', 0)
		WITH(
			[docidPersonaJuridica] bigInt,
			[Nombre] NVARCHAR(50),
			[DocidRepresentante] bigInt,
			[fechaLeido] date '../@fecha'
		)
		WHERE [fechaLeido] = @fechaActual ;
		SELECT * FROM @tempPropietarioJuridico;
		declare @docidPersonaJuridica bigInt, @NombreJ NVARCHAR(50), @idJ INT = 1;
		declare @docidRepresentante bigInt, @TipDocIdPJ int, @fechaLeidoJ date; 

		WHILE @idJ IS NOT NULL
			BEGIN
				PRINT('TACO')
				SELECT @docidPersonaJuridica = PJ.[valorDocIdPropietario] , @NombreJ = PJ.[responsable], @fechaLeidoJ = PJ.[fechaLeido],
				@docidRepresentante = PJ.[valorDocIdResponsable], @TipDocIdPJ = PJ.[idDocId]
				FROM @tempPropietarioJuridico AS PJ WHERE PJ.[id] = @idJ;

				EXEC dbo.[SPI_Propietario_Juridico_XML] @docidPersonaJuridica, @NombreJ, @docidRepresentante, @TipDocIdPJ, @fechaLeidoJ;

				SELECT @idJ = MIN(id) FROM @tempPropietarioJuridico WHERE id > @idJ;
			END
		-- al terminar el dia hay que borrar los datos --
		 DELETE FROM @tempPropietarioJuridico


	    SELECT @fechaActual = DATEADD(DAY,1,@fechaActual);
	END


SELECT * FROM dbo.Propiedad;
SELECT * FROM dbo.Propietario;
SELECT * FROM dbo.Concepto_Cobro
SELECT * FROM dbo.[Concepto_Cobro_en_Propiedad]
SELECT * FROM dbo.[Propiedad_del_Propietario]
SELECT * FROM dbo.[Usuario]
SELECT * FROM dbo.Usuario_de_Propiedad
SELECT * FROM dbo.Tipo_DocId
SELECT * FROM dbo.Propietario_Juridico
SELECT * FROM dbo.Usuario