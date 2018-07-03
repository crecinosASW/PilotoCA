BEGIN TRANSACTION
 
SET DATEFORMAT YMD
 
DELETE FROM rep.brp_bitacora_reportes WHERE brp_codrep = 'CRCalculoPrestacionesLaborales'
DELETE FROM rep.rep_reportes WHERE rep_codigo = 'CRCalculoPrestacionesLaborales'

INSERT rep.rep_reportes (rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('CRCalculoPrestacionesLaborales', 'CR - Cálculo de Prestaciones Laborales', NULL, NULL, '6bfdfce3-7f72-4f9f-89d5-d5d746a5cffa', 2, NULL, 'Viewer', 'cr', 1, 'admin', '2015-04-21 14:06:07', 'admin', '2015-04-21 14:09:53')

INSERT rep.rpm_reportes_modulos (rpm_codrep, rpm_codmod) VALUES ('CRCalculoPrestacionesLaborales', 'Acciones')

INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_calculo_liq_encabezado', 'CRCalculoPrestacionesLaborales', 'cr.rep_calculo_liq_encabezado', 1, 'admin', '2015-04-21 14:06:39', 'admin', '2015-04-21 14:07:15')
INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_calculo_liq_detalle', 'CRCalculoPrestacionesLaborales', 'cr.rep_calculo_liq_detalle', 2, 'admin', '2015-04-21 14:07:00', 'admin', '2015-04-21 14:07:21')
INSERT rep.ddr_det_datasources_reportes (ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion) VALUES ('rep_calculo_liq_aguinaldo', 'CRCalculoPrestacionesLaborales', 'cr.rep_calculo_liq_aguinaldo', 3, 'admin', '2015-04-21 14:07:30', NULL, NULL)

INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRCalculoPrestacionesLaborales', 'Administrador')
INSERT rep.rpr_reportes_roles (rpr_codrep, rpr_codrol) VALUES ('CRCalculoPrestacionesLaborales', 'Planilla')

INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRCalculoPrestacionesLaborales', 'codcia', NULL, 'int', NULL, 'Compañía', 0, 10, '$$CODCIA$$', 'admin', '2015-04-21 14:07:52', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRCalculoPrestacionesLaborales', 'codemp_alternativo', NULL, 'string', 'EmpleosRetirosConCodigoAlternativoyEmpleo', 'Empleado', 1, 20, NULL, 'admin', '2015-04-21 14:08:13', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRCalculoPrestacionesLaborales', 'fecha_retiro_txt', 'DD/MM/YYYY', 'string', NULL, 'Fecha Retiro', 1, 30, NULL, 'admin', '2015-04-21 14:08:34', NULL, NULL)
INSERT rep.dpr_det_parametros_reportes (dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion) VALUES ('CRCalculoPrestacionesLaborales', 'usuario', NULL, 'string', NULL, 'Usuario', 0, 40, '$$USER$$', 'admin', '2015-04-21 14:09:10', NULL, NULL)
 
COMMIT
