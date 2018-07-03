IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('sal.del_oin_otros_ingresos')
			  AND type = 'P')
BEGIN
	DROP PROCEDURE sal.del_oin_otros_ingresos
END

GO

CREATE PROCEDURE sal.del_oin_otros_ingresos (	
	@codcia INT = NULL,	
	@codtpl_visual VARCHAR(20) = NULL, 
    @codppl_visual VARCHAR(10) = NULL,
    @codemp_alternativo VARCHAR(36) = NULL,
    @codtig INT = NULL
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
	
IF @codtig IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sal.tig_tipos_ingreso WHERE tig_codcia = @codcia AND tig_codigo = @codtig)	
	SET @mensaje = @mensaje + 'No existe el tipo de ingreso con el código: ' + ISNULL(CONVERT(VARCHAR, @codtig), 'Vacío') + ', en esa empresa' + ';' + CHAR(13)

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END

BEGIN TRANSACTION

DELETE 
FROM sal.oin_otros_ingresos
WHERE oin_codppl = @codppl
	AND oin_codemp = ISNULL(@codemp, oin_codemp)
	AND oin_codtig = ISNULL(@codtig, oin_codtig)
	
COMMIT