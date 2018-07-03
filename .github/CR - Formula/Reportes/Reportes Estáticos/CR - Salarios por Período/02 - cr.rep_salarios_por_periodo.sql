IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_salarios_por_periodo'))
BEGIN
	DROP PROCEDURE cr.rep_salarios_por_periodo
END

GO

--EXEC cr.rep_salarios_por_periodo 1, '1', '01/01/2014', '31/12/2014', NULL, 'admin'
CREATE PROCEDURE cr.rep_salarios_por_periodo (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@fecha_inicio_txt VARCHAR(10) = NULL,
	@fecha_fin_txt VARCHAR(10) = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET DATEFORMAT DMY
SET NOCOUNT ON

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@fecha_inicio DATETIME,
	@fecha_fin DATETIME,
	@codemp INT,
	@codagr_ingresos INT

SELECT @codpai = cia_codpai
FROM eor.cia_companias
WHERE cia_codigo = @codcia

SELECT @codtpl = tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual
	
SET @fecha_inicio = CONVERT(DATETIME, @fecha_inicio_txt)
SET @fecha_fin = CONVERT(VARCHAR, @fecha_fin_txt)

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRSalariosPorPeriodoIngresos'

SELECT tpl_codigo_visual,
	hpa_nombre_tipo_planilla,
	exp_codigo_alternativo,
	hpa_apellidos_nombres,
	RIGHT('00' + CONVERT(VARCHAR, ppl_mes), 2) ppl_mes,
	ppl_anio,
	tig_abreviatura,
	tig_descripcion,
	SUM(inn_valor) inn_valor
FROM sal.hpa_hist_periodos_planilla
	JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN sal.inn_ingresos ON inn_codemp = emp_codigo AND inn_codppl = hpa_codppl
	JOIN sal.tig_tipos_ingreso ON inn_codtig = tig_codigo
WHERE tpl_codigo = @codtpl
	AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio)) BETWEEN @fecha_inicio AND @fecha_fin
	AND hpa_codemp = ISNULL(@codemp, hpa_codemp)
	AND inn_codtig IN (SELECT iag_codtig
					   FROM sal.iag_ingresos_agrupador
					   WHERE iag_codagr = @codagr_ingresos)
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE codemp = hpa_codemp)
GROUP BY tpl_codigo_visual, hpa_nombre_tipo_planilla, exp_codigo_alternativo, hpa_apellidos_nombres, ppl_mes, ppl_anio, tig_abreviatura, tig_descripcion, tig_orden
ORDER BY exp_codigo_alternativo, ppl_anio, ppl_mes, tig_orden, tig_descripcion