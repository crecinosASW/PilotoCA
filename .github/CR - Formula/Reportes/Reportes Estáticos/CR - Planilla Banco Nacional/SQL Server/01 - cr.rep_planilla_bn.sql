IF EXISTS (SELECT 1
		   FROM sys.objects 
		   WHERE object_id = object_id('cr.rep_planilla_bn'))
BEGIN
	DROP PROCEDURE cr.rep_planilla_bn
END

GO

--EXEC cr.rep_planilla_bn 5, '1', '20140802', 'jcsoria'
CREATE PROCEDURE cr.rep_planilla_bn (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@codppl INT,
	@codbca_bn INT,
	@num_cliente VARCHAR(50),
	@num_transferencia VARCHAR(50),
	@cia_cuenta VARCHAR(50)

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

SET @codbca_bn = gen.get_valor_parametro_int('CodigoBCA_BN', @codpai, NULL, NULL, NULL)
SET @num_cliente = gen.get_valor_parametro_varchar('BancoNacionalCliente', NULL, NULL, @codcia, NULL)
SET @num_transferencia = gen.get_valor_parametro_varchar('BancoNacionalTransferencia', NULL, NULL, @codcia, NULL)
SET @cia_cuenta = gen.get_valor_parametro_varchar('CuentaBancoEmpresa', NULL, NULL, @codcia, NULL)

SELECT datos
FROM (
	-- encabezado
	SELECT 1 orden,
		NULL exp_codigo_alternativo, 
		'1' +
		RIGHT(REPLICATE('0', 6) + ISNULL(@num_cliente, ''), 6) +
		RIGHT(REPLICATE('0', 8) + REPLACE(ISNULL(CONVERT(VARCHAR, ppl_fecha_pago, 103), ''), '/', ''), 8) +
		REPLICATE('0', 6) +
		RIGHT(REPLICATE('0', 6) + ISNULL(@num_transferencia, ''), 6) +
		'1' +
		REPLICATE('0', 4) +
		REPLICATE('0', 12) +
		REPLICATE('0', 7) +
		REPLICATE('0', 7) +
		REPLICATE('0', 10) datos
	FROM sal.ppl_periodos_planilla
	WHERE ppl_codigo = @codppl	
		AND sco.permiso_tipo_planilla(ppl_codtpl, @usuario) = 1			
					
	UNION ALL

	-- débito (empresa)
	SELECT 2 orden,
		NULL exp_codigo_alternativo,
		'2' +
		RIGHT(REPLICATE('0', 3) + ISNULL(SUBSTRING(REPLACE(@cia_cuenta, '-', ''), 6, 3), ''), 3) +
		RIGHT(REPLICATE('0', 3) + ISNULL(SUBSTRING(REPLACE(@cia_cuenta, '-', ''), 1, 3), ''), 3) +
		RIGHT(REPLICATE('0', 2) + ISNULL(SUBSTRING(REPLACE(@cia_cuenta, '-', ''), 4, 2), ''), 2) +
		RIGHT(REPLICATE('0', 6) + ISNULL(SUBSTRING(REPLACE(@cia_cuenta, '-', ''), 9, 6), ''), 6) +
		RIGHT(REPLICATE('0', 1) + ISNULL(SUBSTRING(REPLACE(@cia_cuenta, '-', ''), 15, 1), ''), 1) +
		RIGHT(REPLICATE('0', 8) + REPLACE(ISNULL(CONVERT(VARCHAR, ppl_fecha_pago, 103), ''), '/', ''), 8) +
		RIGHT(REPLICATE('0', 12) + ISNULL(REPLACE(CONVERT(VARCHAR,
			(SELECT SUM(ISNULL(inn_valor, 0.00))
			 FROM sal.inn_ingresos
			 WHERE inn_codppl = ppl_codigo) -
			ISNULL(
				(SELECT SUM(ISNULL(dss_valor, 0.00))
				 FROM sal.dss_descuentos
				 WHERE dss_codppl = ppl_codigo), 0.00)), '.', ''), ''), 12) +
		LEFT('Pago de Planilla ' + ISNULL(CONVERT(VARCHAR, ppl_codigo_planilla), '') + REPLICATE(' ', 30), 30) +
		'00' datos
	FROM sal.ppl_periodos_planilla
	WHERE ppl_codigo = @codppl    
		AND sco.permiso_tipo_planilla(ppl_codtpl, @usuario) = 1				
					
	UNION ALL

	-- créditos (empleados)
	SELECT 3 orden,
		exp_codigo_alternativo,
		'3' +
		RIGHT(REPLICATE('0', 3) + ISNULL(SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 6, 3), ''), 3) +
		RIGHT(REPLICATE('0', 3) + ISNULL(SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 1, 3), ''), 3) +
		RIGHT(REPLICATE('0', 2) + ISNULL(SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 4, 2), ''), 2) +
		RIGHT(REPLICATE('0', 6) + ISNULL(SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 9, 6), ''), 6) +
		RIGHT(REPLICATE('0', 1) + ISNULL(SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 15, 1), ''), 1) +
		RIGHT(REPLICATE('0', 8) + REPLACE(ISNULL(CONVERT(VARCHAR, ppl_fecha_pago, 103), ''), '/', ''), 8) +
		RIGHT(REPLICATE('0', 12) + ISNULL(REPLACE(CONVERT(VARCHAR, CONVERT(decimal(18, 2),
			(SELECT SUM(ISNULL(inn_valor, 0.00))
			 FROM sal.inn_ingresos
			 WHERE inn_codppl = hpa_codppl
				 AND inn_codemp = hpa_codemp) -
			ISNULL(
				(SELECT SUM(ISNULL(dss_valor, 0.00))
				 FROM sal.dss_descuentos
				 WHERE dss_codppl = hpa_codppl
					 AND dss_codemp = hpa_codemp), 0.00))), '.', ''), ''), 12) +
		LEFT('Pago ' + ISNULL(CONVERT(VARCHAR, ppl_codigo_planilla), '') + ' Empleado ' + ISNULL(CONVERT(VARCHAR, exp_codigo_alternativo), '') + REPLICATE(' ', 30), 30) +
		'00' datos
	FROM sal.hpa_hist_periodos_planilla
		JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
		JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
		JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
		JOIN exp.cbe_cuentas_banco_exp ON exp_codigo = cbe_codexp
	WHERE hpa_codppl = @codppl
		AND cbe_codbca = @codbca_bn
		AND EXISTS (SELECT NULL
					FROM sal.inn_ingresos
					WHERE inn_codppl = hpa_codppl
						AND inn_codemp = hpa_codemp
						AND inn_valor > 0.00)
		AND sco.permiso_empleo(hpa_codemp, @usuario) = 1

	UNION ALL

	-- control y totales
	SELECT 4 orden,
		NULL exp_codigo_alternativo, 
		'4' +
		RIGHT(REPLICATE('0', 15) + ISNULL(REPLACE(CONVERT(VARCHAR, CONVERT(decimal(18, 2), 
			((SELECT SUM(ISNULL(inn_valor, 0.00))
			 FROM sal.inn_ingresos
			 WHERE inn_codppl = hpa_codppl) -
			ISNULL(
				(SELECT SUM(ISNULL(dss_valor, 0.00))
				 FROM sal.dss_descuentos
				 WHERE dss_codppl = hpa_codppl), 0.00)) * 2.00)), '.', ''), ''), 15) +
		RIGHT(REPLICATE('0', 10) + ISNULL(CONVERT(VARCHAR, SUM(CONVERT(INT, SUBSTRING(REPLACE(cbe_numero_cuenta, '-', ''), 9, 6)))), ''), 10) +
		REPLICATE('0', 10) +
		REPLICATE('0', 12) +
		REPLICATE('0', 12) +
		REPLICATE('0', 8) datos
	FROM sal.hpa_hist_periodos_planilla
		JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
		JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
		JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
		JOIN exp.cbe_cuentas_banco_exp ON exp_codigo = cbe_codexp
	WHERE hpa_codppl = @codppl
		AND cbe_codbca = @codbca_bn
		AND EXISTS (SELECT NULL
					FROM sal.inn_ingresos
					WHERE inn_codppl = hpa_codppl
						AND inn_codemp = hpa_codemp
						AND inn_valor > 0.00)
		AND sco.permiso_empleo(hpa_codemp, @usuario) = 1		
	GROUP BY hpa_codppl) datos
ORDER BY orden, exp_codigo_alternativo