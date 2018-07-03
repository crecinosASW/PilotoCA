IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('rel.procesa_marcas'))
BEGIN
	DROP PROCEDURE rel.procesa_marcas
END

GO

/*
	Proceso de interpretación de marcas de reloj
	--------------------------------------------

	Creado por: Carlos Soria
				6-Julio-2014

	La forma de importación de marcas de reloj en el módulo de Control de Asistencia de Evolution
	o la ejecución de la plantilla de importación con EvoImport.Exe, permite que las marcaciones
	existentes en un archivo texto se carguen a la tabla de marcas rel.mar_marcas.
   
	Una vez están allí, este proceso las interpreta de acuerdo a las políticas implementadas y a 
	la asistencia teórica de los empleados a través de su asociación a jornadas laborales.

	Al terminar la ejecución el proceso marca los registros como Procesados o no Procesados
	y llena la tabla rel.asi_asistencias con la interpretacion realizada para que el proceso
	de generación de tiempos no trabajados y horas extras pueda ser ejecutado.

	Si el parametro codigo de empleado no es nulo, entonces ejecuta para el empleado seleccionado
	Si el paraemtro codigo de grupo no es nulo, entonces ejecuta para los empleados del grupo seleccionado
	Si el parametro codigo de unidad no es nulo, entonces ejecuta para los empleados de la unidad seleccionada

	Descripción: Este proceso se encarga de analizar las marcas ingresadas de los empleados y identificar cual es la marca de salida y
				 entrada, también determinar cuál es la jornada que más se ajusta al horario, en base a esto crea un registro en la
				 tabla de asistencias. Para determinar las marcas de entrada y de salida revisa las marcas que están más próximas entre ellas.

	Alcance: Este proceso toma en cuenta que se realizan 2 marcas una de entrada y una de salida (sin marcas de almuerzo y de horas extras)
    
	Proceso:
		- Elimina las marcas según la política la minima diferencia entre dos marcas (en minutos)
			- Recorre cada una de las marcas
			- Obtiene la marca anterior y la marca actual
			- Obtiene el número de minutos entre la marca anterior y la marca actual
			- Si el número de minutos es menor al número de minutos para excluir la marca
				- Actualiza la marca actual y la ponde con el estado Fallida
		- Identifica la marca de entrada y salida del día
			- Obtiene la marca anterior (MP)
			- Obtiene la marca actual (MA)
			- Obtiene la marca siguiente (MS)
			- Obtiene las horas actuales (HA)
				- Diferencia en horas de marca actual y marca anterior
			- Obtiene las horas siguientes (HS)
				- Diferencia en horas de marca siguiente y marca actual
			- Si HA <= HS
				- Determina la hora de entrada es igual a la marca anterior
				- Determina la hora de salida es igual a la marca actual
			- De lo contrario
				- Determina la hora de entrada es igual a la marca actual
				- Determina la hora de salida es igual a la marca siguiente
			- Actualiza el estado de las marcas a procesada
			- Obtiene la siguiente marca y actualiza MP, MA y MS
		- Identifica la jornada a la que pertence para cada día de la planilla
			- Recorre las marcas de hora de entrada (HE) y hora de salida (HS) de cada uno de los empleados
			- Para cada par de marcas HE y HS recorre cada una de las jornadas
				- Obtiene la hora de entrada de la jornada (JE) y la hora de salida de la jornada (JS)
				- Si tiene marcas en ese día
					- Obtiene el número de horas de entrada (NE), según el valor absoluto de la diferencia entre HE y JE
					- Obtiene el número de horas de salida (NS), según el valor absoluto de la diferencia entre HS y JS
					- Obtiene el total de horas (NT), NT -> NE + NS
					- Si el NT es el menor comparado con las demás jornadas, asigna esa jornada al empleado para ese día
					- Si la jornada es igual a la jornada que tiene asignado el empleado por defecto no la asigna en ese día
					- Sino encuentra ninguna jornada le asigna la jornada por defecto
				- Si no tiene marcas en ese día
					- Busca la jornada asignada que más se repite en las fechas de la planilla para ese empleado y que su día de descanso sea el día actual
					- Si no le asigna la jornada que más se repite
					- Si no le asigna la jornada del día anterior
					- Si no existe le asigna la jornada por defecto
		- Crea asistencias según las horas de entrada y horas de salida
*/
--EXEC rel.procesa_marcas 1, '4', '20150604', NULL, 'admin'
CREATE PROCEDURE rel.procesa_marcas (
    @codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@codexp_alternativo VARCHAR(36) = NULL,
	@usuario VARCHAR(100) = NULL
)

AS

SET NOCOUNT ON
SET DATEFIRST 7
SET DATEFORMAT DMY

DECLARE	@fecha_ini DATETIME, 
	@fecha_fin DATETIME, 
	@mensaje VARCHAR(500),
	@codtpl INT,
	@codppl INT,
	@codemp INT
		
SET @usuario = ISNULL(@usuario, SYSTEM_USER)

SELECT @codtpl = tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia 
	AND tpl_codigo_visual = @codtpl_visual

SELECT @codppl = ppl_codigo,
	@fecha_ini = ppl_fecha_ini, 
	@fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl 
	AND ppl_codigo_planilla = @codppl_visual
	AND ppl_estado <> 'Autorizado'

SET @codemp = gen.obtiene_codigo_empleo(@codexp_alternativo)

IF @codtpl IS NULL
	SET @mensaje = @mensaje + 'No existe el tipo de planilla con el código: ' + ISNULL(@codtpl_visual, 'Vacío') + '; ' + CHAR(13)	

IF @codppl IS NULL
	SET @mensaje = @mensaje + 'No existe o está autorizado el período de planilla con el código: ' + ISNULL(@codppl_visual, 'Vacío') + '; ' + CHAR(13)	

IF @codexp_alternativo IS NOT NULL AND @codemp IS NULL
	SET @mensaje = @mensaje + 'No existe o no esta activo el empleado con el código: ' + ISNULL(@codexp_alternativo, 'Vacío') + '; ' + CHAR(13)

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END

DECLARE @estado_marca_procesada VARCHAR(20),
	@estado_marca_fallida VARCHAR(20),
	@estado_marca_no_proc VARCHAR(20),
	@minutos_entre_marcas REAL,
	@minutos_ajuste REAL,
	@num_horas_valida REAL,
	@estado_asi_gen VARCHAR(20),
	@estado_workflow_asi_gen VARCHAR(20),
	@estado_marca_indefinido VARCHAR(20),
	@estado_marca_entrada VARCHAR(20),
	@estado_marca_salida VARCHAR(20),
	@mar_codemp INT, 
	@mar_codemp_anterior INT,
	@mar_fecha DATETIME,
	@mar_fecha_anterior DATETIME,
	@mar_fecha_actual DATETIME,
	@mar_fecha_siguiente DATETIME,
	@horas_actuales REAL,
	@horas_siguientes REAL,
	@horas_entrada REAL,
	@horas_salida REAL,
	@horas_totales REAL,
	@horas_min_jornada REAL,
	@emp_codjor INT,
	@mar_codjor INT,
	@asi_codemp INT,
	@asi_codjor INT,
	@asi_hora_entrada DATETIME,
	@asi_hora_entrada_ajus DATETIME,
	@asi_hora_salida DATETIME,
	@asi_hora_salida_ajus DATETIME,
	@asi_hora_entrada_sig DATETIME,
	@asi_hora_salida_ant DATETIME,
	@mar_tipo VARCHAR(20),
	@mar_tipo_anterior VARCHAR(20),
	@mar_tipo_actual VARCHAR(20),
	@mar_tipo_siguiente VARCHAR(20),
	@jor_codigo INT,
	@jor_codigo_visual VARCHAR(20),
	@jor_hora_entrada DATETIME,
	@jor_hora_salida DATETIME,
	@fecha_act DATETIME,
	@djo_dia_descanso INT,
	@contador INT

-- Parámetros de aplicación
SET @minutos_entre_marcas = gen.get_valor_parametro_INT('RelojMinutosEntreMarcasIguales', NULL, NULL, @codcia, NULL)
SET @minutos_ajuste = gen.get_valor_parametro_INT('RelojToleranciaMinutosExtras', NULL, NULL, @codcia, NULL)
SET @estado_marca_procesada = gen.get_valor_parametro_VARCHAR('RelojTipoMarcaProcesada', NULL, NULL, @codcia, NULL)
SET @estado_marca_fallida = gen.get_valor_parametro_VARCHAR('RelojTipoMarcaFallida', NULL, NULL, @codcia, NULL)
SET @estado_marca_no_proc = gen.get_valor_parametro_VARCHAR('RelojTipoMarcaNoProcesada', NULL, NULL, @codcia, NULL)
SET @estado_asi_gen = gen.get_valor_parametro_VARCHAR('RelojEstadoAsistenciaGenerada', NULL, NULL, @codcia, NULL)
SET @estado_workflow_asi_gen = gen.get_valor_parametro_VARCHAR('RelojEstadoWorkflowAsistenciaGenerada', NULL, NULL, @codcia, NULL)
SET @estado_marca_indefinido = gen.get_valor_parametro_VARCHAR('RelojTipoMarcaIndefinido', NULL, NULL, @codcia, NULL)
SET @estado_marca_entrada = gen.get_valor_parametro_VARCHAR('RelojTipoMarcaEntrada', NULL, NULL, @codcia, NULL)
SET @estado_marca_salida = gen.get_valor_parametro_VARCHAR('RelojTipoMarcaSalida', NULL, NULL, @codcia, NULL)
SET @num_horas_valida = 14.00

-- Inicializa los parametros que retornan NULL con valores por defecto
SET @minutos_ajuste = ISNULL(@minutos_ajuste, 25)
SET @minutos_entre_marcas = ISNULL(@minutos_entre_marcas, 30)
SET @estado_marca_procesada = ISNULL(@estado_marca_procesada, 'Procesada')
SET @estado_marca_fallida = ISNULL(@estado_marca_fallida, 'Fallida')
SET @estado_marca_no_proc = ISNULL(@estado_marca_no_proc, 'No Procesada')
SET @estado_asi_gen = ISNULL(@estado_asi_gen, 'Pendiente')
SET @estado_workflow_asi_gen = ISNULL(@estado_workflow_asi_gen, 'Pendiente')
SET @estado_marca_indefinido = ISNULL(@estado_marca_indefinido, 'I')
SET @estado_marca_entrada = ISNULL(@estado_marca_entrada, 'E')
SET @estado_marca_salida = ISNULL(@estado_marca_salida, 'S')
SET @contador = 0

--*
--* Incrementa en uno la fecha fin, para que el proceso tome marcas del dia siguiente
--* de la fecha de finalizacion del proceso.
--* De esta manera se resuelve el problema de la interpretación de la marca de salida
--* para turnos nocturnos o para extras que se pasan al siguiente dia
--*
IF ISNULL((SELECT tpl_asi_rango_fechas_ingreso
		   FROM sal.tpl_tipo_planilla 
		   WHERE tpl_codigo = @codtpl), ' ') = 'PeriodoAnterior'
BEGIN
	SELECT 
		@fecha_ini = ppl_fecha_ini,
		@fecha_fin = ppl_fecha_fin
	FROM sal.ppl_periodos_planilla
	WHERE ppl_codtpl = @codtpl 
		AND ppl_fecha_fin = (SELECT DATEADD(DD, -1, ppl_fecha_ini)
							 FROM sal.ppl_periodos_planilla
							 WHERE ppl_codigo = @codppl)
END

PRINT 'Compañía: ' + ISNULL(CONVERT(VARCHAR, @codcia), '')
PRINT 'Tipo Planilla: ' + ISNULL(@codtpl_visual, '')
PRINT 'Planilla: ' + ISNULL(@codppl_visual, '')
PRINT 'Empleado: ' + ISNULL(@codexp_alternativo, '')
PRINT 'Usuario: ' + ISNULL(@usuario, '')
PRINT 'Fecha Inicial: ' + ISNULL(CONVERT(VARCHAR, @fecha_ini, 103), '')
PRINT 'Fecha Final: ' + ISNULL(CONVERT(VARCHAR, @fecha_fin, 103), '')
PRINT 'Código Tipo Planilla: ' + ISNULL(CONVERT(VARCHAR, @codtpl), '')
PRINT 'Código Planilla: ' + ISNULL(CONVERT(VARCHAR, @codppl), '')
PRINT 'Código Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
PRINT 'Estado Marca Procesada: ' + ISNULL(@estado_marca_procesada, '')
PRINT 'Estado Marca Fallida: ' + ISNULL(@estado_marca_fallida, '')
PRINT 'Estado Marca No Procesada: ' + ISNULL(@estado_marca_no_proc, '')
PRINT 'Tipo Marca Indefinido: ' + ISNULL(@estado_marca_indefinido, '')
PRINT 'Tipo Marca Entrada: ' + ISNULL(@estado_marca_entrada, '')
PRINT 'Tipo Marca Salida: ' + ISNULL(@estado_marca_salida, '')
PRINT 'Estado Asistencia Generada: ' + ISNULL(@estado_asi_gen, '')
PRINT 'Estado Flujo Asistencia Generada: ' + ISNULL(@estado_workflow_asi_gen, '')

SET @fecha_ini = @fecha_ini - 1
SET @fecha_fin = @fecha_fin + 1

-- Actualiza las marcas cen el rango especificado como PROCESADAS
UPDATE rel.mar_marcas 
SET mar_estado = @estado_marca_procesada,
	mar_tipo_marca = @estado_marca_indefinido
WHERE mar_fecha BETWEEN @fecha_ini AND @fecha_fin
	AND mar_codemp = ISNULL(@codemp, mar_codemp)

-- Elimina las marcas según la política la minima diferencia entre dos marcas (en minutos)
PRINT 'Elimina las marcas según la política la minima diferencia entre dos marcas (en minutos)'
PRINT 'Minutos mínimos entre marcas: ' + ISNULL(CONVERT(VARCHAR, @minutos_entre_marcas), '')
DECLARE marcas CURSOR FOR
SELECT mar_codemp, mar_fecha_hora 
FROM rel.mar_marcas
	JOIN exp.emp_empleos ON mar_codemp = emp_codigo
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE mar_codemp = ISNULL(@codemp, emp_codigo)
	AND emp_codtpl = @codtpl
	AND emp_estado = 'A'
	AND ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, 'emp_marca_asistencia'), 0) = 1
	AND mar_fecha BETWEEN @fecha_ini AND @fecha_fin 
ORDER BY mar_codemp, mar_fecha_hora

OPEN marcas

FETCH NEXT FROM marcas INTO @mar_codemp, @mar_fecha_actual

WHILE @@FETCH_STATUS = 0
BEGIN
	IF ISNULL(@mar_codemp_anterior, @mar_codemp + 1) <> @mar_codemp BEGIN
		SET @mar_codemp_anterior = @mar_codemp
		SET @mar_fecha_anterior = NULL
	END

	PRINT 'Empleado: ' + ISNULL(CONVERT(VARCHAR, @mar_codemp), '')
	PRINT 'Empleado Anterior: ' + ISNULL(CONVERT(VARCHAR, @mar_codemp_anterior), '')
	PRINT 'Marca Anterior: ' + ISNULL(CONVERT(VARCHAR, @mar_fecha_anterior, 120), '')
	PRINT 'Marca Actual: ' + ISNULL(CONVERT(VARCHAR, @mar_fecha_actual, 120), '')
	PRINT 'Diferencia Mintutos: ' + ISNULL(CONVERT(VARCHAR, DATEDIFF(MI, @mar_fecha_anterior, @mar_fecha_actual)), '')
	
	IF DATEDIFF(MI, @mar_fecha_anterior, @mar_fecha_actual) < @minutos_entre_marcas
	BEGIN
		PRINT 'Marca Fallida'
		UPDATE rel.mar_marcas
		SET mar_estado = @estado_marca_fallida
		WHERE mar_codemp = @mar_codemp 
			AND mar_fecha_hora = @mar_fecha_actual
	END

	SET @mar_fecha_anterior = @mar_fecha_actual
	PRINT ''

	FETCH NEXT FROM marcas INTO @mar_codemp, @mar_fecha_actual
END

CLOSE marcas
DEALLOCATE marcas

BEGIN TRANSACTION

DELETE rel.asi_asistencias
WHERE asi_fecha BETWEEN @fecha_ini AND @fecha_fin 
	AND asi_estado = @estado_asi_gen
	AND asi_codppl = @codppl
	AND asi_codemp = ISNULL(@codemp, asi_codemp)

DECLARE @mar_tipo_presente VARCHAR(20)

--Identifica la marca de entrada y salida del día
PRINT 'Identifica la marca de entrada y salida del día'
DECLARE marcas CURSOR FOR
SELECT mar_codemp, mar_fecha_hora, emp_codjor
FROM rel.mar_marcas
	JOIN exp.emp_empleos ON mar_codemp = emp_codigo
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE mar_codemp = ISNULL(@codemp, emp_codigo)
	AND mar_estado = @estado_marca_procesada
	AND emp_codtpl = @codtpl
	AND emp_estado = 'A'
	AND ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, 'emp_marca_asistencia'), 0) = 1
	AND mar_fecha BETWEEN @fecha_ini AND @fecha_fin 
ORDER BY mar_codemp, mar_fecha_hora

OPEN marcas

FETCH NEXT FROM marcas INTO @mar_codemp, @mar_fecha, @asi_codjor

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @asi_hora_entrada = NULL
	SET @asi_hora_salida = NULL

	IF ISNULL(@mar_codemp_anterior, @mar_codemp + 1) <> @mar_codemp BEGIN
		SET @mar_codemp_anterior = @mar_codemp
		SET @mar_fecha_anterior = NULL
		SET @mar_fecha_actual = NULL
		SET @mar_fecha_siguiente = NULL
		SET @mar_tipo_anterior = NULL
		SET @mar_tipo_actual = NULL
		SET @mar_tipo_siguiente = NULL
		SET @contador = 0
	END

	SET @mar_tipo = (SELECT mar_tipo_marca FROM rel.mar_marcas WHERE mar_codemp = @mar_codemp AND mar_fecha_hora = @mar_fecha)

	SET @mar_fecha_anterior = @mar_fecha_actual
	SET @mar_fecha_actual = @mar_fecha_siguiente
	SET @mar_fecha_siguiente = @mar_fecha
	SET @mar_tipo_anterior = @mar_tipo_actual
	SET @mar_tipo_actual = @mar_tipo_siguiente
	SET @mar_tipo_siguiente = @mar_tipo

	IF @contador = 0
	BEGIN 	
		SET @horas_actuales = ISNULL(DATEDIFF(MI, @mar_fecha_anterior, @mar_fecha_actual) / 60.00, 1000.00)
		SET @horas_siguientes = ISNULL(DATEDIFF(MI, @mar_fecha_actual, @mar_fecha_siguiente) / 60.00, 1000.00)
	
		IF /*@horas_actuales <= @horas_siguientes AND*/ @horas_actuales < @num_horas_valida
		BEGIN
			SET @contador = 1

			SET @asi_hora_entrada = @mar_fecha_anterior
			SET @asi_hora_salida = @mar_fecha_actual

			UPDATE rel.mar_marcas
			SET mar_tipo_marca = @estado_marca_entrada
			WHERE mar_codemp = @mar_codemp
				AND mar_fecha_hora = @mar_fecha_anterior

			UPDATE rel.mar_marcas
			SET mar_tipo_marca = @estado_marca_salida
			WHERE mar_codemp = @mar_codemp
				AND mar_fecha_hora = @mar_fecha_actual

			SET @mar_tipo_anterior = @estado_marca_entrada
			SET @mar_tipo_actual = @estado_marca_salida
		END
		ELSE IF /*@horas_siguientes < @horas_actuales AND*/ @horas_siguientes < @num_horas_valida
		BEGIN
			SET @contador = 2

			SET @asi_hora_entrada = @mar_fecha_actual
			SET @asi_hora_salida = @mar_fecha_siguiente

			UPDATE rel.mar_marcas
			SET mar_tipo_marca = @estado_marca_entrada
			WHERE mar_codemp = @mar_codemp
				AND mar_fecha_hora = @mar_fecha_actual

			UPDATE rel.mar_marcas
			SET mar_tipo_marca = @estado_marca_salida
			WHERE mar_codemp = @mar_codemp
				AND mar_fecha_hora = @mar_fecha_siguiente

			SET @mar_tipo_actual = @estado_marca_entrada
			SET @mar_tipo_siguiente = @estado_marca_salida
		END
	END
	ELSE
	BEGIN
		SET @contador = @contador - 1
	END

	PRINT 'Empleado: ' + ISNULL(CONVERT(VARCHAR, @mar_codemp), '')
	PRINT 'Empleado Anterior: ' + ISNULL(CONVERT(VARCHAR, @mar_codemp_anterior), '')
	PRINT 'Marca Anterior: ' + ISNULL(CONVERT(VARCHAR, @mar_fecha_anterior, 120), '')
	PRINT 'Marca Actual: ' + ISNULL(CONVERT(VARCHAR, @mar_fecha_actual, 120), '')
	PRINT 'Marca Siguiente: ' + ISNULL(CONVERT(VARCHAR, @mar_fecha_siguiente, 120), '')
	PRINT 'Tipo Marca: ' + ISNULL(@mar_tipo, '')
	PRINT 'Tipo Marca Anterior: ' + ISNULL(@mar_tipo_anterior, '')
	PRINT 'Tipo Marca Actual: ' + ISNULL(@mar_tipo_actual, '')
	PRINT 'Tipo Marca Siguiente: ' + ISNULL(@mar_tipo_siguiente, '')
	PRINT 'Horas Actuales: ' + ISNULL(CONVERT(VARCHAR, @horas_actuales), '')
	PRINT 'Horas Siguientes: ' + ISNULL(CONVERT(VARCHAR, @horas_siguientes), '')
	PRINT 'Fecha Asistencia: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_entrada, 103), '')
	PRINT 'Marca Entrada: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_entrada, 120), '')
	PRINT 'Marca Salida: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_salida, 120), '')
	PRINT 'Contador: ' + ISNULL(CONVERT(VARCHAR, @contador), '')
	PRINT ''

   FETCH NEXT FROM marcas INTO @mar_codemp, @mar_fecha, @asi_codjor
END

CLOSE marcas
DEALLOCATE marcas

PRINT '#Elimina'
DECLARE marcas CURSOR FOR
SELECT mar_codemp, mar_fecha_hora, mar_tipo_marca
FROM rel.mar_marcas
WHERE mar_codemp = ISNULL(@codemp, mar_codemp)
	AND mar_estado = @estado_marca_procesada
	AND mar_fecha BETWEEN @fecha_ini AND @fecha_fin 
ORDER BY mar_codemp, mar_fecha_hora

OPEN marcas

FETCH NEXT FROM marcas INTO @mar_codemp, @mar_fecha, @mar_tipo

WHILE @@FETCH_STATUS = 0
BEGIN
	IF ISNULL(@mar_codemp_anterior, @mar_codemp + 1) <> @mar_codemp BEGIN
		SET @mar_codemp_anterior = @mar_codemp
		SET @mar_fecha_anterior = NULL
		SET @mar_fecha_actual = NULL
		SET @mar_tipo_anterior = NULL
		SET @mar_tipo_actual = NULL
	END

	SET @mar_fecha_anterior = @mar_fecha_actual
	SET @mar_fecha_actual = @mar_fecha
	SET @mar_tipo_anterior = @mar_tipo_actual
	SET @mar_tipo_actual = @mar_tipo

	IF @mar_tipo_anterior = @mar_tipo_actual
	BEGIN
		UPDATE rel.mar_marcas
		SET mar_tipo_marca = @estado_marca_indefinido
		WHERE mar_codemp = @mar_codemp
			AND mar_fecha_hora = @mar_fecha_anterior
	END

	PRINT 'Empleado: ' + ISNULL(CONVERT(VARCHAR, @mar_codemp), '')
	PRINT 'Empleado Anterior: ' + ISNULL(CONVERT(VARCHAR, @mar_codemp_anterior), '')
	PRINT 'Marca Anterior: ' + ISNULL(CONVERT(VARCHAR, @mar_fecha_anterior, 120), '')
	PRINT 'Marca Actual: ' + ISNULL(CONVERT(VARCHAR, @mar_fecha_actual, 120), '')
	PRINT 'Tipo Marca Anterior: ' + ISNULL(@mar_tipo_anterior, '')
	PRINT 'Tipo Marca Actual: ' + ISNULL(@mar_tipo_actual, '')
	PRINT ''

	FETCH NEXT FROM marcas INTO @mar_codemp, @mar_fecha, @mar_tipo
END

CLOSE marcas
DEALLOCATE marcas

-- Depura marcas indefinidas que tengas menos de 15 horas
PRINT '#DepuraI'
DECLARE marcas CURSOR FOR
SELECT mar_codemp, mar_fecha_hora
FROM rel.mar_marcas
WHERE mar_codemp = ISNULL(@codemp, mar_codemp)
	AND mar_estado = @estado_marca_procesada
	AND mar_tipo_marca = @estado_marca_indefinido
	AND mar_fecha BETWEEN @fecha_ini AND @fecha_fin 
ORDER BY mar_codemp, mar_fecha_hora

OPEN marcas

FETCH NEXT FROM marcas INTO @mar_codemp, @mar_fecha

WHILE @@FETCH_STATUS = 0
BEGIN
	IF ISNULL(@mar_codemp_anterior, @mar_codemp + 1) <> @mar_codemp BEGIN
		SET @mar_codemp_anterior = @mar_codemp
		SET @mar_fecha_anterior = NULL
		SET @mar_fecha_actual = NULL
		SET @mar_fecha_siguiente = NULL
		SET @mar_tipo_anterior = NULL
		SET @mar_tipo_actual = NULL
		SET @mar_tipo_siguiente = NULL
		SET @asi_hora_entrada = NULL
		SET @asi_hora_salida = NULL
	END

	SET @mar_tipo = (SELECT mar_tipo_marca FROM rel.mar_marcas WHERE mar_codemp = @mar_codemp AND mar_fecha_hora = @mar_fecha)

	SET @mar_fecha_anterior = @mar_fecha_actual
	SET @mar_fecha_actual = @mar_fecha_siguiente
	SET @mar_fecha_siguiente = @mar_fecha
	SET @mar_tipo_anterior = @mar_tipo_actual
	SET @mar_tipo_actual = @mar_tipo_siguiente
	SET @mar_tipo_siguiente = @mar_tipo

	SET @horas_actuales = ISNULL(DATEDIFF(MI, @mar_fecha_anterior, @mar_fecha_actual) / 60.00, 1000.00)
	SET @horas_siguientes = ISNULL(DATEDIFF(MI, @mar_fecha_actual, @mar_fecha_siguiente) / 60.00, 1000.00)
	
	IF /*@horas_actuales <= @horas_siguientes AND*/ @horas_actuales < @num_horas_valida
	BEGIN
		SET @asi_hora_entrada = @mar_fecha_anterior
		SET @asi_hora_salida = @mar_fecha_actual

		UPDATE rel.mar_marcas
		SET mar_tipo_marca = @estado_marca_entrada
		WHERE mar_codemp = @mar_codemp
			AND mar_fecha_hora = @mar_fecha_anterior

		UPDATE rel.mar_marcas
		SET mar_tipo_marca = @estado_marca_salida
		WHERE mar_codemp = @mar_codemp
			AND mar_fecha_hora = @mar_fecha_actual

		SET @mar_tipo_anterior = @estado_marca_entrada
		SET @mar_tipo_actual = @estado_marca_salida
	END
	ELSE IF /*@horas_siguientes < @horas_actuales AND*/ @horas_siguientes < @num_horas_valida
	BEGIN
		SET @asi_hora_entrada = @mar_fecha_actual
		SET @asi_hora_salida = @mar_fecha_siguiente

		UPDATE rel.mar_marcas
		SET mar_tipo_marca = @estado_marca_entrada
		WHERE mar_codemp = @mar_codemp
			AND mar_fecha_hora = @mar_fecha_actual

		UPDATE rel.mar_marcas
		SET mar_tipo_marca = @estado_marca_salida
		WHERE mar_codemp = @mar_codemp
			AND mar_fecha_hora = @mar_fecha_siguiente

		SET @mar_tipo_actual = @estado_marca_entrada
		SET @mar_tipo_siguiente = @estado_marca_salida

	END

	PRINT 'Empleado: ' + ISNULL(CONVERT(VARCHAR, @mar_codemp), '')
	PRINT 'Empleado Anterior: ' + ISNULL(CONVERT(VARCHAR, @mar_codemp_anterior), '')
	PRINT 'Marca Anterior: ' + ISNULL(CONVERT(VARCHAR, @mar_fecha_anterior, 120), '')
	PRINT 'Marca Actual: ' + ISNULL(CONVERT(VARCHAR, @mar_fecha_actual, 120), '')
	PRINT 'Marca Siguiente: ' + ISNULL(CONVERT(VARCHAR, @mar_fecha_siguiente, 120), '')
	PRINT 'Tipo Marca: ' + ISNULL(@mar_tipo, '')
	PRINT 'Tipo Marca Anterior: ' + ISNULL(@mar_tipo_anterior, '')
	PRINT 'Tipo Marca Actual: ' + ISNULL(@mar_tipo_actual, '')
	PRINT 'Tipo Marca Siguiente: ' + ISNULL(@mar_tipo_siguiente, '')
	PRINT 'Horas Actuales: ' + ISNULL(CONVERT(VARCHAR, @horas_actuales), '')
	PRINT 'Horas Siguientes: ' + ISNULL(CONVERT(VARCHAR, @horas_siguientes), '')
	PRINT 'Fecha Asistencia: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_entrada, 103), '')
	PRINT 'Marca Entrada: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_entrada, 120), '')
	PRINT 'Marca Salida: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_salida, 120), '')
	PRINT ''

	FETCH NEXT FROM marcas INTO @mar_codemp, @mar_fecha
END

CLOSE marcas
DEALLOCATE marcas

PRINT 'Crea asistencias en días laborados'
DECLARE marcas CURSOR FOR
SELECT mar_codemp, 
	mar_fecha_hora, 
	mar_tipo_marca,
	ISNULL(jpe_codjor, ISNULL(jpg_codjor, jpu_codjor)) mar_codjor,
	emp_codjor
FROM rel.mar_marcas
	JOIN exp.emp_empleos ON mar_codemp = emp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	LEFT JOIN rel.jpe_jornadas_empleos ON jpe_codemp = mar_codemp AND mar_fecha = jpe_fecha
	LEFT JOIN rel.jpu_jornadas_unidades ON jpu_coduni = plz_coduni AND mar_fecha = jpu_fecha
	LEFT JOIN rel.gre_grupos_empleos ON gre_codemp = emp_codigo and mar_fecha BETWEEN gre_fecha_inicio and ISNULL(gre_fecha_fin, mar_fecha)
	LEFT JOIN rel.jpg_jornadas_grupos ON jpg_codgra = gre_codgra and jpg_fecha = mar_fecha
WHERE mar_codemp = ISNULL(@codemp, mar_codemp)
	AND mar_estado = @estado_marca_procesada
	AND mar_tipo_marca IN (@estado_marca_entrada, @estado_marca_salida)
	AND mar_fecha BETWEEN @fecha_ini AND @fecha_fin 
ORDER BY mar_codemp, mar_fecha_hora

OPEN marcas

FETCH NEXT FROM marcas INTO @mar_codemp, @mar_fecha, @mar_tipo, @mar_codjor, @emp_codjor

WHILE @@FETCH_STATUS = 0
BEGIN
	IF ISNULL(@mar_codemp_anterior, @mar_codemp + 1) <> @mar_codemp BEGIN
		SET @mar_codemp_anterior = @mar_codemp
		SET @asi_hora_entrada = NULL
	END

	IF @mar_tipo = @estado_marca_entrada
	BEGIN
		SET @asi_hora_entrada = @mar_fecha
		SET @asi_hora_entrada_ajus = NULL
		SET @asi_hora_entrada_sig = NULL
		SET @asi_hora_salida = NULL
		SET @asi_hora_salida_ajus = NULL
		SET @asi_hora_salida_ant = NULL
		SET @asi_codjor = NULL
	END

	IF @mar_tipo = @estado_marca_salida
		SET @asi_hora_salida = @mar_fecha

	PRINT 'Empleado: ' + ISNULL(CONVERT(VARCHAR, @mar_codemp), '')
	PRINT 'Empleado Anterior: ' + ISNULL(CONVERT(VARCHAR, @mar_codemp_anterior), '')
	PRINT 'Tipo Marca: ' + ISNULL(@mar_tipo, '')
	PRINT 'Jornada Asignada en Marcas: ' + ISNULL(CONVERT(VARCHAR, @mar_codjor), '')
	PRINT 'Jornada de Empleado: ' + ISNULL(CONVERT(VARCHAR, @emp_codjor), '')
	PRINT 'Marca Entrada: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_entrada, 120), '')
	PRINT 'Marca Salida: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_salida, 120), '')
	PRINT ''

	IF @asi_hora_entrada IS NOT NULL AND @asi_hora_salida IS NOT NULL
	BEGIN
		PRINT 'Aproximación a medias horas según política de minutos'
		-- Ajuste de hora de entrada
		SET @asi_hora_entrada_sig = DATEADD(HH, 1, DATEADD(MI, -DATEPART(MI, @asi_hora_entrada), @asi_hora_entrada))

		IF DATEDIFF(MI, @asi_hora_entrada, @asi_hora_entrada_sig) <= @minutos_ajuste
			SET @asi_hora_entrada_ajus = @asi_hora_entrada_sig
		ELSE
			SET @asi_hora_entrada_ajus = DATEADD(HH, -1, @asi_hora_entrada_sig)

		-- Ajuste de hora de salida
		SET @asi_hora_salida_ant = DATEADD(MI, -DATEPART(MI, @asi_hora_salida), @asi_hora_salida)

		IF DATEDIFF(MI, @asi_hora_salida_ant, @asi_hora_salida) <= @minutos_ajuste
			SET @asi_hora_salida_ajus = @asi_hora_salida_ant
		ELSE
			SET @asi_hora_salida_ajus = DATEADD(HH, 1, @asi_hora_salida_ant)

		PRINT 'Marca Entrada Siguiente: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_entrada_sig, 120), '')
		PRINT 'Marca Entrada Ajustada: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_entrada_ajus, 120), '')
		PRINT 'Marca Salida Anterior: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_salida_ant, 120), '')
		PRINT 'Marca Salida Ajustada: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_salida_ajus, 120), '')

		PRINT 'Compararacion entre jornadas'
		IF @mar_codjor IS NOT NULL		
		BEGIN
			SET @asi_codjor = @mar_codjor
		END
		ELSE
		BEGIN
			SET @horas_min_jornada = NULL

			DECLARE jornadas CURSOR FOR
			SELECT jor_codigo, 
				jor_codigo_visual,
				CONVERT(DATETIME, CONVERT(VARCHAR, @asi_hora_entrada, 103) + ' ' + CONVERT(VARCHAR, djo_hora_ini, 108)) djo_hora_ini, 
				CONVERT(DATETIME, CONVERT(VARCHAR, @asi_hora_salida, 103) + ' ' + CONVERT(VARCHAR, djo_hora_fin, 108)) djo_hora_fin
			FROM sal.jor_jornadas
				JOIN sal.djo_dias_jornada ON jor_codigo = djo_codjor AND djo_dia + 1 = DATEPART(DW, @asi_hora_entrada)
			WHERE djo_hora_ini IS NOT NULL
				AND djo_hora_fin IS NOT NULL
	
			OPEN jornadas

			FETCH NEXT FROM jornadas INTO @jor_codigo, @jor_codigo_visual, @jor_hora_entrada, @jor_hora_salida

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @horas_entrada = ABS(DATEDIFF(MI, @jor_hora_entrada, @asi_hora_entrada)) / 60.00
				SET @horas_salida = ABS(DATEDIFF(MI, @jor_hora_salida, @asi_hora_salida)) / 60.00
				SET @horas_totales = @horas_entrada + @horas_salida

				IF @horas_totales < ISNULL(@horas_min_jornada, 1000.00)
				BEGIN
					SET @horas_min_jornada = @horas_totales
					SET @asi_codjor = @jor_codigo
				END

				PRINT 'Código Jornada: ' + ISNULL(CONVERT(VARCHAR, @jor_codigo), '')
				PRINT 'Jornada: ' + ISNULL(CONVERT(VARCHAR, @jor_codigo_visual), '')
				PRINT 'Marca Entrada: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_entrada, 120), '')
				PRINT 'Marca Salida: ' + ISNULL(CONVERT(VARCHAR, @asi_hora_salida, 120), '')
				PRINT 'Jornada Entrada: ' + ISNULL(CONVERT(VARCHAR, @jor_hora_entrada, 120), '')
				PRINT 'Jornada Salida: ' + ISNULL(CONVERT(VARCHAR, @jor_hora_salida, 120), '')
				PRINT 'Horas Diferencia Entrada: ' + ISNULL(CONVERT(VARCHAR, @horas_entrada), '')
				PRINT 'Horas Diferencia Salida: ' + ISNULL(CONVERT(VARCHAR, @horas_salida), '')
				PRINT 'Horas Totales: ' + ISNULL(CONVERT(VARCHAR, @horas_totales), '')
				PRINT 'Horas Mínimas Jornada: ' + ISNULL(CONVERT(VARCHAR, @horas_min_jornada), '')
				PRINT 'Jornada Elegida: ' + ISNULL(CONVERT(VARCHAR, @asi_codjor), '')
				PRINT ''

				FETCH NEXT FROM jornadas INTO @jor_codigo, @jor_codigo_visual, @jor_hora_entrada, @jor_hora_salida
			END

			CLOSE jornadas
			DEALLOCATE jornadas

			SET @asi_codjor = ISNULL(@asi_codjor, @emp_codjor)
		END

		PRINT 'Jornada Asistencia: ' + ISNULL(CONVERT(VARCHAR, @asi_codjor), '')
		IF NOT EXISTS (SELECT NULL FROM rel.asi_asistencias WHERE asi_codemp = @mar_codemp AND asi_fecha = CONVERT(DATE, @asi_hora_entrada))
		BEGIN
			PRINT 'Crea registro de asistencia'
			INSERT INTO rel.asi_asistencias (
				asi_codemp,
				asi_codppl,
				asi_codjor,
				asi_estado,
				asi_fecha,
				asi_hora_entrada_1,
				asi_hora_salida_1,
				asi_accion,
				asi_estado_workflow,
				asi_fecha_cambio_estado,
				asi_usuario_grabacion,
				asi_fecha_grabacion)
			SELECT @mar_codemp asi_codemp,
				@codppl asi_codppl,
				@asi_codjor asi_codjor,
				@estado_asi_gen asi_estado,
				CONVERT(DATE, @asi_hora_entrada) asi_fecha,
				@asi_hora_entrada_ajus asi_hora_entrada_1,
				@asi_hora_salida_ajus asi_hora_salida_1,
				'Generada' asi_accion,
				@estado_workflow_asi_gen asi_estado_workflow,
				GETDATE() asi_fecha_cambio_estado,
				@usuario asi_usuario_grabacion,
				GETDATE() asi_fecha_grabacion			
		END
		ELSE
		BEGIN
			PRINT 'Actualiza horarios, cuando ya existe asistencia en la misma fecha'
			UPDATE rel.asi_asistencias
			SET asi_hora_entrada_3 = @asi_hora_entrada_ajus,
				asi_hora_salida_3 = @asi_hora_salida_ajus
			WHERE asi_codemp = @codemp
				AND asi_fecha = CONVERT(DATE, @asi_hora_entrada)
		END

	END

	PRINT ''

	FETCH NEXT FROM marcas INTO @mar_codemp, @mar_fecha, @mar_tipo, @mar_codjor, @emp_codjor
END

CLOSE marcas
DEALLOCATE marcas

SET @fecha_ini = @fecha_ini + 1
SET @fecha_fin = @fecha_fin - 1

PRINT 'Crea asistencias en días no laborados'
DECLARE descansos CURSOR FOR
SELECT asi_codemp, asi_codjor, djo_dia + 1 djo_dia, jor_codigo_visual
FROM (
	SELECT asi_codemp, MIN(asi_codjor) asi_codjor
	FROM (
		SELECT asi_codemp, asi_codjor, COUNT(*) num_jornadas
		FROM rel.asi_asistencias a
		WHERE asi_codemp = ISNULL(@codemp, asi_codemp)
			AND asi_estado = @estado_asi_gen
			AND asi_fecha BETWEEN @fecha_ini AND @fecha_fin 
		GROUP BY asi_codemp, asi_codjor
		HAVING COUNT(*) = (SELECT MAX(num_jornadas)
							FROM (
								SELECT asi_codemp, asi_codjor, COUNT(*) num_jornadas
								FROM rel.asi_asistencias
								WHERE asi_codemp = ISNULL(@codemp, asi_codemp)
									AND asi_estado = @estado_asi_gen
									AND asi_fecha BETWEEN @fecha_ini AND @fecha_fin 
								GROUP BY asi_codemp, asi_codjor) s
							WHERE a.asi_codemp = s.asi_codemp)) i
	GROUP BY asi_codemp) t
	JOIN sal.jor_jornadas ON asi_codjor = jor_codigo
	JOIN sal.djo_dias_jornada ON jor_codigo = djo_codjor
WHERE ISNULL(djo_total_horas, 0.00) = 0.00
ORDER BY asi_codemp

OPEN descansos

FETCH NEXT FROM descansos INTO @asi_codemp, @asi_codjor, @djo_dia_descanso, @jor_codigo_visual

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @mar_codjor = NULL
	SET @fecha_act = @fecha_ini

	PRINT 'Empleado: ' + ISNULL(CONVERT(VARCHAR, @asi_codemp), '')
	PRINT 'Jornada: ' + ISNULL(CONVERT(VARCHAR, @asi_codjor), '')
	PRINT 'Día de Descanso: ' + ISNULL(CONVERT(VARCHAR, @djo_dia_descanso), '')

	WHILE @fecha_act <= @fecha_fin
	BEGIN
		PRINT 'Fecha: ' + ISNULL(CONVERT(VARCHAR, @fecha_act, 103), '')

		IF DATEPART(DW, @fecha_act) = @djo_dia_descanso
		BEGIN
			SELECT @mar_codjor = ISNULL(jpe_codjor, ISNULL(jpg_codjor, jpu_codjor))
			FROM exp.emp_empleos
				JOIN eor.plz_plazas ON emp_codplz = plz_codigo
				LEFT JOIN rel.jpe_jornadas_empleos ON jpe_codemp = emp_codigo AND @fecha_act = jpe_fecha
				LEFT JOIN rel.jpu_jornadas_unidades ON jpu_coduni = plz_coduni AND @fecha_act = jpu_fecha
				LEFT JOIN rel.gre_grupos_empleos ON gre_codemp = emp_codigo and @fecha_act BETWEEN gre_fecha_inicio and ISNULL(gre_fecha_fin, @fecha_act)
				LEFT JOIN rel.jpg_jornadas_grupos ON jpg_codgra = gre_codgra and jpg_fecha = @fecha_act
			WHERE emp_codigo = @asi_codemp

			PRINT 'Es día de descanso'
			PRINT 'Jornada Aplicación: ' + ISNULL(CONVERT(VARCHAR, @mar_codjor), '')

			IF @mar_codjor IS NULL
			BEGIN
				--PRINT 'Actualización de jornada'
				IF EXISTS (SELECT NULL FROM rel.asi_asistencias WHERE asi_codemp = @asi_codemp AND asi_fecha = @fecha_act) AND @jor_codigo_visual IN ('NOCTURNA', 'NOCTURNACS')
				BEGIN
					UPDATE rel.asi_asistencias
					SET asi_codjor = @asi_codjor
					WHERE asi_codemp = @asi_codemp
						AND asi_fecha = @fecha_act
				END
				ELSE IF NOT EXISTS (SELECT NULL FROM rel.asi_asistencias WHERE asi_codemp = @asi_codemp AND asi_fecha = @fecha_act)
				BEGIN
					INSERT INTO rel.asi_asistencias (
						asi_codemp,
						asi_codppl,
						asi_codjor,
						asi_estado,
						asi_fecha,
						asi_hora_entrada_1,
						asi_hora_salida_1,
						asi_accion,
						asi_estado_workflow,
						asi_fecha_cambio_estado,
						asi_usuario_grabacion,
						asi_fecha_grabacion)
					SELECT @asi_codemp asi_codemp,
						@codppl asi_codppl,
						@asi_codjor asi_codjor,
						@estado_asi_gen asi_estado,
						@fecha_act asi_fecha,
						NULL asi_hora_entrada_1,
						NULL asi_hora_salida_1,
						'Generada' asi_accion,
						@estado_workflow_asi_gen asi_estado_workflow,
						GETDATE() asi_fecha_cambio_estado,
						@usuario asi_usuario_grabacion,
						GETDATE() asi_fecha_grabacion							
				END
			END
		END		

		PRINT ''

		SET @fecha_act = DATEADD(DD, 1, @fecha_act)
	END

	PRINT ''

	FETCH NEXT FROM descansos INTO @asi_codemp, @asi_codjor, @djo_dia_descanso, @jor_codigo_visual
END

CLOSE descansos
DEALLOCATE descansos

--SELECT *
--FROM rel.mar_marcas
--WHERE mar_estado = @estado_marca_procesada
--	AND mar_tipo_marca = @estado_marca_indefinido
--	AND mar_fecha BETWEEN @fecha_ini AND @fecha_fin 
--ORDER BY mar_codemp, mar_fecha_hora

--SELECT *
--FROM rel.mar_marcas
--WHERE mar_estado = @estado_marca_procesada
--	AND mar_fecha BETWEEN @fecha_ini AND @fecha_fin 
--ORDER BY mar_codemp, mar_fecha_hora

--SELECT *
--FROM rel.asi_asistencias
--WHERE asi_fecha BETWEEN @fecha_ini AND @fecha_fin  

COMMIT