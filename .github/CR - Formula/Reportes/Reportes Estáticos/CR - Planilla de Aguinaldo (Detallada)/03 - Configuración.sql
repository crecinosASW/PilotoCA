BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRPlanillaAguinaldoDetallada'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRPlanillaAguinaldoDetallada'
 
INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) 
VALUES ('CRPlanillaAguinaldoDetallada', 'CR - Planilla de Aguinaldo (Detallada)', 'CR - Planilla de Aguinaldo (Detallada)', NULL, NULL, 1, 0, 'Viewer', 'cr', 1, 'admin', '2012-04-27 15:19:00', 'admin', '2014-09-04 16:45:25')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRPlanillaAguinaldoDetallada', 'Salarios')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) 
VALUES ('rep_planilla_aguinaldo_det', 'CRPlanillaAguinaldoDetallada', 'cr.rep_planilla_aguinaldo_det', 0, 'admin', '2012-04-27 15:19:00', NULL, '2012-04-27 15:19:00')

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRPlanillaAguinaldoDetallada', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('CRPlanillaAguinaldoDetallada', 'codcia', NULL, 'int', NULL, 'Empresa', 0, 0, '$$CODCIA$$', 'admin', '2012-04-27 15:19:00', 'admin', '2012-04-27 15:23:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('CRPlanillaAguinaldoDetallada', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 5, NULL, 'admin', '2012-04-27 15:19:00', 'admin', '2012-04-27 16:05:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('CRPlanillaAguinaldoDetallada', 'codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 10, NULL, 'admin', '2012-04-27 15:19:00', 'admin', '2012-04-27 15:24:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('CRPlanillaAguinaldoDetallada', 'codarf', NULL, 'int', 'AreasFuncionalesDeGrupoCorporativo', 'Área Funcional', 1, 15, NULL, 'admin', '2012-04-27 15:19:00', 'admin', '2012-04-27 15:25:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('CRPlanillaAguinaldoDetallada', 'coduni', NULL, 'int', 'UnidadesDelGrupoCorporativo', 'Unidad', 1, 20, NULL, 'admin', '2012-04-27 15:19:00', 'admin', '2012-04-27 15:25:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) 
VALUES ('CRPlanillaAguinaldoDetallada', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 25, '$$USER$$', 'admin', '2012-04-27 14:39:00', 'admin', '2012-04-27 12:27:00')

COMMIT