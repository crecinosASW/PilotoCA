/*Obtiene el monto embargable del empleado basándose en los ingresos percibidos en el período de planilla anterior*/
--EXEC cr_rpe_calculo_embargo 1, 3, 20120702, 7
ALTER PROCEDURE cr_rpe_calculo_embargo (
	@codcia INT,
	@codtpl INT,
	@codpla INT,
	@codemp INT = NULL
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY

--DECLARE @codcia INT,
--	@codtpl INT,
--	@codpla INT,
--	@codemp INT
	
--SET @codcia = 1
--SET	@codtpl = 1
--SET	@codpla = 20120302
--SET	@codemp = 6
	
--Definición de Variables	
DECLARE @codpla_anterior INT,
	@codpai INT,
	@codigo_empleado INT,
	@cia_descripcion VARCHAR(50),
	@emp_nombres_apellidos VARCHAR(80),
	@tpl_descripcion VARCHAR(20),
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@ppl_fecha_ini_anterior DATETIME,
	@ppl_fecha_fin_anterior DATETIME,
	@salario_bruto MONEY,
	@seguro_social MONEY,
	@isr MONEY,
	@salario_liquido MONEY,
	@pension_alimenticia MONEY,
	@salario_liquido_menos_pension MONEY,
	@salario_inembargable MONEY,
	@salario_embargable MONEY,
	@embargo_maximo MONEY,
	@pct_embargo_menor REAL,
	@pct_embargo_mayor REAL,
	@no_salarios_minimos REAL,
	@pre_base_pension MONEY,	
	@pre_valor_cuota MONEY,
	@pre_porcentaje REAL,
	@pre_monto MONEY,
	@pre_pagado MONEY,
	@pre_codtag INT,
	@pre_monto_indefinido VARCHAR(1),
	@codtag_salario_bruto INT,
	@codtag_seguro_social INT,
	@codtag_isr INT,
	@codtag_pension INT,
	@descripcion_pension VARCHAR(50)
	
DECLARE @error VARCHAR(400)

--Inicialización de variables	
SET @salario_bruto = 0.00
SET	@seguro_social = 0.00
SET	@isr = 0.00
SET	@salario_liquido = 0.00
SET	@pension_alimenticia = 0.00
SET	@salario_liquido_menos_pension = 0.00
SET	@salario_inembargable = 0.00
SET	@salario_embargable = 0.00
SET @embargo_maximo = 0.00
SET @pre_base_pension = 0.00
SET	@pre_valor_cuota = 0.00
SET	@pre_porcentaje = 0.00
SET	@pre_monto = 0.00
SET	@pre_pagado = 0.00
SET @pre_monto_indefinido = 'S'
SET @descripcion_pension = 'Pensión Alimenticia'

--Obtiene el código del país
SELECT @cia_descripcion = cia_des,
	@codpai = CIA_CODPAI
FROM SIDE_GEN_CIA
WHERE CIA_CODIGO = @codcia

--Obtiene el tipo de planilla y las fechas de inicio y fin de la planilla actual
SELECT @tpl_descripcion = TPL_DESCRIPCION,
	@ppl_fecha_ini = PPL_FECHA_INI,
	@ppl_fecha_fin = PPL_FECHA_FIN
FROM PLA_PPL_PARAM_PLANI
	INNER JOIN PLA_TPL_TIPO_PLANILLA ON PPL_CODCIA = TPL_CODCIA AND PPL_CODTPL = TPL_CODIGO
WHERE PPL_CODCIA = @codcia
	AND PPL_CODTPL = @codtpl
	AND PPL_CODPLA = @codpla	

--Obtienen el código de las familias de ingresos y descuentos correspondientes
SELECT TOP(1) @codtag_salario_bruto = tag_codigo
FROM SAL_TAG_TIPO_AGRUPADOR
WHERE tag_descripcion = 'CR - Rep. Cálculo de Embargo - Salario Bruto'
	AND tag_codpai = @codpai
	
SELECT TOP(1) @codtag_seguro_social = tag_codigo
FROM SAL_TAG_TIPO_AGRUPADOR
WHERE tag_descripcion = 'CR - Rep. Cálculo de Embargo - Seguro Social'
	AND tag_codpai = @codpai
	
SELECT TOP(1) @codtag_isr = tag_codigo
FROM SAL_TAG_TIPO_AGRUPADOR
WHERE tag_descripcion = 'CR - Rep. Cálculo de Embargo - ISR'
	AND tag_codpai = @codpai

SELECT TOP(1) @codtag_pension = tag_codigo
FROM SAL_TAG_TIPO_AGRUPADOR
WHERE tag_descripcion = 'CR - Rep. Cálculo de Embargo - Pensión Alimenticia'
	AND tag_codpai = @codpai		

--Obtiene el código de la planilla anterior autorizada
SELECT @codpla_anterior = PPL_CODPLA
FROM PLA_PPL_PARAM_PLANI
WHERE PPL_CODCIA = @codcia
	AND PPL_CODTPL = @codtpl
	AND PPL_FRECUENCIA = (CASE WHEN PPL_CODTPL = 1 THEN 2 ELSE PPL_FRECUENCIA END)
	AND PPL_FECHA_PAGO < (SELECT PPL_FECHA_PAGO
  						  FROM PLA_PPL_PARAM_PLANI
						  WHERE PPL_CODCIA = @codcia
							  AND PPL_CODTPL = @codtpl
							  AND PPL_CODPLA = @codpla)
ORDER BY PPL_FECHA_PAGO ASC	  

--Crea una tabla temporal para almacenar los datos
CREATE TABLE #tmp_info_embargo (
	tie_codcia INT,
	tie_cia_descripcion VARCHAR(50),
	tie_codtpl INT,
	tie_tpl_descripcion VARCHAR(20),
	tie_codpla INT,
	tie_ppl_fecha_ini DATETIME,
	tie_ppl_fecha_fin DATETIME,
	tie_codpla_anterior INT,
	tie_ppl_fecha_ini_anterior DATETIME,
	tie_ppl_fecha_fin_anterior DATETIME,	
	tie_codemp INT,
	tie_emp_nombres_apellidos VARCHAR(80),
	tie_salario_bruto MONEY,
	tie_seguro_social MONEY,
	tie_isr MONEY,
	tie_salario_liquido MONEY,
	tie_pension_alimenticia MONEY,
	tie_salario_liquido_menos_pension MONEY,
	tie_salario_inembargable MONEY,
	tie_salario_embargable MONEY,
	tie_embargo_maximo MONEY
)

IF @codpla_anterior IS NOT NULL
BEGIN	
	--Obtiene el tipo de planilla y las fechas de inicio y fin de la planilla anterior
	SELECT @ppl_fecha_ini_anterior = PPL_FECHA_INI,
		@ppl_fecha_fin_anterior = PPL_FECHA_FIN
	FROM PLA_PPL_PARAM_PLANI
		INNER JOIN PLA_TPL_TIPO_PLANILLA ON PPL_CODCIA = TPL_CODCIA AND PPL_CODTPL = TPL_CODIGO
	WHERE PPL_CODCIA = @codcia
		AND PPL_CODTPL = @codtpl
		AND PPL_CODPLA = @codpla_anterior	
					  
	DECLARE c_empleados CURSOR FOR
	SELECT DISTINCT INN_CODEMP, EMP_NOMBRES_APELLIDOS
	FROM PLA_INN_INGRESOS
		INNER JOIN PLA_EMP_EMPLEADO ON INN_CODCIA = EMP_CODCIA AND INN_CODEMP = EMP_CODIGO
	WHERE INN_CODCIA = @codcia
		AND INN_CODTPL = @codtpl
		AND INN_CODPLA = @codpla_anterior
		AND INN_VALOR > 0
		AND INN_CODEMP = ISNULL(@codemp, INN_CODEMP)	
		
	OPEN c_empleados
	
	FETCH NEXT FROM c_empleados INTO @codigo_empleado, @emp_nombres_apellidos
	
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		--Salario Bruto
		SELECT @salario_bruto = ISNULL(SUM(ISNULL(inn_valor, 0.00)), 0.00)
		FROM PLA_INN_INGRESOS
			INNER JOIN PLA_PPL_PARAM_PLANI ON INN_CODCIA = PPL_CODCIA AND INN_CODTPL = PPL_CODTPL AND INN_CODPLA = PPL_CODPLA
		WHERE INN_CODCIA = @codcia
			AND INN_CODTPL = @codtpl
			AND INN_CODPLA = @codpla_anterior
			AND INN_CODEMP = @codigo_empleado
			AND INN_CODTIG IN (SELECT dag_cod_tig_tdc 
							  FROM SAL_TAG_TIPO_AGRUPADOR
								  INNER JOIN SAL_DAG_DETALLE_AGRUPADORES ON tag_codigo = dag_codtag
							  WHERE tag_codpai = @codpai
								  AND tag_tipo = 'R'
								  AND dag_tipo = 'I'
								  AND dag_codtag = @codtag_salario_bruto)
								  							  							  
		--Seguro Social
		SELECT @seguro_social = ISNULL(SUM(ISNULL(DSS_VALOR, 0.00)), 0.00)
		FROM PLA_DSS_DESCUENTOS
			INNER JOIN PLA_PPL_PARAM_PLANI ON DSS_CODCIA = PPL_CODCIA AND DSS_CODTPL = PPL_CODTPL AND DSS_CODPLA = PPL_CODPLA
		WHERE DSS_CODCIA = @codcia
			AND DSS_CODTPL = @codtpl
			AND DSS_CODPLA = @codpla_anterior
			AND DSS_CODEMP = @codigo_empleado
			AND DSS_CODTDC IN (SELECT dag_cod_tig_tdc 
							  FROM SAL_TAG_TIPO_AGRUPADOR
								  INNER JOIN SAL_DAG_DETALLE_AGRUPADORES ON tag_codigo = dag_codtag
							  WHERE tag_codpai = @codpai
								  AND tag_tipo = 'R'
								  AND dag_tipo = 'D'
								  AND dag_codtag = @codtag_seguro_social)							  
								  							  
		--ISR
		SELECT @isr = ISNULL(SUM(ISNULL(DSS_VALOR, 0.00)), 0.00)
		FROM PLA_DSS_DESCUENTOS
			INNER JOIN PLA_PPL_PARAM_PLANI ON DSS_CODCIA = PPL_CODCIA AND DSS_CODTPL = PPL_CODTPL AND DSS_CODPLA = PPL_CODPLA
		WHERE DSS_CODCIA = @codcia
			AND DSS_CODTPL = @codtpl
			AND DSS_CODPLA = @codpla_anterior
			AND DSS_CODEMP = @codigo_empleado			
			AND DSS_CODTDC IN (SELECT dag_cod_tig_tdc 
							  FROM SAL_TAG_TIPO_AGRUPADOR
								  INNER JOIN SAL_DAG_DETALLE_AGRUPADORES ON tag_codigo = dag_codtag
							  WHERE tag_codpai = @codpai
								  AND tag_tipo = 'R'
								  AND dag_tipo = 'D'
								  AND dag_codtag = @codtag_isr)
		
		--Pensión Alimenticia						  
		SELECT @pension_alimenticia = ISNULL(SUM(ISNULL(DSS_VALOR, 0.00)), 0.00)
		FROM PLA_DSS_DESCUENTOS
			INNER JOIN PLA_PPL_PARAM_PLANI ON DSS_CODCIA = PPL_CODCIA AND DSS_CODTPL = PPL_CODTPL AND DSS_CODPLA = PPL_CODPLA
		WHERE DSS_CODCIA = @codcia
			AND DSS_CODTPL = @codtpl
			AND DSS_CODPLA = @codpla_anterior
			AND DSS_CODEMP = @codigo_empleado			
			AND DSS_CODTDC IN (SELECT dag_cod_tig_tdc 
							  FROM SAL_TAG_TIPO_AGRUPADOR
								  INNER JOIN SAL_DAG_DETALLE_AGRUPADORES ON tag_codigo = dag_codtag
							  WHERE tag_codpai = @codpai
								  AND tag_tipo = 'R'
								  AND dag_tipo = 'D'
								  AND dag_codtag = @codtag_pension)			
		
		--Salario Líquido
		SET @salario_liquido = @salario_bruto - @seguro_social - @isr
		
		--Salario Líquido menos Pensión Alimenticia
		SET @salario_liquido_menos_pension = @salario_liquido - @pension_alimenticia
		
		--Salario Inembargable
		SELECT @salario_inembargable = ISNULL(pge_salario_inembargable, 0.00),
			@pct_embargo_menor = ISNULL(pge_pct_embargo_menor, 0.00),
			@pct_embargo_mayor = ISNULL(pge_pct_embargo_mayor, 0.00),
			@no_salarios_minimos = ISNULL(pge_salarios_minimos, 0.00)
		FROM PLA_PGE_PARAMETROS_GEN
		WHERE PGE_CODCIA = @codcia
		
		--Salario Embargable
		SET @salario_embargable = @salario_liquido_menos_pension - @salario_inembargable
		
		IF @salario_embargable < 0
			SET @salario_embargable = 0.00
		
		--Suma Máxima Sujeta a Embargo
		IF (@salario_bruto >= 0 AND @salario_bruto < @salario_inembargable * @no_salarios_minimos)
			SET @embargo_maximo = @salario_embargable * @pct_embargo_menor / 100.00
		ELSE IF (@salario_bruto > @salario_inembargable * @no_salarios_minimos)
			SET @embargo_maximo = @salario_embargable * @pct_embargo_mayor / 100.00			
		ELSE 
			SET @embargo_maximo = 0.00
			
		INSERT INTO #tmp_info_embargo(tie_codcia, tie_cia_descripcion, tie_codtpl, tie_tpl_descripcion, tie_codpla, 
			tie_ppl_fecha_ini, tie_ppl_fecha_fin, tie_codpla_anterior, tie_ppl_fecha_ini_anterior, tie_ppl_fecha_fin_anterior,
			tie_codemp, tie_emp_nombres_apellidos, tie_salario_bruto, tie_seguro_social, tie_isr, tie_salario_liquido,
			tie_pension_alimenticia, tie_salario_liquido_menos_pension, tie_salario_inembargable, tie_salario_embargable, tie_embargo_maximo)
		VALUES (@codcia, @cia_descripcion, @codtpl, @tpl_descripcion, @codpla,
			@ppl_fecha_ini, @ppl_fecha_fin, @codpla_anterior, @ppl_fecha_ini_anterior, @ppl_fecha_fin_anterior, 
			@codigo_empleado, @emp_nombres_apellidos, @salario_bruto, @seguro_social, @isr, @salario_liquido,
			@pension_alimenticia, @salario_liquido_menos_pension, @salario_inembargable, @salario_embargable, @embargo_maximo)
		
		FETCH NEXT FROM c_empleados INTO @codigo_empleado, @emp_nombres_apellidos
	END
	
	CLOSE c_empleados
	DEALLOCATE c_empleados
END
ELSE
BEGIN
	SET @error = 'No existe una planilla autorizada menor a la planilla código: ' + CONVERT(VARCHAR, @codpla)
	RAISERROR(@error, 16, 0)
END 						

SELECT * FROM #tmp_info_embargo	
DROP TABLE #tmp_info_embargo	  




	
