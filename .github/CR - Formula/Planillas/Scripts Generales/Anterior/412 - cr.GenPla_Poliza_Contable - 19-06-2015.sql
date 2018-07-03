IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_Poliza_Contable'))
BEGIN
	DROP PROCEDURE cr.GenPla_Poliza_Contable
END

GO

--EXEC cr.GenPla_Poliza_Contable 1131
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
           substring( isnull(tig_cuenta, 'Cuenta PENDIENTE ')
                              , 1, 40
                    ) dco_cuenta,
	       tig_descripcion + ' - ' + cco_descripcion AS dco_descripcion,
	       round(case when inn_codmon = 'USD' then sum(inn_valor) * hpa_tasa_cambio else sum(inn_valor) end, 3)  AS dco_debitos,
	       0.00 AS dco_creditos,
		   hpa_tasa_cambio dco_tasa_cambio,
		   round(case when inn_codmon = 'USD' then sum(inn_valor) else sum(inn_valor) / hpa_tasa_cambio end, 3)  AS dco_debitos_usd,
		   0.00 AS dco_creditos_usd,
	       @anio dco_anio,
	       @mes dco_mes,
	       identity(int, 1, 1) AS dco_linea,
	       'G' AS dco_tipo_partida,
	       null dco_codemp,
	       null dco_norma_reparto
	       
    INTO #Ingresos
    
    FROM sal.inn_ingresos 
		join sal.hpa_hist_periodos_planilla ON inn_codppl = hpa_codppl AND inn_codemp = hpa_codemp AND hpa_tasa_cambio > 0.00
        join sal.tig_tipos_ingreso on tig_codigo = inn_codtig
        join exp.emp_empleos on inn_codemp = emp_codigo
        join eor.plz_plazas on emp_codplz = plz_codigo
        left join eor.cpp_centros_costo_plaza on plz_codigo = cpp_codplz
        left join eor.cco_centros_de_costo on cco_codigo = cpp_codcco
    WHERE inn_codppl = @codppl
    GROUP BY inn_codppl, tig_cuenta, cco_nomenclatura_contable, tig_descripcion, cco_descripcion, inn_codmon, hpa_tasa_cambio

    -- Descuentos aplicados en la planilla

    SELECT dss_codppl AS dco_codppl, 
	       null dco_centro_costo,
	       substring( isnull(tdc_cuenta, 'Cuenta PENDIENTE ')
                              , 1, 40
                    ) dco_cuenta,
	       tdc_descripcion AS dco_descripcion,
	       0.00 AS dco_debitos,
	       round(case when dss_codmon = 'USD' then sum(dss_valor) * hpa_tasa_cambio else sum(dss_valor) end, 3) AS dco_creditos,
		   hpa_tasa_cambio dco_tasa_cambio,
		   0.00 dco_debitos_usd,
		   round(case when dss_codmon = 'USD' then sum(dss_valor) else sum(dss_valor) / hpa_tasa_cambio end, 3) AS dco_creditos_usd,
	       @anio dco_anio,
	       @mes dco_mes,
	   	    identity(int, 2000, 1) dco_linea,
	       'G' AS tipo_partida,
	       null dco_codemp,
	       null dco_norma_reparto
	       
    INTO #Descuentos
    
    FROM sal.dss_descuentos
		join sal.hpa_hist_periodos_planilla ON dss_codppl = hpa_codppl AND dss_codemp = hpa_codemp AND hpa_tasa_cambio > 0.00
        join sal.tdc_tipos_descuento on tdc_codigo = dss_codtdc
    WHERE dss_codppl = @codppl
    GROUP BY  dss_codppl, tdc_cuenta, tdc_codigo, tdc_descripcion, dss_codmon, hpa_tasa_cambio


    -- Salarios por pagar
    
    SELECT hpa_codppl dco_codppl,
	       null dco_centro_costo,
	       isnull(@cta_salarios_por_pagar, 'Parámetro no configurado') dco_cuenta,
	       'Salarios por Pagar' decripcion, 
	       0.00 dco_debito,
	       ROUND((
			   ISNULL((
				   SELECT ROUND(SUM(dco_debitos), 3)
				   FROM #Ingresos
				   WHERE dco_codppl = hpa_codppl
				   GROUP BY dco_codppl), 0.00)
			   - ISNULL((
				   SELECT ROUND(SUM(dco_creditos), 3)
				   FROM #Descuentos
				   WHERE dco_codppl = hpa_codppl
				   GROUP BY dco_codppl), 0.00)), 3) dco_credito,
		   hpa_tasa_cambio dco_tasa_cambio,
	       0.00 dco_debito_usd,
	       ROUND((
			   ISNULL((
				   SELECT ROUND(SUM(dco_debitos_usd), 3)
				   FROM #Ingresos
				   WHERE dco_codppl = hpa_codppl
				   GROUP BY dco_codppl), 0.00)
			   - ISNULL((
				   SELECT ROUND(SUM(dco_creditos_usd), 3)
				   FROM #Descuentos
				   WHERE dco_codppl = hpa_codppl
				   GROUP BY dco_codppl), 0.00)), 3) dco_credito_usd,
	       @anio dco_anio,
	       @mes dco_mes,
	       identity(int, 6000,1) dco_linea,
	       'G' AS dco_tipo_partida,
	       null dco_codemp,
	       null dco_norma_reparto
    	    
    INTO #Acreditamiento
    
    FROM sal.hpa_hist_periodos_planilla
		JOIN sal.ppl_periodos_planilla ON hpa_codppl = ppl_codigo
		JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
    WHERE hpa_codppl = @codppl
    GROUP BY hpa_codppl, hpa_tasa_cambio, tpl_codmon


    -- Reservas Débito
    
    SELECT res_codppl AS dco_codppl, 
	       cco_nomenclatura_contable dco_centro_costo,
	       substring(isnull(trs_cuenta, 'PENDIENTE '),1,40) dco_cuenta,
	       trs_descripcion + ' - ' + cco_descripcion AS dco_descripcion,
	       round(case when res_codmon = 'USD' then sum(res_valor) * hpa_tasa_cambio else sum(res_valor) end, 3)  AS dco_debitos,
	       0.00 AS dco_creditos,
		   hpa_tasa_cambio dco_tasa_cambio,
		   round(case when res_codmon = 'USD' then sum(res_valor) else sum(res_valor) / hpa_tasa_cambio end, 3)  AS dco_debitos_usd,
	       0.00 AS dco_creditos_usd,
	       @anio dco_anio,
	       @mes dco_mes,
	       identity(int, 10000, 1) AS dco_linea,
	       'R' AS dco_tipo_partida,	
	       null dco_codemp,
	       null dco_norma_reparto
	       
    INTO #Reservas
    
    FROM sal.res_reservas
		join sal.hpa_hist_periodos_planilla ON res_codppl = hpa_codppl AND res_codemp = hpa_codemp AND hpa_tasa_cambio > 0.00
        join sal.trs_tipos_reserva on trs_codigo = res_codtrs
        join exp.emp_empleos on emp_codigo = res_codemp
        join eor.plz_plazas on emp_codplz = plz_codigo
        left join eor.cpp_centros_costo_plaza on plz_codigo = cpp_codplz
        left join eor.cco_centros_de_costo on cco_codigo = cpp_codcco
    WHERE res_codppl = @codppl
    GROUP BY res_codppl, trs_cuenta, trs_codigo, cco_codigo,  trs_descripcion, cco_descripcion, cco_nomenclatura_contable, res_codmon, hpa_tasa_cambio
    
    
    -- Reservas Crédito

	SELECT dco_codppl,
		dco_centro_costo,
		dco_cuenta,
		dco_descripcion,
		SUM(dco_debitos) dco_debitos,
		SUM(dco_creditos) dco_creditos,
		dco_tasa_cambio,
		SUM(dco_debitos_usd) dco_debitos_usd,
		SUM(dco_creditos_usd) dco_creditos_usd,
		dco_anio,
		dco_mes,
		identity(int, 10000, 1) AS dco_linea,
		dco_tipo_partida,
		dco_codemp,
		dco_norma_reparto
	INTO #Reservas_credito
	FROM (
		SELECT res_codppl AS dco_codppl, 
			   NULL dco_centro_costo,
			   substring(isnull(trs_cuenta_aux, 'PENDIENTE CTA AUX'),1,40) dco_cuenta,
			   trs_descripcion dco_descripcion,
			   0.00 AS dco_debitos,
			   round(case when res_codmon = 'USD' then sum(res_valor) * hpa_tasa_cambio else sum(res_valor) end, 3) AS dco_creditos,
			   hpa_tasa_cambio dco_tasa_cambio,
			   0.00 AS dco_debitos_usd,
			   round(case when res_codmon = 'USD' then sum(res_valor) else sum(res_valor) / hpa_tasa_cambio end, 3) AS dco_creditos_usd,
			   @anio dco_anio,
			   @mes dco_mes,
			   'R' AS dco_tipo_partida,	
			   null dco_codemp,
			   null dco_norma_reparto
		FROM sal.res_reservas
			join sal.hpa_hist_periodos_planilla ON res_codppl = hpa_codppl AND res_codemp = hpa_codemp AND hpa_tasa_cambio > 0.00
			join sal.trs_tipos_reserva on trs_codigo = res_codtrs
			join exp.emp_empleos on emp_codigo = res_codemp
			join eor.plz_plazas on emp_codplz = plz_codigo
			left join eor.cpp_centros_costo_plaza on plz_codigo = cpp_codplz
			left join eor.cco_centros_de_costo on cco_codigo = cpp_codcco
		WHERE res_codppl = @codppl
		GROUP BY res_codppl, trs_cuenta_aux, trs_codigo, cco_codigo,  trs_descripcion, cco_descripcion, cco_nomenclatura_contable, res_codmon, hpa_tasa_cambio) r
	GROUP BY dco_codppl, dco_centro_costo, dco_cuenta, dco_descripcion, dco_tasa_cambio, dco_anio, dco_mes, dco_tipo_partida, dco_codemp, dco_norma_reparto

    -- Insertando los registros de ingresos a la tabla de datos contables
    
    INSERT INTO cr.dco_datos_contables
        (
        dco_codppl,
	    dco_centro_costo, 
	    dco_cta_contable, 
	    dco_descripcion, 
	    dco_debitos, 
	    dco_creditos, 
		dco_tasa_cambio,
		dco_debitos_usd,
		dco_creditos_usd,
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
		dco_tasa_cambio,
		dco_debitos_usd,
		dco_creditos_usd,
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
		dco_tasa_cambio,
		dco_debitos_usd,
		dco_creditos_usd,
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
		dco_tasa_cambio,
		dco_debitos_usd,
		dco_creditos_usd,		 
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
		dco_tasa_cambio,
		dco_debitos_usd,
		dco_creditos_usd,		 
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