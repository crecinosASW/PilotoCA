BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRAccionPersonalIncremento'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRAccionPersonalIncremento'
 
INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('CRAccionPersonalIncremento', 'CR - Acción de Personal - Incremento', NULL, NULL, '38aa9a81-e9fd-4071-8b42-59022a7f0cec', 2, NULL, 'Viewer', 'cr', 1, 'admin', '2015-02-22 21:26:14', 'admin', '2015-03-24 15:07:12')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRAccionPersonalIncremento', 'Acciones')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_accion_incremento', 'CRAccionPersonalIncremento', 'cr.rep_accion_incremento', 0, 'admin', '2015-02-22 21:27:08', 'admin', '2015-02-22 21:30:28')

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRAccionPersonalIncremento', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRAccionPersonalIncremento', 'codcia', NULL, 'int', NULL, 'Compañía', 0, 0, '$$CODCIA$$', 'admin', '2015-02-22 21:27:33', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRAccionPersonalIncremento', 'codemp_alternativo', NULL, 'string', 'EmpleosConCodigoAlternativoyEmpleo', 'Empleado', 1, 10, NULL, 'admin', '2015-02-23 10:52:47', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRAccionPersonalIncremento', 'fecha_txt', 'DD/MM/YYYY', 'string', NULL, 'Fecha Vigencia', 1, 20, NULL, 'admin', '2015-02-24 08:47:09', 'admin', '2015-03-24 09:58:20')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRAccionPersonalIncremento', 'comentario', NULL, 'string', NULL, 'Comentario', 1, 30, NULL, 'admin', '2015-02-24 08:47:23', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRAccionPersonalIncremento', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 40, '$$USER$$', 'admin', '2015-02-22 21:28:27', 'admin', '2015-02-24 08:47:29')

COMMIT