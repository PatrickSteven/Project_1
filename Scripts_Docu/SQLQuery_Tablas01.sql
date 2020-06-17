
USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]

DECLARE @x xml;

Select @x = P
FROM OPENROWSET (BULK 'C:\Users\alega\Documents\GitHub\BD-Proyecto-1\XML\CC_Prueba.xml', SINGLE_BLOB) AS Products(P);

DECLARE @hdoc int;

EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

-- Concepto cobro es una tabla catalogo y es usada por referencia en:
-- CC_en_Propiedad (Referencia normal): Asocia una propiedad con VARIOS concepto de cobros
-- CC_Fijo (Herencia): Agrega un Monto
-- CC_Consumo (Herencia): Agrega un ValorM3
-- CC_Porcentaje (Herencia): Agrega un ValorPorcentual
-- CC_IntMonetario (Herencia): No agrega nada solo se usa para especificar el tipo
-- Nota: Los datos de concepto de cobro se cargan desde un XML
-- Cambio innecesario

--ACTUALIZADO VERSION FINAL
CREATE TABLE Concepto_Cobro (
    id int primary key not null,
	nombre nvarchar(50) not null,
	DiaDeCobro int,
	qDiasVencidos int,
	EsImpuesto varchar(10),
	EsRecurrente varchar(10),
	EsFijo varchar(10),
	tasaInteresesMoratorios float,
	fechaInicio date not null,
	activo int
);

-- La tabla propiedad tiene tablas que usan una propiedad
-- CC_en_Propiedad: Asocia una propiedad con VARIOS concepto de cobros
-- Comprobante_de_Pago: Tiene UNA referencia a una propiedad
-- Recibos: Tienen UNA referencia a una propiedad
-- Propietario: Tienen una referencia a VARIAS propiedades
-- Propiedad_del_Propietario : Asocia un propietario con VARIAS propiedades

--ACTUALIZADO VERSION FINAL
--ACTUALIZACION SEGUNDA PARTE PROYECTO
CREATE TABLE Propiedad (
	id int primary key not null identity(1,1),
	fechaLeido date not null,
	numeroFinca int not null,
	valor money not null,
	direccion nvarchar(50) not null,
	m3Acumulados int not null, --Nuevos atributos. Se inicializan en 0 cuando una propiedada es insertada
	m3AcumuladosUR int not null,
	activo int 
);

-- Asocia mediante FK las tablas [Propiedad,Concepto_Cobro]
-- Las FK se asocian SOLAMENTE A LLAVES PRIMARIAS(id)

--ACTUALIZADO VERSION FINAL
CREATE TABLE Concepto_Cobro_en_Propiedad (
	id int primary key not null identity(1,1),
	fechaLeido date not null,
	idConeceptoCobro int not null,
	CONSTRAINT FK_idConeceptoCobro FOREIGN KEY (idConeceptoCobro) REFERENCES Concepto_Cobro(id),
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	activo int not null
);



-- Tipo_DocId es una tabla catalogo y es usada por referencia en:
-- Propietario: Asocia a un propietario con un Id UNICO
-- Propietario_Juridico: Asocia a un propietario juridico con un Id UNICO 

--ACTUALIZADO VERSION FINAL
CREATE TABLE Tipo_DocId (
	id int primary key not null identity(1,1),
	codigoDoc int not null,
	nombre nvarchar(50) not null,
	fechaInicio date not null,
	activo int
);

-- Propietario es una tabla usada por referencia en:
-- Propiedad_del_Propietario : Asocia un propietario con VARIAS propiedades
-- Propietario tiene una referencia unica a un DocId
-- #1: Tiene una referencia unica a un DocId UNICO

--ACTUALIZADO VERSION FINAL
CREATE TABLE Propietario (
	id int primary key not null identity(1,1),
	nombre nvarchar(50) not null,
	valorDocId bigInt not null,
	idDocId int not null,
	fechaLeido date not null,
	activo int ,
	CONSTRAINT FK_tipoDocId FOREIGN KEY (idDocId) REFERENCES Tipo_DocId(id),
);





-- Propietario_Juridico tiene una referencia a:
-- #1: Tiene una referencia unica a un DocId UNICO
-- #2: Tiene una referencia unica a un Propietario


CREATE TABLE Propietario_Juridico (
	id int primary key not null,
	--Este id propietario es el id de Propietario juridico
	CONSTRAINT FK_idPropietario_02  FOREIGN KEY (id) REFERENCES Propietario (id),
	responsable nvarchar(50) not null, -- nombre del responsable --
	valorDocId bigInt not null,
	idDocId int not null,
	CONSTRAINT FK_tipoDocId_02 FOREIGN KEY (idDocId) REFERENCES Tipo_DocId(id),
	fechaLeido date not null,
	activo int not null
);



-- Asocia mediante FK las tablas [Propiedad,Propietario]
-- Las FK se asocian SOLAMENTE A LLAVES PRIMARIAS(id)
-- Nota: un propietario puede tene varias propiedades
-- una propiedad solo tiene un propietario

--ACTUALIZADO VERSION FINAL
CREATE TABLE Propiedad_del_Propietario (
	id int primary key not null identity(1,1),
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad_04 FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	idPropietario int not null,
	CONSTRAINT FK_idPropietario  FOREIGN KEY (idPropietario) REFERENCES Propietario (id),
	fechaLeido date not null,
	activo int not null
);

--ACTUALIZADO VERSION FINAL
CREATE TABLE Usuario (
	id int primary key not null identity(1,1),
	nombre nvarchar(50) ,
	password nvarchar(50) , -- palabra reservada?
	tipoUsuario nvarchar(50), -- Administrador / Propietario
	fechaInicio date not null,
	activo int 
);

CREATE TABLE Usuario_de_Propiedad (
	id int primary key not null identity(1,1),
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad_05 FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	idUsuario int not null,
	CONSTRAINT FK_idUsuario  FOREIGN KEY (idUsuario) REFERENCES Usuario (id),
	fechaInicio date not null,
	activo int not null
);


--TODO-- EJECUTAR DESPUES DE SOLUCIONAR EL PRIMARY KEY DEL CATALOGO CONCEPTO_COBRO
-- CC_Fijo , CC_Consumo, CC_Porcentaje y CC_Intereses_Moratorios heredan de la tabla Concepto_Cobro

CREATE TABLE CC_Fijo(
	id int not null primary key, --no puede ser identity porque tambien va a ser Foreign Key relacionada con Conepto_Cobro
	monto int not null,
	valor float not null,
	CONSTRAINT FK_id_CC_Fijo FOREIGN KEY (id) REFERENCES Concepto_Cobro (id),
	fechaInicio date not null,
	activo int
)

CREATE TABLE CC_Consumo(
	id int not null primary key, --no puede ser identity porque tambien va a ser Foreign Key relacionada con Conepto_Cobro
	monto int not null,
	valorM3 int not null,
	CONSTRAINT FK_id_CC_Consumo FOREIGN KEY (id) REFERENCES Concepto_Cobro (id),
	fechaInicio date not null,
	activo int 
)

CREATE TABLE CC_Intereses_Moratorios(
	id int not null primary key, --no puede ser identity porque tambien va a ser Foreign Key relacionada con Conepto_Cobro
	CONSTRAINT FK_id_CC_Intereses_Moratorios FOREIGN KEY (id) REFERENCES Concepto_Cobro (id),
	fechaInicio date not null,
	activo int 
)

CREATE TABLE CC_Porcentual(
	id int not null primary key, --no puede ser identity porque tambien va a ser Foreign Key relacionada con Conepto_Cobro
	CONSTRAINT FK_id_CC_Porcentual FOREIGN KEY (id) REFERENCES Concepto_Cobro (id),
	ValorPorcentaje float not null,
	fechaInicio date not null,
	activo int 
)

--NUEVAS TABLAS SEGUNDA PARTE PROYECTO

CREATE TABLE TipoMov(
	id int primary key not null identity(1,1),
	codigo int not null,
	nombre varchar(20) not null
);

CREATE TABLE MovConsumo(
	id int primary key not null identity(1,1),
	idPropiedad int not null,
	idTipoMov int not null,
	fecha date not null,
	montoM3 int,
	lecturaConsumo int,
	activo int not null,

	CONSTRAINT FK_MovConsumo_idPropiedad FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	CONSTRAINT FK_MovConsumo_idTipoMov FOREIGN KEY (idTipoMov) REFERENCES TipoMov(id),
);


-- Tinene una FK  a solamente una porpiedad
CREATE TABLE Comprobante_Pago(

	id int primary key not null identity(1,1),
	idPropiedad int not null,
	fecha date not null,
	total int,
	activo int not null

	CONSTRAINT FK_CompPago_idPropiedad FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),

);

-- Un recibo tiene 3 FK
-- #1: Referencia a un Concepto de Cobro
-- #2: Referencia a una Propiedad
-- #3: Referencia a un Comprobante de Pago no emitido

CREATE TABLE Recibo (
	id int primary key not null identity(1,1),
	idPropiedad int not null,
	idConceptoCobro int not null,
	idComprobanteDePago int,

	fecha date not null,
	fechaVencimiendo date not null,
	monto int not null,
	estado int not null, --0: Pendiente de pago (estado default), 1: Pagado, 3: Anulado.
	activo int not null,
	CONSTRAINT FK_idConeceptoCobro_02 FOREIGN KEY (idConceptoCobro) REFERENCES Concepto_Cobro(id),
	CONSTRAINT FK_idPropiedad_06 FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	-- idComprobantePago  puede ser null [REVISAR]
	CONSTRAINT FK_idComprobantePago FOREIGN KEY (id) REFERENCES Comprobante_Pago(id)
);


CREATE TABLE ReciboReconexion(
	id int primary key not null,
	activo int not null,

	CONSTRAINT FK_rconexionRecibo FOREIGN KEY (id) REFERENCES Recibo(id)	
);

CREATE TABLE Corte(
	id int primary key not null,
	idPropiedad int not null,
	idReciboReconexion int not null,
	fecha date,
	activo int not null,

	CONSTRAINT FK_CortePropiedad FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	CONSTRAINT FK_CorteRecibo FOREIGN KEY (idReciboReconexion) REFERENCES ReciboReconexion(id)


);

CREATE TABLE Reconexion(
	id int primary key not null,
	idPropiedad int not null,
	idReciboReconexion int not null,
	fecha date,
	activo int not null,

	CONSTRAINT FK_ReconexionPropiedad FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	CONSTRAINT FK_ReconexionRecibo FOREIGN KEY (idReciboReconexion) REFERENCES ReciboReconexion(id)
);

--  1: Propiedad
--  2: Propietario
--  3: User
--  4: Propiedad vs Propietario
--  5 Propiedad vs Usuario
--  6: PropietarioJuridico
--  7: Concepto de Cobro
CREATE TABLE TipoEntidad(
	id int primary key not null, 
	codigo int not null,
	nombre varchar(30)
);

CREATE TABLE Bitacora(

	id int primary key identity (1,1) not null,
	idTipoEntidad int not null, -- referencia a table EntityType
	idEntidad int not null, -- Id de la entidad siendo actualizada
	jsonAntes varchar(500),
	jsonDespues varchar(500),
	insertedAt datetime not null, -- estampa de tiempo de cuando se hizo la actualización
	insertedby varchar(20) not null, -- usuario persona que hizo la actualización
	insertedIn varchar(20) not null, -- IP desde donde se hizo la actualización, NO la IP del servidor, sino la del usuario que debe capturarse en capa lógica
	activo int not null,

	CONSTRAINT FK_BitacoraTipoEntidad FOREIGN KEY (idTipoEntidad) REFERENCES TipoEntidad(id),
);

