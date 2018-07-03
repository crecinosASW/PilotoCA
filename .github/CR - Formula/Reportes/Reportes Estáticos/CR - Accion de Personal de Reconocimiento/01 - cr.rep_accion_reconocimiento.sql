IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_accion_reconocimiento'))
BEGIN
	DROP PROCEDURE cr.rep_accion_reconocimiento
END

GO

--EXEC cr.rep_accion_reconocimiento 1, '2698', '04/03/2015', NULL, 'admin'
CREATE PROCEDURE cr.rep_accion_reconocimiento (
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
	@fecha DATETIME

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)
SET @fecha = CONVERT(DATETIME, @fecha_txt)

SELECT cia_descripcion acc_compania,
	rec_codigo acc_numero,
	'REC' acc_abreviatura,
	'RECONOCIMIENTO' acc_tipo,
	rec_fecha_merito acc_fecha_accion,
	exp_codigo_alternativo acc_codigo_empleado,
	exp_apellidos_nombres acc_nombre,
	ide_cip acc_cedula,
	emp_fecha_ingreso acc_fecha_ingreso,
	plz_nombre acc_puesto,
	cco_descripcion acc_centro_costo,
	uni_descripcion acc_departamento,
	tpl_descripcion acc_nomina,
	'REC' acc_ausencia,
	rec_fecha_merito acc_fecha_rige,
	NULL acc_fecha_hasta,
	NULL acc_dias,
	NULL acc_estado,
	NULL acc_salario,
	NULL acc_moneda,
	ISNULL(@comentario, rec_descripcion) acc_comentario,
	@usuario acc_usuario
FROM acc.rec_reconocimientos
	JOIN exp.emp_empleos ON rec_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.uni_unidades ON plz_coduni = uni_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN sal.tpl_tipo_planilla ON emp_codtpl = tpl_codigo
	LEFT JOIN eor.cpp_centros_costo_plaza ON plz_codigo = cpp_codplz
	LEFT JOIN eor.cco_centros_de_costo ON cpp_codcco = cco_codigo
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE plz_codcia = @codcia
	AND emp_codigo = @codemp
	AND rec_fecha_merito = @fecha
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE codemp = emp_codigo)