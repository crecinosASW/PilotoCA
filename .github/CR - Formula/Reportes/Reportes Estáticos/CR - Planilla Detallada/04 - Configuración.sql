BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRPlanillaDetallada'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRPlanillaDetallada'
 
INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('CRPlanillaDetallada', 'CR - Planilla Detallada', NULL, NULL, 'b8a66325-c7ff-4524-b65a-b667d5335a16', 2, NULL, 'Viewer', 'cr', 1, 'admin', '2015-02-22 21:26:14', 'admin', '2015-02-22 21:31:23')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRPlanillaDetallada', 'Salarios')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_planilla_detallada', 'CRPlanillaDetallada', 'cr.rep_planilla_detallada', 0, 'admin', '2015-02-22 21:27:08', 'admin', '2015-02-22 21:30:28')

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRPlanillaDetallada', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaDetallada', 'codcia', NULL, 'int', NULL, 'Compañía', 0, 0, '$$CODCIA$$', 'admin', '2015-02-22 21:27:33', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaDetallada', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 10, NULL, 'admin', '2015-02-22 21:27:59', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaDetallada', 'codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 20, NULL, 'admin', '2015-02-22 21:28:12', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaDetallada', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 30, '$$USER$$', 'admin', '2015-02-22 21:28:27', NULL, NULL)

COMMIT