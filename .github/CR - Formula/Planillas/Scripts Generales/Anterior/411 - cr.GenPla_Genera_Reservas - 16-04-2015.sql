IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_Genera_Reservas'))
BEGIN
	DROP PROCEDURE cr.GenPla_Genera_Reservas
END

GO

--EXEC cr.GenPla_Genera_Reservas
CREATE PROCEDURE cr.GenPla_Genera_Reservas
    @codppl int,
    @sessionId uniqueidentifier = null

AS
DECLARE
    @codcia int,
    @trs_codigo int,
    @trs_codagr int,
    @trs_porcentaje float

BEGIN

    -- Eliminación de datos de reserva
    DELETE  FROM sal.res_reservas
            WHERE res_codppl = @codppl 
                    and sal.empleado_en_gen_planilla(@sessionId, res_codemp) = 1;
      
    -- Obtiene codigo de compañía
    SELECT  @codcia=tpl_codcia
    FROM sal.ppl_periodos_planilla
        join sal.tpl_tipo_planilla on tpl_codigo = ppl_codtpl
    WHERE ppl_codigo = @codppl;

    -- Cursor de reservas
    DECLARE c_reservas cursor for
    SELECT 
            trs_codigo,
            gen.get_pb_field_data(trs_property_bag_data,'trs_codagr') trs_codagr,
            isnull(gen.get_pb_field_data_float(trs_property_bag_data,'trs_porcentaje'),0) / 100 trs_porc_provision
    FROM sal.trs_tipos_reserva
    WHERE trs_tipo = 'Legal'
        and trs_codcia = @codcia
        
    
    -- Creación de la reserva
    OPEN c_reservas
    FETCH NEXT FROM c_reservas INTO @trs_codigo, @trs_codagr, @trs_porcentaje
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO sal.res_reservas ( 
            res_codppl, 
            res_codemp, res_codtrs, 
            res_valor, 
            res_codmon, 
            res_tiempo,
            res_unidad_tiempo
            )
        SELECT 
            inn_codppl, 
            inn_codemp, 
            @trs_codigo,
            round(sum(inn_valor) * @trs_porcentaje,2) valor, 
            inn_codmon, avg(inn_tiempo) tiempo, inn_unidad_tiempo
        FROM sal.inn_ingresos
        WHERE inn_codppl = @codppl
            and inn_codtig in (select iag_codtig
                               from sal.iag_ingresos_agrupador
                               where iag_codagr = @trs_codagr)
            and sal.empleado_en_gen_planilla(@sessionId, inn_codemp) = 1
            
        GROUP BY inn_codppl, inn_codemp,  inn_codmon, inn_unidad_tiempo;
        
        
        FETCH NEXT FROM c_reservas INTO @trs_codigo, @trs_codagr, @trs_porcentaje
    END
END