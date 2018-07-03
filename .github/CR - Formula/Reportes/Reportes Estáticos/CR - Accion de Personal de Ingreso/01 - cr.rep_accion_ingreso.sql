IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_accion_ingreso'))
BEGIN
	DROP PROCEDURE cr.rep_accion_ingreso
END

GO

--EXEC cr.rep_accion_ingreso 1, '4056', '01/03/2015', 'SE APLICARA AJUSTE SALARIAL AL FINALIZAR EL PERIODO DE PRUEBA.', 'admin'
CREATE PROCEDURE cr.rep_accion_ingreso (
	@codcia INT = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@fecha_txt VARCHAR(10) = NULL,
	@comentario VARCHAR(500) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET DATEFORMAT DMY
SET NOCOUNT ON

DECLARE @codemp INT,
	@fecha DATETIME,
	@codrsa_salario INT

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)
SET @fecha = CONVERT(DATETIME, @fecha_txt)
SET @codrsa_salario = gen.get_valor_parametro_int('CodigoRSA_Salario', NULL, NULL, @codcia, NULL)

SELECT cia_descripcion acc_compania,
	con_codigo acc_numero,
	'ING' acc_abreviatura,
	'INGRESO' acc_tipo,
	con_fecha_ingreso acc_fecha_accion,
	exp_codigo_alternativo acc_codigo_empleado,
	exp_apellidos_nombres acc_nombre,
	ide_cip acc_cedula,
	con_fecha_ingreso acc_fecha_ingreso,
	plz_nombre acc_puesto,
	cco_descripcion acc_centro_costo,
	uni_descripcion acc_departamento,
	tpl_descripcion acc_nomina,
	NULL acc_ausencia,
	con_fecha_ingreso acc_fecha_rige,
	NULL acc_fecha_hasta,
	NULL acc_dias,
	'ACT' acc_estado,
	ROUND(esc_valor, 2) acc_salario,
	esc_codmon acc_moneda,
	@comentario acc_comentario,
	@usuario acc_usuario
FROM acc.con_contrataciones
	JOIN exp.exp_expedientes ON con_codexp = exp_codigo
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp AND con_fecha_ingreso = emp_fecha_ingreso
	JOIN eor.plz_plazas ON con_codplz = plz_codigo
	JOIN eor.uni_unidades ON plz_coduni = uni_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN sal.tpl_tipo_planilla ON con_codtpl = tpl_codigo
	LEFT JOIN eor.cpp_centros_costo_plaza ON plz_codigo = cpp_codplz
	LEFT JOIN eor.cco_centros_de_costo ON cpp_codcco = cco_codigo
	LEFT JOIN acc.esc_estructura_sal_contratos ON esc_codcon = con_codigo AND esc_codrsa = @codrsa_salario
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE plz_codcia = @codcia
	AND emp_codigo = @codemp
	AND emp_fecha_ingreso = @fecha
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE codemp = emp_codigo)