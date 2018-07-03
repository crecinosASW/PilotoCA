IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_Calcula_Embargos'))
BEGIN
	DROP PROCEDURE cr.GenPla_Calcula_Embargos
END

GO

CREATE PROCEDURE cr.GenPla_Calcula_Embargos (	
	@sessionId UNIQUEIDENTIFIER = NULL,
	@codppl INT,
	@userName VARCHAR(100) = NULL
) 

AS

DELETE sal.emb_embargos
WHERE EXISTS (SELECT NULL
			  FROM sal.dcc_descuentos_ciclicos 
				  JOIN sal.cdc_cuotas_descuento_ciclico on dcc_codigo = cdc_coddcc
			  WHERE emb_codcdc = cdc_codigo
				  AND cdc_codppl = @codppl
				  AND cdc_planilla_autorizada = 0)

-- declaracion de variables locales 
DECLARE @codpai VARCHAR(2),
	@codtpl INT, 
	@codemp INT, 
	@coddcc INT, 
	@codcdc INT,
	@proxima_cuota INT, 
	@fecha_pago DATETIME, 
	@frecuencia INT,
	@codtdc INT,
	@emb_porcentaje_menor REAL,
	@emb_porcentaje_mayor REAL,
	@emb_salarios_minimos REAL,
	@emb_salario_inembargable MONEY

-- Obtiene la fecha de finalizacion y la frecuencia del periodo de planilla que va a utilizar 
SELECT @codpai = cia_codpai,
	@codtpl = tpl_codigo,
	@fecha_pago = ppl_fecha_fin, 
	@frecuencia = ppl_frecuencia
FROM sal.ppl_periodos_planilla 
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE ppl_codigo = @codppl

SET @emb_salario_inembargable = gen.get_valor_parametro_money('EmbargosSalarioInembargable', @codpai, NULL, NULL, NULL)
SET @emb_porcentaje_menor = gen.get_valor_parametro_float('EmbargosPorcentajeMenores', @codpai, NULL, NULL, NULL)
SET @emb_porcentaje_mayor = gen.get_valor_parametro_float('EmbargosPorcentajeMayores', @codpai, NULL, NULL, NULL)
SET @emb_salarios_minimos = gen.get_valor_parametro_float('EmbargosNumeroSalariosMinimos', @codpai, NULL, NULL, NULL)

BEGIN TRANSACTION 

DECLARE embargos CURSOR FOR
SELECT dcc_codemp,
	dcc_codigo,
	dcc_codtdc,
	ISNULL((
		SELECT MAX(cdc_numero_cuota)
		FROM sal.cdc_cuotas_descuento_ciclico
		WHERE cdc_coddcc = dcc_codigo), 0) + 1 dcc_proxima_cuota
FROM sal.dcc_descuentos_ciclicos d1
	JOIN sal.tcc_tipos_descuento_ciclico ON dcc_codtcc = tcc_codigo
WHERE dcc_codtpl = @codtpl
	AND dcc_estado = 'Autorizado' 
	AND dcc_activo = 1
	AND dcc_fecha_inicio_descuento <= @fecha_pago
	AND (dcc_frecuencia_periodo_pla = @frecuencia OR dcc_frecuencia_periodo_pla = 0)
	AND ISNULL(dcc_monto, 0.00) - ISNULL(dcc_total_cobrado, 0.00) > 0.00
	AND dcc_monto_indefinido = 1
	AND ISNULL(gen.get_pb_field_data_bit(tcc_property_bag_data, 'EsEmbargo'), 0) = 1
	AND dcc_fecha_inicio_descuento = (SELECT MIN(dcc_fecha_inicio_descuento)
									  FROM sal.dcc_descuentos_ciclicos d2
										  JOIN sal.tcc_tipos_descuento_ciclico ON dcc_codtcc = tcc_codigo
									  WHERE dcc_codtpl = @codtpl
										  AND dcc_estado = 'Autorizado'
										  AND dcc_activo = 1
										  AND dcc_fecha_inicio_descuento <= @fecha_pago
								          AND (dcc_frecuencia_periodo_pla = @frecuencia OR dcc_frecuencia_periodo_pla = 0)
										  AND ISNULL(dcc_monto, 0.00) - ISNULL(dcc_total_cobrado, 0.00) > 0.00
										  AND ISNULL(gen.get_pb_field_data_bit(tcc_property_bag_data, 'EsEmbargo'), 0) = 1
										  AND d2.dcc_codemp = d1.dcc_codemp)
	AND sal.empleado_en_gen_planilla(@sessionId, dcc_codemp) = 1

OPEN embargos

FETCH NEXT FROM embargos INTO @codemp, @coddcc, @codtdc, @proxima_cuota

WHILE  @@FETCH_STATUS = 0
BEGIN 
	IF NOT EXISTS (SELECT NULL
				   FROM sal.cdc_cuotas_descuento_ciclico 
					   JOIN sal.dcc_descuentos_ciclicos ON cdc_coddcc = dcc_codigo
				   WHERE dcc_codemp = @codemp
					   AND dcc_codigo = @coddcc 
					   AND cdc_numero_cuota = @proxima_cuota)
	BEGIN
		INSERT INTO sal.cdc_cuotas_descuento_ciclico(
			cdc_coddcc, 
			cdc_numero_cuota, 
			cdc_codppl, 
			cdc_fecha_descuento, 
			cdc_valor_cobrado, 
			cdc_aplicado_planilla) 
		VALUES (@coddcc, 
			@proxima_cuota, 
			@codppl,
			@fecha_pago, 
			0.00, 
			0)
	END		
	
	SELECT @codcdc = cdc_codigo
	FROM sal.cdc_cuotas_descuento_ciclico 
		JOIN sal.dcc_descuentos_ciclicos ON cdc_coddcc = dcc_codigo
	WHERE dcc_codemp = @codemp
		AND dcc_codigo = @coddcc 
		AND cdc_numero_cuota = @proxima_cuota

	IF NOT EXISTS (SELECT NULL
				   FROM sal.emb_embargos
				   WHERE emb_codcdc = @codcdc)
	BEGIN
		INSERT INTO sal.emb_embargos (emb_codcdc,
			emb_porcentaje_menor,
			emb_porcentaje_mayor,
			emb_salarios_minimos,
			emb_salario_inembargable,
			emb_salario_nominal,
			emb_cargas_sociales,
			emb_salario_embargable,
			emb_valor)
		VALUES (@codcdc,
			@emb_porcentaje_menor,
			@emb_porcentaje_mayor,
			@emb_salarios_minimos,
			@emb_salario_inembargable,
			0.00,
			0.00,
			0.00,
			0.00)
	END

	FETCH NEXT FROM embargos INTO @codemp, @coddcc, @codtdc, @proxima_cuota

END 
CLOSE embargos 
DEALLOCATE embargos 

COMMIT TRANSACTION 