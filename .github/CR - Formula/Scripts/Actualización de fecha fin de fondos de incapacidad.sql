BEGIN TRANSACTION

UPDATE acc.fin_fondos_incapacidad
SET fin_hasta = DATEADD(MM, 1, fin_desde)

SELECT *
FROM acc.fin_fondos_incapacidad

--ROLLBACK
COMMIT