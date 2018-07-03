IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_recibo_detalle'))
BEGIN
	DROP VIEW cr.rep_recibo_detalle
END

GO

--------------------------------------------------------------------------------------
-- EvolutiON - Recibo de Pago                                                       --
-- Arma cada uno de los registros, como lucen en un recibo de pago,                 --
-- es decir ingresos de lado izquierdo y descuentos del lado derecho                --
--------------------------------------------------------------------------------------
--SELECT * FROM cr.rep_recibo_detalle
CREATE VIEW cr.rep_recibo_detalle

AS

SELECT dpr_rn, 
	dpr_codppl, 
	dpr_codemp, 
	dpr_codtig, 
	tig_descripcion, 
	tig_abreviatura,
	dpr_dias_ing,
	dpr_valor_ing, 
	dpr_codtdc, 
	tdc_descripcion, 
	tdc_abreviatura, 
	dpr_dias_desc,
	dpr_valor_desc, 
	dpr_valor_patronal
FROM (
	SELECT g.rn dpr_rn, 
		g.dpn_codppl dpr_codppl, 
		g.dpn_codemp dpr_codemp, 
		i.dpn_cod_tig_tdc dpr_codtig, 
		i.dpn_tiempo dpr_dias_ing,
		i.dpn_valor dpr_valor_ing,
		d.dpn_cod_tig_tdc dpr_codtdc, 
		d.dpn_tiempo dpr_dias_desc,
		d.dpn_valor dpr_valor_desc, 
		d.dpn_valor_patrONal dpr_valor_patrONal
	FROM (
		SELECT DISTINCT rn, 
			dpn_codppl, 
			dpn_codemp
		FROM cr.rep_recibo_numerada) g
		LEFT JOIN cr.rep_recibo_numerada i ON i.dpn_codppl = g.dpn_codppl AND i.dpn_codemp = g.dpn_codemp AND i.rn = g.rn AND i.dpn_tipo = 'Ingreso'
		LEFT JOIN cr.rep_recibo_numerada d ON d.dpn_codppl = g.dpn_codppl AND d.dpn_codemp = g.dpn_codemp AND d.rn = g.rn AND d.dpn_tipo = 'Descuento') v1
	LEFT JOIN sal.tig_tipos_ingreso ON tig_codigo = dpr_codtig
	LEFT JOIN sal.tdc_tipos_descuento ON tdc_codigo = dpr_codtdc


