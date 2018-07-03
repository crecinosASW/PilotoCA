IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_calculo_liq_detalle'))
BEGIN
	DROP PROCEDURE cr.rep_calculo_liq_detalle
END

GO

--EXEC cr.rep_calculo_liq_detalle 1, '2335', '06/03/2015', 'admin'
CREATE PROCEDURE cr.rep_calculo_liq_detalle (
	@codcia INT = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@fecha_retiro_txt VARCHAR(10) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET DATEFORMAT DMY
SET NOCOUNT ON

DECLARE @codemp INT,
	@fecha_retiro DATETIME,
	@codtig_cesantia INT,
	@codtig_preaviso INT,
	@codtig_vacaciones INT,
	@codtig_promedio INT

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)
SET @fecha_retiro = CONVERT(DATETIME, @fecha_retiro_txt)

SET @codtig_cesantia = ISNULL(gen.get_valor_parametro_int('CodigoTIG_Cesantia',NULL,NULL,@codcia,NULL), 0)
SET @codtig_preaviso = ISNULL(gen.get_valor_parametro_int('CodigoTIG_Preaviso',NULL,NULL,@codcia,NULL), 0)
SET @codtig_vacaciones = ISNULL(gen.get_valor_parametro_int('CodigoTIG_VacacionesNoAfectas',NULL,NULL,@codcia,NULL), 0)

IF EXISTS (SELECT NULL
		   FROM acc.lie_liquidaciones
			   JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
		   WHERE lie_codemp = @codemp
			   AND lie_fecha_retiro = @fecha_retiro
			   AND dli_codtig = @codtig_cesantia)
BEGIN
	SET @codtig_promedio = @codtig_cesantia
END

IF EXISTS (SELECT NULL
		   FROM acc.lie_liquidaciones
			   JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
		   WHERE lie_codemp = @codemp
			   AND lie_fecha_retiro = @fecha_retiro
			   AND dli_codtig = @codtig_preaviso) 
	AND @codtig_promedio IS NULL
BEGIN
	SET @codtig_promedio = @codtig_preaviso
END

IF EXISTS (SELECT NULL
		   FROM acc.lie_liquidaciones
			   JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
		   WHERE lie_codemp = @codemp
			   AND lie_fecha_retiro = @fecha_retiro
			   AND dli_codtig = @codtig_vacaciones) 
	AND @codtig_promedio IS NULL
BEGIN
	SET @codtig_promedio = @codtig_vacaciones
END

SELECT gen.nombre_mes(MONTH(hli_fecha_ini)) hli_mes,
	YEAR(hli_fecha_ini) hli_anio,
	ROUND(hli_variable, 2) hli_variable,
	hli_numero,
	CASE WHEN hli_numero > 0 THEN hli_variable ELSE NULL END hli_percibido,
	ROUND(hli_base_calculo, 2) hli_base_calculo,
	ROUND(hli_promedio_mensual, 2) hli_promedio_mensual,
	ROUND(hli_promedio_diario, 2) hli_promedio_diario
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
	JOIN cr.hli_historico_liquidaciones ON lie_codemp = hli_codemp AND lie_fecha_retiro = hli_fecha_retiro AND dli_codtig = hli_codtig
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_promedio
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE lie_codemp = codemp)
ORDER BY hli_fecha_ini