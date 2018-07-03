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
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'ORD')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Salario Ordinario', 'ORD', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'B14')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Bono 14', 'B14', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'AGUI')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Aguinaldo', 'AGUI', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
		
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'VAC')		
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Vacaciones', 'VAC', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
		
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'BVAC')		
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Bono Vacacional', 'BVAC', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)		
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'INDEM')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Indemnizacion', 'INDEM', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
		
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'VACNA')		
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Vacaciones No Afecta', 'VACNA', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'EXT')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Extraordinario', 'EXT', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'AQUI')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Anticipo Quincenal', 'AQUI', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'OIN')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Otros Ingresos', 'OIN', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'BLEY')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Bonificacion Decreto (37-2001)', 'BLEY', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'BPAC')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Bonificacion Pactada', 'BPAC', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'RETROORD')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Retroactivo de Ordinario', 'RETROORD', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'RETROBLEY')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Retroactivo de Bonificacion Decreto (37-2001)', 'RETROBLEY', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'RETROBPAC')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Retroactivo de Bonificacion Pactada', 'RETROBPAC', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'COMPORD')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Complemento de Ordinario', 'COMPORD', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'COMPBLEY')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Complemento de Bonificacion Decreto (37-2001)', 'COMPBLEY', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = 'COMPBPAC')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Complemento de Bonificacion Pactada', 'COMPBPAC', 1, 0, NULL, 'Autorizado', NULL, 0, '2011-02-07 17:51:01', 'admin', NULL, NULL)
	
	FETCH NEXT FROM companias INTO @codcia	
END

CLOSE companias
DEALLOCATE companias

COMMIT