BEGIN TRANSACTION

SET DATEFORMAT YMD

DELETE FROM spx.bep_bitacora_ejecuciones_procedimientos WHERE bep_codstp = 'sal.del_sre_serv_realizados'
DELETE FROM spx.stp_store_procedures WHERE stp_codigo = 'sal.del_sre_serv_realizados'

INSERT spx.stp_store_procedures (stp_codigo, stp_nombre_loc_key, stp_descripcion_loc_key, stp_proc_almacenado, stp_orden, stp_codpai, stp_usuario_grabacion, stp_fecha_grabacion, stp_usuario_modificacion, stp_fecha_modificacion) 
VALUES ('sal.del_sre_serv_realizados', 'Eliminar servicios realizados', 'Procedimiento para eliminar servicios realizados de un período de planilla', 'sal.del_sre_serv_realizados', 30, NULL, 'admin', '2013-08-16 11:35:35', 'admin', '2014-02-27 09:23:51')

INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_sre_serv_realizados', '@codcia', NULL, 'int', NULL, 'Empresa', 0, 0, '$$CODCIA$$', 'admin', '2013-08-16 11:37:12', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_sre_serv_realizados', '@codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 10, NULL, 'admin', '2013-08-16 11:37:34', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_sre_serv_realizados', '@codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 20, NULL, 'admin', '2013-08-16 11:37:50', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_sre_serv_realizados', '@codemp_alternativo', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado', 1, 30, NULL, 'admin', '2013-08-16 11:38:10', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_sre_serv_realizados', '@codsrv', NULL, 'int', 'ServiciosPorCompania', 'Servicio', 1, 50, NULL, 'admin', '2014-02-27 08:56:40', 'admin', '2014-02-27 09:23:46')
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_sre_serv_realizados', '@fecha_txt', NULL, 'string', NULL, 'Fecha', 1, 60, NULL, 'admin', '2014-02-27 08:56:54', NULL, NULL)

INSERT spx.spm_store_procedure_modulo (spm_codstp, spm_codmod) VALUES ('sal.del_sre_serv_realizados', 'Salarios')

INSERT spx.spr_store_procedure_roles (spr_codstp, spr_codrol) VALUES ('sal.del_sre_serv_realizados', 'Administrador')

COMMIT