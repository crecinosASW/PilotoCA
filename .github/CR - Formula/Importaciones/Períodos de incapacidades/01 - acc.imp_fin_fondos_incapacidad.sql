IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('acc.imp_fin_fondos_incapacidad'))
BEGIN
	DROP PROCEDURE acc.imp_fin_fondos_incapacidad
END

GO

CREATE PROCEDURE acc.imp_fin_fondos_incapacidad (
	@codemp_alternativo VARCHAR(36), 
	@desde_txt			VARCHAR(10),
	@hasta_txt			VARCHAR(10),
	@dias				NUMERIC(19, 4)
)

AS

SET DATEFORMAT dmy

SET	@codemp_alternativo = REPLACE(@codemp_alternativo, ';', ',')

DECLARE @codcia INT,
	@codemp INT,
	@desde DATETIME,
	@hasta DATETIME,
	@codrin_ccss INT,
	@codfin INT,
	@dias_derecho REAL,
	@mensaje VARCHAR(1000)

SET @mensaje = ''

SELECT TOP(1) @codcia = plz_codcia,
	@codemp = emp_codigo
FROM exp.exp_expedientes
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
WHERE exp_codigo_alternativo = @codemp_alternativo
ORDER BY emp_fecha_ingreso DESC

SET @codrin_ccss = gen.get_valor_parametro_int('CodigoRIN_CCSS', 'cr', NULL, NULL, NULL)

SELECT @dias_derecho = MAX(pin_final)
FROM acc.pin_parametros_incapacidad
WHERE pin_codcia = @codcia
	AND pin_codrin = @codrin_ccss
	AND pin_por_subsidio_sal_maximo > 0.00

IF NOT EXISTS (SELECT NULL FROM exp.emp_empleos WHERE emp_codigo = @codemp)
	SET @mensaje = @mensaje + 'No existe el empleado con el código: ' + ISNULL(@codemp_alternativo, 'Vacío') + '; ' + CHAR(13)	

IF EXISTS (SELECT NULL FROM acc.fin_fondos_incapacidad WHERE fin_codemp = @codemp AND fin_periodo = @desde_txt)
	SET @mensaje = @mensaje + 'Ya existe el período: ' + ISNULL(@desde_txt, 'Vacío') + ' para el empleado código: ' + ISNULL(@codemp_alternativo, 'Vacío') + ';' + CHAR(13) 
	
IF ISDATE(@desde_txt) = 0
	SET @mensaje = @mensaje + 'La fecha inicial: ' + ISNULL(@desde_txt, 'Vacío') + ', no está en el formato correcto, el formato debe ser DD/MM/YYYY' + '; ' + CHAR(13)	

IF ISDATE(@hasta_txt) = 0
	SET @mensaje = @mensaje + 'La fecha final: ' + ISNULL(@hasta_txt, 'Vacío') + ', no está en el formato correcto, el formato debe ser DD/MM/YYYY' + '; ' + CHAR(13)	

IF ISDATE(@desde_txt) = 1 AND ISDATE(@hasta_txt) = 1 AND CONVERT(DATETIME, @hasta_txt) < CONVERT(DATETIME, @desde_txt)
	SET @mensaje = @mensaje + 'La fecha inicial: ' + ISNULL(@hasta_txt, 'Vacía') + ' es menor a la fecha final: ' + ISNULL(@desde_txt, 'Vacía') + '; ' + CHAR(13)	

IF ISNUMERIC(@dias) = 0
	SET @mensaje = @mensaje + 'El valor de los días de incapacidad es incorrecto: ' + ISNULL(CONVERT(VARCHAR, @dias), 'Vacío') + '; ' + CHAR(13)

IF ISNUMERIC(@dias) = 1 AND @dias < 0
	SET @mensaje = @mensaje + 'El valor de los días de incapacidad: ' + ISNULL(CONVERT(VARCHAR, @dias), 'Vacío') + ' no puede ser menor de cero; ' + CHAR(13)

IF NOT EXISTS (SELECT NULL FROM acc.rin_riesgos_incapacidades WHERE rin_codpai = 'cr' AND rin_codigo = @codrin_ccss)
	SET @mensaje = @mensaje + 'El código del riesgo de incapacidad de CCSS: ' + ISNULL(CONVERT(VARCHAR, @codrin_ccss), 'Vacío') + ', no existe para el país de costa rica, revisar el parámetro de aplicación CodigoRIN_CCSS' + '; ' + CHAR(13)

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END

SET @desde = CONVERT(DATETIME, @desde_txt, 103)	
SET @hasta = CONVERT(DATETIME, @hasta_txt, 103)	

DELETE cr.din_detalle_incapacidad
WHERE EXISTS (SELECT NULL
			  FROM acc.fin_fondos_incapacidad
			  WHERE din_codfin = fin_codigo
				 AND fin_codemp = @codemp
				 AND fin_codrin = @codrin_ccss)

DELETE acc.pie_periodos_incapacidad
WHERE EXISTS (SELECT NULL
			  FROM acc.fin_fondos_incapacidad
			  WHERE pie_codfin = fin_codigo
				 AND fin_codemp = @codemp
				 AND fin_codrin = @codrin_ccss)

DELETE acc.fin_fondos_incapacidad
WHERE fin_codemp = @codemp
	AND fin_codrin = @codrin_ccss

INSERT INTO acc.fin_fondos_incapacidad (
	fin_codemp,
	fin_codrin,
	fin_periodo,
	fin_desde,
	fin_hasta,
	fin_dias_derecho,
	fin_dias_incapacitado,
	fin_horas_incapacitado,
	fin_usuario_grabacion,
	fin_fecha_grabacion)
VALUES (@codemp, 
	@codrin_ccss,
	CONVERT(VARCHAR, @desde, 103),
	@desde,
	@hasta,
	ISNULL(@dias_derecho, 0.00),
	ISNULL(@dias, 0.00),
	0.00,
	SYSTEM_USER,
	GETDATE())

SELECT @codfin = fin_codigo
FROM acc.fin_fondos_incapacidad
WHERE fin_codemp = @codemp
	AND fin_codrin = @codrin_ccss
	AND fin_periodo = CONVERT(VARCHAR, @desde, 103)

IF @dias > 0.00
BEGIN
	INSERT INTO cr.din_detalle_incapacidad (
		din_codfin,
		din_fecha_inicial,
		din_fecha_final,
		din_dias,
		din_planilla_autorizada)
	VALUES (@codfin,
		@desde,
		DATEADD(DD, @dias, @desde) + 1,
		@dias,
		1)
END

RETURN