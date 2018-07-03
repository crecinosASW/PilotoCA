IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gt.SAP_Contabilizacion_Consulta'))
BEGIN
	DROP PROCEDURE gt.SAP_Contabilizacion_Consulta
END

GO

--EXEC gt.SAP_Contabilizacion_Consulta 81
CREATE procedure gt.SAP_Contabilizacion_Consulta (	
	@codpla int
)

as

Select ppl_codigo_planilla Planilla,
	dco_linea Linea, 
	dco_cta_contable "Cuenta Contable", 
	dco_centro_costo "Centro de Costo", 
	dco_descripcion Descripcion, 
	dco_debitos Debito, 
	dco_creditos Credito, 
	dco_tasa_cambio "Tasa de Cambio",	
	ROUND(dco_debitos_usd, 2) "Debito (USD)",
	ROUND(dco_creditos_usd, 2) "Credito (USD)",
	dco_tipo_partida Tipo
from cr.dco_datos_contables
	JOIN sal.ppl_periodos_planilla ON dco_codppl = ppl_codigo
where dco_codppl = @codpla