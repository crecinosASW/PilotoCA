IF EXISTS (SELECT NULL
		   FROM sys.objects 
		   WHERE object_id = object_id('cr.rep_planilla_bac_rev'))
BEGIN
	DROP PROCEDURE cr.rep_planilla_bac_rev
END

GO

--EXEC cr.rep_planilla_bac_rev 1, '1', '201438', '4717', '00144', 'admin'
CREATE PROCEDURE cr.rep_planilla_bac_rev (
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
	@codbca_bac INT,
	@tpl_descripcion VARCHAR(50)

SELECT @codpai = cia_codpai,
	@codtpl = tpl_codigo,
	@tpl_descripcion = tpl_descripcion
FROM sal.tpl_tipo_planilla
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual

SELECT @codppl = ppl_codigo
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_codigo_planilla = @codppl_visual

SET @codbca_bac = gen.get_valor_parametro_int('CodigoBCA_BAC', @codpai, NULL, NULL, NULL)

SELECT cia_descripcion,
	cia_patronal,
	@tpl_descripcion tpl_descripcion,
	ppl_codigo_planilla,
	CONVERT(VARCHAR, ppl_fecha_pago, 103) ppl_fecha_pago,
	@numero_plan numero_plan,
	@numero_envio numero_envio,
	exp_codigo_alternativo,
	exp_apellidos_nombres,
	ISNULL(REPLACE(
	(CASE 
		WHEN ide_cip IS NOT NULL AND LTRIM(RTRIM(ide_cip)) <> '' 
		THEN (CASE WHEN SUBSTRING(LTRIM(RTRIM(ide_cip)), 1, 1) <> '0' THEN '0' ELSE '' END) + LTRIM(RTRIM(ide_cip))
		WHEN ide_residente IS NOT NULL AND LTRIM(RTRIM(ide_residente)) <> ''
		THEN LTRIM(RTRIM(ide_residente))
		WHEN ide_permiso IS NOT NULL AND LTRIM(RTRIM(ide_permiso)) <> ''
		THEN LTRIM(RTRIM(ide_permiso))
		WHEN ide_pasaporte IS NOT NULL AND LTRIM(RTRIM(ide_pasaporte)) <> ''
		THEN LTRIM(RTRIM(ide_pasaporte))
	END), '-', '0'), '') ide_cedula,
	cbe_numero_cuenta,
	cbe_codmon,
	ISNULL(CONVERT(VARCHAR, ROW_NUMBER() OVER(ORDER BY exp_codigo_alternativo)), '') emp_correlativo,
	ISNULL((
		SELECT SUM(ISNULL(inn_valor, 0.00))
		FROM sal.inn_ingresos
		WHERE inn_codppl = hpa_codppl
			AND inn_codemp = hpa_codemp), 0.00) -
	ISNULL((
		SELECT SUM(ISNULL(dss_valor, 0.00))
		FROM sal.dss_descuentos
		WHERE dss_codppl = hpa_codppl
			AND dss_codemp = hpa_codemp), 0.00) valor
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
	AND sco.permiso_empleo(hpa_codemp, @usuario) = 1
ORDER BY exp_codigo_alternativo