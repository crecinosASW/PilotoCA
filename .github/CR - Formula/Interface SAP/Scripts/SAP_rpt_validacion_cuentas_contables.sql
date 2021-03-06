IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gt.SAP_rpt_validacion_cuentas_contables'))
BEGIN
	DROP PROCEDURE gt.SAP_rpt_validacion_cuentas_contables
END

GO

--EXEC gt.SAP_rpt_validacion_cuentas_contables 81
create procedure gt.SAP_rpt_validacion_cuentas_contables (	
	@codppl varchar(15)
)

as

--declare @codppl varchar(15)

--set @codppl = 203

set nocount on

declare	@base_SAP varchar(150),
	@xSql varchar(5000),
	@base_SAP_costo varchar(150),
	@codtpl_v INT

SET @base_SAP = 'SBO_FRUCTACR'

set @xSql = ''

set @xSql = '
select convert(varchar, tpl_codcia) + '' - '' + cia_descripcion as codcia, 
	convert(varchar, tpl_codigo) + '' - '' + tpl_descripcion as codtpl, 
	dco_cta_contable dco_cta_contable, 
	(select acctcode 
	 from ' + @base_SAP + '.dbo.oact 
	 where FormatCode = replace(replace(dco_cta_contable,''.'',''''),''-'','''') COLLATE SQL_Latin1_General_CP1_CI_AS ) as Lines_AccountCode, 
	dco_creditos as Lines_Credit, 
	dco_debitos as Lines_Debit, 
	dco_descripcion as Lines_LineMemo,  
	dco_linea as correlativo 
into #ttemp01 
FROM cr.dco_datos_contables 
	JOIN sal.ppl_periodos_planilla ON dco_codppl = ppl_codigo
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo 
where dco_codppl = ' + CONVERT(VARCHAR, @codppl) + '
	and dco_creditos + dco_debitos <> 0

select * 
from #ttemp01 
where lines_accountcode is null'

exec (@xsql)
--print (@xsql)