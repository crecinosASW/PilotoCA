IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.LIQ_AhorroEscolar'))
BEGIN
	DROP PROCEDURE cr.LIQ_AhorroEscolar
END

GO

--EXEC cr.LIQ_AhorroEscolar 80, '20140806', 'CRC', '20050923', 2184, 221
CREATE PROCEDURE cr.LIQ_AhorroEscolar (
	@codemp INT,
	@fecha_retiro DATETIME,
	@codmon VARCHAR(3),
	@fecha_ingreso DATETIME,
	@codagr_ahorro_escolar INT,
	@codtig_ahorro_escolar INT
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY       
SET DATEFIRST 1

DECLARE @fecha_inicio DATETIME,
	@total_descuentos MONEY,
	@valor REAL
                     
SET @total_descuentos = 0.00
SET @valor = 0.00

SET @fecha_inicio = CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, YEAR(@fecha_retiro)))

IF @fecha_inicio < @fecha_ingreso	
	SET @fecha_inicio = @fecha_ingreso

SELECT @total_descuentos = SUM(dss_valor)
FROM sal.dss_descuentos
	JOIN sal.ppl_periodos_planilla ON dss_codppl = ppl_codigo
WHERE dss_codemp = @codemp
	AND ppl_estado = 'Autorizado'
	AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio))
		BETWEEN @fecha_inicio AND @fecha_retiro
	AND dss_codtdc IN (SELECT iag_codtig
					   FROM sal.iag_ingresos_agrupador
					   WHERE iag_codagr = @codagr_ahorro_escolar)

SET @valor = ROUND(ISNULL(@total_descuentos, 0.00), 2)

--PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
--PRINT 'Fecha de Ingreso: ' + ISNULL(CONVERT(VARCHAR, @fecha_ingreso, 103), '')
--PRINT 'Fecha Retiro: ' + ISNULL(CONVERT(VARCHAR, @fecha_retiro, 103), '')
--PRINT 'Moneda: ' + ISNULL(@codmon, '')
--PRINT 'Agrupador: ' + ISNULL(CONVERT(VARCHAR, @codagr_ahorro_escolar), '')
--PRINT 'Tipo Ingreso: ' + ISNULL(CONVERT(VARCHAR, @codtig_ahorro_escolar), '')
--PRINT 'Fecha Inicio: ' + ISNULL(CONVERT(VARCHAR, @fecha_inicio, 103), '')
--PRINT 'Total Descuentos: ' + ISNULL(CONVERT(VARCHAR, @total_descuentos), '')
--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor), '')

---- calculo de las vacaciones
INSERT INTO #dli_detliq_ingresos (dli_codtig,
	dli_valor,
	dli_codmon,
	dli_tiempo,
	dli_unidad_tiempo,
	dli_comentario, 
	dli_es_valor_fijo)
SELECT @codtig_ahorro_escolar dli_codtig,
	@valor dli_valor,
	@codmon dli_codmon,
	0.00 dli_tiempo,
	'Dias' dli_unidad_tiempo,
	'' dli_comentario,
	0 dli_es_valor_fijo
WHERE @valor > 0.00
	AND NOT EXISTS(SELECT NULL FROM #dli_detliq_ingresos WHERE dli_codtig = @codtig_ahorro_escolar)

RETURN