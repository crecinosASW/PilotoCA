-- Agrupadores

BEGIN TRANSACTION

UPDATE sal.agr_agrupadores
SET agr_para_calculo = 0
WHERE agr_codpai = 'cr'
	AND agr_abreviatura NOT IN ('CRBaseCalculoCCSS', 
		'CRBaseCalculoBP',
		'CRBaseCalculoRenta',
		'CRBaseCalculoAguinaldo',
		'CRBaseCalculoVacaciones',
		'CRBaseCalculoIncapacidades',
		'CRBaseCalculoAsociaciones',
		'CRBaseCalculoEmbargo',
		'CRBaseCalculoCesantia',
		'CRBaseCalculoPreaviso')

COMMIT