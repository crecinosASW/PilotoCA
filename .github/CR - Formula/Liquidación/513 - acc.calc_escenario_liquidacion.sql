--------------------------------------------------------------------------------------
-- Evolution STANDARD - Liquidacion                                                 --
-- Calculo de escenario de Liquidacion                                              --
-- Funciones que utiliza:                                                           --
--   01.- gt.calculo_liquidacion                                                    --
--------------------------------------------------------------------------------------
/*
    Estructura del XML de 'parametros':
        <DocumentElement><MotivosRetiro><NombreCampoPropertyBag1>valor1</NombreCampoPropertyBag1><NombreCampoPropertyBag2>valor2</NombreCampoPropertyBag1></MotivosRetiro></DocumentElement>
*/

/*
EXEC acc.calc_escenario_liquidacion NULL, 80, 1, 1, '20140806', '<DocumentElement>
  <MotivosRetiro>
    <mrt_ordinario>true</mrt_ordinario>
	<mrt_cesantia>true</mrt_cesantia>
	<mrt_preaviso>true</mrt_preaviso>
    <mrt_porc_cesantia>100.00</mrt_porc_cesantia>
	<mrt_dias_preaviso>0.00</mrt_dias_preaviso>
  </MotivosRetiro>
</DocumentElement>', NULL, 'admin'
*/
ALTER procedure acc.calc_escenario_liquidacion
    @SESSION_ID varchar(36),    -- Código de la Liquidación
    @codemp int,                 -- Código del empleado
    @codcmr smallint,            -- Código de la categoría del motivo de retiro
    @codmrt smallint,            -- Código del motivo de retiro
    @fechaRetiro datetime,       -- Fecha de retiro
    @parametros xml,             -- Parametros de calculo (heredado del motivo de retiro)
    @valores xml,                -- Valores Fijos que no sufriran cambios
    @username varchar(50)        -- Nombre del usuario
AS

declare
@codpai varchar(2)

begin
    /* Crear tablas temporales con los datos recibidos*/
    create table #dli_detliq_ingresos (
                    dli_codigo bigint identity(1,1),
                    dli_session_id varchar(36),
                    dli_codtig smallint,
                    dli_valor money,
                    dli_codmon varchar(3),
                    dli_tiempo numeric(10, 2),
                    dli_unidad_tiempo varchar(15),
                    dli_comentario varchar(255),
                    dli_es_valor_fijo bit)
    
    create table #dld_detliq_descuentos (
                    dld_codigo bigint identity(1,1),
                    dld_session_id varchar(36),
                    dld_codtdc smallint,
                    dld_es_descuento_legal bit,
                    dld_valor money,
                    dld_valor_patronal money,
                    dld_ingreso_afecto money,
                    dld_codmon varchar(3),
                    dld_tiempo numeric(10, 2),
                    dld_unidad_tiempo varchar(15),
                    dld_comentario varchar(255),
                    dld_es_valor_fijo bit)

    create table #dlr_detliq_reservas (
                    dlr_codigo bigint identity(1,1),
                    dlr_session_id varchar(36),
                    dlr_codtrs smallint,
                    dlr_valor money,
                    dlr_codmon varchar(3),
                    dlr_tiempo numeric(10, 2),
                    dlr_unidad_tiempo varchar(15),
                    dlr_comentario varchar(255),
                    dlr_es_valor_fijo bit)
    
    insert into #dli_detliq_ingresos (--dli_codigo, 
         dli_session_id, dli_codtig, dli_valor, dli_codmon, dli_tiempo, dli_unidad_tiempo, dli_comentario, dli_es_valor_fijo)
    select 
           -- t.c.value('Codigo[1]', 'bigint') dli_codigo,
            @SESSION_ID dli_session_id,
            t.c.value('CodigoTipo[1]', 'smallint') dli_codtig,
            t.c.value('Valor[1]', 'money') dli_valor, 
            isnull(nullif(t.c.value('CodigoMoneda[1]', 'varchar(3)'), ''), null) dli_codmon,
            t.c.value('Tiempo[1]', 'numeric(10,2)') dli_tiempo,
            isnull(nullif(t.c.value('UnidadTiempo[1]', 'varchar(15)'), ''), null) dli_unidad_tiempo,
            isnull(nullif(t.c.value('Comentario[1]', 'varchar(255)'), ''), null) dli_comentario,
            t.c.value('EsValorFijo[1]', 'bit') dli_es_valor_fijo
     from   @valores.nodes('/EscenarioLiquidacion/Ingresos/EscenarioIngresoLiquidacion') T(c)

    insert into #dld_detliq_descuentos (
            --dld_codigo, 
            dld_session_id, dld_codtdc, dld_es_descuento_legal, dld_valor, dld_valor_patronal, dld_ingreso_afecto, dld_codmon, dld_tiempo, dld_unidad_tiempo, dld_comentario, dld_es_valor_fijo)  
    select  
            --t.c.value('Codigo[1]', 'bigint') dld_codigo,
            @SESSION_ID dli_session_id,
            t.c.value('CodigoTipo[1]', 'smallint') dld_codtdc,
            t.c.value('EsDescuentoLegal[1]', 'bit') dld_es_descuento_legal,
            t.c.value('Valor[1]', 'money') dld_valor,
            t.c.value('ValorPatronal[1]', 'money') dld_valor_patronal,
            t.c.value('IngresoAfecto[1]', 'money') dld_ingreso_afecto,
            isnull(nullif(t.c.value('CodigoMoneda[1]', 'varchar(3)'), ''), null) dld_codmon,
            t.c.value('Tiempo[1]', 'numeric(10,2)') dld_tiempo,
            isnull(nullif(t.c.value('UnidadTiempo[1]', 'varchar(15)'), ''), null) dld_unidad_tiempo,
            isnull(nullif(t.c.value('Comentario[1]', 'varchar(255)'), ''), null) dld_comentario,
            t.c.value('EsValorFijo[1]', 'bit') dld_es_valor_fijo
      from  @valores.nodes('/EscenarioLiquidacion/Descuentos/EscenarioDescuentoLiquidacion') T(c)

    insert  into #dlr_detliq_reservas (--dlr_codigo, 
            dlr_session_id, dlr_codtrs, dlr_valor, dlr_codmon, dlr_tiempo, dlr_unidad_tiempo, dlr_comentario, dlr_es_valor_fijo)
    select  
            --t.c.value('Codigo[1]', 'bigint') dlr_codigo,
            @SESSION_ID dli_session_id,
            t.c.value('CodigoTipo[1]', 'smallint') dlr_codtrs,
            t.c.value('Valor[1]', 'money') dlr_valor, 
            t.c.value('CodigoMoneda[1]', 'varchar(3)') dlr_codmon,
            t.c.value('Tiempo[1]', 'numeric(10,2)') dlr_tiempo,
            t.c.value('UnidadTiempo[1]', 'varchar(15)') dlr_unidad_tiempo,
            t.c.value('Comentario[1]', 'varchar(255)') dlr_comentario,
            t.c.value('EsValorFijo[1]', 'bit') dlr_es_valor_fijo
      from  @valores.nodes('/EscenarioLiquidacion/Reservas/EscenarioReservaLiquidacion') T(c)
     
    /* Fin creacion de tablas temporales con los valores enviados*/
         
	SELECT @codpai = cia_codpai
	  FROM exp.emp_empleos
	  JOIN eor.plz_plazas on plz_codigo = emp_codplz
	  JOIN eor.cia_companias on cia_codigo = plz_codcia
	where emp_codigo = @codemp
  
    --if @codpai = 'sv'
    --begin
    --     exec sv.calculo_liquidacion @codemp, @fechaRetiro, @codmrt, @parametros
    --end

    if @codpai = 'gt'
    begin
        -- Si se necesitan agregar mas parametros (se deben leer en el select de la tabla acc.ret_retiros)
        exec gt.calculo_liquidacion @codemp, @fechaRetiro, @codmrt, @parametros
    end
    
	if @codpai = 'cr'
    begin
        exec cr.calculo_liquidacion @codemp, @fecharetiro, @codmrt, @parametros
    end

    --- resto de paises ---
   
    /*
        Elimina la liquidación y la reemplaza por los valores de las tablas temporales
    */
    begin transaction
    delete from tmp.dli_detliq_ingresos where dli_session_id = @SESSION_ID
    delete from tmp.dld_detliq_descuentos where dld_session_id = @SESSION_ID
    delete from tmp.dlr_detliq_reservas where dlr_session_id = @SESSION_ID

    insert into tmp.dli_detliq_ingresos (dli_session_id, dli_codtig, dli_valor, dli_codmon, dli_tiempo, dli_unidad_tiempo, dli_comentario, dli_es_valor_fijo, dli_fecha_grabacion)
    select 
            --dli_codigo,
            @SESSION_ID,
            dli_codtig,
            isnull(dli_valor,0), 
            dli_codmon,
            dli_tiempo,
            dli_unidad_tiempo,
            dli_comentario,
            dli_es_valor_fijo,
            getdate()
     from   #dli_detliq_ingresos
     where isnull(dli_codtig,0) <> 0
     
    insert into tmp.dld_detliq_descuentos (dld_session_id, dld_codtdc, dld_es_descuento_legal, dld_valor, dld_valor_patronal, dld_ingreso_afecto, dld_codmon, dld_tiempo, dld_unidad_tiempo, dld_comentario, dld_es_valor_fijo, dld_fecha_grabacion)
    select  
            --dld_codigo,
            @SESSION_ID,
            dld_codtdc,
            dld_es_descuento_legal,
            dld_valor,
            dld_valor_patronal,
            dld_ingreso_afecto,
            dld_codmon,
            dld_tiempo,
            dld_unidad_tiempo,
            dld_comentario,
            dld_es_valor_fijo,
            getdate()
     from   #dld_detliq_descuentos

    insert into tmp.dlr_detliq_reservas (dlr_session_id, dlr_codtrs, dlr_valor, dlr_codmon, dlr_tiempo, dlr_unidad_tiempo, dlr_comentario, dlr_es_valor_fijo, dlr_fecha_grabacion)
    select  
            --dlr_codigo,
            @SESSION_ID,
            dlr_codtrs,
            dlr_valor, 
            dlr_codmon,
            dlr_tiempo,
            dlr_unidad_tiempo,
            dlr_comentario,
            dlr_es_valor_fijo,
            getdate()
     from   #dlr_detliq_reservas
     
    commit transaction
end

