IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.inc_act_periodo_incapacidad'))
BEGIN
	DROP PROCEDURE cr.inc_act_periodo_incapacidad
END

GO

/*
Nombre: cr.inc_act_periodo_incapacidad
Descripción: Procedimiento que actualiza los días en que se ha incapacitado un empleado, para llevar el control de las incapacidades por mes.
			 Se paga el 50% de los primeros 3 días en el lapso de 1 mes a partir del primer día de incapacidad. Esto significa que si un 
			 empleado no se ha incapacitado en 1 mes o más al momento de incapacitarse se le van a pagar el 50% de tres días del mes 
			 (No necesariamente es un mes calendario), el mes comienza en la fecha de inicio de la incapacidad y termina un mes después,
			 por ejemplo si la incapacidad es el 05/01/2015, el mes sería desde 3l 05/01/2015 al 04/02/2015.
Proceso: 
	- Este proceso se va a ejecutar al momento de inicializar la planilla para los empleados que tengan una incapacidad dentro del período de planilla
	- Para cada una de las incapacidades de los empleados
		- Se obtiene el período de incapacidad más reciente de la tabla auxiliar acc.fin_fondos_incapacidad
		- Se obtiene la fecha de inicio y fin de la incapacidad
		- Si la fecha de inicio de la incapacidad es después de la fecha fin del período de incapacidad más reciente
			- Se crea un nuevo período de incapacidad de la siguiente forma:
				- Fecha de inicio del periodo -> Fecha de inicio de incapacidad
				- Fecha fin del período -> Fecha de inicio del período más un mes, menos un día
				- Dias -> 0
		- Si la fecha de fin de la incapacidad es menor a la fecha de inicio del período de incapacidad más reciente
			- No se crea ningún período
		- Si la fecha de inicio de la incapacidad es menor a la fecha de inicio del período pero la fecha de fin esta dentro del período
			- No se crea ningún período
		- Si la fecha de inicio de la incapacidad esta dentro del período y la fecha de fin de la incapacidad es después del período (Se debe validar esto en un ciclo por si la fecha de la incapacidad sigue siendo mayor)
			- Se crea un nuevo período de incapacidad de la siguiente forma:
				- Fecha de inicio del periodo -> Fecha de fin del período más reciente más un día
				- Fecha fin del período -> Fecha de inicio del período más un mes, menos un día
				- Dias -> 0
		- Si la fecha de inicio de la incapacidad es menor a la fecha de inicio del período y la fecha de fin es despúés del período
			- Se crea un nuevo período de incapacidad de la siguiente forma:
				- Fecha de inicio del periodo -> Fecha de fin del período más reciente más un día
				- Fecha fin del período -> Fecha de inicio del período más un mes, menos un día
				- Dias -> 0
		- Si la fecha de inicio esta dentro del período y la fecha fin está dentro del período
			- No se crea ningún período
*/
--EXEC cr.inc_act_periodo_incapacidad NULL, 80, 'admin'
CREATE PROCEDURE cr.inc_act_periodo_incapacidad (
	@sessionId UNIQUEIDENTIFIER = NULL,
    @codppl INT,
    @userName VARCHAR(100) = null
)

AS

SET DATEFORMAT DMY
SET DATEFIRST 1
SET NOCOUNT ON

DECLARE @codpai VARCHAR(2),
	@codcia INT,
	@codtpl INT,
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@codemp INT,
	@incap_del_act DATETIME,
	@incap_al_act DATETIME,
	@incap_del DATETIME, 
	@incap_al DATETIME,
	@incap_actual DATETIME,
	@fin_fecha_inicial_ult DATETIME,
	@fin_fecha_final_ult DATETIME,
	@fin_fecha_inicial DATETIME,
	@fin_fecha_final DATETIME,
	@codrin INT,
	@dias REAL

SELECT @codpai = cia_codpai,
	@codcia = cia_codigo,
	@codtpl = tpl_codigo,
	@ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE ppl_codigo = @codppl

DELETE cr.din_detalle_incapacidad
WHERE din_planilla_autorizada = 0

DECLARE incapacidades CURSOR FOR
SELECT ixe_codemp,
	ixe_inicio,
	ixe_final,
	(CASE WHEN ixe_inicio < @ppl_fecha_ini THEN @ppl_fecha_ini ELSE ixe_inicio END) ixe_inicio, 
	(CASE WHEN ISNULL(ixe_final, DATEADD(DD, 1, @ppl_fecha_fin)) > @ppl_fecha_fin THEN @ppl_fecha_fin ELSE ixe_final END) ixe_final,
	ixe_codrin
FROM acc.ixe_incapacidades
	JOIN exp.emp_empleos ON ixe_codemp = emp_codigo
	JOIN acc.rin_riesgos_incapacidades ON ixe_codrin = rin_codigo
WHERE emp_codtpl = @codtpl
	AND (emp_estado = 'A'
		OR (emp_estado = 'R' AND emp_fecha_retiro BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin))
	AND ixe_estado <> 'Pendiente'
	AND ((ixe_inicio < @ppl_fecha_ini AND ixe_final BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin)
		OR (ixe_inicio BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin AND ISNULL(ixe_final, DATEADD(DD, 1, @ppl_fecha_fin)) > @ppl_fecha_fin)
		OR (ixe_inicio >= @ppl_fecha_ini AND ixe_final <= @ppl_fecha_fin)
		OR (ixe_inicio < @ppl_fecha_fin AND ISNULL(ixe_final, DATEADD(DD, 1, @ppl_fecha_fin)) > @ppl_fecha_fin))
	AND sal.empleado_en_gen_planilla(@sessionId, emp_codigo) = 1

OPEN incapacidades

FETCH NEXT FROM incapacidades INTO @codemp, @incap_del_act, @incap_al_act, @incap_del, @incap_al, @codrin

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @fin_fecha_inicial = NULL
	SET @fin_fecha_final = NULL
	SET @dias = 0.00

	SELECT @dias = MAX(pin_final)
	FROM acc.pin_parametros_incapacidad
	WHERE pin_codcia = @codcia
		AND pin_codrin = @codrin
		AND pin_por_subsidio_sal_maximo > 0.00

	SELECT @fin_fecha_inicial_ult = MAX(fin_desde),
		@fin_fecha_final_ult = MAX(fin_hasta)
	FROM acc.fin_fondos_incapacidad
	WHERE fin_codemp = @codemp
		AND fin_codrin = @codrin

	SET @fin_fecha_final_ult = ISNULL(@fin_fecha_final_ult, DATEADD(DD, -1, @incap_del_act))

	WHILE @incap_al_act > @fin_fecha_final_ult
	BEGIN
		IF @incap_del_act > @fin_fecha_final_ult
			SET @fin_fecha_inicial = @incap_del_act
		ELSE
			SET @fin_fecha_inicial = DATEADD(DD, 1, @fin_fecha_final_ult)

		SET @fin_fecha_final = DATEADD(MM, 1, @fin_fecha_inicial)

		IF NOT EXISTS (SELECT NULL 
					   FROM acc.fin_fondos_incapacidad
					   WHERE fin_codemp = @codemp 
						   AND fin_desde = @fin_fecha_inicial 
						   AND fin_hasta = @fin_fecha_final)
			AND @fin_fecha_inicial IS NOT NULL AND @fin_fecha_final IS NOT NULL
		BEGIN
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
				@codrin,
				CONVERT(VARCHAR, @fin_fecha_inicial, 103),
				@fin_fecha_inicial,
				@fin_fecha_final,
				ISNULL(@dias, 0.00),
				0.00,
				0.00,
				@userName,
				GETDATE())
		END	

		SELECT @fin_fecha_inicial_ult = MAX(fin_desde),
			@fin_fecha_final_ult = MAX(fin_hasta)
		FROM acc.fin_fondos_incapacidad
		WHERE fin_codemp = @codemp
			AND fin_codrin = @codrin
	END

	FETCH NEXT FROM incapacidades INTO @codemp, @incap_del_act, @incap_al_act, @incap_del, @incap_al, @codrin
END

CLOSE incapacidades
DEALLOCATE incapacidades

INSERT INTO cr.din_detalle_incapacidad (din_codixe, din_codfin, din_fecha_inicial, din_fecha_final, din_dias, din_planilla_autorizada)
SELECT ixe_codigo,
	fin_codigo,
	CASE WHEN ixe_inicio < fin_desde THEN fin_desde ELSE ixe_inicio END fin_desde,
	CASE WHEN ISNULL(ixe_final, DATEADD(DD, 1, fin_hasta)) > fin_hasta THEN fin_hasta ELSE ixe_final END fin_hasta,
	0.00 din_dias,
	0 din_planilla_autorizada
FROM acc.ixe_incapacidades
	JOIN exp.emp_empleos ON ixe_codemp = emp_codigo
	JOIN acc.fin_fondos_incapacidad ON ixe_codemp = fin_codemp AND ixe_codrin = fin_codrin
		AND ((ixe_inicio < fin_desde AND ixe_final BETWEEN fin_desde AND fin_hasta)
			OR (ixe_inicio BETWEEN fin_desde AND fin_hasta AND ISNULL(ixe_final, DATEADD(DD, 1, fin_hasta)) > fin_hasta)
			OR (ixe_inicio >= fin_desde AND ixe_final <= fin_hasta)
			OR (ixe_inicio < fin_hasta AND ISNULL(ixe_final, DATEADD(DD, 1, fin_hasta)) > fin_hasta))
WHERE emp_codtpl = @codtpl
	AND (emp_estado = 'A'
		OR (emp_estado = 'R' AND emp_fecha_retiro BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin))
	AND ixe_estado <> 'Pendiente'
	AND ((ixe_inicio < @ppl_fecha_ini AND ixe_final BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin)
		OR (ixe_inicio BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin AND ISNULL(ixe_final, DATEADD(DD, 1, @ppl_fecha_fin)) > @ppl_fecha_fin)
		OR (ixe_inicio >= @ppl_fecha_ini AND ixe_final <= @ppl_fecha_fin)
		OR (ixe_inicio < @ppl_fecha_fin AND ISNULL(ixe_final, DATEADD(DD, 1, @ppl_fecha_fin)) > @ppl_fecha_fin))
	AND sal.empleado_en_gen_planilla(@sessionId, emp_codigo) = 1