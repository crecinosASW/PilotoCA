IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.LIQ_AhorroPatronal'))
BEGIN
	DROP PROCEDURE cr.LIQ_AhorroPatronal
END

GO

--EXEC cr.LIQ_AhorroPatronal 80, '20140806', 'CRC', '20050923', 2184, 221
CREATE PROCEDURE cr.LIQ_AhorroPatronal (
	@codemp INT,
	@fecha_retiro DATETIME,
	@codmon VARCHAR(3),
	@fecha_ingreso DATETIME,
	@codtig_ahorro_patronal INT,
	@codtrs_ahorro_patronal INT
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY       
SET DATEFIRST 1

DECLARE @fecha_inicio DATETIME,
	@total_reservas MONEY,
	@valor REAL
                     
SET @total_reservas = 0.00
SET @valor = 0.00

SET @fecha_inicio = CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, YEAR(@fecha_retiro)))

IF @fecha_inicio < @fecha_ingreso	
	SET @fecha_inicio = @fecha_ingreso

SELECT @total_reservas = SUM(res_valor)
FROM sal.res_reservas
	JOIN sal.ppl_periodos_planilla ON res_codppl = ppl_codigo
WHERE res_codemp = @codemp
	AND ppl_estado = 'Autorizado'
	AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio))
		BETWEEN @fecha_inicio AND @fecha_retiro
	AND res_codtrs = @codtrs_ahorro_patronal

SET @valor = ROUND(ISNULL(@total_reservas, 0.00), 2)

--PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
--PRINT 'Fecha de Ingreso: ' + ISNULL(CONVERT(VARCHAR, @fecha_ingreso, 103), '')
--PRINT 'Fecha Retiro: ' + ISNULL(CONVERT(VARCHAR, @fecha_retiro, 103), '')
--PRINT 'Moneda: ' + ISNULL(@codmon, '')
--PRINT 'Tipo Ingreso: ' + ISNULL(CONVERT(VARCHAR, @codtig_ahorro_patronal), '')
--PRINT 'Tipo Reserva: ' + ISNULL(CONVERT(VARCHAR, @codtrs_ahorro_patronal), '')
--PRINT 'Fecha Inicio: ' + ISNULL(CONVERT(VARCHAR, @fecha_inicio, 103), '')
--PRINT 'Total Reservas: ' + ISNULL(CONVERT(VARCHAR, @total_reservas), '')
--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor), '')

---- calculo de las vacaciones
INSERT INTO #dli_detliq_ingresos (dli_codtig,
	dli_valor,
	dli_codmon,
	dli_tiempo,
	dli_unidad_tiempo,
	dli_comentario, 
	dli_es_valor_fijo)
SELECT @codtig_ahorro_patronal dli_codtig,
	@valor dli_valor,
	@codmon dli_codmon,
	0.00 dli_tiempo,
	'Dias' dli_unidad_tiempo,
	'' dli_comentario,
	0 dli_es_valor_fijo
WHERE @valor > 0.00
	AND NOT EXISTS(SELECT NULL FROM #dli_detliq_ingresos WHERE dli_codtig = @codtig_ahorro_patronal)

RETURN