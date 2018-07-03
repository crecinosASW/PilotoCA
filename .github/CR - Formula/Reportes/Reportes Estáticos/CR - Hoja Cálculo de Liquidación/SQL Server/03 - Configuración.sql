BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRHojaCalculoLiquidacion'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRHojaCalculoLiquidacion'
 
INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('CRHojaCalculoLiquidacion', 'CR - Hoja Cálculo de Liquidación', NULL, NULL, '996c582e-ef5b-4a34-81bf-ee9b14c6c7ad', 1, NULL, 'Viewer', 'cr', 1, 'admin', '2014-09-09 14:47:45', 'admin', '2014-09-09 14:56:14')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRHojaCalculoLiquidacion', 'Acciones')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_hoja_calculo_liq', 'CRHojaCalculoLiquidacion', 'cr.rep_hoja_calculo_liq', 0, 'admin', '2014-09-09 14:48:12', NULL, NULL)

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRHojaCalculoLiquidacion', 'Administrador')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRHojaCalculoLiquidacion', 'codcia', NULL, 'int', NULL, 'Compañía', 0, 10, '$$CODCIA$$', 'admin', '2014-09-09 14:48:32', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRHojaCalculoLiquidacion', 'codemp_alternativo', NULL, 'string', 'EmpleosRetirosConCodigoAlternativoyEmpleo', 'Empleado', 1, 20, NULL, 'admin', '2014-09-09 14:48:58', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRHojaCalculoLiquidacion', 'fecha_retiro_txt', 'DD/MM/YYYY', 'string', NULL, 'Fecha Retiro', 1, 30, NULL, 'admin', '2014-09-09 14:49:16', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRHojaCalculoLiquidacion', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 40, '$$USER$$', 'admin', '2014-09-09 14:49:30', NULL, NULL)

COMMIT
