IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_calculo_liq_encabezado'))
BEGIN
	DROP PROCEDURE cr.rep_calculo_liq_encabezado
END

GO

--EXEC cr.rep_calculo_liq_encabezado 1, '2335', '06/03/2015', 'admin'
CREATE PROCEDURE cr.rep_calculo_liq_encabezado (
	@codcia INT = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@fecha_retiro_txt VARCHAR(10) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET DATEFORMAT DMY
SET NOCOUNT ON
SET LANGUAGE 'spanish'

DECLARE @codpai VARCHAR(2),
	@codemp INT,
	@fecha_retiro DATETIME,
	@codcmr_renuncia INT,
	@codcmr_despido INT,
	@codtid_domicilio INT,
	@codrsa_salario INT,
	@nombre_jefe VARCHAR(80),
	@codtig_aguinaldo INT,
	@codtig_cesantia INT,
	@codtig_preaviso INT,
	@codtig_vacaciones INT,
	@codtig_ahorro_escolar INT,
	@codtig_ahorro_patronal INT,
	@codtdc_asociacion INT,
	@codagr_otros_ingresos INT,
	@codagr_otros_descuentos INT,
	@cesantia_aplica VARCHAR(1),
	@cesantia_total_ingresos MONEY,
	@cesantia_meses_promedio INT,
	@cesantia_promedio MONEY,
	@cesantia_promedio_diario MONEY,
	@cesantia_salario_minimo MONEY,
	@cesantia_dias REAL,
	@cesantia_valor MONEY,
	@preaviso_aplica VARCHAR(1),
	@preaviso_total_ingresos MONEY,
	@preaviso_meses_promedio INT,
	@preaviso_promedio MONEY,
	@preaviso_promedio_diario MONEY,
	@preaviso_salario_minimo MONEY,
	@preaviso_dias REAL,
	@preaviso_valor MONEY,
	@vacaciones_aplica VARCHAR(1),
	@vacaciones_total_ingresos MONEY,
	@vacaciones_meses_promedio INT,
	@vacaciones_promedio MONEY,
	@vacaciones_promedio_diario MONEY,
	@vacaciones_salario_minimo MONEY,
	@vacaciones_dias REAL,
	@vacaciones_valor MONEY,
	@aguinaldo_aplica VARCHAR(1),
	@aguinaldo_dias REAL,
	@aguinaldo_valor MONEY,
	@ahorro_patronal_aplica VARCHAR(1),
	@ahorro_patronal_valor MONEY,
	@ahorro_escolar_aplica VARCHAR(1),
	@ahorro_escolar_valor MONEY,
	@otros_ingresos_aplica VARCHAR(1),
	@otros_ingresos_valor MONEY,
	@total_ingresos MONEY,
	@asociacion_valor MONEY,
	@otros_descuentos_valor MONEY,
	@total_descuentos MONEY,
	@neto MONEY

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)
SET @fecha_retiro = CONVERT(DATETIME, @fecha_retiro_txt)

SELECT @codpai = cia_codpai
FROM eor.cia_companias
WHERE cia_codigo = @codcia

SET @codcmr_renuncia = gen.get_valor_parametro_int('CodigoCMR_Renuncia', @codpai, NULL, NULL, NULL)
SET @codcmr_despido = gen.get_valor_parametro_int('CodigoCMR_Despido', @codpai, NULL, NULL, NULL)
SET @codtid_domicilio = gen.get_valor_parametro_int('CodigoTid_Domicilio', @codpai, NULL, NULL, NULL)
SET @codrsa_salario = gen.get_valor_parametro_int('CodigoRSA_Salario', NULL, NULL, @codcia, NULL)

SET @codtig_aguinaldo = ISNULL(gen.get_valor_parametro_int('CodigoTIG_Aguinaldo',NULL,NULL,@codcia,NULL), 0)
SET @codtig_cesantia = ISNULL(gen.get_valor_parametro_int('CodigoTIG_Cesantia',NULL,NULL,@codcia,NULL), 0)
SET @codtig_preaviso = ISNULL(gen.get_valor_parametro_int('CodigoTIG_Preaviso',NULL,NULL,@codcia,NULL), 0)
SET @codtig_vacaciones = ISNULL(gen.get_valor_parametro_int('CodigoTIG_VacacionesNoAfectas',NULL,NULL,@codcia,NULL), 0)
SET @codtig_ahorro_escolar = ISNULL(gen.get_valor_parametro_INT ('CodigoTIG_AhorroEscolar',NULL,NULL,@codcia,NULL), 0)
SET @codtig_ahorro_patronal = ISNULL(gen.get_valor_parametro_INT ('CodigoTIG_AhorroPatronal',NULL,NULL,@codcia,NULL), 0)
SET @codtdc_asociacion = ISNULL(gen.get_valor_parametro_INT ('CodigoTDC_Asociacion',NULL,NULL,@codcia,NULL), 0)

SELECT @codagr_otros_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRCalculoPrestacionesLaboralesOtrosIngresos'

SELECT @codagr_otros_descuentos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRCalculoPrestacionesLaboralesOtrosDescuentos'

SELECT @nombre_jefe = exp_primer_nom + ' ' + exp_primer_ape
FROM exp.emp_empleos e
	JOIN eor.plz_plazas p ON e.emp_codplz = p.plz_codigo
	JOIN eor.pjf_plaza_jefes ON p.plz_codigo = pjf_codplz
	JOIN eor.plz_plazas j ON pjf_codplz_jefe = j.plz_codigo
	JOIN exp.emp_empleos m ON j.plz_codigo = m.emp_codplz
	JOIN exp.exp_expedientes ON m.emp_codexp = exp_codigo
WHERE e.emp_codigo = @codemp

SELECT @cesantia_total_ingresos = ISNULL(MAX(hli_base_calculo), 0.00),
	@cesantia_meses_promedio = ISNULL(MAX(hli_meses_promedio), 0.00),
	@cesantia_promedio = ISNULL(MAX(hli_promedio_mensual), 0.00),
	@cesantia_promedio_diario = ISNULL(MAX(hli_promedio_diario), 0.00),
	@cesantia_salario_minimo = ISNULL(MAX(hli_salario_minimo_diario), 0.00),
	@cesantia_dias = ISNULL(MAX(dli_tiempo), 0),
	@cesantia_valor = ISNULL(MAX(dli_valor), 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
	JOIN cr.hli_historico_liquidaciones ON lie_codemp = hli_codemp AND lie_fecha_retiro = hli_fecha_retiro AND dli_codtig = hli_codtig
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_cesantia

SELECT @preaviso_total_ingresos = ISNULL(MAX(hli_base_calculo), 0.00),
	@preaviso_meses_promedio = ISNULL(MAX(hli_meses_promedio), 0.00),
	@preaviso_promedio = ISNULL(MAX(hli_promedio_mensual), 0.00),
	@preaviso_promedio_diario = ISNULL(MAX(hli_promedio_diario), 0.00),
	@preaviso_salario_minimo = ISNULL(MAX(hli_salario_minimo_diario), 0.00),
	@preaviso_dias = ISNULL(MAX(dli_tiempo), 0),
	@preaviso_valor = ISNULL(MAX(dli_valor), 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
	JOIN cr.hli_historico_liquidaciones ON lie_codemp = hli_codemp AND lie_fecha_retiro = hli_fecha_retiro AND dli_codtig = hli_codtig
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_preaviso

SELECT @vacaciones_total_ingresos = ISNULL(MAX(hli_base_calculo), 0.00),
	@vacaciones_meses_promedio = ISNULL(MAX(hli_meses_promedio), 0.00),
	@vacaciones_promedio = ISNULL(MAX(hli_promedio_mensual), 0.00),
	@vacaciones_promedio_diario = ISNULL(MAX(hli_promedio_diario), 0.00),
	@vacaciones_salario_minimo = ISNULL(MAX(hli_salario_minimo_diario), 0.00),
	@vacaciones_dias = ISNULL(MAX(dli_tiempo), 0),
	@vacaciones_valor = ISNULL(MAX(dli_valor), 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
	JOIN cr.hli_historico_liquidaciones ON lie_codemp = hli_codemp AND lie_fecha_retiro = hli_fecha_retiro AND dli_codtig = hli_codtig
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_preaviso

SELECT @aguinaldo_dias = ISNULL(dli_tiempo, 0),
	@aguinaldo_valor = ISNULL(dli_valor, 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_aguinaldo

SELECT @ahorro_patronal_valor = ISNULL(dli_valor, 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_ahorro_patronal

SELECT @ahorro_patronal_valor = ISNULL(dli_valor, 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_ahorro_patronal

SELECT @ahorro_escolar_valor = ISNULL(dli_valor, 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_ahorro_escolar

SELECT @otros_ingresos_valor = ISNULL(SUM(dli_valor), 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig IN (SELECT iag_codtig
					   FROM sal.iag_ingresos_agrupador
					   WHERE iag_codagr = @codagr_otros_ingresos)

IF @cesantia_valor > 0.00
	SET @cesantia_aplica = 'X'

IF @preaviso_valor > 0.00
	SET @preaviso_aplica = 'X'

IF @vacaciones_valor > 0.00
	SET @vacaciones_aplica = 'X'

IF @aguinaldo_valor > 0.00
	SET @aguinaldo_aplica = 'X'
	
IF @ahorro_patronal_valor > 0.00
	SET @ahorro_patronal_aplica = 'X'

IF @ahorro_escolar_valor > 0.00
	SET @ahorro_escolar_aplica = 'X'

IF @otros_ingresos_valor > 0.00
	SET @otros_ingresos_aplica = 'X'

SET @total_ingresos = ISNULL(@cesantia_valor, 0.00) +
	ISNULL(@preaviso_valor, 0.00) + 
	ISNULL(@vacaciones_valor, 0.00) +
	ISNULL(@aguinaldo_valor, 0.00) +
	ISNULL(@ahorro_patronal_valor, 0.00) +
	ISNULL(@ahorro_escolar_valor, 0.00) +
	ISNULL(@otros_ingresos_valor, 0.00)

SELECT @asociacion_valor = ISNULL(dld_valor, 0)
FROM acc.lie_liquidaciones
	JOIN acc.dld_detliq_descuentos ON dld_codlie = lie_codigo
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dld_codtdc = @codtdc_asociacion

SELECT @otros_descuentos_valor = ISNULL(SUM(dld_valor), 0)
FROM acc.lie_liquidaciones
	JOIN acc.dld_detliq_descuentos ON dld_codlie = lie_codigo
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dld_codtdc IN (SELECT dag_codtdc
					   FROM sal.dag_descuentos_agrupador
					   WHERE dag_codagr = @codagr_otros_descuentos)

SET @total_descuentos = ISNULL(@asociacion_valor, 0.00) +
	ISNULL(@otros_descuentos_valor, 0.00)

SET @neto = @total_ingresos - @total_descuentos

SELECT cia_descripcion,
	REPLACE(REPLACE(CONVERT(VARCHAR, lie_fecha_solicitud, 106), ' ', '-'), ',', '') lie_fecha_solicitud,
	REPLACE(REPLACE(CONVERT(VARCHAR, lie_fecha_retiro, 106), ' ', '-'), ',', '') lie_fecha_retiro,
	CASE WHEN lie_codcmr = @codcmr_renuncia THEN 'X' ELSE '' END lie_es_renuncia,
	CASE WHEN lie_codcmr = @codcmr_despido THEN 'X' ELSE '' END lie_es_despido,
	exp_primer_nom + ISNULL(' ' + exp_segundo_nom, '') + ISNULL(' ' + exp_otros_nom, '') exp_nombres,
	exp_primer_ape,
	exp_segundo_ape,
	dex_direccion,
	ISNULL(exp_telefono_interno, ISNULL(exp_telefono_movil, dex_telefono)) exp_telefono,
	ide_cip,
	ISNULL(ide_isss, ide_cip) ide_isss,
	gen.capitalizar_texto(gen.obtiene_estado_civil(exp_sexo, exp_estado_civil)) exp_estado_civil,
	REPLACE(REPLACE(CONVERT(VARCHAR, emp_fecha_ingreso, 106), ' ', '-'), ',', '') emp_fecha_ingreso,
	REPLACE(REPLACE(CONVERT(VARCHAR, emp_fecha_retiro, 106), ' ', '-'), ',', '') emp_fecha_retiro,
	plz_nombre plz_nombre,
	uni_descripcion,
	@nombre_jefe emp_nombre_jefe,
	ese_valor ese_salario,
	0.00 ese_aumento,
	0.00 ese_salario_nuevo,
	0.00 ese_porcentaje_aumento,
	mrt_nombre,
	gen.obtiene_antiguedad_det(emp_fecha_ingreso, emp_fecha_retiro) antiguedad_texto,
	ISNULL(@cesantia_total_ingresos, ISNULL(@preaviso_total_ingresos, ISNULL(@vacaciones_total_ingresos, 0.00))) total_base,
	ISNULL(@cesantia_meses_promedio, ISNULL(@preaviso_meses_promedio, ISNULL(@vacaciones_meses_promedio, 0.00))) meses_promedio,
	ISNULL(@cesantia_promedio, ISNULL(@preaviso_promedio, ISNULL(@vacaciones_promedio, 0.00))) promedio,
	ISNULL(@cesantia_promedio_diario, ISNULL(@preaviso_promedio_diario, ISNULL(@vacaciones_promedio_diario, 0.00))) promedio_diario,
	ISNULL(@cesantia_salario_minimo, ISNULL(@preaviso_salario_minimo, ISNULL(@vacaciones_salario_minimo, 0.00))) salario_minimo,
	@preaviso_aplica preaviso_aplica,
	@cesantia_aplica cesantia_aplica,
	@vacaciones_aplica vacaciones_aplica,
	@aguinaldo_aplica aguinaldo_aplica,
	@ahorro_patronal_aplica ahorro_patronal_aplica,
	@ahorro_escolar_aplica ahorro_escolar_aplica,
	@otros_ingresos_aplica otros_ingresos_aplica,
	ISNULL(@preaviso_valor, 0.00) preaviso_valor,
	ISNULL(@preaviso_dias, 0.00)  preaviso_dias,
	ISNULL(@cesantia_valor, 0.00)  cesantia_valor,
	ISNULL(@cesantia_dias, 0.00)  cesantia_dias,
	ISNULL(@vacaciones_valor, 0.00)  vacaciones_valor,
	ISNULL(@vacaciones_dias, 0.00)  vacaciones_dias,
	ISNULL(@aguinaldo_valor, 0.00)  aguinaldo_valor,
	ISNULL(@aguinaldo_dias, 0.00)  aguinaldo_dias,
	ISNULL(@ahorro_patronal_valor, 0.00)  ahorro_patronal_valor,
	ISNULL(@ahorro_escolar_valor, 0.00)  ahorro_escolar_valor,
	ISNULL(@otros_ingresos_valor, 0.00)  otros_ingresos_valor,
	ISNULL(@total_ingresos, 0.00)  total_ingresos,
	ISNULL(@asociacion_valor, 0.00)  asociacion_valor,
	ISNULL(@otros_descuentos_valor, 0.00)  otros_descuentos_valor,
	ISNULL(@total_descuentos, 0.00)  total_descuentos,
	ISNULL(@neto, 0.00) neto
FROM acc.lie_liquidaciones
	JOIN exp.mrt_motivos_retiro ON lie_codmrt = mrt_codigo
	JOIN exp.emp_empleos ON lie_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.uni_unidades ON plz_coduni = uni_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	LEFT JOIN exp.ese_estructura_sal_empleos ON emp_codigo = ese_codemp AND ese_codrsa = @codrsa_salario AND ese_estado = 'V'
	LEFT JOIN exp.dex_direcciones_expediente ON dex_codexp = exp_codigo AND dex_codtid = @codtid_domicilio
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE lie_codemp = codemp)