IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gen.fec_fechas_v'))
BEGIN
	DROP VIEW gen.fec_fechas_v
END

GO

-----------------------------------------------------------------------
-- EVOLUTION                                                         --
-- Esta vista retorna el detalle de todos los meses de X años atras  --
-- Se utiliza para obtener el detalle de salarios de un empleado     --
-----------------------------------------------------------------------
CREATE VIEW gen.fec_fechas_v as
select * from gen.FN_MESES_ATRAS(5) -- años atras

GO

