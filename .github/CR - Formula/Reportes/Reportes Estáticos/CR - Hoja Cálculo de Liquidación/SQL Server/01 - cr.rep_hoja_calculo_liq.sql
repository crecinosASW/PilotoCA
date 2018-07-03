IF EXISTS (SELECT NULL
		   FROM sys.objects 
		   WHERE object_id = object_id('cr.rep_hoja_calculo_liq'))
BEGIN
	DROP PROCEDURE cr.rep_hoja_calculo_liq
END

GO

--EXEC cr.rep_hoja_calculo_liq 1, '2335', '06/03/2015', 'admin'
CREATE PROCEDURE cr.rep_hoja_calculo_liq (
	@codcia INT = NULL,
	@codemp_alternativo INT = NULL,
	@fecha_retiro_txt VARCHAR(10) = NULL,
	@usuario VARCHAR(50) = NULL
) 

AS

SET NOCOUNT ON
SET DATEFORMAT DMY

DECLARE @codemp INT,
	@fecha_retiro DATETIME,
	@dias_aguinaldo REAL,
	@dias_cesantia REAL,
	@dias_preaviso REAL,
	@dias_vacaciones REAL,
	@comentario_aguinaldo VARCHAR(150),
	@comentario_cesantia VARCHAR(150),
	@comentario_preaviso VARCHAR(150),
	@comentario_vacaciones VARCHAR(150),
	@valor_aguinaldo MONEY,
	@valor_cesantia MONEY,
	@valor_preaviso MONEY,
	@valor_vacaciones MONEY,
	@codtig_aguinaldo INT,
	@codtig_cesantia INT,
	@codtig_preaviso INT,
	@codtig_vacaciones INT,
	@cia_descripcion VARCHAR(100)

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)
SET @fecha_retiro = CONVERT(DATETIME, @fecha_retiro_txt, 103)

--------------------------------------------
-- obtiene los tipos de ingreso asociados --
--------------------------------------------
SET @codtig_aguinaldo = ISNULL(gen.get_valor_parametro_int('CodigoTIG_Aguinaldo',NULL,NULL,@codcia,NULL), 0)
SET @codtig_cesantia = ISNULL(gen.get_valor_parametro_int('CodigoTIG_Cesantia',NULL,NULL,@codcia,NULL), 0)
SET @codtig_preaviso = ISNULL(gen.get_valor_parametro_int('CodigoTIG_Preaviso',NULL,NULL,@codcia,NULL), 0)
SET @codtig_vacaciones = ISNULL(gen.get_valor_parametro_int('CodigoTIG_VacacionesNoAfectas',NULL,NULL,@codcia,NULL), 0)

SELECT @cia_descripcion = cia_descripcion 
FROM eor.cia_companias
WHERE cia_codigo = @codcia

--------------------------------------------
-- obtiene las formulas de los calculos   --
--------------------------------------------
SELECT @comentario_aguinaldo = ISNULL(dli_comentario, ''),
	@dias_aguinaldo = ISNULL(dli_tiempo, 0),
	@valor_aguinaldo = ISNULL(dli_valor, 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
WHERE lie_codemp = @codemp_alternativo
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_aguinaldo

SELECT @comentario_preaviso = ISNULL(dli_comentario, ''),
	@dias_preaviso = ISNULL(dli_tiempo, 0),
	@valor_preaviso = ISNULL(dli_valor, 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
WHERE lie_codemp = @codemp_alternativo
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_preaviso

SELECT @comentario_cesantia = ISNULL(dli_comentario, ''),
	@dias_cesantia = ISNULL(dli_tiempo, 0),
	@valor_cesantia = ISNULL(dli_valor, 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
WHERE lie_codemp = @codemp_alternativo
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_cesantia

SELECT @comentario_vacaciones = ISNULL(dli_comentario, ''),
	@dias_vacaciones = ISNULL(dli_tiempo, 0),
	@valor_vacaciones = ISNULL(dli_valor, 0)
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
WHERE lie_codemp = @codemp_alternativo
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig =  @codtig_vacaciones

--------------------------------------------
--     SELECT final para el reporte       --
--------------------------------------------
SELECT UPPER(@cia_descripcion) cia_descripcion, 
	CONVERT(VARCHAR, hli_fecha_ingreso, 103) hli_fecha_ingreso,
	@fecha_retiro_txt hli_fecha_retiro,
	exp_nombres_apellidos,
	emp_codigo,
	plz_nombre,
	hli_codtig,
	hli_numero,
	UPPER(tig_descripcion) tig_descripcion,
	CONVERT(VARCHAR, hli_fecha_ini, 103) hli_fecha_ini,
	CONVERT(VARCHAR, hli_fecha_fin, 103) hli_fecha_fin,
	ISNULL(hli_salario, 0.00) hli_salario,
	ISNULL(hli_variable, 0.00) hli_variable,
	ISNULL(hli_variable,0.00) hli_total,
	ISNULL(hli_dias_pago, 0.00) hli_dias_pago,
	-- para los dias totales --
	CASE 
		WHEN hli_codtig = @codtig_aguinaldo THEN @dias_aguinaldo
		WHEN hli_codtig = @codtig_cesantia THEN @dias_cesantia
		WHEN hli_codtig = @codtig_preaviso THEN @dias_preaviso
		WHEN hli_codtig = @codtig_vacaciones THEN @dias_vacaciones
	END hlia_dias,
	-- para las formulas --
	CASE 
		WHEN hli_codtig = @codtig_aguinaldo THEN @comentario_aguinaldo
		WHEN hli_codtig = @codtig_cesantia THEN @comentario_cesantia
		WHEN hli_codtig = @codtig_preaviso THEN @comentario_preaviso
		WHEN hli_codtig = @codtig_vacaciones THEN @comentario_vacaciones
	END hli_formula,
	-- para el valor a pagar --
	CASE 
		WHEN hli_codtig = @codtig_aguinaldo THEN @valor_aguinaldo
		WHEN hli_codtig = @codtig_cesantia THEN @valor_cesantia
		WHEN hli_codtig = @codtig_preaviso THEN @valor_preaviso
		WHEN hli_codtig = @codtig_vacaciones THEN @valor_vacaciones
	END hli_valor,
	-- para el tipo de ingreso --
	CASE 
		WHEN hli_codtig = @codtig_aguinaldo THEN 'A'
		WHEN hli_codtig = @codtig_cesantia THEN 'C'
		WHEN hli_codtig = @codtig_preaviso THEN 'P' 
		WHEN hli_codtig = @codtig_vacaciones THEN 'V'
	END hli_tipo, 
	hli_periodo
FROM cr.hli_historico_liquidaciones  
	JOIN exp.emp_empleos ON emp_codigo = hli_codemp
	JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN sal.tig_tipos_ingreso ON tig_codigo = hli_codtig
WHERE plz_codcia = @codcia
	AND hli_codemp = @codemp
	AND hli_fecha_retiro = @fecha_retiro
	AND sco.permiso_empleo(hli_codemp, @usuario) = 1
ORDER BY tig_descripcion, hli_numero