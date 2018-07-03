BEGIN TRANSACTION

UPDATE sal.ppl_periodos_planilla
SET ppl_estado = 'Autorizado'
WHERE ppl_anio = 2015
	AND ppl_mes = 2

SELECT *
FROM sal.ppl_periodos_planilla
WHERE ppl_anio = 2015
	AND ppl_mes = 2

--ROLLBACK
COMMIT