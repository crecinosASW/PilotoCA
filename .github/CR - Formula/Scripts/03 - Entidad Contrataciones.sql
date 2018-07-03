BEGIN TRANSACTION

UPDATE cfg.cen_cfg_entidades
SET cen_proc_antes_guardar = 'acc.validacion_contratacion',
	cen_procedimiento_desp_fin = 'acc.finaliza_contratacion'
WHERE cen_nombre = 'Contrataciones'

COMMIT