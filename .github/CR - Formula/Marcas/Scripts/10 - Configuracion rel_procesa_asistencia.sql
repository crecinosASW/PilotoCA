BEGIN TRANSACTION

SET DATEFORMAT YMD

DELETE FROM spx.bep_bitacora_ejecuciones_procedimientos WHERE bep_codstp = 'rel.procesa_asistencia'
DELETE FROM spx.spr_store_procedure_roles WHERE spr_codstp = 'rel.procesa_asistencia'
DELETE FROM spx.spm_store_procedure_modulo WHERE spm_codstp = 'rel.procesa_asistencia'
DELETE FROM spx.dpp_det_param_procedimientos WHERE dpp_codstp = 'rel.procesa_asistencia'
DELETE FROM spx.stp_store_procedures WHERE stp_codigo = 'rel.procesa_asistencia'
 
INSERT spx.stp_store_procedures (stp_codigo, stp_nombre_loc_key, stp_descripcion_loc_key, stp_proc_almacenado, stp_orden, stp_codpai, stp_usuario_grabacion, stp_fecha_grabacion, stp_usuario_modificacion, stp_fecha_modificacion) 
VALUES ('rel.procesa_asistencia', 'Procedimiento para generar asistencias, tiempos no trabajados y Horas extras', 'Procedimiento para generar asistencias, tiempos no trabajados y Horas extras', 'rel.procesa_asistencia', 0, 'cr', 'admin', '2014-07-17 11:22:58', 'admin', '2014-07-17 11:55:44')

INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('rel.procesa_asistencia', 'codcia', 'Compañia', 'string', NULL, 'Compañia', 0, 5, '$$CODCIA$$', 'admin', '2014-07-17 11:58:01', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('rel.procesa_asistencia', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo de Planilla', 1, 10, NULL, 'admin', '2014-07-17 11:22:58', 'admin', '2014-07-17 11:37:44')
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('rel.procesa_asistencia', 'codppl_visual', NULL, 'string', NULL, 'Periodo de Planilla', 1, 20, NULL, 'admin', '2014-07-17 11:22:58', 'admin', '2014-07-17 11:39:51')
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('rel.procesa_asistencia', 'codexp_alternativo', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado', 1, 30, NULL, 'admin', '2014-07-17 11:22:58', 'admin', '2014-07-17 11:39:59')
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('rel.procesa_asistencia', 'usuario', 'Usuario', 'string', NULL, 'Usuario', 0, 100, '$$USER$$', 'admin', '2014-07-17 11:58:01', NULL, NULL)

INSERT spx.spm_store_procedure_modulo (spm_codstp, spm_codmod) VALUES ('rel.procesa_asistencia', 'ControlAsistencia')

INSERT spx.spr_store_procedure_roles (spr_codstp, spr_codrol) VALUES ('rel.procesa_asistencia', 'Administrador')

COMMIT