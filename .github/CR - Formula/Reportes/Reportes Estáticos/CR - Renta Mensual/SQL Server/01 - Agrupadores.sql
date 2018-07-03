DECLARE @codpai VARCHAR(2),
	@codagr_ingresos INT,
	@codagr_isr INT

SELECT @codpai = 'cr'

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRRentaMensualIngresos'
	AND agr_codpai = @codpai

SELECT @codagr_isr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRRentaMensualISR'
	AND agr_codpai = @codpai

IF @codagr_ingresos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Renta Mensual - Ingresos', 'CRRentaMensualIngresos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_isr IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Renta Mensual - ISR', 'CRRentaMensualISR', 0, 'TodosExcluyendo', 'admin', GETDATE())
END