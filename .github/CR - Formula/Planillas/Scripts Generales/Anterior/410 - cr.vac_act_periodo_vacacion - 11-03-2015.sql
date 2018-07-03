IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.vac_act_periodo_vacacion'))
BEGIN
	DROP PROCEDURE cr.vac_act_periodo_vacacion
END

GO

/*
Nombre: cr.vac_act_periodo_vacacion
Descripción: Actualiza los días de vacaciones de los empleados en base a los meses que ya han pasado y por lo tanto han gandado vacaciones
			 en cada uno de los meses. 

			 Ejemplo: Si un empleado entro el 15/01/2014 y anualmente recibe 12 días de vacaciones y se genera esté proceso el 
					  20/03/2014, entonces ya ha cumplido al 15/03/2014, 3 meses, por cada mes el empleado gana 12 días / 12 meses = 1 día de vacación
					  por lo que las vacaciones del período 15/01/2014 al 14/01/2015, van a ser igual a 3 días.
*/
--EXECUTE cr.vac_act_periodo_vacacion 1, NULL, '20140215'
CREATE PROCEDURE cr.vac_act_periodo_vacacion (@codcia INT,
	@codemp INT,
	@fecha DATETIME
)

AS

SET DATEFORMAT DMY

DECLARE @codpai VARCHAR(2)

SELECT @codpai = cia_codpai
FROM eor.cia_companias
WHERE cia_codigo = @codcia

UPDATE v
SET v.vac_dias = ROUND(
		ISNULL(gen.get_pb_field_data_float(emp_property_bag_data, 'RegimenVacacion'), 0) / 
		12.00, 2) * 
		DATEDIFF(MM, vac_desde, 
			CONVERT(DATETIME, 
				CASE 
					WHEN MONTH(@fecha) = 2 AND DAY(vac_desde) > 28 THEN '28' 
					WHEN DAY(vac_desde) > 30 THEN '30'
					ELSE CONVERT(VARCHAR, DAY(vac_desde)) 
				END + '/' + 
				CONVERT(VARCHAR, MONTH(@fecha)) + '/' + CONVERT(VARCHAR, YEAR(@fecha)))),
	v.vac_saldo = ROUND(
		ISNULL(gen.get_pb_field_data_float(emp_property_bag_data, 'RegimenVacacion'), 0) / 
		12.00, 2) * 
		DATEDIFF(MM, vac_desde, 
			CONVERT(DATETIME, 
				CASE 
					WHEN MONTH(@fecha) = 2 AND DAY(vac_desde) > 28 THEN '28' 
					WHEN DAY(vac_desde) > 30 THEN '30'
					ELSE CONVERT(VARCHAR, DAY(vac_desde)) END + '/' + 
				CONVERT(VARCHAR, MONTH(@fecha)) + '/' + CONVERT(VARCHAR, YEAR(@fecha)))) -
		vac_gozados
FROM acc.vac_vacaciones v
	JOIN exp.emp_empleos ON vac_codemp = emp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
WHERE plz_codcia = @codcia
	AND (emp_estado = 'A'
		OR (emp_estado = 'R' AND emp_fecha_retiro 
			BETWEEN CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, MONTH(@fecha)) + '/' + CONVERT(VARCHAR, YEAR(@fecha))) 
				AND gen.fn_last_day(CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, MONTH(@fecha)) + '/' + CONVERT(VARCHAR, YEAR(@fecha))))))
	AND emp_codigo = ISNULL(@codemp, emp_codigo)
	AND vac_desde <= @fecha
	AND vac_hasta >= @fecha