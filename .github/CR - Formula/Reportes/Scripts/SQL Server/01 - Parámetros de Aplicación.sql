--Par�metros de aplicaci�n

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codgrc INT,
	@codcia INT,
	@codrin_maternidad INT

SET @codpai = 'cr'

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoRSA_Salario')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoRSA_Salario', 'C�digo Rubro asignado al salario', 'Integer', 'Rubro', 'E', NULL, NULL, NULL, 'admin', '2013-05-02 21:01:02')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoDoc_Identidad')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoDoc_Identidad', 'C�digo del tipo de documento de identidad', 'Integer', 'codigo', 'E', NULL, NULL, NULL, NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoDoc_Pasaporte')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoDoc_Pasaporte', 'C�digo del tipo de documento que tiene el pasaporte', 'Integer', 'codigo', 'E', NULL, NULL, NULL, NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoDoc_SeguroSocial')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoDoc_SeguroSocial', 'C�digo de tipo de documento que contiene el c�digo de afiliaci�n al seguro social', 'Integer', 'codigo', 'E', NULL, NULL, NULL, NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoDoc_PermisoTrabajo')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoDoc_PermisoTrabajo', 'C�digo del tipo de documento de Permiso de Trabajo', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-09 12:44:39', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoFPA_Transferencia')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoFPA_Transferencia', 'C�digo de la forma de pago de transferencia', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-07 10:57:43', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoFPA_Cheque')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoFPA_Cheque', 'C�digo de la forma de pago de cheque', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoFPA_Efectivo')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoFPA_Efectivo', 'C�digo de la forma de pago de efectivo', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoBCA_BAC')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoBCA_BAC', 'C�digo del banco BAC', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoBCA_BCR')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoBCA_BCR', 'C�digo del Banco de Costa Rica', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoBCA_BN')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoBCA_BN', 'C�digo del Banco Nacional', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CuentaBancoEmpresa')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CuentaBancoEmpresa', 'Cuenta del banco de la empresa', 'String', 'Caracteres', 'E', NULL, NULL, NULL, 'admin', '2014-01-08 16:50:33')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'MonedaCuentaBancoEmpresa')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('MonedaCuentaBancoEmpresa', 'C�digo de la moneda de la cuenta del banco de la empresa', 'String', 'Codigo', 'E', NULL, 'admin', '2014-09-05 09:05:40', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'BancoNacionalCliente')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('BancoNacionalCliente', 'N�mero de cliente utilizado en la planilla del banco nacional', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-09-05 09:05:40', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'BancoNacionalTransferencia')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('BancoNacionalTransferencia', 'N�mero de transferencia utilizado en la planilla del banco nacional', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-09-05 09:05:40', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoMED_CCSS')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoMED_CCSS', 'C�digo de la cl�nica m�dica para el C.C.S.S', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoMED_INS')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoMED_INS', 'C�digo de la cl�nica m�dica para el I.N.S', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSRegistroPatronal')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSRegistroPatronal', 'C�digo del registro de informaci�n patronal para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSRegistroObrera')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSRegistroObrera', 'C�digo del registro de informaci�n obrera para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSRegistroControl')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSRegistroControl', 'C�digo del registro de control para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSSucursal')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSSucursal', 'C�digo de la sucursal para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSTipoCliente')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSTipoCliente', 'C�digo del tipo de cliente para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSTCJornada')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSTCJornada', 'C�digo del tipo de cambio para la jornada para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSTCPension')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSTCPension', 'C�digo del tipo de cambio para la pensi�n para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSTCIncapacidad')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSTCIncapacidad', 'C�digo del tipo de cambio para la incapacidad para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSTCPermiso')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSTCPermiso', 'C�digo del tipo de cambio para el permiso de trabajo para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSTCSalario')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSTCSalario', 'C�digo del tipo de cambio para el salario para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSTCOcupacion')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSTCOcupacion', 'C�digo del tipo de cambio para la ocupaci�n para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSTCInclusion')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSTCInclusion', 'C�digo del tipo de cambio para la inclusi�n para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CCSSTCExclusion')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CCSSTCExclusion', 'C�digo del tipo de cambio para la exclusi�n para el reporte planilla ccss', 'String', 'Caracteres', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoRIN_Maternidad')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoRIN_Maternidad', 'C�digo del riesgo para la maternidad', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoMRT_Invalidez')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoMRT_Invalidez', 'C�digo del motivo de retiro de pensi�n por invalidez', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoMRT_Vejez')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoMRT_Vejez', 'C�digo del motivo de retiro de pensi�n por vejez', 'Integer', 'Codigo', 'E', NULL, 'admin', '2014-01-21 09:20:46', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CuentaBancoEmpresaBCR')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CuentaBancoEmpresaBCR', 'CTA DE LA EMPRESA PARA EL BANCO BCR', 'String', 'Caracteres', 'E', NULL, NULL, NULL, 'admin', '2014-10-03 11:51:41')

-- Alcance de Par�metros

SELECT @codrin_maternidad = rin_codigo
FROM acc.rin_riesgos_incapacidades
WHERE rin_codpai = @codpai
	AND rin_descripcion = 'Maternidad'

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSRegistroPatronal' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSRegistroPatronal', @codpai, NULL, NULL, NULL, '25', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSRegistroObrera' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSRegistroObrera', @codpai, NULL, NULL, NULL, '35', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSRegistroControl' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSRegistroControl', @codpai, NULL, NULL, NULL, '15', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSTipoCliente' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSTipoCliente', @codpai, NULL, NULL, NULL, 'PAT', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSTCJornada' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSTCJornada', @codpai, NULL, NULL, NULL, 'JO', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSTCPension' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSTCPension', @codpai, NULL, NULL, NULL, 'PN', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSTCIncapacidad' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSTCIncapacidad', @codpai, NULL, NULL, NULL, 'IN', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSTCPermiso' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSTCPermiso', @codpai, NULL, NULL, NULL, 'PE', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSTCSalario' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSTCSalario', @codpai, NULL, NULL, NULL, 'SA', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSTCOcupacion' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSTCOcupacion', @codpai, NULL, NULL, NULL, 'OC', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CCSSTCInclusion' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CCSSTCInclusion', @codpai, NULL, NULL, NULL, 'IC', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoRIN_Maternidad' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CodigoRIN_Maternidad', @codpai, NULL, NULL, NULL, CONVERT(VARCHAR, @codrin_maternidad), 'admin', GETDATE(), NULL, NULL)

DECLARE companias CURSOR FOR
SELECT cia_codgrc,
	cia_codigo
FROM eor.cia_companias
WHERE cia_codpai = @codpai

OPEN companias

FETCH NEXT FROM companias INTO @codgrc, @codcia

WHILE @@FETCH_STATUS = 0
BEGIN

	FETCH NEXT FROM companias INTO @codgrc, @codcia
END

CLOSE companias
DEALLOCATE companias

COMMIT