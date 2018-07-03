IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_Calcula_Vac_Semanal'))
BEGIN
	DROP PROCEDURE cr.GenPla_Calcula_Vac_Semanal
END

GO

--EXEC cr.GenPla_Calcula_Vac_Semanal null, 103, 'admin'
CREATE PROCEDURE cr.GenPla_Calcula_Vac_Semanal (	
	@sessionid UNIQUEIDENTIFIER = NULL,
    @codppl INT,
    @username VARCHAR(100) = NULL
) 

AS

-------------------------------------------------------------------------------------------------------
-- evolution                                                                                         --
-- genera el detalle de los pagos de anticipos de vacaciones, quincena por quincena                  --
--                                                                                                   --
--  01.- se procesaran las vacaciones de todas las tomas correspondientes al proximo periodo         --
--       de planilla                                                                                 --
--  02.- se calculan tomando en cuenta los ingresos promedio de meses completos para atras el numero --
--       de meses que se indique                                                                     --
--  03.- si la empresa paga bono vacacional, se debe de crear el parametro tablabonovacacional tipo  --
--       rango dependiendo de la antiguedad o si es un solo valor fijo                               --
-------------------------------------------------------------------------------------------------------

SET DATEFORMAT DMY
SET DATEFIRST 1
SET NOCOUNT ON

DECLARE @codpai VARCHAR(2),
	@codcia INT,
	@codtpl INT,
	@codtpl_visual VARCHAR(3),
	@codrsa_salario INT,
	@codagr INT,
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@codemp INT,
	@coddva INT,
	@codppl_anterior INT,
	@dva_desde DATETIME,
	@dva_hasta DATETIME,
	@horas_por_dia REAL,
	@emp_salario MONEY,
	@meses_promedio INT,
	@fecha_inicio_promedio DATETIME,
	@fecha_fin_promedio DATETIME,
	@total_ingresos MONEY,
	@valor_base MONEY,
	@valor_promedio MONEY,
	@valor_promedio_diario MONEY,
	@valor_semana MONEY,
	@valor_semana_diario MONEY,
	@salario_minimo MONEY,
	@salario_minimo_diario MONEY,
	@valor MONEY,
	@divisor REAL,
	@dias_semana REAL,
	@unidad_tiempo VARCHAR(15),
	@valor_vacaciones MONEY,
	@dias_vacaciones REAL,
	@horas_vacaciones REAL,
	@tiempo REAL

SELECT @codpai = cia_codpai,
	@codcia = tpl_codcia,
	@codtpl = ppl_codtpl,
	@codtpl_visual = tpl_codigo_visual,
	@ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE ppl_codigo = @codppl

SELECT @codppl_anterior = ppl_codigo
FROM sal.ppl_periodos_planilla p1
WHERE ppl_codtpl = @codtpl
	AND ppl_estado = 'Autorizado'
	AND ppl_fecha_fin = DATEADD(DD, -1, @ppl_fecha_ini)

SELECT @codagr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoVacaciones'

SET @divisor = 26.00
SET @unidad_tiempo = 'Horas'

SET @codrsa_salario = ISNULL(gen.get_valor_parametro_INT ('CodigoRSA_Salario', NULL, NULL, @codcia, NULL), 0)
SET @meses_promedio = gen.get_valor_parametro_int('VacacionMesesPromedio', @codpai, NULL, NULL, NULL)
SET @dias_semana = gen.get_valor_parametro_float('VacacionDiasSemana', @codpai, NULL, NULL, NULL)
SET @salario_minimo = ISNULL(gen.get_valor_parametro_float('SalarioMinimo', @codpai, NULL, NULL, NULL), 0.00)
SET @horas_por_dia = ISNULL(gen.get_valor_parametro_float('HorasLaboralesPorDia', @codpai, NULL, NULL, NULL), 0.00)

SET @salario_minimo_diario = ISNULL(@salario_minimo / @divisor, 0.00)

SET @fecha_fin_promedio = CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, MONTH(@ppl_fecha_ini)) + '/' + CONVERT(VARCHAR, YEAR(@ppl_fecha_ini)))
SET @fecha_inicio_promedio = DATEADD(MM, -@meses_promedio, @fecha_fin_promedio)
SET @fecha_fin_promedio = DATEADD(DD, -1, @fecha_fin_promedio)

IF ISNULL(@meses_promedio, 0) = 0
	SET @meses_promedio = 1

DELETE
FROM cr.vca_vacaciones_calculadas
WHERE vca_codppl = @codppl

UPDATE acc.dva_dias_vacacion
SET dva_codppl = NULL,
    dva_aplicado_planilla = 0,
    dva_pagadas = 0
WHERE dva_codppl = @codppl

DECLARE vacaciones CURSOR FOR
SELECT emp_codigo,
	dva_codigo,
	dva_desde,
	dva_hasta,
	(SELECT ISNULL(SUM(ese_valor),0) * 
		(CASE 
			WHEN ese_exp_valor = 'Mensual' THEN 1.00/240.00
			WHEN ese_exp_valor = 'Diario' THEN 1.00/8.00
			ELSE 1.00 
		 END)
	 FROM exp.ese_estructura_sal_empleos
	 WHERE ese_codemp = emp_codigo
		AND ese_estado = 'V'
		AND ese_codrsa = @codrsa_salario
	 GROUP BY ese_exp_valor) emp_salario
FROM exp.emp_empleos
	JOIN acc.vac_vacaciones ON vac_codemp = emp_codigo
	JOIN acc.dva_dias_vacacion ON dva_codvac = vac_codigo
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = @codcia
	AND (emp_estado = 'A'
		OR (emp_estado = 'R' AND emp_fecha_retiro BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin))
	AND emp_codtpl = @codtpl 
	AND dva_aplicado_planilla = 0
	AND dva_desde >= @ppl_fecha_ini
	AND sal.empleado_en_gen_planilla(@sessionid, emp_codigo) = 1
ORDER BY  emp_codigo, dva_desde   

OPEN vacaciones

FETCH NEXT FROM vacaciones INTO @codemp, @coddva, @dva_desde, @dva_hasta, @emp_salario

-- Recorre cada una de las vacaciones de los empleados
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @valor_base = 0.00
	SET	@total_ingresos = 0.00
	SET	@valor_promedio = 0.00
	SET	@valor_promedio_diario = 0.00
	SET	@valor_semana = 0.00
	SET	@valor_semana_diario = 0.00
	SET	@valor = 0.00
	SET	@valor_vacaciones = 0.00
	SET	@dias_vacaciones = 0.00
	SET @horas_vacaciones = 0.00
	SET @tiempo = 0.00

	SET @dias_vacaciones =	DATEDIFF(DD, @dva_desde, @dva_hasta) + 1

	SELECT @total_ingresos = SUM(inn_valor)
	FROM sal.inn_ingresos
		JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
	WHERE inn_codemp = @codemp
		AND ppl_estado = 'Autorizado'
		AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, MONTH(ppl_fecha_ini)) + '/' + CONVERT(VARCHAR, YEAR(ppl_fecha_ini)))
			BETWEEN @fecha_inicio_promedio AND @fecha_fin_promedio
		AND inn_codtig IN (SELECT iag_codtig
							FROM sal.iag_ingresos_agrupador
							WHERE iag_codagr = @codagr)

	SET @valor_promedio = @total_ingresos / @meses_promedio
	SET @valor_promedio_diario = ISNULL(@valor_promedio / @divisor, 0.00)

	SELECT @valor_semana = SUM(inn_valor)
	FROM sal.inn_ingresos
	WHERE inn_codemp = @codemp
		AND inn_codppl = @codppl_anterior
		AND inn_codtig IN (SELECT iag_codtig
							FROM sal.iag_ingresos_agrupador
							WHERE iag_codagr = @codagr)

	SET @valor_semana_diario = ISNULL(@valor_semana / @dias_semana, 0.00)

	IF @valor_promedio_diario > @valor_semana_diario AND @valor_promedio_diario > @salario_minimo_diario
	BEGIN
		SET @valor_base = @total_ingresos
		SET @valor = @valor_promedio_diario
	END
	ELSE IF @valor_semana_diario > @valor_promedio_diario AND @valor_semana_diario > @salario_minimo_diario
	BEGIN
		SET @valor_base = @valor_semana
		SET @valor = @valor_semana_diario
	END
	ELSE
	BEGIN
		SET @valor_base = @salario_minimo
		SET @valor = @salario_minimo_diario
	END

	SET @horas_vacaciones = @dias_vacaciones * @horas_por_dia

	SET @tiempo = @horas_vacaciones
	SET @valor_vacaciones = @valor * @dias_vacaciones

	INSERT INTO cr.vca_vacaciones_calculadas (vca_codppl,                 
		vca_codemp,                  
		vca_coddva,           
		vca_fecha_inicial,			
		vca_fecha_final,				
		vca_total_ingresos,          
		vca_promedio_mensual,        
		vca_promedio_diario,			
		vca_valor,					
		vca_tiempo,			        
		vca_unidad_tiempo,
		vca_usuario_grabacion,      
		vca_fecha_grabacion)
	VALUES (@codppl,
		@codemp,
		@coddva,
		@dva_desde,
		@dva_hasta,
		@total_ingresos,
		@valor_base,
		@valor,
		@valor_vacaciones,
		@tiempo,
		@unidad_tiempo,
		@username,
		GETDATE()) 

	UPDATE acc.dva_dias_vacacion
	SET dva_codppl = @codppl,
		dva_aplicado_planilla = 1
	WHERE dva_codigo = @coddva

	PRINT 'Código de Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
	PRINT 'Fecha de Inicio: ' + ISNULL(CONVERT(VARCHAR, @dva_desde, 103), '')
	PRINT 'Fecha de Fin: ' + ISNULL(CONVERT(VARCHAR, @dva_hasta, 103), '')
	PRINT 'Salario Empleado: ' + ISNULL(CONVERT(VARCHAR, @emp_salario), '')
	PRINT 'Fecha de Inicio Promedio: ' + ISNULL(CONVERT(VARCHAR, @fecha_inicio_promedio, 103), '')
	PRINT 'Fecha de Fin Promedio: ' + ISNULL(CONVERT(VARCHAR, @fecha_fin_promedio, 103), '')
	PRINT 'Valor Base: ' + ISNULL(CONVERT(VARCHAR, @valor_base), '')
	PRINT 'Total de Ingresos: ' + ISNULL(CONVERT(VARCHAR, @total_ingresos), '')
	PRINT 'Valor Promedio: ' + ISNULL(CONVERT(VARCHAR, @valor_promedio), '')
	PRINT 'Valor Promedio Diario: ' + ISNULL(CONVERT(VARCHAR, @valor_promedio_diario), '')
	PRINT 'Valor Semana: ' + ISNULL(CONVERT(VARCHAR, @valor_semana), '')
	PRINT 'Valor Semana Diario: ' + ISNULL(CONVERT(VARCHAR, @valor_semana_diario), '')
	PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor), '')
	PRINT 'Valor de vacaciones: ' + ISNULL(CONVERT(VARCHAR, @valor_vacaciones), '')
	PRINT 'Días de Vacaciones: ' + ISNULL(CONVERT(VARCHAR, @dias_vacaciones), '')
	PRINT 'Horas Vacaciones: ' + ISNULL(CONVERT(VARCHAR, @horas_vacaciones), '')
	PRINT ''

	FETCH NEXT FROM vacaciones INTO @codemp, @coddva, @dva_desde, @dva_hasta, @emp_salario
END

CLOSE vacaciones
DEALLOCATE vacaciones