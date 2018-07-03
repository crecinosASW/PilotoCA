IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_Inicializacion_Aguinaldo'))
BEGIN
	DROP PROCEDURE cr.GenPla_Inicializacion_Aguinaldo
END

GO

--EXEC cr.GenPla_Inicializacion_Aguinaldo NULL, 68, 'admin'
CREATE PROCEDURE cr.GenPla_Inicializacion_Aguinaldo (
	@sessionId UNIQUEIDENTIFIER = null,
    @codppl INT,
    @userName VARCHAR(100) = null
)

AS

DECLARE @codtpl INT

SELECT @codtpl = ppl_codtpl
FROM sal.ppl_periodos_planilla
WHERE ppl_codigo = @codppl  

SET @username = ISNULL(@username, SYSTEM_USER)
 
SET NOCOUNT ON
BEGIN TRANSACTION

	-- ingresos
	DELETE 
	FROM sal.inn_ingresos
	WHERE inn_codppl = @codppl
		AND (sal.empleado_en_gen_planilla(@sessionId, inn_codemp) = 1 
			OR inn_codemp IN (SELECT emp_codigo 
							  FROM exp.emp_empleos
							  WHERE emp_estado = 'R' 
								  OR emp_codtpl <> @codtpl))

	-- descuentos
	DELETE 
	FROM sal.dss_descuentos
	WHERE dss_codppl = @codppl
		AND (sal.empleado_en_gen_planilla(@sessionid, dss_codemp) = 1
			OR dss_codemp IN (SELECT emp_codigo 
							  FROM exp.emp_empleos
							  WHERE emp_estado = 'R' 
								  OR emp_codtpl <> @codtpl))

    -- HISTÓRICO DE CENTROS DE COSTO
	DELETE
	FROM sal.hco_hist_cco_periodos_planilla
	WHERE hco_codhpa IN (SELECT hpa_codigo
						 FROM sal.hpa_hist_periodos_planilla 
						 WHERE sal.empleado_en_gen_planilla(@sessionId, hpa_codemp) = 1 
							 AND hpa_codppl = @codppl)

	-- historico de planillas calculadas
	DELETE 
	FROM sal.hpa_hist_periodos_planilla
	WHERE hpa_codppl = @codppl
		AND (sal.empleado_en_gen_planilla(@sessionid, hpa_codemp) = 1
					OR hpa_codemp IN (SELECT emp_codigo 
									  FROM exp.emp_empleos
									  WHERE emp_estado = 'R' 
										  OR emp_codtpl <> @codtpl))


	-- Cuotas de descuentos cíclicos
	DELETE 
	FROM sal.cdc_cuotas_descuento_ciclico
	WHERE cdc_codppl = @codppl
		AND EXISTS (SELECT NULL 
					FROM sal.dcc_descuentos_ciclicos 
					WHERE dcc_codigo = cdc_coddcc 
						AND (sal.empleado_en_gen_planilla(@sessionId, dcc_codemp) = 1
							OR dcc_codemp IN (SELECT emp_codigo 
											  FROM exp.emp_empleos
											  WHERE emp_estado = 'R' 
												  OR emp_codtpl <> @codtpl)))

	--Coloca las transacciones como no procesadas     
    UPDATE sal.oin_otros_ingresos
    SET oin_aplicado_planilla=0
    WHERE oin_estado = 'Autorizado'
		AND oin_ignorar_en_planilla = 0
		AND sal.empleado_en_gen_planilla(@sessionId, oin_codemp) = 1
      
    UPDATE sal.ods_otros_descuentos
    SET ods_aplicado_planilla=0
    WHERE ods_estado = 'Autorizado' 
		AND ods_ignorar_en_planilla = 0
        AND ods_codppl = @codppl
        AND sal.empleado_en_gen_planilla(@sessionId, ods_codemp) = 1

    UPDATE sal.cdc_cuotas_descuento_ciclico
    SET cdc_aplicado_planilla = 0
    WHERE cdc_codppl = @codppl
       AND cdc_planilla_autorizada = 0
       AND EXISTS (SELECT NULL
                   FROM sal.dcc_descuentos_ciclicos 
                   WHERE cdc_coddcc = dcc_codigo
					   AND sal.empleado_en_gen_planilla(@sessionId, dcc_codemp) = 1)
                      
	UPDATE sal.cec_cuotas_extras_desc_ciclico
	SET cec_aplicado_planilla = 0
	WHERE cec_codppl = @codppl
		AND cec_planilla_autorizada = 0
		AND EXISTS (SELECT NULL
					FROM sal.dcc_descuentos_ciclicos
					WHERE dcc_codigo = cec_coddcc
						AND sal.empleado_en_gen_planilla(@sessionId, dcc_codemp) = 1)

	-- Delete de temporales por cancelaciones de generacion de planillas

	-- INGRESOS
	DELETE 
	FROM tmp.inn_ingresos
	WHERE inn_codppl = @codppl
		AND sal.empleado_en_gen_planilla(@sessionId, inn_codemp) = 1
			
	---- DESCUENTOS
	DELETE
	FROM tmp.dss_descuentos
	WHERE dss_codppl = @codppl
		AND sal.empleado_en_gen_planilla(@sessionId, dss_codemp) = 1

	IF ISNULL(gen.get_valor_parametro_bit('AguinaldoAplicaPension', 'cr', NULL, NULL, NULL), 0) = 1
		EXECUTE cr.GenPla_DCC_Cuotas_Pension @sessionId, @codppl, @userName

	EXECUTE cr.GenPla_Planilla_Aguinaldo @sessionid, @codppl, @username

	-- Actualizacion del periodo a Generado  
	UPDATE sal.ppl_periodos_planilla
	SET ppl_estado = 'Generado'
	WHERE ppl_codigo = @codppl

COMMIT TRANSACTION

RETURN
