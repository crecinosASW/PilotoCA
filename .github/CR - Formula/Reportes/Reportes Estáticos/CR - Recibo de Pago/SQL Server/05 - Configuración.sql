BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRReciboPago'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRReciboPago'
 
INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('CRReciboPago', 'CR - Recibo de Pago', 'CR - Recibo de Pago', NULL, '6f140dca-05f6-46a0-876f-98b2c6c6e12d', 1, 0, 'Viewer', 'cr', 1, 'admin', '2012-04-30 11:44:00', 'admin', '2014-05-29 10:38:44')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRReciboPago', 'Salarios')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_recibo_pago', 'CRReciboPago', 'cr.rep_recibo_pago', 0, 'admin', '2012-04-30 11:44:00', 'admin', '2012-04-30 11:44:00')

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRReciboPago', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRReciboPago', 'codcia', NULL, 'small', NULL, 'Empresa', 0, 0, '$$CODCIA$$', 'admin', '2012-04-30 11:44:00', 'admin', '2012-04-30 11:47:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRReciboPago', 'codtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 10, NULL, 'admin', '2012-04-30 11:44:00', 'admin', '2012-04-30 12:17:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRReciboPago', 'codppl_visual', NULL, 'string', NULL, 'Planilla', 1, 20, NULL, 'admin', '2012-04-30 11:44:00', 'admin', '2012-04-30 11:47:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRReciboPago', 'codemp_alternativo', NULL, 'string', 'EmpleosActivosConCodigoAlternativoyEmpleo', 'Empleado', 1, 30, NULL, 'admin', '2012-04-30 10:33:00', 'admin', '2012-04-30 11:28:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRReciboPago', 'codarf', NULL, 'int', 'AreasFuncionalesDeGrupoCorporativo', 'Área Funcional', 1, 40, NULL, 'admin', '2012-04-30 11:44:00', 'admin', '2012-04-30 11:48:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRReciboPago', 'coduni', NULL, 'int', 'UnidadesDelGrupoCorporativo', 'Unidad', 1, 50, NULL, 'admin', '2012-04-30 11:44:00', 'admin', '2012-04-30 11:50:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRReciboPago', 'codcdt', NULL, 'int', 'CentrosDeTrabajoDeCompaniaSeleccionada', 'Centro de Trabajo', 1, 60, NULL, 'admin', '2012-04-30 11:44:00', 'admin', '2012-04-30 11:53:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRReciboPago', 'copias', NULL, 'int', NULL, 'No. Copias', 1, 70, NULL, 'admin', '2012-04-30 11:44:00', 'admin', '2012-04-30 11:53:00')
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRReciboPago', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 80, '$$USER$$', 'admin', '2012-04-30 14:39:00', 'admin', '2012-04-30 12:27:00')

COMMIT
