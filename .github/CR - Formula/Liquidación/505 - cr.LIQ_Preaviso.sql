IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.LIQ_Preaviso'))
BEGIN
	DROP PROCEDURE cr.LIQ_Preaviso
END

GO

--EXEC cr.LIQ_Preaviso 80, '20140806', 'CRC', '20050923', 2183, 220
CREATE PROCEDURE cr.LIQ_Preaviso ( 
	@codemp INT,
	@fecha_retiro DATETIME, 
	@codmon VARCHAR(3),
	@fecha_ingreso DATETIME,
	@codagr_preaviso INT,
	@codtig_preaviso INT,
	@dias_preaviso REAL
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY       
SET DATEFIRST 1

DECLARE @antiguedad_meses REAL,
	@dias_maximos REAL,
	@promedio_diario REAL,
	@dias REAL, 
	@valor REAL,
	@comentario VARCHAR(300)

SET @antiguedad_meses = gen.fn_antiguedad_meses(@fecha_ingreso, @fecha_retiro)
                      
SET @dias = 0.00
SET @valor = 0.00

SET @dias_maximos = ISNULL((SELECT valor FROM gen.get_valor_rango_parametro('TablaPreaviso', 'cr', NULL, NULL, NULL, @antiguedad_meses)), 0.00)

--Obtienen los días a utilizar en el cálculo del preaviso, si se especifica que el empleado gozo días de preaviso se toman los días de la tabla de preaviso menos los días gozados del preaviso.
SET @dias = @dias_maximos - ISNULL(@dias_preaviso, 0.00)

IF @dias < 0.00
	SET @dias = 0.00

EXEC cr.get_promedio_ingresos @codemp, @codagr_preaviso, @fecha_retiro, @codtig_preaviso, @promedio_diario OUTPUT

SET @valor = ROUND(@promedio_diario * @dias, 2)

SET @comentario =  'Promedio Diario (' + CONVERT(VARCHAR, @promedio_diario) + ') * Dias ('+CONVERT(VARCHAR, @dias) + ')'

--PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
--PRINT 'Fecha de Ingreso: ' + ISNULL(CONVERT(VARCHAR, @fecha_ingreso, 103), '')
--PRINT 'Fecha Retiro: ' + ISNULL(CONVERT(VARCHAR, @fecha_retiro, 103), '')
--PRINT 'Agrupador: ' + ISNULL(CONVERT(VARCHAR, @codagr_preaviso), '')
--PRINT 'Moneda: ' + ISNULL(@codmon, '')
--PRINT 'Tipo Ingreso: ' + ISNULL(CONVERT(VARCHAR, @codtig_preaviso), '')
--PRINT 'Antigüedad Meses: ' + ISNULL(CONVERT(VARCHAR, @antiguedad_meses), '')
--PRINT 'Días Máximos: ' + ISNULL(CONVERT(VARCHAR, @dias_maximos), '')
--PRINT 'Días Otorgados: ' + ISNULL(CONVERT(VARCHAR, @dias_preaviso), '')
--PRINT 'Promedio Diario: ' + ISNULL(CONVERT(VARCHAR, @promedio_diario), '')
--PRINT 'Días Preaviso: ' + ISNULL(CONVERT(VARCHAR, @dias), '')
--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor), '')
--PRINT ''

INSERT INTO #dli_detliq_ingresos ( dli_codtig,
                                   dli_valor,
                                   dli_codmon,
                                   dli_tiempo,
                                   dli_unidad_tiempo,
                                   dli_comentario, 
                                   dli_es_valor_fijo)
SELECT @codtig_preaviso dli_codtig,
	   @valor dli_valor,
	   @codmon dli_codmon,
	   ISNULL(@dias, 0.00) dli_tiempo,
	   'Dias' dli_unidad_tiempo,
	   @comentario dli_comentario,
	   0 dli_es_valor_fijo
WHERE @valor > 0.00
	AND NOT EXISTS(SELECT NULL FROM #dli_detliq_ingresos WHERE dli_codtig = @codtig_preaviso)

RETURN