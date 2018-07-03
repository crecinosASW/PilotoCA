IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_Calcula_Vacaciones'))
BEGIN
	DROP PROCEDURE cr.GenPla_Calcula_Vacaciones
END

GO

--EXEC cr.GenPla_Calcula_Vacaciones null, 80, 'admin'
CREATE PROCEDURE cr.GenPla_Calcula_Vacaciones
(	@sessionid UNIQUEIDENTIFIER = NULL,
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

DECLARE	@codcia INT,
	@codtpl INT,
	@codrsa_salario INT,
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@codemp INT,
	@coddva INT,
	@dva_desde DATETIME,
	@dva_hasta DATETIME,
	@emp_salario MONEY,
	@valor MONEY,
	@divisor REAL,
	@unidad_tiempo VARCHAR(15),
	@valor_vacaciones MONEY,
	@dias_vacaciones REAL,
	@tiempo REAL

SELECT @codcia = tpl_codcia,
	@codtpl = ppl_codtpl,
	@ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE ppl_codigo = @codppl

SET @divisor = 30.00
SET @unidad_tiempo = 'Dias'

SET @codrsa_salario = ISNULL(gen.get_valor_parametro_INT ('CodigoRSA_Salario', NULL, NULL, @codcia, NULL), 0)

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
	CASE WHEN dva_desde < @ppl_fecha_ini THEN @ppl_fecha_ini ELSE dva_desde END dva_desde,
	CASE WHEN dva_hasta > @ppl_fecha_fin THEN @ppl_fecha_fin ELSE dva_hasta END dva_hasta,
	(SELECT ISNULL(SUM(ese_valor),0) * 
		(CASE 
			WHEN ese_exp_valor = 'Diario' THEN 30.00
			WHEN ese_exp_valor = 'Hora' THEN 240.00
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
	AND ((dva_desde < @ppl_fecha_ini AND dva_hasta BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin)
		OR (dva_desde BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin AND dva_hasta > @ppl_fecha_fin)
		OR (dva_desde >= @ppl_fecha_ini AND dva_hasta <= @ppl_fecha_fin)
		OR (dva_desde < @ppl_fecha_ini AND dva_hasta > @ppl_fecha_fin))
	AND sal.empleado_en_gen_planilla(@sessionid, emp_codigo) = 1
ORDER BY  emp_codigo, dva_desde   

OPEN vacaciones

FETCH NEXT FROM vacaciones INTO @codemp, @coddva, @dva_desde, @dva_hasta, @emp_salario

-- Recorre cada una de las vacaciones de los empleados
WHILE @@FETCH_STATUS = 0
BEGIN
	SET	@valor = 0.00
	SET	@valor_vacaciones = 0.00
	SET	@dias_vacaciones = 0.00
	SET @tiempo = 0.00

	SET @dias_vacaciones = gen.fn_diff_two_dates_30(@dva_desde, @dva_hasta)

	SET @valor = @emp_salario / @divisor

	SET @tiempo = @dias_vacaciones
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
		0.00,
		0.00,
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

	--PRINT 'C�digo de Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
	--PRINT 'Fecha de Inicio: ' + ISNULL(CONVERT(VARCHAR, @dva_desde, 103), '')
	--PRINT 'Fecha de Fin: ' + ISNULL(CONVERT(VARCHAR, @dva_hasta, 103), '')
	--PRINT 'Salario Empleado: ' + ISNULL(CONVERT(VARCHAR, @emp_salario), '')
	--PRINT 'D�as de Vacaciones: ' + ISNULL(CONVERT(VARCHAR, @dias_vacaciones), '')
	--PRINT 'Salario Diario: ' + ISNULL(CONVERT(VARCHAR, @salario_diario), '')
	--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor_vacaciones), '')
	--PRINT ''

	FETCH NEXT FROM vacaciones INTO @codemp, @coddva, @dva_desde, @dva_hasta, @emp_salario
END

CLOSE vacaciones
DEALLOCATE vacaciones