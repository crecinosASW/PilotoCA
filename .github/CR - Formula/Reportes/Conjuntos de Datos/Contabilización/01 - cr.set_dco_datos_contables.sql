IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.set_dco_datos_contables'))
BEGIN
	DROP VIEW cr.set_dco_datos_contables
END

GO

--SELECT * FROM cr.set_dco_datos_contables WHERE ppl_codtpl = 2 AND ppl_codigo_planilla = '20150502'
CREATE VIEW cr.set_dco_datos_contables

AS

SELECT emp_codigo,
	emp_codplz,
	emp_codexp,
	emp_estado,
	emp_fecha_ingreso,
	emp_fecha_retiro,
	emp_codtco,
	emp_codjor,
	emp_codtpl,
	exp_codigo_alternativo,
	exp_nombres_apellidos,
	exp_apellidos_nombres,
	exp_fecha_nac,
	exp_edad,
	plz_codcia,
	plz_coduni,
	plz_codpue,
	plz_codcdt,
	uni_codarf,
	uni_codtun,
	pue_codtpp,
	cia_codgrc
	ppl_codigo,
	ppl_codtpl,
	ppl_codigo_planilla,
	ppl_fecha_ini,
	ppl_fecha_fin,
	ppl_fecha_pago,
	ppl_fecha_corte,
	ppl_frecuencia,
	ppl_mes,
	ppl_anio,
	ppl_estado,
	'Planilla al '+ CONVERT(VARCHAR,ppl_fecha_fin,103) + ' período: ' + CONVERT(VARCHAR, ppl_codigo_planilla) + ' año: ' + CONVERT(VARCHAR, dco_anio)+ ' mes:' + CONVERT(VARCHAR, dco_mes) descripcion_periodo_planilla,	
	dco_codigo,
	dco_tipo_partida,
	dco_grupo,
	dco_centro_costo,
	CONVERT(INT, dco_linea) dco_linea,
	dco_mes,
	dco_anio,
	dco_cta_contable,
	dco_descripcion,
	ROUND(dco_debitos, 3) dco_debitos,
	ROUND(dco_creditos, 3) dco_creditos,
	ROUND(dco_creditos - dco_debitos, 3) dco_valor,
	dco_tasa_cambio,	
	ROUND(dco_debitos_usd, 3) dco_debitos_usd,
	ROUND(dco_creditos_usd, 3) dco_creditos_usd,
	ROUND(dco_creditos_usd - dco_debitos_usd, 3) dco_valor_usd
FROM cr.dco_datos_contables
	JOIN sal.ppl_periodos_planilla ON dco_codppl = ppl_codigo
	LEFT JOIN exp.set_emp_empleos ON dco_codemp = emp_codigo
WHERE (dco_creditos <> 0 OR dco_debitos <> 0)