SET DATEFORMAT YMD

DELETE FROM spx.bep_bitacora_ejecuciones_procedimientos WHERE bep_codstp = 'sal.del_ext_horas_extras'
DELETE FROM spx.stp_store_procedures WHERE stp_codigo = 'sal.del_ext_horas_extras'

INSERT spx.stp_store_procedures (stp_codigo, stp_nombre_loc_key, stp_descripcion_loc_key, stp_proc_almacenado, stp_orden, stp_codpai, stp_usuario_grabacion, stp_fecha_grabacion, stp_usuario_modificacion, stp_fecha_modificacion) 
VALUES ('sal.del_ext_horas_extras', 'Eliminar horas extras', 'Procedimiento para eliminar horas extras de un período de planilla', 'sal.del_ext_horas_extras', 20, NULL, 'csoria', '2013-04-12 11:59:05', 'csoria', '2013-04-12 12:02:46')

INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_ext_horas_extras', 'codcia', NULL, 'int', NULL, 'Empresa', 0, 0, '$$CODCIA$$', 'csoria', '2013-04-12 12:00:55', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_ext_horas_extras', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 10, NULL, 'csoria', '2013-04-12 12:01:20', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_ext_horas_extras', 'codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 30, NULL, 'csoria', '2013-04-12 12:01:31', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_ext_horas_extras', 'codemp_alternativo', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado', 1, 30, NULL, 'csoria', '2013-04-12 12:01:58', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_ext_horas_extras', 'fecha_txt', 'dd/mm/yyyy', 'string', NULL, 'Fecha (Opcional)', 1, 50, NULL, 'csoria', '2013-04-12 14:15:25', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('sal.del_ext_horas_extras', 'codthe', NULL, 'int', 'TiposHoraExtraPorCompania', 'Tipo (Opcional)', 1, 50, NULL, 'csoria', '2013-04-12 14:20:40', NULL, NULL)

INSERT spx.spm_store_procedure_modulo (spm_codstp, spm_codmod) 
VALUES ('sal.del_ext_horas_extras', 'Salarios')

INSERT spx.spr_store_procedure_roles (spr_codstp, spr_codrol) 
VALUES ('sal.del_ext_horas_extras', 'Administrador')