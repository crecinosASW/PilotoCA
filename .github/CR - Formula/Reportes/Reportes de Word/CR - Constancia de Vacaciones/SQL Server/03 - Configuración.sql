BEGIN TRANSACTION

SET DATEFORMAT YMD

DELETE wrp.bwr_bitacora_word_rep WHERE bwr_codwrd = 'CRConstanciaVacaciones'
DELETE wrp.wrd_word_templates WHERE wrd_codigo = 'CRConstanciaVacaciones'

INSERT wrp.wrd_word_templates (wrd_codigo, wrd_nombre_loc_key, wrd_descripcion_loc_key, wrd_codupf, wrd_codpai, wrd_tipo_origen_datos, wrd_fecha_grabacion, wrd_usuario_grabacion, wrd_fecha_modificacion, wrd_usuario_modificacion) VALUES ('CRConstanciaVacaciones', 'CR - Constancia de Vacaciones', 'CR - Constancia de Vacaciones', '23d88b41-9bde-49f9-a2bd-c3af5997839a', 'cr', 1, '2014-09-23 09:32:31', 'admin', NULL, NULL)

INSERT wrp.ddw_det_datasources_word (ddw_nombre, ddw_codwrd, ddw_origen_datos, ddw_es_principal, ddw_campos_join_pk, ddw_campos_join_fk, ddw_usuario_grabacion, ddw_fecha_grabacion, ddw_usuario_modificacion, ddw_fecha_modificacion) VALUES ('rep_constancia_vacaciones', 'CRConstanciaVacaciones', 'cr.rep_constancia_vacaciones', 1, NULL, NULL, 'admin', '2014-09-22 17:21:34', 'admin', '2014-09-22 17:21:40')

INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaVacaciones', 'codcia', NULL, 'int', NULL, 'Compañía', 0, 10, '$$CODCIA$$', 'admin', '2014-09-22 17:21:57', NULL, NULL)
INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaVacaciones', 'codemp_alternativo', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado', 1, 20, NULL, 'admin', '2014-09-22 17:22:20', 'jcsoria', '2014-09-23 09:10:00')
INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaVacaciones', 'codemp_alternativo_firma', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado que Firma', 1, 30, NULL, 'admin', '2014-09-22 17:22:38', NULL, NULL)
INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaVacaciones', 'fecha_ini_txt', 'DD/MM/YYYY', 'string', NULL, 'Fecha', 1, 40, NULL, 'admin', '2014-09-22 17:23:12', NULL, NULL)
INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaVacaciones', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 50, '$$USER$$', 'admin', '2014-09-22 17:23:28', NULL, NULL)

INSERT wrp.wrm_word_modulos (wrm_codwrd, wrm_codmod) VALUES ('CRConstanciaVacaciones', 'Acciones')

INSERT wrp.wrr_word_roles (wrr_codwrd, wrr_codrol) VALUES ('CRConstanciaVacaciones', 'Administrador')

COMMIT