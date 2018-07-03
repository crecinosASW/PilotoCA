BEGIN TRANSACTION

DECLARE @codpai VARCHAR(2),
	@codapa INT

SET @codpai = 'cr'

 IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'VacacionDiasRango')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('VacacionDiasRango', 'Dias a adjudicar en un período segun antiguedad', 'Integer', 'días', 'R', NULL, NULL, NULL, NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'VacacionDiasRango' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'VacacionDiasRango', @codpai, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)

SELECT @codapa = apa_codigo
FROM gen.apa_alcances_parametros
WHERE apa_codpar = 'VacacionDiasRango' 
	AND apa_codpai = @codpai

IF NOT EXISTS (SELECT NULL FROM gen.rap_rangos_alcance_parametros WHERE rap_codapa = @codapa)
	INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
	VALUES (@codapa, 0.0000, 99.0000, 0.0000, 0.0000, 12.0000, NULL, NULL, NULL, NULL)


COMMIT