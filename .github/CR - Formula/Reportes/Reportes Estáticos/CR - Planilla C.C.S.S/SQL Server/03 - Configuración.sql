BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRPlanillaCCSS'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRPlanillaCCSS'
 
INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('CRPlanillaCCSS', 'CR - Planilla C.C.S.S', NULL, NULL, NULL, 4, NULL, 'Texto', 'cr', 1, 'admin', '2013-09-18 12:04:09', 'admin', '2014-09-09 10:32:11')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRPlanillaCCSS', 'Salarios')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_planilla_ccss', 'CRPlanillaCCSS', 'cr.rep_planilla_ccss', 0, 'admin', '2013-09-18 12:04:41', 'admin', '2014-09-09 10:32:06')

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRPlanillaCCSS', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaCCSS', 'codpai', NULL, 'string', 'TodosPaises', 'Pais', 1, 0, 'cr', 'admin', '2013-09-18 12:06:20', 'admin', '2013-09-18 12:10:23')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaCCSS', 'mes', NULL, 'int', 'Meses', 'Mes', 1, 30, NULL, 'admin', '2014-09-05 12:19:06', 'admin', '2014-09-05 12:19:13')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaCCSS', 'anio', NULL, 'int', NULL, 'Año', 1, 40, NULL, 'admin', '2014-09-05 12:19:28', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaCCSS', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 70, '$$USER$$', 'admin', '2014-09-05 12:20:24', NULL, NULL)

COMMIT
