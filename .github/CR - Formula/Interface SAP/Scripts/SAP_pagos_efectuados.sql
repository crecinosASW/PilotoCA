IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gt.SAP_pagos_efectuados'))
BEGIN
	DROP PROCEDURE gt.SAP_pagos_efectuados
END

GO

create procedure gt.SAP_pagos_efectuados
(	@codppl int,
	@BankCode VARCHAR(30),
	@Branch VARCHAR(50) = NULL
)

AS

--declare @codppl VARCHAR(15),
--	@BankCode VARCHAR(30),
--	@Branch VARCHAR(50) = NULL

--set @codcia = 1
--set	@codtpl = 12
--set	@codppl = '201409CO01'
--set	@BankCode = 'BI'
--set	@Branch = NULL

DECLARE	@servidor_SAP varchar(20),
	@base_SAP varchar(150),
	@codfpa INT,
	@xSql varchar(8000)

--SELECT @servidor_SAP = pge_servidor_sap
--FROM PLA_PGE_PARAMETROS_GEN
--WHERE PGE_CODCIA = @codcia

SET @base_SAP = '[35_PANACEA_FINAL]'
--SELECT @base_SAP = '[' + ltrim(rtrim(SAP_database)) + ']'
--FROM SAP_Initial_Catalog

SET @codfpa = 3 --ISNULL(gen.get_valor_parametro_int('CodigoFpa_Transferencia', @codpai, NULL, NULL, NULL), 0)

SET @codppl = ISNULL(@codppl, 0)
SET @bankcode = ISNULL(@bankcode, '')
SET @branch = ISNULL(@branch, '')

set @xSql = 'SELECT cia_codigo codcia,
	ppl_codtpl codtpl,
	CONVERT(VARCHAR, ppl_codigo) codpla, 
	emp_codigo codemp, 

	(SELECT acctcode 
	 FROM ' + @base_SAP + '.dbo.oact 
	 WHERE formatcode = + '''' + REPLACE(pge_cta_debito, ''-'', '''') + ''''
	 COLLATE sql_latin1_general_cp1_ci_AS ) acctcode, 

	(SELECT acctNAME
	 FROM ' + @base_SAP + '.dbo.oact 
	 WHERE formatcode = + '''' + REPLACE(pge_cta_debito, ''-'', '''') + ''''
	 COLLATE sql_latin1_general_cp1_ci_AS ) accountname, 
	
	''Pago '' + 
	CASE WHEN ppl_frecuencia = 1 THEN ''1ra ''	
	     WHEN ppl_frecuencia = 2 THEN ''2da ''	
	     WHEN ppl_frecuencia = 3 THEN ''3ra ''	
	     WHEN ppl_frecuencia = 4 THEN ''4ta ''	
	     WHEN ppl_frecuencia = 5 THEN ''5ta ''	
		 ELSE '''' 
	END + 
	gen.fn_crufl_NombreMes(ppl_mes) +
	CONVERT(VARCHAR, ppl_anio) description, 
	((SELECT ISNULL(SUM(inn_valor),0) 	
	  FROM sal.inn_ingresos 	
	  WHERE inn_codppl = ppl_codigo 	
		  AND inn_codemp = emp_codigo) - 	
	 (SELECT ISNULL(SUM(dss_valor), 0) 	
	  FROM sal.dss_descuentos 	
	  WHERE dss_codppl = ppl_codigo	
		  AND dss_codemp = emp_codigo)) sumpaid, 
	0 applyvat, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN '''' ELSE ''' +'' + ISNULL(@bankcode,'''')  + ''  + ''' END bankcode, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN '''' ELSE ''' + ISNULL(@branch,'')  + ''' END branch, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN NULL ELSE 4 END billofexchangestatus, 

	(SELECT glaccount
	FROM ' + @base_SAP + '.dbo.dsc1
	WHERE bankcode = ''' + ISNULL(@bankcode,'''') + '''
		and account = (SELECT dfltacct 
					FROM ' + @base_SAP + '.dbo.odsc 
					WHERE bankcode = ''' + ISNULL(@bankcode,'')  + ''' )) cardcode,
	
	exp_nombres_apellidos cardname, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN '''' 
		 ELSE (SELECT dfltacct 
			   FROM ' + @base_SAP + '.dbo.odsc 
			   WHERE bankcode = ''' + ISNULL(@bankcode,'')  + ''' ) 
	END checkaccount, 
	(SELECT dfltacct 
		FROM ' + @base_SAP + '.dbo.odsc 
		WHERE bankcode = ''' + ISNULL(@bankcode,'')  + ''' ) accounttnum, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN 0 
		 ELSE ((SELECT ISNULL(SUM(inn_valor),0)
			   FROM sal.inn_ingresos
			   WHERE inn_codppl = ppl_codigo
				   AND inn_codemp = emp_codigo) - 					
			  (SELECT ISNULL(SUM(dss_valor),0) 					
			   FROM sal.dss_descuentos
			   WHERE dss_codppl = ppl_codigo
				   AND dss_codemp = emp_codigo )) 
	END chechksum, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN '''' 
		 ELSE (SELECT countrycod 
			   FROM ' + @base_SAP + '.dbo.odsc 
			   WHERE bankcode = ''' + ISNULL(@bankcode,'')  + ''') 
	END countrycode, 
	'''' details, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN NULL 
		 ELSE GETDATE() 
	END duedate, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN NULL 
		 ELSE 0 
	END trnsfrable, 
	0 contactpersonecode, 
	(SELECT nextchckno 
	 FROM ' + @base_SAP + '.dbo.odsc 
	 WHERE bankcode =''' + ISNULL(@bankcode,'')  + ''') counterreference, 
	''Q'' doccurrency, 
	GETDATE() docdate,
	1 docobjectcode, 
	0 docrate, 
	1 doctype, 
	1 doctypte, 
	(SELECT ISNULL(nextchckno,0) 
	 FROM ' + @base_SAP + '.dbo.odsc 
	 WHERE bankcode = ''' + ISNULL(@bankcode,'')  + ''') docnum, 
	0 handwritten, 
	0 ispaytobank, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN ''TRANSF-''
		 ELSE ''CHEQUE-''
	END + ''Pago '' + 
	CASE WHEN ppl_frecuencia = 1 THEN ''1ra ''
		 WHEN ppl_frecuencia = 2 THEN ''2da ''
		 WHEN ppl_frecuencia = 3 THEN ''3ra ''
		 WHEN ppl_frecuencia = 4 THEN ''4ta ''
		 WHEN ppl_frecuencia = 5 THEN ''5ta ''
		 ELSE '''' 
	END + 
	gen.fn_crufl_NombreMes(ppl_mes) + 
	CONVERT(VARCHAR, ppl_anio) journalremarks, 
	0 localcurrency, 
	5 paymentpriority, 
	0 proforma, 
	'''' projectcode, 
	''Evol'' reference2, 
	''@codcia = '' + CONVERT(VARCHAR, plz_codcia) + '', @codtpl = '' + CONVERT(VARCHAR, ppl_codtpl) + '', @codppl = '' + CONVERT(VARCHAR, ppl_codigo) + '', @codemp = '' + CONVERT(VARCHAR, emp_codigo) remarks, 
	pge_serie_pagos_e series,
	GETDATE() taxdate, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' 
		 THEN (SELECT acctcode 
			   FROM ' + @base_SAP + '.dbo.oact 
			   WHERE formatcode = REPLACE(pge_cta_transfer,''-'','''') 
			   COLLATE sql_latin1_general_cp1_ci_AS ) 
	     ELSE  ''''
	END transferaccount, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' THEN GETDATE() 
		 ELSE '''' 
	END transferdate, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' 
		 THEN ''Pago '' + 
			CASE WHEN ppl_frecuencia = 1 THEN ''1ra ''	
				 WHEN ppl_frecuencia = 2 THEN ''2da ''	
				 WHEN ppl_frecuencia = 2 THEN ''3ra ''	
				 WHEN ppl_frecuencia = 2 THEN ''4ta ''	
				 WHEN ppl_frecuencia = 2 THEN ''5ta ''	
				 ELSE '''' 
			END + 	
			gen.fn_crufl_NombreMes(ppl_mes) + CONVERT(VARCHAR, ppl_anio) 	
		 ELSE '''' 
	END transferreference, 
	CASE WHEN fpe_codfpa = ' + CONVERT(VARCHAR, @codfpa) + ' 
		 THEN ((SELECT ISNULL(SUM(inn_valor), 0) 	
			    FROM sal.inn_ingresos 	
			    WHERE inn_codppl = ppl_codigo
					AND inn_codemp = emp_codigo) - 
			   (SELECT ISNULL(SUM(dss_valor), 0)
				FROM sal.dss_descuentos 	
				WHERE dss_codppl = ppl_codigo
					AND   dss_codemp = emp_codigo))
		 ELSE 0     
	END transfersum, 	
	CASE WHEN fpe_codfpa = 2 THEN
		''C''
	WHEN fpe_codfpa = 3 THEN
		''A''
	end forma_pago 
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
WHERE hpa_codppl = ' + CONVERT(VARCHAR, @codppl) + '
	and fpe_codfpa = 2
	AND NOT EXISTS (SELECT 1
				    FROM sap_cpe_control_pagos_efectuados
				    WHERE cpe_codcia = cia_codigo
						AND cpe_codtpl = ppl_codtpl
						AND cpe_codpla = hpa_codppl
						AND cpe_codemp = hpa_codemp) 
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