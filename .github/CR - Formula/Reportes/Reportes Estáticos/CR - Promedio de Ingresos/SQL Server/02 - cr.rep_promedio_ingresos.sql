IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_promedio_ingresos'))
BEGIN
	DROP PROCEDURE cr.rep_promedio_ingresos
END

GO

--EXEC cr.rep_promedio_ingresos 5, '1',	NULL, 6, '81', 'jcsoria'
CREATE PROCEDURE cr.rep_promedio_ingresos (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(20) = NULL,
	@fecha_txt VARCHAR(10) = NULL,
	@meses_promedio INT = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,	
	@usuario VARCHAR(50) = NULL
)

AS

SET DATEFORMAT DMY
SET NOCOUNT ON

DECLARE @codemp INT

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@fecha_fin DATETIME,
	@fecha_ini DATETIME,
	@codagr_ordinario INT,
	@codagr_extraordinario INT,
	@codagr_comisiones INT,
	@codagr_otros_ingresos INT

SELECT @codpai = cia_codpai
FROM eor.cia_companias
WHERE cia_codigo = @codcia

SELECT @codtpl = tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual

SELECT @codagr_ordinario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPromedioOrdinario'
	AND agr_codpai = @codpai

SELECT @codagr_extraordinario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPromedioExtraordinario'
	AND agr_codpai = @codpai

SELECT @codagr_comisiones = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPromedioComisiones'
	AND agr_codpai = @codpai

SELECT @codagr_otros_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPromedioOtrosIngresos'
	AND agr_codpai = @codpai

SET @fecha_fin = CONVERT(DATETIME, @fecha_txt)

SET @meses_promedio = ISNULL(@meses_promedio, 6)

-- Si no se proporciona el parámetro de fecha se otbiente la fecha de fin de la planilla autorizada más reciente
IF @fecha_fin IS NULL
BEGIN
	SELECT @fecha_fin = MAX(ppl_fecha_fin)
	FROM sal.hpa_hist_periodos_planilla
		JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
	WHERE ppl_codtpl = @codtpl
		AND ppl_estado = 'Autorizado'
		AND hpa_codemp = ISNULL(@codemp, hpa_codemp)
END

-- Ajusta a meses completos
IF @fecha_fin = gen.fn_last_day(@fecha_fin)
	SET @fecha_fin = DATEADD(DD, 1, @fecha_fin)
ELSE
	SET @fecha_fin = CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, MONTH(@fecha_fin)) + '/' + CONVERT(VARCHAR, YEAR(@fecha_fin)))

SET @fecha_ini = DATEADD(mm, -@meses_promedio, @fecha_fin)
SET @fecha_fin = DATEADD(DD, -1, @fecha_fin)

SELECT cia_descripcion,
	exp_codigo_alternativo,
	hpa_nombres_apellidos,
	@meses_promedio meses_promedio,
	ppl_anio,
	gen.nombre_mes(ppl_mes) nombres_mes,
	ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla l ON inn_codppl = l.ppl_codigo
		WHERE l.ppl_codtpl = @codtpl
			AND l.ppl_anio = p.ppl_anio
			AND l.ppl_mes = p.ppl_mes
			AND inn_codemp = hpa_codemp
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ordinario)), 0.00) ordinario,
	ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla l ON inn_codppl = l.ppl_codigo
		WHERE l.ppl_codtpl = @codtpl
			AND l.ppl_anio = p.ppl_anio
			AND l.ppl_mes = p.ppl_mes
			AND inn_codemp = hpa_codemp
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_extraordinario)), 0.00) extraordinario,	
	ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla l ON inn_codppl = l.ppl_codigo
		WHERE l.ppl_codtpl = @codtpl
			AND l.ppl_anio = p.ppl_anio
			AND l.ppl_mes = p.ppl_mes
			AND inn_codemp = hpa_codemp
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_comisiones)), 0.00) comisiones,		
	ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla l ON inn_codppl = l.ppl_codigo
		WHERE l.ppl_codtpl = @codtpl
			AND l.ppl_anio = p.ppl_anio
			AND l.ppl_mes = p.ppl_mes
			AND inn_codemp = hpa_codemp
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_otros_ingresos)), 0.00) otros_ingresos
FROM sal.hpa_hist_periodos_planilla
	JOIN sal.ppl_periodos_planilla p ON hpa_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE tpl_codcia = @codcia
	AND ppl_codtpl = @codtpl
	AND ppl_fecha_pago >= @fecha_ini
	AND ppl_fecha_pago <= @fecha_fin
	AND hpa_codemp = ISNULL(@codemp, hpa_codemp)
	AND sco.permiso_empleo(hpa_codemp, @usuario) = 1	
GROUP BY cia_descripcion, hpa_codemp, exp_codigo_alternativo, hpa_nombres_apellidos, ppl_anio, ppl_mes
ORDER BY hpa_codemp ASC, ppl_anio DESC, ppl_mes DESC