BEGIN TRANSACTION

DECLARE @codpai VARCHAR(2),
	@codagr_ingresos INT,
	@codagr_seguro_social INT,
	@codagr_isr INT,
	@codagr_pension INT
	
SELECT @codpai = 'cr'
		
SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRCalculoEmbargoIngresos'
	AND agr_codpai = @codpai

SELECT @codagr_seguro_social = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRCalculoEmbargoSeguroSocial'
	AND agr_codpai = @codpai	

SELECT @codagr_isr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRCalculoEmbargoISR'
	AND agr_codpai = @codpai	

SELECT @codagr_pension = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRCalculoEmbargoPension'
	AND agr_codpai = @codpai	

IF @codagr_ingresos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion)
	VALUES('cr', 'CR - Cálculo de Embargo - Ingresos', 'CRCalculoEmbargoIngresos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_seguro_social IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion)
	VALUES('cr', 'CR - Cálculo de Embargo - Seguro Social', 'CRCalculoEmbargoSeguroSocial', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_isr IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion)
	VALUES('cr', 'CR - Cálculo de Embargo - ISR', 'CRCalculoEmbargoISR', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_pension IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion)
	VALUES('cr', 'CR - Cálculo de Embargo - Pensión Alimenticia', 'CRCalculoEmbargoPension', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

COMMIT