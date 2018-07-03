IF EXISTS (SELECT NULL 
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_const_trab_salario_prom'))
BEGIN
	DROP PROCEDURE cr.rep_const_trab_salario_prom
END

GO	

--EXEC cr.rep_const_trab_salario_prom 1, '1725', '1725', 'Costa Rica', '13/04/2015', 'admin'
CREATE PROCEDURE cr.rep_const_trab_salario_prom (
	@codcia INT = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@codemp_alternativo_firma VARCHAR(36) = NULL,
	@ciudad VARCHAR(30) = NULL,
	@fecha_txt VARCHAR(10) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY

DECLARE @codpai VARCHAR(2),
	@codemp INT,
	@emp_fecha_ingreso DATETIME,
	@codemp_firma INT,
	@fecha DATETIME,
	@codrsa_salario INT,
	@exp_nombres_apellidos_firma VARCHAR(80),
	@plz_nombre_firma VARCHAR(80),
	@total_ingresos MONEY,
	@salario MONEY,
	@salario_neto MONEY,
	@fecha_inicio_promedio DATETIME,
	@fecha_fin_promedio DATETIME,
	@meses_promedio REAL,
	@codagr_ingresos INT,
	@codagr_embargo INT,
	@emp_es_jubildado BIT,
	@porcentaje_ccss REAL,
	@porcentaje_jubilado REAL,
	@porcentaje_bp REAL,
	@porcentaje REAL,
	@descuentos MONEY,
	@texto_embargo VARCHAR(100)

SELECT @codpai = cia_codpai
FROM eor.cia_companias
WHERE cia_codigo = @codcia

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)
SET @codemp_firma = gen.obtiene_codigo_empleo(@codemp_alternativo_firma)
SET @fecha = CONVERT(DATETIME, @fecha_txt)
SET @codrsa_salario = gen.get_valor_parametro_int('CodigoRSA_Salario', NULL, NULL, @codcia, NULL)
SET @meses_promedio = gen.get_valor_parametro_float('ConstanciaSalarioMesesPromedio', @codpai, NULL, NULL, NULL)
SET @porcentaje_ccss = ISNULL(gen.get_valor_parametro_float('CuotaEmpleadoSeguroSocial', @codpai, NULL, NULL, NULL), 0.00)
SET @porcentaje_jubilado = ISNULL(gen.get_valor_parametro_float('CuotaJubiladoSeguroSocial', @codpai, NULL, NULL, NULL), 0.00)
SET @porcentaje_bp = ISNULL(gen.get_valor_parametro_float('BancoPopularPorcentaje', @codpai, NULL, NULL, NULL), 0.00)

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRConstanciaTrabajoSalarioPromedioIngresos'

SELECT @codagr_embargo = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRConstanciaTrabajoSalarioPromedioEmbargo'

SELECT @emp_fecha_ingreso = emp_fecha_ingreso,
	@emp_es_jubildado = ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, 'EsJubilado'), CAST(0 AS bit))
FROM exp.emp_empleos
WHERE emp_codigo = @codemp

SELECT @exp_nombres_apellidos_firma = exp_nombres_apellidos,
	@plz_nombre_firma = plz_nombre
FROM exp.exp_expedientes
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
WHERE emp_codigo = @codemp_firma
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

IF @emp_es_jubildado = 1
	SET @porcentaje = @porcentaje_jubilado + @porcentaje_bp
ELSE
	SET @porcentaje = @porcentaje_ccss + @porcentaje_bp

SET @fecha_fin_promedio = CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, MONTH(@fecha)) + '/' + CONVERT(VARCHAR, YEAR(@fecha)))
SET @fecha_inicio_promedio = DATEADD(MM, -@meses_promedio, @fecha_fin_promedio)
SET @fecha_fin_promedio = DATEADD(DD, -1, @fecha_fin_promedio)

IF @fecha_inicio_promedio < @emp_fecha_ingreso
	SET @fecha_inicio_promedio = @emp_fecha_ingreso

IF DAY(@fecha_inicio_promedio) <> 1
	SET @fecha_inicio_promedio = DATEADD(DD, 1, gen.fn_last_day(@fecha_inicio_promedio))

SET @meses_promedio = DATEDIFF(MM, @fecha_inicio_promedio, @fecha_fin_promedio) + 1

IF @meses_promedio <= 0
	SET @meses_promedio = 1

SELECT @total_ingresos = ROUND(SUM(ISNULL(inn_valor, 0.00)), 2) 
FROM sal.inn_ingresos 
	JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
WHERE inn_codemp = @codemp
	AND ppl_estado = 'Autorizado'
	AND CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, ppl_mes) + '/' + CONVERT(VARCHAR, ppl_anio))
		BETWEEN @fecha_inicio_promedio AND @fecha_fin_promedio
	AND inn_codtig IN (SELECT iag_codtig
						FROM sal.iag_ingresos_agrupador
						WHERE iag_codagr = @codagr_ingresos)

SET @salario = ROUND(ISNULL(@total_ingresos / @meses_promedio, 0.00), 2)

SET @descuentos = ROUND(ISNULL(@salario * @porcentaje / 100.00, 0.00), 2)

SET @salario_neto = @salario - @descuentos

IF EXISTS (SELECT NULL
		   FROM sal.pla_pre_prestamo_v
		   WHERE dcc_codemp = @codemp
			   AND dcc_estado = 'Autorizado' 
			   AND dcc_activo = 1
			   AND ISNULL(dcc_saldo, 9999999999) > 0.00
			   AND pre_valor_cuota <> 0
			   AND dcc_codtdc IN (SELECT dag_codtdc
								  FROM sal.dag_descuentos_agrupador
								  WHERE dag_codagr = @codagr_embargo))
BEGIN
	SET @texto_embargo = gen.get_valor_parametro_varchar('ConstanciaSalarioTextoEmbargo', @codpai, NULL, NULL, NULL)
END
ELSE
BEGIN
	SET @texto_embargo = gen.get_valor_parametro_varchar('ConstanciaSalarioTextoNoEmbargo', @codpai, NULL, NULL, NULL)
END

--PRINT 'País: ' + ISNULL(@codpai, '')
--PRINT 'Empleado: ' + ISNULL(@codemp_alternativo, '')
--PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
--PRINT 'Fecha: ' + ISNULL(CONVERT(VARCHAR, @fecha, 103), '')
--PRINT 'Fecha Ingreso: ' + ISNULL(CONVERT(VARCHAR, @emp_fecha_ingreso, 103), '')
--PRINT 'Rubro Salarial de Salario: ' + ISNULL(CONVERT(VARCHAR, @codrsa_salario), '')
--PRINT 'Es Jubilado: ' + ISNULL(CONVERT(VARCHAR, @emp_es_jubildado), '')
--PRINT 'Porcentaje CCSS: ' + ISNULL(CONVERT(VARCHAR, @porcentaje_ccss), '')
--PRINT 'Porcentaje Jubilado: ' + ISNULL(CONVERT(VARCHAR, @porcentaje_jubilado), '')
--PRINT 'Porcentaje Banco Popular: ' + ISNULL(CONVERT(VARCHAR, @porcentaje_bp), '')
--PRINT 'Porcentaje: ' + ISNULL(CONVERT(VARCHAR, @porcentaje), '')
--PRINT 'Agrupador CRConstanciaTrabajoSalarioPromedioIngresos: ' + ISNULL(CONVERT(VARCHAR, @codagr_ingresos), '')
--PRINT 'Agrupador CRConstanciaTrabajoSalarioPromedioEmbargo: ' + ISNULL(CONVERT(VARCHAR, @codagr_embargo), '')
--PRINT 'Meses Promedio: ' + ISNULL(CONVERT(VARCHAR, @meses_promedio), '')
--PRINT 'Fecha Inicio Promedio: ' + ISNULL(CONVERT(VARCHAR, @fecha_inicio_promedio, 103), '')
--PRINT 'Fecha Fin Promedio: ' + ISNULL(CONVERT(VARCHAR, @fecha_fin_promedio, 103), '')
--PRINT 'Total Ingresos: ' + ISNULL(CONVERT(VARCHAR, @total_ingresos), '')
--PRINT 'Salario: ' + ISNULL(CONVERT(VARCHAR, @salario), '')
--PRINT 'Descuentos: ' + ISNULL(CONVERT(VARCHAR, @descuentos), '')
--PRINT 'Salario Neto: ' + ISNULL(CONVERT(VARCHAR, @salario_neto), '')
--PRINT 'Texto Embargo: ' + ISNULL(@texto_embargo, '')

SELECT ISNULL(@ciudad, pai_descripcion) cts_pais,
	gen.convierte_fecha_a_letras(@fecha, 0, 2) cts_fecha_reporte,
	cia_descripcion cts_cia,
	exp_nombres_apellidos cts_empleado,
	ide_cip cts_cedula,
	plz_nombre cts_plaza,
	CONVERT(VARCHAR, emp_fecha_ingreso, 103) cts_fecha_ingreso,
	uni_descripcion cts_unidad,
	CONVERT(VARCHAR, CONVERT(MONEY, @salario))  cts_salario,
	CONVERT(VARCHAR, CONVERT(MONEY, @salario_neto))  cts_salario_neto,
	LOWER(gen.convierte_numeros_a_letras(@salario, cia_codpai)) cts_salario_letras,
	LOWER(gen.convierte_numeros_a_letras(@salario_neto, cia_codpai)) cts_salario_neto_letras,
	mon_simbolo cts_simbolo_moneda,
	mon_descripcion cts_moneda,
	@texto_embargo cts_texto_embargo,
	@exp_nombres_apellidos_firma cts_empleado_firma,
	@plz_nombre_firma cts_plaza_firma
FROM exp.exp_expedientes
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp
	JOIN exp.ese_estructura_sal_empleos ON emp_codigo = ese_codemp AND ese_estado = 'V' AND ese_codrsa = @codrsa_salario
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.uni_unidades ON plz_codcia = uni_codcia AND plz_coduni = uni_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN gen.pai_paises ON cia_codpai = pai_codigo
	JOIN gen.mon_monedas ON ese_codmon = mon_codigo
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE plz_codcia = @codcia
	AND emp_codigo = ISNULL(@codemp, emp_codigo)
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1