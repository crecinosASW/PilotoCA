IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('acc.imp_vac_vacaciones')
			  AND type = 'P')
BEGIN
	DROP PROCEDURE acc.imp_vac_vacaciones
END

GO

CREATE PROCEDURE acc.imp_vac_vacaciones (
	@codemp_alternativo VARCHAR(36), 
	@periodo			VARCHAR(10),
	@desde_txt			VARCHAR(10),
	@hasta_txt			VARCHAR(10),
	@dias_periodo_ant	NUMERIC(19, 4),
	@horas_periodo_ant	NUMERIC(19, 4),
	@dias_adjudicados	NUMERIC(19, 4),
	@dias_gozados		NUMERIC(19, 4),
	@horas_gozadas		NUMERIC(19, 4),
	@dias_saldo			NUMERIC(19, 4),
	@horas_saldo		NUMERIC(19, 4)
)

AS

--DECLARE @codemp_alternativo VARCHAR(36), 
--	@periodo			VARCHAR(10),
--	@desde_txt			VARCHAR(10),
--	@hasta_txt			VARCHAR(10),
--	@dias_periodo_ant	NUMERIC(19, 4),
--	@horas_periodo_ant	NUMERIC(19, 4),
--	@dias_adjudicados	NUMERIC(19, 4),
--	@dias_gozados		NUMERIC(19, 4),
--	@horas_gozadas		NUMERIC(19, 4),
--	@dias_saldo			NUMERIC(19, 4),
--	@horas_saldo		NUMERIC(19, 4)

--SET	@codemp_alternativo = NULL
--SET	@periodo = NULL
--SET	@desde_txt = NULL
--SET	@hasta_txt = NULL
--SET	@dias_periodo_ant = NULL
--SET	@horas_periodo_ant = NULL
--SET	@dias_adjudicados = NULL
--SET	@dias_gozados = NULL
--SET	@horas_gozadas = NULL
--SET	@dias_saldo = NULL
--SET	@horas_saldo = NULL

SET DATEFORMAT dmy

SET	@codemp_alternativo = REPLACE(@codemp_alternativo, ';', ',')
SET	@periodo = REPLACE(@periodo, ';', ',')

DECLARE @codemp INT,
	@desde DATETIME,
	@hasta DATETIME,
	@mensaje VARCHAR(1000)

SET @mensaje = ''

SELECT TOP(1) @codemp = emp_codigo
FROM exp.exp_expedientes
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp
WHERE exp_codigo_alternativo = @codemp_alternativo
ORDER BY emp_fecha_ingreso DESC

IF NOT EXISTS (SELECT 1 FROM exp.emp_empleos WHERE emp_codigo = @codemp)
	SET @mensaje = @mensaje + 'No existe el empleado con el código: ' + ISNULL(@codemp_alternativo, 'Vacío') + '; ' + CHAR(13)	

IF @periodo IS NULL OR @periodo = ''
	SET @mensaje = @mensaje + 'El período: ' + ISNULL(@periodo, 'Vacío') + ', no puede ser vacío; ' + CHAR(13)	

IF EXISTS (SELECT 1 FROM acc.vac_vacaciones WHERE vac_codemp = @codemp AND vac_periodo = @periodo)
	SET @mensaje = @mensaje + 'Ya existe el período: ' + ISNULL(@periodo, 'Vacío') + ' para el empleado código: ' + ISNULL(@codemp_alternativo, 'Vacío') + ';' + CHAR(13) 
	
IF ISDATE(@desde_txt) = 0
	SET @mensaje = @mensaje + 'La fecha del: ' + ISNULL(@desde_txt, 'Vacío') + ', no está en el formato correcto, el formato debe ser DD/MM/YYYY' + '; ' + CHAR(13)	

IF ISDATE(@hasta_txt) = 0
	SET @mensaje = @mensaje + 'La fecha hasta: ' + ISNULL(@hasta_txt, 'Vacío') + ', no está en el formato correcto, el formato debe ser DD/MM/YYYY' + '; ' + CHAR(13)	

IF ISDATE(@desde_txt) = 1 AND ISDATE(@hasta_txt) = 1 AND CONVERT(DATETIME, @hasta_txt) < CONVERT(DATETIME, @desde_txt)
	SET @mensaje = @mensaje + 'La fecha hasta: ' + ISNULL(@hasta_txt, 'Vacía') + ' es menor a la fecha desde: ' + ISNULL(@desde_txt, 'Vacía') + '; ' + CHAR(13)	

IF ISNUMERIC(@dias_periodo_ant) = 0
	SET @mensaje = @mensaje + 'El valor de los días del período anterior es incorrecto: ' + ISNULL(CONVERT(VARCHAR, @dias_periodo_ant), 'Vacío') + '; ' + CHAR(13)

IF ISNUMERIC(@dias_periodo_ant) = 1 AND @dias_periodo_ant < 0
	SET @mensaje = @mensaje + 'El valor de los días del período anterior: ' + ISNULL(CONVERT(VARCHAR, @dias_periodo_ant), 'Vacío') + ' no puede ser menor de cero; ' + CHAR(13)

IF ISNUMERIC(@horas_periodo_ant) = 0
	SET @mensaje = @mensaje + 'El valor de las horas del período anterior es incorrecto: ' + ISNULL(CONVERT(VARCHAR, @horas_periodo_ant), 'Vacío') + '; ' + CHAR(13)

IF ISNUMERIC(@horas_periodo_ant) = 1 AND @horas_periodo_ant < 0
	SET @mensaje = @mensaje + 'El valor de las horas del período anterior: ' + ISNULL(CONVERT(VARCHAR, @horas_periodo_ant), 'Vacío') + ' no puede ser menor de cero; ' + CHAR(13)

IF ISNUMERIC(@dias_adjudicados) = 0
	SET @mensaje = @mensaje + 'El valor de los días adjudicados es incorrecto: ' + ISNULL(CONVERT(VARCHAR, @dias_adjudicados), 'Vacío') + '; ' + CHAR(13)

IF ISNUMERIC(@dias_adjudicados) = 1 AND @dias_adjudicados < 0
	SET @mensaje = @mensaje + 'El valor de los días adjudicados: ' + ISNULL(CONVERT(VARCHAR, @dias_adjudicados), 'Vacío') + ' no puede ser menor de cero; ' + CHAR(13)

IF ISNUMERIC(@dias_gozados) = 0
	SET @mensaje = @mensaje + 'El valor de los días gozados es incorrecto: ' + ISNULL(CONVERT(VARCHAR, @dias_gozados), 'Vacío') + '; ' + CHAR(13)

IF ISNUMERIC(@dias_gozados) = 1 AND @dias_gozados < 0
	SET @mensaje = @mensaje + 'El valor de los días gozados: ' + ISNULL(CONVERT(VARCHAR, @dias_gozados), 'Vacío') + ' no puede ser menor de cero; ' + CHAR(13)

IF ISNUMERIC(@horas_gozadas) = 0
	SET @mensaje = @mensaje + 'El valor de las horas gozadas es incorrecto: ' + ISNULL(CONVERT(VARCHAR, @horas_gozadas), 'Vacío') + '; ' + CHAR(13)

IF ISNUMERIC(@horas_gozadas) = 1 AND @horas_gozadas < 0
	SET @mensaje = @mensaje + 'El valor de las horas gozadas: ' + ISNULL(CONVERT(VARCHAR, @horas_gozadas), 'Vacío') + ' no puede ser menor de cero; ' + CHAR(13)

IF ISNUMERIC(@dias_saldo) = 0
	SET @mensaje = @mensaje + 'El valor de los días saldo es incorrecto: ' + ISNULL(CONVERT(VARCHAR, @dias_saldo), 'Vacío') + '; ' + CHAR(13)

--IF ISNUMERIC(@dias_saldo) = 1 AND @dias_saldo < 0
--	SET @mensaje = @mensaje + 'El valor de los días saldo: ' + ISNULL(CONVERT(VARCHAR, @dias_saldo), 'Vacío') + ' no puede ser menor de cero; ' + CHAR(13)

IF ISNUMERIC(@horas_saldo) = 0
	SET @mensaje = @mensaje + 'El valor de las horas saldo es incorrecto: ' + ISNULL(CONVERT(VARCHAR, @horas_saldo), 'Vacío') + '; ' + CHAR(13)

--IF ISNUMERIC(@horas_saldo) = 1 AND @horas_saldo < 0
--	SET @mensaje = @mensaje + 'El valor de las horas saldo: ' + ISNULL(CONVERT(VARCHAR, @horas_saldo), 'Vacío') + ' no puede ser menor de cero; ' + CHAR(13)

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END

SET @desde = CONVERT(DATETIME, @desde_txt, 103)	
SET @hasta = CONVERT(DATETIME, @hasta_txt, 103)	

INSERT INTO acc.vac_vacaciones (vac_codemp,
	vac_periodo,
	vac_desde,
	vac_hasta,
	vac_periodo_anterior,
	vac_horas_periodo_anterior,
	vac_dias,
	vac_gozados,
	vac_horas_gozadas,
	vac_saldo,
	vac_horas_saldo,
	vac_usuario_grabacion,
	vac_fecha_grabacion)
VALUES(@codemp,
	@periodo,
	@desde,
	@hasta,
	@dias_periodo_ant,
	@horas_periodo_ant,
	@dias_adjudicados,
	@dias_gozados,
	@horas_gozadas,
	@dias_saldo,
	@horas_saldo,
	USER,
	GETDATE())

RETURN