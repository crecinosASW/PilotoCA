	IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_accion_incremento'))
BEGIN
	DROP PROCEDURE cr.rep_accion_incremento
END

GO

--EXEC cr.rep_accion_incremento 1, '1025', '15/03/2015', NULL, 'admin'
CREATE PROCEDURE cr.rep_accion_incremento (
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
	inc_codigo acc_numero,
	'INC' acc_abreviatura,
	'INCREMENTO' acc_tipo,
	idr_fecha_vigencia acc_fecha_accion,
	exp_codigo_alternativo acc_codigo_empleado,
	exp_apellidos_nombres acc_nombre,
	ide_cip acc_cedula,
	emp_fecha_ingreso acc_fecha_ingreso,
	plz_nombre acc_puesto,
	cco_descripcion acc_centro_costo,
	uni_descripcion acc_departamento,
	tpl_descripcion acc_nomina,
	NULL acc_ausencia,
	idr_fecha_vigencia acc_fecha_rige,
	NULL acc_fecha_hasta,
	NULL acc_dias,
	NULL acc_estado,
	idr_valor acc_salario,
	idr_codmon acc_moneda,
	ISNULL(@comentario, inc_motivo) acc_comentario,
	@usuario acc_usuario
FROM acc.inc_incrementos
	JOIN acc.idr_incremento_detalle_rubros ON inc_codigo = idr_codinc AND idr_codrsa = @codrsa_salario
	JOIN exp.emp_empleos ON inc_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN exp.ese_estructura_sal_empleos ON idr_codese = ese_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.uni_unidades ON plz_coduni = uni_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN sal.tpl_tipo_planilla ON emp_codtpl = tpl_codigo
	LEFT JOIN eor.cpp_centros_costo_plaza ON plz_codigo = cpp_codplz
	LEFT JOIN eor.cco_centros_de_costo ON cpp_codcco = cco_codigo
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE plz_codcia = @codcia
	AND emp_codigo = @codemp
	AND idr_fecha_vigencia = @fecha
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE codemp = emp_codigo)