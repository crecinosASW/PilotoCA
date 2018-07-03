IF EXISTS (SELECT NULL 
		   FROM sys.procedures p
			  JOIN sys.schemas s ON p.schema_id = s.schema_id 
		   WHERE p.name = 'del_ext_horas_extras'
			   AND s.name = 'sal')
	DROP PROCEDURE sal.del_ext_horas_extras
	
GO	

CREATE PROCEDURE sal.del_ext_horas_extras (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(20) = NULL,
	@codppl_visual VARCHAR(20) = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@fecha_txt VARCHAR(10) = NULL,
	@codthe INT = NULL
)

AS	

SET NOCOUNT ON
SET DATEFORMAT dmy

DECLARE @codemp INT,
	@codtpl INT,
	@codppl INT,
	@fecha DATETIME,
	@mensaje VARCHAR(1000)
	
SET @mensaje = ''

SELECT @codtpl = tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual
	
SELECT @codppl = ppl_codigo
FROM sal.ppl_periodos_planilla	
WHERE ppl_codtpl = @codtpl
	AND ppl_codigo_planilla = @codppl_visual
	
SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)	

IF @codtpl IS NULL
	SET @mensaje = @mensaje + 'No existe el tipo de planilla con el código visual: ' + ISNULL(@codtpl_visual, 'Vacío') + ';' + CHAR(13)

IF @codppl IS NULL
	SET @mensaje = @mensaje + 'No existe la planilla con el código : ' + ISNULL(@codppl_visual, 'Vacío') + ';' + CHAR(13)

IF @codemp_alternativo IS NOT NULL AND @codemp IS NULL
	SET @mensaje = @mensaje + 'No el empleado con el código alternativo : ' + ISNULL(@codemp_alternativo, 'Vacío') + ';' + CHAR(13)

IF @fecha_txt IS NOT NULL AND ISDATE(@fecha_txt) = 0
	SET @mensaje = @mensaje + 'La fecha: ' + ISNULL(@fecha_txt, 'Vacío') + ', no está en el formato correcto, el formato debe ser DD/MM/YYYY' + '; ' + CHAR(13)	
	
IF @codthe IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sal.the_tipos_hora_extra WHERE the_codigo = @codthe)
	SET @mensaje = @mensaje + 'No existe el tipo de hora extra con el código: ' + ISNULL(CONVERT(VARCHAR, @codthe), 'Vacío') + '; ' + CHAR(13)	

IF EXISTS(SELECT 1 FROM sal.ppl_periodos_planilla WHERE ppl_codigo = @codppl AND ppl_estado = 'Autorizado')
	SET @mensaje = @mensaje + 'No puede eliminar registros de la planilla ' + ISNULL(@codppl_visual, 'Vacío') + ' debido a que ya está autorizada' + ';' + CHAR(13)

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END

SET @fecha = CONVERT(DATETIME, @fecha_txt)	

BEGIN TRANSACTION

DELETE 
FROM sal.ext_horas_extras
WHERE ext_codppl = @codppl
	AND ext_codemp = ISNULL(@codemp, ext_codemp)
	AND ext_fecha = ISNULL(@fecha, ext_fecha)
	AND ext_codthe = ISNULL(@codthe, ext_codthe)

COMMIT