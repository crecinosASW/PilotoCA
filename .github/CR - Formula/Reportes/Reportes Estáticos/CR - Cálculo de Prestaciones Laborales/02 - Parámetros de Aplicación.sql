-- Parámetros de Aplicación

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codgrc INT,
	@codcia INT

SET @codpai = 'cr'

--Parámetros
IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoCMR_Renuncia')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoCMR_Renuncia', 'Código de la categoría de retiro de renuncia', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoCMR_Despido')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoCMR_Despido', 'Código de la categoría de retiro de despedio', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

--Alcances
DECLARE @codcmr_renuncia INT,
	@codcmr_despido INT

SELECT @codcmr_renuncia = cmr_codigo
FROM exp.cmr_categorias_motivo_retiro
WHERE cmr_descripcion = 'Renuncia'
	AND cmr_codpai = @codpai

SELECT @codcmr_despido = cmr_codigo
FROM exp.cmr_categorias_motivo_retiro
WHERE cmr_descripcion = 'Despido'
	AND cmr_codpai = @codpai

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoCMR_Renuncia' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CodigoCMR_Renuncia', @codpai, NULL, NULL, NULL, CONVERT(VARCHAR, @codcmr_renuncia), 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoCMR_Despido' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CodigoCMR_Despido', @codpai, NULL, NULL, NULL, CONVERT(VARCHAR, @codcmr_despido), 'admin', GETDATE(), NULL, NULL)

DECLARE companias CURSOR FOR
SELECT cia_codgrc,
	cia_codigo
FROM eor.cia_companias
WHERE cia_codpai = @codpai

OPEN companias

FETCH NEXT FROM companias INTO @codgrc, @codcia

WHILE @@FETCH_STATUS = 0
BEGIN

	FETCH NEXT FROM companias INTO @codgrc, @codcia
END

CLOSE companias
DEALLOCATE companias

COMMIT