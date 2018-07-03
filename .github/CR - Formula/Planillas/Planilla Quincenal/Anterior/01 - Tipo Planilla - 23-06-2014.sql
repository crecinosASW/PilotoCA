--SELECT * FROM sal.tpl_tipo_planilla
--DELETE FROM sal.tpl_tipo_planilla

BEGIN TRANSACTION

DECLARE @codpai VARCHAR(2),
	@codcia INT

SET @codpai = 'gt'

DECLARE companias CURSOR FOR
SELECT cia_codigo
FROM eor.cia_companias
WHERE cia_codpai = @codpai

OPEN companias

FETCH NEXT FROM companias INTO @codcia

WHILE @@FETCH_STATUS = 0
BEGIN
	IF NOT EXISTS (SELECT NULL FROM sal.tpl_tipo_planilla WHERE tpl_codcia = @codcia AND tpl_codigo_visual = '1')
		INSERT INTO sal.tpl_tipo_planilla(tpl_codigo_visual, tpl_codcia, tpl_codmon, tpl_descripcion, tpl_frecuencia, tpl_aplicacion, tpl_num_periodo, tpl_total_periodos, tpl_codtpl_normal, tpl_hex_rango_fechas_ingreso, tpl_hex_offset_rango_fechas, tpl_asi_rango_fechas_ingreso, tpl_asi_offset_rango_fechas, tpl_property_bag_data, tpl_usuario_grabacion, tpl_fecha_grabacion, tpl_usuario_modificacion, tpl_fecha_modificacion)
		VALUES ('1', @codcia, 'GTQ', 'Planilla Mensual Con Anticipo', 'Mensual', 'Normal', 1, 24, NULL, 'UsarFechasCorte', 2, 'UsarFechasCorte', 2, NULL, NULL, NULL, NULL, NULL)

	FETCH NEXT FROM companias INTO @codcia
END

CLOSE companias
DEALLOCATE companias

COMMIT

