IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_Planilla_Aguinaldo'))
BEGIN
	DROP PROCEDURE cr.GenPla_Planilla_Aguinaldo
END

GO

-- EXEC cr.GenPla_Planilla_Aguinaldo null, 68, 'admin'
CREATE PROCEDURE cr.GenPla_Planilla_Aguinaldo (	
	@sessionid UNIQUEIDENTIFIER = NULL,
    @codppl INT,
    @username VARCHAR(100) = NULL
) 
	
AS

--DECLARE @sessionid UNIQUEIDENTIFIER,
--    @codppl INT,
--    @username VARCHAR(100)
--
--SET @sessionid = 2
--SET @codppl = 2
--SET @username = 2009

SET NOCOUNT ON
SET DATEFORMAT DMY

-- declaracion de variables locales 
DECLARE @codpai VARCHAR(2),
	@codcia INT,
	@codagr_aguinaldo INT,
	@codtpl INT,
	@codtpl_normal INT,
	@ppl_fecha_fin DATETIME,
	@ppl_fecha_ini  DATETIME,
	@codemp INT,
	@codexp_alternativo VARCHAR(36),
	@emp_fecha_ingreso DATETIME,
	@meses_totales INT,
	@valor_ingresos MONEY,
	@valor_maternidad MONEY,
	@valor_total MONEY,
	@valor MONEY,
	@dias REAL,
	@codrin_maternidad INT

-- obtiene la fecha de finalizacion y la frecuencia del periodo de planilla que va a utilizar 
SELECT @codpai = cia_codpai,
    @codcia = tpl_codcia,
    @codtpl = ppl_codtpl,
	@codtpl_normal = tpl_codtpl_normal,
	@ppl_fecha_fin = ppl_fecha_fin, 
    @ppl_fecha_ini = ppl_fecha_ini
FROM sal.ppl_periodos_planilla 
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE ppl_codigo = @codppl

SELECT @codagr_aguinaldo  = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoAguinaldo'

SET @codrin_maternidad = gen.get_valor_parametro_int('CodigoRIN_Maternidad', @codpai, NULL, NULL, NULL)
SET @meses_totales = DATEDIFF(mm, @ppl_fecha_ini, @ppl_fecha_fin) + 1

DELETE cr.cag_calculo_aguinaldo
WHERE cag_codppl = @codppl
	AND (sal.empleado_en_gen_planilla(@sessionId, cag_codemp) = 1 
		OR cag_codemp IN (SELECT emp_codigo 
							FROM exp.emp_empleos
							WHERE emp_estado = 'R' 
								OR emp_codtpl <> @codtpl_normal))

--PRINT 'País: ' + ISNULL(@codpai, '')
--PRINT 'Compañía: ' + ISNULL(CONVERT(VARCHAR, @codcia), '')
--PRINT 'Agrupador: ' + ISNULL(CONVERT(VARCHAR, @codagr_aguinaldo), '')
--PRINT 'Tipo Planilla: ' + ISNULL(CONVERT(VARCHAR, @codtpl), '')
--PRINT 'Tipo Planilla Normal: ' + ISNULL(CONVERT(VARCHAR, @codtpl_normal), '')
--PRINT 'Fecha Inicio Planilla: ' + ISNULL(CONVERT(VARCHAR, @ppl_fecha_ini, 103), '')
--PRINT 'Fecha Final Planilla: ' + ISNULL(CONVERT(VARCHAR, @ppl_fecha_fin, 103), '')

DECLARE empleados CURSOR FOR
SELECT exp_codigo_alternativo,
	emp_codigo, 
	emp_fecha_ingreso
FROM exp.emp_empleos 
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
WHERE plz_codcia = @codcia
	AND emp_estado = 'A'
	AND emp_codtpl = @codtpl_normal

OPEN empleados

FETCH NEXT FROM empleados INTO @codexp_alternativo, @codemp, @emp_fecha_ingreso

WHILE @@FETCH_STATUS = 0 
BEGIN  
	SET @valor_ingresos = 0.00
	SET @valor_maternidad = 0.00
	SET @valor_total = 0.00
	SET @valor = 0.00

	IF @ppl_fecha_ini < @emp_fecha_ingreso
		SET @dias = DATEDIFF(DD, @emp_fecha_ingreso, @ppl_fecha_fin) + 1
	ELSE
		SET @dias = DATEDIFF(DD, @ppl_fecha_ini, @ppl_fecha_fin) + 1

	SELECT @valor_ingresos = SUM(inn_valor)
	FROM sal.inn_ingresos
		JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
	WHERE inn_codemp = @codemp
		AND ppl_estado = 'Autorizado'
		AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio))
			BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin
		AND inn_codtig IN (SELECT iag_codtig
						   FROM sal.iag_ingresos_agrupador
						   WHERE iag_codagr = @codagr_aguinaldo)

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
			BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin

	SET @valor_total = ISNULL(@valor_ingresos, 0.00) + ISNULL(@valor_maternidad, 0.00)
	
	SET @valor = ROUND(@valor_total / @meses_totales, 2)

	INSERT INTO cr.cag_calculo_aguinaldo (
		cag_codppl, 
		cag_codemp, 
		cag_total_ingresos,
		cag_valor_maternidad,
		cag_valor_total, 
		cag_valor, 
		cag_dias)
	VALUES (@codppl, 
		@codemp, 
		ISNULL(@valor_ingresos, 0.00),
		ISNULL(@valor_maternidad, 0.00),
		ISNULL(@valor_total, 0.00), 
		ISNULL(@valor, 0.00), 
		ISNULL(@dias, 0.00))

	--PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
	--PRINT 'Empleado: ' + ISNULL(CONVERT(VARCHAR, @codexp_alternativo), '')
	--PRINT 'Fecha Ingreso: ' + ISNULL(CONVERT(VARCHAR, @emp_fecha_ingreso, 103), '')
	--PRINT 'Total Ingresos: ' + ISNULL(CONVERT(VARCHAR, @valor_ingresos), '')
	--PRINT 'Maternidad: ' + ISNULL(CONVERT(VARCHAR, @valor_maternidad), '')
	--PRINT 'Valor Total: ' + ISNULL(CONVERT(VARCHAR, @valor_total), '')
	--PRINT 'Valor: ' + ISNULL(CONVERT(VARCHAR, @valor), '')
	--PRINT 'Días: ' + ISNULL(CONVERT(VARCHAR, @dias), '')
	--PRINT ''

	FETCH NEXT FROM empleados INTO @codexp_alternativo, @codemp, @emp_fecha_ingreso
END

CLOSE empleados
DEALLOCATE empleados

RETURN