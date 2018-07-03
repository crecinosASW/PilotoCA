IF EXISTS (SELECT NULL
		   FROM sys.objects 
		   WHERE object_id = object_id('cr.rep_planilla_bac'))
BEGIN
	DROP PROCEDURE cr.rep_planilla_bac
END

GO

--EXEC cr.rep_planilla_bac 5, '1', 20140802, '4717', '00144'
CREATE PROCEDURE cr.rep_planilla_bac (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@numero_plan VARCHAR(4) = NULL,
	@numero_envio VARCHAR(5) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@codppl INT,
	@codbca_bac INT

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

SET @codbca_bac = gen.get_valor_parametro_int('CodigoBCA_BAC', @codpai, NULL, NULL, NULL)

SELECT datos
FROM (
	SELECT 1 orden,
		0 exp_codigo_alternativo,
		'B' +
		RIGHT(REPLICATE(' ', 4) + ISNULL(@numero_plan , ''), 4) +
		RIGHT(REPLICATE(' ', 5) + ISNULL(@numero_envio, ''), 5) + 
		REPLICATE(' ', 20) +
		REPLICATE('0', 5) +
		RIGHT(REPLICATE('0', 4) + ISNULL(CONVERT(VARCHAR, YEAR(ppl_fecha_pago)), ''), 4) +
		RIGHT(REPLICATE('0', 2) + ISNULL(CONVERT(VARCHAR, MONTH(ppl_fecha_pago)), ''), 2) +
		RIGHT(REPLICATE('0', 2) + ISNULL(CONVERT(VARCHAR, DAY(ppl_fecha_pago)), ''), 2) +
		RIGHT(REPLICATE('0', 13) + ISNULL(REPLACE(CONVERT(VARCHAR,
			(SELECT SUM(ISNULL(inn_valor, 0.00))
			 FROM sal.inn_ingresos
			 WHERE inn_codppl = hpa_codppl) -
			ISNULL(
				(SELECT SUM(ISNULL(dss_valor, 0.00))
				 FROM sal.dss_descuentos
				 WHERE dss_codppl = hpa_codppl), 0.00)), '.', ''), ''), 13) +
		RIGHT(REPLICATE('0', 5) + ISNULL(CONVERT(VARCHAR, COUNT(*)), ''), 5) +
		REPLICATE(' ', 30) +
		REPLICATE(' ', 1) +
		REPLICATE(' ', 60) +
		REPLICATE(' ', 9) datos
	FROM sal.hpa_hist_periodos_planilla
		JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
		JOIN exp.emp_empleos ON emp_codigo = hpa_codemp
		JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
		JOIN exp.cbe_cuentas_banco_exp ON exp_codigo = cbe_codexp
	WHERE hpa_codppl = @codppl
		AND EXISTS (SELECT NULL
					FROM sal.inn_ingresos
					WHERE inn_codppl = hpa_codppl
						AND inn_codemp = hpa_codemp
						AND inn_valor > 0.00)
		AND cbe_codbca = @codbca_bac
		AND sco.permiso_empleo(hpa_codemp, @usuario) = 1
	GROUP BY hpa_codppl, ppl_fecha_pago
					
	UNION 

	SELECT 2 orden,
		exp_codigo_alternativo,
		'T' +
		RIGHT(REPLICATE(' ', 4) + ISNULL(@numero_plan , ''), 4) +
		RIGHT(REPLICATE(' ', 5) + ISNULL(@numero_envio, ''), 5) + 
		LEFT(ISNULL(REPLACE(
		(CASE 
			WHEN ide_cip IS NOT NULL AND LTRIM(RTRIM(ide_cip)) <> '' 
			THEN (CASE WHEN SUBSTRING(LTRIM(RTRIM(ide_cip)), 1, 1) <> '0' THEN '0' ELSE '' END) + LTRIM(RTRIM(ide_cip))
			WHEN ide_residente IS NOT NULL AND LTRIM(RTRIM(ide_residente)) <> ''
			THEN LTRIM(RTRIM(ide_residente))
			WHEN ide_permiso IS NOT NULL AND LTRIM(RTRIM(ide_permiso)) <> ''
			THEN LTRIM(RTRIM(ide_permiso))
			WHEN ide_pasaporte IS NOT NULL AND LTRIM(RTRIM(ide_pasaporte)) <> ''
			THEN LTRIM(RTRIM(ide_pasaporte))
		END), '-', '0'), '') + REPLICATE(' ', 20), 20) +
		RIGHT(REPLICATE('0', 5) + ISNULL(CONVERT(VARCHAR, ROW_NUMBER() OVER(ORDER BY exp_codigo_alternativo)), ''), 5) +
		RIGHT(REPLICATE('0', 4) + ISNULL(CONVERT(VARCHAR, YEAR(ppl_fecha_pago)), ''), 4) +
		RIGHT(REPLICATE('0', 2) + ISNULL(CONVERT(VARCHAR, MONTH(ppl_fecha_pago)), ''), 2) +
		RIGHT(REPLICATE('0', 2) + ISNULL(CONVERT(VARCHAR, DAY(ppl_fecha_pago)), ''), 2) +
		RIGHT(REPLICATE('0', 13) + ISNULL(REPLACE(CONVERT(VARCHAR,
			(SELECT SUM(ISNULL(inn_valor, 0.00))
			 FROM sal.inn_ingresos
			 WHERE inn_codppl = hpa_codppl
				 AND inn_codemp = hpa_codemp) -
			ISNULL(
				(SELECT SUM(ISNULL(dss_valor, 0.00))
				 FROM sal.dss_descuentos
				 WHERE dss_codppl = hpa_codppl
					 AND dss_codemp = hpa_codemp), 0.00)), '.', ''), ''), 13) +
		REPLICATE(' ', 5) +
		LEFT('Pago de Planilla ' + ISNULL(CONVERT(VARCHAR, ppl_codigo_planilla), '') + REPLICATE(' ', 30), 30) +
		REPLICATE(' ', 1) +
		LEFT(ISNULL(REPLACE(hpa_nombres_apellidos, ',', ''), '') + REPLICATE(' ', 60), 60) +
		RIGHT(REPLICATE(' ', 9), 9) datos
	FROM sal.hpa_hist_periodos_planilla
		JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
		JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
		JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
		JOIN exp.cbe_cuentas_banco_exp ON exp_codigo = cbe_codexp
		JOIN eor.plz_plazas ON emp_codplz = plz_codigo
		JOIN eor.cia_companias ON plz_codcia = cia_codigo
		LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
	WHERE hpa_codppl = @codppl
		AND EXISTS (SELECT NULL
					FROM sal.inn_ingresos
					WHERE inn_codppl = hpa_codppl
						AND inn_codemp = hpa_codemp
						AND inn_valor > 0.00)
		AND cbe_codbca = @codbca_bac
		AND sco.permiso_empleo(hpa_codemp, @usuario) = 1) datos
ORDER BY orden, exp_codigo_alternativo