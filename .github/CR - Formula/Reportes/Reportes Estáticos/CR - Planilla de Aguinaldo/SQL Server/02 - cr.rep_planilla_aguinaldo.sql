IF EXISTS (SELECT NULL
		   FROM sys.objects 
		   WHERE object_id = object_id('cr.rep_planilla_aguinaldo'))
BEGIN
	DROP PROCEDURE cr.rep_planilla_aguinaldo
END

GO

--EXECUTE cr.rep_planilla_aguinaldo 5, '2', '2014', NULL, NULL, 'jcsoria'
CREATE PROCEDURE cr.rep_planilla_aguinaldo (
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
	@cia_descripcion VARCHAR(50),
	@codagr_aguinaldo INT,
	@codagr_descuentos INT

SELECT @codpai = cia_codpai,
	@cia_descripcion = cia_descripcion
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

SELECT @codagr_aguinaldo = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai	
	AND agr_abreviatura = 'CRPlanillaAguinaldo'

SELECT @codagr_descuentos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaAguinaldoDescuentos'
	AND agr_codpai = 'cr'

SELECT ROW_NUMBER() OVER(PARTITION BY hpa_nombre_areafun, hpa_nombre_unidad ORDER BY hpa_nombre_areafun, hpa_nombre_unidad, hpa_codemp ASC) contador,
	cia_descripcion,
	hpa_nombre_tipo_planilla,
	ppl_codigo_planilla,
	ppl_fecha_ini,
	ppl_fecha_fin,
	exp_codigo_alternativo,
	hpa_codemp,
	hpa_apellidos_nombres, 
	hpa_nombre_areafun,
	hpa_nombre_unidad, 
	hpa_salario,
	hpa_fecha_ingreso,
	dias,
	aguinaldo,
	descuentos,
	aguinaldo - descuentos neto
FROM (
	SELECT @cia_descripcion cia_descripcion,
		hpa_nombre_tipo_planilla,
		ppl_codigo_planilla,
		ppl_fecha_ini,
		ppl_fecha_fin,
		exp_codigo_alternativo,
		hpa_codemp,
		hpa_apellidos_nombres, 
		hpa_nombre_areafun,
		hpa_nombre_unidad, 
		hpa_salario,
		hpa_fecha_ingreso,
		ISNULL((
			SELECT SUM(inn_tiempo)
			FROM sal.inn_ingresos
			WHERE inn_codppl = hpa_codppl
				AND inn_codemp = hpa_codemp
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @codagr_aguinaldo)), 0.00) dias,
		ISNULL((
			SELECT SUM(inn_valor)
			FROM sal.inn_ingresos
			WHERE inn_codppl = hpa_codppl
				AND inn_codemp = hpa_codemp
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @codagr_aguinaldo)), 0.00) aguinaldo,
		ISNULL((
			SELECT SUM(dss_valor)
			FROM sal.dss_descuentos
			WHERE dss_codppl = hpa_codppl
				AND dss_codemp = hpa_codemp
				AND dss_codtdc IN (SELECT dag_codtdc
								   FROM sal.dag_descuentos_agrupador
								   WHERE dag_codagr = @codagr_descuentos)), 0.00) descuentos
	FROM sal.hpa_hist_periodos_planilla
		JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
		JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
		JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
	WHERE hpa_codppl = @codppl
		AND hpa_codarf = ISNULL(@codarf, hpa_codarf)
		AND hpa_coduni = ISNULL(@coduni, hpa_coduni)		
		AND EXISTS (SELECT NULL
					FROM sal.inn_ingresos
					WHERE inn_codppl = hpa_codppl
						AND inn_codemp = hpa_codemp
						AND inn_valor > 0.00)) a
WHERE sco.permiso_empleo(hpa_codemp, @usuario) = 1
ORDER BY hpa_nombre_areafun, hpa_nombre_unidad, a.hpa_codemp ASC