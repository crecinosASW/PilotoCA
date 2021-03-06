IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.LIQ_Ingresos'))
BEGIN
	DROP PROCEDURE cr.LIQ_Ingresos
END

GO

--------------------------------------------------------------------------------------
-- Evolution STANDARD - Liquidacion                                                 --
-- Proceso Principal de Ingresos a la fecha de retiro                               --
-- Funciones y Procedimmientos que utiliza:                                         --
--   01.- gt.LIQ_SalarioProporcional                                                --
--   02.- gt.LIQ_AguinaldoProporcional                                              --
--   03.- gt.Liq_Bono14Proporcional                                                 --
--   04.- gt.LIQ_IndemnizacionProporcional                                          -- 
--                                                                                  --
-- Calcula el salario ordinario                                                     --
--            vacaciones                                                            --
--            Aguinaldo                                                             --  
--            Cesantía	                                                            -- 
--            Preaviso	                                                            -- 
--            Extraordinario si la fecha de retiro esta en el rango                 --
--                           de fechas de la planilla a la cual fueron              --
--                           asignadas                                              --
--            Ingresos Ciclicos si la fecha de retiro esta en el rango              --
--                           de fechas de la planilla a la cual fueron              --
--                           asignadas                                              --
--            Otros Ingresos si la fecha de retiro esta en el rango                 --
--                           de fechas de la planilla a la cual fueron              --
--                           asignadas                                              --
--------------------------------------------------------------------------------------
CREATE PROCEDURE cr.LIQ_Ingresos (
	@codemp INT, 
	@fecha_retiro DATETIME, 
	@paga_cesantia BIT = 0, 
	@paga_preaviso BIT = 0, 
	@dias_preaviso REAL = 0.00,
	@codmon VARCHAR(3),
	@fecha_ingreso DATETIME,
	@codtig_salario INT,
	@codtig_aguinaldo INT,
	@codtig_vac INT,
	@codtig_cesantia INT,
	@codtig_preaviso INT,
	@codtig_ahorro_escolar INT,
	@codtig_ahorro_patronal INT,
	@codtrs_ahorro_patronal INT,
	@codtpl_salario INT,
	@codtpl_aguinaldo INT,
	@codagr_cesantia INT,
	@codagr_vac INT,
	@codagr_aguinaldo INT,
	@codagr_preaviso INT,
	@codagr_ahorro_escolar INT,
	@salario_actual REAL
)

AS

SET DATEFORMAT DMY

DECLARE @fecha_desde DATETIME

SET DATEFORMAT DMY

SET @paga_cesantia = ISNULL(@paga_cesantia, 0)
SET @paga_preaviso = ISNULL(@paga_preaviso, 0)
SET @dias_preaviso = ISNULL(@dias_preaviso, 0.00)

----------------------------------
--    aguinaldo proporcional    -- 
----------------------------------

EXECUTE cr.LIQ_AguinaldoProporcional @codemp, 
                                     @fecha_retiro,
                                     @codmon,
                                     @fecha_ingreso,
                                     @codtpl_aguinaldo,
                                     @codtig_aguinaldo,
                                     @codagr_aguinaldo

-------------------------------------------
-- vacaciones pendientes y proporcinales -- 
-------------------------------------------

EXECUTE cr.LIQ_VacacionesProporcional @codemp, 
									  @fecha_retiro,
									  @codmon,
									  @fecha_ingreso,
									  @codagr_vac,
									  @codtig_vac
----------------------------------
--        cesantía         -- 
----------------------------------

IF @paga_cesantia = 1 
BEGIN
	EXECUTE cr.LIQ_Cesantia @codemp, 
	                        @fecha_retiro, 
	                        @codmon,
                            @fecha_ingreso,
                            @codagr_cesantia,
                            @codtig_cesantia
END

----------------------------------
--        preaviso         -- 
----------------------------------

IF @paga_preaviso = 1 
BEGIN
	EXECUTE cr.LIQ_Preaviso @codemp, 
	                        @fecha_retiro, 
	                        @codmon,
                            @fecha_ingreso,
                            @codagr_preaviso,
                            @codtig_preaviso,
							@dias_preaviso
END

----------------------------------
--        Ahorro Escolar         -- 
----------------------------------

EXEC cr.LIQ_AhorroEscolar @codemp, 
	                      @fecha_retiro, 
	                      @codmon,
                          @fecha_ingreso,
                          @codagr_ahorro_escolar,
                          @codtig_ahorro_escolar

----------------------------------
--        Ahorro Patronal         -- 
----------------------------------

EXEC cr.LIQ_AhorroPatronal @codemp, 
	                       @fecha_retiro, 
	                       @codmon,
                           @fecha_ingreso,
                           @codtig_ahorro_escolar,
						   @codtrs_ahorro_patronal

----------------------------------------------------------------
-- obtiene la ultima fecha en que se pago salario al empleado -- 
----------------------------------------------------------------
SELECT @fecha_desde = MAX(ppl_fecha_fin)
FROM sal.inn_ingresos 
	JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON tpl_codigo = ppl_codtpl
WHERE ppl_estado = 'Autorizado'
	AND inn_codemp = @codemp
	AND inn_codtig IN (@codtig_salario)

-------------------------------------------------------------------------------
-- si aún no ha recibo pago, entonces se le pagará desde su fecha de ingreso --
-------------------------------------------------------------------------------
IF @fecha_desde IS NULL 
   SET @fecha_desde = @fecha_ingreso
ELSE
   SET @fecha_desde = DATEADD(DAY, 1, @fecha_desde)

----------------------------------
--        otros ingresos        -- 
----------------------------------

INSERT INTO #dli_detliq_ingresos ( dli_codtig,
                                   dli_valor,
                                   dli_codmon,
                                   dli_tiempo,
                                   dli_unidad_tiempo,
                                   dli_comentario, 
                                   dli_es_valor_fijo )
----------------------------------
--       ingresos ciclicos      -- 
----------------------------------
SELECT igc_codtig, 
	CASE 
		WHEN igc_accion_liquidacion = 'ProcesaSaldo' THEN igc_saldo
		WHEN igc_accion_liquidacion = 'ProcesaCuota' THEN igc_valor_cuota
	END igc_valor,
	igc_codmon,
	0,
	'Dias',
	'IGC-' + CONVERT(VARCHAR, igc_codigo),
	0
FROM sal.igc_ingresos_ciclicos
WHERE igc_estado = 'Autorizado'
	AND igc_activo = 1
	AND igc_accion_liquidacion <> 'Ninguna'
	AND igc_codemp = @codemp
	AND NOT EXISTS(SELECT NULL FROM #dli_detliq_ingresos WHERE dli_codtig = igc_codtig)
----------------------------------
--         otros ingresos       -- 
----------------------------------
UNION ALL
SELECT oin_codtig,
	ISNULL(ROUND(oin_valor_a_pagar, 2), 0), 
	oin_codmon,
	ISNULL(ROUND(ISNULL(oin_num_horas, 0) / 8, 1), 0), 
	'Dias',
	'OIN-' + CONVERT(VARCHAR, oin_codigo),
	0
FROM sal.oin_otros_ingresos 
	JOIN sal.ppl_periodos_planilla ON oin_codppl = ppl_codigo
WHERE oin_codemp = @codemp
	AND oin_estado = 'Autorizado'
	AND @fecha_retiro BETWEEN @fecha_desde AND ppl_fecha_fin
	AND NOT EXISTS(SELECT NULL FROM #dli_detliq_ingresos WHERE dli_codtig = oin_codtig)
----------------------------------
--         extraordinario       -- 
----------------------------------
UNION ALL
SELECT the_codtig,
	SUM(ROUND(ISNULL(ext_valor_a_pagar,0), 2)), 
	ext_codmon,
	SUM(ROUND(ISNULL(ext_num_horas,0), 2)), 
	'Horas',
	'Extraordinario Pendiente',
	0
FROM sal.ext_horas_extras
	JOIN sal.the_tipos_hora_extra ON the_codigo = ext_codthe
	JOIN sal.ppl_periodos_planilla ON ext_codppl = ppl_codigo
WHERE ext_codemp = @codemp
	AND ext_estado = 'Autorizado'
	AND ext_aplicado_planilla = 0
	AND @fecha_retiro BETWEEN @fecha_desde AND ppl_fecha_fin
	AND NOT EXISTS(SELECT NULL FROM #dli_detliq_ingresos WHERE dli_codtig = the_codtig)
GROUP BY the_codtig, ext_codmon

RETURN
