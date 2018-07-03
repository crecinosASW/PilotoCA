BEGIN TRANSACTION

DELETE sal.agr_agrupadores
WHERE agr_abreviatura IN ('CRBaseCalculoExtraordinario')

--ROLLBACK
COMMIT