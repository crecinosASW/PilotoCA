SET DATEFORMAT YMD

DELETE FROM spx.bep_bitacora_ejecuciones_procedimientos WHERE bep_codstp = 'sal.genera_hist_planillas'
DELETE FROM spx.stp_store_procedures WHERE stp_codigo = 'sal.genera_hist_planillas'

INSERT spx.stp_store_procedures (stp_codigo, stp_nombre_loc_key, stp_descripcion_loc_key, stp_proc_almacenado, stp_orden, stp_codpai, stp_usuario_grabacion, stp_fecha_grabacion, stp_usuario_modificacion, stp_fecha_modificacion) 
VALUES ('sal.genera_hist_planillas', 'Genera histórico de planillas', 'Procedimiento para generar el histórico de planillas para planillas que se importaron y para que puedan ser visualizadas en la consulta de historial de pagos', 'sal.genera_hist_planillas', 40, NULL, 'admin', '2013-08-16 11:42:40', 'admin', '2013-08-16 11:44:47')

INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.genera_hist_planillas', '@codcia', NULL, 'int', NULL, 'Empresa', 0, 0, '$$CODCIA$$', 'admin', '2013-08-16 11:43:20', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.genera_hist_planillas', '@codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 10, NULL, 'admin', '2013-08-16 11:43:43', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.genera_hist_planillas', '@codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 20, NULL, 'admin', '2013-08-16 11:43:58', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.genera_hist_planillas', '@username', NULL, 'string', NULL, 'Usuario', 0, 30, '$$USER$$', 'admin', '2013-08-16 11:44:19', NULL, NULL)

INSERT spx.spm_store_procedure_modulo (spm_codstp, spm_codmod) 
VALUES ('sal.genera_hist_planillas', 'Salarios')

INSERT spx.spr_store_procedure_roles (spr_codstp, spr_codrol) 
VALUES ('sal.genera_hist_planillas', 'Administrador')