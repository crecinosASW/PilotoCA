IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_salarios_por_periodo'))
BEGIN
	DROP PROCEDURE cr.rep_salarios_por_periodo
END

GO

--EXEC cr.rep_salarios_por_periodo 1, '1', '201503', NULL, 'admin'
CREATE PROCEDURE cr.rep_salarios_por_periodo (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET DATEFORMAT DMY
SET NOCOUNT ON

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@codppl INT,
	@codemp INT,
	@codagr_ingresos INT

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

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRSalariosPorPeriodoIngresos'

SELECT tpl_codigo_visual,
	hpa_nombre_tipo_planilla,
	exp_codigo_alternativo,
	hpa_apellidos_nombres,
	fecha,
	abreviatura,
	tipo,
	valor
FROM sal.hpa_hist_periodos_planilla
	JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN (
		SELECT ext_codppl codppl,
			ext_codemp codemp,
			ext_fecha fecha,
			tig_orden orden,
			tig_abreviatura abreviatura,
			tig_descripcion tipo,
			SUM(ext_valor_a_pagar) valor
		FROM sal.ext_horas_extras
			JOIN sal.the_tipos_hora_extra ON ext_codthe = the_codigo
			JOIN sal.tig_tipos_ingreso ON the_codtig = tig_codigo
		WHERE ext_aplicado_planilla = 1
		GROUP BY ext_codppl, ext_codemp, ext_fecha, tig_orden, tig_abreviatura, tig_descripcion
			
		UNION

		SELECT oin_codppl codppl,
			oin_codemp codemp,
			oin_fecha fecha,
			tig_orden orden,
			tig_abreviatura abreviatura,
			tig_descripcion tipo,
			SUM(oin_valor_a_pagar) valor
		FROM sal.oin_otros_ingresos
			JOIN sal.tig_tipos_ingreso ON oin_codtig = tig_codigo
		WHERE oin_aplicado_planilla = 1
			AND oin_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ingresos)
		GROUP BY oin_codppl, oin_codemp, oin_fecha, tig_orden, tig_abreviatura, tig_descripcion) d ON hpa_codppl = codppl AND hpa_codemp = codemp
WHERE hpa_codppl = @codppl
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE codemp = hpa_codemp)
ORDER BY exp_codigo_alternativo, fecha, orden, tipo