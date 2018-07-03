-- Parámetros de Aplicación

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codgrc INT,
	@codcia INT

SET @codpai = 'cr'

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojDiasDesplazamientoCortePlanilla')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojDiasDesplazamientoCortePlanilla', 'Dias de desplazamiento (offset) para procesar las marcas', 'Integer', 'Dias', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:40:30')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojEstadoAsistenciaGenerada')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojEstadoAsistenciaGenerada', 'Estado de una Asistencia Generada', 'String', 'Estado', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:41:52')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojEstadoHEXGenerado')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojEstadoHEXGenerado', 'Estado para horas extras generadas', 'String', 'Estado', 'E', NULL, 'admin', '2014-07-17 15:28:53', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojEstadoTNNGenerado')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojEstadoTNNGenerado', 'Estado de un tiempo no trabajado generado', 'String', 'Estado', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 15:15:31')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojEstadoWorkflowAsistenciaGenerada')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojEstadoWorkflowAsistenciaGenerada', 'Estado del Workflow para una asistencia generada', 'String', 'Estado', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:43:05')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojEstadoWorkflowHEXGenerado')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojEstadoWorkflowHEXGenerado', 'Estado de Workflow para Horas extras generadas', 'String', 'Estado', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 15:30:04')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojEstadoWorkflowTNNGenerado')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojEstadoWorkflowTNNGenerado', 'Estado de Workflow para un tiempo no trabajado Generado', 'String', 'Estado', 'E', NULL, 'admin', '2014-07-17 15:16:22', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojGeneraExtrasAntesHoraEntrada')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojGeneraExtrasAntesHoraEntrada', 'Indica si genera horas extras antes de la hora de entrada', 'Boolean', 'SINO', 'E', NULL, 'admin', '2014-07-17 15:20:21', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojGeneraHEX')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojGeneraHEX', 'Indica si genera automaticamente el tiempo extraordinario a partir del control de asistencias', 'Boolean', 'SINO', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:31:43')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojGeneraTNT')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojGeneraTNT', 'Indica si genera automaticamente los tiempos no trabajados a partir del control de asistencias', 'Boolean', 'SINO', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:30:22')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojMinutosDescuentoUnaMarca')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojMinutosDescuentoUnaMarca', 'Minutos de descuento para una marca no encontrada', 'Integer', 'Minutos', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 15:03:57')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojMinutosEntreMarcasIguales')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojMinutosEntreMarcasIguales', 'Indica el numero de minutos que deben de haber para que una marca no se tome como duplicada', 'Integer', 'Minutos', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:34:07')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojNocturnidadHoraFin')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojNocturnidadHoraFin', 'Hora final de nocturnidad', 'String', 'Hora', 'E', NULL, 'admin', '2014-07-17 15:27:55', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojNocturnidadHoraInicio')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojNocturnidadHoraInicio', 'Hora de inicio de Nocturnidad', 'String', 'Hora', 'E', NULL, 'admin', '2014-07-17 15:27:08', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoEXTNormal')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoEXTNormal', 'Tipo de hora normal', 'Integer', 'Tipo', 'E', NULL, 'admin', '2014-07-17 15:25:45', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoEXTExtra')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoEXTExtra', 'Tipo de hora extra', 'Integer', 'Tipo', 'E', NULL, 'admin', '2014-07-17 15:25:45', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoEXTMixtaNormal')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoEXTMixtaNormal', 'Tipo de hora mixta normal', 'Integer', 'Tipo', 'E', NULL, 'admin', '2014-07-17 15:25:45', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoEXTMixta')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoEXTMixta', 'Tipo de hora mixta', 'Integer', 'Tipo', 'E', NULL, 'admin', '2014-07-17 15:25:45', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoEXTNocturna')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoEXTNocturna', 'Tipo de hora nocturna', 'Integer', 'Tipo', 'E', NULL, 'admin', '2014-07-17 15:25:45', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoEXTDoble')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoEXTDoble', 'Tipo de hora doble', 'Integer', 'Tipo', 'E', NULL, 'admin', '2014-07-17 15:25:45', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoMarcaFallida')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoMarcaFallida', 'Texto para el estado de una marca fallida', 'String', 'Tipo', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:38:01')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoMarcaNoProcesada')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoMarcaNoProcesada', 'Texto para el estado de una marca no procesada', 'String', 'Tipo', 'E', NULL, 'admin', '2014-07-17 14:38:39', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoMarcaProcesada')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoMarcaProcesada', 'Texto para el estado de una marca procesada', 'String', 'Tipo', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:36:05')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoMarcaIndefinido')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoMarcaIndefinido', 'Texto para el tipo de marca indefinido', 'String', 'Tipo', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:36:05')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoMarcaEntrada')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoMarcaEntrada', 'Texto para el tipo de marca de entrada', 'String', 'Tipo', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:36:05')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoMarcaSalida')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoMarcaSalida', 'Texto para el tipo de marca de salida', 'String', 'Tipo', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 14:36:05')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoTNNFalta')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoTNNFalta', 'Tipo de tiempo no trabajado cuando falta una marca', 'Integer', 'Tipo', 'E', NULL, 'admin', '2014-07-17 15:07:55', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoTNNLlegadaTarde')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoTNNLlegadaTarde', 'Tipo de tiempo no trabajado para llegadas tarde', 'Integer', 'Tipo', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 15:11:20')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojTipoTNNSalidaTemprana')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojTipoTNNSalidaTemprana', 'Tipo de tiempo no trabajado por Salida temprana', 'Integer', 'Tipo', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 15:14:26')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojToleranciaMinutosExtras')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojToleranciaMinutosExtras', 'Tolearancia de Minutos Extras', 'Integer', 'Minutos', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 15:19:40')

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojToleranciaMinutosSalidaTemprana')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojToleranciaMinutosSalidaTemprana', 'Tolerancia de Minutos en la salida temprana', 'Integer', 'Minutos', 'E', NULL, 'admin', '2014-07-17 15:06:21', NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'RelojToleranciaMinutosTarde')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('RelojToleranciaMinutosTarde', 'Tolerancia de minutos en llegadas tardias', 'Integer', 'Minutos', 'E', NULL, NULL, NULL, 'admin', '2014-07-17 15:05:16')

-- Alcances



DECLARE companias CURSOR FOR
SELECT cia_codgrc,
	cia_codigo
FROM eor.cia_companias
WHERE cia_codpai = @codpai

OPEN companias

FETCH NEXT FROM companias INTO @codgrc, @codcia

WHILE @@FETCH_STATUS = 0
BEGIN

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojDiasDesplazamientoCortePlanilla' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojDiasDesplazamientoCortePlanilla', NULL, @codgrc, @codcia, NULL, '0', 'admin', '2014-07-17 14:40:18', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojEstadoAsistenciaGenerada' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojEstadoAsistenciaGenerada', NULL, @codgrc, @codcia, NULL, 'Pendiente', 'admin', '2014-07-17 14:41:37', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojEstadoHEXGenerado' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojEstadoHEXGenerado', NULL, @codgrc, @codcia, NULL, 'Autorizado', 'admin', '2014-07-17 15:29:03', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojEstadoTNNGenerado' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojEstadoTNNGenerado', NULL, @codgrc, @codcia, NULL, 'Autorizado', 'admin', '2014-07-17 15:15:18', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojEstadoWorkflowAsistenciaGenerada' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojEstadoWorkflowAsistenciaGenerada', NULL, @codgrc, @codcia, NULL, 'Autorizado', 'admin', '2014-07-17 14:42:51', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojEstadoWorkflowHEXGenerado' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojEstadoWorkflowHEXGenerado', NULL, @codgrc, @codcia, NULL, 'Autorizado', 'admin', '2014-07-17 15:29:50', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojEstadoWorkflowTNNGenerado' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojEstadoWorkflowTNNGenerado', NULL, @codgrc, @codcia, NULL, 'Autorizado', 'admin', '2014-07-17 15:16:33', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojGeneraExtrasAntesHoraEntrada' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojGeneraExtrasAntesHoraEntrada', NULL, @codgrc, @codcia, NULL, '1', 'admin', '2014-07-17 15:20:32', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojGeneraHEX' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojGeneraHEX', NULL, @codgrc, @codcia, NULL, '1', 'admin', '2014-07-17 14:31:23', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojGeneraTNT' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojGeneraTNT', NULL, @codgrc, @codcia, NULL, '0', 'admin', '2014-07-17 14:30:01', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojMinutosDescuentoUnaMarca' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojMinutosDescuentoUnaMarca', NULL, @codgrc, @codcia, NULL, '60', 'admin', '2014-07-17 15:03:44', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojMinutosEntreMarcasIguales' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojMinutosEntreMarcasIguales', NULL, @codgrc, @codcia, NULL, '30', 'admin', '2014-07-17 14:33:54', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojNocturnidadHoraFin' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojNocturnidadHoraFin', NULL, @codgrc, @codcia, NULL, '10:00', 'admin', '2014-07-17 15:28:09', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojNocturnidadHoraInicio' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojNocturnidadHoraInicio', NULL, @codgrc, @codcia, NULL, '18:00', 'admin', '2014-07-17 15:27:24', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoEXTNormal' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoEXTNormal', NULL, @codgrc, @codcia, NULL, '1', 'admin', '2014-07-17 15:22:25', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoEXTExtra' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoEXTExtra', NULL, @codgrc, @codcia, NULL, '2', 'admin', '2014-07-17 15:22:25', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoEXTMixtaNormal' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoEXTMixtaNormal', NULL, @codgrc, @codcia, NULL, '3', 'admin', '2014-07-17 15:22:25', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoEXTMixta' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoEXTMixta', NULL, @codgrc, @codcia, NULL, '4', 'admin', '2014-07-17 15:22:25', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoEXTNocturna' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoEXTNocturna', NULL, @codgrc, @codcia, NULL, '5', 'admin', '2014-07-17 15:22:25', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoEXTDoble' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoEXTDoble', NULL, @codgrc, @codcia, NULL, '6', 'admin', '2014-07-17 15:22:25', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoMarcaFallida' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoMarcaFallida', NULL, @codgrc, @codcia, NULL, 'Fallida', 'admin', '2014-07-17 14:37:47', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoMarcaIndefinido' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoMarcaIndefinido', NULL, @codgrc, @codcia, NULL, 'I', 'admin', '2014-07-17 14:37:47', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoMarcaEntrada' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoMarcaEntrada', NULL, @codgrc, @codcia, NULL, 'E', 'admin', '2014-07-17 14:37:47', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoMarcaSalida' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoMarcaSalida', NULL, @codgrc, @codcia, NULL, 'S', 'admin', '2014-07-17 14:37:47', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoTNNLlegadaTarde' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoTNNLlegadaTarde', NULL, @codgrc, @codcia, NULL, '9', 'admin', '2014-07-17 15:11:08', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoMarcaNoProcesada' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoMarcaNoProcesada', NULL, @codgrc, @codcia, NULL, 'No Procesada', 'admin', '2014-07-17 14:38:58', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoMarcaProcesada' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoMarcaProcesada', NULL, @codgrc, @codcia, NULL, 'Procesada', 'admin', '2014-07-17 14:35:53', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoTNNFalta' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoTNNFalta', NULL, @codgrc, @codcia, NULL, '8', 'admin', '2014-07-17 15:10:04', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojTipoTNNSalidaTemprana' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojTipoTNNSalidaTemprana', NULL, @codgrc, @codcia, NULL, '9', 'admin', '2014-07-17 15:12:09', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojToleranciaMinutosExtras' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojToleranciaMinutosExtras', NULL, @codgrc, @codcia, NULL, '10', 'admin', '2014-07-17 15:19:28', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojToleranciaMinutosSalidaTemprana' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojToleranciaMinutosSalidaTemprana', NULL, @codgrc, @codcia, NULL, '10', 'admin', '2014-07-17 15:06:32', NULL, NULL)

	IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'RelojToleranciaMinutosTarde' AND apa_codgrc = @codgrc AND apa_codcia = @codcia)
		INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
		VALUES (NULL, NULL, 'RelojToleranciaMinutosTarde', NULL, @codgrc, @codcia, NULL, '10', 'admin', '2014-07-17 15:04:48', NULL, NULL)

	FETCH NEXT FROM companias INTO @codgrc, @codcia
END

CLOSE companias
DEALLOCATE companias

COMMIT