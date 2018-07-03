BEGIN TRANSACTION

SET DATEFORMAT YMD

DELETE FROM spx.bep_bitacora_ejecuciones_procedimientos WHERE bep_codstp = 'rel.procesa_marcas'
DELETE FROM spx.spr_store_procedure_roles WHERE spr_codstp = 'rel.procesa_marcas'
DELETE FROM spx.spm_store_procedure_modulo WHERE spm_codstp = 'rel.procesa_marcas'
DELETE FROM spx.dpp_det_param_procedimientos WHERE dpp_codstp = 'rel.procesa_marcas'
DELETE FROM spx.stp_store_procedures WHERE stp_codigo = 'rel.procesa_marcas'
 
INSERT spx.stp_store_procedures (stp_codigo, stp_nombre_loc_KEY, stp_descripcion_loc_KEY, stp_PROC_almacenado, stp_orden, stp_codpai, stp_usuario_grabacion, stp_fecha_grabacion, stp_usuario_modificacion, stp_fecha_modificacion) 
VALUES ('rel.procesa_marcas', 'Procedimiento para procesar Marcas y generar asistencias', 'Procedimiento para procesar Marcas y generar asistencias', 'rel.procesa_marcas', 0, 'cr', 'admin', '2014-07-17 11:22:58', 'admin', '2014-07-17 11:55:44')

INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_KEY, dpp_codfld, dpp_codvli, dpp_prompt_loc_KEY, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('rel.procesa_marcas', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo de Planilla', 1, 10, NULL, 'admin', '2014-07-17 11:22:58', 'admin', '2014-07-17 11:37:44')
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_KEY, dpp_codfld, dpp_codvli, dpp_prompt_loc_KEY, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('rel.procesa_marcas', 'codppl_visual', NULL, 'string', NULL, 'Periodo de Planilla', 1, 20, NULL, 'admin', '2014-07-17 11:22:58', 'admin', '2014-07-17 11:39:51')
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_KEY, dpp_codfld, dpp_codvli, dpp_prompt_loc_KEY, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('rel.procesa_marcas', 'codexp_alternativo', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado', 1, 30, NULL, 'admin', '2014-07-17 11:22:58', 'admin', '2014-07-17 11:39:59')
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_KEY, dpp_codfld, dpp_codvli, dpp_prompt_loc_KEY, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('rel.procesa_marcas', 'codcia', 'Compañia', 'int', NULL, 'Compañia', 0, 1, '$$CODCIA$$', 'admin', '2014-07-17 11:55:12', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_KEY, dpp_codfld, dpp_codvli, dpp_prompt_loc_KEY, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('rel.procesa_marcas', 'usuario', 'Usuario', 'string', NULL, 'Usuario', 0, 100, '$$USER$$', 'admin', '2014-07-17 11:58:01', NULL, NULL)

INSERT spx.spm_store_procedure_modulo (spm_codstp, spm_codmod) VALUES ('rel.procesa_marcas', 'ControlAsistencia')

INSERT spx.spr_store_procedure_roles (spr_codstp, spr_codrol) VALUES ('rel.procesa_marcas', 'Administrador')

COMMIT