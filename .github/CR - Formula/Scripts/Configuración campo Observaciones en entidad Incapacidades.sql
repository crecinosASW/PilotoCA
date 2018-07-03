BEGIN TRANSACTION

SET DATEFORMAT YMD

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Incapacidades' AND pbf_field_name = 'Observaciones')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Incapacidades', 'Observaciones', 'Observaciones', NULL, 'string', NULL, 'DropDownList', NULL, NULL, 0, '2015-03-18 15:45:54', 'admin', NULL, NULL)

COMMIT