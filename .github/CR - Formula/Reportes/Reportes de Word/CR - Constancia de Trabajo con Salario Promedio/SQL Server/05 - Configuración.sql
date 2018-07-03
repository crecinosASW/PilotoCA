BEGIN TRANSACTION

SET DATEFORMAT YMD

DELETE wrp.bwr_bitacora_word_rep WHERE bwr_codwrd = 'CRConstanciaTrabajoSalarioPromedio'
DELETE wrp.wrd_word_templates WHERE wrd_codigo = 'CRConstanciaTrabajoSalarioPromedio'

INSERT wrp.wrd_word_templates (wrd_codigo, wrd_nombre_loc_key, wrd_descripcion_loc_key, wrd_codupf, wrd_codpai, wrd_tipo_origen_datos, wrd_fecha_grabacion, wrd_usuario_grabacion, wrd_fecha_modificacion, wrd_usuario_modificacion) VALUES ('CRConstanciaTrabajoSalarioPromedio', 'CR - Constancia de Trabajo con Salario Promedio', 'CR - Constancia de Trabajo con Salario Promedio', '86d6d745-f5cd-4672-9802-8133beb86ba2', 'cr', 1, '2015-04-13 15:30:58', 'admin', NULL, NULL)

INSERT wrp.ddw_det_datasources_word (ddw_nombre, ddw_codwrd, ddw_origen_datos, ddw_es_principal, ddw_campos_join_pk, ddw_campos_join_fk, ddw_usuario_grabacion, ddw_fecha_grabacion, ddw_usuario_modificacion, ddw_fecha_modificacion) VALUES ('rep_const_trab_salario_prom', 'CRConstanciaTrabajoSalarioPromedio', 'cr.rep_const_trab_salario_prom', 1, NULL, NULL, 'admin', '2014-09-22 17:21:34', 'admin', '2014-09-22 17:21:40')

INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaTrabajoSalarioPromedio', 'codcia', NULL, 'int', NULL, 'Compañía', 0, 10, '$$CODCIA$$', 'admin', '2014-09-22 17:21:57', NULL, NULL)
INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaTrabajoSalarioPromedio', 'codemp_alternativo', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado', 1, 20, NULL, 'admin', '2014-09-22 17:22:20', NULL, NULL)
INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaTrabajoSalarioPromedio', 'codemp_alternativo_firma', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado que Firma', 1, 30, NULL, 'admin', '2014-09-22 17:22:38', NULL, NULL)
INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaTrabajoSalarioPromedio', 'ciudad', NULL, 'string', NULL, 'Ciudad', 1, 40, NULL, 'admin', '2014-09-22 17:22:52', NULL, NULL)
INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaTrabajoSalarioPromedio', 'fecha_txt', 'DD/MM/YYYY', 'string', NULL, 'Fecha', 1, 50, NULL, 'admin', '2014-09-22 17:23:12', NULL, NULL)
INSERT wrp.dpw_det_parametros_word (dpw_codwrd, dpw_parametro, dpw_descripcion_loc_key, dpw_codfld, dpw_codvli, dpw_prompt_loc_key, dpw_visible, dpw_orden, dpw_valor, dpw_usuario_grabacion, dpw_fecha_grabacion, dpw_usuario_modificacion, dpw_fecha_modificacion) VALUES ('CRConstanciaTrabajoSalarioPromedio', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 60, '$$USER$$', 'admin', '2014-09-22 17:23:28', NULL, NULL)

INSERT wrp.wrm_word_modulos (wrm_codwrd, wrm_codmod) VALUES ('CRConstanciaTrabajoSalarioPromedio', 'Expedientes')

INSERT wrp.wrr_word_roles (wrr_codwrd, wrr_codrol) VALUES ('CRConstanciaTrabajoSalarioPromedio', 'Administrador')

COMMIT