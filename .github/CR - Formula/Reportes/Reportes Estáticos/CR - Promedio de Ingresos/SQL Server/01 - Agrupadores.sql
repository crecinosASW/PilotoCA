DECLARE @codpai VARCHAR(2),
	@codagr_ordinario INT,
	@codagr_extraordinario INT,
	@codagr_comisiones INT,
	@codagr_otros_ingresos INT

SELECT @codpai = 'cr'

SELECT @codagr_ordinario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPromedioOrdinario'
	AND agr_codpai = @codpai

SELECT @codagr_extraordinario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPromedioExtraordinario'
	AND agr_codpai = @codpai

SELECT @codagr_comisiones = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPromedioComisiones'
	AND agr_codpai = @codpai

SELECT @codagr_otros_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPromedioOtrosIngresos'
	AND agr_codpai = @codpai
	
IF @codagr_ordinario IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Promedio de Ingresos - Ordinario', 'CRPromedioOrdinario', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_extraordinario IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Promedio de Ingresos - Extraordinario', 'CRPromedioExtraordinario', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_comisiones IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Promedio de Ingresos - Comisiones', 'CRPromedioComisiones', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_otros_ingresos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Promedio de Ingresos - Otros Ingresos', 'CRPromedioOtrosIngresos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END