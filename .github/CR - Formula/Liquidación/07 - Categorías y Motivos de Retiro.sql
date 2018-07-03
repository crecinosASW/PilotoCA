-- Categorias y Motivos de Retiro

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codcmr_despido INT,
	@codcmr_renuncia INT,
	@codcmr_finalizacion INT

SET @codpai = 'cr'

IF NOT EXISTS (SELECT NULL FROM exp.cmr_categorias_motivo_retiro WHERE cmr_codpai = @codpai AND cmr_descripcion = 'Despido')
	INSERT INTO exp.cmr_categorias_motivo_retiro(cmr_descripcion, cmr_estado_plaza, cmr_codpai, cmr_property_bag_data, cmr_usuario_grabacion, cmr_fecha_grabacion, cmr_usuario_modificacion, cmr_fecha_modificacion)
	VALUES ('Despido', 'V', @codpai, NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM exp.cmr_categorias_motivo_retiro WHERE cmr_codpai = @codpai AND cmr_descripcion = 'Renuncia')
	INSERT INTO exp.cmr_categorias_motivo_retiro(cmr_descripcion, cmr_estado_plaza, cmr_codpai, cmr_property_bag_data, cmr_usuario_grabacion, cmr_fecha_grabacion, cmr_usuario_modificacion, cmr_fecha_modificacion)
	VALUES('Renuncia', 'V', @codpai, NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM exp.cmr_categorias_motivo_retiro WHERE cmr_codpai = @codpai AND cmr_descripcion = 'Finalización de Contrato')
	INSERT INTO exp.cmr_categorias_motivo_retiro(cmr_descripcion, cmr_estado_plaza, cmr_codpai, cmr_property_bag_data, cmr_usuario_grabacion, cmr_fecha_grabacion, cmr_usuario_modificacion, cmr_fecha_modificacion)
	VALUES('Finalización de Contrato', 'V', @codpai, NULL, 'admin', GETDATE(), NULL, NULL)

SELECT @codcmr_despido = cmr_codigo
FROM exp.cmr_categorias_motivo_retiro
WHERE cmr_codpai = @codpai
	AND cmr_descripcion = 'Despido'

SELECT @codcmr_renuncia = cmr_codigo
FROM exp.cmr_categorias_motivo_retiro
WHERE cmr_codpai = @codpai
	AND cmr_descripcion = 'Renuncia'

SELECT @codcmr_finalizacion = cmr_codigo
FROM exp.cmr_categorias_motivo_retiro
WHERE cmr_codpai = @codpai
	AND cmr_descripcion = 'Finalización de Contrato'

IF NOT EXISTS (SELECT NULL FROM exp.mrt_motivos_retiro WHERE mrt_codcmr = @codcmr_despido AND mrt_nombre = 'Despido con Responsabilidad')
	INSERT INTO exp.mrt_motivos_retiro(mrt_codcmr, mrt_nombre, mrt_puede_editar_params, mrt_property_bag_data, mrt_usuario_grabacion, mrt_fecha_grabacion, mrt_usuario_modificacion, mrt_fecha_modificacion)
	VALUES(@codcmr_despido, 'Despido con Responsabilidad', 0, NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM exp.mrt_motivos_retiro WHERE mrt_codcmr = @codcmr_despido AND mrt_nombre = 'Despido sin Responsabilidad')
	INSERT INTO exp.mrt_motivos_retiro(mrt_codcmr, mrt_nombre, mrt_puede_editar_params, mrt_property_bag_data, mrt_usuario_grabacion, mrt_fecha_grabacion, mrt_usuario_modificacion, mrt_fecha_modificacion)
	VALUES(@codcmr_despido, 'Despido sin Responsabilidad', 1, NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM exp.mrt_motivos_retiro WHERE mrt_codcmr = @codcmr_despido AND mrt_nombre = 'Renuncia Voluntaria')
	INSERT INTO exp.mrt_motivos_retiro(mrt_codcmr, mrt_nombre, mrt_puede_editar_params, mrt_property_bag_data, mrt_usuario_grabacion, mrt_fecha_grabacion, mrt_usuario_modificacion, mrt_fecha_modificacion)
	VALUES(@codcmr_renuncia, 'Renuncia Voluntaria', 1, NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM exp.mrt_motivos_retiro WHERE mrt_codcmr = @codcmr_despido AND mrt_nombre = 'Finalización de Contrato')
	INSERT INTO exp.mrt_motivos_retiro(mrt_codcmr, mrt_nombre, mrt_puede_editar_params, mrt_property_bag_data, mrt_usuario_grabacion, mrt_fecha_grabacion, mrt_usuario_modificacion, mrt_fecha_modificacion)
	VALUES(@codcmr_finalizacion, 'Finalización de Contrato', 1, NULL, 'admin', GETDATE(), NULL, NULL)

UPDATE EXP.mrt_motivos_retiro
SET mrt_property_bag_data = '<DocumentElement>
  <MotivosRetiro>
    <mrt_cesantia>false</mrt_cesantia>
    <mrt_porc_cesantia>100</mrt_porc_cesantia>
	<mrt_dias_preaviso>0.00</mrt_dias_preaviso>
  </MotivosRetiro>
</DocumentElement>'


COMMIT