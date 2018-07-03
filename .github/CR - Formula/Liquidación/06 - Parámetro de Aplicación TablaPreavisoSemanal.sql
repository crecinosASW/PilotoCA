BEGIN TRANSACTION

DECLARE @codapa INT

DELETE FROM gen.par_parametros WHERE par_codigo ='TablaPreavisoSemanal'

INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
VALUES ('TablaPreavisoSemanal', 'Tabla utilizada para el pago del preaviso para empleados semanales', 'Double', 'Dias', 'R', NULL, 'admin', GETDATE(), NULL, NULL)

INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
VALUES (NULL, NULL, 'TablaPreavisoSemanal', 'cr', NULL, NULL, NULL, NULL, 'admin', GETDATE(), NULL, NULL)

SET @codapa = @@IDENTITY

INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 0.0000, 3.0000, 0.0000, 0.0000, 0.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 3.0000, 7.0000, 0.0000, 0.0000, 7.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 7.0000, 13.0000, 0.0000, 0.0000, 14.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 13.0000, 1000000000.0000, 0.0000, 0.0000, 26.0000, 'admin', GETDATE(), NULL, NULL)

COMMIT