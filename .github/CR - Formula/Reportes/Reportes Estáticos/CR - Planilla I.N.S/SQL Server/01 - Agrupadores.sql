BEGIN TRANSACTION

DECLARE @codagr_salario INT

SELECT @codagr_salario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaINSSalario'
	AND agr_codpai = 'cr'
	
IF @codagr_salario IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES('cr', 'CR - Planilla I.N.S. - Salario', 'CRPlanillaINSSalario', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

COMMIT