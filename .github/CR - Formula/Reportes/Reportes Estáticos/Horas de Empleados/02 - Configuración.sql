BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'HorasEmpleados'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'HorasEmpleados'
 
INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) 
VALUES ('HorasEmpleados', 'Horas de Empleados', NULL, NULL, NULL, 2, NULL, 'Excel', NULL, 1, 'admin', '2015-07-13 13:46:48', 'admin', '2015-07-13 13:56:28')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('HorasEmpleados', 'ControlAsistencia')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) 
VALUES ('rep_horas_empleados', 'HorasEmpleados', 'rel.rep_horas_empleados', 0, 'admin', '2015-07-13 13:47:12', NULL, NULL)

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('HorasEmpleados', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('HorasEmpleados', 'codcia', NULL, 'int', NULL, 'Compañía', 0, 10, '$$CODCIA$$', 'admin', '2015-07-13 13:47:30', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('HorasEmpleados', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 20, NULL, 'admin', '2015-07-13 13:48:11', 'admin', '2015-07-13 13:48:23')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('HorasEmpleados', 'codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 30, NULL, 'admin', '2015-07-13 13:48:38', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('HorasEmpleados', 'codexp_alternativo', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado', 1, 40, NULL, 'admin', '2015-07-13 13:49:09', 'admin', '2015-07-13 13:49:16')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('HorasEmpleados', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 50, '$$USER$$', 'admin', '2015-07-13 13:49:34', NULL, NULL)
 
COMMIT
