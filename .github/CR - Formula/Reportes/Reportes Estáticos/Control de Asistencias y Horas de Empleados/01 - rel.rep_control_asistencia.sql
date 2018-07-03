IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('rel.rep_control_asistencia'))
BEGIN
	DROP PROCEDURE rel.rep_control_asistencia
END

GO

/*
Codigo: ControlAsistenciasHorasEmpleados
Nombre: Control de Asistencias y Horas de Empleados
Descripción: Reporte que muestra las asistencias que realizó un empleado en los días de la planilla y las horas que le genra el sistema

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
- Para cada uno de los días de la planilla
	- Encabezado
		- Fecha de planilla
		- Día
		- Jornada
	- Columnas
		- Entrada
		- Salida
		- Almuerzo Inicio
		- Almuerzo Fin
		- Abreviatura de horas extras
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
- Orden de unidad administrativa
- Codigo de empleado
*/
--EXEC rel.rep_control_asistencia 1, '4', '20150604', NULL, 'admin'
CREATE PROCEDURE rel.rep_control_asistencia (
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
	jor_descripcion,
	@ppl_fecha_ini + number ppl_fecha,
	DATENAME(DW, @ppl_fecha_ini + number) dia,
	asi_hora_entrada_1,
	asi_hora_salida_1,
	asi_hora_entrada_2,
	asi_hora_salida_2,
	asi_hora_entrada_3,
	asi_hora_salida_3,
	ext_codthe,
	the_abreviatura,
	ext_num_horas
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas on emp_codplz = plz_codigo
	JOIN eor.uni_unidades ON plz_coduni = uni_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN (SELECT number FROM master..spt_values WHERE TYPE = 'P') c ON (@ppl_fecha_ini + number) <= @ppl_fecha_fin AND (@ppl_fecha_ini + number) BETWEEN emp_fecha_ingreso AND @ppl_fecha_fin
	LEFT JOIN rel.asi_asistencias ON emp_codigo = asi_codemp AND asi_codppl = @codppl AND asi_fecha = @ppl_fecha_ini + number
	LEFT JOIN sal.jor_jornadas ON asi_codjor = jor_codigo
	LEFT JOIN sal.ext_horas_extras ON ext_codemp = emp_codigo AND ext_codppl = @codppl AND CONVERT(DATE, ext_fecha) = CONVERT(DATE, @ppl_fecha_ini + number) AND ext_generado_reloj = 1
	LEFT JOIN sal.the_tipos_hora_extra ON ext_codthe = the_codigo
WHERE emp_codigo = ISNULL(@codemp, emp_codigo)
	AND EXISTS (SELECT NULL
				FROM rel.asi_asistencias
				WHERE asi_codemp = emp_codigo
					AND asi_codppl = @codppl)
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1
ORDER BY uni_descripcion, exp_codigo_alternativo, ext_codthe