IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.LIQ_DescuentoAsociacion'))
BEGIN
	DROP PROCEDURE cr.LIQ_DescuentoAsociacion
END

GO

--EXEC cr.LIQ_DescuentoAsociacion 80, '20140806', 'CRC', '20050923', 2184, 221
CREATE PROCEDURE cr.LIQ_DescuentoAsociacion (
	@codemp INT,
	@fecha_retiro DATETIME,
	@codmon VARCHAR(3),
	@fecha_ingreso DATETIME,
	@codtdc_asociacion INT,
	@codtrs_asociacion INT
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY       
SET DATEFIRST 1

DECLARE @total_reservas MONEY,
	@valor REAL
                     
SET @total_reservas = 0.00
SET @valor = 0.00

SELECT @total_reservas = SUM(res_valor)
FROM sal.res_reservas
	JOIN sal.ppl_periodos_planilla ON res_codppl = ppl_codigo
WHERE res_codemp = @codemp
	AND ppl_estado = 'Autorizado'
	AND res_codtrs = @codtrs_asociacion

SET @valor = ROUND(ISNULL(@total_reservas, 0.00), 2)

--PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
--PRINT 'Fecha de Ingreso: ' + ISNULL(CONVERT(VARCHAR, @fecha_ingreso, 103), '')
--PRINT 'Fecha Retiro: ' + ISNULL(CONVERT(VARCHAR, @fecha_retiro, 103), '')
--PRINT 'Moneda: ' + ISNULL(@codmon, '')
--PRINT 'Tipo Descuento: ' + ISNULL(CONVERT(VARCHAR, @codtdc_asociacion), '')
--PRINT 'Tipo Reserva: ' + ISNULL(CONVERT(VARCHAR, @codtrs_asociacion), '')
--PRINT 'Total Reservas: ' + ISNULL(CONVERT(VARCHAR, @total_reservas), '')
--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor), '')

INSERT INTO #dld_detliq_descuentos (dld_codtdc,
	dld_es_descuento_legal,
	dld_valor, 
	dld_valor_patronal,
	dld_ingreso_afecto,
	dld_codmon,
	dld_tiempo,
	dld_unidad_tiempo,
	dld_comentario,
	dld_es_valor_fijo)
SELECT @codtdc_asociacion,
	0, 
	@valor,
	0.00,
	0.00,
	@codmon,
	0.00,
	'Dias',
	'' det_comentario,
	0
WHERE @valor > 0.00
	AND NOT EXISTS(SELECT NULL FROM #dld_detliq_descuentos WHERE dld_codtdc = @codtdc_asociacion)

RETURN