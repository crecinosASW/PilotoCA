BEGIN TRANSACTION

SET DATEFORMAT YMD

DELETE wrp.bre_bitacora_reportes WHERE EXISTS (SELECT NULL FROM wrp.rep_reportes WHERE rep_repid = bre_codrep AND rep_setkey = 'ContabilizacionCR')
DELETE wrp.rep_reportes WHERE rep_setkey = 'ContabilizacionCR'
DELETE wrp.sdf_set_fields WHERE sdf_setkey = 'ContabilizacionCR'
DELETE wrp.sdr_set_roles WHERE sdr_setkey = 'ContabilizacionCR'
DELETE wrp.sdm_set_modules WHERE sdm_setkey = 'ContabilizacionCR'
DELETE wrp.set_sets WHERE set_setkey = 'ContabilizacionCR'

INSERT wrp.set_sets (set_setkey, set_nombre, set_target_tabla_cruzada, set_descripcion, set_namedef, set_titulodef, set_subtitulodef, set_tableview_name, set_addtowhere, set_usuario_grabacion, set_fecha_grabacion, set_usuario_modificacion, set_fecha_modificacion) VALUES ('ContabilizacionCR', 'Información sobre contabilización (Costa Rica)', 0, 'Información sobre contabilización (Costa Rica)', 'Información sobre contabilización', 'Información sobre contabilización', NULL, 'cr.set_dco_datos_contables', 'sco.permiso_tipo_planilla(ppl_codtpl, ''$$USER$$'') = 1', NULL, NULL, 'admin', '2013-08-02 15:13:00')

INSERT wrp.sdm_set_modules (sdm_setkey, sdm_codmod) VALUES ('ContabilizacionCR', 'Salarios')

INSERT wrp.sdr_set_roles (sdr_setkey, sdr_codrol) VALUES ('ContabilizacionCR', 'Administrador')

INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'emp_codigo', 'Código de empleado', 0, 'int', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'emp_codplz', 'Plaza', 10, 'int', 'TodasPlazas', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'emp_codexp', 'Código del expediente', 20, 'int', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'emp_fecha_ingreso', 'Fecha de ingreso', 30, 'date', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'emp_fecha_retiro', 'Fecha de retiro', 40, 'date', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'emp_codtco', 'Contrato', 50, 'small', 'TodosTiposContratos', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'emp_codjor', 'Jornada', 60, 'small', 'TodasJornadas', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'emp_codtpl', 'Tipo planilla', 70, 'int', 'TodosTiposPlanilla', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'exp_codigo_alternativo', 'Código alternativo del empledao', 80, 'string', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'exp_nombres_apellidos', 'Nombres apellidos', 90, 'string', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'exp_apellidos_nombres', 'Apellidos nombres', 100, 'string', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'exp_fecha_nac', 'Fecha de nacimiento', 110, 'date', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'exp_edad', 'Edad', 120, 'int', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'plz_codcia', 'Compañía', 130, 'int', 'CompaniasDeGrupoCorporativo', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'plz_coduni', 'Unidad', 140, 'int', 'TodasUnidades', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'plz_codpue', 'Puesto', 150, 'int', 'TodosPuestos', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'plz_codcdt', 'Centro de trabajo', 160, 'int', 'TodosCentrosDeTrabajo', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'uni_codarf', 'Área funcional', 170, 'small', 'TodasAreasFuncionales', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'uni_codtun', 'Tipo unidad', 180, 'small', 'TodosTiposUnidad', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'pue_codtpp', 'Tipo puesto', 190, 'int', 'TodosTiposPuesto', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_codigo', 'Código de planilla', 200, 'int', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_codtpl', 'Tipo planilla', 210, 'int', 'TodosTiposPlanilla', 1, 'W', 1, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_codigo_planilla', 'Planilla', 220, 'string', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_fecha_ini', 'Fecha de inicio', 230, 'date', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_fecha_fin', 'Fecha de fin', 240, 'date', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_fecha_pago', 'Fecha de pago', 250, 'date', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_fecha_corte', 'Fecha de corte', 260, 'date', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_frecuencia', 'Frecuencia', 270, 'int', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_mes', 'Mes de contabilización', 280, 'int', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_anio', 'Año de contabilización', 290, 'int', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'ppl_estado', 'Estado', 300, 'string', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'descripcion_periodo_planilla', 'Descripción planilla', 310, 'string', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_tipo_partida', 'Tipo', 320, 'string', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_centro_costo', 'Centro de costo', 330, 'string', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_linea', 'Línea', 340, 'int', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_mes', 'Mes', 350, 'int', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_anio', 'Año', 360, 'int', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_cta_contable', 'Cuenta contable', 370, 'string', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_descripcion', 'Descripción', 380, 'string', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_debitos', 'Débitos', 390, 'double', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_creditos', 'Créditos', 400, 'double', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_valor', 'Valor neto', 410, 'double', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_tasa_cambio', 'Tasa de Cambio', 420, 'double', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_debitos_usd', 'Débitos (USD)', 430, 'double', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_creditos_usd', 'Créditos (USD)', 440, 'double', NULL, 1, 'W', 0, NULL)
INSERT wrp.sdf_set_fields (sdf_setkey, sdf_fieldname, sdf_prompt, sdf_orden, sdf_codfld, sdf_codvli, sdf_groupby, sdf_filter_in, sdf_replacevaluelist, sdf_sqlexp) VALUES ('ContabilizacionCR', 'dco_valor_usd', 'Valor neto (USD)', 450, 'double', NULL, 1, 'W', 0, NULL)

DECLARE @codrep INT

IF NOT EXISTS (SELECT NULL FROM wrp.rep_reportes WHERE rep_setkey = 'ContabilizacionCR' AND rep_nombre = 'Póliza Contable') 
	INSERT wrp.rep_reportes (rep_nombre, rep_titulo, rep_subtitulo, rep_orden_por, rep_setkey, rep_muestragrantotal, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion) VALUES ('Póliza Contable', 'Póliza Contable', '', 'Descripcion', 'ContabilizacionCR', 1, 'admin', '2015-04-21 16:40:29', NULL, NULL)

SELECT @codrep = rep_repid
FROM wrp.rep_reportes
WHERE rep_setkey = 'ContabilizacionCR'
	AND rep_nombre = 'Póliza Contable'

INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'ppl_codtpl', 'ContabilizacionCR', 0, 'None', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'ppl_codigo_planilla', 'ContabilizacionCR', 1, 'None', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_linea', 'ContabilizacionCR', 2, 'None', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_cta_contable', 'ContabilizacionCR', 3, 'None', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_centro_costo', 'ContabilizacionCR', 4, 'None', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_descripcion', 'ContabilizacionCR', 5, 'None', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_debitos', 'ContabilizacionCR', 6, 'Sum', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_creditos', 'ContabilizacionCR', 7, 'Sum', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_tasa_cambio', 'ContabilizacionCR', 8, 'None', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_debitos_usd', 'ContabilizacionCR', 9, 'Sum', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_creditos_usd', 'ContabilizacionCR', 10, 'Sum', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_tipo_partida', 'ContabilizacionCR', 11, 'None', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_mes', 'ContabilizacionCR', 12, 'None', 1)
INSERT wrp.rfl_rep_fields (rfl_repid, rfl_fieldname, rfl_setkey, rfl_orden, rfl_funcion_total, rfl_visible) VALUES (@codrep, 'dco_anio', 'ContabilizacionCR', 13, 'None', 1)

INSERT wrp.rfg_rep_field_grp (rfg_repid, rfg_fieldname, rfg_orden, rfg_orden_ascendente) VALUES (@codrep, 'ppl_codtpl', 0, 1)

INSERT wrp.rfs_rep_field_sort (rfs_repid, rfs_fieldname, rfs_orden, rfs_orden_ascendente) VALUES (@codrep, 'dco_linea', 2, 1)

INSERT wrp.rfq_rep_field_query (rfq_repid, rfq_fieldname, rfq_modo, rfq_text, rfq_exp) VALUES (@codrep, 'dco_tipo_partida', 'Generacion', '', '')
INSERT wrp.rfq_rep_field_query (rfq_repid, rfq_fieldname, rfq_modo, rfq_text, rfq_exp) VALUES (@codrep, 'ppl_codigo_planilla', 'Generacion', '', '')
INSERT wrp.rfq_rep_field_query (rfq_repid, rfq_fieldname, rfq_modo, rfq_text, rfq_exp) VALUES (@codrep, 'ppl_codtpl', 'Generacion', '', '')

COMMIT