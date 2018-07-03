IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_desgloce_concepto'))
BEGIN
	DROP PROCEDURE cr.rep_desgloce_concepto
END

GO

--EXEC cr.rep_desgloce_concepto 2, '01', '20140401', '20140702', NULL, 'jcsoria'
CREATE PROCEDURE cr.rep_desgloce_concepto (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual_inicial VARCHAR(10) = NULL,
	@codppl_visual_final VARCHAR(10) = NULL,
	@codtdc INT = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET DATEFORMAT DMY
SET NOCOUNT ON

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@codemp INT,
	@fecha_inicial DATETIME,
	@fecha_final DATETIME

SELECT @codpai = cia_codpai
FROM eor.cia_companias
WHERE cia_codigo = @codcia

SELECT @codtpl = tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual

SELECT @fecha_inicial = ppl_fecha_ini
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_codigo_planilla = @codppl_visual_inicial

SELECT @fecha_final = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_codigo_planilla = @codppl_visual_final

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)

SELECT cia_descripcion,
	cia_direccion,
	cia_telefonos, 
	tpl_codigo_visual,
	hpa_nombre_tipo_planilla,
	@codppl_visual_inicial codppl_visual_inicial,
	@codppl_visual_final codppl_visual_final,
	ppl_codigo_planilla,
	RIGHT(ppl_codigo_planilla, 2) ppl_num_semana,
	exp_codigo_alternativo,
	hpa_apellidos_nombres,
	tdc_abreviatura,
	tdc_descripcion,
	dss_valor
FROM sal.hpa_hist_periodos_planilla
	JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN sal.dss_descuentos ON hpa_codppl = dss_codppl AND hpa_codemp = dss_codemp
	JOIN sal.tdc_tipos_descuento ON dss_codtdc = tdc_codigo
WHERE ppl_codtpl = @codtpl
	AND ppl_fecha_ini BETWEEN ISNULL(@fecha_inicial, ppl_fecha_ini) AND ISNULL(@fecha_final, ppl_fecha_ini)
	AND dss_codtdc = ISNULL(@codtdc, dss_codtdc)
	AND hpa_codemp = ISNULL(@codemp, hpa_codemp)
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE codemp = hpa_codemp)
ORDER BY ppl_fecha_ini, exp_codigo_alternativo, tdc_orden, tdc_descripcion