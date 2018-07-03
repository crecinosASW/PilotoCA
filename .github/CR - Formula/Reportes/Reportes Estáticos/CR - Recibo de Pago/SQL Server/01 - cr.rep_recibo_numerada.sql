IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_recibo_numerada'))
BEGIN
	DROP VIEW cr.rep_recibo_numerada
END

GO

--------------------------------------------------------------------------------------
-- Evolution - Recibo de Pago                                                       --
-- Enumera cada uno de los registros del desgloce de pago de Salarios, tanto        --
-- ingresos como descuentospor planilla, codigo de empleado y planilla de salarios  --                                               --
--------------------------------------------------------------------------------------
--SELECT * FROM cr.rep_recibo_numerada
CREATE VIEW cr.rep_recibo_numerada

AS

SELECT * 
FROM (
	SELECT ROW_NUMBER() OVER( PARTITION BY inn_codppl, inn_codemp ORDER BY inn_codppl, inn_codemp, inn_codtig) AS rn, 
		'Ingreso' dpn_tipo, 
		inn_codppl dpn_codppl, 
		inn_codemp dpn_codemp, 
		inn_codtig dpn_cod_tig_tdc, 
		inn_valor dpn_valor, 
		0.00 dpn_valor_patronal, 
		0.00 dpn_ingreso_afecto, 
		inn_codmon dpn_codmon, 
		inn_tiempo dpn_tiempo, 
		inn_unidad_tiempo dpn_unidad_tiempo
	FROM sal.inn_ingresos
   
	UNION ALL
	
	SELECT ROW_NUMBER() OVER( PARTITION BY dss_codppl, dss_codemp ORDER BY dss_codppl, dss_codemp, dss_codtdc) AS rn,
		'Descuento' dpn_tipo, 
		dss_codppl dpn_codppl, 
		dss_codemp dpn_codemp, 
		dss_codtdc dpn_cod_tig_tdc, 
		dss_valor dpn_valor, 
		dss_valor_patronal dpn_valor_patronal, 
		dss_ingreso_afecto dpn_ingreso_afecto, 
		dss_codmon dpn_valor, 
		dss_tiempo dpn_tiempo, 
		dss_unidad_tiempo dpn_unidad_tiempo
    FROM sal.dss_descuentos) i
    
    