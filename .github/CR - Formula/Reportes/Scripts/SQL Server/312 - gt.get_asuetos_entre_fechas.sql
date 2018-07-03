IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gt.get_asuetos_entre_fechas'))
BEGIN
	DROP FUNCTION gt.get_asuetos_entre_fechas
END

GO	

--SELECT gt.get_asuetos_entre_fechas('gt', '20130101', '20131231')
CREATE FUNCTION gt.get_asuetos_entre_fechas (
	@codpai VARCHAR(2),	
	@fecha_inicial DATETIME,
	@fecha_final DATETIME
) RETURNS INT

AS

BEGIN

--DECLARE @fecha_inicial DATETIME,
--	@fecha_final DATETIME
	
--SET @fecha_inicial = CONVERT(DATETIME, '01/01/2010', 103)
--SET	@fecha_final = CONVERT(DATETIME, '31/12/2010', 103)

DECLARE @dias INT

SELECT @dias = ISNULL(SUM(CASE WHEN cal_medio_dia = 0 THEN 1 ELSE 0.5 END), 0.00)
FROM gen.cal_calendario
WHERE cal_fecha >= @fecha_inicial
	and cal_fecha <= @fecha_final 
	and DATEPART(DW, cal_fecha) <> 6
	and DATEPART(DW, cal_fecha) <> 7
	and cal_codpai = @codpai
	
RETURN ISNULL(@dias, 0.00)

END