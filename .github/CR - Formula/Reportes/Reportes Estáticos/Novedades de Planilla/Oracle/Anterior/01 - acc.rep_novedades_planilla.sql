IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('acc.rep_novedades_planilla'))
BEGIN
	DROP PROCEDURE acc.rep_novedades_planilla
END

GO

/*Obtiene las acciones que se han realizado en determinado período de planilla. Realiza las siguientes comparaciones para determinar las acciones a mostrar:
altas -> Fecha de inicio ENTRE periodo de planilla
bajas -> Fecha de retiro ENTRE periodo de planilla
Incapacidades -> El período de incapacidad se intercepte con el período de planilla se pueden dar en 4 casos:
	- Fecha Inicio Incapacidad <= Fecha Inicio Planilla y Fecha Fin Incapacidad ENTRE Fecha Inicio Planilla y Fecha Fin Planilla
	- Fecha Inicio Incapacidad <= Fecha Inicio Planilla y Fecha Fin Incapacidad >= Fecha Fin Planilla
	- Fecha Inicio Incapacidad ENTRE Fecha Inicio Planilla y Fecha Fin Planilla y Fecha Fin Incapacidad ENTRE Fecha Inicio Planilla y Fecha Fin Planilla
	- Fecha Inicio Incapacidad ENTRE Fecha Inicio Planilla y Fecha Fin Planilla y Fecha Fin Incapacidad >= Fecha Fin Planilla
Vacaciones -> El período de vacaciones se intercepte con el período de planilla, se comporta de la misma manera que el de incapacidades
Tiempo no trabajado -> Fecha de registro ENTRE período de la planilla
Incrementos salariales-> Fecha de registro ENTRE período de la planilla
Incrementos bonificación decreto -> Fecha de registro ENTRE período de la planilla
Incrementos bonificación -> Fecha de registro ENTRE período de la planilla (Para deteriminar si es decreto o bonificación incentivo se válida que se encuentre en 0 el incremento de una de las dos)
Amonestaciones -> Fecha de registro ENTRE período de la planilla*/

--EXEC acc.rep_novedades_planilla 1, '1', NULL, NULL, NULL, 'admin'
CREATE PROCEDURE acc.rep_novedades_planilla (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@mes INT = NULL,
	@anio INT = NULL,	
	@usuario VARCHAR(50) = NULL
)

AS

BEGIN

--DECLARE @codcia INT,
--	@codtpl_visual VARCHAR(3),
--	@codppl_visual VARCHAR(10),
--	@mes INT = NULL,
--	@anio INT = NULL,
--	@usuario VARCHAR(50)
	
--SET @codcia = 1
--SET	@codtpl_visual = '1'
--SET	@codppl_visual = '20140101'
--SET	@mes INT = NULL,
--SET	@anio INT = NULL,
--SET	@usuario 'admin'	
	
DECLARE @ppl_fecha_inicio DATETIME,
	@ppl_fecha_fin DATETIME,
	@tipo_planilla VARCHAR(50),
	@codtpl INT,
	@codppl INT
	
SELECT @codtpl = tpl_codigo,
	@tipo_planilla = tpl_descripcion
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual

SELECT @codppl = ppl_codigo
FROM sal.ppl_periodos_planilla
WHERE ppl_codigo_planilla = @codppl_visual
	AND ppl_codtpl = @codtpl

SELECT @ppl_fecha_inicio = MIN(ppl_fecha_ini), 
	@ppl_fecha_fin = MAX(ppl_fecha_fin)
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_codigo = ISNULL(@codppl, ppl_codigo)
	AND ppl_anio = ISNULL(@anio, ppl_anio)
	AND ppl_mes = ISNULL(@mes, ppl_mes)

SELECT cia_descripcion,
	@tipo_planilla tpl_descripcion,
	@ppl_fecha_inicio ppl_fecha_inicio,
	@ppl_fecha_fin ppl_fecha_fin,
	exp_codigo_alternativo,
	exp_apellidos_nombres,
	nov_fecha_inicio,
	nov_fecha_fin,
	nov_rubro,
	nov_valor,
	nov_tipo
FROM exp.emp_empleos e
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN (
		SELECT 
			   emp_codigo			nov_codemp,
			   emp_fecha_ingreso	nov_fecha_inicio,
			   NULL					nov_fecha_fin,
			   NULL					nov_rubro,
			   NULL					nov_valor,
			   'Altas'				nov_tipo
		FROM exp.emp_empleos
			JOIN eor.plz_plazas ON emp_codplz = plz_codigo
		WHERE plz_codcia = @codcia
			AND emp_codtpl = @codtpl
			AND emp_fecha_ingreso BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin

		UNION ALL
			
		SELECT 
			   emp_codigo			nov_codemp,
			   emp_fecha_ingreso	nov_fecha_inicio,
			   NULL					nov_fecha_fin,
			   NULL					nov_rubro,
			   NULL					nov_valor,
			   'Bajas'				nov_tipo
		FROM exp.emp_empleos
			JOIN eor.plz_plazas ON emp_codplz = plz_codigo	
		WHERE plz_codcia = @codcia
			AND emp_codtpl = @codtpl
			AND emp_fecha_retiro BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin
			
		UNION ALL

		SELECT 
			   emp_codigo									nov_codemp,
			   inc_fecha_solicitud							nov_fecha_inicio,
			   NULL											nov_fecha_fin,
			   rsa_descripcion								nov_rubro,
			   ese_valor - ISNULL(ese_valor_anterior, 0.00)	nov_valor,
			   'Incrementos salariales'	nov_tipo
		FROM acc.inc_incrementos
			JOIN exp.emp_empleos ON inc_codemp = emp_codigo
			JOIN eor.plz_plazas ON emp_codplz = plz_codigo
			JOIN acc.idr_incremento_detalle_rubros ON inc_codigo = idr_codinc
			JOIN exp.rsa_rubros_salariales ON idr_codrsa = rsa_codigo		
			JOIN exp.ese_estructura_sal_empleos ON idr_codese = ese_codigo
		WHERE plz_codcia = @codcia
			AND emp_codtpl = @codtpl
			AND inc_fecha_solicitud BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin		
			AND idr_valor > 0
			
		UNION ALL

		SELECT 
			   emp_codigo				nov_codemp,
			   tnn_fecha_del			nov_fecha_inicio,
			   tnn_fecha_al				nov_fecha_fin,
			   NULL						nov_rubro,
			   NULL						nov_valor,
			   'Tiempo no trabajado'	nov_tipo
		FROM sal.tnn_tiempos_no_trabajados
			JOIN exp.emp_empleos ON tnn_codemp = emp_codigo
			JOIN eor.plz_plazas ON emp_codplz = plz_codigo		
		WHERE plz_codcia = @codcia
			AND emp_codtpl = @codtpl
			AND (((tnn_fecha_del BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin) AND (tnn_fecha_al BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin))
				OR ((tnn_fecha_del BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin) AND (tnn_fecha_al >= @ppl_fecha_fin))	
				OR ((tnn_fecha_del <= @ppl_fecha_inicio) AND (tnn_fecha_al BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin))
				OR ((tnn_fecha_del <= @ppl_fecha_inicio) AND (tnn_fecha_al >= @ppl_fecha_fin)))
			
		UNION ALL

		SELECT 
			   ixe_codemp		nov_codemp,
			   ixe_inicio		nov_fecha_inicio,
			   ixe_final		nov_fecha_fin,
			   NULL				nov_rubro,
			   NULL				nov_valor,
			   'Incapacidades'	nov_tipo
		FROM acc.ixe_incapacidades
			JOIN exp.emp_empleos ON ixe_codemp = emp_codigo
			JOIN eor.plz_plazas ON emp_codplz = plz_codigo		
		WHERE plz_codcia = @codcia
			AND emp_codtpl = @codtpl
			AND (((ixe_inicio BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin) AND (ixe_final BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin))
				OR ((ixe_inicio BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin) AND (ixe_final >= @ppl_fecha_fin))	
				OR ((ixe_inicio <= @ppl_fecha_inicio) AND (ixe_final BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin))
				OR ((ixe_inicio <= @ppl_fecha_inicio) AND (ixe_final >= @ppl_fecha_fin)))

		UNION ALL

		SELECT 
			   vac_codemp	nov_codemp,
			   dva_desde	nov_fecha_inicio,
			   dva_hasta	nov_fecha_fin,
			   NULL			nov_rubro,
			   NULL			nov_valor,
			   'Vacaciones'	nov_tipo
		FROM acc.vac_vacaciones
			JOIN acc.dva_dias_vacacion ON vac_codigo = dva_codvac
			JOIN exp.emp_empleos ON vac_codemp = emp_codigo
			JOIN eor.plz_plazas ON emp_codplz = plz_codigo		
		WHERE plz_codcia = @codcia
			AND emp_codtpl = @codtpl
			AND (((dva_desde BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin) AND (dva_hasta BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin))
				OR ((dva_desde BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin) AND (dva_hasta >= @ppl_fecha_fin))	
				OR ((dva_desde <= @ppl_fecha_inicio) AND (dva_hasta BETWEEN @ppl_fecha_inicio AND @ppl_fecha_fin))
				OR ((dva_desde <= @ppl_fecha_inicio) AND (dva_hasta >= @ppl_fecha_fin)))

		UNION ALL

		SELECT 
			   amo_codemp				nov_codemp,
			   amo_inicio_suspension	nov_fecha_inicio,
			   amo_final_suspension		nov_fecha_fin,
			   NULL						nov_rubro,
			   NULL						nov_valor,
			   'Amonestaciones'			nov_tipo
		FROM acc.amo_amonestaciones
			JOIN exp.emp_empleos ON amo_codemp = emp_codigo
			JOIN eor.plz_plazas ON emp_codplz = plz_codigo
		WHERE plz_codcia = @codcia
			AND amo_codppl_suspension = @codppl) novedades ON emp_codigo = novedades.nov_codemp
WHERE sco.permiso_empleo(emp_codigo, @usuario) = 1
	
END