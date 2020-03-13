USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]

DECLARE @x xml;

Select @x = P
FROM OPENROWSET (BULK 'C:\Users\alega\Documents\GitHub\BD-Proyecto-1\XML\CC_Prueba.xml', SINGLE_BLOB) AS Products(P);

DECLARE @hdoc int;

EXEC sp_xml_preparedocument @hdoc OUTPUT, @x


CREATE TABLE Concepto_Cobro (
    id int primary key not null,
	nombre nvarchar(50) not null,
	tasaInteresesMoratorios int not null,
	qDiasVencidos int
);



CREATE TABLE Propiedad (
	id int primary key not null identity(1,1),
	numeroFinca int not null,
	valor int not null,
	direccion nvarchar(50) not null
);

CREATE TABLE Concepto_Cobro_en_Propiedad (
	id int primary key not null identity(1,1),
	fechaInicio date not null,
	fechaFin date not null,
	idConeceptoCobro int not null,
	CONSTRAINT FK_idConeceptoCobro FOREIGN KEY (idConeceptoCobro) REFERENCES Concepto_Cobro(id),
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id)
);

CREATE TABLE Comprobante_Pago (
	id int primary key not null identity(1,1),
	fecha date not null,
	total int,
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad_02 FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id)
);

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


CREATE TABLE Tipo_DocId (
	id int primary key not null,
	nombre nvarchar(50) not null
);

CREATE TABLE Propietario (
	id int primary key not null identity(1,1),
	nombre nvarchar(50) not null,
	valorDocId int not null,
	idDocId int not null,
	CONSTRAINT FK_tipoDocId FOREIGN KEY (idDocId) REFERENCES Tipo_DocId(id),
);

CREATE TABLE Propietario_Juridico (
	id int primary key not null identity(1,1),
	responsable nvarchar(50) not null,
	valorDocId int not null,
	idDocId int not null,
	CONSTRAINT FK_tipoDocId_02 FOREIGN KEY (idDocId) REFERENCES Tipo_DocId(id),
	idPropietario int not null,
	CONSTRAINT FK_idPropietario_02  FOREIGN KEY (idPropietario) REFERENCES Propietario (id)
);

CREATE TABLE Propiedad_del_Propietario (
	id int primary key not null identity(1,1),
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad_04 FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	idPropietario int not null,
	CONSTRAINT FK_idPropietario  FOREIGN KEY (idPropietario) REFERENCES Propietario (id)
);


CREATE TABLE Usuario (
	id int primary key not null identity(1,1),
	nombre nvarchar(50) not null,
	password nvarchar(50) not null, -- palabra reservada?
	tipoUsuario nvarchar(50) not null -- Administrador / Propietario
);

CREATE TABLE Usuario_de_Propiedad (
	id int primary key not null identity(1,1),
	idPropiedad int not null,
	CONSTRAINT FK_idPropiedad_05 FOREIGN KEY (idPropiedad) REFERENCES Propiedad(id),
	idUsuario int not null,
	CONSTRAINT FK_idUsuario  FOREIGN KEY (idUsuario) REFERENCES Usuario (id)
);


--TODO-- EJECUTAR DESPUES DE SOLUCIONAR EL PRIMARY KEY DEL CATALOGO CONCEPTO_COBRO
-- CC_Fijo , CC_Consumo, CC_Porcentaje y CC_Intereses_Moratorios heredan de la tabla Concepto_Cobro

CREATE TABLE CC_Fijo(
	id int not null primary key, --no puede ser identity porque tambien va a ser Foreign Key relacionada con Conepto_Cobro
	monto money not null,
	CONSTRAINT FK_id_CC_Fijo FOREIGN KEY (id) REFERENCES Concepto_Cobro (id) 
)

CREATE TABLE CC_Consumo(
	id int not null primary key, --no puede ser identity porque tambien va a ser Foreign Key relacionada con Conepto_Cobro
	valor money not null,
	CONSTRAINT FK_id_CC_Consumo FOREIGN KEY (id) REFERENCES Concepto_Cobro (id) 
)

CREATE TABLE CC_Intereses_Moratorios(
	id int not null primary key, --no puede ser identity porque tambien va a ser Foreign Key relacionada con Conepto_Cobro
	CONSTRAINT FK_id_CC_Intereses_Moratorios FOREIGN KEY (id) REFERENCES Concepto_Cobro (id) 
)