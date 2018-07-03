IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_calculo_liq_aguinaldo'))
BEGIN
	DROP PROCEDURE cr.rep_calculo_liq_aguinaldo
END

GO

--EXEC cr.rep_calculo_liq_aguinaldo 1, '2335', '06/03/2015', 'admin'
CREATE PROCEDURE cr.rep_calculo_liq_aguinaldo (
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
	@codtig_aguinaldo INT

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)
SET @fecha_retiro = CONVERT(DATETIME, @fecha_retiro_txt)

SET @codtig_aguinaldo = ISNULL(gen.get_valor_parametro_int('CodigoTIG_Aguinaldo', NULL, NULL, @codcia, NULL), 0)

PRINT @codemp
PRINT CONVERT(VARCHAR, @fecha_retiro, 103)
PRINT @codtig_aguinaldo

SELECT gen.nombre_mes(MONTH(hli_fecha_ini)) hli_mes,
	YEAR(hli_fecha_ini) hli_anio,
	hli_variable,
	hli_numero,
	CASE WHEN hli_numero > 0 THEN hli_variable ELSE NULL END hli_percibido,
	hli_base_calculo,
	dli_valor
FROM acc.lie_liquidaciones
	JOIN acc.dli_detliq_ingresos ON dli_codlie = lie_codigo
	JOIN cr.hli_historico_liquidaciones ON lie_codemp = hli_codemp AND lie_fecha_retiro = hli_fecha_retiro AND dli_codtig = hli_codtig
WHERE lie_codemp = @codemp
	AND lie_fecha_retiro = @fecha_retiro
	AND dli_codtig = @codtig_aguinaldo
	AND EXISTS (SELECT NULL FROM sco.permiso_empleo_tabla(@usuario) WHERE lie_codemp = codemp)