IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.LIQ_VacacionesProporcional'))
BEGIN
	DROP PROCEDURE cr.LIQ_VacacionesProporcional
END

GO

--EXEC cr.LIQ_VacacionesProporcional 80, '20140806', 'CRC', '20050923', 2184, 221
CREATE PROCEDURE cr.LIQ_VacacionesProporcional (
	@codemp INT,
	@fecha_retiro DATETIME,
	@codmon VARCHAR(3),
	@fecha_ingreso DATETIME,
	@codagr_vac INT,
	@codtig_vac INT
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY       
SET DATEFIRST 1

DECLARE @dias REAL, 
	@promedio_diario REAL,
	@valor REAL,
	@comentario VARCHAR(300)
                     
SET @dias = 0.00
SET @valor = 0.00

SELECT @dias = ISNULL(SUM(vac_saldo), 0)
FROM acc.vac_vacaciones
WHERE vac_codemp = @codemp
  
EXEC cr.get_promedio_ingresos @codemp, @codagr_vac, @fecha_retiro, @codtig_vac, @promedio_diario OUTPUT

SET @valor = ROUND(@promedio_diario * @dias, 2)

SET @comentario =  'Promedio Diario (' + CONVERT(VARCHAR, @promedio_diario) + ') * Dias (' + CONVERT(VARCHAR, @dias) + ')'

--PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
--PRINT 'Fecha de Ingreso: ' + ISNULL(CONVERT(VARCHAR, @fecha_ingreso, 103), '')
--PRINT 'Fecha Retiro: ' + ISNULL(CONVERT(VARCHAR, @fecha_retiro, 103), '')
--PRINT 'Agrupador: ' + ISNULL(CONVERT(VARCHAR, @codagr_vac), '')
--PRINT 'Moneda: ' + ISNULL(@codmon, '')
--PRINT 'Tipo Ingreso: ' + ISNULL(CONVERT(VARCHAR, @codtig_vac), '')
--PRINT 'Promedio Diario: ' + ISNULL(CONVERT(VARCHAR, @promedio_diario), '')
--PRINT 'Días Vacaciones: ' + ISNULL(CONVERT(VARCHAR, @dias), '')
--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor), '')

---- calculo de las vacaciones
INSERT INTO #dli_detliq_ingresos (dli_codtig,
	dli_valor,
	dli_codmon,
	dli_tiempo,
	dli_unidad_tiempo,
	dli_comentario, 
	dli_es_valor_fijo)
SELECT @codtig_vac dli_codtig,
	@valor dli_valor,
	@codmon dli_codmon,
	@dias dli_tiempo,
	'Dias' dli_unidad_tiempo,
	@comentario dli_comentario,
	0 dli_es_valor_fijo
WHERE @valor > 0.00
	AND NOT EXISTS(SELECT NULL FROM #dli_detliq_ingresos WHERE dli_codtig = @codtig_vac)

RETURN