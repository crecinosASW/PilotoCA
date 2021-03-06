IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.vac_genera_periodo_vacacion'))
BEGIN
	DROP PROCEDURE cr.vac_genera_periodo_vacacion
END

GO

CREATE PROCEDURE cr.vac_genera_periodo_vacacion (
	@varcodcia      INT, 
	@varanioini     INT, 
	@varaniofin     INT = NULL,
	@varcodemp      INT = NULL,
	@vargendiasgoce BIT = 0,
	@varutifecani   BIT = 1,
	@varfechaapart  DATETIME = NULL,
	@varusaparame   BIT = 1,
	@vardiasotra    INT = NULL,
	@varuser        VARCHAR(50) = NULL
)

AS

--DECLARE    @varcodcia      INT,     @varanioini     INT,    @varaniofin     INT ,    @varcodemp INT ,
--           @vargendiasgoce BIT , @varutifecani   BIT,    @varfechaapart  DATETIME,@varusaparame   BIT,  
--           @vardiasotra    INT ,@varuser        VARCHAR(50)
--SELECT     @varcodcia=2,@varanioini=2012,@varaniofin=2013,@varcodemp=56,
--           @vargendiasgoce=0, @varutifecani=0,    @varfechaapart= NULL ,@varusaparame = 1,  
--           @vardiasotra=0,@varuser='jcsoria'

SET NOCOUNT ON
SET DATEFORMAT DMY
SET DATEFIRST 7 -- significa que domingo es 1 de la semana

/*
 * este procedimiento difiere de otros porque el número de días a adjudicar
 * de acuerdo a la tabla de parámetros es variable dependiendo de la antigüedad
 * del empleado.
 */
 
 /*

DECLARE @codpai VARCHAR(2),
	@tmpcodigoperiodo  AS VARCHAR(9),
	@es_acumulativa BIT,
	@fecha DATETIME

SET @fecha = GETDATE()

SELECT @codpai = cia_codpai
FROM eor.cia_companias
WHERE cia_codigo = @varcodcia

--* 
--* genera el codigo del periodo en base a los datos
--*
SET @tmpcodigoperiodo = CONVERT(VARCHAR, @varanioini) + '-' + CONVERT(VARCHAR, @varaniofin)
SET @es_acumulativa = ISNULL(gen.get_valor_parametro_bit('VacacionEsAcumulativa', @codpai, NULL, NULL, NULL), 1)

INSERT INTO acc.vac_vacaciones (vac_codemp, 
	vac_periodo, 
	vac_desde,
	vac_hasta, 
	vac_periodo_anterior, 
	vac_dias, 
	vac_saldo, 
	vac_gozados, 
    vac_fecha_pago_prima, 
	vac_usuario_grabacion, 
	vac_fecha_grabacion)
SELECT emp_codigo, 
	emp_periodo, 
	emp_fecha_ini, 
	emp_fecha_fin,
    0 emp_periodo_ant,
	CASE 
		WHEN @es_acumulativa = 1 THEN 0.00 
		ELSE ISNULL(
			CASE 
				WHEN (@varusaparame = 0) AND (@vardiasotra > 0) THEN @vardiasotra
                ELSE ISNULL((SELECT valor FROM gen.get_valor_rango_parametro('VacacionDiasRango', @codpai, NULL, NULL, NULL, gen.get_diferencia_anios(emp_fecha_ingreso, emp_fecha_fin))), 0)
			END, 0) 
	END emp_dias,
	CASE 
		WHEN @es_acumulativa = 1 THEN 0.00 
		ELSE ISNULL(
			CASE 
				WHEN (@varusaparame = 0) AND (@vardiasotra > 0) THEN @vardiasotra
                ELSE ISNULL((SELECT valor FROM gen.get_valor_rango_parametro('VacacionDiasRango', @codpai, NULL, NULL, NULL, gen.get_diferencia_anios(emp_fecha_ingreso, emp_fecha_fin))), 0)
			END, 0) 
	END saldo,
	0 gozados, 
	NULL, 
	ISNULL(@varuser, SYSTEM_USER), 
	GETDATE()
FROM (
	SELECT emp_codigo,
		@tmpcodigoperiodo emp_periodo,
		CONVERT(DATETIME, 
			CASE WHEN DAY(emp_fecha_ingreso) = 29 AND MONTH(emp_fecha_ingreso) = 2 THEN '28' ELSE CONVERT(VARCHAR, DAY(emp_fecha_ingreso)) END + '/' + 
			CONVERT(VARCHAR, MONTH(emp_fecha_ingreso)) + '/' +
			CONVERT(VARCHAR, @varanioini), 103) emp_fecha_ini,
		DATEADD(DD, -1, DATEADD(YY, 1, CONVERT(DATETIME, 
			CASE WHEN DAY(emp_fecha_ingreso) = 29 AND MONTH(emp_fecha_ingreso) = 2 THEN '28' ELSE CONVERT(VARCHAR, DAY(emp_fecha_ingreso)) END + '/' + 
			CONVERT(VARCHAR, MONTH(emp_fecha_ingreso)) + '/' +
			CONVERT(VARCHAR, @varanioini), 103))) emp_fecha_fin,
		emp_fecha_ingreso
	FROM exp.emp_empleos
		JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	WHERE plz_codcia = @varcodcia
		AND emp_estado = 'A'
		AND emp_codigo = ISNULL(@varcodemp, emp_codigo)
		AND emp_fecha_ingreso < CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, @varanioini + 1), 103)
		AND NOT EXISTS (SELECT NULL 
						FROM acc.vac_vacaciones
						WHERE vac_codemp = emp_codigo
							AND vac_periodo = @tmpcodigoperiodo)) f1

--*
--* genera los dias de goce de los empleados
--* en los primeros quince dias del siguiente mes
--*
IF ISNULL(@vargendiasgoce, 0) = 1 AND @es_acumulativa = 0
BEGIN
	--PRINT 'antes de SELECT'
	--PRINT '@varfechaapart: ' + ISNULL(CAST(@varfechaapart AS VARCHAR), 'NULL')
	--PRINT '@varusaparame: ' + ISNULL(CAST(@varusaparame AS VARCHAR), 'NULL')
	--PRINT '@vardiasotra: ' + ISNULL(CAST(@vardiasotra AS VARCHAR), 'NULL')
	--PRINT '@diasadjudicados: ' + ISNULL(CAST(@diasadjudicados AS VARCHAR), 'NULL')
    
    -- inserta los dias a generar en una tabla temporal
	SELECT codvac, 
		desde, 
		hasta, 
		dias, 
		0 pagados, 
		ISNULL(@varuser, SYSTEM_USER) usuario, 
		GETDATE() fecha
	INTO #dvatemp
	FROM (
		SELECT emp_codigo,
			vac_codigo codvac, 
			CASE 
				WHEN (@varutifecani = 0) AND (@varfechaapart IS NOT NULL) THEN @varfechaapart 
				ELSE acc.vac_busca_inicio_periodo_goce(emp_codigo, @varanioini) 
			END desde,
			ISNULL(
				CASE 
					WHEN (@varutifecani = 0) AND (@varfechaapart IS NOT NULL) 
					THEN acc.vac_busca_final_periodo_goce(emp_codigo, @varfechaapart,
						CASE 
							WHEN (@varusaparame = 0) AND (@vardiasotra > 0) THEN @vardiasotra
							ELSE ISNULL((SELECT valor FROM gen.get_valor_rango_parametro('VacacionDiasRango', @codpai, NULL, NULL, NULL, gen.get_diferencia_anios(emp_fecha_ingreso, vac_hasta))), 0)
						END)                            
					ELSE acc.vac_busca_final_periodo_goce(emp_codigo, acc.vac_busca_inicio_periodo_goce(emp_codigo, @varanioini),
						CASE 
							WHEN (@varusaparame = 0) AND (@vardiasotra > 0) THEN @vardiasotra
							ELSE ISNULL((SELECT valor FROM gen.get_valor_rango_parametro('VacacionDiasRango', @codpai, NULL, NULL, NULL, gen.get_diferencia_anios(emp_fecha_ingreso, vac_hasta))), 0)
						END) 
				END,
				CASE 
					WHEN (@varutifecani = 0) AND (@varfechaapart IS NOT NULL) THEN @varfechaapart 
					ELSE acc.vac_busca_inicio_periodo_goce(emp_codigo, @varanioini) 
				END) hasta,
			ISNULL(
				CASE 
					WHEN (@varusaparame = 0) AND (@vardiasotra > 0) THEN @vardiasotra
					ELSE ISNULL((SELECT valor FROM gen.get_valor_rango_parametro('VacacionDiasRango', @codpai, NULL, NULL, NULL, gen.get_diferencia_anios(emp_fecha_ingreso, vac_hasta))), 0)
				END, 0) dias
		FROM exp.emp_empleos
			JOIN eor.plz_plazas ON plz_codigo = emp_codplz
			JOIN acc.vac_vacaciones ON vac_codemp = emp_codigo AND vac_periodo = @tmpcodigoperiodo
		WHERE plz_codcia = @varcodcia
			AND emp_estado = 'A'
			AND emp_codigo = ISNULL(@varcodemp, emp_codigo)
			AND emp_fecha_ingreso < CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, @varanioini + 1), 103)
			AND vac_saldo >= ISNULL(
								CASE 
									WHEN (@varusaparame = 0) AND (@vardiasotra > 0) THEN @vardiasotra
									ELSE ISNULL((SELECT valor FROM gen.get_valor_rango_parametro('VacacionDiasRango', @codpai, NULL, NULL, NULL, gen.get_diferencia_anios(emp_fecha_ingreso, vac_hasta))), 0)
								END, 0)) v1
	WHERE NOT EXISTS (
		SELECT NULL 
		FROM acc.dva_dias_vacacion
			JOIN acc.vac_vacaciones ON vac_codigo = dva_codvac
		WHERE vac_codemp = emp_codigo
			AND vac_periodo = @tmpcodigoperiodo
			AND dva_desde = desde
			AND dva_hasta = hasta
			AND dva_dias = dias)

    --PRINT 'despues de SELECT'
    BEGIN TRANSACTION
    
    --*
    --* genera los dias de goce de los empleados
    --*
    INSERT INTO acc.dva_dias_vacacion (dva_codvac, 
		dva_desde, 
		dva_hasta, 
		dva_dias, 
		dva_pagadas, 
		dva_usuario_grabacion, 
		dva_fecha_grabacion)
    SELECT * FROM #dvatemp
    
   --*
   --* por si acaso ya habian empleados para este periodo
   --* actualiza el maestro con los dias ya asinados a goze
   --*
   UPDATE acc.vac_vacaciones
	SET vac_gozados = ISNULL((SELECT SUM(ISNULL(t1.dva_dias, 0))
                              FROM acc.dva_dias_vacacion t1
                              WHERE t1.dva_codvac = vac_codigo), 0)
   WHERE EXISTS (SELECT NULL 
				 FROM #dvatemp 
				 WHERE vac_codigo = codvac)
    
    COMMIT TRANSACTION
            
    DROP TABLE #dvatemp
END

IF @es_acumulativa = 1
BEGIN
	EXECUTE cr.vac_act_periodo_vacacion @varcodcia, @varcodemp, @fecha
END

*/