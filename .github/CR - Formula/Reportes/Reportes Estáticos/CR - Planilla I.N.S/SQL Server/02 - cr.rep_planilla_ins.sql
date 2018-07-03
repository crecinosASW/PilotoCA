IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_planilla_ins'))
BEGIN
	DROP PROCEDURE cr.rep_planilla_ins
END

GO

/*Procedimiento para el reporte de la planilla del Instituto Nacional de Seguro (INS) de costarrica*/
--EXEC cr.rep_planilla_ins 5, '1', 8, 2014, '9224932', '1', 'jcsoria'
CREATE PROCEDURE cr.rep_planilla_ins (
	@codcia INT = NULL,
	@codtpl_visual INT = NULL,
	@mes INT = NULL,
	@anio INT = NULL,
	@poliza VARCHAR(7) = NULL,	
	@correlativo VARCHAR(15) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

DECLARE @codpai VARCHAR(3),
	@codtpl INT,
	@codppl INT,
	@codagr_salario INT,
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@tipo VARCHAR(1),
	@codmed_ccss INT,
	@codmed_ins INT

SELECT @codpai = cia_codpai,
	@codtpl = tpl_codigo,
	@tipo = (CASE WHEN tpl_frecuencia = 'Anual' THEN 'A' ELSE 'M' END)
FROM sal.tpl_tipo_planilla
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual

SELECT @ppl_fecha_ini = MIN(ppl_fecha_ini),
	@ppl_fecha_fin = MAX(ppl_fecha_fin)
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_mes = @mes
	AND ppl_anio = @anio

SELECT @codagr_salario = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRPlanillaINSSalario'

SET @codmed_ccss = gen.get_valor_parametro_int('CodigoMED_CCSS', @codpai, NULL, NULL, NULL)
SET @codmed_ins = gen.get_valor_parametro_int('CodigoMED_INS', @codpai, NULL, NULL, NULL)

SELECT datos
FROM (	
	SELECT 1 orden,
		NULL exp_codigo_alternativo,
		LEFT(ISNULL(@poliza, '') + REPLICATE(' ', 7), 7) + --póliza
		UPPER(ISNULL(@tipo, ' ')) + --tipo
		LEFT(ISNULL(CONVERT(VARCHAR, @anio), '') + REPLICATE(' ', 4), 4) + --año
		ISNULL(RIGHT('00' + CONVERT(VARCHAR, @mes), 2), '') + --mes
		' ' + --vacío
		LEFT(ISNULL(REPLACE(
			CASE 
				WHEN ide_cip IS NOT NULL AND LTRIM(RTRIM(ide_cip)) <> ''
				THEN LTRIM(RTRIM(ide_cip))
				WHEN ide_residente IS NOT NULL AND LTRIM(RTRIM(ide_residente)) <> ''
				THEN '1' + SUBSTRING(LTRIM(RTRIM(ide_residente)), 1, 3) + RIGHT(REPLICATE('0', 8) + SUBSTRING(LTRIM(RTRIM(ide_residente)), 4, 8), 8)
				WHEN ide_pasaporte IS NOT NULL AND LTRIM(RTRIM(ide_pasaporte)) <> ''
				THEN '9' + REPLACE(RIGHT(REPLICATE('0', 11) + LTRIM(RTRIM(ide_pasaporte)), 11), 'RE', '0')
			END, '-', '0'), '') + REPLICATE(' ', 15), 15) + --no. identificaición
		LEFT(ISNULL(REPLACE(cia_fax, '-', ''), '') + REPLICATE(' ', 8), 8) + --teléfono
		LEFT(ISNULL(REPLACE(cia_telefonos, '-', ''), '') + REPLICATE(' ', 8), 8) +
		RIGHT(ISNULL(REPLICATE(' ', 15) + @correlativo, ''), 15) datos
	FROM eor.cia_companias
		LEFT JOIN eor.rep_representantes_legales ON rep_codcia = cia_codigo AND rep_activo = 1
		LEFT JOIN cr.ide_ident_emp_v ON rep_codexp = ide_codexp
	WHERE cia_codigo = @codcia
		AND sco.permiso_compania(cia_codigo, @usuario) = 1

	UNION

	SELECT 2 orden,
		NULL exp_codigo_alternativo,
		LEFT(ISNULL(UPPER(cia_direccion), '') + REPLICATE(' ', 200), 200) cia_direccion
	FROM eor.cia_companias
		LEFT JOIN eor.rep_representantes_legales ON rep_codcia = cia_codigo AND rep_activo = 1
		LEFT JOIN cr.ide_ident_emp_v ON rep_codexp = ide_codexp
	WHERE cia_codigo = @codcia
		AND sco.permiso_compania(cia_codigo, @usuario) = 1

	UNION

	SELECT 3 orden,
		NULL exp_codigo_alternativo,
		' ' datos

	UNION

	SELECT 4 orden,
		exp_codigo_alternativo,
		LEFT(ISNULL(REPLACE(
			(CASE 
				WHEN ide_cip IS NOT NULL AND LTRIM(RTRIM(ide_cip)) <> '' 
				THEN (CASE WHEN SUBSTRING(LTRIM(RTRIM(ide_cip)), 1, 1) <> '0' THEN '0' ELSE '' END) + LTRIM(RTRIM(ide_cip))
				WHEN ide_residente IS NOT NULL AND LTRIM(RTRIM(ide_residente)) <> ''
				THEN '1' + SUBSTRING(LTRIM(RTRIM(ide_residente)), 1, 3) + RIGHT(REPLICATE('0', 8) + SUBSTRING(LTRIM(RTRIM(ide_residente)), 4, 8), 8)
				WHEN ide_permiso IS NOT NULL AND LTRIM(RTRIM(ide_permiso)) <> ''
				THEN '8' + SUBSTRING(LTRIM(RTRIM(ide_permiso)), 3, 2) + RIGHT(REPLICATE('0', 9) + SUBSTRING(LTRIM(RTRIM(ide_permiso)), 6, 9), 9)
				WHEN ide_pasaporte IS NOT NULL AND LTRIM(RTRIM(ide_pasaporte)) <> ''
				THEN '9' + REPLACE(RIGHT(REPLICATE('0', 11) + LTRIM(RTRIM(ide_pasaporte)), 11), 'RE', '0')
				ELSE '5' + SUBSTRING(UPPER(pai_codigo), 1, 2) +
					REPLACE(CONVERT(VARCHAR, exp_fecha_nac, 103), '/', '') + 
					SUBSTRING(exp_segundo_ape, 1, 1) +
					SUBSTRING(exp_primer_ape, 1, 1) +
					SUBSTRING(exp_primer_nom, 1, 1)
			END), '-', '0'), '') + REPLICATE(' ', 15), 15) + --no. de identificación
		LEFT(REPLACE(ISNULL(ISNULL(ide_isss, ide_cip), ''), '-', '0') + REPLICATE(' ', 25), 25) + --no. asegurado
		LEFT(ISNULL(UPPER(exp_primer_nom), '') + REPLICATE(' ', 15), 15) + --nombre
		LEFT(ISNULL(UPPER(exp_primer_ape), '') + REPLICATE(' ', 15), 15) + --apellido1
		LEFT(ISNULL(UPPER(exp_segundo_ape), '') + REPLICATE(' ', 15), 15) + --apellido2
		RIGHT(REPLICATE('0', 10) + CONVERT(VARCHAR, ISNULL((
			SELECT SUM(inn_valor * ISNULL(CASE WHEN inn_codmon = 'USD' THEN hpa_tasa_cambio ELSE 1.00 END, 0.00))
			FROM sal.inn_ingresos
				JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
				JOIN sal.hpa_hist_periodos_planilla ON hpa_codppl = inn_codppl AND hpa_codemp = inn_codemp
			WHERE ppl_codtpl = @codtpl
				AND ppl_mes = @mes
				AND ppl_anio = @anio
				AND inn_codemp = emp_codigo
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @codagr_salario)), 0.00)), 13) + --salario
		RIGHT('00' + CONVERT(VARCHAR, CONVERT(INT, ISNULL((
			SELECT SUM(ISNULL(inn_tiempo, 0.00))
			FROM sal.inn_ingresos
				JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
			WHERE ppl_codtpl = @codtpl
				AND ppl_mes = @mes
				AND ppl_anio = @anio
				AND inn_codemp = emp_codigo
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @codagr_salario)), 0.00))), 3) + --días laborales
		RIGHT('000' + CONVERT(VARCHAR, CONVERT(INT, ISNULL((
			SELECT SUM(ISNULL(inn_tiempo, 0.00))
			FROM sal.inn_ingresos
				JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
			WHERE ppl_codtpl = @codtpl
				AND ppl_mes = @mes
				AND ppl_anio = @anio
				AND inn_codemp = emp_codigo
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @codagr_salario)), 0.00) *
			ISNULL((SELECT MAX(djo_total_horas) FROM sal.djo_dias_jornada WHERE djo_codjor = jor_codigo), 0.00))), 4) + --horas laboradas
		LEFT(ISNULL(SUBSTRING(gen.get_pb_field_data(jor_property_bag_data, 'CodigoINS'), 1, 2), '') + REPLICATE(' ', 2), 2) + --jornada laboral
		CASE 
			WHEN emp_fecha_ingreso >= @ppl_fecha_ini AND emp_fecha_ingreso <= @ppl_fecha_fin 
				AND ISNULL(emp_fecha_retiro, DATEADD(DD, 1, @ppl_fecha_fin)) > @ppl_fecha_fin
			THEN '01'
			WHEN emp_fecha_retiro >= @ppl_fecha_ini AND emp_fecha_retiro <= @ppl_fecha_fin 
				AND ISNULL(emp_fecha_ingreso, DATEADD(YY, -100, GETDATE())) < @ppl_fecha_ini
			THEN '02'
			WHEN EXISTS (SELECT NULL
						 FROM acc.ixe_incapacidades 
						 WHERE ixe_codemp = emp_codigo
							 AND ixe_estado = 'Autorizado'	
							 AND ixe_codmed = @codmed_ccss
							 AND ((ixe_inicio >= @ppl_fecha_ini AND ixe_final <= @ppl_fecha_fin)
								 OR (ixe_inicio BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin AND ixe_final > @ppl_fecha_fin)	
								 OR (ixe_inicio < @ppl_fecha_ini AND ixe_final BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin)
								 OR (ixe_inicio < @ppl_fecha_ini AND ixe_final > @ppl_fecha_fin)))
			THEN '03'
			WHEN EXISTS (SELECT NULL
						 FROM acc.ixe_incapacidades
						 WHERE ixe_codemp = emp_codigo
							 AND ixe_estado = 'Autorizado'	
							 AND ixe_codmed = @codmed_ins
							 AND ((ixe_inicio >= @ppl_fecha_ini AND ixe_final <= @ppl_fecha_fin)
								 OR (ixe_inicio BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin AND ixe_final > @ppl_fecha_fin)	
								 OR (ixe_inicio < @ppl_fecha_ini AND ixe_final BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin)
								 OR (ixe_inicio < @ppl_fecha_ini AND ixe_final > @ppl_fecha_fin)))
			THEN '04'		  
			WHEN emp_fecha_ingreso >= @ppl_fecha_ini AND emp_fecha_ingreso <= @ppl_fecha_fin 
				AND emp_fecha_retiro >= @ppl_fecha_ini AND emp_fecha_retiro <= @ppl_fecha_fin 	
			THEN '05'
			ELSE '00'
		END + --condición laboral
		LEFT(ISNULL(SUBSTRING(gen.get_pb_field_data(pue_property_bag_data, 'CodigoINS'), 1, 5), '') + REPLICATE(' ', 5), 5)  datos --ocupación
	FROM exp.emp_empleos
		JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
		JOIN eor.plz_plazas ON emp_codplz = plz_codigo
		JOIN eor.pue_puestos ON plz_codpue = pue_codigo
		LEFT JOIN sal.jor_jornadas ON emp_codjor = jor_codigo
		LEFT JOIN gen.pai_paises ON exp_codpai_nacionalidad = pai_codigo
		LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
	WHERE plz_codcia = @codcia
		AND EXISTS (SELECT NULL
					FROM sal.hpa_hist_periodos_planilla
						JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
					WHERE hpa_codemp = emp_codigo
						AND ppl_anio = @anio
						AND ppl_mes = @mes)
		AND EXISTS (SELECT NULL
					FROM sal.inn_ingresos
						JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
					WHERE inn_codemp = emp_codigo
						AND ppl_anio = @anio
						AND ppl_mes = @mes
						AND inn_valor > 0.00)
		AND sco.permiso_empleo(emp_codigo, @usuario) = 1) datos
ORDER BY orden, exp_codigo_alternativo