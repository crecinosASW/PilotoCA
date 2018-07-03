-- Parámetros de Aplicación

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codgrc INT,
	@codcia INT

SET @codpai = 'cr'

DECLARE @codrsa_salario INT,
	@codtig_aguinaldo INT,
	@codtig_vacaciones INT,
	@codtig_cesantia INT,
	@codtig_preaviso INT,
	@codtig_ahorro_escolar INT,
	@codtig_ahorro_patronal INT,
	@codtdc_seguro INT,
	@codtdc_asociacion INT,
	@codtrs_ahorro_patronal INT,
	@codtrs_asociacion INT

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoRSA_Salario')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoRSA_Salario', 'Código Rubro asignado al salario', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTIG_Aguinaldo')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTIG_Aguinaldo', 'Código de tipo de Ingreso de Aguinaldo', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTIG_VacacionesNoAfectas')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTIG_VacacionesNoAfectas', 'Codigo de ingreso para vacaciones no afectas', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTIG_Cesantia')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTIG_Cesantia', 'Código de tipo de Ingreso para cesantía', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTIG_Preaviso')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTIG_Preaviso', 'Código de tipo de Ingreso para preaviso', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTIG_AhorroEscolar')	
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTIG_AhorroEscolar', 'Código de tipo de Ingreso de Ahorro Escolar', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTIG_AhorroPatronal')	
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTIG_AhorroPatronal', 'Código de tipo de Ingreso de Ahorro Patronal', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTDC_SeguroSocial')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTDC_SeguroSocial', 'Código de tipo de descuento del seguro social', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTDC_Asociacion')	
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTDC_Asociacion', 'Código de tipo de descuentos de Asociacion', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTRS_AhorroPatronal')	
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTRS_AhorroPatronal', 'Código de tipo de reserva de Ahorro Patronal', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CodigoTRS_Asociacion')	
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CodigoTRS_Asociacion', 'Código de tipo de reserva de Asociacion', 'Integer', 'Codigo', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'CesantiaMesesPromedio')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('CesantiaMesesPromedio', 'Número de meses para el cálculo del promedio de la cesantía', 'Integer', 'Meses', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'VacacionesMesesPromedio')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('VacacionesMesesPromedio', 'Número de meses para el cálculo del promedio de las vacaciones', 'Integer', 'Meses', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'VacacionesDiasMinimosLey')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('VacacionesDiasMinimosLey', 'Número de días trabajados mínimos para que se le pague al empleado vacaciones', 'Integer', 'Meses', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'PreavisoMesesPromedio')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('PreavisoMesesPromedio', 'Número de meses para el cálculo del promedio del preaviso', 'Integer', 'Meses', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CesantiaMesesPromedio' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'CesantiaMesesPromedio', @codpai, NULL, NULL, NULL, '6', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'VacacionesMesesPromedio' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'VacacionesMesesPromedio', @codpai, NULL, NULL, NULL, '12', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'VacacionesDiasMinimosLey' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'VacacionesDiasMinimosLey', @codpai, NULL, NULL, NULL, '0.00', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'PreavisoMesesPromedio' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'PreavisoMesesPromedio', @codpai, NULL, NULL, NULL, '6', 'admin', GETDATE(), NULL, NULL)

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
	SET @codtig_aguinaldo = NULL
	SET @codtig_vacaciones = NULL
	SET @codtig_cesantia = NULL
	SET @codtig_ahorro_escolar = NULL
	SET @codtig_ahorro_patronal = NULL
	SET @codtdc_seguro = NULL
	SET @codtdc_asociacion = NULL
	SET @codtrs_ahorro_patronal = NULL
	SET @codtrs_asociacion = NULL

	SELECT @codrsa_salario = rsa_codigo
	FROM exp.rsa_rubros_salariales
	WHERE rsa_codcia = @codcia
		AND rsa_descripcion = 'Salario'

	SELECT @codtig_aguinaldo = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '14'

	SELECT @codtig_vacaciones = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '10'

	SELECT @codtig_cesantia = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '16'

	SELECT @codtig_preaviso = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '17'

	SELECT @codtig_ahorro_escolar = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '18'

	SELECT @codtig_ahorro_patronal = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '19'

	SELECT @codtdc_seguro = tdc_codigo
	FROM sal.tdc_tipos_descuento
	WHERE tdc_codcia = @codcia
		AND tdc_abreviatura = '1'

	SELECT @codtdc_asociacion = tdc_codigo
	FROM sal.tdc_tipos_descuento
	WHERE tdc_codcia = @codcia
		AND tdc_abreviatura = '26'

	SELECT @codtrs_ahorro_patronal = trs_codigo
	FROM sal.trs_tipos_reserva
	WHERE trs_codcia = @codcia
		AND trs_abreviatura = '5'

	SELECT @codtrs_asociacion = trs_codigo
	FROM sal.trs_tipos_reserva
	WHERE trs_codcia = @codcia
		AND trs_abreviatura = '13'

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoRSA_Salario' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoRSA_Salario', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codrsa_salario), 'admin', GETDATE(), NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTIG_Aguinaldo' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTIG_Aguinaldo', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtig_aguinaldo), 'admin', GETDATE(), NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTIG_VacacionesNoAfectas' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTIG_VacacionesNoAfectas', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtig_vacaciones), 'admin', GETDATE(), NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTIG_Cesantia' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTIG_Cesantia', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtig_cesantia), 'admin', GETDATE(), NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTIG_Preaviso' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTIG_Preaviso', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtig_preaviso), 'admin', GETDATE(), NULL, NULL)	

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTIG_AhorroEscolar' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTIG_AhorroEscolar', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtig_ahorro_escolar), 'admin', GETDATE(), NULL, NULL)	

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTIG_AhorroPatronal' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTIG_AhorroPatronal', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtig_ahorro_patronal), 'admin', GETDATE(), NULL, NULL)	

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTDC_SeguroSocial' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTDC_SeguroSocial', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtdc_seguro), 'admin', GETDATE(), NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTDC_Asociacion' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTDC_Asociacion', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtdc_asociacion), 'admin', GETDATE(), NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTRS_AhorroPatronal' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTRS_AhorroPatronal', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtrs_ahorro_patronal), 'admin', GETDATE(), NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'CodigoTRS_Asociacion' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'CodigoTRS_Asociacion', NULL, @codgrc, @codcia, NULL, CONVERT(VARCHAR, @codtrs_asociacion), 'admin', GETDATE(), NULL, NULL)

	FETCH NEXT FROM companias INTO @codgrc, @codcia
END

CLOSE companias
DEALLOCATE companias

COMMIT