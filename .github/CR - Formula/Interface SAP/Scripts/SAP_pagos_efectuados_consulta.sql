IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gt.SAP_pagos_efectuados_consulta'))
BEGIN
	DROP PROCEDURE gt.SAP_pagos_efectuados_consulta
END

GO

create procedure gt.SAP_pagos_efectuados_consulta
(	@codppl int
)

AS

--declare @codppl int

--set	@codppl = 25

DECLARE	@servidor_SAP varchar(20),
	@base_SAP varchar(150),
	@codfpa INT,
	@xSql varchar(8000),
	@codcia int,
	@cuentacontapagocheques varchar(25)

--SELECT @servidor_SAP = pge_servidor_sap
--FROM PLA_PGE_PARAMETROS_GEN
--WHERE PGE_CODCIA = @codcia

select @codcia = tpl_codcia
from sal.ppl_periodos_planilla join sal.tpl_tipo_planilla on
	ppl_codtpl = tpl_codigo
where ppl_codigo = @codppl

SET @base_SAP = '[35_PANACEA_FINAL]'
--SELECT @base_SAP = '[' + ltrim(rtrim(SAP_database)) + ']'
--FROM SAP_Initial_Catalog

SET @codfpa = 3 --ISNULL(gen.get_valor_parametro_int('CodigoFpa_Transferencia', @codpai, NULL, NULL, NULL), 0)

set @cuentacontapagocheques = gen.get_valor_parametro_varchar('CuentaContaPagoCheques', null, null, @codcia, NULL)

SET @codppl = ISNULL(@codppl, 0)

set @xSql = 'SELECT CONVERT(VARCHAR, ppl_codigo) codpla, 
	emp_codigo codemp, 

	exp_nombres_apellidos nombre, 

	((SELECT ISNULL(SUM(inn_valor),0) 	
	  FROM sal.inn_ingresos 	
	  WHERE inn_codppl = ppl_codigo 	
		  AND inn_codemp = emp_codigo) - 	
	 (SELECT ISNULL(SUM(dss_valor), 0) 	
	  FROM sal.dss_descuentos 	
	  WHERE dss_codppl = ppl_codigo	
		  AND dss_codemp = emp_codigo)) monto_pago, 

	(SELECT acctcode 
	 FROM ' + @base_SAP + '.dbo.oact 
	 WHERE formatcode = + '''' + REPLACE(' + @cuentacontapagocheques + ', ''-'', '''') + ''''
	 COLLATE sql_latin1_general_cp1_ci_AS ) codigo_cuenta_sap, 

	(SELECT acctNAME
	 FROM ' + @base_SAP + '.dbo.oact 
	 WHERE formatcode = + '''' + REPLACE(' + @cuentacontapagocheques + ', ''-'', '''') + ''''
	 COLLATE sql_latin1_general_cp1_ci_AS ) nombre_cuenta_sap, 
	
	''Pago '' + 
	tpl_descripcion + '' '' +
	CASE WHEN ppl_frecuencia = 1 THEN ''1ra ''	
	     WHEN ppl_frecuencia = 2 THEN ''2da ''	
	     WHEN ppl_frecuencia = 3 THEN ''3ra ''	
	     WHEN ppl_frecuencia = 4 THEN ''4ta ''	
	     WHEN ppl_frecuencia = 5 THEN ''5ta ''	
		 ELSE '''' 
	END + 
	gen.fn_crufl_NombreMes(ppl_mes) +
	CONVERT(VARCHAR, ppl_anio) descripcion, 

	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN NULL 
		 ELSE GETDATE() 
	END fecha
FROM sal.hpa_hist_periodos_planilla JOIN exp.emp_empleos ON 
		hpa_codemp = emp_codigo
	JOIN exp.exp_expedientes ON 
		emp_codexp = exp_codigo
	JOIN sal.ppl_periodos_planilla ON 
		hpa_codppl = ppl_codigo
	JOIN eor.plz_plazas ON 
		hpa_codplz = plz_codigo
	JOIN eor.cia_companias ON 
		plz_codcia = cia_codigo
	LEFT JOIN exp.fpe_formas_pago_empleo ON 
		emp_codigo = fpe_codemp
	join sal.tpl_tipo_planilla on
		ppl_codtpl = tpl_codigo
WHERE hpa_codppl = ' + CONVERT(VARCHAR, @codppl) + '
	and fpe_codfpa = 2
	--AND NOT EXISTS (SELECT 1
	--			    FROM sap_cpe_control_pagos_efectuados
	--			    WHERE cpe_codcia = cia_codigo
	--					AND cpe_codtpl = ppl_codtpl
	--					AND cpe_codpla = hpa_codppl
	--					AND cpe_codemp = hpa_codemp) 
	AND ((SELECT ISNULL(SUM(inn_valor), 0.00)
		  FROM sal.inn_ingresos
		  WHERE inn_codppl = hpa_codppl
			 AND inn_codemp = hpa_codemp) -
		 (SELECT ISNULL(SUM(dss_valor), 0.00)
		  FROM sal.dss_descuentos
		  WHERE dss_codppl = hpa_codppl
			 AND dss_codemp = hpa_codemp)) > 0.00
ORDER BY hpa_codemp'

EXEC (@xSql)