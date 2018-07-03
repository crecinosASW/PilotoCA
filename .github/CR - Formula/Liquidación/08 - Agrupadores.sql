-- Agrupadores

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2)

SET @codpai = 'cr'

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoCesantia')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Cálculo de Cesantía', 'CRBaseCalculoCesantia', 1, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoPreaviso')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Cálculo de Preaviso', 'CRBaseCalculoPreaviso', 1, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoVacaciones')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Cálculo de Vacaciones', 'CRBaseCalculoVacaciones', 1, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoAguinaldo')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Cálculo de Aguinaldo', 'CRBaseCalculoAguinaldo', 1, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoAhorroEscolar')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Cálculo de Ahorro Escolar', 'CRBaseCalculoAhorroEscolar', 1, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

COMMIT