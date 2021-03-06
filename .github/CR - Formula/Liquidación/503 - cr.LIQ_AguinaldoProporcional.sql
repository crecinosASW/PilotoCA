IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.LIQ_AguinaldoProporcional'))
BEGIN
	DROP PROCEDURE cr.LIQ_AguinaldoProporcional
END

GO

--------------------------------------------------------------------------------------
-- evolution standard - liquidacion                                                 --
-- calculo de aguinaldo proporcional a la fecha de retiro                           --
--------------------------------------------------------------------------------------
--EXEC cr.LIQ_AguinaldoProporcional 1859, '20150306', 'CRC', '20050923', 18, 222, 2185
CREATE PROCEDURE cr.LIQ_AguinaldoProporcional (
	@codemp INT,
	@fecha_retiro DATETIME,
	@codmon VARCHAR(3),
	@fecha_ingreso DATETIME,
	@codtpl_aguinaldo INT,
	@codtig_aguinaldo INT, 
	@codagr_aguinaldo INT
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY
SET DATEFIRST 1

-- variables
DECLARE @codpai VARCHAR(2),
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@ppl_estado char(1),
	@pago MONEY,
	@codppl INT,
	@dias REAL,
	@valor MONEY,
	@comentario VARCHAR(1000),
	@meses_totales INT,
	@total_ingresos MONEY,
	@total_maternidad MONEY,
	@otros_ingresos_liq MONEY,
	@total MONEY,
	@codrin_maternidad INT

SELECT @codpai = cia_codpai
FROM exp.emp_empleos
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
WHERE emp_codigo = @codemp

SET @codrin_maternidad = gen.get_valor_parametro_int('CodigoRIN_Maternidad', @codpai, NULL, NULL, NULL)

---------------------------
--    inicializacion     --
---------------------------
SET @dias = 0
SET @valor = 0.00
SET @codppl = 0

----------------------------------------
-- busca planilla actual de aguinaldo --
----------------------------------------
SELECT @ppl_estado = ppl_estado,
	@codppl = ppl_codigo,
	@ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl_aguinaldo
	AND @fecha_retiro BETWEEN ppl_fecha_ini AND ppl_fecha_fin

SELECT @pago = ISNULL(COUNT(*), 0)
FROM sal.inn_ingresos
WHERE inn_codppl = @codppl
	AND inn_codemp = @codemp

IF @ppl_estado <> 'Autorizado' OR (@ppl_estado = 'Autorizado' AND @pago = 0) OR @codppl = 0
BEGIN
	-- determina la fecha de corte del aguinaldo
	IF @ppl_fecha_ini < @fecha_ingreso
		SET @ppl_fecha_ini = @fecha_ingreso

	-- calcula el numero de dias de aguinaldo
	SET @dias = DATEDIFF(DAY, @ppl_fecha_ini, @fecha_retiro) + 1
  
	SET @meses_totales = DATEDIFF(mm, @ppl_fecha_ini, @ppl_fecha_fin) + 1

	SELECT @total_ingresos = ROUND(SUM(inn_valor), 2) 
	FROM sal.inn_ingresos 
		JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
	WHERE inn_codemp = @codemp
		AND ppl_estado = 'Autorizado'
		AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio))
			BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin
		AND inn_codtig IN (SELECT iag_codtig
						   FROM sal.iag_ingresos_agrupador
						   WHERE iag_codagr = @codagr_aguinaldo)

	SELECT @total_maternidad = ROUND(SUM(pie_valor_a_pagar + pie_valor_a_descontar), 2)
	FROM acc.pie_periodos_incapacidad 
		JOIN acc.ixe_incapacidades ON pie_codixe = ixe_codigo
		JOIN sal.ppl_periodos_planilla ON pie_codppl = ppl_codigo
		JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
	WHERE ixe_codemp = @codemp
		AND ixe_codrin = @codrin_maternidad
		AND pie_planilla_autorizada = 1
		AND ppl_estado = 'Autorizado'
		AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio))
			BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin

	SELECT @otros_ingresos_liq = ROUND(SUM(dli_valor), 2)
	FROM #dli_detliq_ingresos
	WHERE dli_codtig IN (SELECT iag_codtig
						 FROM sal.iag_ingresos_agrupador
						 WHERE iag_codagr = @codagr_aguinaldo)

	SET @total = ISNULL(@total_ingresos, 0.00) + ISNULL(@total_maternidad, 0.00) + ISNULL(@otros_ingresos_liq, 0.00)

	SET @valor = ROUND(ISNULL(@total, 0.00) / @meses_totales, 2)
 
	-- llena el detalle del calculo para el reporte
	EXEC cr.fill_promedio_aguinaldo @codemp, @codagr_aguinaldo, @ppl_fecha_ini, @fecha_retiro, @ppl_fecha_fin, @codtig_aguinaldo, @codmon
     
	SET @comentario = ' Ingresos Totales (' + CONVERT(VARCHAR, @total) + ') / '+ CONVERT(VARCHAR, @meses_totales)

END
ELSE
BEGIN
	SET @dias = 0
	SET @valor = 0 
END

--PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
--PRINT 'Fecha de Ingreso: ' + ISNULL(CONVERT(VARCHAR, @fecha_ingreso, 103), '')
--PRINT 'Fecha Retiro: ' + ISNULL(CONVERT(VARCHAR, @fecha_retiro, 103), '')
--PRINT 'Agrupador: ' + ISNULL(CONVERT(VARCHAR, @codagr_aguinaldo), '')
--PRINT 'Riesgo Maternidad: ' + ISNULL(CONVERT(VARCHAR, @codrin_maternidad), '')
--PRINT 'Moneda: ' + ISNULL(@codmon, '')
--PRINT 'Pais: ' + ISNULL(@codpai, '')
--PRINT 'Tipo Ingreso: ' + ISNULL(CONVERT(VARCHAR, @codtig_aguinaldo), '')
--PRINT 'Tipo Planilla: ' + ISNULL(CONVERT(VARCHAR, @codtpl_aguinaldo), '')
--PRINT 'Fecha Inicio: ' + ISNULL(CONVERT(VARCHAR, @ppl_fecha_ini, 103), '')
--PRINT 'Fecha Fin: ' + ISNULL(CONVERT(VARCHAR, @ppl_fecha_fin, 103), '')
--PRINT 'Estado Planilla: ' + ISNULL(@ppl_estado, '')
--PRINT 'Pago: ' + ISNULL(CONVERT(VARCHAR, @pago), '')
--PRINT 'Planilla: ' + ISNULL(CONVERT(VARCHAR, @codppl), '')
--PRINT 'Meses Totales: ' + ISNULL(CONVERT(VARCHAR, @meses_totales), '')
--PRINT 'Total Ingresos: ' + ISNULL(CONVERT(VARCHAR, @total_ingresos), '')
--PRINT 'Total Maternidad: ' + ISNULL(CONVERT(VARCHAR, @total_maternidad), '')
--PRINT 'Total: ' + ISNULL(CONVERT(VARCHAR, @total), '')
--PRINT 'Días Aguinaldo: ' + ISNULL(CONVERT(VARCHAR, @dias), '')
--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor), '')
--PRINT ''

-----------------------------
--      crea ingresos      --
-----------------------------
INSERT INTO #dli_detliq_ingresos ( dli_codtig,
                                   dli_valor,
                                   dli_codmon,
                                   dli_tiempo,
                                   dli_unidad_tiempo,
                                   dli_comentario, 
                                   dli_es_valor_fijo)
SELECT @codtig_aguinaldo dli_codtig,
	   @valor dli_valor,
	   @codmon dli_codmon,
	   @dias dli_tiempo,
	   'Dias' dli_unidad_tiempo,
	   @comentario dli_comentario,
	   0 dli_es_valor_fijo
 WHERE @valor > 0
	AND NOT EXISTS(SELECT NULL FROM #dli_detliq_ingresos WHERE dli_codtig = @codtig_aguinaldo)

RETURN
