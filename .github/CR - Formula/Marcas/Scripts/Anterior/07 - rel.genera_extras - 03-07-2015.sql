IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('rel.genera_extras'))
BEGIN
	DROP PROCEDURE rel.genera_extras
END

GO

/*
	Proceso de generación de horas extras
	a partir de la información de asistencia
	----------------------------------------------
	Creado por: Fernando Paz
				25/04/2014

	Este proceso toma la información de la tabla de asistencia y genera horas extras
	a partir de ella.

	Los parametros para la generación los toma de la tabla pla_prl_parametros_reloj.  El procedimiento
	tambien toma en cuenta los dias de feriado de la tabla pla_cal_calendario
	Si el parametro codigo de empleado no es nulo, entonces ejecuta para el empleado seleccionado
	Si el paraemtro codigo de grupo no es nulo, entonces ejecuta para los empleados del grupo seleccionado
	Si el parametro codigo de unidad no es nulo, entonces ejecuta para los empleados de la unidad seleccionada
   
	Proceso toma en cuenta las siguientes configuraciones:
		Diurna: 06:00 a.m. a 02:00 p.m.
			•	8 Normales
			•	Extras (1.5)
			•	Día Libre (2.0)
			•	Asueto (2.0)

		Mixta: 02:00 p.m. a 10:00 p.m.
			•	7 Mixtas Normales (1.14 Horas Normales)
			•	1 Mixta (1.71 Horas Normales)
			•	Extras
				o	Entra antes se paga mixta
				o	Sale después se paga doble
			•	Día Libre (2.0)

		Mixta Especial: 03:00 p.m. a 10:00 p.m.
			•	7 Mixtas Normales (1.14 Horas Normales)
			•	0.5 Mixta (1.71 Horas Normales)
			•	Extras
				o	Entra antes se paga mixta
				o	Sale después se paga doble
			•	Día Libre (2.0)

		Nocturno: 10:00 p.m. a 06:00 a.m.
			•	6 Nocturnas (1.33 Horas Normales)
			•	2 Dobles
			•	Extras (2.0)
			•	Día Libre (2.0)
			•	Asueto (2.0)

	El proceso funciona de la siguiente manera:
		- Para cada uno de los empleados obtiene las asistencias de entrada y salida y el horario de la jornada
		- Ajusta la asistencia de entrada y salida según los horarios de entrada y salida a la media hora más próxima
		- Obtiene la jornada del empleado y el número de horas extras y número de horas normales
		- Inserta registros de horas según el número de horas extras y normales
*/
--EXEC rel.genera_extras 1136, NULL, NULL, NULL, 'admin'
CREATE PROCEDURE rel.genera_extras (
	@codppl INT = NULL,
	@codemp INT = NULL,
	@codgra INT = NULL,
	@coduni INT = NULL,
	@usuario VARCHAR(100) = NULL
)

AS

SET NOCOUNT ON
SET DATEFIRST  7
SET DATEFORMAT DMY

SET @usuario = ISNULL(@usuario, SYSTEM_USER)

-- Variables para almacenar la empresa, el tipo de planilla, fecha inicial y final de la planilla
DECLARE @codcia INT, 
	@codtpl INT, 
	@fecha_ini DATETIME, 
	@fecha_fin DATETIME, 
	@codmon VARCHAR(3)

SELECT @codcia = tpl_codcia, 
	@codtpl = tpl_codigo,
	@fecha_ini = ppl_fecha_ini, 
	@fecha_fin = ppl_fecha_fin,
	@codmon = tpl_codmon
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
WHERE ppl_codigo = @codppl

--*
--* Obtiene los parametros de reloj que necesita el proceso de generacion
--*
DECLARE @generaHEX bit,
	@errorMsg VARCHAR(MAX),     
	@estado_hex_gen VARCHAR(50),
	@estado_workflow_hex_gen VARCHAR(20),
	@asi_codemp INT,
	@asi_jor_del DATETIME,
	@asi_jor_al DATETIME,
	@asi_del DATETIME,
	@asi_al DATETIME,
	@codjor_visual VARCHAR(10),
	@num_horas_antes REAL,
	@num_horas_entre REAL,
	@num_horas_despues REAL,
	@num_horas_extras REAL,
	@num_horas_normales REAL,
	@num_horas_totales REAL,
	@codthe_normal INT,
	@codthe_extra INT,
	@codthe_mixta_normal INT,
	@codthe_mixta INT,
	@codthe_nocturna INT,
	@codthe_doble INT,
	@factor_normal REAL,
	@factor_extra REAL,
	@factor_mixta_normal REAL,
	@factor_mixta REAL,
	@factor_nocturna REAL,
	@factor_doble REAL,
	@num_max_horas_mixtas REAL,
	@num_max_horas_nocturnas REAL,
	@es_feriado BIT,
	@es_habil BIT

SET @generaHEX = ISNULL(gen.get_valor_parametro_bit('RelojGeneraHEX', NULL, NULL, @codcia, NULL), 0)
SET @codthe_normal = gen.get_valor_parametro_INT('RelojTipoEXTNormal', NULL, NULL, @codcia, NULL)
SET @codthe_extra = gen.get_valor_parametro_INT('RelojTipoEXTExtra', NULL, NULL, @codcia, NULL)
SET @codthe_mixta_normal = gen.get_valor_parametro_INT('RelojTipoEXTMixtaNormal', NULL, NULL, @codcia, NULL)
SET @codthe_mixta = gen.get_valor_parametro_INT('RelojTipoEXTMixta', NULL, NULL, @codcia, NULL)
SET @codthe_nocturna = gen.get_valor_parametro_INT('RelojTipoEXTNocturna', NULL, NULL, @codcia, NULL)
SET @codthe_doble = gen.get_valor_parametro_INT('RelojTipoEXTDoble', NULL, NULL, @codcia, NULL)
SET @estado_hex_gen = gen.get_valor_parametro_VARCHAR('RelojEstadoHEXGenerado', NULL, NULL, @codcia, NULL)
SET @estado_workflow_hex_gen = gen.get_valor_parametro_VARCHAR('RelojEstadoWorkflowHEXGenerado', NULL, NULL, @codcia, NULL)
SET @num_max_horas_mixtas = 7.00
SET @num_max_horas_nocturnas = 6.00
SET @estado_hex_gen = ISNULL(@estado_hex_gen, 'Pendiente')
SET @estado_workflow_hex_gen = ISNULL(@estado_workflow_hex_gen, 'Pendiente')

PRINT 'Período de planilla: ' + ISNULL(CONVERT(VARCHAR, @codppl), '')
PRINT 'Empleado: ' + ISNULL(CONVERT(VARCHAR, @codemp), '')
PRINT 'Grupo de Asistencia: ' + ISNULL(CONVERT(VARCHAR, @codgra), '')
PRINT 'Unidad: ' + ISNULL(CONVERT(VARCHAR, @coduni), '')
PRINT 'Usuario: ' + ISNULL(@usuario, '')
PRINT 'Unidad: ' + ISNULL(CONVERT(VARCHAR, @coduni), '')
PRINT 'Compañía: ' + ISNULL(CONVERT(VARCHAR, @codcia), '')
PRINT 'Tipo Planilla: ' + ISNULL(CONVERT(VARCHAR, @codtpl), '')
PRINT 'Fecha Inicial: ' + ISNULL(CONVERT(VARCHAR, @fecha_ini, 103), '')
PRINT 'Fecha Final: ' + ISNULL(CONVERT(VARCHAR, @fecha_fin, 103), '')
PRINT 'Moneda: ' + ISNULL(@codmon, '')
PRINT 'Genera Extras: ' + ISNULL(CONVERT(VARCHAR, @generaHEX), '')
PRINT 'Tipo de Hora Normal: ' + ISNULL(CONVERT(VARCHAR, @codthe_normal), '')
PRINT 'Tipo de Hora Extra: ' + ISNULL(CONVERT(VARCHAR, @codthe_extra), '')
PRINT 'Tipo de Hora Mixta Normal: ' + ISNULL(CONVERT(VARCHAR, @codthe_mixta_normal), '')
PRINT 'Tipo de Hora Mixta: ' + ISNULL(CONVERT(VARCHAR, @codthe_mixta), '')
PRINT 'Tipo de Hora Nocturna: ' + ISNULL(CONVERT(VARCHAR, @codthe_nocturna), '')
PRINT 'Tipo de Hora Doble: ' + ISNULL(CONVERT(VARCHAR, @codthe_doble), '')
PRINT 'Estado de hora extra: ' + ISNULL(@estado_hex_gen, '')
PRINT 'Estado de flujo de hora extra: ' + ISNULL(@estado_workflow_hex_gen, '')
PRINT 'Número maximo de horas mixtas: ' + ISNULL(CONVERT(VARCHAR, @num_max_horas_mixtas), '')
PRINT 'Número maximo de horas nocturnas: ' + ISNULL(CONVERT(VARCHAR, @num_max_horas_nocturnas), '')

IF @generaHEX = 0
BEGIN
    SET @errorMsg = 'No se generaron horas extras porque el parámetro de aplicación RelojTipoEXTNormal no está especificado o indica que no se generen al enviarle el código de empresa (' + CAST(@codcia AS VARCHAR) + ')'
    RAISERROR (@errorMsg, 16, 1)
	RETURN
END

IF @codthe_normal IS NULL OR NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codigo = @codthe_normal AND the_codcia = @codcia) 
BEGIN
    SET @errorMsg = 'No se encontró un valor para el parámetro RelojTipoEXTNormal para la empresa (' + CAST(@codcia AS VARCHAR) + ').  Este valor debe contener el código del tipo de hora extra que se utilizará para generar horas normales.'
    RAISERROR (@errorMsg, 16, 1)
    RETURN
END

IF @codthe_extra IS NULL OR NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codigo = @codthe_extra AND the_codcia = @codcia) 
BEGIN
    SET @errorMsg = 'No se encontró un valor para el parámetro RelojTipoEXTExtra para la empresa (' + CAST(@codcia AS VARCHAR) + ').  Este valor debe contener el código del tipo de hora extra que se utilizará para generar horas extras.'
    RAISERROR (@errorMsg, 16, 1)
    RETURN
END

IF @codthe_mixta_normal IS NULL OR NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codigo = @codthe_mixta_normal AND the_codcia = @codcia) 
BEGIN
    SET @errorMsg = 'No se encontró un valor para el parámetro RelojTipoEXTMixtaNormal para la empresa (' + CAST(@codcia AS VARCHAR) + ').  Este valor debe contener el código del tipo de hora extra que se utilizará para generar horas mixtas normales.'
    RAISERROR (@errorMsg, 16, 1)
    RETURN
END

IF @codthe_mixta IS NULL OR NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codigo = @codthe_mixta AND the_codcia = @codcia) 
BEGIN
    SET @errorMsg = 'No se encontró un valor para el parámetro RelojTipoEXTMixta para la empresa (' + CAST(@codcia AS VARCHAR) + ').  Este valor debe contener el código del tipo de hora extra que se utilizará para generar horas mixtas.'
    RAISERROR (@errorMsg, 16, 1)
    RETURN
END

IF @codthe_nocturna IS NULL OR NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codigo = @codthe_nocturna AND the_codcia = @codcia) 
BEGIN
    SET @errorMsg = 'No se encontró un valor para el parámetro RelojTipoEXTNocturna para la empresa (' + CAST(@codcia AS VARCHAR) + ').  Este valor debe contener el código del tipo de hora extra que se utilizará para generar horas nocturnas.'
    RAISERROR (@errorMsg, 16, 1)
    RETURN
END

IF @codthe_doble IS NULL OR NOT EXISTS (SELECT NULL FROM sal.the_tipos_hora_extra WHERE the_codigo = @codthe_doble AND the_codcia = @codcia) 
BEGIN
    SET @errorMsg = 'No se encontró un valor para el parámetro RelojTipoEXTDoble para la empresa (' + CAST(@codcia AS VARCHAR) + ').  Este valor debe contener el código del tipo de hora extra que se utilizará para generar horas dobles.'
    RAISERROR (@errorMsg, 16, 1)
    RETURN
END

SELECT @factor_normal = ISNULL(the_factor, 0.00) + ISNULL(the_factor_nocturnidad, 0.00)
FROM sal.the_tipos_hora_extra 
WHERE the_codigo = @codthe_normal

SELECT @factor_extra = ISNULL(the_factor, 0.00) + ISNULL(the_factor_nocturnidad, 0.00)
FROM sal.the_tipos_hora_extra 
WHERE the_codigo = @codthe_extra

SELECT @factor_mixta_normal = ISNULL(the_factor, 0.00) + ISNULL(the_factor_nocturnidad, 0.00)
FROM sal.the_tipos_hora_extra 
WHERE the_codigo = @codthe_mixta_normal

SELECT @factor_mixta = ISNULL(the_factor, 0.00) + ISNULL(the_factor_nocturnidad, 0.00)
FROM sal.the_tipos_hora_extra 
WHERE the_codigo = @codthe_mixta

SELECT @factor_nocturna = ISNULL(the_factor, 0.00) + ISNULL(the_factor_nocturnidad, 0.00)
FROM sal.the_tipos_hora_extra 
WHERE the_codigo = @codthe_nocturna

SELECT @factor_doble = ISNULL(the_factor, 0.00) + ISNULL(the_factor_nocturnidad, 0.00)
FROM sal.the_tipos_hora_extra 
WHERE the_codigo = @codthe_doble

PRINT 'Factor de hora normal: ' + ISNULL(CONVERT(VARCHAR, @factor_normal), '')
PRINT 'Factor de hora extra: ' + ISNULL(CONVERT(VARCHAR, @factor_extra), '')
PRINT 'Factor de hora mixta normal: ' + ISNULL(CONVERT(VARCHAR, @factor_mixta_normal), '')
PRINT 'Factor de hora mixta: ' + ISNULL(CONVERT(VARCHAR, @factor_mixta), '')
PRINT 'Factor de hora nocturna: ' + ISNULL(CONVERT(VARCHAR, @factor_nocturna), '')
PRINT 'Factor de hora doble: ' + ISNULL(CONVERT(VARCHAR, @factor_doble), '')
PRINT ''

BEGIN TRANSACTION

---------------------------------------------------------------------------------------
-- CREA UNA TABLA temporal con los empleados que participan del procesamiento ---------
---------------------------------------------------------------------------------------
SELECT plz_codcia emp_codcia, 
       emp_codigo, 
       emp_codjor, 
        --CASE WHEN emp_fecha_ultimo_cotrato IS NULL THEN EMP_FECHA_INGRESO ELSE emp_fecha_ultimo_cotrato END emp_fecha_ingreso, 
       emp_fecha_ingreso, 
       plz_coduni,
       (SELECT TOP 1 cpp_codcco FROM eor.cpp_centros_costo_plaza c1
         WHERE cpp_codplz = plz_codigo
           AND cpp_porcentaje IN (
           SELECT MAX(cpp_porcentaje) cpp_porcentaje
             FROM eor.cpp_centros_costo_plaza c2
            WHERE c2.cpp_codplz = c1.cpp_codplz
              AND c2.cpp_codcco = c1.cpp_codcco)) emp_codcco
  INTO #empFiltro
  FROM exp.emp_empleos
  JOIN eor.plz_plazas ON plz_codigo = emp_codplz
  JOIN sal.ppl_periodos_planilla ON ppl_codigo = @codppl
  LEFT JOIN rel.gre_grupos_empleos ON gre_codemp = emp_codigo AND ppl_fecha_corte BETWEEN gre_fecha_inicio AND ISNULL(gre_fecha_fin, ppl_fecha_corte)
 WHERE plz_codcia = @codcia
   AND emp_codigo = ISNULL(@codemp, emp_codigo)
   AND emp_codtpl = @codtpl
   AND emp_estado = 'A'
   AND ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, 'emp_marca_asistencia'), 0) = 1
   AND plz_coduni = ISNULL(@coduni, plz_coduni)
   AND CASE WHEN @codgra IS NULL THEN 1 
            ELSE CASE WHEN EXISTS (
                    SELECT NULL FROM rel.gre_grupos_empleos 
                     WHERE gre_codemp = emp_codigo AND gre_codgra = @codgra 
                       AND (@fecha_ini BETWEEN gre_fecha_inicio AND ISNULL(gre_fecha_fin, @fecha_fin) OR @fecha_fin BETWEEN gre_fecha_inicio AND ISNULL(gre_fecha_fin, @fecha_fin)))
                      THEN 1
                      ELSE 0
                 END
       END = 1

--*
--* Tabla temporal con la asistencia teórica de los empleados
--* en el periodo especificado
--*
CREATE TABLE #djo (
   djo_fecha DATETIME,
   djo_es_feriado bit,
   djo_dia INT,
   djo_codemp INT,
   djo_salario_hora MONEY,
   djo_codjor INT,
   djo_horas REAL,
   djo_hora_del DATETIME,
   djo_hora_al DATETIME, 
   djo_hora_del_ves DATETIME,
   djo_hora_al_ves DATETIME,
   djo_rel_entrada1 DATETIME,
   djo_rel_salida1 DATETIME,
   djo_rel_entrada2 DATETIME,
   djo_rel_salida2 DATETIME,
   djo_rel_entrada3 DATETIME,
   djo_rel_salida3 DATETIME,
   djo_rel_entrada4 DATETIME,
   djo_rel_salida4 DATETIME,
   djo_num_marcas INT,
   djo_esta_incapacitado bit,
   djo_esta_vacaciones bit,
   djo_tiene_tnt_manual bit,
   djo_tiene_tnt_generado bit,
   djo_tiene_tnt_autorizado bit,
   djo_es_dia_habil bit)

--*
--* Crea una tabla con la asistencia teórica basado en las jornadas
--*
EXEC rel.crea_asistencia_teorica @codppl, @codemp, @codgra, @coduni

DELETE sal.ext_horas_extras
WHERE ext_codppl = @codppl
   AND EXISTS (select NULL from #empFiltro where emp_codigo = ext_codemp)
   AND ext_generado_reloj = 1

DECLARE horarios CURSOR FOR
SELECT djo_codemp,
	jor_codigo_visual,
	djo_hora_del,
	djo_hora_al_ves,
	djo_rel_entrada1,
	djo_rel_salida1,
	djo_es_feriado,
	djo_es_dia_habil
FROM #djo
	JOIN sal.jor_jornadas ON djo_codjor = jor_codigo
WHERE djo_rel_entrada1 IS NOT NULL AND djo_rel_salida1 IS NOT NULL
ORDER BY djo_codemp, djo_rel_entrada1

OPEN horarios

FETCH NEXT FROM horarios INTO @asi_codemp, @codjor_visual, @asi_jor_del, @asi_jor_al, @asi_del, @asi_al, @es_feriado, @es_habil

WHILE @@FETCH_STATUS = 0
BEGIN

	PRINT 'Empleado: ' + ISNULL(CONVERT(VARCHAR, @asi_codemp), '')
	PRINT 'Jornada abreviatura: ' + ISNULL(@codjor_visual, '')
	PRINT 'Horario entrada jornada: ' + ISNULL(CONVERT(VARCHAR, @asi_jor_del, 120), '')
	PRINT 'Horario salida jornada: ' + ISNULL(CONVERT(VARCHAR, @asi_jor_al, 120), '')
	PRINT 'Horario entrada empleado: ' + ISNULL(CONVERT(VARCHAR, @asi_del, 120), '')
	PRINT 'Horario salida empleado: ' + ISNULL(CONVERT(VARCHAR, @asi_al, 120), '')
	PRINT '¿Es feriado?: ' + ISNULL(CONVERT(VARCHAR, @es_feriado), '')
	PRINT '¿Es día hábil?: ' + ISNULL(CONVERT(VARCHAR, @es_habil), '')

	SET @num_horas_antes = 0.00
	SET @num_horas_entre = 0.00
	SET @num_horas_despues = 0.00
	SET @num_horas_extras = 0.00
	SET @num_horas_normales = 0.00
	SET @num_horas_totales = 0.00

	IF DATEPART(MI, @asi_del) < 20
		SET @asi_del = DATEADD(MI, -DATEPART(MI, @asi_del), @asi_del)
	ELSE IF DATEPART(MI, @asi_del) BETWEEN 20 AND 49
		SET @asi_del = DATEADD(MI, 30, DATEADD(MI, -DATEPART(MI, @asi_del), @asi_del))
	ELSE
		SET @asi_del = DATEADD(HH, 1, DATEADD(MI, -DATEPART(MI, @asi_del), @asi_del))

	IF DATEPART(MI, @asi_al) < 20
		SET @asi_al = DATEADD(MI, -DATEPART(MI, @asi_al), @asi_al)
	ELSE IF DATEPART(MI, @asi_al) BETWEEN 20 AND 49
		SET @asi_al = DATEADD(MI, 30, DATEADD(MI, -DATEPART(MI, @asi_al), @asi_al))
	ELSE
		SET @asi_al = DATEADD(HH, 1, DATEADD(MI, -DATEPART(MI, @asi_al), @asi_al))

	PRINT 'Horario entrada empleado ajustado: ' + ISNULL(CONVERT(VARCHAR, @asi_del, 120), '')
	PRINT 'Horario salida empleado ajustado: ' + ISNULL(CONVERT(VARCHAR, @asi_al, 120), '')

	IF @asi_del < @asi_jor_del
	BEGIN
		SET @num_horas_antes = ROUND(DATEDIFF(MI, @asi_del, @asi_jor_del) / 60.00, 2)
	END
	
	IF @asi_al > @asi_jor_al
	BEGIN
		SET @num_horas_despues = ROUND(DATEDIFF(MI, @asi_jor_al, @asi_al) / 60.00, 2)
	END

	IF @asi_del < @asi_jor_del
	BEGIN
		IF @asi_al > @asi_jor_al
			SET @num_horas_entre = ROUND(DATEDIFF(MI, @asi_jor_del, @asi_jor_al) / 60.00, 2)
		ELSE
			SET @num_horas_entre = ROUND(DATEDIFF(MI, @asi_jor_del, @asi_al) / 60.00, 2)
	END
	ELSE IF @asi_al > @asi_jor_al
	BEGIN
		IF @asi_del < @asi_jor_del
			SET @num_horas_entre = ROUND(DATEDIFF(MI, @asi_jor_del, @asi_jor_al) / 60.00, 2)
		ELSE
			SET @num_horas_entre = ROUND(DATEDIFF(MI, @asi_del, @asi_jor_al) / 60.00, 2)
	END
	ELSE 
	BEGIN
		SET @num_horas_entre = ROUND(DATEDIFF(MI, @asi_del, @asi_al) / 60.00, 2)
	END

	SET @num_horas_extras = @num_horas_antes + @num_horas_despues
	SET @num_horas_totales = @num_horas_antes + @num_horas_despues + @num_horas_entre

	PRINT 'Horas entre la jornada: ' + ISNULL(CONVERT(VARCHAR, @num_horas_entre), '')
	PRINT 'Horas antes la jornada: ' + ISNULL(CONVERT(VARCHAR, @num_horas_antes), '')
	PRINT 'Horas despues la jornada: ' + ISNULL(CONVERT(VARCHAR, @num_horas_despues), '')
	PRINT 'Horas normales: ' + ISNULL(CONVERT(VARCHAR, @num_horas_normales), '')
	PRINT 'Horas extras: ' + ISNULL(CONVERT(VARCHAR, @num_horas_extras), '')	
	PRINT 'Horas totales: ' + ISNULL(CONVERT(VARCHAR, @num_horas_totales), '')

	IF @es_habil = 0 OR @es_feriado = 1
	BEGIN
		INSERT INTO sal.ext_horas_extras (
			ext_codemp, 
			ext_codthe, 
			ext_fecha, 
			ext_num_horas, 
			ext_num_mins, 
			ext_factor, 
			ext_salario_hora, 
			ext_valor_a_pagar, 
			ext_codmon, 
			ext_generado_reloj, 
			ext_generado_solicitud, 
			ext_codcco, 
			ext_codppl, 
			ext_aplicado_planilla, 
			ext_planilla_autorizada, 
			ext_ignorar_en_planilla, 
			ext_estado, 
			ext_fecha_cambio_estado, 
			ext_estado_workflow, 
			ext_ingresado_portal, 
			ext_usuario_grabacion, 
			ext_fecha_grabacion)
		SELECT @asi_codemp,
			@codthe_doble,
			@asi_del,
			FLOOR(@num_horas_totales),
			(@num_horas_totales - FLOOR(@num_horas_totales)) * 60.00,
			@factor_doble,
			0.00,
			0.00,
			@codmon,
			1,
			0,
			NULL,
			@codppl,
			0,
			0,
			0,
			@estado_hex_gen,
			GETDATE(),
			@estado_workflow_hex_gen,
			0,
			@usuario,
			GETDATE()
		WHERE @num_horas_totales > 0.00	
	END
	ELSE
	BEGIN
		IF @codjor_visual IN ('DIURNA', 'DIURNACS')
		BEGIN
			PRINT 'Jornada Diurna'

			-- Agrega horas normales
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_normal,
				@asi_del,
				FLOOR(@num_horas_entre),
				(@num_horas_entre - FLOOR(@num_horas_entre)) * 60.00,
				@factor_normal,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_entre > 0.00

			-- Agrega horas extras
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_extra,
				@asi_del,
				FLOOR(@num_horas_extras),
				(@num_horas_extras - FLOOR(@num_horas_extras)) * 60.00,
				@factor_extra,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_extras > 0.00
		END		

		IF @codjor_visual IN ('MIXTA', 'MIXTACS')
		BEGIN
			PRINT 'Jornada Mixta'

			IF @num_horas_entre > @num_max_horas_mixtas
			BEGIN
				SET @num_horas_normales = @num_max_horas_mixtas
				SET @num_horas_extras = @num_horas_entre - @num_max_horas_mixtas
			END
			ELSE
			BEGIN
				SET @num_horas_normales = @num_horas_entre
			END

			PRINT 'Horas normales: ' + ISNULL(CONVERT(VARCHAR, @num_horas_normales), '')
			PRINT 'Horas extras: ' + ISNULL(CONVERT(VARCHAR, @num_horas_extras), '')	
			
			-- Agrega horas mixtas normales
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_mixta_normal,
				@asi_del,
				FLOOR(@num_horas_normales),
				(@num_horas_normales - FLOOR(@num_horas_normales)) * 60.00,
				@factor_mixta_normal,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_normales > 0.00

			-- Agrega horas mixtas
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_mixta,
				@asi_del,
				FLOOR(@num_horas_extras),
				(@num_horas_extras - FLOOR(@num_horas_extras)) * 60.00,
				@factor_mixta,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_extras > 0.00

			-- Agrega hora mixta cuando entra antes
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_mixta,
				@asi_del,
				FLOOR(@num_horas_antes),
				(@num_horas_antes - FLOOR(@num_horas_antes)) * 60.00,
				@factor_mixta,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_antes > 0.00

			-- Agrega hora doble cuando sale despues
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_doble,
				@asi_del,
				FLOOR(@num_horas_despues),
				(@num_horas_despues - FLOOR(@num_horas_despues)) * 60.00,
				@factor_doble,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_despues > 0.00
		END	

		IF @codjor_visual IN ('MIXTAESP', 'MIXTAESPCS')
		BEGIN
			PRINT 'Jornada Mixta Especial'

			IF @num_horas_entre = @num_max_horas_mixtas
			BEGIN
				SET @num_horas_normales = @num_max_horas_mixtas
				SET @num_horas_extras = 0.5
			END
			ELSE
			BEGIN
				SET @num_horas_normales = @num_horas_entre
			END

			PRINT 'Horas normales: ' + ISNULL(CONVERT(VARCHAR, @num_horas_normales), '')
			PRINT 'Horas extras: ' + ISNULL(CONVERT(VARCHAR, @num_horas_extras), '')	
			
			-- Agrega horas mixtas normales
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_mixta_normal,
				@asi_del,
				FLOOR(@num_horas_normales),
				(@num_horas_normales - FLOOR(@num_horas_normales)) * 60.00,
				@factor_mixta_normal,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_normales > 0.00

			-- Agrega horas mixtas
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_mixta,
				@asi_del,
				FLOOR(@num_horas_extras),
				(@num_horas_extras - FLOOR(@num_horas_extras)) * 60.00,
				@factor_mixta,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_extras > 0.00

			-- Agrega hora mixta cuando entra antes
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_mixta,
				@asi_del,
				FLOOR(@num_horas_antes),
				(@num_horas_antes - FLOOR(@num_horas_antes)) * 60.00,
				@factor_mixta,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_antes > 0.00

			-- Agrega hora doble cuando sale despues
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_doble,
				@asi_del,
				FLOOR(@num_horas_despues),
				(@num_horas_despues - FLOOR(@num_horas_despues)) * 60.00,
				@factor_doble,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_despues > 0.00
		END	

		IF @codjor_visual IN ('NOCTURNA', 'NOCTURNACS')
		BEGIN
			PRINT 'Jornada Nocturna'

			IF @num_horas_entre > @num_max_horas_nocturnas
			BEGIN
				SET @num_horas_normales = @num_max_horas_nocturnas
				SET @num_horas_extras = @num_horas_entre - @num_max_horas_nocturnas
			END
			ELSE
			BEGIN
				SET @num_horas_normales = @num_horas_entre
			END
			
			SET @num_horas_totales = @num_horas_antes + @num_horas_despues + @num_horas_extras

			PRINT 'Horas normales: ' + ISNULL(CONVERT(VARCHAR, @num_horas_normales), '')
			PRINT 'Horas extras: ' + ISNULL(CONVERT(VARCHAR, @num_horas_extras), '')	
			PRINT 'Horas totales: ' + ISNULL(CONVERT(VARCHAR, @num_horas_totales), '')	

			-- Agrega horas nocturnas
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_nocturna,
				@asi_del,
				FLOOR(@num_horas_normales),
				(@num_horas_normales - FLOOR(@num_horas_normales)) * 60.00,
				@factor_nocturna,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_normales > 0.00

			-- Agrega horas dobles
			INSERT INTO sal.ext_horas_extras (
				ext_codemp, 
				ext_codthe, 
				ext_fecha, 
				ext_num_horas, 
				ext_num_mins, 
				ext_factor, 
				ext_salario_hora, 
				ext_valor_a_pagar, 
				ext_codmon, 
				ext_generado_reloj, 
				ext_generado_solicitud, 
				ext_codcco, 
				ext_codppl, 
				ext_aplicado_planilla, 
				ext_planilla_autorizada, 
				ext_ignorar_en_planilla, 
				ext_estado, 
				ext_fecha_cambio_estado, 
				ext_estado_workflow, 
				ext_ingresado_portal, 
				ext_usuario_grabacion, 
				ext_fecha_grabacion)
			SELECT @asi_codemp,
				@codthe_doble,
				@asi_del,
				FLOOR(@num_horas_totales),
				(@num_horas_totales - FLOOR(@num_horas_totales)) * 60.00,
				@factor_doble,
				0.00,
				0.00,
				@codmon,
				1,
				0,
				NULL,
				@codppl,
				0,
				0,
				0,
				@estado_hex_gen,
				GETDATE(),
				@estado_workflow_hex_gen,
				0,
				@usuario,
				GETDATE()
			WHERE @num_horas_totales > 0.00
		END	

		PRINT ''
	END

	FETCH NEXT FROM horarios INTO @asi_codemp, @codjor_visual, @asi_jor_del, @asi_jor_al, @asi_del, @asi_al, @es_feriado, @es_habil
END

CLOSE horarios
DEALLOCATE horarios

-- Finaliza
COMMIT TRANSACTION
--ROLLBACK TRANSACTION

IF OBJECT_ID('tempdb..#empFiltro') IS NOT NULL DROP TABLE #empFiltro
IF OBJECT_ID('tempdb..#djo') IS NOT NULL DROP TABLE #djo

RETURN
