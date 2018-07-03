IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_INC_GeneraPeriodosIncapacidad'))
BEGIN
	DROP PROCEDURE cr.GenPla_INC_GeneraPeriodosIncapacidad
END

GO

--EXEC cr.GenPla_INC_GeneraPeriodosIncapacidad null, 104, 'admin'
CREATE PROCEDURE cr.GenPla_INC_GeneraPeriodosIncapacidad (	
	@sessionId uniqueidentifier = null,
    @codppl int,
    @userName varchar(100) = null
) 

AS

/*--------------------------------------------------
  01.- Se procesaran las incapacidades cuya fecha de inicio y fin estén dentro del periodo de planilla.
  02.- La incapacidad se tiene que poner como Finalizada en la autorizacion de la planilla y
       no en la finalizacion de la planilla, porque si no ya no se calcularan nuevamente
  03.- Genera ingresos y descuentos en la planilla dependiendo de la configuraicón de los riesgos de 
	   incapacidad, el porcentaje de descuento y el porcentaje de subsidio (ingresos).
  04.- Tomar en cuenta que cuando se ingresen prorrogas, se debe de asignar el riesgo como Prorroga,
       mas que todo cuando el riesgo es por Accidente o enfermedad comun
  05.- Calcula el salario normal correspondiente a los dias de incapacidad (calendario o comercial)
       
  -------------------------------------------------- */

SET DATEFORMAT DMY
SET DATEFIRST 1
SET NOCOUNT ON

--------------------------------
--  declaracion de variables  --
--------------------------------
DECLARE @codpai VARCHAR(2),
	@codcia INT,
	@codtpl INT,
	@codtpl_visual VARCHAR(3),
	@codemp INT,								
	@codixe INT,
	@codagr INT,
	@codfin INT,
	@codfin_real INT,
	@coddin INT,
	@salario MONEY, 
	@incap_del DATETIME,						        
	@incap_al DATETIME,						    
	@dias_aplicar REAL,					        
	@dias_aplicados REAL,
	@dias_aplicados_anteriores REAL,
	@dias_incap REAL,
	@codrin INT,
	@codrin_maternidad INT,
	@pin_desde INT,							        
	@pin_hasta INT,						        
	@pin_porcentaje_descuento REAL,
	@pin_porcentaje_ingreso REAL,							
	@pie_valor_a_pagar MONEY,
	@pie_valor_a_descontar MONEY,
	@utiliza_mes_comercial bit,			
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@ppl_fecha_pago DATETIME,
	@ppl_mes INT,
	@ppl_anio INT,
	@codrsa_salario INT,
	@codmon VARCHAR(3),
	@utiliza_promedio BIT,
	@total_ingresos MONEY,
	@meses_promedio INT,
	@fecha_inicio_promedio DATETIME,
	@fecha_fin_promedio DATETIME,
	@valor_promedio MONEY,
	@salario_minimo MONEY,
	@salario_minimo_diario MONEY,
	@valor MONEY,
	@tasa_cambio REAL,
	@dias_domingo REAL,
	@divisor REAL,
	@horas_dia REAL,
	@fin_fecha_inicial_ult DATETIME,
	@fin_fecha_final_ult DATETIME,
	@fin_fecha_inicial DATETIME,
	@fin_fecha_final DATETIME,
	@fin_fecha_inicial_act DATETIME,
	@fin_fecha_final_act DATETIME,
	@fin_dias_act REAL,
	@emp_fecha_ingreso DATETIME

---------------------------------------------------
--                  limpieza                     --
---------------------------------------------------

-- elimina el detalle de la tabla de aplicaciones

DELETE acc.pie_periodos_incapacidad
WHERE pie_codppl = @codppl
	AND pie_planilla_autorizada = 0

DELETE cr.din_detalle_incapacidad
WHERE din_planilla_autorizada = 0

---------------------------------------------------
--     obtiene informacion de la planilla        --
---------------------------------------------------
SELECT @codpai = cia_codpai,
	@codcia = tpl_codcia,
	@codtpl = tpl_codigo,
	@codtpl_visual = tpl_codigo_visual,
	@ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin,
	@ppl_fecha_pago = ppl_fecha_pago,
	@codmon = tpl_codmon,
	@ppl_mes = ppl_mes,
	@ppl_anio = ppl_anio
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE ppl_codigo = @codppl 

SELECT @codagr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoIncapacidades'

IF @codmon = 'USD'
	SET @tasa_cambio = ISNULL(gen.get_tasa_cambio('CRC', @ppl_fecha_pago), 1.00)
ELSE	
	SET @tasa_cambio = 1.00

SET @codrsa_salario = ISNULL(gen.get_valor_parametro_int('CodigoRSA_Salario', NULL, NULL, @codcia, NULL), 0.00)
SET @codrin_maternidad = ISNULL(gen.get_valor_parametro_int('CodigoRIN_Maternidad', @codpai, NULL, NULL, NULL), 0.00)
SET @utiliza_mes_comercial = gen.get_valor_parametro_bit('IncapacidadUtilizaMesComercial', NULL, NULL, @codcia, NULL)
SET @salario_minimo_diario = gen.get_valor_parametro_float('SalarioMinimoDiario', @codpai, NULL, NULL, NULL) / @tasa_cambio
SET @horas_dia = ISNULL(gen.get_valor_parametro_float('HorasLaboralesPorDia', @codpai, NULL, NULL, NULL), 0.00)

SET @divisor = 30.00

EXEC cr.inc_act_periodo_incapacidad @sessionId, @codppl, @userName

---------------------------------------------------
--             CURSOR de incapacidades           --
---------------------------------------------------
DECLARE incapacidades CURSOR FOR
SELECT ixe_codigo, 
	ixe_codemp,
	emp_fecha_ingreso,
	CASE WHEN din_fecha_inicial < @ppl_fecha_ini THEN @ppl_fecha_ini ELSE din_fecha_inicial END ixe_inicio, 
	CASE WHEN ISNULL(din_fecha_final, DATEADD(DD, 1, @ppl_fecha_fin)) > @ppl_fecha_fin THEN @ppl_fecha_fin ELSE din_fecha_final END ixe_final,
	ixe_codrin,
	(SELECT ISNULL(SUM(ese_valor),0) * (CASE WHEN ese_exp_valor = 'Diario' THEN 30.00 ELSE 1.00 END)
	 FROM exp.ese_estructura_sal_empleos
	 WHERE ese_codemp = emp_codigo
		AND ese_estado = 'V'
		AND ese_codrsa = @codrsa_salario
	 GROUP BY ese_exp_valor) salario,
	gen.get_pb_field_data_bit(rin_property_bag_data, 'UtilizaPromedio') ixe_utiliza_promedio,
	din_codfin,
	din_codigo
FROM acc.ixe_incapacidades
	JOIN exp.emp_empleos ON ixe_codemp = emp_codigo
	JOIN acc.rin_riesgos_incapacidades ON ixe_codrin = rin_codigo
	JOIN cr.din_detalle_incapacidad ON ixe_codigo = din_codixe
WHERE emp_codtpl = @codtpl
	AND (emp_estado = 'A'
		OR (emp_estado = 'R' AND emp_fecha_retiro BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin))
	AND ixe_estado <> 'Pendiente'
	AND ((ixe_inicio < @ppl_fecha_ini AND ixe_final BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin)
		OR (ixe_inicio BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin AND ISNULL(ixe_final, DATEADD(DD, 1, @ppl_fecha_fin)) > @ppl_fecha_fin)
		OR (ixe_inicio >= @ppl_fecha_ini AND ixe_final <= @ppl_fecha_fin)
		OR (ixe_inicio < @ppl_fecha_fin AND ISNULL(ixe_final, DATEADD(DD, 1, @ppl_fecha_fin)) > @ppl_fecha_fin))
	AND sal.empleado_en_gen_planilla(@sessionId, emp_codigo) = 1
ORDER BY ixe_codemp, ixe_inicio

OPEN incapacidades

FETCH NEXT FROM incapacidades INTO @codixe, @codemp, @emp_fecha_ingreso, @incap_del, @incap_al, @codrin, @salario, @utiliza_promedio, @codfin, @coddin

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @dias_domingo = 0.00
	SET @dias_aplicados = 0.00
	SET @dias_aplicados_anteriores = 0.00

	SELECT @dias_aplicados = SUM(pie_dias)
	FROM acc.pie_periodos_incapacidad
	WHERE pie_codixe = @codixe

	IF @codtpl_visual = '4'
	BEGIN
		SET @dias_domingo = gen.cuenta_tipo_dia(7, @incap_del, @incap_al)
		SET @divisor = 26.00
	END

	SET @salario_minimo = @salario_minimo_diario * @divisor

    IF @incap_del > @incap_al
		SET @dias_aplicar = 0
	ELSE IF @utiliza_mes_comercial = 0
	    SET @dias_aplicar = ABS(DATEDIFF(DD, @incap_del, @incap_al)) + 1 - @dias_domingo
	ELSE
		SET @dias_aplicar = gen.fn_diff_two_dates_30(@incap_del, @incap_al) - @dias_domingo

	SET @dias_incap = 0

	IF @codrin = @codrin_maternidad 
	BEGIN
		IF @codtpl_visual = '4'
			SET @valor = @salario * @horas_dia
		ELSE
			SET @valor = @salario / @divisor
	END
	ELSE 
	BEGIN
		SET @meses_promedio = gen.get_valor_parametro_int('IncapacidadMesesPromedio', @codpai, NULL, NULL, NULL)

		SET @fecha_fin_promedio = CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, @ppl_mes) + '/' + CONVERT(VARCHAR, @ppl_anio))
		SET @fecha_inicio_promedio = DATEADD(MM, -@meses_promedio, @fecha_fin_promedio)
		SET @fecha_fin_promedio = DATEADD(DD, -1, @fecha_fin_promedio)

		IF ISNULL(@meses_promedio, 0) = 0
			SET @meses_promedio = 1

		--IF @emp_fecha_ingreso > @fecha_inicio_promedio
		--BEGIN
		--	IF DAY(@emp_fecha_ingreso) = 1
		--		SET @fecha_inicio_promedio = @emp_fecha_ingreso
		--	ELSE
		--		SET @fecha_inicio_promedio = DATEADD(DD, 1, gen.fn_last_day(@emp_fecha_ingreso))

		--	SET @meses_promedio = DATEDIFF(MM, @fecha_inicio_promedio, @fecha_fin_promedio) + 1
		--END

		SELECT @total_ingresos = SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		WHERE inn_codemp = @codemp
			AND ppl_estado = 'Autorizado'
			AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio))
				BETWEEN @fecha_inicio_promedio AND @fecha_fin_promedio
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr)

		IF ISNULL(@total_ingresos, 0.00) = 0
			SET @valor_promedio = @salario
		ELSE
			SET @valor_promedio = ISNULL(@total_ingresos, 0.00) / @meses_promedio

		IF @valor_promedio < @salario_minimo
			SET @valor = @salario_minimo / @divisor
		ELSE 
			SET @valor = @valor_promedio / @divisor
	END

	UPDATE acc.fin_fondos_incapacidad
	SET fin_dias_incapacitado = ISNULL((SELECT SUM(din_dias)
										FROM cr.din_detalle_incapacidad
										WHERE fin_codigo = din_codfin), 0.00)
	WHERE fin_codigo = @codfin

	SELECT @dias_aplicados_anteriores = fin_dias_incapacitado
	FROM acc.fin_fondos_incapacidad
	WHERE fin_codigo = @codfin

	--PRINT ''
	--PRINT 'Código de Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
	--PRINT 'Código del riesgo: ' + ISNULL(CONVERT(VARCHAR, @codrin), '')
	--PRINT 'Fecha de Ingreso: ' + ISNULL(CONVERT(VARCHAR, @emp_fecha_ingreso, 103), '')
	--PRINT 'Fecha de Inicio de Incapacidad: ' + ISNULL(CONVERT(VARCHAR, @incap_del, 103), '')
	--PRINT 'Fecha de Fin de Incapacidad: ' + ISNULL(CONVERT(VARCHAR, @incap_al, 103), '')
	--PRINT 'Fecha de Inicio de Promedio: ' + ISNULL(CONVERT(VARCHAR, @fecha_inicio_promedio, 103), '')
	--PRINT 'Fecha de Fin de Promedio: ' + ISNULL(CONVERT(VARCHAR, @fecha_fin_promedio, 103), '')
	--PRINT 'Meses Promedio: ' + ISNULL(CONVERT(VARCHAR, @meses_promedio), '')
	--PRINT 'Total de ingresos: ' + ISNULL(CONVERT(VARCHAR, @total_ingresos), '')
	--PRINT 'Valor promedio: ' + ISNULL(CONVERT(VARCHAR, @valor_promedio), '')
	--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor), '')
	--PRINT 'Días Aplicados Anteriores: ' + ISNULL(CONVERT(VARCHAR, @dias_aplicados_anteriores), '')
	--PRINT 'Días Aplicados: ' + ISNULL(CONVERT(VARCHAR, @dias_aplicados), '')
	--PRINT 'Días a Aplicar: ' + ISNULL(CONVERT(VARCHAR, @dias_aplicar), '')
	--PRINT 'Salario Diario: ' + ISNULL(CONVERT(VARCHAR, @salario), '')

	-----------------------------------------------------
	----      CURSOR de parametros de incapacidades    --
	-----------------------------------------------------
	DECLARE rangos CURSOR FOR
	SELECT pin_inicio + ISNULL(@dias_aplicados, 0.00) + ISNULL(@dias_aplicados_anteriores, 0.00) pin_inicio, 
		pin_final, 
		ISNULL(pin_por_descuento, 0.00) pin_porcentaje,
		ISNULL(pin_por_subsidio_sal_maximo, 0.00) pin_por_sal_maximo
	FROM acc.pin_parametros_incapacidad
	WHERE pin_codcia = @codcia 
		AND pin_codrin = @codrin
		AND pin_final > ISNULL(@dias_aplicados, 0.00) + ISNULL(@dias_aplicados_anteriores, 0.00)
	ORDER BY pin_inicio

	OPEN rangos
   
	FETCH NEXT FROM rangos INTO @pin_desde, @pin_hasta, @pin_porcentaje_descuento, @pin_porcentaje_ingreso
   
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @pie_valor_a_descontar = 0.00
		SET @pie_valor_a_pagar = 0.00
		SET @codfin_real = NULL

		---	si dias aplicar es menor a 0 entoces detiene el calculo
		IF @dias_aplicar <= 0 BREAK

		IF @pin_hasta > @pin_desde + ISNULL(@dias_aplicar, 0.00)
			SET @pin_hasta = (@pin_desde + @dias_aplicar - 1)
	 
		SET @dias_incap = ISNULL((@pin_hasta - @pin_desde) + 1,0)
		
		IF @dias_incap > @dias_aplicar
			SET @dias_incap = @dias_aplicar	 

		IF @dias_incap >= 31 AND @utiliza_mes_comercial = 1
			SET @dias_incap = 30
		---------------------------------------------------
		--                   calculo de pago             --
		---------------------------------------------------		
		
		IF @pin_porcentaje_descuento > 0
			SET @pie_valor_a_descontar = ROUND(@valor * @pin_porcentaje_descuento / 100.00 * @dias_incap, 2)
		
		IF @pin_porcentaje_ingreso > 0
		BEGIN
			SET @pie_valor_a_pagar = ROUND(@valor * @pin_porcentaje_ingreso / 100.00 * @dias_incap, 2)

			UPDATE cr.din_detalle_incapacidad
			SET din_dias = din_dias + @dias_incap
			WHERE din_codigo = @coddin

			UPDATE acc.fin_fondos_incapacidad
			SET fin_dias_incapacitado = fin_dias_incapacitado + @dias_incap
			WHERE fin_codigo = @codfin

			SET @codfin_real = @codfin
		END

		-------------------------------------------------------
		----               crea los registros                --
		-------------------------------------------------------
		INSERT INTO acc.pie_periodos_incapacidad (pie_codixe, 
			pie_inicio, 
			pie_final, 
			pie_dias, 
			pie_codppl, 
			pie_aplicado_planilla, 
			pie_salario_diario, 
			pie_salario_hora,
			pie_valor_total, 
			pie_valor_a_pagar, 
			pie_valor_a_descontar,
			pie_ajuste_sobre_sal_maximo, 
			pie_codmon,
			pie_codfin)
		VALUES (@codixe, 
			@incap_del, 
			DATEADD(DD, @dias_incap -1, @incap_del), 
			@dias_incap, 
			@codppl, 
			0, 
			ISNULL(@valor, 0.00),
			0.00, 
			ISNULL(@total_ingresos, 0.00),
			ISNULL(@pie_valor_a_pagar, 0.00), 
			ISNULL(@pie_valor_a_descontar, 0.00),
			0.00, 
			@codmon,
			@codfin_real)

		--PRINT 'Rango Desde: ' + ISNULL(CONVERT(VARCHAR, @pin_desde), '')
		--PRINT 'Rango Hasta: ' + ISNULL(CONVERT(VARCHAR, @pin_hasta), '')
		--PRINT 'Porcentaje de Descuento: ' + ISNULL(CONVERT(VARCHAR, @pin_porcentaje_descuento), '')
		--PRINT 'Porcentaje de Ingreso: ' + ISNULL(CONVERT(VARCHAR, @pin_porcentaje_ingreso), '')
		--PRINT 'Valor a pagar: ' + ISNULL(CONVERT(VARCHAR, @pie_valor_a_pagar), '')
		--PRINT 'Valor a descontar: ' + ISNULL(CONVERT(VARCHAR, @pie_valor_a_descontar), '')
	
		SET @dias_aplicar = @dias_aplicar - @dias_incap
		SET @incap_del = DATEADD(DD, @dias_incap, @incap_del)
		
		FETCH NEXT FROM rangos INTO @pin_desde, @pin_hasta, @pin_porcentaje_descuento, @pin_porcentaje_ingreso
	END
	CLOSE rangos
	DEALLOCATE rangos

	FETCH NEXT FROM incapacidades INTO @codixe, @codemp, @emp_fecha_ingreso, @incap_del, @incap_al, @codrin, @salario, @utiliza_promedio, @codfin, @coddin
END

CLOSE incapacidades
DEALLOCATE incapacidades