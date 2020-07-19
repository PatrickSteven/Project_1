USE [D:\DOCUMENTOS\PROJECT_1\PROJECT_1\APP_DATA\DATABASE1.MDF]
GO

CREATE TYPE PagosTipo AS TABLE (id INT IDENTITY(1,1),numFinca VARCHAR(30),idTipoRecibo INT)
-- Cambios de valor de propiedad --
CREATE TYPE PropiedadCambio AS TABLE (id INT IDENTITY(1,1),numFinca VARCHAR(30),nuevoValor MONEY)
-- SELECT PRE-CONFIRMACION --
CREATE TYPE ReciboSelect AS TABLE (id int, idRecibo int)
