IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.Liq_Descuentos'))
BEGIN
	DROP PROCEDURE cr.Liq_Descuentos
END

GO

--------------------------------------------------------------------------------------
-- Evolution STANDARD - Liquidacion                                                 --
-- Proceso Principal calculo de Descuentos a la fecha de retiro                     --
-- Funciones que utiliza:                                                           --
--------------------------------------------------------------------------------------
CREATE PROCEDURE cr.Liq_Descuentos (
	@codemp INT, 
	@fecha_retiro DATETIME,
	@codmon VARCHAR(3),
	@fecha_ingreso DATETIME,
	@codtdc_asociacion INT,
	@codtrs_asociacion INT
)

AS

SET DATEFORMAT DMY

DECLARE @valor_anticipo MONEY,
	@valor_descuento MONEY,
	@fecha_desde DATETIME

-------------------------------------------------------------
-- busca si hay anticipo de salario pendiente de descontar --
-------------------------------------------------------------
-- busca el posible anticipo quincenal que se pudo haber dado en el mes de
-- retiro siempre y cuando no se haya pagado la planilla mensual de ese mes
SET @fecha_desde = CONVERT(DATETIME, '01/' + CONVERT(VARCHAR, MONTH(@fecha_retiro)) + '/' + CONVERT(VARCHAR, YEAR(@fecha_retiro)))

-- si aún no ha recibo pago, entonces se le buscara desde su fecha de ingreso.
IF @fecha_desde IS NULL 
   SET @fecha_desde = @fecha_ingreso

-------------------------------------------
-- generacion de registros de descuentos --
-------------------------------------------

EXEC cr.LIQ_DescuentoAsociacion @codemp, 
								@fecha_retiro, 
								@codmon,
								@fecha_ingreso,
								@codtdc_asociacion,
								@codtrs_asociacion

--------------------------
-- por otros descuentos --
--------------------------
-- toma en cuenta los descuentos no ciclicos que deben de aplicarse en la
-- planilla dentro de la cual ocurrio el retiro
SELECT ods_codtdc,
	0,
	ods_valor_a_descontar,
	0.00,
	0.00,
	ods_codmon,
	0, 
	'Dias',
	'ODS-' + CONVERT(VARCHAR, ods_codigo) det_comentario,
	0
FROM sal.ods_otros_descuentos 
	JOIN sal.ppl_periodos_planilla ON ods_codppl = ppl_codigo
WHERE ods_codemp = @codemp
	AND ods_estado = 'Autorizado'
	AND ods_aplicado_planilla = 0
	AND @fecha_retiro BETWEEN @fecha_desde AND @fecha_retiro
	AND NOT EXISTS(SELECT NULL FROM #dld_detliq_descuentos WHERE dld_codtdc = ods_codtdc)
-----------------------------
-- por descuentos ciclicos --
-----------------------------
-- de los descuentos ciclicos toma todos aquellos que no son indefinidos,
-- que tengan saldo y que el flag de descontar al momento de la
-- liquidacion este en cuota o saldo.
UNION ALL
SELECT dcc_codtdc,
	0,
	CASE 
		WHEN dcc_accion_liquidacion = 'ProcesaCuota' 
			THEN dcc_valor_cuota 
	ELSE dcc_saldo
	END,
	0.00,
	0.00,
	dcc_codmon,
	0,
	'Dias',
	'PRE-' + CONVERT(VARCHAR, dcc_codigo),
	0
FROM sal.dcc_descuentos_ciclicos
WHERE dcc_estado = 'Autorizado'
	AND dcc_activo = 1
	AND dcc_accion_liquidacion <> 'ninguna'
	AND dcc_codemp = @codemp
	AND dcc_monto_indefinido = 0
	AND dcc_saldo > 0.00
	AND NOT EXISTS(SELECT NULL FROM #dld_detliq_descuentos WHERE dld_codtdc = dcc_codtdc)

RETURN