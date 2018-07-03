IF EXISTS (SELECT 1
		   FROM sys.objects 
		   WHERE object_id = object_id('cr.rep_planilla_bcr'))
BEGIN
	DROP PROCEDURE cr.rep_planilla_bcr
END

GO

--EXEC cr.rep_planilla_bcr 1, '1', 201436, 1, '02007', 'admin'
CREATE PROCEDURE cr.rep_planilla_bcr (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@num_correlativo VARCHAR(3) = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@codppl INT,
	@codbca_bcr INT,
	@ide_cedula VARCHAR(20),
	@test_KEY REAL,
	@cia_cuenta VARCHAR(50),
	@cia_codmon_cuenta VARCHAR(3)

SELECT @codpai = cia_codpai,
	@codtpl = tpl_codigo
FROM sal.tpl_tipo_planilla
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual

SELECT @codppl = ppl_codigo
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_codigo_planilla = @codppl_visual

SET @codbca_bcr = gen.get_valor_parametro_int('CodigoBCA_BCR', @codpai, NULL, NULL, NULL)
SET @cia_cuenta = gen.get_valor_parametro_varchar('CuentaBancoEmpresaBCR', NULL, NULL, @codcia, NULL)
SET @cia_codmon_cuenta = gen.get_valor_parametro_varchar('MonedaCuentaBancoEmpresa', NULL, NULL, @codcia, NULL)

SELECT @ide_cedula = ISNULL(
	(CASE 
		WHEN ide_cip IS NOT NULL AND LTRIM(RTRIM(ide_cip)) <> '' 
		THEN LTRIM(RTRIM(ide_cip))
		WHEN ide_residente IS NOT NULL AND LTRIM(RTRIM(ide_residente)) <> ''
		THEN LTRIM(RTRIM(ide_residente))
		WHEN ide_permiso IS NOT NULL AND LTRIM(RTRIM(ide_permiso)) <> ''
		THEN LTRIM(RTRIM(ide_permiso))
		WHEN ide_pasaporte IS NOT NULL AND LTRIM(RTRIM(ide_pasaporte)) <> ''
		THEN LTRIM(RTRIM(ide_pasaporte))
	END), '')
FROM cr.ide_ident_emp_v
	JOIN exp.exp_expedientes ON ide_codexp = exp_codigo
WHERE exp_codigo_alternativo = @codemp_alternativo

SELECT @test_KEY = SUM(ISNULL(ofic_cuenta, 0.00)) + SUM(ISNULL(cuenta_monto, 0.00))
FROM (
	SELECT 
		CONVERT(INT, ISNULL(SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 2, 3), '0')) +
		CONVERT(INT, ISNULL(SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 5, 7), '0')) ofic_cuenta,
		CONVERT(INT, 
			CONVERT(REAL, ISNULL(SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 2, 10), '0')) /
			ISNULL(
				(SELECT SUM(ISNULL(inn_valor, 0.00))
				 FROM sal.inn_ingresos
				 WHERE inn_codppl = hpa_codppl
					 AND inn_codemp = hpa_codemp) -
				ISNULL(
					(SELECT SUM(ISNULL(dss_valor, 0.00))
					 FROM sal.dss_descuentos
					 WHERE dss_codppl = hpa_codppl
						 AND dss_codemp = hpa_codemp), 0.00), 1.00)) cuenta_monto
	FROM sal.hpa_hist_periodos_planilla
		JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
		JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
		JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
		JOIN exp.cbe_cuentas_banco_exp ON exp_codigo = cbe_codexp
	WHERE hpa_codppl = @codppl
		AND cbe_codbca = @codbca_bcr    
		AND EXISTS (SELECT NULL
					FROM sal.inn_ingresos
					WHERE inn_codppl = hpa_codppl
						AND inn_codemp = hpa_codemp
						AND inn_valor > 0.00)
		AND sco.permiso_empleo(hpa_codemp, @usuario) = 1
	GROUP BY hpa_codppl, hpa_codemp, cbe_numero_cuenta) test_KEY

SELECT datos
FROM (
	-- encabezado
	SELECT 1 orden,
		NULL exp_codigo_alternativo,
		REPLICATE('0', 3) +
		RIGHT(REPLICATE('0', 12) + REPLACE(REPLACE(ISNULL(cia_patronal, ''), '-', ''), ' ', ''), 12) +
		RIGHT(REPLICATE('0', 3) + ISNULL(@num_correlativo, '1'), 3) +
		REPLICATE('0', 6) +
		RIGHT(REPLICATE('0', 12) + REPLACE(REPLACE(ISNULL(@ide_cedula, ''), '-', ''), ' ', ''), 12) +
		RIGHT(REPLICATE('0', 12) + CONVERT(VARCHAR, CONVERT(INT, ISNULL(@test_KEY, ''))), 12) + 
		REPLICATE('0', 6) +
		REPLACE(CONVERT(VARCHAR, ppl_fecha_pago, 103), '/', '') +
		REPLICATE(' ', 21) +
		'Y' datos
	FROM sal.ppl_periodos_planilla
		JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
		JOIN eor.cia_companias ON tpl_codcia = cia_codigo
	WHERE ppl_codigo = @codppl
		AND sco.permiso_tipo_planilla(tpl_codigo, @usuario) = 1
					
	UNION ALL

	-- débito (empresa)
	SELECT 2 orden,
		NULL exp_codigo_alternativo,
		REPLICATE('0', 3) +
		'1' +
		'5201' +	
		RIGHT(REPLICATE('0', 3) + ISNULL(SUBSTRING(REPLACE(@cia_cuenta, '-', ''), 1, 3), ''), 3) +
		RIGHT(REPLICATE('0', 8) + ISNULL(SUBSTRING(REPLACE(@cia_cuenta, '-', ''), 4, 8), ''), 8) +
		'0' +
		RIGHT(REPLICATE('0', 1) + ISNULL(
			(CASE
				WHEN @cia_codmon_cuenta = 'CRC' THEN '1'
				WHEN @cia_codmon_cuenta = 'USD' THEN '2' 
				ELSE ''
			END), ''), 1) +
		'4' +
		REPLICATE('0', 4) +	
		RIGHT(REPLICATE('0', 8) + '1', 8) +
		RIGHT(REPLICATE('0', 12) + ISNULL(REPLACE(CONVERT(VARCHAR,
			(SELECT SUM(ISNULL(inn_valor, 0.00))
				FROM sal.inn_ingresos
				WHERE inn_codppl = ppl_codigo) -
			ISNULL(
				(SELECT SUM(ISNULL(dss_valor, 0.00))
					FROM sal.dss_descuentos
					WHERE dss_codppl = ppl_codigo), 0.00)), '.', ''), ''), 12) +
		REPLACE(CONVERT(VARCHAR, ppl_fecha_pago, 103), '/', '') +
		REPLICATE('0', 1) +	
		LEFT('Pago de Planilla ' + ISNULL(CONVERT(VARCHAR, ppl_codigo_planilla), '') + REPLICATE(' ', 30), 30) datos
	FROM sal.ppl_periodos_planilla
		JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
		JOIN eor.cia_companias ON tpl_codcia = cia_codigo
	WHERE ppl_codigo = @codppl
		AND sco.permiso_tipo_planilla(tpl_codigo, @usuario) = 1
					
	UNION ALL

	-- créditos (empleados)
	SELECT 3 orden,
		exp_codigo_alternativo,
		REPLICATE('0', 3) +
		'1' +
		'5202' +	
		RIGHT(REPLICATE('0', 3) + ISNULL(SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 1, 3), ''), 3) +
		RIGHT(REPLICATE('0', 8) + ISNULL(SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 4, 8), ''), 8) +
		'0' +
		RIGHT(REPLICATE('0', 1) + ISNULL(
			(CASE
				WHEN cbe_codmon = 'CRC' THEN '1'
				WHEN cbe_codmon = 'USD' THEN '2' 
				ELSE ''
			END), ''), 1) +
		'2' +
		REPLICATE('0', 4) +	
		RIGHT(REPLICATE('0', 8) + CONVERT(VARCHAR, row_number() OVER(ORDER BY exp_codigo_alternativo)), 8) +
		RIGHT(REPLICATE('0', 12) + ISNULL(REPLACE(CONVERT(VARCHAR, CONVERT(decimal(18, 2),
		(SELECT SUM(ISNULL(inn_valor, 0.00))
			FROM sal.inn_ingresos
			WHERE inn_codppl = ppl_codigo
				AND inn_codemp = hpa_codemp) -
		ISNULL(
			(SELECT SUM(ISNULL(dss_valor, 0.00))
				FROM sal.dss_descuentos
				WHERE dss_codppl = ppl_codigo
					AND dss_codemp = hpa_codemp), 0.00))), '.', ''), ''), 12) +
		REPLACE(CONVERT(VARCHAR, ppl_fecha_pago, 103), '/', '') +
		REPLICATE('0', 1) +	
		LEFT('Pago ' + ISNULL(CONVERT(VARCHAR, ppl_codigo_planilla), '') + ' Empleado ' + ISNULL(exp_codigo_alternativo, '') + REPLICATE(' ', 30), 30) datos
	FROM sal.hpa_hist_periodos_planilla
		JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
		JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
		JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
		JOIN exp.cbe_cuentas_banco_exp ON exp_codigo = cbe_codexp
	WHERE hpa_codppl = @codppl
		AND cbe_codbca = @codbca_bcr    
		AND EXISTS (SELECT NULL
					FROM sal.inn_ingresos
					WHERE inn_codppl = hpa_codppl
						AND inn_codemp = hpa_codemp
						AND inn_valor > 0.00)
		AND sco.permiso_empleo(hpa_codemp, @usuario) = 1) datos
ORDER BY orden, exp_codigo_alternativo