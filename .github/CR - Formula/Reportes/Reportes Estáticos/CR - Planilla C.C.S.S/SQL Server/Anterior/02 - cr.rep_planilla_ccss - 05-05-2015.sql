IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_planilla_ccss'))
BEGIN
	DROP PROCEDURE cr.rep_planilla_ccss
END

GO

--cr.rep_planilla_ccss 'cr', 2014, 8, 'jcsoria'
CREATE procedure cr.rep_planilla_ccss (
	@codpai VARCHAR(2) = NULL, 
	@anio INT = NULL, 
	@mes INT = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY

declare @codcia INT,
	@codagr_ingresos INT,
	@fecha_inicial DATETIME,
	@fecha_final DATETIME,
	@codmed_ccss INT,
	@codmed_ins INT,
	@codrin_maternidad INT,
	@codmrt_invalidez INT,
	@codmrt_vejez INT,
	@num_reg_patronal INT,
	@num_reg_obrero INT,
	@codreg_patronal VARCHAR(2),
	@codreg_obrero VARCHAR(2),
	@codreg_control VARCHAR(2)

SET @fecha_inicial = CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, @mes) + '/' + CONVERT(VARCHAR, @anio))
SET @fecha_final = DATEADD(DD, -1, DATEADD(MM, 1, @fecha_inicial))

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRPlanillaCCSSIngresos'

SET @codmed_ccss = gen.get_valor_parametro_int('CodigoMED_CCSS', @codpai, NULL, NULL, NULL)
SET @codmed_ins = gen.get_valor_parametro_int('CodigoMED_INS', @codpai, NULL, NULL, NULL)
SET @codrin_maternidad = gen.get_valor_parametro_int('CodigoRIN_Maternidad', @codpai, NULL, NULL, NULL)
SET @codmrt_invalidez = gen.get_valor_parametro_int('CodigoMRT_Invalidez', @codpai, NULL, NULL, NULL)
SET @codmrt_vejez = gen.get_valor_parametro_int('CodigoMRT_Vejez', @codpai, NULL, NULL, NULL)
SET @codreg_patronal = gen.get_valor_parametro_varchar('CCSSRegistroPatronal', @codpai, NULL, NULL, NULL)
SET @codreg_obrero = gen.get_valor_parametro_varchar('CCSSRegistroObrera', @codpai, NULL, NULL, NULL)
SET @codreg_control = gen.get_valor_parametro_varchar('CCSSRegistroControl', @codpai, NULL, NULL, NULL)

CREATE TABLE #final (
	orden INT NOT NULL,
	cia_codigo INT NULL,
	exp_codigo_alternativo VARCHAR(36) NULL,
	tipo VARCHAR(2) NULL,
	datos VARCHAR(500) NULL
)

-- Encabezado
SELECT 1 orden,
	cia_codigo,
	NULL exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_patronal, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_patronal, ''), 2, '0') +
	gen.rpad(ISNULL(cia_patronal, ''), 18, '0') +
	gen.rpad(ISNULL(gen.get_valor_parametro_varchar('CCSSSucursal', @codpai, NULL, NULL, NULL), ''), 4, '0') +
	gen.rpad(ISNULL(CONVERT(VARCHAR, @anio) + RIGHT('00' + CONVERT(VARCHAR, @mes), 2), ''), 6, '0') + ' ' datos
INTO #patronal
FROM eor.cia_companias
WHERE cia_codpai = @codpai
	AND sco.permiso_compania(cia_codigo, @usuario) = 1

-- Registros de inclusiones (Nuevas Contrataciones)
SELECT 2 orden,
	cia_codigo,
	exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') +
	CASE WHEN exp_codpai_nacionalidad <> @codpai THEN '7' ELSE '0' END +
	gen.rpad(ISNULL(REPLACE(ide_cip, '-', '0'), ISNULL(ide_isss, '')), 25, '0') +
	gen.lpad(ISNULL(exp_primer_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_segundo_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_primer_nom, '') + ISNULL(' ' + exp_segundo_nom, ''), 60, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(pue_property_bag_data,'CodigoINS'), ''), 4, '0') +
	gen.rpad(REPLACE(REPLACE(CONVERT(VARCHAR, CONVERT(DECIMAL(13, 2), ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		WHERE inn_codemp = emp_codigo
			AND ppl_mes = @mes
			AND ppl_anio = @anio
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ingresos)), 0.00))), '.', ''), ',', '.'), 15, '0') +
	'C' + -- Clase de Seguro
	gen.lpad(ISNULL(gen.get_valor_parametro_varchar('CCSSTCInclusion', @codpai, NULL, NULL, NULL), ''), 2, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'HorasDia'), ''), 2, '0') +
	gen.lpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'CodigoCCSS'), ''), 3, ' ') +
	'GEN' +
	gen.lpad(ISNULL(CONVERT(VARCHAR, emp_fecha_ingreso, 112), ''), 8, ' ') +
	gen.lpad('', 8, ' ') datos
INTO #inclusiones
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN eor.cia_companias ON cia_codigo = plz_codcia
	JOIN eor.pue_puestos ON pue_codigo = plz_codpue
	LEFT JOIN sal.jor_jornadas ON jor_codcia = cia_codigo AND jor_codigo = emp_codjor
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE cia_codpai = @codpai 
	AND emp_estado = 'A' 
	AND YEAR(emp_fecha_ingreso) = @anio 
	AND MONTH(emp_fecha_ingreso) = @mes 
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

-- Registros de salarios normales
SELECT 3 orden,
	cia_codigo,
	exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') +
	CASE WHEN exp_codpai_nacionalidad <> @codpai THEN '7' ELSE '0' END +
	gen.rpad(ISNULL(REPLACE(ide_cip, '-', '0'), ISNULL(ide_isss, '')), 25, '0') +
	gen.lpad(ISNULL(exp_primer_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_segundo_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_primer_nom, '') + ISNULL(' ' + exp_segundo_nom, ''), 60, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(pue_property_bag_data,'CodigoINS'), ''), 4, '0') +
	gen.rpad(REPLACE(REPLACE(CONVERT(VARCHAR, CONVERT(DECIMAL(13, 2), ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		WHERE inn_codemp = emp_codigo
			AND ppl_mes = @mes
			AND ppl_anio = @anio
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ingresos)), 0.00))), '.', ''), ',', '.'), 15, '0') +
	'C' + -- Clase de Seguro
	gen.lpad(ISNULL(gen.get_valor_parametro_varchar('CCSSTCSalario', @codpai, NULL, NULL, NULL), ''), 2, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'HorasDia'), '08'), 2, '0') +
	gen.lpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'CodigoCCSS'), ''), 3, ' ') +
	gen.lpad('', 3, ' ') +
	gen.lpad('', 8, ' ') +
	gen.lpad('', 8, ' ') datos
INTO #salarios
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN eor.cia_companias ON cia_codigo = plz_codcia
	JOIN eor.pue_puestos ON pue_codigo = plz_codpue
	LEFT JOIN sal.jor_jornadas ON jor_codcia = cia_codigo AND jor_codigo = emp_codjor
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE cia_codpai = @codpai 
	AND ((emp_estado = 'A' AND emp_fecha_ingreso < @fecha_inicial)
		OR (emp_estado = 'R' AND emp_fecha_retiro > @fecha_final))
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

-- Registros de empleados retirados (Retiros Exclusiones)
SELECT 4 orden,
	cia_codigo,
	exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') +
	CASE WHEN exp_codpai_nacionalidad <> @codpai THEN '7' ELSE '0' END +
	gen.rpad(ISNULL(REPLACE(ide_cip, '-', '0'), ISNULL(ide_isss, '')), 25, '0') +
	gen.lpad(ISNULL(exp_primer_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_segundo_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_primer_nom, '') + ISNULL(' ' + exp_segundo_nom, ''), 60, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(pue_property_bag_data,'CodigoINS'), ''), 4, '0') +
	gen.rpad(REPLACE(REPLACE(CONVERT(VARCHAR, CONVERT(DECIMAL(13, 2), ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		WHERE inn_codemp = emp_codigo
			AND ppl_mes = @mes
			AND ppl_anio = @anio
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ingresos)), 0.00))), '.', ''), ',', '.'), 15, '0') +
	'C' + -- Clase de Seguro
	gen.lpad(ISNULL(gen.get_valor_parametro_varchar('CCSSTCExclusion', @codpai, NULL, NULL, NULL), ''), 2, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'HorasDia'), '08'), 2, '0') +
	gen.lpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'CodigoCCSS'), ''), 3, ' ') +
	gen.lpad('', 3, ' ') +
	gen.lpad('', 8, ' ') +
	gen.lpad(ISNULL(CONVERT(VARCHAR, emp_fecha_retiro, 112), ''), 8, ' ') datos
INTO #exclusiones
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN eor.cia_companias ON cia_codigo = plz_codcia
	JOIN eor.pue_puestos ON pue_codigo = plz_codpue
	LEFT JOIN sal.jor_jornadas ON jor_codcia = cia_codigo AND jor_codigo = emp_codjor
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE cia_codpai = @codpai 
	AND emp_estado = 'R' 
	AND YEAR(emp_fecha_retiro) = @anio 
	AND MONTH(emp_fecha_retiro) = @mes 
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

-- Registros Cambios de Jornada
SELECT 5 orden,
	cia_codigo,
	exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') +
	CASE WHEN exp_codpai_nacionalidad <> @codpai THEN '7' ELSE '0' END +
	gen.rpad(ISNULL(REPLACE(ide_cip, '-', '0'), ISNULL(ide_isss, '')), 25, '0') +
	gen.lpad(ISNULL(exp_primer_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_segundo_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_primer_nom, '') + ISNULL(' ' + exp_segundo_nom, ''), 60, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(pue_property_bag_data,'CodigoINS'), ''), 4, '0') +
	gen.rpad(REPLACE(REPLACE(CONVERT(VARCHAR, CONVERT(DECIMAL(13, 2), ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		WHERE inn_codemp = emp_codigo
			AND ppl_mes = @mes
			AND ppl_anio = @anio
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ingresos)), 0.00))), '.', ''), ',', '.'), 15, '0') +
	'C' + -- Clase de Seguro
	gen.lpad(ISNULL(gen.get_valor_parametro_varchar('CCSSTCJornada', @codpai, NULL, NULL, NULL), ''), 2, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'HorasDia'), '08'), 2, '0') +
	gen.lpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'CodigoCCSS'), ''), 3, ' ') +
	'GEN' +
	gen.lpad(ISNULL(CONVERT(VARCHAR, cjo_fecha_vigencia, 112), ''), 8, ' ') +
	gen.lpad('', 8, ' ') datos
INTO #jornadas
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN eor.cia_companias ON cia_codigo = plz_codcia
	JOIN eor.pue_puestos ON pue_codigo = plz_codpue
	JOIN acc.cjo_cambios_jornada ON cjo_codemp = emp_codigo
	JOIN sal.jor_jornadas ON jor_codigo = cjo_codjor_nuevo
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE cia_codpai = @codpai 
	AND (emp_estado = 'A'
		OR (emp_estado = 'R' AND emp_fecha_retiro >= @fecha_inicial))
	AND YEAR(cjo_fecha_vigencia) = @anio
	AND MONTH(cjo_fecha_vigencia) = @mes
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

-- Registros de Movimientos (Cambios de Ocupacion)
SELECT 6 orden,
	cia_codigo,
	exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') +
	CASE WHEN exp_codpai_nacionalidad <> @codpai THEN '7' ELSE '0' END +
	gen.rpad(ISNULL(REPLACE(ide_cip, '-', '0'), ISNULL(ide_isss, '')), 25, '0') +
	gen.lpad(ISNULL(exp_primer_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_segundo_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_primer_nom, '') + ISNULL(' ' + exp_segundo_nom, ''), 60, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(pue_property_bag_data,'CodigoINS'), ''), 4, '0') +
	gen.rpad('', 15, '0') +
	'C' + -- Clase de Seguro
	gen.lpad(ISNULL(gen.get_valor_parametro_varchar('CCSSTCOcupacion', @codpai, NULL, NULL, NULL), ''), 2, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'HorasDia'), ''), 2, '0') +
	gen.lpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'CodigoCCSS'), ''), 3, ' ') +
	gen.lpad('', 3, ' ') +
	gen.lpad(ISNULL(CONVERT(VARCHAR, mov_fecha_vigencia, 112), ''), 8, ' ') +
	gen.lpad('', 8, ' ') datos
INTO #movimientos
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN eor.cia_companias ON cia_codigo = plz_codcia
	JOIN eor.pue_puestos ON pue_codigo = plz_codpue
	JOIN acc.mov_movimientos ON mov_codemp = emp_codigo
	LEFT JOIN sal.jor_jornadas ON jor_codcia = cia_codigo AND jor_codigo = emp_codjor
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE cia_codpai = @codpai 
	AND (emp_estado = 'A'
		OR (emp_estado = 'R' AND emp_fecha_retiro >= @fecha_inicial))
	AND YEAR(mov_fecha_vigencia) = @anio
	AND MONTH(mov_fecha_vigencia) = @mes
	AND (SELECT gen.get_pb_field_data(pue_property_bag_data, 'CodigoINS') 
		 FROM eor.pue_puestos 
			 JOIN eor.plz_plazas ON plz_codpue = pue_codigo
		 WHERE plz_codigo = mov_codplz_anterior) <> 
		(SELECT gen.get_pb_field_data(pue_property_bag_data,'CodigoINS') 
		 FROM eor.pue_puestos 
			 JOIN eor.plz_plazas ON plz_codpue = pue_codigo
		 WHERE plz_codigo = mov_codplz_nuevo) 
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

-- Registros de Incapacidades Caja e INSS (Excluye meternidades)
SELECT 7 orden,
	cia_codigo,
	exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') +
	CASE WHEN exp_codpai_nacionalidad <> @codpai THEN '7' ELSE '0' END +
	gen.rpad(ISNULL(REPLACE(ide_cip, '-', '0'), ISNULL(ide_isss, '')), 25, '0') +
	gen.lpad(ISNULL(exp_primer_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_segundo_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_primer_nom, '') + ISNULL(' ' + exp_segundo_nom, ''), 60, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(pue_property_bag_data,'CodigoINS'), ''), 4, '0') +
	gen.rpad(REPLACE(REPLACE(CONVERT(VARCHAR, CONVERT(DECIMAL(13, 2), ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		WHERE inn_codemp = emp_codigo
			AND ppl_mes = @mes
			AND ppl_anio = @anio
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ingresos)), 0.00))), '.', ''), ',', '.'), 15, '0') +
	'C' + -- Clase de Seguro
	gen.lpad(ISNULL(gen.get_valor_parametro_varchar('CCSSTCIncapacidad', @codpai, NULL, NULL, NULL), ''), 2, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'HorasDia'), '08'), 2, '0') +
	gen.lpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'CodigoCCSS'), ''), 3, ' ') +
	gen.lpad(CASE WHEN ixe_codmed = @codmed_ccss THEN 'SEM' WHEN ixe_codmed = @codmed_ins THEN 'INS' ELSE '' END, 3, ' ') +
	gen.lpad(ISNULL(CONVERT(VARCHAR, CASE WHEN ixe_inicio < @fecha_inicial THEN @fecha_inicial ELSE ixe_inicio END, 112), ''), 8, ' ') +
	gen.lpad(ISNULL(CONVERT(VARCHAR, CASE WHEN ixe_final > @fecha_final THEN @fecha_final ELSE ixe_final END, 112), ''), 8, ' ') datos
INTO #incapacidades
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN eor.cia_companias ON cia_codigo = plz_codcia
	JOIN eor.pue_puestos ON pue_codigo = plz_codpue
	JOIN acc.ixe_incapacidades ON emp_codigo = ixe_codemp
	LEFT JOIN sal.jor_jornadas ON jor_codcia = cia_codigo AND jor_codigo = emp_codjor
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE cia_codpai = @codpai 
	AND (emp_estado = 'A'
		OR (emp_estado = 'R' AND emp_fecha_retiro >= @fecha_inicial))
	AND ixe_estado = 'Autorizado'
	AND ixe_codrin <> @codrin_maternidad
	AND ((ixe_inicio >= @fecha_inicial AND ixe_final <= @fecha_final)
		OR (ixe_inicio BETWEEN @fecha_inicial AND @fecha_final AND (ixe_final > @fecha_final OR ixe_final IS NULL))
		OR (ixe_inicio < @fecha_inicial AND ixe_final BETWEEN @fecha_inicial AND @fecha_final)
		OR (ixe_inicio < @fecha_inicial AND (ixe_final > @fecha_final OR ixe_final IS NULL)))
	AND ixe_codmed IN (@codmed_ccss, @codmed_ins)
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

-- Registros de Incapacidades por Maternidad
SELECT 8 orden,
	cia_codigo,
	exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') +
	CASE WHEN exp_codpai_nacionalidad <> @codpai THEN '7' ELSE '0' END +
	gen.rpad(ISNULL(REPLACE(ide_cip, '-', '0'), ISNULL(ide_isss, '')), 25, '0') +
	gen.lpad(ISNULL(exp_primer_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_segundo_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_primer_nom, '') + ISNULL(' ' + exp_segundo_nom, ''), 60, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(pue_property_bag_data,'CodigoINS'), ''), 4, '0') +
	gen.rpad(REPLACE(REPLACE(CONVERT(VARCHAR, CONVERT(DECIMAL(13, 2), ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		WHERE inn_codemp = emp_codigo
			AND ppl_mes = @mes
			AND ppl_anio = @anio
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ingresos)), 0.00))), '.', ''), ',', '.'), 15, '0') +
	'C' + -- Clase de Seguro
	gen.lpad(ISNULL(gen.get_valor_parametro_varchar('CCSSTCIncapacidad', @codpai, NULL, NULL, NULL), ''), 2, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'HorasDia'), '08'), 2, '0') +
	gen.lpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'CodigoCCSS'), ''), 3, ' ') +
	'MAT' +
	gen.lpad(ISNULL(CONVERT(VARCHAR, CASE WHEN ixe_inicio < @fecha_inicial THEN @fecha_inicial ELSE ixe_inicio END, 112), ''), 8, ' ') +
	gen.lpad(ISNULL(CONVERT(VARCHAR, CASE WHEN ixe_final > @fecha_final THEN @fecha_final ELSE ixe_final END, 112), ''), 8, ' ') datos
INTO #maternidades
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN eor.cia_companias ON cia_codigo = plz_codcia
	JOIN eor.pue_puestos ON pue_codigo = plz_codpue
	JOIN acc.ixe_incapacidades ON emp_codigo = ixe_codemp
	LEFT JOIN sal.jor_jornadas ON jor_codcia = cia_codigo AND jor_codigo = emp_codjor
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE cia_codpai = @codpai 
	AND (emp_estado = 'A'
		OR (emp_estado = 'R' AND emp_fecha_retiro >= @fecha_inicial))
	AND ixe_estado = 'Autorizado'
	AND ixe_codrin <> @codrin_maternidad
	AND ((ixe_inicio >= @fecha_inicial AND ixe_final <= @fecha_final)
		OR (ixe_inicio BETWEEN @fecha_inicial AND @fecha_final AND (ixe_final > @fecha_final OR ixe_final IS NULL))
		OR (ixe_inicio < @fecha_inicial AND ixe_final BETWEEN @fecha_inicial AND @fecha_final)
		OR (ixe_inicio < @fecha_inicial AND (ixe_final > @fecha_final OR ixe_final IS NULL)))
	AND ixe_codmed IN (@codmed_ccss, @codmed_ins)
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

-- Registros de Tiempos no trabajados (Permisos con y sin goce de sueldo)
SELECT 9 orden,
	cia_codigo,
	exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') +
	CASE WHEN exp_codpai_nacionalidad <> @codpai THEN '7' ELSE '0' END +
	gen.rpad(ISNULL(REPLACE(ide_cip, '-', '0'), ISNULL(ide_isss, '')), 25, '0') +
	gen.lpad(ISNULL(exp_primer_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_segundo_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_primer_nom, '') + ISNULL(' ' + exp_segundo_nom, ''), 60, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(pue_property_bag_data,'CodigoINS'), ''), 4, '0') +
	gen.rpad(REPLACE(REPLACE(CONVERT(VARCHAR, CONVERT(DECIMAL(13, 2), ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		WHERE inn_codemp = emp_codigo
			AND ppl_mes = @mes
			AND ppl_anio = @anio
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ingresos)), 0.00))), '.', ''), ',', '.'), 15, '0') +
	'C' + -- Clase de Seguro
	gen.lpad(ISNULL(gen.get_valor_parametro_varchar('CCSSTCPermiso', @codpai, NULL, NULL, NULL), ''), 2, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'HorasDia'), '08'), 2, '0') +
	gen.lpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'CodigoCCSS'), ''), 3, ' ') +
	gen.lpad(CASE WHEN ISNULL(tnt_goce_sueldo, 0) = 1 THEN 'C' ELSE 'S' END, 3, ' ') +
	gen.lpad(ISNULL(CONVERT(VARCHAR, CASE WHEN tnn_fecha_del < @fecha_inicial THEN @fecha_inicial ELSE tnn_fecha_del END, 112), ''), 8, ' ') +
	gen.lpad(ISNULL(CONVERT(VARCHAR, CASE WHEN tnn_fecha_al > @fecha_final THEN @fecha_final ELSE tnn_fecha_al END, 112), ''), 8, ' ') datos
INTO #permisos
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN eor.cia_companias ON cia_codigo = plz_codcia
	JOIN eor.pue_puestos ON pue_codigo = plz_codpue
	JOIN sal.tnn_tiempos_no_trabajados on tnn_codemp = emp_codigo
	JOIN sal.tnt_tipos_tiempo_no_trabajado on tnt_codigo = tnn_codtnt
	LEFT JOIN sal.jor_jornadas ON jor_codcia = cia_codigo AND jor_codigo = emp_codjor
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE cia_codpai = @codpai 
	AND (emp_estado = 'A'
		OR (emp_estado = 'R' AND emp_fecha_retiro >= @fecha_inicial))
	AND tnn_estado = 'Autorizado'
	AND ((tnn_fecha_del >= @fecha_inicial AND tnn_fecha_al <= @fecha_final)
		OR (tnn_fecha_del BETWEEN @fecha_inicial AND @fecha_final AND tnn_fecha_al > @fecha_final)
		OR (tnn_fecha_del < @fecha_inicial AND tnn_fecha_al BETWEEN @fecha_inicial AND @fecha_final)
		OR (tnn_fecha_del < @fecha_inicial AND tnn_fecha_al > @fecha_final))
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

-- Pensiones por invalidez vejez y muerte
SELECT 10 orden,
	cia_codigo,
	exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_obrero, ''), 2, '0') +
	CASE WHEN exp_codpai_nacionalidad <> @codpai THEN '7' ELSE '0' END +
	gen.rpad(ISNULL(REPLACE(ide_cip, '-', '0'), ISNULL(ide_isss, '')), 25, '0') +
	gen.lpad(ISNULL(exp_primer_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_segundo_ape, ''), 20, ' ') +
	gen.lpad(ISNULL(exp_primer_nom, '') + ISNULL(' ' + exp_segundo_nom, ''), 60, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(pue_property_bag_data,'CodigoINS'), ''), 4, '0') +
	gen.rpad(REPLACE(REPLACE(CONVERT(VARCHAR, CONVERT(DECIMAL(13, 2), ISNULL((
		SELECT SUM(inn_valor)
		FROM sal.inn_ingresos
			JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		WHERE inn_codemp = emp_codigo
			AND ppl_mes = @mes
			AND ppl_anio = @anio
			AND inn_codtig IN (SELECT iag_codtig
							   FROM sal.iag_ingresos_agrupador
							   WHERE iag_codagr = @codagr_ingresos)), 0.00))), '.', ''), ',', '.'), 15, '0') +
	'C' + -- Clase de Seguro
	gen.lpad(ISNULL(gen.get_valor_parametro_varchar('CCSSTCPension', @codpai, NULL, NULL, NULL), ''), 2, ' ') +
	gen.rpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'HorasDia'), '08'), 2, '0') +
	gen.lpad(ISNULL(gen.get_pb_field_data(jor_property_bag_data, 'CodigoCCSS'), ''), 3, ' ') +
	gen.lpad(CASE WHEN ret_codmrt = @codmrt_invalidez THEN 'INV' WHEN ret_codmrt = @codmrt_vejez THEN 'VEJ' ELSE '' END, 3, ' ') +
	gen.lpad('', 8, ' ') +
	gen.lpad(ISNULL(CONVERT(VARCHAR, emp_fecha_retiro, 112), ''), 8, ' ') datos
INTO #pensiones
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN eor.cia_companias ON cia_codigo = plz_codcia
	JOIN eor.pue_puestos ON pue_codigo = plz_codpue
	JOIN acc.ret_retiros ON ret_codemp = emp_codigo
	LEFT JOIN sal.jor_jornadas ON jor_codcia = cia_codigo AND jor_codigo = emp_codjor
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE cia_codpai = @codpai 
	AND ret_estado = 'Autorizado'
	AND YEAR(emp_fecha_retiro) = @anio
	AND MONTH(emp_fecha_retiro) = @mes
	AND ret_codmrt IN (@codmrt_invalidez, @codmrt_vejez)
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

INSERT INTO #final SELECT orden, cia_codigo, exp_codigo_alternativo, tipo, datos FROM #patronal
INSERT INTO #final SELECT orden, cia_codigo, exp_codigo_alternativo, tipo, datos FROM #inclusiones
INSERT INTO #final SELECT orden, cia_codigo, exp_codigo_alternativo, tipo, datos FROM #salarios
INSERT INTO #final SELECT orden, cia_codigo, exp_codigo_alternativo, tipo, datos FROM #jornadas
INSERT INTO #final SELECT orden, cia_codigo, exp_codigo_alternativo, tipo, datos FROM #exclusiones
INSERT INTO #final SELECT orden, cia_codigo, exp_codigo_alternativo, tipo, datos FROM #movimientos
INSERT INTO #final SELECT orden, cia_codigo, exp_codigo_alternativo, tipo, datos FROM #incapacidades
INSERT INTO #final SELECT orden, cia_codigo, exp_codigo_alternativo, tipo, datos FROM #maternidades
INSERT INTO #final SELECT orden, cia_codigo, exp_codigo_alternativo, tipo, datos FROM #permisos
INSERT INTO #final SELECT orden, cia_codigo, exp_codigo_alternativo, tipo, datos FROM #pensiones

SELECT @num_reg_patronal = COUNT(*)
FROM #final
WHERE tipo = @codreg_patronal

SELECT @num_reg_obrero = COUNT(*)
FROM #final
WHERE tipo = @codreg_obrero

-- Construyendo registro final con totales
INSERT INTO #final
SELECT 11 orden,
	999 cia_codigo,
	NULL exp_codigo_alternativo,
	gen.rpad(ISNULL(@codreg_control, ''), 2, '0') tipo,
	gen.rpad(ISNULL(@codreg_control, ''), 2, '0') +
	gen.lpad(ISNULL(gen.get_valor_parametro_varchar('CCSSTipoCliente', @codpai, NULL, NULL, NULL), ''), 3, ' ') +
	gen.lpad(ISNULL(CONVERT(VARCHAR, GETDATE(), 112), ''), 8, ' ') +
	gen.rpad(ISNULL(CONVERT(VARCHAR, @num_reg_patronal), ''), 10, '0') +
	gen.rpad(ISNULL(CONVERT(VARCHAR, @num_reg_obrero), ''), 10, '0') datos

SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(datos, 'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'Ü','U') datos
FROM #final
ORDER BY cia_codigo, exp_codigo_alternativo, orden

--SELECT * FROM #patronal
--SELECT * FROM #inclusiones
--SELECT * FROM #salarios
--SELECT * FROM #jornadas
--SELECT * FROM #exclusiones
--SELECT * FROM #movimientos
--SELECT * FROM #incapacidades
--SELECT * FROM #maternidades
--SELECT * FROM #permisos
--SELECT * FROM #pensiones
--SELECT * FROM #final

-- Eliminando tablas temporales
DROP TABLE #patronal
DROP TABLE #inclusiones
DROP TABLE #salarios
DROP TABLE #jornadas
DROP TABLE #exclusiones
DROP TABLE #movimientos
DROP TABLE #incapacidades
DROP TABLE #maternidades
DROP TABLE #permisos
DROP TABLE #pensiones
DROP TABLE #final