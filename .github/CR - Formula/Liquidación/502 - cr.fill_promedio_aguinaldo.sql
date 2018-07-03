IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.fill_promedio_aguinaldo'))
BEGIN
	DROP PROCEDURE cr.fill_promedio_aguinaldo
END

GO

------------------------------------------------------------
-- evolution costa rica standard                           --
-- llena el detalle del calculo de cada uno de los rubros --
-- principales de la liquidacion, para poder imprimir la  --       
-- hoja de liquidacion                                    --                     
------------------------------------------------------------
--EXEC cr.fill_promedio_aguinaldo  1859, 53, '20141201', '20150306', '20151130', 14, 'CRC'
CREATE PROCEDURE cr.fill_promedio_aguinaldo (
	@codemp INT,
    @codagr INT = 0, -- agrupador para los ingresos variables
    @fecha_inicio DATETIME, -- fecha de inicio promedio
    @fecha_fin DATETIME, -- fecha de fin de promedio
	@fecha_fin_planilla DATETIME, -- fecha en que finaliza la planilla
    @codtig INT, -- tipo del ingreso que se esta calculando aguinaldo, bono 14, indem, vacaciones
	@codmon VARCHAR(3) -- Moneda
)

-------------------------------------------------------------------------------
--  obtiene el promedio de los x meses completos atras de la fecha recibida  --
--  si la fecha recibida no es fin de mes la ajusta al fin de mes anterior   --
--  se ajusta a la fecha de ingreso si esta fuera mayor a la fecha de inicio --
--  del promedio, y realiza el promedio entre estos meses                    --
-------------------------------------------------------------------------------

AS

DECLARE @codpai VARCHAR(2),
	@fecha_desde DATETIME,
	@fecha_hasta DATETIME,
	@fecha_ingreso DATETIME,
	@fecha_desde_aux DATETIME,
	@fecha_hasta_aux DATETIME,
	@total_ingresos MONEY = 0,
	@total_maternidad MONEY,
	@otros_ingresos_liq MONEY,
	@total MONEY,
	@codrin_maternidad INT,
	@dias_trabajados INT = 0,
	@dias_promedio INT = 0,
	@numero INT = 0

-----------------------------------------
-- obtiene compania y fecha de ingreso --
-----------------------------------------  
SELECT @codpai = cia_codpai,
	@fecha_ingreso = emp_fecha_ingreso
FROM exp.emp_empleos
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
WHERE emp_codigo = @codemp
    
SET @codrin_maternidad = gen.get_valor_parametro_int('CodigoRIN_Maternidad', @codpai, NULL, NULL, NULL)

--------------------------------------
--        limpia el detalle         --
--------------------------------------  
DELETE cr.hli_historico_liquidaciones
WHERE hli_codemp = @codemp
	AND hli_fecha_retiro = @fecha_fin
	AND hli_codtig = @codtig

SET @fecha_desde = @fecha_inicio
SET @fecha_hasta = @fecha_fin_planilla
   
-- calcula nuevamente los meses promedio por el ajuste a meses completos

SET @dias_promedio = gen.fn_diff_two_dates_30(@fecha_desde, @fecha_hasta)

---------------------------------------------------
--        obtiene ingresos del agrupador         --
---------------------------------------------------
SET @fecha_desde_aux = @fecha_desde
SET @numero  = 0

WHILE @fecha_desde_aux < @fecha_hasta
BEGIN

	SET @numero = @numero + 1

	SET @fecha_hasta_aux = gen.fn_last_DAY(@fecha_desde_aux)

	IF @fecha_hasta_aux > @fecha_hasta
		SET @fecha_hasta_aux = @fecha_hasta

	SET @dias_trabajados = DATEDIFF(DD, @fecha_desde_aux, @fecha_hasta_aux) + 1

	SELECT @total_ingresos = ROUND(SUM(inn_valor), 2) 
	FROM sal.inn_ingresos 
		JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
	WHERE inn_codemp = @codemp
		AND ppl_estado = 'Autorizado'
		AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio))
			BETWEEN @fecha_desde_aux AND @fecha_hasta_aux
		AND inn_codtig IN (SELECT iag_codtig
						   FROM sal.iag_ingresos_agrupador
						   WHERE iag_codagr = @codagr)

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
			BETWEEN @fecha_desde_aux AND @fecha_hasta_aux

	IF @fecha_fin BETWEEN @fecha_desde_aux AND @fecha_hasta_aux
	BEGIN
		SELECT @otros_ingresos_liq = ROUND(SUM(dli_valor), 2)
		FROM #dli_detliq_ingresos
		WHERE dli_codtig IN (SELECT iag_codtig
							 FROM sal.iag_ingresos_agrupador
							 WHERE iag_codagr = @codagr)
	END

	SET @total = ISNULL(@total_ingresos, 0.00) + ISNULL(@total_maternidad, 0.00) + ISNULL(@otros_ingresos_liq, 0.00)

	IF @total > 0.00
	BEGIN
		INSERT INTO cr.hli_historico_liquidaciones (hli_codemp,
			hli_fecha_retiro,
			hli_codtig,
			hli_numero,
			hli_fecha_ingreso,
			hli_codmon,
			hli_base_calculo,
			hli_dias_totales,
			hli_dias_pago,
			hli_fecha_ini,
			hli_fecha_fin,
			hli_salario,
			hli_variable,
			hli_periodo)
		VALUES (@codemp,
			@fecha_fin,
			@codtig,
			@numero,
			@fecha_ingreso,
			@codmon,
			@total,
			@dias_trabajados,
			@dias_trabajados,
			@fecha_desde_aux,
			@fecha_hasta_aux,
			NULL,
			@total,
			0)
	END

	SET @fecha_desde_aux = DATEADD(DD, 1, @fecha_hasta_aux)

END