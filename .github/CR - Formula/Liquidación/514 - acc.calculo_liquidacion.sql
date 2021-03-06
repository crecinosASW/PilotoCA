IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('acc.calculo_liquidacion'))
BEGIN
	DROP PROCEDURE acc.calculo_liquidacion
END

GO

--------------------------------------------------------------------------------------
-- Evolution STANDARD - Liquidacion                                                 --
-- Procedimiento General del calculo de liquidacion                                 --
-- Funciones que utiliza:                                                           --
--   01.- gt.calculo_liquidacion                                                    --                                                          --
--------------------------------------------------------------------------------------
/*
    Estructura XML parametros:
        '<DocumentElement><Liquidaciones><NombreCampoPropertyBag1>valor1</NombreCampoPropertyBag1><NombreCampoPropertyBag2>valor2</NombreCampoPropertyBag2></Liquidaciones><DocumentElement>'
*/
CREATE PROCEDURE acc.calculo_liquidacion
    @codlie int,            -- Código de la Liquidación
    @codemp int,            -- Código del empleado
    @codcmr smallint,       -- Código de la categoría del motivo de retiro
    @codmrt smallint,       -- Código del motivo de retiro
    @parametros xml,        -- Parametros de calculo (heredado del motivo de retiro)
    @valores xml,           -- Valores Fijos que no sufriran cambios
    @username varchar(50)   -- Nombre de usuario
AS

begin
    /* Crear tablas temporales con los datos recibidos*/
    create table #dli_detliq_ingresos (
                    dli_codigo int identity(1,1),
                    dli_codlie int,
                    dli_codtig smallint,
                    dli_valor money,
                    dli_codmon varchar(3),
                    dli_tiempo numeric(10, 2),
                    dli_unidad_tiempo varchar(15),
                    dli_comentario varchar(255),
                    dli_es_valor_fijo bit)
    
    create table #dld_detliq_descuentos (
                    dld_codigo int identity(1,1) , 
                    dld_codlie int,
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
                    dlr_codigo int identity(1,1),
                    dlr_codlie int,
                    dlr_codtrs smallint,
                    dlr_valor money,
                    dlr_codmon varchar(3),
                    dlr_tiempo numeric(10, 2),
                    dlr_unidad_tiempo varchar(15),
                    dlr_comentario varchar(255),
                    dlr_es_valor_fijo bit)
                    
    insert into #dli_detliq_ingresos (--dli_codigo, 
            dli_codlie, dli_codtig, dli_valor, dli_codmon, dli_tiempo, dli_unidad_tiempo, dli_comentario, dli_es_valor_fijo)
    select 
            --t.c.value('Codigo[1]', 'int') dli_codigo,
            @codlie dli_codlie,
            t.c.value('CodigoTipo[1]', 'smallint') dli_codtig,
            t.c.value('Valor[1]', 'money') dli_valor, 
            isnull(nullif(t.c.value('CodigoMoneda[1]', 'varchar(3)'), ''), null) dli_codmon,
            t.c.value('Tiempo[1]', 'numeric(10,2)') dli_tiempo,
            isnull(nullif(t.c.value('UnidadTiempo[1]', 'varchar(15)'), ''), null) dli_unidad_tiempo,
            isnull(nullif(t.c.value('Comentario[1]', 'varchar(255)'), ''), null) dli_comentario,
            t.c.value('EsValorFijo[1]', 'bit') dli_es_valor_fijo
     from   @valores.nodes('/DetallesLiquidacion/Ingresos/IngresoLiquidacion') T(c)

    insert into #dld_detliq_descuentos (--dld_codigo, 
            dld_codlie, dld_codtdc, dld_es_descuento_legal, dld_valor, dld_valor_patronal, dld_ingreso_afecto, dld_codmon, dld_tiempo, dld_unidad_tiempo, dld_comentario, dld_es_valor_fijo)
    select  
            --t.c.value('Codigo[1]', 'int') dld_codigo,
            @codlie dld_codlde,
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
      from  @valores.nodes('/DetallesLiquidacion/Descuentos/DescuentoLiquidacion') T(c)

    insert  into #dlr_detliq_reservas (--dlr_codigo, 
            dlr_codlie, dlr_codtrs, dlr_valor, dlr_codmon, dlr_tiempo, dlr_unidad_tiempo, dlr_comentario, dlr_es_valor_fijo)
    select  
            --t.c.value('Codigo[1]', 'int') dlr_codigo,
            @codlie dlr_codlie,
            t.c.value('CodigoTipo[1]', 'smallint') dlr_codtrs,
            t.c.value('Valor[1]', 'money') dlr_valor, 
            t.c.value('CodigoMoneda[1]', 'varchar(3)') dlr_codmon,
            t.c.value('Tiempo[1]', 'numeric(10,2)') dlr_tiempo,
            t.c.value('UnidadTiempo[1]', 'varchar(15)') dlr_unidad_tiempo,
            t.c.value('Comentario[1]', 'varchar(255)') dlr_comentario,
            t.c.value('EsValorFijo[1]', 'bit') dlr_es_valor_fijo
      from  @valores.nodes('/DetallesLiquidacion/Reservas/ReservaLiquidacion') T(c)

    /* Fin creacion de tablas temporales con los valores enviados*/

    -- Variables para enviar parametros a los procedimientos de país
    declare @codpai varchar(2), @fecha_retiro datetime

    select @fecha_retiro = lie_fecha_retiro 
      from acc.lie_liquidaciones
     where lie_codigo = @codlie
    
    select @codpai = cia_codpai
      from exp.emp_empleos
      join eor.plz_plazas on plz_codigo = emp_codplz
      join eor.cia_companias on cia_codigo = plz_codcia
     where emp_codigo = @codemp

    /*
    if @codpai = 'sv'
    begin
        exec sv.calculo_liquidacion @codemp, @fecha_retiro, @codmrt, @parametros
    end
     */
    if @codpai = 'gt'
    begin
        exec gt.calculo_liquidacion @codemp, @fecha_retiro, @codmrt, @parametros
    end
 
	if @codpai = 'cr'
    begin
        exec cr.calculo_liquidacion @codemp, @fecha_retiro, @codmrt, @parametros
    end
	
    --- resto de paises ---
    
    /*
        Elimina la liquidación y la reemplaza por los valores de las tablas temporales
    */
    begin transaction

    delete from acc.dli_detliq_ingresos
     where dli_codlie = @codlie
     
    delete from acc.dld_detliq_descuentos
     where dld_codlie = @codlie

    delete from acc.dlr_detliq_reservas
     where dlr_codlie = @codlie

    insert into acc.dli_detliq_ingresos (dli_codlie, dli_codtig, dli_valor, dli_codmon, dli_tiempo, dli_unidad_tiempo, dli_comentario, dli_es_valor_fijo, dli_usuario_grabacion, dli_fecha_grabacion)
    select  @codlie,
            dli_codtig,
            dli_valor, 
            dli_codmon,
            dli_tiempo,
            dli_unidad_tiempo,
            dli_comentario,
            dli_es_valor_fijo,
            @username,
            getdate()
     from   #dli_detliq_ingresos

    insert into acc.dld_detliq_descuentos (dld_codlie, dld_codtdc, dld_es_descuento_legal, dld_valor, dld_valor_patronal, dld_ingreso_afecto, dld_codmon, dld_tiempo, dld_unidad_tiempo, dld_comentario, dld_es_valor_fijo, dld_usuario_grabacion, dld_fecha_grabacion)
    select  @codlie,
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
            @username,
            getdate()
     from   #dld_detliq_descuentos

    insert into acc.dlr_detliq_reservas (dlr_codlie, dlr_codtrs, dlr_valor, dlr_codmon, dlr_tiempo, dlr_unidad_tiempo, dlr_comentario, dlr_es_valor_fijo, dlr_usuario_grabacion, dlr_fecha_grabacion)
    select  @codlie,
            dlr_codtrs,
            dlr_valor, 
            dlr_codmon,
            dlr_tiempo,
            dlr_unidad_tiempo,
            dlr_comentario,
            dlr_es_valor_fijo,
            @username,
            getdate()
     from   #dlr_detliq_reservas
     
    commit transaction
end
