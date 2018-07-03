/*
IMPORTANTE: Antes de ejecutar este script, validar que tipos de ingresos existen para no duplicar los tipos de ingresos.

SELECT *
FROM sal.tig_tipos_ingreso
	JOIN eor.cia_companias ON tig_codcia = cia_codigo
WHERE cia_codpai = 'cr'
ORDER BY tig_codcia, tig_descripcion

*/

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
	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = '20')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_cuenta, tig_cuenta_aux, tig_cuenta_patronal, tig_cuenta_patronal_aux, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Ahorro Escolar', '20', 1, 160, NULL, NULL, NULL, NULL, '', 'Autorizado', NULL, 0, '2015-03-26 09:27:43', 'admin', '2015-03-26 09:28:02', 'admin')

	IF NOT EXISTS (SELECT NULL FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_abreviatura = '21')
		INSERT sal.tig_tipos_ingreso (tig_codcia, tig_descripcion, tig_abreviatura, tig_activo, tig_orden, tig_cuenta, tig_cuenta_aux, tig_cuenta_patronal, tig_cuenta_patronal_aux, tig_property_bag_data, tig_estado_workflow, tig_codigo_workflow, tig_ingresado_portal, tig_fecha_grabacion, tig_usuario_grabacion, tig_fecha_modificacion, tig_usuario_modificacion) 
		VALUES (@codcia, 'Ahorro Patronal', '21', 1, 170, NULL, NULL, NULL, NULL, '', 'Autorizado', NULL, 0, '2015-03-26 09:33:55', 'admin', '2015-03-26 09:34:05', 'admin')

	FETCH NEXT FROM companias INTO @codcia
END

CLOSE companias
DEALLOCATE companias

COMMIT