IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('rel.rep_horas_empleados'))
BEGIN
	DROP PROCEDURE rel.rep_horas_empleados
END

GO

/*
Codigo: HorasEmpleados
Nombre: Horas de Empleados
Descripción: 

Parametros
- Compañía (No visible)
- Tipo planilla
- Planilla
- Empleado
- Uusario (No visiblie)

Campos
- Compañía
- Tipo Planilla
- Fecha de inicio de planilla
- Fecha de fin de planilla
- Departamento
- Código de empleado
- Nombre de empleado
- Por cada uno de los tipos de horas extras
	- Encabezado
		- Abreviatura
	- Columnas
		- Número de horas
	- Totales
		- Total de horas

Totales
	- Total de horas por empleado
	- Total por tipo de hora extra
	- Total por unidad administrativa
	
Agrupamiento
- Unidad administrativa

Ordenamiento
- Codigo de empleado
- Codigo de tipo hora extra
*/
--EXEC rel.rep_horas_empleados 1, '4', '20150604', NULL, 'admin'
CREATE PROCEDURE rel.rep_horas_empleados (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@codexp_alternativo VARCHAR(36) = NULL,
	@usuario varchar(100) = NULL
)

AS

SET NOCOUNT ON
SET DATEFIRST 7
SET DATEFORMAT DMY
SET LANGUAGE spanish

DECLARE	@codtpl INT,
	@codppl INT,
	@codemp INT,
	@ppl_fecha_ini DATETIME, 
	@ppl_fecha_fin DATETIME, 
	@tpl_descripcion VARCHAR(50)
		
SET @usuario = ISNULL(@usuario, SYSTEM_USER)

SELECT @codtpl = tpl_codigo,
	@tpl_descripcion = tpl_descripcion
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia 
	AND tpl_codigo_visual = @codtpl_visual

SELECT @codppl = ppl_codigo,
	@ppl_fecha_ini = ppl_fecha_ini, 
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl 
	AND ppl_codigo_planilla = @codppl_visual

SET @codemp = gen.obtiene_codigo_empleo(@codexp_alternativo)

SELECT cia_descripcion,
	@tpl_descripcion tpl_descripcion,
	@ppl_fecha_ini ppl_fecha_ini,
	@ppl_fecha_fin ppl_fecha_fin,
	uni_descripcion,
	NULL uni_orden,
	exp_codigo_alternativo,
	exp_nombres_apellidos,
	ext_codthe,
	the_abreviatura,
	ext_num_horas
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas on emp_codplz = plz_codigo
	JOIN eor.uni_unidades ON plz_coduni = uni_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	LEFT JOIN sal.ext_horas_extras ON ext_codemp = emp_codigo
	LEFT JOIN sal.the_tipos_hora_extra ON ext_codthe = the_codigo
WHERE emp_codigo = ISNULL(@codemp, emp_codigo)
	AND ext_codppl = @codppl
	AND ext_generado_reloj = 1
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1
ORDER BY uni_orden, exp_codigo_alternativo, ext_codthe