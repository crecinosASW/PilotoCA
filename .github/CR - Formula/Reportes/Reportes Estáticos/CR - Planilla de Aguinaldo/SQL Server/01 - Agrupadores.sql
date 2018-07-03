BEGIN TRANSACTION

DECLARE @codagr_aguinaldo INT,
	@codagr_descuentos INT

SELECT @codagr_aguinaldo = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaAguinaldo'
	AND agr_codpai = 'cr'

SELECT @codagr_descuentos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaAguinaldoDescuentos'
	AND agr_codpai = 'cr'
	
IF @codagr_aguinaldo IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES('cr', 'CR - Planilla de Aguinaldo - Aguinaldo', 'CRPlanillaAguinaldo', 0, 'TodosExcluyendo', 'admin', getdate())
END

IF @codagr_descuentos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES('cr', 'CR - Planilla de Aguinaldo - Descuentos', 'CRPlanillaAguinaldoDescuentos', 0, 'TodosExcluyendo', 'admin', getdate())
END

COMMIT