BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRAccionPersonalReconocimiento'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRAccionPersonalReconocimiento'

INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('CRAccionPersonalReconocimiento', 'CR - Acción de Personal - Reconocimiento', NULL, NULL, 'c5efda38-e59c-4df0-9d91-6b41d0ae766a', 2, NULL, 'Viewer', 'cr', 1, 'admin', '2015-02-22 21:26:14', 'admin', '2015-03-24 15:32:18')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRAccionPersonalReconocimiento', 'Acciones')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_accion_reconocimiento', 'CRAccionPersonalReconocimiento', 'cr.rep_accion_reconocimiento', 0, 'admin', '2015-02-22 21:27:08', 'admin', '2015-02-22 21:30:28')

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRAccionPersonalReconocimiento', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRAccionPersonalReconocimiento', 'codcia', NULL, 'int', NULL, 'Compañía', 0, 0, '$$CODCIA$$', 'admin', '2015-02-22 21:27:33', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRAccionPersonalReconocimiento', 'codemp_alternativo', NULL, 'string', 'EmpleosConCodigoAlternativoyEmpleo', 'Empleado', 1, 10, NULL, 'admin', '2015-02-23 10:52:47', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRAccionPersonalReconocimiento', 'fecha_txt', 'DD/MM/YYYY', 'string', NULL, 'Fecha de Mérito', 1, 20, NULL, 'admin', '2015-02-24 08:47:09', 'admin', '2015-03-24 09:58:20')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRAccionPersonalReconocimiento', 'comentario', NULL, 'string', NULL, 'Comentario', 1, 30, NULL, 'admin', '2015-02-24 08:47:23', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRAccionPersonalReconocimiento', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 40, '$$USER$$', 'admin', '2015-02-22 21:28:27', 'admin', '2015-02-24 08:47:29')

COMMIT