BEGIN TRANSACTION

DELETE cfg.pro_procesos WHERE pro_entityset_name = 'SolicitudesVacaciones'
DELETE acc.dva_dias_vacacion
DELETE acc.sdv_solicitud_dias_vacacion
DELETE acc.vac_vacaciones

DBCC CHECKIDENT('acc.dva_dias_vacacion', RESEED, 0)
DBCC CHECKIDENT('acc.sdv_solicitud_dias_vacacion', RESEED, 0)
DBCC CHECKIDENT('acc.vac_vacaciones', RESEED, 0)

SELECT *
FROM acc.vac_vacaciones

--ROLLBACK
COMMIT