IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('rel.procesa_asistencia'))
BEGIN
	DROP PROCEDURE rel.procesa_asistencia
END

GO

/*
   Proceso para procesar la asistencia
   generando tiempos no trabajados y horas extras
   ----------------------------------------------
   Creado por: Fernando Paz
               29-Abr-2014

   Este proceso se creo para que en una sola llamada se chequean los parámetros de aplicación
   y se generan tiempos no trabajados y horas extras de una vez.
   
   Ejemplo de ejecución:
      exec rel.procesa_asistencia 1, null, null, null
*/
--EXEC rel.procesa_asistencia 1, '4', '20150701', NULL, 'admin'
CREATE PROCEDURE rel.procesa_asistencia (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@codexp_alternativo VARCHAR(36) = NULL,
	@usuario varchar(100) = NULL
)

AS

SET NOCOUNT ON
SET DATEFIRST 7
SET DATEFORMAT DMY

DECLARE	@fecha_ini DATETIME, 
	@fecha_fin DATETIME, 
	@mensaje VARCHAR(500),
	@error INT, 
	@codtpl INT,
	@codppl INT,
	@codemp INT,
	@genera_extras BIT
		
SET @usuario = ISNULL(@usuario, SYSTEM_USER)

SELECT @codtpl = tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia 
	AND tpl_codigo_visual = @codtpl_visual

SELECT @codppl = ppl_codigo,
	@fecha_ini = ppl_fecha_ini, 
	@fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl 
	AND ppl_codigo_planilla = @codppl_visual
	AND ppl_estado <> 'Autorizado'

SET @codemp = gen.obtiene_codigo_empleo(@codexp_alternativo)
SET @mensaje = ''

IF @codtpl IS NULL
	SET @mensaje = @mensaje + 'No existe el tipo de planilla con el código: ' + ISNULL(@codtpl_visual, 'Vacío') + '; ' + CHAR(13)	

IF @codppl IS NULL
	SET @mensaje = @mensaje + 'No existe o está autorizado el período de planilla con el código: ' + ISNULL(@codppl_visual, 'Vacío') + '; ' + CHAR(13)	

IF @codexp_alternativo IS NOT NULL AND @codemp IS NULL
	SET @mensaje = @mensaje + 'No existe o no esta activo el empleado con el código: ' + ISNULL(@codexp_alternativo, 'Vacío') + '; ' + CHAR(13)

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END

SET @error = 0
SET @mensaje = ''
SET @usuario = ISNULL(@usuario, SYSTEM_USER)

SET @genera_extras = isnull(gen.get_valor_parametro_bit('RelojGeneraHEX', null, null, @codcia, null), 0)

IF @genera_extras = 1
BEGIN
    -- Genera Horas Extras
    EXEC rel.genera_extras @codppl, @codemp, @usuario

    IF @@ERROR != 0
	BEGIN
        SET @error = @@ERROR
    
        RAISERROR ('Error ID:%d.  Sucedio un error al ejecutar el procedimiento rel.genera_hex.', 16, 1, @error)
    END
END
ELSE
BEGIN
    PRINT 'No se generaron horas extras porque el parámetro de aplicación RelojGeneraHEX no está especificado o indica que no se generen al enviarle el código de empresa (' + cast(@codcia as varchar) + ')'
END