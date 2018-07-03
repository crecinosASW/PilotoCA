IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('sal.del_ods_otros_descuentos')
			  AND type = 'P')
BEGIN
	DROP PROCEDURE sal.del_ods_otros_descuentos
END

GO

CREATE PROCEDURE sal.del_ods_otros_descuentos (
	@codcia INT = NULL,	
	@codtpl_visual VARCHAR(20) = NULL, 
    @codppl_visual VARCHAR(10) = NULL,
    @codemp_alternativo VARCHAR(36) = NULL,
    @codtdc INT = NULL
)

AS

SET DATEFORMAT dmy

DECLARE @codemp INT,
	@codtpl INT,
	@codppl INT,
	@mensaje VARCHAR(1000)

SELECT @codtpl = tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual

SELECT @codppl = ppl_codigo
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
  AND ppl_codigo_planilla = @codppl_visual	
  
SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)	

SET @mensaje = ''

IF @codtpl IS NULL
	SET @mensaje = @mensaje + 'No existe el tipo de planilla con el código visual: ' + ISNULL(@codtpl_visual, 'Vacío') + ';' + CHAR(13)

IF @codppl IS NULL
	SET @mensaje = @mensaje + 'No existe la planilla con el código : ' + ISNULL(@codppl_visual, 'Vacío') + ';' + CHAR(13)

IF @codemp_alternativo IS NOT NULL AND @codemp IS NULL
	SET @mensaje = @mensaje + 'No el empleado con el código alternativo : ' + ISNULL(@codemp_alternativo, 'Vacío') + ';' + CHAR(13)

IF EXISTS(SELECT 1 FROM sal.ppl_periodos_planilla WHERE ppl_codigo = @codppl AND ppl_estado = 'Autorizado')
	SET @mensaje = @mensaje + 'No puede eliminar registros de la planilla ' + ISNULL(@codppl_visual, 'Vacío') + ' debido a que ya está autorizada' + ';' + CHAR(13)

IF @codtdc IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sal.tdc_tipos_descuento WHERE tdc_codcia = @codcia AND tdc_codigo = @codtdc)
	SET @mensaje = @mensaje + 'No existe el tipo de descuento con el código: ' + ISNULL(CONVERT(VARCHAR, @codtdc), 'Vacío') + ', en esa empresa' + ';' + CHAR(13)

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END

BEGIN TRANSACTION

DELETE 
FROM sal.ods_otros_descuentos
WHERE ods_codppl = @codppl
	AND ods_codemp = ISNULL(@codemp, ods_codemp)
	AND ods_codtdc = ISNULL(@codtdc, ods_codtdc)
	
COMMIT