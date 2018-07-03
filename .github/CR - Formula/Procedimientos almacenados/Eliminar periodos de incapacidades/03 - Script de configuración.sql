SET DATEFORMAT YMD

DELETE FROM spx.bep_bitacora_ejecuciones_procedimientos WHERE bep_codstp = 'acc.del_fin_fondos_incapacidad'
DELETE FROM spx.stp_store_procedures WHERE stp_codigo = 'acc.del_fin_fondos_incapacidad'

INSERT spx.stp_store_procedures (stp_codigo, stp_nombre_loc_key, stp_descripcion_loc_key, stp_proc_almacenado, stp_orden, stp_codpai, stp_usuario_grabacion, stp_fecha_grabacion, stp_usuario_modificacion, stp_fecha_modificacion) 
VALUES ('acc.del_fin_fondos_incapacidad', 'Eliminar períodos de incapacidad', 'Procedimiento para eliminar períodos de incapacidad', 'acc.del_fin_fondos_incapacidad', 20, NULL, 'csoria', '2013-04-12 11:59:05', 'csoria', '2013-04-12 12:02:46')

INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('acc.del_fin_fondos_incapacidad', 'codemp_alternativo', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado', 1, 10, NULL, 'csoria', '2013-04-12 12:01:58', NULL, NULL)
INSERT spx.dpp_det_param_procedimientos (dpp_codstp, dpp_parametro, dpp_descripcion_loc_key, dpp_codfld, dpp_codvli, dpp_prompt_loc_key, dpp_visible, dpp_orden, dpp_valor, dpp_usuario_grabacion, dpp_fecha_grabacion, dpp_usuario_modificacion, dpp_fecha_modificacion) 
VALUES ('acc.del_fin_fondos_incapacidad', 'fecha_txt', 'dd/mm/yyyy', 'string', NULL, 'Fecha (Período)', 1, 20, NULL, 'csoria', '2013-04-12 14:15:25', NULL, NULL)

INSERT spx.spm_store_procedure_modulo (spm_codstp, spm_codmod) 
VALUES ('acc.del_fin_fondos_incapacidad', 'Acciones')

INSERT spx.spr_store_procedure_roles (spr_codstp, spr_codrol) 
VALUES ('acc.del_fin_fondos_incapacidad', 'Administrador')