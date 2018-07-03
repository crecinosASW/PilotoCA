BEGIN TRANSACTION

DECLARE @codpai VARCHAR(2),
	@codagr_ordinario INT,
	@codagr_comp_ordinario INT,
	@codagr_extras INT,
	@codagr_bono_ley INT,
	@codagr_bonificaciones INT,
	@codagr_anticipo INT,
	@codagr_otros_ingresos INT,
	@codagr_CCSS INT,
	@codagr_prestamos INT,
	@codagr_seguros INT,
	@codagr_isr INT,
	@codagr_otros_descuentos INT

SELECT @codpai = 'cr'

SELECT @codagr_ordinario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualOrdinario'
	AND agr_codpai = @codpai

SELECT @codagr_comp_ordinario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualCompOrdinario'
	AND agr_codpai = @codpai

SELECT @codagr_extras = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualExtraordinario'
	AND agr_codpai = @codpai

SELECT @codagr_bonificaciones = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualBonificaciones'
	AND agr_codpai = @codpai

SELECT @codagr_anticipo = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualAnticipo'
	AND agr_codpai = @codpai		

SELECT @codagr_otros_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualOtrosIngresos'
	AND agr_codpai = @codpai

SELECT @codagr_CCSS = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualCCSS'
	AND agr_codpai = @codpai

SELECT @codagr_prestamos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualPrestamos'
	AND agr_codpai = @codpai

SELECT @codagr_seguros = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualSeguros'
	AND agr_codpai = @codpai

SELECT @codagr_isr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualISR'
	AND agr_codpai = @codpai

SELECT @codagr_otros_descuentos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaMensualOtrosDescuentos'
	AND agr_codpai = @codpai
	
IF @codagr_ordinario IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - Ordinario', 'CRPlanillaMensualOrdinario', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_comp_ordinario IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - Complemento Ordinario', 'CRPlanillaMensualCompOrdinario', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_extras IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - Extraordinario', 'CRPlanillaMensualExtraordinario', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_bonificaciones IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - Otras Bonificaciones', 'CRPlanillaMensualBonificaciones', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_anticipo IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - Anticipo', 'CRPlanillaMensualAnticipo', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_otros_ingresos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - Otros Ingresos', 'CRPlanillaMensualOtrosIngresos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_CCSS IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - CCSS', 'CRPlanillaMensualCCSS', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_prestamos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - Préstamos', 'CRPlanillaMensualPrestamos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_seguros IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - Seguros', 'CRPlanillaMensualSeguros', 0, 'TodosExcluyendo', 'admin', GETDATE())
END
 
IF @codagr_isr IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - ISR', 'CRPlanillaMensualISR', 0, 'TodosExcluyendo', 'admin', GETDATE())
END
 
IF @codagr_otros_descuentos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Mensual - Otros Descuentos', 'CRPlanillaMensualOtrosDescuentos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

COMMIT

