IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_accion_movimiento'))
BEGIN
	DROP PROCEDURE cr.rep_accion_movimiento
END

GO

--EXEC cr.rep_accion_movimiento 1, '1036', '01/03/2015', NULL, 'admin'
CREATE PROCEDURE cr.rep_accion_movimiento (
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
	mov_codigo acc_numero,
	'MOV' acc_abreviatura,
	'MOVIMIENTO' acc_tipo,
	mov_fecha_vigencia acc_fecha_accion,
	exp_codigo_alternativo acc_codigo_empleado,
	exp_apellidos_nombres acc_nombre,
	ide_cip acc_cedula,
	emp_fecha_ingreso acc_fecha_ingreso,
	p2.plz_nombre acc_puesto_anterior,
	c2.cco_descripcion acc_centro_costo_anterior,
	u2.uni_descripcion acc_departamento_anterior,
	p1.plz_nombre acc_puesto,
	c1.cco_descripcion acc_centro_costo,
	u1.uni_descripcion acc_departamento,
	tpl_descripcion acc_nomina,
	NULL acc_ausencia,
	mov_fecha_vigencia acc_fecha_rige,
	NULL acc_fecha_hasta,
	NULL acc_dias,
	'MOV' acc_estado,
	NULL acc_salario,
	NULL acc_moneda,
	ISNULL(@comentario, mov_motivo) acc_comentario,
	@usuario acc_usuario
FROM acc.mov_movimientos
	JOIN exp.emp_empleos ON mov_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas p1 ON mov_codplz_nuevo = p1.plz_codigo
	JOIN eor.uni_unidades u1 ON p1.plz_coduni = u1.uni_codigo
	JOIN eor.plz_plazas p2 ON mov_codplz_anterior = p2.plz_codigo
	JOIN eor.uni_unidades u2 ON p2.plz_coduni = u2.uni_codigo
	JOIN eor.cia_companias ON p1.plz_codcia = cia_codigo
	JOIN sal.tpl_tipo_planilla ON emp_codtpl = tpl_codigo
	LEFT JOIN eor.cpp_centros_costo_plaza e1 ON p1.plz_codigo = e1.cpp_codplz
	LEFT JOIN eor.cco_centros_de_costo c1 ON e1.cpp_codcco = c1.cco_codigo
	LEFT JOIN eor.cpp_centros_costo_plaza e2 ON p2.plz_codigo = e2.cpp_codplz
	LEFT JOIN eor.cco_centros_de_costo c2 ON e2.cpp_codcco = c2.cco_codigo
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE p1.plz_codcia = @codcia
	AND emp_codigo = @codemp
	AND mov_fecha_vigencia = @fecha
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE codemp = emp_codigo)