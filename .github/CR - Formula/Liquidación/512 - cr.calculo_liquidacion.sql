IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.calculo_liquidacion'))
BEGIN
	DROP PROCEDURE cr.calculo_liquidacion
END

GO

--------------------------------------------------------------------------------------
-- Evolution STANDARD - Liquidacion                                                 --
-- Procedimiento principal del calculo de liquidacion                               --
--------------------------------------------------------------------------------------
/*
exec cr.calculo_liquidacion 1859, '20150306', 1, 
'<DocumentElement>
  <MotivosRetiro>
	<mrt_cesantia>true</mrt_cesantia>
	<mrt_preaviso>true</mrt_preaviso>
	<mrt_dias_preaviso>0.00</mrt_dias_preaviso>
  </MotivosRetiro>
</DocumentElement>'
*/
CREATE PROCEDURE cr.calculo_liquidacion (
	@codemp INT,				-- codigo de empleado a liquidar.
	@fecha_retiro DATETIME,     -- fecha de retiro.
	@codmrt INT,			    -- codigo del motivo de retiro.
	@parametros xml				-- parametros de calculo (heredado del motivo de retiro)
)

AS

BEGIN

DECLARE @paga_cesantia		  BIT,
	@paga_preaviso		  BIT,
	@dias_preaviso		  REAL,
	@codcia               INT,
	@codpai               VARCHAR(2),
	@codmon               VARCHAR(3),
	@fecha_ingreso        DATETIME,
	@codrsa_salario       INT,
	@codtig_salario       INT,
	@codtig_aguinaldo     INT,
	@codtig_vac           INT,
	@codtig_cesantia      INT,
	@codtig_preaviso	  INT,
	@codtig_ahorro_escolar INT,
	@codtig_ahorro_patronal INT,
	@codtdc_asociacion INT,
	@codtrs_ahorro_patronal INT,
	@codtrs_asociacion INT,
	@codtpl_salario       INT,
	@codtpl_aguinaldo     INT,
	@codagr_cesantia      INT,
	@codagr_vac           INT,
	@codagr_aguinaldo     INT,
	@codagr_preaviso	  INT,
	@codagr_ahorro_escolar INT,
	@salario_actual       REAL

------------------------------------
--        inicializacion          --	
------------------------------------
SET @paga_cesantia = CASE WHEN gen.get_pb_field_data(@parametros, 'mrt_cesantia') = 'True' THEN 1 ELSE 0 END
SET @paga_preaviso = CASE WHEN gen.get_pb_field_data(@parametros, 'mrt_preaviso') = 'True' THEN 1 ELSE 0 END
SET @dias_preaviso = gen.get_pb_field_data_float(@parametros, 'mrt_dias_preaviso')

------------------------------------
--  llena todos los parametros    --
--        necesarios              --
------------------------------------
SELECT @codpai = cia_codpai, 
	@codcia = plz_codcia,
	@fecha_ingreso = emp_fecha_ingreso,
	@codtpl_salario = emp_codtpl,
	@codtpl_aguinaldo = gen.get_pb_field_data_int(tpl_property_bag_data, 'tpl_codtpl_aguinaldo')
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
	JOIN eor.cia_companias ON cia_codigo = plz_codcia
	JOIN sal.tpl_tipo_planilla ON emp_codtpl = tpl_codigo
WHERE emp_codigo = @codemp

SET @codrsa_salario = ISNULL(gen.get_valor_parametro_int('CodigoRSA_Salario', NULL, NULL, @codcia, NULL), 0)

SELECT @codtig_salario =  ese_codtig 
FROM exp.rsa_rubros_salariales 
	JOIN exp.ese_estructura_sal_empleos ON ese_codrsa = rsa_codigo 
WHERE rsa_codcia = @codcia 
	AND ese_codemp = @codemp 
	AND rsa_codigo = @codrsa_salario
    
SELECT @salario_actual = ese_valor,
	@codmon = ese_codmon
FROM exp.ese_estructura_sal_empleos 
	JOIN exp.rsa_rubros_salariales ON	rsa_codigo = ese_codrsa
	JOIN (
		SELECT ese_codemp codemp, MAX(ese_codigo) MAX_codigo
		FROM exp.ese_estructura_sal_empleos
		WHERE ese_estado = 'V'
			AND ese_codrsa = @codrsa_salario
			AND ese_fecha_inicio <= @fecha_retiro
			AND ISNULL(ese_fecha_fin, @fecha_retiro + 1) >= @fecha_retiro
		GROUP BY ese_codemp) m ON ese_codigo = MAX_codigo
WHERE ese_codemp = @codemp
	AND ese_codrsa = @codrsa_salario

SET @codtig_aguinaldo = ISNULL(gen.get_valor_parametro_INT ('CodigoTIG_Aguinaldo',NULL,NULL,@codcia,NULL), 0)
SET @codtig_vac = ISNULL(gen.get_valor_parametro_INT ('CodigoTIG_VacacionesNoAfectas',NULL,NULL,@codcia,NULL), 0)
SET @codtig_cesantia = ISNULL(gen.get_valor_parametro_INT ('CodigoTIG_Cesantia',NULL,NULL,@codcia,NULL), 0)
SET @codtig_preaviso = ISNULL(gen.get_valor_parametro_INT ('CodigoTIG_Preaviso',NULL,NULL,@codcia,NULL), 0)
SET @codtig_ahorro_escolar = ISNULL(gen.get_valor_parametro_INT ('CodigoTIG_AhorroEscolar',NULL,NULL,@codcia,NULL), 0)
SET @codtig_ahorro_patronal = ISNULL(gen.get_valor_parametro_INT ('CodigoTIG_AhorroPatronal',NULL,NULL,@codcia,NULL), 0)
SET @codtdc_asociacion = ISNULL(gen.get_valor_parametro_INT ('CodigoTDC_Asociacion',NULL,NULL,@codcia,NULL), 0)
SET @codtrs_ahorro_patronal = ISNULL(gen.get_valor_parametro_INT ('CodigoTRS_AhorroPatronal',NULL,NULL,@codcia,NULL), 0)
SET @codtrs_asociacion = ISNULL(gen.get_valor_parametro_INT ('CodigoTRS_Asociacion',NULL,NULL,@codcia,NULL), 0)

SELECT @codagr_cesantia = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoCesantia'

SELECT @codagr_preaviso = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoPreaviso'

SELECT @codagr_vac  = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoVacaciones'

SELECT @codagr_aguinaldo  = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoAguinaldo'

SELECT @codagr_ahorro_escolar  = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoAhorroEscolar'
   
------------------------------------
--       calcula ingresos         --	
------------------------------------	

EXECUTE cr.LIQ_Ingresos @codemp, 
	                    @fecha_retiro, 
	                    @paga_cesantia, 
	                    @paga_preaviso,
						@dias_preaviso,
                        @codmon,
                        @fecha_ingreso,
                        @codtig_salario,
                        @codtig_aguinaldo,
                        @codtig_vac,
                        @codtig_cesantia,
						@codtig_preaviso,
						@codtig_ahorro_escolar,
						@codtig_ahorro_patronal,
						@codtrs_ahorro_patronal,
                        @codtpl_salario,
                        @codtpl_aguinaldo,
                        @codagr_cesantia,
                        @codagr_vac,
                        @codagr_aguinaldo,
                        @codagr_preaviso,
						@codagr_ahorro_escolar,
                        @salario_actual

------------------------------------
--        calcula descuentos      --	
------------------------------------		

EXECUTE cr.Liq_Descuentos @codemp, 
	                      @fecha_retiro,
	                      @codmon,
                          @fecha_ingreso,
						  @codtdc_asociacion,
						  @codtrs_asociacion
END
