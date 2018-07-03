-- Agrupadores

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codagr_ingresos INT

SET @codpai = 'cr'

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRCalculoPrestacionesLaboralesOtrosIngresos')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Cálculo de Prestaciones Laborales - Otros Ingresos', 'CRCalculoPrestacionesLaboralesOtrosIngresos', 0, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRCalculoPrestacionesLaboralesOtrosDescuentos')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Cálculo de Prestaciones Laborales - Otros Descuentos', 'CRCalculoPrestacionesLaboralesOtrosDescuentos', 0, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

COMMIT