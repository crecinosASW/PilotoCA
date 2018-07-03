IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gt.SAP_Contabilizacion_Consulta'))
BEGIN
	DROP PROCEDURE gt.SAP_Contabilizacion_Consulta
END

GO

--EXEC gt.SAP_Contabilizacion_Consulta 81
create procedure gt.SAP_Contabilizacion_Consulta (	
	@codpla int
)

as

Select dco_codppl Planilla, 
	dco_linea Correlativo, 
	dco_tipo_partida Tipo_Partida, 
	NULL Pais, 
	NULL Empresa, 
	dco_centro_costo Centro_Costo, 
	dco_cta_contable Cuenta, 
	dco_descripcion Descripcion, 
	dco_debitos Debito, 
	dco_creditos Credito, 
	'' Ubicacion 
from cr.dco_datos_contables
where dco_codppl = @codpla