IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.vac_act_per_vac_anterior'))
BEGIN
	DROP PROCEDURE cr.vac_act_per_vac_anterior
END

GO

--EXEC cr.vac_act_per_vac_anterior 1, 1853, '20151006'
CREATE PROCEDURE 
 (
	@codcia INT = NULL,
	@codemp INT = NULL,
	@fecha DATETIME = NULL
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY
SET DATEFIRST 1
 
DECLARE @codpai VARCHAR(2),
	@es_acumulativa BIT

SET @fecha = ISNULL(@fecha, GETDATE())

SELECT @codpai = cia_codpai
FROM eor.cia_companias
WHERE cia_codigo = @codcia

SET @es_acumulativa = ISNULL(gen.get_valor_parametro_bit('VacacionEsAcumulativa', @codpai, NULL, NULL, NULL), 1)

UPDATE v1
SET vac_hasta = 
	DATEADD(DD, -1, 
		CONVERT(DATETIME, 
			CASE 
				WHEN MONTH(@fecha) = 2 AND DAY(vac_desde) > 28 THEN '28' 
				WHEN DAY(vac_desde) > 30 THEN '30'
				ELSE CONVERT(VARCHAR, DAY(vac_desde)) 
			END + '/' + 
			CONVERT(VARCHAR, MONTH(@fecha)) + '/' + CONVERT(VARCHAR, YEAR(@fecha))))
FROM acc.vac_vacaciones v1
	JOIN exp.emp_empleos ON vac_codemp = emp_codigo
WHERE vac_codemp = @codemp
	AND vac_desde = (SELECT MIN(vac_desde)
				   FROM acc.vac_vacaciones v2
				   WHERE v1.vac_codemp = v2.vac_codemp)
	AND vac_dias <=  ISNULL(gen.get_pb_field_data_float(emp_property_bag_data, 'RegimenVacacion'), 0.00)
	AND vac_hasta < DATEADD(DD, -1, CONVERT(DATETIME, 
				CASE 
					WHEN MONTH(@fecha) = 2 AND DAY(vac_desde) > 28 THEN '28' 
					WHEN DAY(vac_desde) > 30 THEN '30'
					ELSE CONVERT(VARCHAR, DAY(vac_desde)) 
				END + '/' + 
				CONVERT(VARCHAR, MONTH(@fecha)) + '/' + CONVERT(VARCHAR, YEAR(@fecha))))

IF @es_acumulativa = 1
BEGIN
	EXECUTE cr.vac_act_periodo_vacacion @codcia, @codemp, @fecha
END