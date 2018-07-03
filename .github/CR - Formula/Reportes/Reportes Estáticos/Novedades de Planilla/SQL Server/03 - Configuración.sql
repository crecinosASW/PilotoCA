BEGIN TRANSACTION

SET DATEFORMAT YMD

DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'Novedades'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'Novedades'

INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('Novedades', 'Novedades de Planilla', NULL, NULL, '96e6105c-c69f-4ca8-9e2f-68ab4eea76cc', 1, 0, 'Viewer', NULL, 1, 'admin', '2012-04-27 11:38:00', 'admin', '2014-03-07 15:31:44')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('Novedades', 'Acciones')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('Novedades', 'Novedades', 'acc.rep_novedades_planilla', 0, 'admin', '2012-04-27 11:38:00', NULL, '2012-04-27 11:38:00')

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('Novedades', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('Novedades', 'codcia', NULL, 'int', NULL, 'Empresa', 0, 0, '$$CODCIA$$', 'admin', '2012-04-27 11:38:00', 'admin', '2012-04-27 11:40:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('Novedades', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo de Planilla', 1, 5, NULL, 'admin', '2012-04-27 11:38:00', 'admin', '2012-04-27 11:54:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('Novedades', 'codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 10, NULL, 'admin', '2012-04-27 11:38:00', 'admin', '2012-04-27 11:50:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('Novedades', 'mes', NULL, 'int', 'Meses', 'Mes', 1, 10, NULL, 'admin', '2012-04-27 11:38:00', 'admin', '2014-03-07 14:52:43')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('Novedades', 'anio', NULL, 'int', NULL, 'Año', 1, 10, NULL, 'admin', '2012-04-27 11:38:00', 'admin', '2012-04-27 11:50:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('Novedades', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 0, '$$USER$$', 'admin', '2012-04-27 11:38:00', 'admin', '2012-04-27 11:40:00')

COMMIT