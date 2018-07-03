BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codcia INT,
	@codpai VARCHAR(2)
	
SET @codpai = 'gt'

DECLARE companias CURSOR FOR
SELECT cia_codigo
FROM eor.cia_companias
WHERE cia_codpai = @codpai

OPEN companias

FETCH NEXT FROM companias INTO @codcia

WHILE @@fetch_status = 0
BEGIN
	IF NOT EXISTS (SELECT NULL FROM sal.tdc_tipos_descuento WHERE tdc_codcia = @codcia AND tdc_abreviatura = 'IGSS')
		INSERT sal.tdc_tipos_descuento (tdc_codcia, tdc_descripcion, tdc_abreviatura, tdc_activo, tdc_orden, tdc_es_descuento_legal, tdc_property_bag_data, tdc_estado_workflow, tdc_codigo_workflow, tdc_ingresado_portal, tdc_fecha_grabacion, tdc_usuario_grabacion, tdc_fecha_modificacion, tdc_usuario_modificacion) 
		VALUES (@codcia, 'Seguro Social', 'IGSS', 1, 1, 1, NULL, 'Autorizado', NULL, 0, '2011-01-28 00:00:00', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tdc_tipos_descuento WHERE tdc_codcia = @codcia AND tdc_abreviatura = 'ISR')
		INSERT sal.tdc_tipos_descuento (tdc_codcia, tdc_descripcion, tdc_abreviatura, tdc_activo, tdc_orden, tdc_es_descuento_legal, tdc_property_bag_data, tdc_estado_workflow, tdc_codigo_workflow, tdc_ingresado_portal, tdc_fecha_grabacion, tdc_usuario_grabacion, tdc_fecha_modificacion, tdc_usuario_modificacion) 
		VALUES (@codcia, 'Impuesto Sobre la Renta', 'ISR', 1, 2, 1, NULL, 'Autorizado', NULL, 0, '2011-01-28 00:00:00', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tdc_tipos_descuento WHERE tdc_codcia = @codcia AND tdc_abreviatura = 'AQUI')
		INSERT sal.tdc_tipos_descuento (tdc_codcia, tdc_descripcion, tdc_abreviatura, tdc_activo, tdc_orden, tdc_es_descuento_legal, tdc_property_bag_data, tdc_estado_workflow, tdc_codigo_workflow, tdc_ingresado_portal, tdc_fecha_grabacion, tdc_usuario_grabacion, tdc_fecha_modificacion, tdc_usuario_modificacion) 
		VALUES (@codcia, 'Anticipo Quincenal', 'AQUI', 1, 3, 0, NULL, 'Autorizado', NULL, 0, '2011-01-28 00:00:00', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tdc_tipos_descuento WHERE tdc_codcia = @codcia AND tdc_abreviatura = 'SEGMED')
		INSERT sal.tdc_tipos_descuento (tdc_codcia, tdc_descripcion, tdc_abreviatura, tdc_activo, tdc_orden, tdc_es_descuento_legal, tdc_property_bag_data, tdc_estado_workflow, tdc_codigo_workflow, tdc_ingresado_portal, tdc_fecha_grabacion, tdc_usuario_grabacion, tdc_fecha_modificacion, tdc_usuario_modificacion) 
		VALUES (@codcia, 'Seguro Medico', 'SEGMED', 1, 4, 0, NULL, 'Autorizado', NULL, 0, '2011-01-28 00:00:00', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tdc_tipos_descuento WHERE tdc_codcia = @codcia AND tdc_abreviatura = 'ORNATO')
		INSERT sal.tdc_tipos_descuento (tdc_codcia, tdc_descripcion, tdc_abreviatura, tdc_activo, tdc_orden, tdc_es_descuento_legal, tdc_property_bag_data, tdc_estado_workflow, tdc_codigo_workflow, tdc_ingresado_portal, tdc_fecha_grabacion, tdc_usuario_grabacion, tdc_fecha_modificacion, tdc_usuario_modificacion) 
		VALUES (@codcia, 'Boleto de Ornato', 'ORNATO', 1, 5, 1, NULL, 'Autorizado', NULL, 0, '2011-01-28 00:00:00', 'admin', NULL, NULL)
	
	FETCH NEXT FROM companias INTO @codcia	
END

CLOSE companias
DEALLOCATE companias

COMMIT