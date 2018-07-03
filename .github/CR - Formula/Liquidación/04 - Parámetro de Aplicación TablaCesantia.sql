BEGIN TRANSACTION

DECLARE @codapa INT

DELETE FROM gen.par_parametros WHERE par_codigo ='TablaCesantia'

INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
VALUES ('TablaCesantia', 'Tabla utilizada para el pago de la cesantía', 'Double', 'Dias', 'R', NULL, 'admin', GETDATE(), NULL, NULL)

INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
VALUES (NULL, NULL, 'TablaCesantia', 'cr', NULL, NULL, NULL, NULL, 'admin', GETDATE(), NULL, NULL)

SET @codapa = @@IDENTITY

INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 0.0000, 3.0000, 0.0000, 0.0000, 0.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 3.0000, 7.0000, 0.0000, 0.0000, 7.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 7.0000, 13.0000, 0.0000, 0.0000, 14.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 13.0000, 24.0000, 0.0000, 0.0000, 19.5000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 24.0000, 36.0000, 0.0000, 0.0000, 20.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 36.0000, 48.0000, 0.0000, 0.0000, 20.5000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 48.0000, 60.0000, 0.0000, 0.0000, 21.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 60.0000, 72.0000, 0.0000, 0.0000, 21.5000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 72.0000, 84.0000, 0.0000, 0.0000, 21.5000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 84.0000, 96.0000, 0.0000, 0.0000, 22.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 96.0000, 108.0000, 0.0000, 0.0000, 22.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 108.0000, 120.0000, 0.0000, 0.0000, 22.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 120.0000, 132.0000, 0.0000, 0.0000, 21.5000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 132.0000, 144.0000, 0.0000, 0.0000, 21.0000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 144.0000, 156.0000, 0.0000, 0.0000, 20.5000, 'admin', GETDATE(), NULL, NULL)
INSERT gen.rap_rangos_alcance_parametros (rap_codapa, rap_inicio, rap_fin, rap_porcentaje, rap_excedente, rap_valor, rap_usuario_grabacion, rap_fecha_grabacion, rap_usuario_modificacion, rap_fecha_modificacion) 
VALUES (@codapa, 156.0000, 1000000000.0000, 0.0000, 0.0000, 20.0000, 'admin', GETDATE(), NULL, NULL)

COMMIT