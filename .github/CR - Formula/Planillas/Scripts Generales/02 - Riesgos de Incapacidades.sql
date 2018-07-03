/*
IMPORTANTE: Antes de ejecutar este script, validar que riesgos de incapacidad existen para no duplicar la información

SELECT *
FROM acc.rin_riesgos_incapacidades
WHERE rin_codpai = 'cr'
ORDER BY rin_codpai, rin_descripcion

*/

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codcia INT,
	@codrin_ccss INT,
	@codrin_ins INT,
	@codrin_maternidad INT,
	@codrin_prorroga INT

SET @codpai = 'cr'

IF NOT EXISTS (SELECT NULL FROM acc.rin_riesgos_incapacidades WHERE rin_codpai = @codpai AND rin_descripcion = 'CCSS (IVM)')
	INSERT acc.rin_riesgos_incapacidades (rin_codpai, rin_descripcion, rin_utiliza_fondo, rin_anios_acumulables, rin_dias_acumulados_anio, rin_considera_septimo, rin_considera_sabado, rin_considera_asueto, rin_usa_jornada, rin_permite_incap_indefinida, rin_permite_incap_horas, rin_es_prorroga, rin_property_bag_data, rin_usuario_grabacion, rin_fecha_grabacion, rin_usuario_modificacion, rin_fecha_modificacion) 
	VALUES (@codpai, 'CCSS (IVM)', 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, NULL, 'admin', GETDATE(), NULL, NULL)
	
IF NOT EXISTS (SELECT NULL FROM acc.rin_riesgos_incapacidades WHERE rin_codpai = @codpai AND rin_descripcion = 'INS')	
	INSERT acc.rin_riesgos_incapacidades (rin_codpai, rin_descripcion, rin_utiliza_fondo, rin_anios_acumulables, rin_dias_acumulados_anio, rin_considera_septimo, rin_considera_sabado, rin_considera_asueto, rin_usa_jornada, rin_permite_incap_indefinida, rin_permite_incap_horas, rin_es_prorroga, rin_property_bag_data, rin_usuario_grabacion, rin_fecha_grabacion, rin_usuario_modificacion, rin_fecha_modificacion) 
	VALUES (@codpai, 'INS', 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM acc.rin_riesgos_incapacidades WHERE rin_codpai = @codpai AND rin_descripcion = 'Maternidad')	
	INSERT acc.rin_riesgos_incapacidades (rin_codpai, rin_descripcion, rin_utiliza_fondo, rin_anios_acumulables, rin_dias_acumulados_anio, rin_considera_septimo, rin_considera_sabado, rin_considera_asueto, rin_usa_jornada, rin_permite_incap_indefinida, rin_permite_incap_horas, rin_es_prorroga, rin_property_bag_data, rin_usuario_grabacion, rin_fecha_grabacion, rin_usuario_modificacion, rin_fecha_modificacion) 
	VALUES (@codpai, 'Maternidad', 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM acc.rin_riesgos_incapacidades WHERE rin_codpai = @codpai AND rin_descripcion = 'Prorroga')	
	INSERT acc.rin_riesgos_incapacidades (rin_codpai, rin_descripcion, rin_utiliza_fondo, rin_anios_acumulables, rin_dias_acumulados_anio, rin_considera_septimo, rin_considera_sabado, rin_considera_asueto, rin_usa_jornada, rin_permite_incap_indefinida, rin_permite_incap_horas, rin_es_prorroga, rin_property_bag_data, rin_usuario_grabacion, rin_fecha_grabacion, rin_usuario_modificacion, rin_fecha_modificacion) 
	VALUES (@codpai, 'Prorroga', 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, NULL, 'admin', GETDATE(), NULL, NULL)

SELECT @codrin_ccss = rin_codigo FROM acc.rin_riesgos_incapacidades WHERE rin_codpai = @codpai AND rin_descripcion = 'CCSS (IVM)'
SELECT @codrin_ins = rin_codigo FROM acc.rin_riesgos_incapacidades WHERE rin_codpai = @codpai AND rin_descripcion = 'INS'
SELECT @codrin_maternidad = rin_codigo FROM acc.rin_riesgos_incapacidades WHERE rin_codpai = @codpai AND rin_descripcion = 'Maternidad'
SELECT @codrin_prorroga = rin_codigo FROM acc.rin_riesgos_incapacidades WHERE rin_codpai = @codpai AND rin_descripcion = 'Prorroga'

DECLARE companias CURSOR FOR
SELECT cia_codigo
FROM eor.cia_companias
WHERE cia_codpai = @codpai

OPEN companias

FETCH NEXT FROM companias INTO @codcia

WHILE @@FETCH_STATUS = 0
BEGIN
	IF NOT EXISTS (SELECT NULL FROM acc.pin_parametros_incapacidad WHERE pin_codcia = @codcia AND pin_codrin = @codrin_ccss)
	BEGIN
		INSERT acc.pin_parametros_incapacidad (pin_codcia, pin_codrin, pin_inicio, pin_final, pin_por_descuento, pin_por_subsidio_sal_maximo, pin_por_subsidio_sal_diario, pin_property_bag_data, pin_usuario_grabacion, pin_fecha_grabacion, pin_usuario_modificacion, pin_fecha_modificacion) 
		VALUES (@codcia, @codrin_ccss, 1, 3, 0.00, 50.00, 0.00, NULL, 'admin', GETDATE(), NULL, NULL)
		INSERT acc.pin_parametros_incapacidad (pin_codcia, pin_codrin, pin_inicio, pin_final, pin_por_descuento, pin_por_subsidio_sal_maximo, pin_por_subsidio_sal_diario, pin_property_bag_data, pin_usuario_grabacion, pin_fecha_grabacion, pin_usuario_modificacion, pin_fecha_modificacion) 
		VALUES (@codcia, @codrin_ccss, 4, 999, 100.00, 0.00, 0.00, NULL, 'admin', GETDATE(), NULL, NULL)
	END

	IF NOT EXISTS (SELECT NULL FROM acc.pin_parametros_incapacidad WHERE pin_codcia = @codcia AND pin_codrin = @codrin_ins)
	BEGIN
		INSERT acc.pin_parametros_incapacidad (pin_codcia, pin_codrin, pin_inicio, pin_final, pin_por_descuento, pin_por_subsidio_sal_maximo, pin_por_subsidio_sal_diario, pin_property_bag_data, pin_usuario_grabacion, pin_fecha_grabacion, pin_usuario_modificacion, pin_fecha_modificacion) 
		VALUES (@codcia, @codrin_ins, 1, 999, 100.00, 0.00, 0.00, NULL, 'admin', GETDATE(), NULL, NULL)
	END

	IF NOT EXISTS (SELECT NULL FROM acc.pin_parametros_incapacidad WHERE pin_codcia = @codcia AND pin_codrin = @codrin_maternidad)
	BEGIN
		INSERT acc.pin_parametros_incapacidad (pin_codcia, pin_codrin, pin_inicio, pin_final, pin_por_descuento, pin_por_subsidio_sal_maximo, pin_por_subsidio_sal_diario, pin_property_bag_data, pin_usuario_grabacion, pin_fecha_grabacion, pin_usuario_modificacion, pin_fecha_modificacion) 
		VALUES (@codcia, @codrin_maternidad, 1, 999, 50.00, 100.00, 0.00, NULL, 'admin', GETDATE(), NULL, NULL)
	END

	IF NOT EXISTS (SELECT NULL FROM acc.pin_parametros_incapacidad WHERE pin_codcia = @codcia AND pin_codrin = @codrin_prorroga)
	BEGIN
		INSERT acc.pin_parametros_incapacidad (pin_codcia, pin_codrin, pin_inicio, pin_final, pin_por_descuento, pin_por_subsidio_sal_maximo, pin_por_subsidio_sal_diario, pin_property_bag_data, pin_usuario_grabacion, pin_fecha_grabacion, pin_usuario_modificacion, pin_fecha_modificacion) 
		VALUES (@codcia, @codrin_prorroga, 1, 999, 100.00, 0.00, 0.00, NULL, 'admin', GETDATE(), NULL, NULL)
	END

	FETCH NEXT FROM companias INTO @codcia
END

CLOSE companias
DEALLOCATE companias

UPDATE acc.rin_riesgos_incapacidades
SET rin_property_bag_data = gen.set_pb_field_data(rin_property_bag_data, 'RiesgosIncapacidades', 'UtilizaPromedio', '1')
WHERE rin_codpai = @codpai
	AND rin_descripcion = 'Maternidad'

UPDATE acc.rin_riesgos_incapacidades
SET rin_property_bag_data = gen.set_pb_field_data(rin_property_bag_data, 'RiesgosIncapacidades', 'UtilizaPromedio', '0')
WHERE rin_codpai = @codpai
	AND rin_descripcion <> 'Maternidad'

COMMIT

