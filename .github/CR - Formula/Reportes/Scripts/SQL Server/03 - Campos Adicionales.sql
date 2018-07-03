-- Campos Adicionales

SET DATEFORMAT YMD

BEGIN TRANSACTION

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Jornadas' AND pbf_field_name = 'CodigoINS')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Jornadas', 'CodigoINS', 'Tipo para Planilla INS', NULL, 'string', 'TiposJornadaLaboralINS', 'DropDownList', NULL, NULL, 10, '2014-09-05 14:08:10', 'admin', '2014-09-05 14:12:11', 'admin')

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Jornadas' AND pbf_field_name = 'CodigoCCSS')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Jornadas', 'CodigoCCSS', 'Tipo para Planilla CCSS', NULL, 'string', 'TiposJornadaLaboralCCSS', 'DropDownList', NULL, NULL, 20, '2014-09-08 15:49:35', 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Jornadas' AND pbf_field_name = 'HorasDia')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Jornadas', 'HorasDia', 'Horas por Día', NULL, 'double', NULL, 'DropDownList', NULL, NULL, 30, '2014-09-08 15:50:20', 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Puestos' AND pbf_field_name = 'CodigoINS')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Puestos', 'CodigoINS', 'Código para Planilla INS', NULL, 'string', NULL, 'DropDownList', NULL, NULL, 20, '2014-09-05 14:39:40', 'admin', NULL, NULL)

COMMIT