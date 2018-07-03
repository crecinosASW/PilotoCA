BEGIN TRANSACTION

SELECT *
FROM acc.vac_vacaciones
WHERE vac_codemp = 1944

SELECT *
FROM acc.sdv_solicitud_dias_vacacion
WHERE sdv_codemp = 1944

SELECT *
FROM acc.dva_dias_vacacion
WHERE dva_codsdv = 1197

SELECT *
FROM cr.vca_vacaciones_calculadas
WHERE vca_coddva = 1197

DELETE cr.vca_vacaciones_calculadas
WHERE vca_coddva = 1197

DELETE acc.dva_dias_vacacion
WHERE dva_codsdv = 1197

DELETE acc.sdv_solicitud_dias_vacacion
WHERE sdv_codemp = 1944

UPDATE acc.vac_vacaciones
SET vac_gozados = 0,
	vac_saldo = 35.96
WHERE vac_codemp = 1944

SELECT *
FROM acc.vac_vacaciones
WHERE vac_codemp = 1944

SELECT *
FROM acc.sdv_solicitud_dias_vacacion
WHERE sdv_codemp = 1944

SELECT *
FROM acc.dva_dias_vacacion
WHERE dva_codsdv = 1197

SELECT *
FROM cr.vca_vacaciones_calculadas
WHERE vca_coddva = 1197

--ROLLBACK
COMMIT