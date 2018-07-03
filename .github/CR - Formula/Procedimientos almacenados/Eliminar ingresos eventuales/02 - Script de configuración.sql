SET DATEFORMAT YMD

DELETE FROM spx.bep_bitacora_ejecuciones_procedimientos WHERE bep_codstp = 'sal.del_oin_otros_ingresos'
DELETE FROM spx.stp_store_procedures WHERE stp_codigo = 'sal.del_oin_otros_ingresos'

INSERT [spx].[stp_store_procedures] ([stp_codigo], [stp_nombre_loc_key], [stp_descripcion_loc_key], [stp_proc_almacenado], [stp_orden], [stp_codpai], [stp_usuario_grabacion], [stp_fecha_grabacion], [stp_usuario_modificacion], [stp_fecha_modificacion]) 
VALUES ('sal.del_oin_otros_ingresos', 'Eliminar ingresos eventuales', 'Procedimiento para eliminar ingresos eventuales de un período de planilla', 'sal.del_oin_otros_ingresos', 20, NULL, 'admin', '2013-08-16 11:35:35', 'admin', '2013-08-16 11:38:36')
 
INSERT [spx].[dpp_det_param_procedimientos] ([dpp_codstp], [dpp_parametro], [dpp_descripcion_loc_key], [dpp_codfld], [dpp_codvli], [dpp_prompt_loc_key], [dpp_visible], [dpp_orden], [dpp_valor], [dpp_usuario_grabacion], [dpp_fecha_grabacion], [dpp_usuario_modificacion], [dpp_fecha_modificacion]) 
VALUES ('sal.del_oin_otros_ingresos', '@codcia', NULL, 'int', NULL, 'Empresa', 0, 0, '$$CODCIA$$', 'admin', '2013-08-16 11:37:12', NULL, NULL)
INSERT [spx].[dpp_det_param_procedimientos] ([dpp_codstp], [dpp_parametro], [dpp_descripcion_loc_key], [dpp_codfld], [dpp_codvli], [dpp_prompt_loc_key], [dpp_visible], [dpp_orden], [dpp_valor], [dpp_usuario_grabacion], [dpp_fecha_grabacion], [dpp_usuario_modificacion], [dpp_fecha_modificacion]) 
VALUES ('sal.del_oin_otros_ingresos', '@codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 10, NULL, 'admin', '2013-08-16 11:37:34', NULL, NULL)
INSERT [spx].[dpp_det_param_procedimientos] ([dpp_codstp], [dpp_parametro], [dpp_descripcion_loc_key], [dpp_codfld], [dpp_codvli], [dpp_prompt_loc_key], [dpp_visible], [dpp_orden], [dpp_valor], [dpp_usuario_grabacion], [dpp_fecha_grabacion], [dpp_usuario_modificacion], [dpp_fecha_modificacion]) 
VALUES ('sal.del_oin_otros_ingresos', '@codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 20, NULL, 'admin', '2013-08-16 11:37:50', NULL, NULL)
INSERT [spx].[dpp_det_param_procedimientos] ([dpp_codstp], [dpp_parametro], [dpp_descripcion_loc_key], [dpp_codfld], [dpp_codvli], [dpp_prompt_loc_key], [dpp_visible], [dpp_orden], [dpp_valor], [dpp_usuario_grabacion], [dpp_fecha_grabacion], [dpp_usuario_modificacion], [dpp_fecha_modificacion]) 
VALUES ('sal.del_oin_otros_ingresos', '@codemp_alternativo', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado', 1, 30, NULL, 'admin', '2013-08-16 11:38:10', NULL, NULL)

INSERT [spx].[spm_store_procedure_modulo] ([spm_codstp], [spm_codmod]) 
VALUES ('sal.del_oin_otros_ingresos', 'Salarios')

INSERT [spx].[spr_store_procedure_roles] ([spr_codstp], [spr_codrol]) 
VALUES ('sal.del_oin_otros_ingresos', 'Administrador')