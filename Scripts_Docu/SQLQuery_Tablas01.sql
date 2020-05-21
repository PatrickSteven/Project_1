
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
	activo int
);

-- La tabla propiedad tiene tablas que usan una propiedad
-- CC_en_Propiedad: Asocia una propiedad con VARIOS concepto de cobros
-- Comprobante_de_Pago: Tiene UNA referencia a una propiedad
-- Recibos: Tienen UNA referencia a una propiedad
-- Propietario: Tienen una referencia a VARIAS propiedades
-- Propiedad_del_Propietario : Asocia un propietario con VARIAS propiedades

--ACTUALIZADO VERSION FINAL
CREATE TABLE Propiedad (
	id int primary key not null identity(1,1),
	numeroFinca int not null,
	valor int not null,
	direccion nvarchar(50) not null,
	activo int 
);

-- Asocia mediante FK las tablas [Propiedad,Concepto_Cobro]
-- Las FK se asocian SOLAMENTE A LLAVES PRIMARIAS(id)

--ACTUALIZADO VERSION FINAL
CREATE TABLE Concepto_Cobro_en_Propiedad (
	id int primary key not null identity(1,1),
	fechaInicio date not null,
	fechaFin date not null,
	idConeceptoCobro int not null,
	CONSTRAINT FK_idConeceptoCobro FOREIGN KEY (idConeceptoCobro) REFERENCES Concepto_Cobro(id),
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	activo int not null
);

-- Tinene una FK  a solamente una porpiedad
-- Nota: Para la primera entrega no se necesita implementar

--ACTUALIZADO VERSION FINAL
CREATE TABLE Comprobante_Pago (
	id int primary key not null identity(1,1),
	fecha date not null,
	total int,
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad_02 FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	activo int not null
);

-- Un recibo tiene 3 FK
-- #1: Referencia a un Concepto de Cobro
-- #2: Referencia a una Propiedad
-- #3: Referencia a un Comprobante de Pago no emitido
-- Nota: Para la primera entrega no se necesita implementar
CREATE TABLE Recibos (
	id int primary key not null identity(1,1),
	fecha date not null,
	fechaVencimiendo date not null,
	monto int not null,
	esPendiente bit not null,
	idConeceptoCobro int not null,
	CONSTRAINT FK_idConeceptoCobro_02 FOREIGN KEY (idConeceptoCobro) REFERENCES Concepto_Cobro(id),
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad_06 FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	-- idComprobantePago  puede ser null [REVISAR]
	idComprobanteDePago int,
	CONSTRAINT FK_idComprobantePago FOREIGN KEY (id) REFERENCES Comprobante_Pago(id)
);

-- Tipo_DocId es una tabla catalogo y es usada por referencia en:
-- Propietario: Asocia a un propietario con un Id UNICO
-- Propietario_Juridico: Asocia a un propietario juridico con un Id UNICO 

--ACTUALIZADO VERSION FINAL
CREATE TABLE Tipo_DocId (
	id int primary key not null identity(1,1),
	codigoDoc int not null,
	nombre nvarchar(50) not null,
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
	activo int ,
	CONSTRAINT FK_tipoDocId FOREIGN KEY (idDocId) REFERENCES Tipo_DocId(id),
);

-- Propietario_Juridico tiene una referencia a:
-- #1: Tiene una referencia unica a un DocId UNICO
-- #2: Tiene una referencia unica a un Propietario


CREATE TABLE Propietario_Juridico (
	id int primary key not null identity(1,1),
	responsable nvarchar(50) not null,
	valorDocId int not null,
	idDocId int not null,
	CONSTRAINT FK_tipoDocId_02 FOREIGN KEY (idDocId) REFERENCES Tipo_DocId(id),
	--Este id propietario es el id de Propietario juridico
	idPropietario int not null,
	CONSTRAINT FK_idPropietario_02  FOREIGN KEY (idPropietario) REFERENCES Propietario (id),
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
	activo int not null
);

--ACTUALIZADO VERSION FINAL
CREATE TABLE Usuario (
	id int primary key not null identity(1,1),
	nombre nvarchar(50) ,
	password nvarchar(50) , -- palabra reservada?
	tipoUsuario nvarchar(50), -- Administrador / Propietario
	activo int 
);


CREATE TABLE Usuario_de_Propiedad (
	id int primary key not null identity(1,1),
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad_05 FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	idUsuario int not null,
	CONSTRAINT FK_idUsuario  FOREIGN KEY (idUsuario) REFERENCES Usuario (id),
	activo int not null
);


--TODO-- EJECUTAR DESPUES DE SOLUCIONAR EL PRIMARY KEY DEL CATALOGO CONCEPTO_COBRO
-- CC_Fijo , CC_Consumo, CC_Porcentaje y CC_Intereses_Moratorios heredan de la tabla Concepto_Cobro

CREATE TABLE CC_Fijo(
	id int not null primary key, --no puede ser identity porque tambien va a ser Foreign Key relacionada con Conepto_Cobro
	monto int not null,
	valor float not null,
	CONSTRAINT FK_id_CC_Fijo FOREIGN KEY (id) REFERENCES Concepto_Cobro (id),
	activo int
)

CREATE TABLE CC_Consumo(
	id int not null primary key, --no puede ser identity porque tambien va a ser Foreign Key relacionada con Conepto_Cobro
	monto int not null,
	valorM3 int not null,
	CONSTRAINT FK_id_CC_Consumo FOREIGN KEY (id) REFERENCES Concepto_Cobro (id),
	activo int 
)

CREATE TABLE CC_Intereses_Moratorios(
	id int not null primary key, --no puede ser identity porque tambien va a ser Foreign Key relacionada con Conepto_Cobro
	CONSTRAINT FK_id_CC_Intereses_Moratorios FOREIGN KEY (id) REFERENCES Concepto_Cobro (id),
	activo int 
)