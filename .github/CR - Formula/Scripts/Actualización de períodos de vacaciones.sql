BEGIN TRANSACTION

SET DATEFORMAT DMY

UPDATE v1
SET v1.vac_desde = 
		DATEADD(DD, 1, 
			CONVERT(DATETIME, 
				CASE 
					WHEN MONTH(emp_fecha_ingreso) = 2 AND DAY(emp_fecha_ingreso) > 28 THEN '28' 
					ELSE CONVERT(VARCHAR, DAY(emp_fecha_ingreso)) 
				END + '/' + 
				CONVERT(VARCHAR, MONTH(emp_fecha_ingreso)) + '/' + CONVERT(VARCHAR, YEAR(vac_hasta) - 1)))
FROM acc.vac_vacaciones v1
	JOIN exp.emp_empleos ON vac_codemp = emp_codigo
WHERE vac_desde = (SELECT MIN(vac_desde)
				   FROM acc.vac_vacaciones v2
				   WHERE v1.vac_codemp = v2.vac_codemp)

UPDATE v1
SET v1.vac_hasta = 
		DATEADD(DD, -1, 
			CONVERT(DATETIME, 
				CASE 
					WHEN MONTH(vac_desde) = 2 AND DAY(vac_desde) > 28 THEN '28' 
					ELSE CONVERT(VARCHAR, DAY(vac_desde)) 
				END + '/' + 
				CONVERT(VARCHAR, MONTH(vac_desde)) + '/' + CONVERT(VARCHAR, YEAR(vac_desde) + 1)))
FROM acc.vac_vacaciones v1
	JOIN exp.emp_empleos ON vac_codemp = emp_codigo
WHERE vac_desde = (SELECT MIN(vac_desde)
				   FROM acc.vac_vacaciones v2
				   WHERE v1.vac_codemp = v2.vac_codemp)

SELECT *
FROM acc.vac_vacaciones v1
	JOIN exp.emp_empleos ON vac_codemp = emp_codigo
WHERE vac_desde = (SELECT MIN(vac_desde)
				   FROM acc.vac_vacaciones v2
				   WHERE v1.vac_codemp = v2.vac_codemp)

--COMMIT
ROLLBACK