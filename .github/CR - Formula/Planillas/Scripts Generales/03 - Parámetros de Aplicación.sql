-- Parámetros de Aplicación

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codgrc INT,
	@codcia INT

SET @codpai = 'cr'

DECLARE @codrsa_salario INT,
	@codtdc_ccss INT,
	@codtdc_ccss_jubilado INT,
	@codrin_maternidad INT,
	@codrin_ccss INT,
	@codaso_asociacion INT,
	@codtrs_aguinaldo INT

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoRSA_Salario')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoRSA_Salario', 'Código Rubro asignado al salario', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'AguinaldoAplicaPension')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('AguinaldoAplicaPension', 'Indica si aplica los descuentos de pensión alimenticia al cálculo del aguinaldo', 'Boolean', 'si / no', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'IncapacidadUtilizaMesComercial')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('IncapacidadUtilizaMesComercial', 'Indica si el cálculo de la incapacidad utiliza el mes comercial', 'Boolean', 'si / no', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'IncapacidadMesesPromedio')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('IncapacidadMesesPromedio', 'Número de meses para el cálculo del promedio de la incapacidad', 'Integer', 'Meses', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'VacacionHorasMedioDia')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('VacacionHorasMedioDia', 'Número de horas que representa medió día de vacación', 'Double', 'Horas', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'VacacionDiasSemana')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('VacacionDiasSemana', 'Número de días de una semana para el cálculo de vacaciones', 'Double', 'Dias', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'VacacionMesesPromedio')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('VacacionMesesPromedio', 'Número de meses que es usan para sacar promedios relacionados con las vacaciones', 'Double', 'meses', 'E', NULL, NULL, NULL, NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CuotaJubiladoSeguroSocial')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CuotaJubiladoSeguroSocial', 'Cutota del seguro social para empleado jubilado', 'Double', 'Porcentaje', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'HorasLaboradasPorMes')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('HorasLaboradasPorMes', 'Parametro default para las horas laboradas por mes', 'Integer', 'Horas por mes', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'HorasLaboralesPorDia')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('HorasLaboralesPorDia', 'Número de horas laborales por dia', 'Integer', 'Horas', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CuotaEmpleadoSeguroSocial')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CuotaEmpleadoSeguroSocial', 'Cuota a descontar al empleado por seguro social', 'Double', 'Porcentaje', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CuotaPatronoSeguroSocial')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CuotaPatronoSeguroSocial', 'Cuota a pagar por el patrono por seguro social', 'Double', 'Porcentaje', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'BancoPopularPorcentaje')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('BancoPopularPorcentaje', 'Porcentaje de descuento por el banco popular', 'Double', 'Porcentaje', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'ISRValorConyugue')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('ISRValorConyugue', 'Valor deducible por conyugue en el cálculo del ISR', 'Double', 'Colones', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'ISRValorHijos')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('ISRValorHijos', 'Valor por hijo deducible al impuesto sobre la renta', 'Double', 'Colones', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'EmbargosSalarioInembargable')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('EmbargosSalarioInembargable', 'Salario inembargable en los embargos', 'Double', 'Colones', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'EmbargosPorcentajeMenores')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('EmbargosPorcentajeMenores', 'Porcentaje para los embargos menores', 'Double', 'Porcentaje', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'EmbargosPorcentajeMayores')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('EmbargosPorcentajeMayores', 'Porcentaje para embargos mayores', 'Double', 'Porcentaje', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'EmbargosNumeroSalariosMinimos')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('EmbargosNumeroSalariosMinimos', 'Número de salario mínimos para clasificar un embargo como menor o mayor', 'Double', 'Salarios', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'PensionAlimenticiaPorcentajeMaximo')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('PensionAlimenticiaPorcentajeMaximo', 'Porcentaje máximo aplicable a la pensión alimenticia', 'Double', 'Porcentaje', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'VacacionEsAcumulativa')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('VacacionEsAcumulativa', 'Indica si los días adjudicados del período de vacación se van acumulando cada vez que se genere el período', 'Boolean', 'si / no', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTDC_CCSS')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTDC_CCSS', 'Código del tipo de descuento de CCSS', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTDC_CCSS_Jubilado')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTDC_CCSS_Jubilado', 'Código del tipo de descuento de CCSS para Jubilados', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CuentaContableSalarioPorPagar')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CuentaContableSalarioPorPagar', 'Cuenta contable para el líquido que devenga un empleado.', 'String', 'Cuenta Contable', 'E', NULL,  'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoRIN_Maternidad')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoRIN_Maternidad', 'Código del riesgo de maternidad', 'Integer', 'Codigo', 'E', NULL,  'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoRIN_CCSS')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoRIN_CCSS', 'Código del riesgo de CCSS', 'Integer', 'Codigo', 'E', NULL,  'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'SalarioMinimoDiario')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('SalarioMinimoDiario', 'Monto en moneda local del salario mínimo utilizado para los cálculos de planilla', 'Double', 'Colones', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoASO_Ahorro')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoASO_Ahorro', 'Código de la asociación a la cual le va a generar reserva', 'Integer', 'Codigo', 'E', NULL,  'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTRS_Aguinaldo')	
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTRS_Aguinaldo', 'Código de tipo de reserva de aguinaldo', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

-- Alcances

SELECT @codrin_ccss = rin_codigo
FROM acc.rin_riesgos_incapacidades
WHERE rin_codpai = @codpai
	AND rin_descripcion = 'CCSS (IVM)'

SELECT @codrin_maternidad = rin_codigo
FROM acc.rin_riesgos_incapacidades
WHERE rin_codpai = @codpai
	AND rin_descripcion = 'Maternidad'

SELECT @codaso_asociacion = aso_codigo
FROM exp.aso_asociaciones
WHERE aso_codpai = @codpai
	AND aso_abreviatura = 'AsoAho6%'

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'AguinaldoAplicaPension' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'AguinaldoAplicaPension', @codpai, NULL, NULL, NULL, '1', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'IncapacidadUtilizaMesComercial' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'IncapacidadUtilizaMesComercial', @codpai, NULL, NULL, NULL, '0', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'VacacionHorasMedioDia' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'VacacionHorasMedioDia', @codpai, NULL, NULL, NULL, '4', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CuotaJubiladoSeguroSocial' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CuotaJubiladoSeguroSocial', @codpai, NULL, NULL, NULL, '5.5', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'HorasLaboradasPorMes' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'HorasLaboradasPorMes', @codpai, NULL, NULL, NULL, '208.00', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'HorasLaboralesPorDia' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'HorasLaboralesPorDia', @codpai, NULL, NULL, NULL, '8', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CuotaEmpleadoSeguroSocial' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CuotaEmpleadoSeguroSocial', @codpai, NULL, NULL, NULL, '8.34', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CuotaPatronoSeguroSocial' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CuotaPatronoSeguroSocial', @codpai, NULL, NULL, NULL, '26.17', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'BancoPopularPorcentaje' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'BancoPopularPorcentaje', @codpai, NULL, NULL, NULL, '1.00', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'ISRValorConyugue' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'ISRValorConyugue', @codpai, NULL, NULL, NULL, '0.00', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'ISRValorHijos' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'ISRValorHijos', @codpai, NULL, NULL, NULL, '0.00', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'EmbargosSalarioInembargable' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'EmbargosSalarioInembargable', @codpai, NULL, NULL, NULL, '0.00', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'EmbargosPorcentajeMenores' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'EmbargosPorcentajeMenores', @codpai, NULL, NULL, NULL, '12.5', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'EmbargosPorcentajeMayores' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'EmbargosPorcentajeMayores', @codpai, NULL, NULL, NULL, '25', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'EmbargosNumeroSalariosMinimos' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'EmbargosNumeroSalariosMinimos', @codpai, NULL, NULL, NULL, '3', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'PensionAlimenticiaPorcentajeMaximo' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'PensionAlimenticiaPorcentajeMaximo', @codpai, NULL, NULL, NULL, '50', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'VacacionEsAcumulativa' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'VacacionEsAcumulativa', @codpai, NULL, NULL, NULL, '1', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'IncapacidadMesesPromedio' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'IncapacidadMesesPromedio', @codpai, NULL, NULL, NULL, '6', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'VacacionMesesPromedio' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'VacacionMesesPromedio', @codpai, NULL, NULL, NULL, '3', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'VacacionDiasSemana' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'VacacionDiasSemana', @codpai, NULL, NULL, NULL, '6.00', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoRIN_Maternidad' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CodigoRIN_Maternidad', @codpai, NULL, NULL, NULL, @codrin_maternidad, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoRIN_CCSS' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CodigoRIN_CCSS', @codpai, NULL, NULL, NULL, @codrin_ccss, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoASO_Ahorro' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CodigoASO_Ahorro', @codpai, NULL, NULL, NULL, CONVERT(VARCHAR, @codaso_asociacion), 'admin', GETDATE(), NULL, NULL)

DECLARE companias CURSOR FOR
SELECT cia_codgrc,
	cia_codigo
FROM eor.cia_companias
WHERE cia_codpai = @codpai

OPEN companias

FETCH NEXT FROM companias INTO @codgrc, @codcia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @codrsa_salario = NULL
	SET @codtdc_ccss = NULL
	SET @codtdc_ccss_jubilado = NULL
	SET @codtrs_aguinaldo = NULL

	SELECT @codrsa_salario = rsa_codigo
	FROM exp.rsa_rubros_salariales
	WHERE rsa_codcia = @codcia
		AND rsa_descripcion = 'Salario'

	SELECT @codtdc_ccss = tdc_codigo
	FROM sal.tdc_tipos_descuento
	WHERE tdc_codcia = @codcia
		AND tdc_abreviatura = '1'

	SELECT @codtdc_ccss_jubilado = tdc_codigo
	FROM sal.tdc_tipos_descuento
	WHERE tdc_codcia = @codcia
		AND tdc_abreviatura = '3'

	SELECT @codtrs_aguinaldo = trs_codigo
	FROM sal.trs_tipos_reserva
	WHERE trs_codcia = @codcia
		AND trs_abreviatura = '1'

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoRSA_Salario' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoRSA_Salario', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codrsa_salario), 'admin', GETDATE(), NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTDC_CCSS' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTDC_CCSS', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtdc_ccss), 'admin', GETDATE(), NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTDC_CCSS_Jubilado' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTDC_CCSS_Jubilado', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtdc_ccss_jubilado), 'admin', GETDATE(), NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTRS_Aguinaldo' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTRS_Aguinaldo', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtrs_aguinaldo), 'admin', GETDATE(), NULL, NULL)

	FETCH NEXT FROM companias INTO @codgrc, @codcia
END

CLOSE companias
DEALLOCATE companias

COMMIT