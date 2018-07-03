DECLARE @codpai VARCHAR(2),
	@codagr_ordinario INT,
	@codagr_comp_ordinario INT,
	@codagr_extras INT,
	@codagr_bonificaciones INT,
	@codagr_otros_ingresos INT,
	@codagr_ccss INT,
	@codagr_prestamos INT,
	@codagr_seguros INT,
	@codagr_isr INT,
	@codagr_otros_descuentos INT

SELECT @codpai = 'cr'

SELECT @codagr_ordinario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalOrdinario'
	AND agr_codpai = @codpai

SELECT @codagr_comp_ordinario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalCompOrdinario'
	AND agr_codpai = @codpai

SELECT @codagr_extras = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalExtraordinario'
	AND agr_codpai = @codpai

SELECT @codagr_bonificaciones = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalBonificaciones'
	AND agr_codpai = @codpai

SELECT @codagr_otros_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalOtrosIngresos'
	AND agr_codpai = @codpai

SELECT @codagr_ccss = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalCCSS'
	AND agr_codpai = @codpai

SELECT @codagr_prestamos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalPrestamos'
	AND agr_codpai = @codpai

SELECT @codagr_seguros = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalSeguros'
	AND agr_codpai = @codpai

SELECT @codagr_isr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalISR'
	AND agr_codpai = @codpai

SELECT @codagr_otros_descuentos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaQuincenalOtrosDescuentos'
	AND agr_codpai = @codpai
	
IF @codagr_ordinario IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Quincenal - Ordinario', 'CRPlanillaQuincenalOrdinario', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_comp_ordinario IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Quincenal - Complemento Ordinario', 'CRPlanillaQuincenalCompOrdinario', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_extras IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Quincenal - Extraordinario', 'CRPlanillaQuincenalExtraordinario', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_bonificaciones IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Quincenal - Otras Bonificaciones', 'CRPlanillaQuincenalBonificaciones', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_otros_ingresos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Quincenal - Otros Ingresos', 'CRPlanillaQuincenalOtrosIngresos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_ccss IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Quincenal - CCSS', 'CRPlanillaQuincenalCCSS', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_prestamos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Quincenal - Préstamos', 'CRPlanillaQuincenalPrestamos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_seguros IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Quincenal - Seguros', 'CRPlanillaQuincenalSeguros', 0, 'TodosExcluyendo', 'admin', GETDATE())
END
 
IF @codagr_isr IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Quincenal - ISR', 'CRPlanillaQuincenalISR', 0, 'TodosExcluyendo', 'admin', GETDATE())
END
 
IF @codagr_otros_descuentos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Quincenal - Otros Descuentos', 'CRPlanillaQuincenalOtrosDescuentos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END