BEGIN TRANSACTION

DECLARE @codpai VARCHAR(2),
	@codapa INT

SET @codpai = 'cr'

DELETE gen.par_parametros WHERE par_codigo = 'TablaRentaMensual'

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'TablaRentaMensual')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('TablaRentaMensual', 'Tabla de Renta Mensual', 'Double', 'Colones', 'R', NULL, NULL, NULL, NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'TablaRentaMensual' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'TablaRentaMensual', @codpai, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)

SELECT @codapa = apa_codigo
FROM gen.apa_alcances_parametros
WHERE apa_codpar = 'TablaRentaMensual' 
	AND apa_codpai = @codpai

IF NOT EXISTS (SELECT NULL FROM gen.rap_rangos_alcance_parametros WHERE rap_codapa = @codapa)
BEGIN
	INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
	VALUES (@codapa, 0.0000, 793000.0000, 0.0000, 0.0000, 0.0000, NULL, NULL, NULL, NULL)
	INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
	VALUES (@codapa, 793000.0100, 1190000.0000, 10.0000, 0000.0000, 0.0000, NULL, NULL, NULL, NULL)
	INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
	VALUES (@codapa, 1190000.0100, 1000000000.0000, 15.0000, 39700.0000, 0.0000, NULL, NULL, NULL, NULL)
END


COMMIT