IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('acc.alerta_act_vacaciones'))
BEGIN
	DROP PROCEDURE acc.alerta_act_vacaciones
END

GO

--EXEC acc.alerta_act_vacaciones
CREATE PROCEDURE acc.alerta_act_vacaciones

AS

SET DATEFORMAT DMY
SET NOCOUNT ON
SET LANGUAGE 'spanish'

DECLARE @codcia INT,
	@fecha_actual DATETIME

SET @fecha_actual = GETDATE()

DECLARE companias CURSOR FOR
SELECT cia_codigo
FROM eor.cia_companias

OPEN companias

FETCH NEXT FROM companias INTO @codcia

WHILE @@FETCH_STATUS = 0
BEGIN
	EXECUTE cr.vac_act_periodo_vacacion @codcia, NULL, @fecha_actual

	FETCH NEXT FROM companias INTO @codcia
END

CLOSE companias
DEALLOCATE companias

SELECT 'Acciones' controller_area, 
	'FondoVacacion' controller_name,
	'Details' controller_action, 
	vac_codemp codigo_entidad, 
	exp_apellidos_nombres texto_link, 
	CONVERT(VARCHAR, vac_desde, 103) Columna1,
	 CONVERT(VARCHAR, vac_hasta, 103) Columna2,
	ROUND(vac_saldo, 2) Columna3
FROM acc.vac_vacaciones
	JOIN exp.emp_empleos ON vac_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
WHERE CONVERT(DATE, vac_hasta) = CONVERT(DATE, @fecha_actual)