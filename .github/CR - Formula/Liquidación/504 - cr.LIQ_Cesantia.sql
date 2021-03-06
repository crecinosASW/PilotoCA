IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.LIQ_Cesantia'))
BEGIN
	DROP PROCEDURE cr.LIQ_Cesantia
END

GO

--EXEC cr.LIQ_Cesantia 80, '20140806', '100.00', 'CRC', '20050923', 2183, 220
CREATE PROCEDURE cr.LIQ_Cesantia ( 
	@codemp INT,
	@fecha_retiro DATETIME, 
	@codmon VARCHAR(3),
	@fecha_ingreso DATETIME,
	@codagr_cesantia INT,
	@codtig_cesantia INT
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY       
SET DATEFIRST 1

DECLARE @dias REAL, 
	@valor MONEY,
	@comentario VARCHAR(1000),
	@promedio_diario REAL,
	@antiguedad REAL,
	@antiguedad_meses REAL

SET @dias = 0.00
SET @valor = 0.00

SET @antiguedad_meses = gen.fn_antiguedad_meses(@fecha_ingreso, @fecha_retiro)

SET @dias = ISNULL((SELECT valor FROM gen.get_valor_rango_parametro('TablaCesantia', 'cr', NULL, NULL, NULL, @antiguedad_meses)), 0.00)

--Obtiene los años laborados, si lleva más de 6 meses en el último año y lleva más de 1 año de antigüedad se le cuenta como un año los 6 meses
SET @antiguedad = FLOOR(@antiguedad_meses / 12.00)

IF (@antiguedad_meses - @antiguedad * 12.00 >= 6.00 AND @antiguedad > 1.00)
	SET @antiguedad = @antiguedad + 1.00

IF @antiguedad = 0.00
	SET @antiguedad = 1.00

-- Obtiene el promedio diario  
EXEC cr.get_promedio_ingresos @codemp, @codagr_cesantia, @fecha_retiro, @codtig_cesantia, @promedio_diario OUTPUT

SET @valor = ROUND(@promedio_diario * @dias * @antiguedad, 2)

SET @comentario = '(Promedio Diario ('  + CONVERT(VARCHAR, @promedio_diario) + ') * Dias (' + CONVERT(VARCHAR, @dias) + 
                  ') * Años de Antigüedad (' + CONVERT(VARCHAR, @antiguedad) + ')'

--PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
--PRINT 'Fecha de Ingreso: ' + ISNULL(CONVERT(VARCHAR, @fecha_ingreso, 103), '')
--PRINT 'Fecha Retiro: ' + ISNULL(CONVERT(VARCHAR, @fecha_retiro, 103), '')
--PRINT 'Agrupador: ' + ISNULL(CONVERT(VARCHAR, @codagr_vac), '')
--PRINT 'Moneda: ' + ISNULL(@codmon, '')
--PRINT 'Tipo Ingreso: ' + ISNULL(CONVERT(VARCHAR, @codtig_vac), '')
--PRINT 'Antigüedad: ' + ISNULL(CONVERT(VARCHAR, @antiguedad), '')
--PRINT 'Antigüedad Meses: ' + ISNULL(CONVERT(VARCHAR, @antiguedad_meses), '')
--PRINT 'Promedio Diario: ' + ISNULL(CONVERT(VARCHAR, @promedio_diario), '')
--PRINT 'Días Cesantía: ' + ISNULL(CONVERT(VARCHAR, @dias), '')
--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor), '')

INSERT INTO #dli_detliq_ingresos ( dli_codtig,
                                   dli_valor,
                                   dli_codmon,
                                   dli_tiempo,
                                   dli_unidad_tiempo,
                                   dli_comentario, 
                                   dli_es_valor_fijo)
SELECT @codtig_cesantia dli_codtig,
	   @valor dli_valor,
	   @codmon dli_codmon,
	   ISNULL(@dias, 0.00) * ISNULL(@antiguedad, 0.00) dli_tiempo,
	   'Dias' dli_unidad_tiempo,
	   @comentario dli_comentario,
	   0 dli_es_valor_fijo
WHERE @valor > 0.00
  AND NOT EXISTS(SELECT NULL FROM #dli_detliq_ingresos WHERE dli_codtig = @codtig_cesantia)

RETURN