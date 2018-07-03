	IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_Poliza_Contable'))
BEGIN
	DROP PROCEDURE cr.GenPla_Poliza_Contable
END

GO

-- exec gt.GenPla_Poliza_Contable 3226
CREATE PROCEDURE cr.GenPla_Poliza_Contable (	
    @codppl int,
    @sessionId uniqueidentifier = null
)
 
AS

DECLARE @codcia INT,
	@mes SMALLINT,
	@anio INT,
	@codtpl INT,
	@cta_salarios_por_pagar varchar(50)

BEGIN
    -- Asignando los valores de la planilla
    
    SELECT @anio = ppl_anio,
	       @mes = ppl_mes,
	       @codtpl = ppl_codtpl,
	       @codcia = tpl_codcia
    FROM sal.ppl_periodos_planilla
        join sal.tpl_tipo_planilla on tpl_codigo = ppl_codtpl
    WHERE ppl_codigo = @codppl
    
    
    -- Eliminando los datos contables de la planilla actual
    
    DELETE cr.dco_datos_contables 
    WHERE dco_codppl = @codppl


    -- Asignando la cuenta para salarios por pagar
    	   
    SET @cta_salarios_por_pagar = isnull(gen.get_valor_parametro_varchar ('CuentaContableSalarioPorPagar',null,null,@codcia,null),'Cuenta Salario por pagar PENDIENTE')

    
    -- Ingresos aplicados en la planilla
    
    SELECT inn_codppl AS dco_codppl, 
	       cco_nomenclatura_contable dco_centro_costo,
           substring( isnull(cti_cuenta, 'Cuenta PENDIENTE ')
                              , 1, 40
                    ) dco_cuenta,
	       tig_descripcion + ' - ' + cco_descripcion AS dco_descripcion,
	       round(sum(inn_valor * isnull(cpp_porcentaje,100.00) ) / 100.00,2)  AS dco_debitos,
	       0.00 AS dco_creditos,
	       @anio dco_anio,
	       @mes dco_mes,
	       identity(int, 1, 1) AS dco_linea,
	       'G' AS dco_tipo_partida,
	       null dco_codemp,
	       cco_cta_contable dco_norma_reparto
	       
    INTO #Ingresos
    
    FROM sal.inn_ingresos 
        join sal.tig_tipos_ingreso on tig_codigo = inn_codtig
        join exp.emp_empleos on inn_codemp = emp_codigo
        join eor.plz_plazas on emp_codplz = plz_codigo
        left join eor.cpp_centros_costo_plaza on plz_codigo = cpp_codplz
        left join eor.cco_centros_de_costo on cco_codigo = cpp_codcco
        left join sal.cti_cuentas_tipo_ingreso on cti_codtig = inn_codtig AND cti_codcco = cco_codigo
    WHERE inn_codppl = @codppl
    GROUP BY inn_codppl, cti_cuenta, cco_nomenclatura_contable, tig_descripcion, cco_descripcion, cco_cta_contable

    -- Descuentos aplicados en la planilla

    SELECT dss_codppl AS dco_codppl, 
	       null dco_centro_costo,
	       substring( isnull(ctd_cuenta, 'Cuenta PENDIENTE ')
                              , 1, 40
                    ) dco_cuenta,
	       tdc_descripcion AS dco_descripcion,
	       0.00 AS dco_debitos,
	       round(sum(dss_valor),2) AS dco_creditos,
	       @anio dco_anio,
	       @mes dco_mes,
	   	    identity(int, 2000, 1) dco_linea,
	       'G' AS tipo_partida,
	       null dco_codemp,
	       null dco_norma_reparto
	       
    INTO #Descuentos
    
    FROM sal.dss_descuentos
        join sal.tdc_tipos_descuento on tdc_codigo = dss_codtdc
        left join sal.ctd_cuentas_tipo_descuen on ctd_codtdc = dss_codtdc
    WHERE dss_codppl = @codppl
    GROUP BY  dss_codppl, ctd_cuenta, tdc_codigo, tdc_descripcion


    -- Salarios por pagar
    
    SELECT inn_codppl dco_codppl,
	       null dco_centro_costo,
	       isnull(@cta_salarios_por_pagar, 'Parámetro no configurado') dco_cuenta, 
	       'Salarios por Pagar' decripcion, 
	       0.00 dco_debito,
	       round(isnull( sum(inn_Valor), 0 ) -
                isnull( ( SELECT isnull(sum(dss_valor), 0) 
                          FROM sal.dss_descuentos 
                          WHERE dss_codppl = @codppl
                         ), 0
                      ), 2
                ) dco_credito,
	       @anio dco_anio,
	       @mes dco_mes,
	       identity(int, 6000,1) dco_linea,
	       'G' AS dco_tipo_partida,
	       null dco_codemp,
	       null dco_norma_reparto
    	    
    INTO #Acreditamiento
    
    FROM sal.inn_ingresos
    WHERE inn_codppl = @codppl
    GROUP BY inn_codppl


    -- Reservas Débito
    
    SELECT res_codppl AS dco_codppl, 
	       cco_nomenclatura_contable dco_centro_costo,
	       substring(isnull(ctr_cuenta, 'PENDIENTE '),1,40) dco_cuenta,
	       trs_descripcion + ' - ' + cco_descripcion AS dco_descripcion,
	       round(sum(res_valor * isnull(cpp_porcentaje,100) )  / 100.00,2)  AS dco_debitos,
	       0.00 AS dco_creditos,
	       @anio dco_anio,
	       @mes dco_mes,
	       identity(int, 10000, 1) AS dco_linea,
	       'R' AS dco_tipo_partida,	
	       null dco_codemp,
	       cco_cta_contable dco_norma_reparto
	       
    INTO #Reservas
    
    FROM sal.res_reservas
        join sal.trs_tipos_reserva on trs_codigo = res_codtrs
        join exp.emp_empleos on emp_codigo = res_codemp
        join eor.plz_plazas on emp_codplz = plz_codigo
        left join eor.cpp_centros_costo_plaza on plz_codigo = cpp_codplz
        left join eor.cco_centros_de_costo on cco_codigo = cpp_codcco
		left join sal.ctr_cuentas_tipo_reserva on ctr_codtrs = trs_codigo and cco_codigo = ctr_codcco
    WHERE res_codppl = @codppl
    GROUP BY res_codppl, ctr_cuenta, cco_cta_contable, trs_codigo, cco_codigo,  trs_descripcion, cco_descripcion, cco_nomenclatura_contable, cco_cta_contable
    
    
    -- Reservas Crédito
    
    SELECT res_codppl AS dco_codppl, 
	       NULL dco_centro_costo,
	       substring(isnull(ctr_cuenta_aux, 'PENDIENTE CTA AUX'),1,40) dco_cuenta,
	       trs_descripcion dco_descripcion,
	       0.00  AS dco_debitos,
	       round(sum(res_valor),2) AS dco_creditos,
	       @anio dco_anio,
	       @mes dco_mes,
	       identity(int, 10000, 1) AS dco_linea,
	       'R' AS dco_tipo_partida,	
	       null dco_codemp,
	       null dco_norma_reparto
	       
    INTO #Reservas_credito
    
    FROM sal.res_reservas
        join sal.trs_tipos_reserva on trs_codigo = res_codtrs
		join exp.emp_empleos on emp_codigo = res_codemp
        join eor.plz_plazas on emp_codplz = plz_codigo
        left join eor.cpp_centros_costo_plaza on plz_codigo = cpp_codplz
        left join eor.cco_centros_de_costo on cco_codigo = cpp_codcco
		left join sal.ctr_cuentas_tipo_reserva on ctr_codtrs = trs_codigo and ctr_codcco = cco_codigo
    WHERE res_codppl = @codppl
    GROUP BY res_codppl, ctr_cuenta_aux, trs_codigo, trs_descripcion

    -- Insertando los registros de ingresos a la tabla de datos contables
    
    INSERT INTO cr.dco_datos_contables
        (
        dco_codppl,
	    dco_centro_costo, 
	    dco_cta_contable, 
	    dco_descripcion, 
	    dco_debitos, 
	    dco_creditos, 
	    dco_anio, 
	    dco_mes, 
	    dco_linea, 
	    dco_tipo_partida, 
	    dco_codemp,
	    dco_grupo
	    )
    SELECT *
    FROM #Ingresos
    WHERE dco_codppl = @codppl


    -- Insertando los registros de descuentos a la tabla de datos contables
    
    INSERT INTO cr.dco_datos_contables
        (
        dco_codppl,
	    dco_centro_costo, 
	    dco_cta_contable, 
	    dco_descripcion, 
	    dco_debitos, 
	    dco_creditos, 
	    dco_anio, 
	    dco_mes, 
	    dco_linea, 
	    dco_tipo_partida, 
	    dco_codemp,
	    dco_grupo
	    )
    SELECT *
    FROM #Descuentos
    WHERE dco_codppl = @codppl	

    
    -- Insertando los registros de salarios por pagar a la tabla de datos contables

    INSERT INTO cr.dco_datos_contables
        (
        dco_codppl,
	    dco_centro_costo, 
	    dco_cta_contable, 
	    dco_descripcion, 
	    dco_debitos, 
	    dco_creditos, 
	    dco_anio, 
	    dco_mes, 
	    dco_linea, 
	    dco_tipo_partida, 
	    dco_codemp,
	    dco_grupo
	    )
    SELECT *
    FROM #Acreditamiento
    WHERE dco_codppl = @codppl
    
    
    -- Insertando los registros del débito de las reservas

    INSERT INTO cr.dco_datos_contables
        (
        dco_codppl,
	    dco_centro_costo, 
	    dco_cta_contable, 
	    dco_descripcion, 
	    dco_debitos, 
	    dco_creditos, 
	    dco_anio, 
	    dco_mes, 
	    dco_linea, 
	    dco_tipo_partida, 
	    dco_codemp,
	    dco_grupo
	    )
    SELECT *
    FROM #Reservas
    WHERE dco_codppl = @codppl
    
    
    -- Insertando los registros del crédito de las reservas

    INSERT INTO cr.dco_datos_contables
        (
        dco_codppl,
	    dco_centro_costo, 
	    dco_cta_contable, 
	    dco_descripcion, 
	    dco_debitos, 
	    dco_creditos, 
	    dco_anio, 
	    dco_mes, 
	    dco_linea, 
	    dco_tipo_partida, 
	    dco_codemp,
	    dco_grupo
	    )
    SELECT *
    FROM #Reservas_credito
    WHERE dco_codppl = @codppl
    
    

    ----------------------------------------------------------------
    SELECT *
    FROM cr.dco_datos_contables
    WHERE dco_codppl = @codppl
    order by CONVERT(INT, dco_linea)


    drop table #Ingresos
    drop table #Descuentos
    drop table #Acreditamiento
    drop table #reservas
    drop table #reservas_credito

END