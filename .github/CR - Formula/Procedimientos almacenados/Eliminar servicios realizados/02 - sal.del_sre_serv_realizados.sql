IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('sal.del_sre_serv_realizados')
			  AND type = 'P')
BEGIN
	DROP PROCEDURE sal.del_sre_serv_realizados
END

GO

CREATE PROCEDURE sal.del_sre_serv_realizados (	
	@codcia INT = NULL,	
	@codtpl_visual VARCHAR(20) = NULL, 
    @codppl_visual VARCHAR(10) = NULL,
    @codemp_alternativo VARCHAR(36) = NULL,
    @codsrv INT = NULL,
    @fecha_txt VARCHAR(10) = NULL
)

AS

SET DATEFORMAT dmy

DECLARE @codemp INT,
	@codtpl INT,
	@codppl INT,
	@fecha DATETIME,
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
	
IF @codsrv IS NOT NULL AND NOT EXISTS (SELECT 1 
									   FROM sal.srv_servicios
										  JOIN sal.gsr_grupos_servicio ON srv_codgsr = gsr_codigo
										  JOIN sal.csr_categorias_servicio ON gsr_codcsr = csr_codigo
									   WHERE csr_codcia = @codcia 
										  AND srv_codigo = @codsrv)	
	SET @mensaje = @mensaje + 'No existe el servicio con el código: ' + ISNULL(CONVERT(VARCHAR, @codsrv), 'Vacío') + ', en esa empresa' + ';' + CHAR(13)

IF @fecha_txt IS NOT NULL AND @fecha_txt <> '' AND ISDATE(@fecha_txt) = 0
	SET @mensaje = @mensaje + 'La fecha: ' + ISNULL(@fecha_txt, 'Vacío') + ', no está en el formato correcto, el formato es DD/MM/YYYY' + ';' + CHAR(13)

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END

BEGIN TRANSACTION

SET @fecha = CONVERT(DATETIME, @fecha_txt)

DELETE 
FROM sal.sre_servicios_realizados
WHERE sre_codppl = @codppl
	AND sre_codemp = ISNULL(@codemp, sre_codemp)
	AND sre_codsrv = ISNULL(@codsrv, sre_codsrv)
	AND sre_fecha = ISNULL(@fecha, sre_fecha)
	
COMMIT