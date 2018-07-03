/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'Vacaciones';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','Vacaciones','pago por vacaciones gozadas','SELECT vca_codppl, 
	vca_codemp, 
	vca_valor,
	vca_tiempo,
	vca_unidad_tiempo
FROM cr.vca_vacaciones_calculadas
WHERE vca_codppl = 0','SELECT vca_codppl, 
	vca_codemp, 
	vca_valor,
	vca_tiempo,
	vca_unidad_tiempo
FROM cr.vca_vacaciones_calculadas
WHERE vca_codppl = $$CODPPL$$
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', vca_codemp) = 1','vca_codemp','vca_codppl','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'Amonestaciones';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','Amonestaciones','Amonestaciones','SELECT amo_codppl_suspension,
	amo_codemp, 
	0.00 amo_dias
FROM acc.amo_amonestaciones 
WHERE amo_codppl_suspension = 0','SELECT amo_codppl_suspension,
	amo_codemp, 
	CASE 
		WHEN (amo_inicio_suspension < ppl_fecha_ini AND amo_final_suspension > ppl_fecha_fin)
		THEN gen.fn_diff_two_dates_30(ppl_fecha_ini, ppl_fecha_fin)
		WHEN (amo_inicio_suspension < ppl_fecha_ini AND amo_final_suspension >= ppl_fecha_ini AND amo_final_suspension <= ppl_fecha_fin) 
		THEN gen.fn_diff_two_dates_30(ppl_fecha_ini, amo_final_suspension)
		WHEN (amo_inicio_suspension >= ppl_fecha_ini AND amo_inicio_suspension <= ppl_fecha_fin AND amo_final_suspension > ppl_fecha_fin) 
		THEN gen.fn_diff_two_dates_30(amo_inicio_suspension, ppl_fecha_fin)
		WHEN (amo_inicio_suspension >= ppl_fecha_ini AND amo_final_suspension <= ppl_fecha_fin) 
		THEN gen.fn_diff_two_dates_30(amo_inicio_suspension, amo_final_suspension)
	END amo_dias
FROM acc.amo_amonestaciones 
	JOIN sal.ppl_periodos_planilla ON amo_codppl_suspension = ppl_codigo
WHERE amo_estado = ''Autorizado'' 
	AND amo_aplica_suspension = 1
	AND amo_codppl_suspension = $$CODPPL$$
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', amo_codemp) = 1','amo_codemp','','amo_codppl_suspension','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'Asociaciones';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','Asociaciones','Asociacioens del empleado','SELECT 0 ase_codppl,
	emp_codigo ase_codemp,
	ISNULL(ase_porcentaje_pago, aso_porcentaje) ase_porcentaje_pago,
	gen.get_pb_field_data_int(aso_property_bag_data, ''TipoDescuento'') ase_codtdc
FROM exp.ase_asociaciones_expedientes
	JOIN exp.exp_expedientes ON ase_codexp = exp_codigo
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp
	JOIN exp.aso_asociaciones ON ase_codaso = aso_codigo
WHERE ase_codigo = 0','DECLARE @codppl INT,
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@sessionid UNIQUEIDENTIFIER

SET @codppl = $$CODPPL$$
SET @sessionid = ''$$SESSIONID$$''

SELECT @ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codigo = @codppl

SELECT @codppl ase_codppl,
	emp_codigo ase_codemp,
	ISNULL(ase_porcentaje_pago, aso_porcentaje) ase_porcentaje_pago,
	gen.get_pb_field_data_int(aso_property_bag_data, ''TipoDescuento'') ase_codtdc
FROM exp.ase_asociaciones_expedientes
	JOIN exp.exp_expedientes ON ase_codexp = exp_codigo
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp
	JOIN exp.aso_asociaciones ON ase_codaso = aso_codigo
WHERE ((ase_fecha_ingreso IS NULL AND ase_fecha_retiro IS NULL)
	OR (ase_fecha_ingreso <= @ppl_fecha_fin AND (ase_fecha_retiro >= @ppl_fecha_ini OR ase_fecha_retiro IS NULL)))
	AND sal.empleado_en_gen_planilla(@sessionid, emp_codigo) = 1','ase_codemp','ase_codppl','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'CalculoAguinaldo';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','CalculoAguinaldo','obtiene los datos calculados de aguinaldo','SELECT cag_codppl,
	cag_codemp,
	cag_valor_total,
	cag_valor,
	cag_dias
FROM cr.cag_calculo_aguinaldo
WHERE cag_codppl = 0','SELECT cag_codppl,
	cag_codemp,
	cag_valor_total,
	cag_valor,
	cag_dias
FROM cr.cag_calculo_aguinaldo
WHERE cag_codppl = $$CODPPL$$
','cag_codemp','cag_codppl','TodosExcluyendo',1,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'ComplementosSalario';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','ComplementosSalario','empleados de nuevo ingreso que iniciaron luego de pagada la planilla','SELECT 0 eni_codppl,
	emp_codigo eni_codemp, 
	GETDATE() eni_dias
FROM exp.emp_empleos 
WHERE emp_codigo = 0','DECLARE @codppl INT,
	@sessionid UNIQUEIDENTIFIER,
	@codppl_anterior INT,
	@ppl_fecha_ini_anterior DATETIME,
	@ppl_fecha_fin_anterior DATETIME

SET @codppl = $$CODPPL$$
SET @sessionid = ''$$SESSIONID$$''

SELECT @codppl_anterior = ppl_codigo,
	@ppl_fecha_ini_anterior = ppl_fecha_ini,
	@ppl_fecha_fin_anterior = ppl_fecha_fin
FROM sal.ppl_periodos_planilla p
WHERE EXISTS (SELECT NULL
			  FROM sal.ppl_periodos_planilla l
			  WHERE l.ppl_codigo = @codppl 
				  AND p.ppl_codtpl = l.ppl_codtpl
				  AND DATEADD(DD, -1, l.ppl_fecha_ini) = p.ppl_fecha_fin)

SELECT @codppl eni_codppl,
	emp_codigo eni_codemp, 
	gen.fn_diff_two_dates_30(emp_fecha_ingreso, @ppl_fecha_fin_anterior) eni_dias
FROM exp.emp_empleos 
WHERE emp_estado = ''A''
	AND emp_fecha_ingreso BETWEEN @ppl_fecha_ini_anterior AND @ppl_fecha_fin_anterior
	AND NOT EXISTS (SELECT NULL
					FROM sal.inn_ingresos
					WHERE inn_codppl = @codppl_anterior
						AND inn_codemp = emp_codigo
						AND inn_valor > 0.00)
	AND sal.empleado_en_gen_planilla(@sessionid, emp_codigo) = 1','eni_codemp','eni_codppl','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'DescuentosCiclicos';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','DescuentosCiclicos','DescuentosCiclicos','SELECT cdc_codigo,
	cdc_codppl,
	dcc_codemp,
	cdc_fecha_descuento,
	cdc_valor_cobrado,
	cdc_aplicado_planilla,
	dcc_codtdc,
	dcc_codmon,
	ISNULL(gen.get_pb_field_data_bit(tcc_property_bag_data, ''EsPension''), 0) es_pension,
	ISNULL(gen.get_pb_field_data_bit(tcc_property_bag_data, ''EsEmbargo''), 0) es_embargo
FROM sal.cdc_cuotas_descuento_ciclico 
	JOIN sal.dcc_descuentos_ciclicos ON cdc_coddcc = dcc_codigo
	JOIN sal.tcc_tipos_descuento_ciclico ON dcc_codtcc = tcc_codigo
WHERE cdc_codppl = 0','SELECT cdc_codigo,
	cdc_codppl,
	dcc_codemp,
	cdc_fecha_descuento,
	cdc_valor_cobrado * gen.get_tasa_entre_mon(dcc_codmon, tpl_codmon, ppl_fecha_fin) cdc_valor_cobrado,
	cdc_aplicado_planilla,
	dcc_codtdc,
	dcc_codmon,
	ISNULL(gen.get_pb_field_data_bit(tcc_property_bag_data, ''EsPension''), 0) es_pension,
	ISNULL(gen.get_pb_field_data_bit(tcc_property_bag_data, ''EsEmbargo''), 0) es_embargo
FROM sal.cdc_cuotas_descuento_ciclico 
	JOIN sal.dcc_descuentos_ciclicos ON cdc_coddcc = dcc_codigo
	JOIN sal.tcc_tipos_descuento_ciclico ON dcc_codtcc = tcc_codigo
	JOIN sal.ppl_periodos_planilla ON cdc_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
WHERE cdc_codppl = $$CODPPL$$  
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', dcc_codemp) = 1','dcc_codemp','','cdc_codppl','','TodosExcluyendo',0,1);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'DescuentosCiclicosPorcentaje';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','DescuentosCiclicosPorcentaje','DescuentosCiclicosPorcentaje','SELECT 0 ppl_codigo,
	dcc_codemp,
	dcc_porcentaje,
	dcc_codagr,
	dcc_codtdc,
	dcc_codmon,
	ISNULL(gen.get_pb_field_data_bit(tcc_property_bag_data, ''EsPension''), 0) es_pension,
	ISNULL(gen.get_pb_field_data_bit(tcc_property_bag_data, ''EsEmbargo''), 0) es_embargo
FROM sal.dcc_descuentos_ciclicos 
	JOIN sal.tcc_tipos_descuento_ciclico ON dcc_codtcc = tcc_codigo
WHERE dcc_codigo = 0','DECLARE @codppl INT
	
SET @codppl = $$CODPPL$$

SELECT @codppl ppl_codigo,
	dcc_codemp,
	dcc_porcentaje,
	dcc_codagr,
	dcc_codtdc,
	dcc_codmon,
	ISNULL(gen.get_pb_field_data_bit(tcc_property_bag_data, ''EsPension''), 0) es_pension,
	ISNULL(gen.get_pb_field_data_bit(tcc_property_bag_data, ''EsEmbargo''), 0) es_embargo
FROM sal.dcc_descuentos_ciclicos 
	JOIN sal.tcc_tipos_descuento_ciclico ON dcc_codtcc = tcc_codigo
WHERE dcc_usa_porcentaje = 1
	AND dcc_activo = 1
	AND dcc_porcentaje > 0.00
	AND EXISTS (SELECT NULL
				FROM sal.ppl_periodos_planilla
				WHERE ppl_codigo = @codppl
					AND ppl_codtpl = dcc_codtpl
					AND dcc_fecha_inicio_descuento <= ppl_fecha_fin
					AND ppl_mes <> dcc_mes_no_descuenta
					AND (ppl_frecuencia = dcc_frecuencia_periodo_pla OR dcc_frecuencia_periodo_pla = 0)) 
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', dcc_codemp) = 1','dcc_codemp','ppl_codigo','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'DescuentosEstaPlanilla';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','DescuentosEstaPlanilla','DescuentosEstaPlanilla','SELECT * 
FROM tmp.dss_descuentos
WHERE dss_codigo < 0','SELECT * 
FROM tmp.dss_descuentos
WHERE dss_codppl = $$CODPPL$$
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', dss_codemp) = 1','dss_codemp','dss_codppl','TodosExcluyendo',0,1);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'DescuentosEventuales';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','DescuentosEventuales','DescuentosEventuales','SELECT ods_codigo,
	ods_codppl,
	ods_codemp,
	ods_codtdc,
	ods_valor_a_descontar,
	ods_codmon,
	ods_aplicado_planilla
FROM sal.ods_otros_descuentos
WHERE ods_codppl = 0','SELECT ods_codigo,
	ods_codppl,
	ods_codemp,
	ods_codtdc,
	ods_valor_a_descontar * gen.get_tasa_entre_mon(ods_codmon, tpl_codmon, ppl_fecha_fin) ods_valor_a_descontar,
	ods_codmon,
	ods_aplicado_planilla
FROM sal.ods_otros_descuentos
	JOIN sal.ppl_periodos_planilla ON ods_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo	
WHERE ods_codppl = $$CODPPL$$
   AND ods_estado = ''Autorizado'' 
   AND ods_ignorar_en_planilla = 0
   AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', ods_codemp) = 1','ods_codemp','','ods_codppl','','TodosExcluyendo',0,1);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'DiasIncapacidades';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','DiasIncapacidades','DiasIncapacidades','SELECT 0 ppl_codigo,
	ixe_codemp, 
	0.00 ixe_dias
FROM acc.ixe_incapacidades 
WHERE ixe_codigo = 0','SELECT ppl_codigo,
	ixe_codemp, 
	CASE 
		WHEN ixe_inicio < ppl_fecha_ini AND (ixe_final > ppl_fecha_fin OR ixe_final IS NULL) 
		THEN gen.fn_diff_two_dates_30(ppl_fecha_ini, ppl_fecha_fin)
		WHEN ixe_inicio <= ppl_fecha_ini AND ixe_final >= ppl_fecha_ini AND ixe_final <= ppl_fecha_fin 
		THEN gen.fn_diff_two_dates_30(ppl_fecha_ini, ixe_final)
		WHEN ixe_inicio >= ppl_fecha_ini AND ixe_final <= ppl_fecha_fin 
		THEN gen.fn_diff_two_dates_30(ixe_inicio, ixe_final)
		WHEN ixe_inicio >= ppl_fecha_ini AND ixe_inicio <= ppl_fecha_fin AND (ixe_final > ppl_fecha_fin OR ixe_final IS NULL) 
		THEN gen.fn_diff_two_dates_30(ixe_inicio, ppl_fecha_fin)
	END ixe_dias
FROM acc.ixe_incapacidades 
	JOIN sal.ppl_periodos_planilla ON 
		((ixe_inicio < ppl_fecha_ini AND (ixe_final > ppl_fecha_fin OR ixe_final IS NULL))
			OR (ixe_inicio < ppl_fecha_ini AND ixe_final >= ppl_fecha_ini AND ixe_final <= ppl_fecha_fin)
			OR (ixe_inicio >= ppl_fecha_ini AND ixe_inicio <= ppl_fecha_fin AND (ixe_final > ppl_fecha_fin OR ixe_final IS NULL))
			OR (ixe_inicio >= ppl_fecha_ini AND ixe_final <= ppl_fecha_fin))
WHERE ppl_codigo = $$CODPPL$$
	AND ixe_estado = ''Autorizado''
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', ixe_codemp) = 1','ixe_codemp','','ppl_codigo','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'DiasVacaciones';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','DiasVacaciones','DiasVacaciones','SELECT 0 ppl_codigo,
	vac_codemp,
	0.00 vac_dias
FROM acc.dva_dias_vacacion 
	JOIN acc.vac_vacaciones ON dva_codvac = vac_codigo
WHERE vac_codigo = 0','SELECT ppl_codigo,
	vac_codemp,
	CASE 
		WHEN dva_desde < ppl_fecha_ini AND dva_hasta > ppl_fecha_fin 
		THEN gen.fn_diff_two_dates_30(ppl_fecha_ini, ppl_fecha_fin)
		WHEN dva_desde < ppl_fecha_ini AND dva_hasta >= ppl_fecha_ini AND dva_hasta <= ppl_fecha_fin 
		THEN gen.fn_diff_two_dates_30(ppl_fecha_ini, dva_hasta)
		WHEN dva_desde >= ppl_fecha_ini AND dva_desde <= ppl_fecha_fin AND dva_hasta > ppl_fecha_fin 
		THEN gen.fn_diff_two_dates_30(dva_desde, ppl_fecha_fin)
		WHEN dva_desde >= ppl_fecha_ini AND dva_hasta <= ppl_fecha_fin 
		THEN gen.fn_diff_two_dates_30(dva_desde, dva_hasta)
		ELSE 0
	END vac_dias
FROM acc.dva_dias_vacacion 
	JOIN acc.vac_vacaciones ON dva_codvac = vac_codigo
	JOIN sal.ppl_periodos_planilla ON
		((dva_desde < ppl_fecha_ini AND dva_hasta > ppl_fecha_fin)
			 OR (dva_desde < ppl_fecha_ini AND dva_hasta >= ppl_fecha_ini AND dva_hasta <= ppl_fecha_fin) 
			 OR (dva_desde >= ppl_fecha_ini AND dva_desde <= ppl_fecha_fin AND dva_hasta > ppl_fecha_fin) 
			 OR (dva_desde >= ppl_fecha_ini AND dva_hasta <= ppl_fecha_fin))
WHERE ppl_codigo = $$CODPPL$$
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', vac_codemp) = 1','vac_codemp','','ppl_codigo','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'Embargos';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','Embargos','Embargos de los empleados','SELECT emb_codigo,
	cdc_codppl,
	dcc_codemp,
	ISNULL(dcc_monto, 0.00) - ISNULL(dcc_total_cobrado, 0.00) dcc_saldo,
	dcc_codtdc,
	dcc_codmon,
	emb_porcentaje_menor,
	emb_porcentaje_mayor,
	emb_salarios_minimos,
	emb_salario_inembargable,
	emb_salario_nominal,
	emb_cargas_sociales,
	emb_salario_embargable,
	emb_valor,
	emb_aplicado_planilla
FROM sal.emb_embargos
	JOIN sal.cdc_cuotas_descuento_ciclico ON emb_codcdc = cdc_codigo
	JOIN sal.dcc_descuentos_ciclicos ON cdc_coddcc = dcc_codigo
WHERE cdc_codppl = 0','SELECT emb_codigo,
	cdc_codppl,
	dcc_codemp,
	ISNULL(dcc_monto, 0.00) - ISNULL(dcc_total_cobrado, 0.00) dcc_saldo,
	dcc_codtdc,
	dcc_codmon,
	emb_porcentaje_menor,
	emb_porcentaje_mayor,
	emb_salarios_minimos,
	emb_salario_inembargable,
	emb_salario_nominal,
	emb_cargas_sociales,
	emb_salario_embargable,
	emb_valor,
	emb_aplicado_planilla
FROM sal.emb_embargos
	JOIN sal.cdc_cuotas_descuento_ciclico ON emb_codcdc = cdc_codigo
	JOIN sal.dcc_descuentos_ciclicos ON cdc_coddcc = dcc_codigo
WHERE cdc_codppl = $$CODPPL$$  
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', dcc_codemp) = 1','dcc_codemp','cdc_codppl','TodosExcluyendo',0,1);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'Empleados';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','Empleados','Empleados','SELECT emp_codigo,
     emp_fecha_ingreso,
     emp_fecha_retiro,
     emp_codtpl,
     emp_codplz,
     plz_es_temporal,
     plz_fecha_fin,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaSeguroSocial''), CAST(1 AS bit)) aplica_seguro_social,
	 ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaBancoPopular''), CAST(1 AS bit)) aplica_banco_popular,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaRenta''), CAST(1 AS bit)) aplica_renta,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaISRConyugue''), CAST(0 AS bit)) aplica_isr_conyugue,
     ISNULL(gen.get_pb_field_data_float(emp_property_bag_data, ''NumeroHijos''), 0.00) emp_numero_hijos,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''EsJubilado''), CAST(0 AS bit)) emp_es_jubilado
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = 0','DECLARE @codcia INT,
	@codtpl INT,
	@codppl INT,
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@session_id UNIQUEIDENTIFIER

SET @codcia = $$CODCIA$$
SET @codtpl = $$CODTPL$$
SET @codppl = $$CODPPL$$
SET @session_id = ''$$SESSIONID$$''

SELECT @ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codigo = @codppl

SELECT emp_codigo,
     emp_fecha_ingreso,
     emp_fecha_retiro,
     emp_codtpl,
     emp_codplz,
     plz_es_temporal,
     plz_fecha_fin,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaSeguroSocial''), CAST(1 AS bit)) aplica_seguro_social,
	 ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaBancoPopular''), CAST(1 AS bit)) aplica_banco_popular,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaRenta''), CAST(1 AS bit)) aplica_renta,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaISRConyugue''), CAST(1 AS bit)) aplica_isr_conyugue,
     ISNULL(gen.get_pb_field_data_float(emp_property_bag_data, ''NumeroHijos''), 0.00) emp_numero_hijos,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''EsJubilado''), CAST(0 AS bit)) emp_es_jubilado
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = @codcia
	AND (emp_estado = ''A''
		OR (emp_estado = ''R'' AND emp_fecha_retiro BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin))
	AND emp_codtpl = @codtpl
	AND sal.empleado_en_gen_planilla(@session_id, emp_codigo) = 1','emp_codigo','','','TodosExcluyendo',1,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'EmpleadosAguinaldo';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','EmpleadosAguinaldo','Empleados para el cálculo del aguinaldo','SELECT emp_codigo,
     emp_fecha_ingreso
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = 0','DECLARE @codcia INT,
	@codtpl INT,
	@codtpl_normal INT
	
SET @codcia = $$CODCIA$$
SET @codtpl = $$CODTPL$$

SELECT 	@codtpl_normal = tpl_codtpl_normal
FROM sal.tpl_tipo_planilla
WHERE tpl_codigo = @codtpl

SELECT emp_codigo,
     emp_fecha_ingreso
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = @codcia
	AND emp_estado = ''A''
	AND emp_codtpl = @codtpl_normal
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', emp_codigo) = 1','emp_codigo','TodosExcluyendo',1,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'EmpleadosExtraordinaria';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','EmpleadosExtraordinaria','Lista de empleados que participan en la planilla extraordinaria','SELECT emp_codigo,
     emp_fecha_ingreso,
     emp_fecha_retiro,
     emp_codtpl,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaSeguroSocial''), CAST(1 AS bit)) aplica_seguro_social,
	 ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaBancoPopular''), CAST(1 AS bit)) aplica_banco_popular,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaRenta''), CAST(1 AS bit)) aplica_renta,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaISRConyugue''), CAST(1 AS bit)) aplica_isr_conyugue,
     ISNULL(gen.get_pb_field_data_float(emp_property_bag_data, ''NumeroHijos''), 0.00) emp_numero_hijos,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''EsJubilado''), CAST(0 AS bit)) emp_es_jubilado
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = 0','DECLARE @codcia INT,
	@codtpl INT,
	@codppl INT,
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@session_id UNIQUEIDENTIFIER

SET @codcia = $$CODCIA$$
SET @codtpl = $$CODTPL$$
SET @codppl = $$CODPPL$$
SET @session_id = ''$$SESSIONID$$''

SELECT @ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codigo = @codppl

SELECT emp_codigo,
     emp_fecha_ingreso,
     emp_fecha_retiro,
     emp_codtpl,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaSeguroSocial''), CAST(1 AS bit)) aplica_seguro_social,
	 ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaBancoPopular''), CAST(1 AS bit)) aplica_banco_popular,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaRenta''), CAST(1 AS bit)) aplica_renta,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaISRConyugue''), CAST(1 AS bit)) aplica_isr_conyugue,
     ISNULL(gen.get_pb_field_data_float(emp_property_bag_data, ''NumeroHijos''), 0.00) emp_numero_hijos,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''EsJubilado''), CAST(0 AS bit)) emp_es_jubilado
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = @codcia
	AND (emp_estado = ''A''
		OR (emp_estado = ''R'' AND emp_fecha_retiro BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin))
	AND EXISTS (SELECT NULL
				FROM sal.oin_otros_ingresos
				WHERE oin_codppl = @codppl
					AND oin_codemp = emp_codigo
					AND oin_estado = ''Autorizado''
					AND oin_ignorar_en_planilla = 0)
	AND sal.empleado_en_gen_planilla(@session_id, emp_codigo) = 1','emp_codigo','TodosExcluyendo',1,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'HorasExtras';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','HorasExtras','HorasExtras','SELECT ext_codigo, 
	ext_codppl,
	ext_codemp,
	ext_valor_a_pagar,
	ext_num_horas,
	ext_aplicado_planilla,
	the_codtig
FROM sal.ext_horas_extras 
	JOIN sal.the_tipos_hora_extra ON ext_codthe = the_codigo
WHERE ext_codppl = 0','SELECT ext_codigo, 
	ext_codppl,
	ext_codemp,
	ext_valor_a_pagar,
	ROUND(ISNULL(ext_num_horas, 0.00) + (ISNULL(ext_num_mins, 0.00) / 60.00), 2) ext_num_horas,
	ext_aplicado_planilla,
	the_codtig
FROM sal.ext_horas_extras
	JOIN sal.the_tipos_hora_extra ON ext_codthe = the_codigo
WHERE ext_estado = ''Autorizado''
	AND ext_ignorar_en_planilla = 0
	AND ext_codppl = $$CODPPL$$
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', ext_codemp) = 1','ext_codemp','','ext_codppl','','TodosExcluyendo',0,1);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'Incapacidades';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','Incapacidades','pago por incapacidades del seguro social','SELECT pie_codppl,
	ixe_codemp, 
    pie_valor_a_pagar,
    pie_valor_a_descontar,
	pie_dias,
	txi_codtig,
	txi_codtdc
FROM acc.ixe_incapacidades
	JOIN acc.pie_periodos_incapacidad ON pie_codixe = ixe_codigo
	JOIN acc.txi_tipos_incapacidad ON ixe_codtxi = txi_codigo
WHERE pie_codppl = 0','SELECT pie_codppl,
	ixe_codemp, 
    SUM(pie_valor_a_pagar) pie_valor_a_pagar,
    SUM(pie_valor_a_descontar) pie_valor_a_descontar,
	SUM(pie_dias) pie_dias,
	txi_codtig,
	txi_codtdc
FROM acc.ixe_incapacidades
	JOIN acc.pie_periodos_incapacidad ON pie_codixe = ixe_codigo
	JOIN acc.txi_tipos_incapacidad ON ixe_codtxi = txi_codigo
WHERE pie_codppl = $$CODPPL$$
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', ixe_codemp) = 1
GROUP BY pie_codppl, ixe_codemp, txi_codtig, txi_codtdc','ixe_codemp','pie_codppl','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'IngresosCiclicos';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','IngresosCiclicos','detalle de ingresos ciclicos para pagar a los empleados','SELECT cic_codigo,
	cic_codppl,
	igc_codemp,
	cic_valor_cuota,
	cic_aplicado_planilla,
	igc_codtig,
	igc_codmon   
FROM sal.cic_cuotas_ingreso_ciclico 
	JOIN sal.igc_ingresos_ciclicos ON cic_codigc = igc_codigo
WHERE cic_codppl = 0','SELECT cic_codigo,
	cic_codppl,
	igc_codemp,
	cic_valor_cuota * gen.get_tasa_entre_mon(igc_codmon, tpl_codmon, ppl_fecha_fin) cic_valor_cuota,
	cic_aplicado_planilla,
	igc_codtig,
	igc_codmon   
FROM sal.cic_cuotas_ingreso_ciclico 
	JOIN sal.igc_ingresos_ciclicos ON cic_codigc = igc_codigo
	JOIN sal.ppl_periodos_planilla ON cic_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
WHERE cic_codppl = $$CODPPL$$  
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', igc_codemp) = 1','igc_codemp','cic_codppl','','TodosExcluyendo',0,1);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'IngresosEstaPlanilla';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','IngresosEstaPlanilla','IngresosEstaPlanilla','SELECT * 
FROM tmp.inn_ingresos
WHERE inn_codigo < 0','SELECT * 
FROM tmp.inn_ingresos
WHERE inn_codppl = $$CODPPL$$
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', inn_codemp) = 1','inn_codemp','','inn_codppl','','TodosExcluyendo',0,1);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'IngresosEventuales';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','IngresosEventuales','IngresosEventuales','SELECT oin_codigo,
	oin_codppl,
	oin_codemp,
	oin_codtig,
	oin_valor_a_pagar,
	oin_codmon,
	oin_aplicado_planilla
FROM sal.oin_otros_ingresos
WHERE oin_codppl = 0','SELECT oin_codigo,
	oin_codppl,
	oin_codemp,
	oin_codtig,
	oin_valor_a_pagar * gen.get_tasa_entre_mon(oin_codmon, tpl_codmon, ppl_fecha_fin) oin_valor_a_pagar,
	oin_codmon,
	oin_aplicado_planilla
FROM sal.oin_otros_ingresos
	JOIN sal.ppl_periodos_planilla ON oin_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
WHERE oin_codppl = $$CODPPL$$ 
	AND oin_estado = ''Autorizado''
	AND oin_ignorar_en_planilla = 0
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', oin_codemp) = 1','oin_codemp','','oin_codppl','','TodosExcluyendo',0,1);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'IngresosPlanillaAnterior';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','IngresosPlanillaAnterior','IngresosPlanillaAnterior','SELECT inn_codppl,
	inn_codemp,
	inn_codtig,
	inn_valor,
	inn_codmon
FROM sal.inn_ingresos
WHERE inn_codppl = 0','DECLARE @codtpl INT,
	@codppl INT,
	@mes INT,
	@anio INT,
	@sessionid UNIQUEIDENTIFIER

SET @codtpl = $$CODTPL$$
SET @codppl = $$CODPPL$$
SET @sessionid = ''$$SESSIONID$$''

SELECT @mes = ppl_mes,
	@anio = ppl_anio
FROM sal.ppl_periodos_planilla
WHERE ppl_codigo = @codppl

SELECT inn_codppl,
	inn_codemp,
	inn_codtig,
	inn_valor,
	inn_codmon
FROM sal.inn_ingresos
	JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
WHERE ppl_codtpl = @codtpl
	AND ppl_anio = @anio
	AND ppl_mes = @mes
	AND ppl_frecuencia = 1
	AND sal.empleado_en_gen_planilla(@sessionid, inn_codemp) = 1','inn_codemp','TodosExcluyendo',0,1);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'IngresosPlanillaAnteriorISR';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','IngresosPlanillaAnteriorISR','Las suma de los ingresos de la planilla anterior que aplican al ISR por empleado','SELECT inn_codppl,
	inn_codemp,
	inn_valor
FROM sal.inn_ingresos
WHERE inn_codppl = 0','DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@codppl INT,
	@mes INT,
	@anio INT,
	@codagr INT,
	@sessionid UNIQUEIDENTIFIER

SET @codtpl = $$CODTPL$$
SET @codppl = $$CODPPL$$
SET @sessionid = ''$$SESSIONID$$''

SELECT @codpai = cia_codpai,
	@mes = ppl_mes,
	@anio = ppl_anio
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE ppl_codigo = @codppl

SELECT @codagr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = ''CRBaseCalculoRenta''

SELECT 	inn_codemp,
	SUM(inn_valor) inn_valor
FROM sal.inn_ingresos
	JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
WHERE ppl_codtpl = @codtpl
	AND ppl_estado = ''Autorizado''
	AND ppl_anio = @anio
	AND ppl_mes = @mes
	AND inn_codtig IN (SELECT iag_codtig
					   FROM sal.iag_ingresos_agrupador
					   WHERE iag_codagr = @codagr)
	AND sal.empleado_en_gen_planilla(@sessionid, inn_codemp) = 1
GROUP BY inn_codemp','inn_codemp','inn_codppl','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'ParametrosAplicacion';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codcia],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','ParametrosAplicacion','ParametrosAplicacion','SELECT 0 quincena_descontar_isr,
	0.00 porcentaje_anticipo,
	0.00 porc_empleado_seguro_social,
	0.00 porc_jubilado_seguro_social,
	0.00 porc_patrono_seguro_social,
	0.00 banco_popular_porcentaje,
	0.00 isr_valor_conyugue,
	0.00 isr_valor_hijos,
	0.00 emb_salario_inembargable,
	0.00 emb_porcentaje_menores,
	0.00 emb_porcentaje_mayores,
	0.00 emb_num_sal_minimos,
	0.00 pal_porcentaje_maximo,
	0.00 codtdc_ccss,
	0.00 codtdc_ccss_jubilado,
	0.00 horas_por_mes,
	0.00 horas_por_dia,
	0.00 tasa_cambio','SET DATEFORMAT DMY
SET DATEFIRST 1

DECLARE @codpai VARCHAR(2),
	@codgrc INT,
	@codcia INT,
	@codtpl INT,
	@codppl INT,
	@codmon VARCHAR(3),
	@anio INT,
	@mes INT,
	@ppl_fecha_pago DATETIME,
	@tasa_cambio REAL

SET @codcia = $$CODCIA$$
SET @codppl = $$CODPPL$$
	
SELECT @codpai = cia_codpai,
	@codgrc = cia_codgrc
FROM eor.cia_companias 
WHERE cia_codigo = @codcia

SELECT @anio = ppl_anio,
	@mes = ppl_mes,
	@codmon = tpl_codmon,
	@ppl_fecha_pago = ppl_fecha_pago
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
WHERE ppl_codigo = @codppl

IF @codmon = ''USD''
	SET @tasa_cambio = ISNULL(gen.get_tasa_cambio(''CRC'', @ppl_fecha_pago), 1.00)
ELSE	
	SET @tasa_cambio = 1.00

SELECT ISNULL(gen.get_valor_parametro_float(''CuotaEmpleadoSeguroSocial'', @codpai, NULL, NULL, NULL), 0.00) porc_empleado_seguro_social,
	ISNULL(gen.get_valor_parametro_float(''CuotaEmpleadoSeguroSocial'', @codpai, NULL, NULL, NULL), 0.00) porc_empleado_seguro_social,
	ISNULL(gen.get_valor_parametro_float(''CuotaJubiladoSeguroSocial'', @codpai, NULL, NULL, NULL), 0.00) porc_jubilado_seguro_social,
	ISNULL(gen.get_valor_parametro_float(''CuotaPatronoSeguroSocial'', @codpai, NULL, NULL,NULL), 0.00) porc_patrono_seguro_social,
	ISNULL(gen.get_valor_parametro_float(''BancoPopularPorcentaje'', @codpai, NULL, NULL, NULL), 0.00) banco_popular_porcentaje,
	ISNULL(gen.get_valor_parametro_money(''ISRValorConyugue'', @codpai, NULL, NULL,NULL), 0.00) isr_valor_conyugue,
	ISNULL(gen.get_valor_parametro_money(''ISRValorHijos'', @codpai, NULL, NULL, NULL), 0.00) isr_valor_hijos,
	ISNULL(gen.get_valor_parametro_money(''EmbargosSalarioInembargable'', @codpai, NULL, NULL, NULL), 0.00) emb_salario_inembargable,
	ISNULL(gen.get_valor_parametro_float(''EmbargosPorcentajeMenores'', @codpai, NULL, NULL, NULL), 0.00) emb_porcentaje_menores,
	ISNULL(gen.get_valor_parametro_float(''EmbargosPorcentajeMayores'', @codpai, NULL, NULL, NULL), 0.00) emb_porcentaje_mayores,
	ISNULL(gen.get_valor_parametro_float(''EmbargosNumeroSalariosMinimos'', @codpai, NULL, NULL, NULL), 0.00) emb_num_sal_minimos,
	ISNULL(gen.get_valor_parametro_float(''PensionAlimenticiaPorcentajeMaximo'', @codpai, NULL, NULL, NULL), 0.00) pal_porcentaje_maximo,
	ISNULL(gen.get_valor_parametro_int(''CodigoTDC_CCSS'', NULL, NULL, @codcia, NULL), 0.00) codtdc_ccss,
	ISNULL(gen.get_valor_parametro_int(''CodigoTDC_CCSS_Jubilado'', NULL, NULL, @codcia, NULL), 0.00) codtdc_ccss_jubilado,
	ISNULL(gen.get_valor_parametro_float(''HorasLaboradasPorMes'', @codpai, NULL, NULL, NULL), 0.00) horas_por_mes,
	ISNULL(gen.get_valor_parametro_float(''HorasLaboralesPorDia'', @codpai, NULL, NULL, NULL), 0.00) horas_por_dia,
	ISNULL(@tasa_cambio, 1.00) tasa_cambio','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'Periodos';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codcia],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','Periodos','Periodos','SELECT ppl_codtpl,
	ppl_codigo,
	ppl_fecha_ini,
	ppl_fecha_fin,
	ppl_fecha_pago,
	ppl_frecuencia,
	tpl_codmon,
	gen.get_pb_field_data_bit(ppl_property_bag_data, ''EsUltimaSemana'') ppl_es_ultima_semana
FROM sal.ppl_periodos_planilla 
	JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
WHERE ppl_codigo = 0','SELECT ppl_codtpl,
	ppl_codigo,
	ppl_fecha_ini,
	CASE 
		WHEN DAY(ppl_fecha_fin) > 30.00 THEN CONVERT(DATETIME, ''30/'' + CONVERT(VARCHAR, MONTH(ppl_fecha_fin)) + ''/'' + CONVERT(VARCHAR, YEAR(ppl_fecha_fin)))
		ELSE ppl_fecha_fin
	END ppl_fecha_fin,
	ppl_fecha_pago,
	ppl_frecuencia,
	tpl_codmon,
	gen.get_pb_field_data_bit(ppl_property_bag_data, ''EsUltimaSemana'') ppl_es_ultima_semana
FROM sal.ppl_periodos_planilla 
	JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
WHERE ppl_codigo = $$CODPPL$$	
','','ppl_codigo','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'PeriodosAnteriores';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','PeriodosAnteriores','PeriodosAnteriores','SELECT 0 ppl_codigo
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = 0','DECLARE @codtpl INT,
	@codppl INT,
	@mes INT,
	@anio INT

SET @codtpl = $$CODTPL$$
SET @codppl = $$CODPPL$$

SELECT @mes = ppl_mes,
	@anio = ppl_anio
FROM sal.ppl_periodos_planilla
WHERE ppl_codigo = @codppl

SELECT ppl_codigo
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_mes = @mes
	AND ppl_anio = @anio
	AND ppl_frecuencia = 1','ppl_codigo','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'PrestacionesEmpleado';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codppl],[fcu_field_codtpl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','PrestacionesEmpleado','PrestacionesEmpleado','SELECT 0 ppp_codppl,
	emp_codigo ppp_codemp,
	CASE WHEN ISNULL(pre_tipo, ''V'') = ''H'' THEN ROUND(ppp_valor * esa_valor_hora, 2) ELSE ppp_valor END ppp_valor,
	pre_codtig,
	ppp_codmon
FROM eor.ppp_prestaciones_puesto 
	JOIN eor.pre_prestaciones ON ppp_codpre = pre_codigo
	JOIN eor.plz_plazas ON ppp_codpue = plz_codpue
	JOIN exp.emp_empleos ON plz_codigo = emp_codplz
	JOIN exp.esa_est_sal_actual_empleos_v ON esa_codemp = emp_codigo AND esa_es_salario_base = 1
WHERE plz_codcia = 0','DECLARE @codcia INT,
	@codtpl INT, 
	@codppl INT, 
	@frecuencia VARCHAR(15), 
	@fin DATETIME

SET @codcia = $$CODCIA$$
SET @codtpl = $$CODTPL$$
SET @codppl = $$CODPPL$$

-- obtiene la fecha de finalizacion de la planilla y la frecuencia
SELECT @frecuencia = tpl_frecuencia,
       @fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
WHERE ppl_codigo = @codppl;
   
SELECT @codppl ppp_codppl,
	emp_codigo ppp_codemp,
	ROUND(CASE WHEN ISNULL(pre_tipo, ''V'') = ''H'' THEN ROUND(ppp_valor * esa_valor_hora, 2) ELSE ppp_valor END * gen.get_tasa_entre_mon(ppp_codmon, tpl_codmon, @fin), 2) ppp_valor,
	pre_codtig,
	ppp_codmon
FROM eor.ppp_prestaciones_puesto 
	JOIN eor.pre_prestaciones ON ppp_codpre = pre_codigo
	JOIN eor.plz_plazas ON ppp_codpue = plz_codpue
	JOIN exp.emp_empleos ON plz_codigo = emp_codplz
	JOIN exp.esa_est_sal_actual_empleos_v ON esa_codemp = emp_codigo AND esa_es_salario_base = 1
	JOIN eor.fre_frecuencias ON pre_codfre = fre_codigo
	JOIN sal.tpl_tipo_planilla ON emp_codtpl = tpl_codigo
WHERE plz_codcia = @codcia
	AND emp_codtpl = @codtpl
	AND emp_estado = ''A''
	AND ((ppp_fecha_fin >= @fin AND ppp_fecha_ini <= @fin) OR ppp_fecha_fin IS NULL)
	AND (fre_abreviatura = @frecuencia)
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', emp_codigo) = 1','ppp_codemp','','ppp_codppl','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'RetroactivosSalario';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','RetroactivosSalario','RetroactivosSalario','SELECT ppl_codigo, 
	inc_codemp,
	0.00 idr_valor, 
	0.00 idr_dias
FROM acc.inc_incrementos 
	JOIN acc.idr_incremento_detalle_rubros ON inc_codigo = idr_codinc
	JOIN exp.ese_estructura_sal_empleos ON ese_codigo = idr_codese 
	JOIN sal.ppl_periodos_planilla ON inc_fecha_solicitud >= ppl_fecha_ini AND inc_fecha_solicitud <= ppl_fecha_fin
WHERE ppl_codigo = 0','SELECT ppl_codigo, 
	inc_codemp,
	(ISNULL(idr_valor, 0.00) - ISNULL(ese_valor, 0.00)) / 30.00 * 
		gen.fn_diff_two_dates_30(idr_fecha_vigencia, DATEADD(DD, -1, ppl_fecha_ini)) idr_valor, 
	gen.fn_diff_two_dates_30(idr_fecha_vigencia, DATEADD(DD, -1, ppl_fecha_ini)) idr_dias
FROM acc.inc_incrementos 
	JOIN acc.idr_incremento_detalle_rubros ON inc_codigo = idr_codinc
	JOIN exp.ese_estructura_sal_empleos ON ese_codigo = idr_codese 
	JOIN sal.ppl_periodos_planilla ON inc_fecha_solicitud >= ppl_fecha_ini AND inc_fecha_solicitud <= ppl_fecha_fin
WHERE ppl_codigo = $$CODPPL$$
	AND inc_estado = ''Autorizado''   
	AND idr_es_retroactivo = 1
	AND idr_valor != ese_valor
	AND idr_codrsa = gen.get_valor_parametro_INT (''CodigoRSA_Salario'', NULL, NULL, $$CODCIA$$, NULL)
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', inc_codemp) = 1','inc_codemp','ppl_codigo','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'RubrosSalario';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','RubrosSalario','recoge los datos del salario ordinario del empleado','SELECT ese_codemp, 
       ese_valor,
       ese_codmon,
       ese_exp_valor,
       ese_valor_anterior,
       ese_fecha_inicio,
       ese_codtig
FROM exp.ese_estructura_sal_empleos e
WHERE ese_codigo = 0','DECLARE @codcia INT,
	@codppl INT, 
	@sessionid UNIQUEIDENTIFIER,
	@ppl_fecha_fin DATETIME

SET @codcia = $$CODCIA$$
SET @codppl = $$CODPPL$$
SET @sessionid = ''$$SESSIONID$$''

SELECT @ppl_fecha_fin = ppl_fecha_fin 
FROM sal.ppl_periodos_planilla 
WHERE ppl_codigo = @codppl

SELECT ese_codemp, 
       ese_valor,
       ese_codmon,
       ese_exp_valor,
       ese_valor_anterior,
       ese_fecha_inicio,
       ese_codtig
FROM exp.ese_estructura_sal_empleos e
WHERE ese_codigo = (SELECT MAX(ese_codigo) ese_codigo
					FROM exp.ese_estructura_sal_empleos s
					WHERE ese_codrsa = ISNULL(gen.get_valor_parametro_INT (''CodigoRSA_Salario'', NULL, NULL, @codcia, NULL), 0)
						AND ese_fecha_inicio <= @ppl_fecha_fin
						AND ISNULL(ese_fecha_fin, @ppl_fecha_fin + 1) >= @ppl_fecha_fin
						AND s.ese_codemp = e.ese_codemp)
	AND sal.empleado_en_gen_planilla(@sessionid, ese_codemp) = 1','ese_codemp','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'RubrosSalarioHistorial';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','RubrosSalarioHistorial','Historial de los salarios que ha tenido el empleado','SELECT ese_codemp, 
       ese_valor,
       ese_codmon,
       ese_fecha_inicio,
       ese_fecha_fin
FROM exp.ese_estructura_sal_empleos 
WHERE ese_codemp = 0','DECLARE @codcia INT,
	@codppl INT, 
	@sessionid UNIQUEIDENTIFIER,
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME
	
SET @codcia = $$CODCIA$$
SET @codppl = $$CODPPL$$
SET @sessionid = ''$$SESSIONID$$''

SELECT @ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin 
FROM sal.ppl_periodos_planilla 
WHERE ppl_codigo = @codppl

SELECT ese_codemp, 
       CASE WHEN ese_exp_valor = ''Diario'' THEN ese_valor * 30.00 ELSE ese_valor END ese_valor,
       ese_codmon,
       ese_fecha_inicio,
       ese_fecha_fin
FROM exp.ese_estructura_sal_empleos 
WHERE ese_codrsa = ISNULL(gen.get_valor_parametro_INT (''CodigoRSA_Salario'', NULL, NULL, @codcia, NULL), 0)
	AND (ese_fecha_fin IS NULL
		OR (ese_fecha_fin >= @ppl_fecha_ini
			AND ese_fecha_fin <= @ppl_fecha_fin))
	AND sal.empleado_en_gen_planilla(@sessionid, ese_codemp) = 1
ORDER BY ese_fecha_inicio ASC','ese_codemp','','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'SegurosMedicos';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','SegurosMedicos','SegurosMedicos','SELECT sem_codemp,
	sem_cuota_empleado,
	sem_cuota_patrono
FROM exp.sem_seguros_medicos_empleo 
	JOIN exp.sme_seguros_medicos ON	sem_codsme = sme_codigo
WHERE sem_codigo = 0','SELECT sem_codemp,
	sem_cuota_empleado,
	sem_cuota_patrono
FROM exp.sem_seguros_medicos_empleo 
	JOIN exp.sme_seguros_medicos ON	sem_codsme = sme_codigo
WHERE sem_es_activo = 1
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', sem_codemp) = 1','sem_codemp','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'Sustituciones';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','Sustituciones','para calculo del pago de sustituciones temporales','SELECT 0 ste_codppl, 
	0 ste_codemp, 
	0.00 ste_valor, 
	0.00 ste_dias
FROM acc.ste_sustituciones_temp
WHERE ste_codigo = 0','DECLARE @codcia INT,
	@codppl INT,
	@codrsa INT,
	@sessionid UNIQUEIDENTIFIER

SET @codcia = $$CODCIA$$
SET @codppl = $$CODPPL$$
SET @codrsa = ISNULL(gen.get_valor_parametro_INT (''CodigoRSA_Salario'', NULL, NULL, @codcia, NULL), 0) 
SET @sessionid = ''$$SESSIONID$$''

SELECT ste_codppl, 
	ste_codemp, 
	ROUND((ste_salario_titular - ste_salario_sustituto) / 30.00 * ste_dias, 2) ste_valor, 
	ste_dias
FROM (
	SELECT
		ppl_codigo ste_codppl, 
		ste_codemp_sustito ste_codemp, 
		t.ese_valor ste_salario_titular, 
		s.ese_valor ste_salario_sustituto, 
		ste_codemp_sustito, 
		gen.fn_diff_two_dates_30(
			CASE WHEN ste_fecha_inicio < ppl_fecha_ini THEN ppl_fecha_ini ELSE ste_fecha_inicio END,
			CASE WHEN ste_fecha_fin > ppl_fecha_fin THEN ppl_fecha_fin ELSE ste_fecha_fin END) ste_dias
	FROM acc.ste_sustituciones_temp
		JOIN exp.emp_empleos ON emp_codigo = ste_codemp_titular
		JOIN sal.ppl_periodos_planilla ON ppl_codtpl = emp_codtpl AND ste_fecha_inicio >= ppl_fecha_ini AND ste_fecha_inicio <= ppl_fecha_fin
		JOIN exp.ese_estructura_sal_empleos t ON t.ese_codemp = ste_codemp_titular AND t.ese_codrsa = @codrsa AND t.ese_estado = ''V''
		JOIN exp.ese_estructura_sal_empleos s ON s.ese_codemp = ste_codemp_sustito AND s.ese_codrsa = @codrsa AND s.ese_estado = ''V''
	WHERE ppl_codigo = @codppl
		AND t.ese_valor > s.ese_valor) v1
WHERE sal.empleado_en_gen_planilla(@sessionid, ste_codemp) = 1','ste_codemp','ste_codppl','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'TablaISRMensual';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','TablaISRMensual','Tabla del ISR Mensual','SELECT inicio,
	fin,
	porcentaje,
	excedente
FROM gen.get_valor_rango_parametro(''TablaRentaMensual'', null, null, null, null, null)	','SELECT inicio,
	fin,
	porcentaje,
	excedente
FROM gen.get_valor_rango_parametro(''TablaRentaMensual'', ''cr'', null, null, null, null)	','TodosExcluyendo',0,0);


commit transaction;

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:57 */

begin transaction

delete from [sal].[fcu_formulacion_cursores] where [fcu_codpai] = 'cr' and [fcu_nombre] = 'TiemposNoTrabajados';


insert into [sal].[fcu_formulacion_cursores] ([fcu_codpai],[fcu_proceso],[fcu_nombre],[fcu_descripcion],[fcu_select_edit],[fcu_select_run],[fcu_field_codemp],[fcu_field_codcia],[fcu_field_codppl],[fcu_modo_asociacion_tpl],[fcu_loop_calculo],[fcu_updatable]) values ('cr','Planilla','TiemposNoTrabajados','TiemposNoTrabajados','SELECT tnn_codppl,
	tnn_codemp,
	tnn_num_dias + ISNULL(tnn_num_horas / 8.00, 0.00) dias,
	tnt_codtig,
	tnt_porcentaje_descuento
FROM sal.tnn_tiempos_no_trabajados 
	JOIN sal.tnt_tipos_tiempo_no_trabajado ON tnn_codtnt = tnt_codigo
WHERE tnn_codppl = 0','DECLARE @codppl INT,
	@fecha_inicio DATETIME,
	@fecha_fin DATETIME,
	@tpl_frecuencia VARCHAR(15)
	
SET @codppl = $$CODPPL$$

SELECT @fecha_inicio = ppl_fecha_ini,
	@fecha_fin = ppl_fecha_fin,
	@tpl_frecuencia = tpl_frecuencia
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
WHERE ppl_codigo = @codppl

SELECT @codppl tnn_codppl,
	tnn_codemp,
	CASE 
		WHEN tnn_fecha_del <= @fecha_inicio AND tnn_fecha_al >= @fecha_fin THEN
			CASE 
				WHEN @tpl_frecuencia = ''Semanal'' THEN DATEDIFF(DD, @fecha_inicio, @fecha_fin) + 1 
				ELSE gen.fn_diff_two_dates_30(@fecha_inicio, @fecha_fin) 
			END
		WHEN tnn_fecha_del <= @fecha_inicio AND tnn_fecha_al >= @fecha_inicio AND tnn_fecha_al <= @fecha_fin THEN
			CASE 
				WHEN @tpl_frecuencia = ''Semanal'' THEN DATEDIFF(DD, @fecha_inicio, tnn_fecha_al) + 1 
				ELSE gen.fn_diff_two_dates_30(@fecha_inicio, tnn_fecha_al)
			END			
		WHEN tnn_fecha_del >= @fecha_inicio AND tnn_fecha_del <= @fecha_fin AND tnn_fecha_al >= @fecha_fin THEN
			CASE 
				WHEN @tpl_frecuencia = ''Semanal'' THEN DATEDIFF(DD, tnn_fecha_del, @fecha_fin) + 1 
				ELSE gen.fn_diff_two_dates_30(tnn_fecha_del, @fecha_fin)
			END						
		WHEN tnn_fecha_del >= @fecha_inicio AND tnn_fecha_al <= @fecha_fin THEN
			CASE 
				WHEN @tpl_frecuencia = ''Semanal'' THEN DATEDIFF(DD, tnn_fecha_del, tnn_fecha_al) + 1 
				ELSE gen.fn_diff_two_dates_30(tnn_fecha_del, tnn_fecha_al)
			END											
		ELSE
			0.00
	END + ISNULL(tnn_num_horas / 8, 0) dias,
	tnt_codtig,
	tnt_porcentaje_descuento
FROM sal.tnn_tiempos_no_trabajados 
	JOIN sal.tnt_tipos_tiempo_no_trabajado ON tnn_codtnt = tnt_codigo
WHERE tnn_estado = ''Autorizado'' 
	AND tnn_ignorar_en_planilla = 0
	AND ((tnn_fecha_del >= @fecha_inicio AND tnn_fecha_al <= @fecha_fin)
		OR (tnn_fecha_del < @fecha_inicio AND tnn_fecha_al >= @fecha_inicio AND tnn_fecha_al <= @fecha_fin)
		OR (tnn_fecha_del >= @fecha_inicio AND tnn_fecha_del <= @fecha_fin AND tnn_fecha_al > @fecha_fin)
		OR (tnn_fecha_del < @fecha_inicio AND tnn_fecha_al > @fecha_fin))	
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', tnn_codemp) = 1','tnn_codemp','','tnn_codppl','TodosExcluyendo',0,0);


commit transaction;

