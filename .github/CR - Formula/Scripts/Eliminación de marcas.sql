BEGIN TRANSACTION

DELETE rel.mar_marcas
DELETE rel.asi_asistencias
DELETE sal.ext_horas_extras WHERE ext_generado_reloj = 1

COMMIT
--ROLLBACK