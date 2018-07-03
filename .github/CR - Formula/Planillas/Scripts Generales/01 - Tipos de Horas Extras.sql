BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codcia INT

SET @codpai = 'cr'

DECLARE companias CURSOR FOR
SELECT cia_codigo
FROM eor.cia_companias
WHERE cia_codpai = @codpai

OPEN companias

FETCH NEXT FROM companias INTO @codcia

WHILE @@FETCH_STATUS = 0
BEGIN

	IF NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codcia = @codcia AND the_abreviatura = 'HN')	
		INSERT sal.the_tipos_hora_extra (the_codcia, the_nombre, the_abreviatura, the_tipo_dia, the_hora_inicial, the_hora_final, the_factor, the_factor_nocturnidad, the_codtig, the_activo, the_property_bag_data, the_usuario_grabacion, the_fecha_grabacion, the_usuario_modificacion, the_fecha_modificacion) 
		VALUES (@codcia, 'Hora Normal', 'HN', 'Habil', NULL, NULL, 1.0000, 0.0000, (SELECT tig_codigo FROM sal.tig_tipos_ingreso WHERE  tig_codcia = @codcia AND tig_abreviatura = 2), 1, '', 'admin', '2015-02-15 19:42:13', NULL, NULL)
	
	IF NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codcia = @codcia AND the_abreviatura = 'HE')	
		INSERT sal.the_tipos_hora_extra (the_codcia, the_nombre, the_abreviatura, the_tipo_dia, the_hora_inicial, the_hora_final, the_factor, the_factor_nocturnidad, the_codtig, the_activo, the_property_bag_data, the_usuario_grabacion, the_fecha_grabacion, the_usuario_modificacion, the_fecha_modificacion) 
		VALUES (@codcia, 'Hora Extra', 'HE', 'Habil', NULL, NULL, 1.5000, 0.0000, (SELECT tig_codigo FROM sal.tig_tipos_ingreso WHERE  tig_codcia = @codcia AND tig_abreviatura = 3), 1, '', 'admin', '2015-02-15 19:42:38', 'admin', '2015-02-15 19:45:03')
	
	IF NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codcia = @codcia AND the_abreviatura = 'HX')	
		INSERT sal.the_tipos_hora_extra (the_codcia, the_nombre, the_abreviatura, the_tipo_dia, the_hora_inicial, the_hora_final, the_factor, the_factor_nocturnidad, the_codtig, the_activo, the_property_bag_data, the_usuario_grabacion, the_fecha_grabacion, the_usuario_modificacion, the_fecha_modificacion) 
		VALUES (@codcia, 'Hora Mixta Normal', 'HX', 'Habil', NULL, NULL, 1.1400, 0.0000, (SELECT tig_codigo FROM sal.tig_tipos_ingreso WHERE  tig_codcia = @codcia AND tig_abreviatura = 5), 1, '', 'admin', '2015-02-15 19:43:31', 'admin', '2015-02-15 19:45:14')
		
	IF NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codcia = @codcia AND the_abreviatura = 'HM')			
		INSERT sal.the_tipos_hora_extra (the_codcia, the_nombre, the_abreviatura, the_tipo_dia, the_hora_inicial, the_hora_final, the_factor, the_factor_nocturnidad, the_codtig, the_activo, the_property_bag_data, the_usuario_grabacion, the_fecha_grabacion, the_usuario_modificacion, the_fecha_modificacion) 
		VALUES (@codcia, 'Hora Mixta', 'HM', 'Habil', NULL, NULL, 1.7200, 0.0000, (SELECT tig_codigo FROM sal.tig_tipos_ingreso WHERE  tig_codcia = @codcia AND tig_abreviatura = 6), 1, '', 'admin', '2015-02-15 19:44:04', NULL, NULL)
		
	IF NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codcia = @codcia AND the_abreviatura = 'HO')	
		INSERT sal.the_tipos_hora_extra (the_codcia, the_nombre, the_abreviatura, the_tipo_dia, the_hora_inicial, the_hora_final, the_factor, the_factor_nocturnidad, the_codtig, the_activo, the_property_bag_data, the_usuario_grabacion, the_fecha_grabacion, the_usuario_modificacion, the_fecha_modificacion) 
		VALUES (@codcia, 'Hora Nocturna', 'HO', 'Habil', NULL, NULL, 1.3300, 0.0000, (SELECT tig_codigo FROM sal.tig_tipos_ingreso WHERE  tig_codcia = @codcia AND tig_abreviatura = 7), 1, '', 'admin', '2015-02-15 19:44:48', 'admin', '2015-02-15 19:45:48')
		
	IF NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codcia = @codcia AND the_abreviatura = 'HD')			
		INSERT sal.the_tipos_hora_extra (the_codcia, the_nombre, the_abreviatura, the_tipo_dia, the_hora_inicial, the_hora_final, the_factor, the_factor_nocturnidad, the_codtig, the_activo, the_property_bag_data, the_usuario_grabacion, the_fecha_grabacion, the_usuario_modificacion, the_fecha_modificacion) 
		VALUES (@codcia, 'Hora Doble', 'HD', 'Habil', NULL, NULL, 2.0000, 0.0000, (SELECT tig_codigo FROM sal.tig_tipos_ingreso WHERE  tig_codcia = @codcia AND tig_abreviatura = 4), 1, '', 'admin', '2015-02-15 19:46:03', NULL, NULL)

	FETCH NEXT FROM companias INTO @codcia
END

CLOSE companias
DEALLOCATE companias

COMMIT

--SELECT *
--FROM sal.the_tipos_hora_extra


