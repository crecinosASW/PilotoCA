IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.get_promedio_ingresos'))
BEGIN
	DROP PROCEDURE cr.get_promedio_ingresos
END

GO

----------------------------------------------------------------
-- evolution costa rica standard                               --
-- obtiene el promedio de x meses completos atras de la fecha --
-- recibida                                                   --                 
----------------------------------------------------------------
/*
--82	CR - Base Cálculo de Cesantía
--83	CR - Base Cálculo de Preaviso
--75	CR - Base Calculo de Vacaciones
--74	CR - Base Calculo de Aguinaldo
--86	CR - Base Calculo Ahorro Escolar

DECLARE @fecha_desde DATETIME,
	@promedio REAL

SET @fecha_desde = CONVERT(DATETIME,'06/03/2015',103)
SET @promedio = 0

EXEC cr.get_promedio_ingresos 1859, 82, @fecha_desde, 16, @promedio output
*/
CREATE PROCEDURE cr.get_promedio_ingresos (
	@codemp INT,
    @codagr INT = 0, -- agrupador para los ingresos variables
    @fecha DATETIME, -- fecha a partir de la cual se desea el promedio
	@codtig INT, -- tipo del ingreso que se esta calculando aguinaldo, bono 14, indem, vacaciones
    @promedio REAL OUTPUT -- resultado
)

-------------------------------------------------------------------------------
--  evolution                                                                --
--  obtiene el promedio de los x meses completos atras de la fecha recibida  --
--  si la fecha recibida no es fin de mes la ajusta al fin de mes anterior   --
--  se ajusta a la fecha de ingreso si esta fuera mayor a la fecha de inicio --
--  del promedio, y realiza el promedio entre estos meses                    --
-------------------------------------------------------------------------------

AS

SET NOCOUNT ON
SET DATEFORMAT DMY

DECLARE @codpai VARCHAR(2),
	@codexp_alternativo VARCHAR(36),
	@tasa_cambio REAL,
	@codcia INT,
	@divisor REAL,
	@salario_minimo_diario MONEY,
	@salario_minimo MONEY,
	@meses_promedio REAL,
	@fecha_desde DATETIME,
	@fecha_hasta DATETIME,
	@fecha_ingreso DATETIME,
	@total_ingresos MONEY,
	@total_ingresos_parcial MONEY,
	@valor MONEY,
	@valor_maternidad MONEY,
	@valor_total MONEY,
	@promedio_mensual MONEY,
	@valor_base MONEY,
	@promedio_diario MONEY,
	@salario MONEY = 0,
	@codrsa_salario INT = 0,
	@dias_trabajados INT = 0,
	@dias_totales INT = 0,
	@codmon VARCHAR(3),
	@incluye_promedio BIT,
	@codrin_maternidad INT

-----------------------------------------
-- obtiene compania y fecha de ingreso --
-----------------------------------------  
SELECT @codpai = cia_codpai,
	@codcia = plz_codcia,
	@codexp_alternativo = exp_codigo_alternativo,
	@fecha_ingreso = emp_fecha_ingreso,
	@divisor = CASE WHEN tpl_frecuencia = 'Semanal' THEN 26.00 ELSE 30.00 END
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo   
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN sal.tpl_tipo_planilla ON emp_codtpl = tpl_codigo
WHERE emp_codigo = @codemp

--------------------------------------
--      obtiene tipos de ingreso    --
--------------------------------------  
SET @codrsa_salario = ISNULL(gen.get_valor_parametro_INT ('CodigoRSA_Salario',NULL,NULL,@codcia,NULL), 0)
SET @codrin_maternidad = gen.get_valor_parametro_int('CodigoRIN_Maternidad', @codpai, NULL, NULL, NULL)

-----------------------------------------
--     obtiene salarios actuales       --
-----------------------------------------    
SELECT @salario = ese_valor,
	@codmon = ese_codmon
FROM exp.emp_empleos
	JOIN exp.ese_estructura_sal_empleos ON emp_codigo = ese_codemp
WHERE emp_codigo = @codemp 
	AND ese_estado = 'V'
	AND ese_codrsa = @codrsa_salario

IF @codmon = 'USD'
	SET @tasa_cambio = ISNULL(gen.get_tasa_cambio('CRC', @fecha), 1.00)
ELSE	
	SET @tasa_cambio = 1.00

SET @salario_minimo_diario = gen.get_valor_parametro_float('SalarioMinimoDiario', @codpai, NULL, NULL, NULL) / @tasa_cambio
SET @salario_minimo = @salario_minimo_diario * @divisor

--------------------------------------
--        limpia el detalle         --
--------------------------------------  
DELETE cr.hli_historico_liquidaciones
WHERE hli_codemp = @codemp
	AND hli_fecha_retiro = @fecha
	AND hli_codtig = @codtig

SET @meses_promedio = 0.00
SET @total_ingresos = 0.00
SET @total_ingresos_parcial = 0.00
SET @valor = 0.00
SET @valor_maternidad = 0.00
SET @valor_total = 0.00
SET @dias_totales = 0.00
SET @incluye_promedio = 0

----------------------------------------------
--          ajusta a meses completos        --
--           tanto inicio como fin          --
----------------------------------------------
SET @fecha_hasta = @fecha

IF  @fecha_hasta <> gen.fn_last_DAY(@fecha_hasta)
   SET @fecha_hasta = gen.fn_last_DAY(DATEADD(mm, -1, @fecha_hasta))

SET @fecha_desde = CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, MONTH(@fecha_hasta)) + '/' + CONVERT(VARCHAR, YEAR(@fecha_hasta)))

IF @fecha_desde < @fecha_ingreso
   SET @fecha_desde = @fecha_ingreso

IF DATEPART(DD, @fecha_desde) <> 1
   SET @fecha_desde = gen.fn_last_DAY(@fecha_desde) + 1

--PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
--PRINT 'Código Alternativo Empleado: ' + ISNULL(@codexp_alternativo, '')
--PRINT 'Fecha de Ingreso: ' + ISNULL(CONVERT(VARCHAR, @fecha_ingreso, 103), '')
--PRINT 'Fecha Retiro: ' + ISNULL(CONVERT(VARCHAR, @fecha, 103), '')
--PRINT 'Moneda: ' + ISNULL(@codmon, '')
--PRINT 'País: ' + ISNULL(@codpai, '')
--PRINT 'Compañía: ' + ISNULL(CONVERT(VARCHAR, @codcia), '')
--PRINT 'Divisor: ' + ISNULL(CONVERT(VARCHAR, @divisor), '')
--PRINT 'Tasa Cambio: ' + ISNULL(CONVERT(VARCHAR, @tasa_cambio), '')
--PRINT 'Rubro de Salario: ' + ISNULL(CONVERT(VARCHAR, @codrsa_salario), '')
--PRINT ''
   
---------------------------------------------------
--        obtiene ingresos del agrupador         --
---------------------------------------------------
WHILE @meses_promedio < 6 AND @fecha_desde > @fecha_ingreso
BEGIN
	set @incluye_promedio = 0
	SET @valor = 0.00
	SET @valor_maternidad = 0.00
	SET @valor_total = 0.00
	SET @dias_trabajados = gen.fn_diff_two_dates_30(@fecha_desde, @fecha_hasta)
	SET @dias_totales = @dias_totales + @dias_trabajados

	SELECT @valor = ROUND(SUM(ISNULL(inn_valor, 0.00)), 2) 
	FROM sal.inn_ingresos 
		JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
	WHERE inn_codemp = @codemp
		AND ppl_estado = 'Autorizado'
		AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio))
			BETWEEN @fecha_desde AND @fecha_hasta
		AND inn_codtig IN (SELECT iag_codtig
							FROM sal.iag_ingresos_agrupador
							WHERE iag_codagr = @codagr)

	SELECT @valor_maternidad = ROUND(SUM(pie_valor_a_pagar + pie_valor_a_descontar), 2)
	FROM acc.pie_periodos_incapacidad 
		JOIN acc.ixe_incapacidades ON pie_codixe = ixe_codigo
		JOIN sal.ppl_periodos_planilla ON pie_codppl = ppl_codigo
		JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
	WHERE ixe_codemp = @codemp
		AND ixe_codrin = @codrin_maternidad
		AND pie_planilla_autorizada = 1
		AND ppl_estado = 'Autorizado'
		AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio))
			BETWEEN @fecha_desde AND @fecha_hasta

	SET @valor_total = ISNULL(@valor, 0.00) + ISNULL(@valor_maternidad, 0.00)

	--PRINT 'Dias Trabajados: ' + ISNULL(CONVERT(VARCHAR, @dias_trabajados), '')	
	--PRINT 'Fecha Desde: ' + ISNULL(CONVERT(VARCHAR, @fecha_desde, 103), '')	
	--PRINT 'Fecha Hasta: ' + ISNULL(CONVERT(VARCHAR, @fecha_hasta, 103), '')	

	-- Sino existe ninguna incapacidad, amonestación o tiempo no trabajado en el mes, si se considera en el promedio
	IF NOT EXISTS (SELECT NULL
				   FROM acc.ixe_incapacidades
				   WHERE ixe_codemp = @codemp
					   AND ixe_estado = 'Autorizado'
					   AND ((ixe_inicio < @fecha_desde AND ixe_final BETWEEN @fecha_desde AND @fecha_hasta)
						   OR (ixe_inicio BETWEEN @fecha_desde AND @fecha_hasta AND ISNULL(ixe_final, DATEADD(DD, 1, @fecha_hasta)) > @fecha_hasta)
						   OR (ixe_inicio >= @fecha_desde AND ixe_final <= @fecha_hasta)
						   OR (ixe_inicio < @fecha_hasta AND ISNULL(ixe_final, DATEADD(DD, 1, @fecha_hasta)) > @fecha_hasta)))
		AND NOT EXISTS (SELECT NULL
						FROM acc.amo_amonestaciones
						WHERE amo_codemp = @codemp	
							AND amo_estado = 'Autorizado'
							AND amo_aplica_suspension = 1
						    AND ((amo_inicio_suspension < @fecha_desde AND amo_final_suspension BETWEEN @fecha_desde AND @fecha_hasta)
							    OR (amo_inicio_suspension BETWEEN @fecha_desde AND @fecha_hasta AND ISNULL(amo_final_suspension, DATEADD(DD, 1, @fecha_hasta)) > @fecha_hasta)
							    OR (amo_inicio_suspension >= @fecha_desde AND amo_final_suspension <= @fecha_hasta)
								OR (amo_inicio_suspension < @fecha_hasta AND ISNULL(amo_final_suspension, DATEADD(DD, 1, @fecha_hasta)) > @fecha_hasta)))
		AND NOT EXISTS (SELECT NULL
						FROM sal.tnn_tiempos_no_trabajados
							JOIN sal.tnt_tipos_tiempo_no_trabajado ON tnn_codtnt = tnt_codigo
						WHERE tnn_codemp = @codemp	
							AND tnn_estado = 'Autorizado'
							AND tnt_goce_sueldo = 0
							AND ((tnn_fecha_del >= tnn_fecha_del AND tnn_fecha_al <= tnn_fecha_al)
								OR (tnn_fecha_del < tnn_fecha_del AND tnn_fecha_al >= tnn_fecha_del AND tnn_fecha_al <= tnn_fecha_al)
								OR (tnn_fecha_del >= tnn_fecha_del AND tnn_fecha_del <= tnn_fecha_al AND tnn_fecha_al > tnn_fecha_al)
								OR (tnn_fecha_del < tnn_fecha_del AND tnn_fecha_al > tnn_fecha_al)))
	BEGIN
		IF @valor_total > 0.00
		BEGIN
			SET @total_ingresos = @total_ingresos + @valor_total
			SET @meses_promedio = @meses_promedio + 1
			SET @incluye_promedio = 1
		END

		IF @meses_promedio = 3
			SET @total_ingresos_parcial = @total_ingresos
	
		--PRINT 'Meses Promedio: ' + ISNULL(CONVERT(VARCHAR, @meses_promedio), '')
		--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor, 103), '')	
		--PRINT 'Valor Maternidad: ' + ISNULL(CONVERT(VARCHAR, @valor_maternidad), '')	
		--PRINT 'Valor Total: ' + ISNULL(CONVERT(VARCHAR, @valor_total), '')	
		--PRINT ''
	END			

	INSERT INTO cr.hli_historico_liquidaciones (
		hli_codemp,
		hli_fecha_retiro,
		hli_codtig,
		hli_numero,
		hli_fecha_ingreso,
		hli_codmon,
		hli_fecha_ini,
		hli_fecha_fin,
		hli_salario,
		hli_variable,
		hli_dias_pago,
		hli_periodo)
	VALUES (@codemp,
		@fecha,
		@codtig,
		CASE WHEN @incluye_promedio = 1 THEN @meses_promedio ELSE NULL END,
		@fecha_ingreso,
		@codmon,
		@fecha_desde,
		@fecha_hasta,
		@salario,
		@valor_total,
		@dias_trabajados,
		0)
	
	SET @fecha_desde = DATEADD(MM, -1, @fecha_desde)
	SET @fecha_hasta = gen.fn_last_day(@fecha_desde)						
END

IF @meses_promedio = 0.00
	SET @meses_promedio = 1.00

IF @meses_promedio < 6.00 AND @meses_promedio > 3.00
BEGIN
	SET @total_ingresos = @total_ingresos_parcial
	SET @meses_promedio = 3.00

	DELETE cr.hli_historico_liquidaciones
	WHERE hli_codemp = @codemp
		AND hli_fecha_retiro = @fecha
		AND hli_codtig = @codtig
		AND hli_numero > 3
END

SET @promedio_mensual = ISNULL(ROUND(@total_ingresos / @meses_promedio, 2), 0.00)

IF @promedio_mensual < @salario_minimo
	SET @valor_base = @salario_minimo
ELSE
	SET @valor_base = @promedio_mensual

SET @promedio_diario = @valor_base / @divisor

SET @promedio = ISNULL(@promedio_diario, 0.00)

UPDATE cr.hli_historico_liquidaciones
SET hli_base_calculo = @total_ingresos,
	hli_dias_totales = @dias_totales,
	hli_meses_promedio = @meses_promedio,
	hli_promedio_mensual = @promedio_mensual,
	hli_promedio_diario = @promedio_diario,
	hli_salario_minimo = @salario_minimo,
	hli_salario_minimo_diario = @salario_minimo_diario,
	hli_tasa_cambio = @tasa_cambio
WHERE hli_codemp = @codemp
	AND hli_fecha_retiro = @fecha
	AND hli_codtig = @codtig

--PRINT 'Meses Promedio: ' + ISNULL(CONVERT(VARCHAR, @meses_promedio), '')	
--PRINT 'Total Ingresos: ' + ISNULL(CONVERT(VARCHAR, @total_ingresos), '')	
--PRINT 'Promedio Mensual: ' + ISNULL(CONVERT(VARCHAR, @promedio_mensual), '')	
--PRINT 'Salario Minimo: ' + ISNULL(CONVERT(VARCHAR, @salario_minimo), '')	
--PRINT 'Salario Minimo Diario: ' + ISNULL(CONVERT(VARCHAR, @salario_minimo_diario), '')	
--PRINT 'Valor Base: ' + ISNULL(CONVERT(VARCHAR, @valor_base), '')	
--PRINT 'Promedio Diario: ' + ISNULL(CONVERT(VARCHAR, @promedio), '')	
--PRINT ''

RETURN