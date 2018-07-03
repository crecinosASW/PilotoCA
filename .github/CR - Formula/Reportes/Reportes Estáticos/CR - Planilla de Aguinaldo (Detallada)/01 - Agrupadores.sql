	BEGIN TRANSACTION

DECLARE @codagr_aguinaldo INT,
	@codagr_ingresos INT,
	@codagr_descuentos INT

SELECT @codagr_aguinaldo = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaAguinaldoDetallada'
	AND agr_codpai = 'cr'

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaAguinaldoDetalladaIngresos'
	AND agr_codpai = 'cr'

SELECT @codagr_descuentos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaAguinaldoDetalladaDescuentos'
	AND agr_codpai = 'cr'

IF @codagr_aguinaldo IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES('cr', 'CR - Planilla de Aguinaldo (Detallada) - Aguinaldo', 'CRPlanillaAguinaldoDetallada', 0, 'TodosExcluyendo', 'admin', getdate())
END

IF @codagr_ingresos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES('cr', 'CR - Planilla de Aguinaldo (Detallada) - Ingresos', 'CRPlanillaAguinaldoDetalladaIngresos', 0, 'TodosExcluyendo', 'admin', getdate())
END

IF @codagr_descuentos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES('cr', 'CR - Planilla de Aguinaldo (Detallada) - Descuentos', 'CRPlanillaAguinaldoDetalladaDescuentos', 0, 'TodosExcluyendo', 'admin', getdate())
END

COMMIT