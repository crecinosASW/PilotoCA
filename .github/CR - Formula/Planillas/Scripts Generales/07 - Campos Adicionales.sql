BEGIN TRANSACTION

SET DATEFORMAT YMD

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Empleos' AND pbf_field_name = 'descuentaSeguroSocial')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Empleos', 'descuentaSeguroSocial', '¿Descuenta Seguro Social?', NULL, 'boolean', NULL, 'DropDownList', NULL, NULL, 10, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Empleos' AND pbf_field_name = 'AplicaBancoPopular')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Empleos', 'AplicaBancoPopular', '¿Aplica Banco Popular?', NULL, 'boolean', NULL, 'DropDownList', NULL, NULL, 15, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Empleos' AND pbf_field_name = 'descuentaRenta')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Empleos', 'descuentaRenta', '¿Descuenta Renta?', NULL, 'boolean', NULL, 'DropDownList', NULL, NULL, 20, GETDATE(), 'admin', NULL, NULL)
	
IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Empleos' AND pbf_field_name = 'AplicaISRConyugue')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Empleos', 'AplicaISRConyugue', '¿Aplica ISR Conyugue?', 'Aplica el conyugue para el cálculo del ISR', 'boolean', NULL, 'DropDownList', NULL, NULL, 50, GETDATE(), 'admin', NULL, NULL)
	
IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Empleos' AND pbf_field_name = 'NumeroHijos')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Empleos', 'NumeroHijos', 'Número de Hijos', 'Número de hijos que aplican al ISR', 'double', NULL, 'DropDownList', NULL, NULL, 60, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Empleos' AND pbf_field_name = 'EsJubilado')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Empleos', 'EsJubilado', '¿Está Jubilado?', 'Indica si la persona está jubilada', 'boolean', NULL, 'DropDownList', NULL, NULL, 70, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Empleos' AND pbf_field_name = 'RegimenVacacion')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Empleos', 'RegimenVacacion', 'Régimen de Vacación', NULL, 'double', 'RegimenesVacacion', 'DropDownList', NULL, NULL, 80, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Empleos' AND pbf_field_name = 'emp_marca_asistencia')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Empleos', 'emp_marca_asistencia', '¿Marca Asistencia?', NULL, 'boolean', NULL, 'DropDownList', NULL, NULL, 90, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'TiposDescuentoCiclico' AND pbf_field_name = 'EsPension')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('TiposDescuentoCiclico', 'EsPension', '¿Es Pensión Alimenticia?', NULL, 'boolean', 'SiNoBooleano', 'DropDownList', NULL, NULL, 10, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'TiposDescuentoCiclico' AND pbf_field_name = 'EsEmbargo')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('TiposDescuentoCiclico', 'EsEmbargo', '¿Es Embargo?', NULL, 'boolean', 'SiNoBooleano', 'DropDownList', NULL, NULL, 20, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'RiesgosIncapacidades' AND pbf_field_name = 'UtilizaPromedio')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('RiesgosIncapacidades', 'UtilizaPromedio', '¿Utiliza Promedio?', NULL, 'boolean', NULL, 'DropDownList', NULL, NULL, 10, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Contrataciones' AND pbf_field_name = 'RegimenVacacion')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Contrataciones', 'RegimenVacacion', 'Régimen de Vacación', NULL, 'double', 'RegimenesVacacion', 'DropDownList', NULL, NULL, 10, GETDATE(), 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'Asociaciones' AND pbf_field_name = 'TipoDescuento')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('Asociaciones', 'TipoDescuento', 'Tipo Descuento', NULL, 'int', 'TodosTiposDescuentosPorCompania', 'DropDownList', NULL, NULL, 0, '2014-12-11 16:45:50', 'erickvado', NULL, NULL)
	
IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'PeriodosPlanilla' AND pbf_field_name = 'EsUltimaSemana')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('PeriodosPlanilla', 'EsUltimaSemana', '¿Es última semana?', NULL, 'boolean', NULL, 'DropDownList', NULL, NULL, 10, '2015-02-19 10:19:05', 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'TiposReserva' AND pbf_field_name = 'trs_codagr')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('TiposReserva', 'trs_codagr', 'Agrupador', NULL, 'int', 'AgrupadoresPorCompania', 'DropDownList', NULL, NULL, 0, '2013-08-07 11:45:41', 'admin', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM cfg.pbf_property_bag_fields WHERE pbf_entidad = 'TiposReserva' AND pbf_field_name = 'trs_porcentaje')
	INSERT cfg.pbf_property_bag_fields (pbf_entidad, pbf_field_name, pbf_prompt_loc_key, pbf_descripcion_loc_key, pbf_codfld, pbf_codvli, pbf_list_mode, pbf_group_loc_key, pbf_controller_action_name, pbf_orden, pbf_fecha_grabacion, pbf_usuario_grabacion, pbf_fecha_modificacion, pbf_usuario_modificacion) 
	VALUES ('TiposReserva', 'trs_porcentaje', 'Porcentaje', NULL, 'double', NULL, 'DropDownList', NULL, NULL, 10, '2013-08-07 11:46:07', 'admin', NULL, NULL)

COMMIT





	