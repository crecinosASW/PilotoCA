-- Campos Adicionales

BEGIN TRANSACTION

SET DATEFORMAT DMY

DELETE cfg.pbf_property_bag_fields WHERE pbf_entidad = 'MotivosRetiro'
DELETE cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Liquidaciones'

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'MotivosRetiro' AND pbf_field_name = 'mrt_cesantia')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('MotivosRetiro', 'mrt_cesantia', 'Cesantía', 'Indica si se paga cesantía en la liquidación', 'boolean', NULL, 'CodeCombo', NULL, NULL, 20, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'MotivosRetiro' AND pbf_field_name = 'mrt_preaviso')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('MotivosRetiro', 'mrt_preaviso', 'Preaviso', 'Indica si se paga preaviso en la liquidación', 'boolean', NULL, 'CodeCombo', NULL, NULL, 30, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'MotivosRetiro' AND pbf_field_name = 'mrt_dias_preaviso')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('MotivosRetiro', 'mrt_dias_preaviso', 'Días de Preaviso', 'Días que se le dieron al empleado de preaviso', 'double', NULL, 'DropDownList', NULL, NULL, 50, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Liquidaciones' AND pbf_field_name = 'mrt_cesantia')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Liquidaciones', 'mrt_cesantia', 'Cesantía', 'Indica si se paga cesantía en la liquidación', 'boolean', NULL, 'CodeCombo', NULL, NULL, 20, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Liquidaciones' AND pbf_field_name = 'mrt_preaviso')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Liquidaciones', 'mrt_preaviso', 'Preaviso', 'Indica si se paga preaviso en la liquidación', 'boolean', NULL, 'CodeCombo', NULL, NULL, 30, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'MotivosRetiro' AND pbf_field_name = 'Liquidaciones')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Liquidaciones', 'mrt_dias_preaviso', 'Días de Preaviso', 'Días que se le dieron al empleado de preaviso', 'double', NULL, 'DropDownList', NULL, NULL, 50, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'TiposPlanillas' AND pbf_field_name = 'tpl_codtpl_aguinaldo')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('TiposPlanillas', 'tpl_codtpl_aguinaldo', 'Tipo Planilla Aguinaldo', NULL, 'int', 'TiposPlanillasPorCompania', 'DropDownList', NULL, NULL, 0, '2015-03-26 12:02:01', 'admin', NULL, NULL)

COMMIT