IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_renta_acumulada'))
BEGIN
	DROP PROCEDURE cr.rep_renta_acumulada
END

GO

--cr.rep_renta_acumulada 1, NULL, 2015, 1, 3, 'admin'
CREATE procedure cr.rep_renta_acumulada (
   @codcia INT = NULL,
   @codemp_alternativo VARCHAR(36) = NULL,
   @anio INT = NULL,
   @mes_ini	INT = NULL,
   @mes_fin INT = NULL,
   @usuario VARCHAR(50) = NULL
)

AS
 
SET NOCOUNT ON

SET @mes_fin = ISNULL(@mes_fin, @mes_ini)

DECLARE @codpai VARCHAR(2),
	@codemp INT,
	@cia_descripcion VARCHAR(50),
	@codagr_ingresos INT,
	@codagr_isr INT,
	@codagr_pension INT,
	@isr_conyugue MONEY,
	@isr_hijos MONEY

SELECT @codpai = cia_codpai,
	@cia_descripcion = cia_descripcion
FROM eor.cia_companias
WHERE cia_codigo = @codcia

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRRentaAcumuladaIngresos'
	AND agr_codpai = @codpai

SELECT @codagr_isr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRRentaAcumuladaISR'

SELECT @codagr_pension = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRRentaAcumuladaPension'

SET @isr_conyugue = ISNULL(gen.get_valor_parametro_money('ISRValorConyugue', @codpai, NULL, NULL, NULL), 0.00)
SET @isr_hijos = ISNULL(gen.get_valor_parametro_money('ISRValorHijos', @codpai, NULL, NULL, NULL), 0.00)

SELECT @cia_descripcion cia_descripcion,
	@anio anio,
	gen.nombre_mes(@mes_ini) mes_ini,
	gen.nombre_mes(@mes_fin) mes_fin,
	exp_codigo_alternativo,
	h.hpa_nombres_apellidos, 
	ide_cip,
	ISNULL((
		SELECT SUM(inn_valor * ISNULL(CASE WHEN inn_codmon = 'USD' THEN a.hpa_tasa_cambio ELSE 1.00 END, 0.00))
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla l ON inn_codppl = l.ppl_codigo
			JOIN sal.hpa_hist_periodos_planilla a ON a.hpa_codppl = inn_codppl AND a.hpa_codemp = inn_codemp
		WHERE inn_codemp = h.hpa_codemp
			AND l.ppl_anio = p.ppl_anio
			AND l.ppl_mes BETWEEN @mes_ini AND @mes_fin
			AND inn_codtig IN (SELECT iag_codtig
								FROM sal.iag_ingresos_agrupador
								WHERE iag_codagr = @codagr_ingresos)), 0.00) ingresos, 
	ISNULL((
		SELECT SUM(dss_valor * ISNULL(CASE WHEN dss_codmon = 'USD' THEN a.hpa_tasa_cambio ELSE 1.00 END, 0.00))
		FROM sal.dss_descuentos
			JOIN sal.ppl_periodos_planilla l ON dss_codppl = l.ppl_codigo
			JOIN sal.hpa_hist_periodos_planilla a ON a.hpa_codppl = dss_codppl AND a.hpa_codemp = dss_codemp
		WHERE dss_codemp = h.hpa_codemp
			AND l.ppl_anio = p.ppl_anio
			AND l.ppl_mes BETWEEN @mes_ini AND @mes_fin
			AND dss_codtdc IN (SELECT dag_codtdc
								FROM sal.dag_descuentos_agrupador
								WHERE dag_codagr = @codagr_isr)), 0.00) isr,
	CASE 
		WHEN ISNULL(MAX(CONVERT(INT, gen.get_pb_field_data_bit(emp_property_bag_data, 'AplicaISRConyugue'))), 1) = 1
		THEN @isr_conyugue
		ELSE 0.00
	END +
	ISNULL(MAX(gen.get_pb_field_data_float(emp_property_bag_data, 'NumeroHijos')), 0.00) * @isr_hijos credito_isr,
	ISNULL((
		SELECT SUM(dss_valor * ISNULL(CASE WHEN dss_codmon = 'USD' THEN a.hpa_tasa_cambio ELSE 1.00 END, 0.00))
		FROM sal.dss_descuentos
			JOIN sal.ppl_periodos_planilla l ON dss_codppl = ppl_codigo
			JOIN sal.hpa_hist_periodos_planilla a ON a.hpa_codppl = dss_codppl AND a.hpa_codemp = dss_codemp
		WHERE dss_codemp = h.hpa_codemp
			AND l.ppl_anio = p.ppl_anio
			AND l.ppl_mes BETWEEN @mes_ini AND @mes_fin
			AND dss_codtdc IN (SELECT dag_codtdc
								FROM sal.dag_descuentos_agrupador
								WHERE dag_codagr = @codagr_pension)), 0.00) pension
FROM sal.hpa_hist_periodos_planilla h
	JOIN sal.ppl_periodos_planilla p ON h.hpa_codppl = p.ppl_codigo
	JOIN sal.tpl_tipo_planilla ON p.ppl_codtpl = tpl_codigo
	JOIN exp.emp_empleos ON h.hpa_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE plz_codcia = @codcia
	AND h.hpa_codemp = ISNULL(@codemp, emp_codigo)
	AND p.ppl_anio = @anio
	AND p.ppl_mes BETWEEN @mes_ini AND @mes_fin
	AND EXISTS (SELECT NULL
				FROM sal.dss_descuentos
				WHERE dss_codppl = h.hpa_codppl
					AND dss_codemp = h.hpa_codemp
					AND dss_valor > 0.00
					AND dss_codtdc IN (SELECT dag_codtdc
								       FROM sal.dag_descuentos_agrupador
									   WHERE dag_codagr = @codagr_isr))
	AND sco.permiso_empleo(h.hpa_codemp, @usuario) = 1
GROUP BY p.ppl_anio, h.hpa_codemp, exp_codigo_alternativo, h.hpa_nombres_apellidos, ide_cip, tpl_codmon