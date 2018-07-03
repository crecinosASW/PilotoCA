IF EXISTS (SELECT 1
		   FROM sys.objects 
		   WHERE object_id = object_id('cr.rep_planilla_bcr_rev'))
BEGIN
	DROP PROCEDURE cr.rep_planilla_bcr_rev
END

GO

--EXEC cr.rep_planilla_bcr_rev 1, '1', '201438', 1, '1003', 'admin'
CREATE PROCEDURE cr.rep_planilla_bcr_rev (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@num_correlativo VARCHAR(3) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@codppl INT,
	@codbca_bcr INT,
	@cia_cuenta VARCHAR(50),
	@cia_codmon_cuenta VARCHAR(3),
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

SET @codbca_bcr = gen.get_valor_parametro_int('CodigoBCA_BCR', @codpai, NULL, NULL, NULL)
SET @cia_cuenta = gen.get_valor_parametro_varchar('CuentaBancoEmpresaBCR', NULL, NULL, @codcia, NULL)
SET @cia_codmon_cuenta = gen.get_valor_parametro_varchar('MonedaCuentaBancoEmpresa', NULL, NULL, @codcia, NULL)

SELECT cia_descripcion,
	cia_patronal,
	@cia_cuenta cia_cuenta,
	@cia_codmon_cuenta cia_codmon,
	@tpl_descripcion tpl_descripcion,
	ppl_codigo_planilla,
	CONVERT(VARCHAR, ppl_fecha_pago, 103) ppl_fecha_pago,
	RIGHT(REPLICATE('0', 3) + ISNULL(@num_correlativo, '1'), 3) num_correlativo,
	exp_codigo_alternativo,
	exp_apellidos_nombres,
	ISNULL(
		CASE 
			WHEN ide_cip IS NOT NULL AND LTRIM(RTRIM(ide_cip)) <> '' 
			THEN LTRIM(RTRIM(ide_cip))
			WHEN ide_residente IS NOT NULL AND LTRIM(RTRIM(ide_residente)) <> ''
			THEN LTRIM(RTRIM(ide_residente))
			WHEN ide_permiso IS NOT NULL AND LTRIM(RTRIM(ide_permiso)) <> ''
			THEN LTRIM(RTRIM(ide_permiso))
			WHEN ide_pasaporte IS NOT NULL AND LTRIM(RTRIM(ide_pasaporte)) <> ''
			THEN LTRIM(RTRIM(ide_pasaporte))
		END, '') ide_cedula,
	cbe_numero_cuenta,
	cbe_codmon,
	CONVERT(VARCHAR, row_number() OVER(ORDER BY exp_codigo_alternativo)) emp_correlativo,
	ROUND(
		ISNULL((
		SELECT SUM(ISNULL(inn_valor, 0.00))
		FROM sal.inn_ingresos
		WHERE inn_codppl = ppl_codigo
			AND inn_codemp = hpa_codemp), 0.00) -
	ISNULL((
		SELECT SUM(ISNULL(dss_valor, 0.00))
		FROM sal.dss_descuentos
		WHERE dss_codppl = ppl_codigo
			AND dss_codemp = hpa_codemp), 0.00), 2) valor
FROM sal.hpa_hist_periodos_planilla
	JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
	JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN exp.cbe_cuentas_banco_exp ON exp_codigo = cbe_codexp
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE hpa_codppl = @codppl
	AND cbe_codbca = @codbca_bcr    
	AND EXISTS (SELECT NULL
				FROM sal.inn_ingresos
				WHERE inn_codppl = hpa_codppl
					AND inn_codemp = hpa_codemp
					AND inn_valor > 0.00)
	AND sco.permiso_empleo(hpa_codemp, @usuario) = 1
ORDER BY exp_codigo_alternativo