BEGIN TRANSACTION

SELECT emp_codigo
FROM exp.emp_empleos	
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
WHERE exp_codigo_alternativo = '2992'

SELECT *
FROM acc.vac_vacaciones
WHERE vac_codemp = 1858

SELECT *
FROM acc.dva_dias_vacacion
WHERE dva_codsdv = 25

SELECT *
FROM acc.sdv_solicitud_dias_vacacion
WHERE sdv_codemp = 2008

UPDATE acc.sdv_solicitud_dias_vacacion
SET sdv_hasta = '20150327'
WHERE sdv_codemp = 2008

UPDATE acc.dva_dias_vacacion
SET dva_hasta = '20150407'
WHERE dva_codsdv = 10

SELECT *
FROM cr.vca_vacaciones_calculadas
WHERE vca_codemp = 2221


COMMIT