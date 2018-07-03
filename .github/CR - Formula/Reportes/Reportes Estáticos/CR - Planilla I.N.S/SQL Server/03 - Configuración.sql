BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRPlanillaINS'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRPlanillaINS'
 
INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('CRPlanillaINS', 'CR - Planilla I.N.S', NULL, NULL, NULL, 4, NULL, 'Texto', 'cr', 1, 'admin', '2014-09-05 12:17:42', 'admin', '2014-09-05 12:20:53')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRPlanillaINS', 'Salarios')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_planilla_ins', 'CRPlanillaINS', 'cr.rep_planilla_ins', 0, 'admin', '2014-09-05 12:18:03', NULL, NULL)

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRPlanillaINS', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaINS', 'codcia', NULL, 'int', NULL, 'Compañía', 0, 10, '$$CODCIA$$', 'admin', '2014-09-05 12:18:20', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaINS', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 20, NULL, 'admin', '2014-09-05 12:18:46', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaINS', 'mes', NULL, 'int', 'Meses', 'Mes', 1, 30, NULL, 'admin', '2014-09-05 12:19:06', 'admin', '2014-09-05 12:19:13')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaINS', 'anio', NULL, 'int', NULL, 'Año', 1, 40, NULL, 'admin', '2014-09-05 12:19:28', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaINS', 'poliza', NULL, 'string', NULL, 'Póliza', 1, 50, NULL, 'admin', '2014-09-05 12:19:42', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaINS', 'correlativo', NULL, 'string', NULL, 'Correlativo', 1, 60, NULL, 'admin', '2014-09-05 12:19:58', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaINS', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 70, '$$USER$$', 'admin', '2014-09-05 12:20:24', NULL, NULL)

COMMIT
