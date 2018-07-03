BEGIN TRANSACTION

UPDATE sal.tpl_tipo_planilla 
SET tpl_asi_rango_fechas_ingreso = 'PeriodoActual' 
WHERE tpl_descripcion = 'Planilla Producción'

COMMIT