BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRPlanillaQuincenal'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRPlanillaQuincenal'

INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('CRPlanillaQuincenal', 'CR - Planilla Quincenal', 'CR - Planilla Quincenal', NULL, '310b195b-06fc-4540-ae63-ccaa8d2e11e3', 1, 0, 'Viewer', 'cr', 1, 'admin', '2012-04-30 09:56:00', 'admin', '2014-05-28 14:52:18')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRPlanillaQuincenal', 'Salarios')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_planilla_quincenal', 'CRPlanillaQuincenal', 'cr.rep_planilla_quincenal', 0, 'admin', '2012-04-30 09:56:00', 'admin', '2014-05-28 13:22:00')

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRPlanillaQuincenal', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaQuincenal', 'codcia', NULL, 'int', NULL, 'Empresa', 0, 0, '$$CODCIA$$', 'admin', '2012-04-30 09:56:00', 'admin', '2013-09-09 14:14:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaQuincenal', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 10, NULL, 'admin', '2012-04-30 09:56:00', 'admin', '2012-04-30 10:17:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaQuincenal', 'codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 20, NULL, 'admin', '2012-04-30 09:56:00', 'admin', '2012-04-30 10:02:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaQuincenal', 'codarf', NULL, 'small', 'AreasFuncionalesDeGrupoCorporativo', '�rea Funcional', 1, 30, NULL, 'admin', '2012-04-30 09:56:00', 'admin', '2012-04-30 10:00:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaQuincenal', 'coduni', NULL, 'int', 'UnidadesDelGrupoCorporativo', 'Unidad', 1, 40, NULL, 'admin', '2012-04-30 09:56:00', 'admin', '2012-04-30 10:01:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaQuincenal', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 50, '$$USER$$', 'admin', '2012-04-27 14:39:00', 'admin', '2012-04-27 12:27:00')

COMMIT
