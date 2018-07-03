IF EXISTS (
	SELECT NULL
	FROM sys.procedures p
		JOIN sys.schemas s ON p.schema_id = s.schema_id  
	WHERE p.name = 'rep_calculo_embargo'
		AND s.name = 'cr')
	DROP PROCEDURE cr.rep_calculo_embargo
	
GO

/*Obtiene el monto embargable del empleado basándose en los ingresos percibidos en el período de planilla anterior*/
--EXEC cr.rep_calculo_embargo 5, '1', '20140602', NULL, 'jcsoria'
CREATE PROCEDURE cr.rep_calculo_embargo (
	@codcia INT,
	@codtpl_visual VARCHAR(3),
	@codppl_visual VARCHAR(10),
	@codemp_alternativo VARCHAR(36) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET DATEFORMAT dmy
SET NOCOUNT ON	

--Definición de Variables	
DECLARE @codpai VARCHAR(2),
	@cia_descripcion VARCHAR(50),
	@tpl_descripcion VARCHAR(20),
	@codemp INT,
	@codtpl INT,
	@codppl INT,
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@codppl_anterior INT,
	@codppl_visual_anterior VARCHAR(3),
	@ppl_fecha_ini_anterior DATETIME,
	@ppl_fecha_fin_anterior DATETIME,
	@salario_inembargable MONEY,
	@porcentaje_embargo_menor REAL,
	@porcentaje_embargo_mayor REAL,
	@no_salarios_minimos REAL,
	@codagr_ingresos INT,
	@codagr_seguro_social INT,
	@codagr_isr INT,
	@codagr_pension INT

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)

SELECT @codpai = pai_codigo,
	@cia_descripcion = cia_descripcion
FROM eor.cia_companias
	JOIN gen.pai_paises ON cia_codpai=pai_codigo
WHERE cia_codigo = @codcia

SELECT @codtpl = tpl_codigo,
	@tpl_descripcion = tpl_descripcion
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual

--Obtiene el tipo de planilla y las fechas de inicio y fin de la planilla actual
SELECT @codppl = ppl_codigo,
	@ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_codigo_planilla = @codppl_visual

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRCalculoEmbargoIngresos'
	AND agr_codpai = @codpai

SELECT @codagr_seguro_social = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRCalculoEmbargoSeguroSocial'
	AND agr_codpai = @codpai	

SELECT @codagr_isr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRCalculoEmbargoISR'
	AND agr_codpai = @codpai	

SELECT @codagr_pension = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRCalculoEmbargoPension'
	AND agr_codpai = @codpai		

--Parámetros de Aplicación
SET @salario_inembargable = ISNULL(gen.get_valor_parametro_money('EmbargosSalarioInembargable', @codpai, NULL, NULL, NULL), 0.00)
SET	@porcentaje_embargo_menor = ISNULL(gen.get_valor_parametro_float('EmbargosPorcentajeMenores', @codpai, NULL, NULL, NULL), 0.00)
SET	@porcentaje_embargo_mayor = ISNULL(gen.get_valor_parametro_float('EmbargosPorcentajeMayores', @codpai, NULL, NULL, NULL), 0.00)
SET	@no_salarios_minimos = ISNULL(gen.get_valor_parametro_float('EmbargosNumeroSalariosMinimos', @codpai, NULL, NULL, NULL), 0.00)

--Obtiene el código de la planilla anterior autorizada
SELECT @codppl_anterior = ppl_codigo,
	@codppl_visual_anterior = ppl_codigo_planilla,
	@ppl_fecha_ini_anterior = ppl_fecha_ini,
	@ppl_fecha_fin_anterior = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_fecha_fin = (SELECT DATEADD(DD, -1, ppl_fecha_ini)
  						  FROM sal.ppl_periodos_planilla
						  WHERE ppl_codigo = @codppl)

SELECT cia_descripcion,
	tpl_descripcion,
	codppl_visual,
	ppl_fecha_ini,
	ppl_fecha_fin,
	codppl_visual_anterior,
	ppl_fecha_ini_anterior,
	ppl_fecha_fin_anterior,
	exp_codigo_alternativo,
	hpa_nombres_apellidos,
	total_ingresos,
	seguro_social,
	isr,
	liquido,
	pension_alimenticia,
	liquido_menos_pension,
	salario_inembargable,
	salario_embargable,
	CASE 
		WHEN total_ingresos >= 0 AND total_ingresos < salario_inembargable * @no_salarios_minimos THEN
			ROUND(salario_embargable * @porcentaje_embargo_menor / 100.00, 2)
		WHEN total_ingresos >= salario_inembargable * @no_salarios_minimos THEN
			ROUND(salario_embargable * @porcentaje_embargo_mayor / 100.00, 2)
		ELSE
			0.00
	END embargo_maximo
FROM (
	SELECT cia_descripcion,
		tpl_descripcion,
		codppl_visual,
		ppl_fecha_ini,
		ppl_fecha_fin,
		codppl_visual_anterior,
		ppl_fecha_ini_anterior,
		ppl_fecha_fin_anterior,
		exp_codigo_alternativo,
		hpa_nombres_apellidos,
		total_ingresos,
		seguro_social,
		isr,
		total_ingresos - seguro_social - isr liquido,
		pension_alimenticia,
		total_ingresos - seguro_social - isr - pension_alimenticia liquido_menos_pension,
		@salario_inembargable salario_inembargable,
		CASE 
			WHEN total_ingresos - seguro_social - isr - pension_alimenticia - @salario_inembargable < 0.00 THEN 0.00
			ELSE total_ingresos - seguro_social - isr - pension_alimenticia - @salario_inembargable 
		END salario_embargable
	FROM (		  
		SELECT @cia_descripcion cia_descripcion,
			@tpl_descripcion tpl_descripcion,
			@codppl_visual codppl_visual,
			@ppl_fecha_ini ppl_fecha_ini,
			@ppl_fecha_fin ppl_fecha_fin,
			@codppl_visual_anterior codppl_visual_anterior,
			@ppl_fecha_ini_anterior ppl_fecha_ini_anterior,
			@ppl_fecha_fin_anterior ppl_fecha_fin_anterior,
			exp_codigo_alternativo,
			hpa_nombres_apellidos,
			ISNULL((
				SELECT SUM(inn_valor)
				FROM sal.inn_ingresos
				WHERE inn_codppl = hpa_codppl
					AND inn_codemp = hpa_codemp
					AND inn_codtig IN (SELECT iag_codtig
										FROM sal.iag_ingresos_agrupador
										WHERE iag_codagr = @codagr_ingresos)), 0.00) total_ingresos,
			ISNULL((
				SELECT SUM(dss_valor)
				FROM sal.dss_descuentos
				WHERE dss_codppl = hpa_codppl
					AND dss_codemp = hpa_codemp
					AND dss_codtdc IN (SELECT dag_codtdc
									   FROM sal.dag_descuentos_agrupador
									   WHERE dag_codagr = @codagr_seguro_social)), 0.00) seguro_social,
			ISNULL((
				SELECT SUM(dss_valor)
				FROM sal.dss_descuentos
				WHERE dss_codppl = hpa_codppl
					AND dss_codemp = hpa_codemp
					AND dss_codtdc IN (SELECT dag_codtdc
									   FROM sal.dag_descuentos_agrupador
									   WHERE dag_codagr = @codagr_isr)), 0.00) isr,
			ISNULL((
				SELECT SUM(dss_valor)
				FROM sal.dss_descuentos
				WHERE dss_codppl = hpa_codppl
					AND dss_codemp = hpa_codemp
					AND dss_codtdc IN (SELECT dag_codtdc
									   FROM sal.dag_descuentos_agrupador
									   WHERE dag_codagr = @codagr_pension)), 0.00) pension_alimenticia
		FROM sal.hpa_hist_periodos_planilla
			JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
			JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
		WHERE hpa_codppl = @codppl_anterior
			AND hpa_codemp = ISNULL(@codemp, hpa_codemp)
			AND EXISTS (SELECT NULL
						FROM sal.inn_ingresos
						WHERE inn_codppl = hpa_codppl
							AND inn_codemp = hpa_codemp
							AND inn_valor > 0.00)
			AND sco.permiso_empleo(hpa_codemp, @usuario) = 1) d) a