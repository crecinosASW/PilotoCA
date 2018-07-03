BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRPlanillaBACRevision'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRPlanillaBACRevision'
 
INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('CRPlanillaBACRevision', 'CR - Planilla BAC (Revisi�n)', NULL, NULL, 'a34773db-84cf-4814-9da7-335f1deec298', 1, NULL, 'Viewer', 'cr', 1, 'admin', '2014-09-04 17:24:06', 'admin', '2014-09-04 17:26:32')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRPlanillaBACRevision', 'Salarios')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_planilla_bac_rev', 'CRPlanillaBACRevision', 'cr.rep_planilla_bac_rev', 0, 'admin', '2014-09-04 17:24:26', NULL, NULL)

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRPlanillaBACRevision', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaBACRevision', 'codcia', NULL, 'int', NULL, 'Compa��a', 0, 10, '$$CODCIA$$', 'admin', '2014-09-04 17:24:46', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaBACRevision', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 20, NULL, 'admin', '2014-09-04 17:25:05', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaBACRevision', 'codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 30, NULL, 'admin', '2014-09-04 17:25:23', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaBACRevision', 'numero_plan', NULL, 'string', NULL, 'N�mero de Plan', 1, 40, NULL, 'admin', '2014-09-04 17:25:49', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaBACRevision', 'numero_envio', NULL, 'string', NULL, 'N�mero de Env�o', 1, 50, NULL, 'admin', '2014-09-04 17:26:06', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRPlanillaBACRevision', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 60, '$$USER$$', 'admin', '2012-04-27 14:39:00', 'admin', '2012-04-27 12:27:00')

COMMIT
