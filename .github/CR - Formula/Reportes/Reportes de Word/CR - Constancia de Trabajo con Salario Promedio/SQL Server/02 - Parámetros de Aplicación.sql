-- Parámetros de Aplicación

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codgrc INT,
	@codcia INT

SET @codpai = 'cr'

--Parámetros
IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'ConstanciaSalarioMesesPromedio')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('ConstanciaSalarioMesesPromedio', 'Número de meses para el promedio de la constancia de salario', 'Double', 'Mes', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'ConstanciaSalarioTextoEmbargo')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('ConstanciaSalarioTextoEmbargo', 'Texto cuando el empleado tiene embargo', 'String', 'Caracteres', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.par_parametros WHERE par_codigo = 'ConstanciaSalarioTextoNoEmbargo')
	INSERT gen.par_parametros (par_codigo, par_descripcion, par_tipo, par_unidad_medida, par_tipo_valor, par_property_bag_data, par_usuario_grabacion, par_fecha_grabacion, par_usuario_modificacion, par_fecha_modificacion) 
	VALUES ('ConstanciaSalarioTextoNoEmbargo', 'Texto cuando el empelado no tiene embargo', 'String', 'Caracteres', 'E', NULL, 'admin', GETDATE(), NULL, NULL)

--Alcances
IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'ConstanciaSalarioMesesPromedio' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'ConstanciaSalarioMesesPromedio', @codpai, NULL, NULL, NULL, CONVERT(VARCHAR, 3), 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'ConstanciaSalarioTextoEmbargo' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'ConstanciaSalarioTextoEmbargo', @codpai, NULL, NULL, NULL, 'se encuentra embargado', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM gen.apa_alcances_parametros WHERE apa_codpar = 'ConstanciaSalarioTextoNoEmbargo' AND apa_codpai = @codpai)
	INSERT gen.apa_alcances_parametros (apa_fecha_inicio, apa_fecha_final, apa_codpar, apa_codpai, apa_codgrc, apa_codcia, apa_codcdt, apa_valor, apa_usuario_grabacion, apa_fecha_grabacion, apa_usuario_modificacion, apa_fecha_modificacion) 
	VALUES (NULL, NULL, 'ConstanciaSalarioTextoNoEmbargo', @codpai, NULL, NULL, NULL, 'no ha sido embargado y se encuentra libre de gravámenes', 'admin', GETDATE(), NULL, NULL)

DECLARE companias CURSOR FOR
SELECT cia_codgrc,
	cia_codigo
FROM eor.cia_companias
WHERE cia_codpai = @codpai

OPEN companias

FETCH NEXT FROM companias INTO @codgrc, @codcia

WHILE @@FETCH_STATUS = 0
BEGIN

	FETCH NEXT FROM companias INTO @codgrc, @codcia
END

CLOSE companias
DEALLOCATE companias

COMMIT