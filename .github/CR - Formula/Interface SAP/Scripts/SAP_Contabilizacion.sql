 EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gt.SAP_Contabilizacion'))
BEGIN
	DROP PROCEDURE gt.SAP_Contabilizacion
END

GO

--EXEC gt.SAP_Contabilizacion 1131 
CREATE procedure gt.SAP_Contabilizacion (	
	@codppl int
)

AS

--declare @codppl int

--set @codppl = 202

declare	@base_SAP varchar(150),
	@xSql varchar(5000)

SET @base_SAP = 'SBO_FRUCTACR'

SET @xsql = '
SELECT cia_codigo codcia,
	ppl_codtpl codtpl,
	CONVERT(VARCHAR, ppl_codigo) codppl, 
	dco_codemp codemp, 
	cia_codigo empresa,
	ppl_fecha_fin duedate,
	'''' indicator,
	replace(dco_cta_contable, ''.'', '''') dco_cta_contable,
	(SELECT acctcode
		FROM ' + @base_sap + '.dbo.oact 	
		WHERE formatcode = replace(replace(dco_cta_contable,''.'',''''),''-'','''') 
		COLLATE sql_latin1_general_cp1_ci_AS ) lines_accountcode, 
	0 lines_basesum, 
	'''' lines_contraaccount, 
	ISNULL(LTRIM(RTRIM(dco_centro_costo)), '''') lines_costingcode,
	'''' lines_costingcode2,
	'''' lines_costingcode3,
	'''' lines_costingcode4,
	'''' lines_costingcode5,
	dco_creditos_usd lines_credit, 
	dco_debitos_usd lines_debit, 
	ppl_fecha_fin lines_duedate, 
	CASE 
		WHEN tpl_codmon = ''GTQ'' THEN ''QTZ''
		WHEN tpl_codmon = ''USD'' THEN ''COL''
		WHEN tpl_codmon = ''CRC'' THEN ''COL''
		ELSE ''''
	END lines_fccurrency, 
	SUBSTRING(dco_descripcion,1,50) lines_linememo,  
	'''' lines_projectcode, 
	'''' lines_reference1, 
	'''' lines_reference2, 
	0 lines_referencedate1, 
	0 lines_referencedate2, 
	(SELECT acctcode
		FROM ' + @base_sap + '.dbo.oact 	
		WHERE formatcode = replace(replace(dco_cta_contable,''.'',''''),''-'','''') 
		COLLATE sql_latin1_general_cp1_ci_AS ) lines_shortname, 
	0 lines_systembaseamount, 
	ppl_fecha_fin lines_taxdate, 
	'''' lines_taxgroup, 
	ppl_fecha_fin lines_vatdate, 
	0 lines_vatline, 
	''Pago '' + 
		LTRIM(RTRIM(tpl_descripcion)) +  	
		CASE 
			WHEN ppl_frecuencia = 1 THEN '' 1ra '' 	
			WHEN ppl_frecuencia = 2 THEN '' 2da '' 	
			WHEN ppl_frecuencia = 2 THEN '' 3ra '' 	
			WHEN ppl_frecuencia = 2 THEN '' 4ta '' 	
			WHEN ppl_frecuencia = 2 THEN '' 5ta '' 	
			ELSE '''' 
		END + 
		gen.nombre_mes(ppl_mes) +
		CONVERT(VARCHAR, ppl_anio ) memo, 
	'''' projectcode, 
	'''' reference, 
	''Evolution'' reference2, 
	ppl_fecha_fin referencedate, 
	''19'' series,
	0 stamptax, 
	ppl_fecha_fin stornodate, 
	ppl_fecha_fin taxdate, 
	'''' transactioncode, 
	0 useautostorno, 
	ppl_fecha_fin vatdate, 
	dco_linea correlativo, 
	''G'' tipo_partida 
FROM cr.dco_datos_contables 
	JOIN sal.ppl_periodos_planilla ON dco_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE dco_codppl = ' + CONVERT(VARCHAR, @codppl) + '
	AND (dco_creditos + dco_debitos) <> 0
ORDER BY dco_tipo_partida, correlativo'

EXEC (@xsql)
--PRINT (@xsql)