IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.vac_act_periodo_vacacion'))
BEGIN
	DROP PROCEDURE cr.vac_act_periodo_vacacion
END

GO

/*
Nombre: cr.vac_act_periodo_vacacion
Descripción: Actualiza el saldo de vacaciones de los empleados, agregando los días proporcionales según el mes de generación,
			 asume que solo existe un período de vacaciones, por lo que actualiza los días y la fecha de fin
*/
--EXECUTE cr.vac_act_periodo_vacacion 1, NULL, '20150630'
CREATE PROCEDURE cr.vac_act_periodo_vacacion (
	@codcia INT,
	@codemp INT,
	@fecha DATETIME
)

AS

SET DATEFORMAT DMY

DECLARE @emp_codigo INT,
	@codvac INT,
	@vac_desde DATETIME,
	@vac_hasta DATETIME,
	@fecha_ultima DATETIME,
	@dias_regimen REAL,
	@dias_vacacion REAL,
	@meses_vacacion REAL,
	@dias_proporcionales REAL,
	@vac_hasta_nueva DATETIME

SET @fecha_ultima = gen.fn_last_day(CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, MONTH(@fecha)) + '/' + CONVERT(VARCHAR, YEAR(@fecha))))

DECLARE empleados CURSOR FOR
SELECT emp_codigo, 
	vac_codigo,
	vac_desde,
	vac_hasta,
	ISNULL(gen.get_pb_field_data_float(emp_property_bag_data, 'RegimenVacacion'), 0) dias_regimen
FROM acc.vac_vacaciones v
	JOIN exp.emp_empleos ON vac_codemp = emp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
WHERE plz_codcia = @codcia
	AND emp_estado = 'A'
	AND emp_codigo = ISNULL(@codemp, emp_codigo)
	AND vac_hasta = (SELECT MAX(vac_hasta)
					 FROM acc.vac_vacaciones v2
					 WHERE v.vac_codemp = v2.vac_codemp
						AND vac_hasta < @fecha)

OPEN empleados

FETCH NEXT FROM empleados INTO @emp_codigo, @codvac, @vac_desde, @vac_hasta, @dias_regimen

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @vac_desde = DATEADD(DD, -1, @vac_desde)

	SET @vac_hasta_nueva = 
		CONVERT(DATETIME, 
			CASE 
				WHEN MONTH(@fecha) = 2 AND DAY(@vac_desde) > 28 THEN '28' 
				WHEN DAY(@vac_desde) > 30 AND DAY(@fecha_ultima) = 30 THEN '30'
				ELSE CONVERT(VARCHAR, DAY(@vac_desde)) 
			END + '/' + 
			CONVERT(VARCHAR, MONTH(@fecha)) + '/' + 
			CONVERT(VARCHAR, YEAR(@fecha)))

	IF @vac_hasta_nueva <= @fecha
	BEGIN
		SET @dias_vacacion = ROUND(@dias_regimen / 12.00, 2)
		SET @meses_vacacion = DATEDIFF(MM, @vac_hasta, @vac_hasta_nueva)
		SET @dias_proporcionales = @dias_vacacion * @meses_vacacion

		IF @dias_proporcionales > 0
		BEGIN
			UPDATE acc.vac_vacaciones
			SET vac_saldo = vac_saldo + ISNULL(@dias_proporcionales, 0.00),
				vac_hasta = @vac_hasta_nueva
			WHERE vac_codigo = @codvac
		END
	END

	FETCH NEXT FROM empleados INTO @emp_codigo, @codvac, @vac_desde, @vac_hasta, @dias_regimen
END

CLOSE empleados
DEALLOCATE empleados