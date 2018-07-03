IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_planilla_detallada'))
BEGIN
	DROP PROCEDURE cr.rep_planilla_detallada
END

GO

--EXEC cr.rep_planilla_detallada 1, '4', '20150301', 'admin'
CREATE PROCEDURE cr.rep_planilla_detallada (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET NOCOUNT ON

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@codppl INT,
	@codagr_ingresos INT,
	@codagr_descuentos INT

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

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaDetalladaIngresos'
	AND agr_codpai = @codpai

SELECT @codagr_descuentos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaDetalladaDescuentos'
	AND agr_codpai = @codpai

SELECT cia_descripcion,
	cia_direccion,
	cia_telefonos,
	exp_codigo_alternativo,
	hpa_apellidos_nombres,
	ISNULL(ide_cip, ide_pasaporte) ide_cip,
	cco_cta_contable,
	cco_descripcion,
	hpa_codplz,
	hpa_nombre_plaza,
	hpa_coduni,
	hpa_nombre_unidad,
	tpl_codigo_visual,
	hpa_nombre_tipo_planilla,
	tipo,
	orden,
	ISNULL(descripcion, '') descripcion,
	ISNULL(valor, 0.00) valor,
	ISNULL(tiempo, 0.00) tiempo
FROM sal.hpa_hist_periodos_planilla
	LEFT JOIN (
		SELECT inn_codppl codppl,
			inn_codemp codemp,
			'I' tipo,
			tig_descripcion descripcion,
			tig_orden orden,
			SUM(inn_valor) valor,
			SUM(inn_tiempo) tiempo
		FROM sal.inn_ingresos
			JOIN sal.tig_tipos_ingreso ON inn_codtig = tig_codigo
		WHERE inn_codppl = @codppl
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ingresos)
		GROUP BY inn_codppl, inn_codemp, tig_descripcion, tig_orden

		UNION

		SELECT dss_codppl codppl,
			dss_codemp codemp,
			'D' tipo,
			tdc_descripcion descripcion,
			tdc_orden orden,
			SUM(dss_valor) valor,
			SUM(dss_tiempo) tiempo
		FROM sal.dss_descuentos
			JOIN sal.tdc_tipos_descuento ON dss_codtdc = tdc_codigo
		WHERE dss_codppl = @codppl
			AND dss_codtdc IN (SELECT dag_codtdc
							   FROM sal.dag_descuentos_agrupador
							   WHERE dag_codagr = @codagr_descuentos)
		GROUP BY dss_codppl, dss_codemp, tdc_descripcion, tdc_orden) d ON hpa_codppl = codppl AND hpa_codemp = codemp
	JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	LEFT JOIN eor.cpp_centros_costo_plaza ON plz_codigo = cpp_codplz
	LEFT JOIN eor.cco_centros_de_costo ON cpp_codcco = cco_codigo
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE hpa_codppl = @codppl
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE codemp = hpa_codemp)
ORDER BY exp_codigo_alternativo, tipo DESC, orden, descripcion