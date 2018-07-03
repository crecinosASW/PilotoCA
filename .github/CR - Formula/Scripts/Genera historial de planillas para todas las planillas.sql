DECLARE @codcia INT,
	@codtpl_visual VARCHAR(20),
	@codppl_visual VARCHAR(10),
	@usuario VARCHAR(50)

SET @codcia = 1
SET @codtpl_visual = '10'
SET @usuario = 'admin'

DECLARE planillas CURSOR FOR
SELECT ppl_codigo_planilla
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = ISNULL(@codtpl_visual, tpl_codigo_visual)

OPEN planillas

FETCH NEXT FROM planillas INTO @codppl_visual

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC sal.genera_hist_planillas @codcia, @codtpl_visual, @codppl_visual, @usuario

	FETCH NEXT FROM planillas INTO @codppl_visual
END

CLOSE planillas
DEALLOCATE planillas

--DELETE sal.hpa_hist_periodos_planilla