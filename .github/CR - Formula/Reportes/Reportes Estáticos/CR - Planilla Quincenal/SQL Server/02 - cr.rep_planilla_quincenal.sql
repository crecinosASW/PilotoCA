IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_planilla_quincenal'))
BEGIN
	DROP PROCEDURE cr.rep_planilla_quincenal
END

GO

----------------------------------------------------------------------------------
-- evolution                                                                    --
-- reporte de planilla mensual con anticipo quincenal - costa rica               --
----------------------------------------------------------------------------------
--EXEC cr.rep_planilla_quincenal 5, '1', '20140802', NULL, NULL, 'jcsoria'
CREATE PROCEDURE cr.rep_planilla_quincenal (
   @codcia INT = NULL,
   @codtpl_visual VARCHAR(20) = NULL,
   @codppl_visual VARCHAR(10) = NULL,
   @codarf INT = NULL,
   @coduni INT = NULL,
   @usuario VARCHAR(50) = NULL
)

AS

SET NOCOUNT ON

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@codppl INT,
	@codagr_ordinario INT,
	@codagr_comp_ordinario INT,
	@codagr_extras INT,
	@codagr_bonificaciones INT,
	@codagr_otros_ingresos INT,
	@codagr_ccss INT,
	@codagr_prestamos INT,
	@codagr_seguros INT,
	@codagr_isr INT,
	@codagr_otros_descuentos INT

SELECT @codpai = cia_codpai 
FROM eor.cia_companias 
WHERE cia_codigo = @codcia

SELECT @codtpl = tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual
	
SELECT @codppl = ppl_codigo
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_codigo_planilla = @codppl_visual

SELECT @codagr_ordinario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalOrdinario'
	AND agr_codpai = @codpai

SELECT @codagr_comp_ordinario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalCompOrdinario'
	AND agr_codpai = @codpai

SELECT @codagr_extras = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalExtraordinario'
	AND agr_codpai = @codpai

SELECT @codagr_bonificaciones = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalBonificaciones'
	AND agr_codpai = @codpai

SELECT @codagr_otros_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalOtrosIngresos'
	AND agr_codpai = @codpai

SELECT @codagr_ccss = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalCCSS'
	AND agr_codpai = @codpai

SELECT @codagr_prestamos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalPrestamos'
	AND agr_codpai = @codpai

SELECT @codagr_seguros = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalSeguros'
	AND agr_codpai = @codpai

SELECT @codagr_isr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalISR'
	AND agr_codpai = @codpai

SELECT @codagr_otros_descuentos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalOtrosDescuentos'
	AND agr_codpai = @codpai

SELECT ROW_NUMBER() OVER(PARTITION BY hpa_nombre_areafun, hpa_nombre_unidad ORDER BY hpa_nombre_areafun, hpa_nombre_unidad, hpa_codemp ASC) contador,
	cia_descripcion,
	hpa_nombre_tipo_planilla,
	ppl_codigo_planilla,
	ppl_fecha_ini,
	ppl_fecha_fin,
	exp_codigo_alternativo,
	hpa_nombre_areafun,
	hpa_nombre_unidad,
	hpa_nombres_apellidos,
	hpa_salario,
	ISNULL((
		SELECT SUM(inn_tiempo)
		FROM sal.inn_ingresos
		WHERE inn_codppl = hpa_codppl
			AND inn_codemp = hpa_codemp
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ordinario)), 0.00) dias,
	ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
		WHERE inn_codppl = hpa_codppl
			AND inn_codemp = hpa_codemp
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ordinario)), 0.00) ordinario,
	ISNULL((
			SELECT SUM(inn_valor)
			FROM sal.inn_ingresos
			WHERE inn_codppl = hpa_codppl
				AND inn_codemp = hpa_codemp
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @codagr_comp_ordinario)), 0.00) complemento_ordinario,
	ISNULL((
			SELECT SUM(inn_valor)
			FROM sal.inn_ingresos
			WHERE inn_codppl = hpa_codppl
				AND inn_codemp = hpa_codemp
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @codagr_extras)), 0.00) extraordinario,		
	ISNULL((
			SELECT SUM(inn_valor)
			FROM sal.inn_ingresos
			WHERE inn_codppl = hpa_codppl
				AND inn_codemp = hpa_codemp
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @codagr_bonificaciones)), 0.00) bonificaciones,	
	ISNULL((
			SELECT SUM(inn_valor)
			FROM sal.inn_ingresos
			WHERE inn_codppl = hpa_codppl
				AND inn_codemp = hpa_codemp
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @codagr_otros_ingresos)), 0.00) otros_ingresos,									   	
	ISNULL((
			SELECT SUM(dss_valor)
			FROM sal.dss_descuentos
			WHERE dss_codppl = hpa_codppl
				AND dss_codemp = hpa_codemp
				AND dss_codtdc IN (SELECT dag_codtdc
								   FROM sal.dag_descuentos_agrupador
								   WHERE dag_codagr = @codagr_ccss)), 0.00) ccss,		
	ISNULL((
			SELECT SUM(dss_valor)
			FROM sal.dss_descuentos
			WHERE dss_codppl = hpa_codppl
				AND dss_codemp = hpa_codemp
				AND dss_codtdc IN (SELECT dag_codtdc
								   FROM sal.dag_descuentos_agrupador
								   WHERE dag_codagr = @codagr_prestamos)), 0.00) prestamos,		
	ISNULL((
			SELECT SUM(dss_valor)
			FROM sal.dss_descuentos
			WHERE dss_codppl = hpa_codppl
				AND dss_codemp = hpa_codemp
				AND dss_codtdc IN (SELECT dag_codtdc
								   FROM sal.dag_descuentos_agrupador
								   WHERE dag_codagr = @codagr_seguros)), 0.00) seguros,		
	ISNULL((
			SELECT SUM(dss_valor)
			FROM sal.dss_descuentos
			WHERE dss_codppl = hpa_codppl
				AND dss_codemp = hpa_codemp
				AND dss_codtdc IN (SELECT dag_codtdc
								   FROM sal.dag_descuentos_agrupador
								   WHERE dag_codagr = @codagr_isr)), 0.00) isr,
	ISNULL((
			SELECT SUM(dss_valor)
			FROM sal.dss_descuentos
			WHERE dss_codppl = hpa_codppl
				AND dss_codemp = hpa_codemp
				AND dss_codtdc IN (SELECT dag_codtdc
								   FROM sal.dag_descuentos_agrupador
								   WHERE dag_codagr = @codagr_otros_descuentos)), 0.00) otros_descuentos								   							   							   							   							   							   								   								   							   							   
FROM sal.hpa_hist_periodos_planilla
	JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE hpa_codppl = @codppl
	AND hpa_codarf = ISNULL(@codarf, hpa_codarf)
	AND hpa_coduni = ISNULL(@coduni, hpa_coduni)
	AND sco.permiso_empleo(hpa_codemp, @usuario) = 1
ORDER BY hpa_nombre_areafun, hpa_nombre_unidad, hpa_codemp ASC	