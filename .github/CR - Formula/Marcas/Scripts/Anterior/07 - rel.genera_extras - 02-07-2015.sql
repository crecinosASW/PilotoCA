IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('rel.genera_extras'))
BEGIN
	DROP PROCEDURE rel.genera_extras
END

GO

/*
   Proceso de generación de horas extras
   a partir de la información de asistencia
   ----------------------------------------------
   Creado por: Fernando Paz
               25/04/2014

   Este proceso toma la información de la tabla de asistencia y genera horas extras
   a partir de ella.

   Los parametros para la generación los toma de la tabla pla_prl_parametros_reloj.  El procedimiento
   tambien toma en cuenta los dias de feriado de la tabla pla_cal_calendario
   Si el parametro codigo de empleado no es nulo, entonces ejecuta para el empleado seleccionado
   Si el paraemtro codigo de grupo no es nulo, entonces ejecuta para los empleados del grupo seleccionado
   Si el parametro codigo de unidad no es nulo, entonces ejecuta para los empleados de la unidad seleccionada
   
   Ejemplo de ejecución:
      exec rel.genera_extras 4
*/
CREATE PROCEDURE rel.genera_extras (
   @codppl int,
   @codemp int = null,
   @codgra int = null,
   @coduni int = null,
   @usuario varchar(100) = null
)

AS

--declare @codppl int, @codemp int, @codgra int, @coduni int
--select @codppl = 4

set nocount on
set datefirst  7
set dateformat dmy

set @usuario = isnull(@usuario, SYSTEM_USER)

-- Variables para almacenar la empresa, el tipo de planilla, fecha inicial y final de la planilla
declare @codcia int, @codtpl int, @fechaIni datetime, @fechaFin datetime, @codmon varchar(3)

select @codcia = tpl_codcia, @codtpl = tpl_codigo,
       @fechaIni = ppl_fecha_ini, 
       @fechaFin = ppl_fecha_fin,
       @codmon = tpl_codmon
  from sal.ppl_periodos_planilla
  join sal.tpl_tipo_planilla on tpl_codigo = ppl_codtpl
 where ppl_codigo = @codppl

--*
--* Obtiene los parametros de reloj que necesita el proceso de generacion
--*
declare @generaHEX bit,
        @errorMsg varchar(max),
        
        @estado_hex_gen varchar(50),
        @estado_workflow_hex_gen varchar(20),
        @tolerancia_min_extra int,
        @genera_extras_previas_hora_entrada bit,
        @codthe_diurna int,
        @factor_diurno decimal(7,4),
        
        @codthe_nocturna int,
        @factor_nocturno decimal(7,4),
        @hora_nocturnidad_ini char(5),
        @hora_nocturnidad_fin char(5),
        
        -- factores y tipos de hora para dia domingo, feriado
        @codthe_diurna_d int,
        @factor_diurno_d decimal(7,4),
        @codthe_nocturna_d int,
        @factor_nocturno_d decimal(7,4)        


set @generaHEX = isnull(gen.get_valor_parametro_bit('RelojGeneraHEX', null, null, @codcia, null), 0)
if @generaHEX = 0
begin
    print 'No se generaron horas extras porque el parámetro de aplicación RelojGeneraHEX no está especificado o indica que no se generen al enviarle el código de empresa (' + cast(@codcia as varchar) + ')'
    return
end

set @tolerancia_min_extra = gen.get_valor_parametro_int('RelojToleranciaMinutosExtras', null, null, @codcia, null)
set @genera_extras_previas_hora_entrada = gen.get_valor_parametro_bit('RelojGeneraExtrasAntesHoraEntrada', null, null, @codcia, null)

set @codthe_diurna = gen.get_valor_parametro_int('RelojTipoEXTDiurna', null, null, @codcia, null)
set @codthe_nocturna = gen.get_valor_parametro_int('RelojTipoEXTNocturna', null, null, @codcia, null)
set @codthe_diurna_d = gen.get_valor_parametro_int('RelojTipoEXTDiurnaDomingoAsueto', null, null, @codcia, null)
set @codthe_nocturna_d = gen.get_valor_parametro_int('RelojTipoEXTNocturnaDomingoAsueto', null, null, @codcia, null)
set @hora_nocturnidad_ini = right('0' + cast(gen.get_valor_parametro_varchar('RelojNocturnidadHoraInicio', null, null, @codcia, null) as varchar), 2) + ':00'
set @hora_nocturnidad_fin = right('0' + cast(gen.get_valor_parametro_varchar('RelojNocturnidadHoraFin', null, null, @codcia, null) as varchar), 2) + ':00'
set @estado_hex_gen = gen.get_valor_parametro_varchar('RelojEstadoHEXGenerado', null, null, @codcia, null)
set @estado_workflow_hex_gen = gen.get_valor_parametro_varchar('RelojEstadoWorkflowHEXGenerado', null, null, @codcia, null)

set @genera_extras_previas_hora_entrada = 0
set @tolerancia_min_extra = isnull(@tolerancia_min_extra, 0)
set @hora_nocturnidad_ini = isnull(@hora_nocturnidad_ini, '19:00')
set @hora_nocturnidad_fin = isnull(@hora_nocturnidad_fin, '06:00')
set @estado_hex_gen = isnull(@estado_hex_gen, 'Pendiente')
set @estado_workflow_hex_gen = isnull(@estado_workflow_hex_gen, 'Pendiente')


/** parametros para prueba *******************************************************************/
--set @codthe_diurna = 21
--set @codthe_nocturna = 21
--set @tolerancia_min_extra = 0
/*********************************************************************************************/

if @codthe_diurna is null begin
    set @errorMsg = 'No se halló un valor para el parámetro RelojTipoEXTDiurna para la empresa (' + cast(@codcia as varchar) + ').  Este valor debe contener el código del tipo de hora extra que se utilizará para generar horas extras diurnas.'
    raiserror (@errorMsg, 16, 1)
    return
end

if @codthe_nocturna is null begin
    set @errorMsg = 'No se halló un valor para el parámetro RelojTipoEXTNocturna para la empresa (' + cast(@codcia as varchar) + ').  Este valor debe contener el código del tipo de hora extra que se utilizará para generar horas extras nocturnas.'
    raiserror (@errorMsg, 16, 1)
    return
end

set @codthe_diurna_d = isnull(@codthe_diurna_d, @codthe_diurna)
set @codthe_nocturna_d = isnull(@codthe_nocturna_d, @codthe_nocturna)

select @factor_diurno = isnull(the_factor, 0) + isnull(the_factor_nocturnidad, 0)
  from sal.the_tipos_hora_extra 
 where the_codigo = @codthe_diurna

select @factor_nocturno = isnull(the_factor, 0) + isnull(the_factor_nocturnidad, 0)
  from sal.the_tipos_hora_extra 
 where the_codigo = @codthe_nocturna

select @factor_diurno_d = isnull(the_factor, 0) + isnull(the_factor_nocturnidad, 0)
  from sal.the_tipos_hora_extra 
 where the_codigo = @codthe_diurna_d

select @factor_nocturno_d = isnull(the_factor, 0) + isnull(the_factor_nocturnidad, 0)
  from sal.the_tipos_hora_extra 
 where the_codigo = @codthe_nocturna_d

---------------------------------------------------------------------------------------
-- CREA UNA TABLA temporal con los empleados que participan del procesamiento ---------
---------------------------------------------------------------------------------------
select plz_codcia emp_codcia, 
       emp_codigo, 
       emp_codjor, 
        --CASE WHEN emp_fecha_ultimo_cotrato IS NULL THEN EMP_FECHA_INGRESO ELSE emp_fecha_ultimo_cotrato END emp_fecha_ingreso, 
       emp_fecha_ingreso, 
       plz_coduni,
       (select top 1 cpp_codcco from eor.cpp_centros_costo_plaza c1
         where cpp_codplz = plz_codigo
           and cpp_porcentaje in (
           select max(cpp_porcentaje) cpp_porcentaje
             from eor.cpp_centros_costo_plaza c2
            where c2.cpp_codplz = c1.cpp_codplz
              and c2.cpp_codcco = c1.cpp_codcco)) emp_codcco
  into #empFiltro
  from exp.emp_empleos
  join eor.plz_plazas on plz_codigo = emp_codplz
  join sal.ppl_periodos_planilla on ppl_codigo = @codppl
  left join rel.gre_grupos_empleos on gre_codemp = emp_codigo and ppl_fecha_corte between gre_fecha_inicio and isnull(gre_fecha_fin, ppl_fecha_corte)
 where plz_codcia = @codcia
   and emp_codigo = isnull(@codemp, emp_codigo)
   and emp_codtpl = @codtpl
   and emp_estado = 'A'
   and isnull(gen.get_pb_field_data_bit(emp_property_bag_data, 'emp_marca_asistencia'), 0) = 1
   and plz_coduni = isnull(@coduni, plz_coduni)
   and case when @codgra is null then 1 
            else case when exists (
                    select null from rel.gre_grupos_empleos 
                     where gre_codemp = emp_codigo and gre_codgra = @codgra 
                       and (@fechaIni between gre_fecha_inicio and isnull(gre_fecha_fin, @fechaFin) or @fechaFin between gre_fecha_inicio and isnull(gre_fecha_fin, @fechaFin)))
                      then 1
                      else 0
                 end
       end = 1

--*
--* Tabla temporal con la asistencia teórica de los empleados
--* en el periodo especificado
--*
create table #djo (
   djo_fecha datetime,
   djo_es_feriado bit,
   djo_dia int,
   djo_codemp int,
   djo_salario_hora money,
   djo_codjor int,
   djo_horas real,
   djo_hora_del datetime,
   djo_hora_al datetime, 
   djo_hora_del_ves datetime,
   djo_hora_al_ves datetime,
   djo_rel_entrada1 datetime,
   djo_rel_salida1 datetime,
   djo_rel_entrada2 datetime,
   djo_rel_salida2 datetime,
   djo_rel_entrada3 datetime,
   djo_rel_salida3 datetime,
   djo_rel_entrada4 datetime,
   djo_rel_salida4 datetime,
   djo_num_marcas int,
   djo_esta_incapacitado bit,
   djo_esta_vacaciones bit,
   djo_tiene_tnt_manual bit,
   djo_tiene_tnt_generado bit,
   djo_tiene_tnt_autorizado bit,
   djo_es_dia_habil bit)

--*
--* Crea una tabla con la asistencia teórica basado en las jornadas
--*
exec rel.crea_asistencia_teorica @codppl, @codemp, @codgra, @coduni

--*
--* Para la generacion de horas extras los dias de feriado son dias inhabiles
--* asi que se deben generar horas extras a partir de las marcaciones en esos dias
--*
update #djo
   set djo_es_dia_habil = 0
 where djo_es_dia_habil = 1
   and djo_es_feriado = 1

--*
--* Crea una tabla temporal con los registros a procesar para la generacion
--* de horas extras en día inhabil
--*
select djo_codemp,
       djo_fecha,
       djo_salario_hora,
       djo_hora_del,
       djo_hora_al,
       djo_min_jornada,
       djo_min_comida,
       djo_rel_entrada,
       djo_rel_salida, 
       djo_dia, 
       djo_codjor,
       0 djo_min_laborados,
       0 djo_min_extras,
       0 djo_min_extras_entrada,
       0 djo_min_extras_salida,
       0 djo_min_entre_marca_2y3,
       convert(datetime, substring(convert(varchar, djo_fecha - 1, 120), 1, 10) + ' ' + @hora_nocturnidad_ini, 120) djo_nocturnidad_ini_dia_anterior,
       convert(datetime, substring(convert(varchar, djo_fecha, 120), 1, 10) + ' ' + @hora_nocturnidad_fin, 120) djo_diurno_ini,
       convert(datetime, substring(convert(varchar, djo_fecha, 120), 1, 10) + ' ' + @hora_nocturnidad_ini, 120) djo_diurno_fin,
       convert(datetime, substring(convert(varchar, djo_fecha + 1, 120), 1, 10) + ' ' + @hora_nocturnidad_fin, 120) djo_nocturnidad_fin_dia_siguiente
  into #hex
  from (
    select djo_codemp,
           djo_fecha,
           djo_salario_hora,
           djo_hora_del,
           isnull(djo_hora_al_ves, djo_hora_al) djo_hora_al,
           0 djo_min_jornada,
           0 djo_min_comida,
           djo_rel_entrada1 djo_rel_entrada,
           djo_rel_salida1 djo_rel_salida, djo_dia, djo_codjor
      from #djo
     where djo_es_dia_habil = 0
       and djo_esta_incapacitado = 0
       and djo_num_marcas in (2, 3)
    union all
    select djo_codemp,
           djo_fecha,
           djo_salario_hora,
           djo_hora_del,
           isnull(djo_hora_al_ves, djo_hora_al) djo_hora_al,
           0 djo_min_jornada,
           0 djo_min_comida,
           djo_rel_entrada1,
           djo_rel_salida1, djo_dia, djo_codjor
      from #djo
     where djo_es_dia_habil = 0
       and djo_esta_incapacitado = 0
       and djo_num_marcas in (4, 5)
    union all
    select djo_codemp,
           djo_fecha,
           djo_salario_hora,
           djo_hora_del,
           isnull(djo_hora_al_ves, djo_hora_al) djo_hora_al,
           0 djo_min_jornada,
           0 djo_min_comida,
           djo_rel_entrada2,
           djo_rel_salida2, djo_dia, djo_codjor
      from #djo
     where djo_es_dia_habil = 0
       and djo_esta_incapacitado = 0
       and djo_num_marcas in (4, 5)
       ) d1

----------------------------------------------------------
-- AQUI INICIA EL PROCESO DE GENERACION DE HORAS EXTRAS --
----------------------------------------------------------
begin transaction

select *
  into #vEXT
  from sal.ext_horas_extras
 where ext_codppl = @codppl
   and exists(select 1 from #empFiltro where emp_codigo = ext_codemp)
   and ext_generado_reloj = 1

delete from sal.ext_horas_extras
 where ext_codppl = @codppl
   and exists(select 1 from #empFiltro where emp_codigo = ext_codemp)
   and ext_generado_reloj = 1

--*
--* En esta parte del proceso se generan horas extras por las marcas encontradas
--* en días inhabiles para el empleado de acuerdo a su jornada (los dias feriados
--* se procesan como días inhabiles.
--*
--* Basicamente se tienen cuatro casos de generacion:
--*   1) Cuando las marcas se dan en el período diurno (de 6:00 a 19:00)
--*   2) Cuando las marcas se traslapan respecto del periodo diurno
--*   3) Cuando las marcas se dan en el período nocturno
--*   4) Cuando las marcas empiezan y terminan en el período nocturno
--*
--* Se hace esta diferenciacion para generar nocturnidad!
--*
insert into sal.ext_horas_extras
    (ext_codemp, ext_codthe, ext_fecha, ext_num_horas, ext_num_mins, 
     ext_factor, ext_salario_hora, ext_valor_a_pagar, ext_codmon, ext_generado_reloj, ext_generado_solicitud, 
     ext_codcco, ext_codppl, ext_aplicado_planilla, ext_planilla_autorizada, ext_ignorar_en_planilla, 
     ext_estado, ext_fecha_cambio_estado, ext_estado_workflow, ext_ingresado_portal, ext_usuario_grabacion, ext_fecha_grabacion)
select djo_codemp, djo_codthe, djo_fecha,
       case when sum(djo_min_extras) > 60 then floor(sum(djo_min_extras) / 60.0) else 0 end djo_hrs_extras,
       case when sum(djo_min_extras) > 60 then sum(djo_min_extras) - floor(sum(djo_min_extras) / 60.0) * 60.0 else sum(djo_min_extras) end djo_min_extras,
       djo_factor, djo_salario_hora,
       round(djo_salario_hora / 60.0 * djo_factor * sum(djo_min_extras), 2), 
       @codmon, 1, 0, emp_codcco, @codppl, 0, 0, 0, 
       @estado_hex_gen, getdate(), @estado_workflow_hex_gen, 0, @usuario, getdate()
  from (
    -- Obtiene el número de minutos extras cuando las marcaciones estan dentro del periodo que no es nocturnidad
    select djo_codemp,
           djo_fecha,
           @codthe_diurna_d djo_codthe, 
           @factor_diurno_d djo_factor,
           djo_salario_hora,
           djo_rel_entrada,
           djo_rel_salida,
           datediff(mi, djo_rel_entrada, djo_rel_salida) djo_min_extras
      from #hex
     where datediff(mi, djo_rel_entrada, djo_rel_salida) >= @tolerancia_min_extra
       and djo_rel_entrada between djo_diurno_ini and djo_diurno_fin
       and djo_rel_salida between djo_diurno_ini and djo_diurno_fin
    union all
    -- Obtiene el número de minutos extras cuando la hora de entrada cae en el periodo de nocturnidad
    -- y la fecha de salida no  (PARTE A FACTOR DE NOCTURNIDAD)
    select djo_codemp,
           djo_fecha,
           @codthe_nocturna_d djo_codthe, 
           @factor_nocturno_d djo_factor,
           djo_salario_hora,
           djo_rel_entrada,
           djo_diurno_ini djo_rel_salida,
           datediff(mi, djo_rel_entrada, djo_diurno_ini) djo_min_extras
      from #hex
     where datediff(mi, djo_rel_entrada, djo_diurno_ini) >= @tolerancia_min_extra
       and djo_rel_entrada between djo_nocturnidad_ini_dia_anterior and djo_diurno_ini 
       and djo_rel_salida between djo_diurno_ini and djo_diurno_fin
    union all
    -- Obtiene el número de minutos extras cuando la hora de entrada cae en el periodo de nocturnidad
    -- y la fecha de salida no (PARTA A FACTOR DIURNO)
    select djo_codemp,
           djo_fecha,
           @codthe_diurna_d djo_codthe, 
           @factor_diurno_d djo_factor,
           djo_salario_hora,
           djo_diurno_ini djo_rel_entrada,
           djo_rel_salida,
           datediff(mi, djo_diurno_ini, djo_rel_salida) djo_min_extras
      from #hex
     where datediff(mi, djo_diurno_ini, djo_rel_salida) >= @tolerancia_min_extra
       and djo_rel_entrada between djo_nocturnidad_ini_dia_anterior and djo_diurno_ini 
       and djo_rel_salida between djo_diurno_ini and djo_diurno_fin
    union all
    -- Obtiene el número de minutos extras cuando la hora de entrada esta en el periodo diurno
    -- y la fecha de salida en el periodo nocturno (PARTE A FACTOR DE NOCTURNIDAD)
    select djo_codemp,
           djo_fecha,
           @codthe_nocturna_d djo_codthe, 
           @factor_nocturno_d djo_factor,
           djo_salario_hora,
           djo_diurno_fin djo_rel_entrada,
           djo_rel_salida,
           datediff(mi, djo_diurno_fin, djo_rel_salida) djo_min_extras
      from #hex
     where datediff(mi, djo_diurno_fin, djo_rel_salida) >= @tolerancia_min_extra
       and djo_rel_entrada between djo_diurno_ini and djo_diurno_fin
       and djo_rel_salida between djo_diurno_fin and djo_nocturnidad_fin_dia_siguiente
    union all
    -- Obtiene el número de minutos extras cuando la hora de entrada esta en el periodo diurno
    -- y la fecha de salida en el periodo nocturno (PARTE A FACTOR DIURNO)
    select djo_codemp,
           djo_fecha,
           @codthe_diurna_d djo_codthe, 
           @factor_diurno_d djo_factor,
           djo_salario_hora,
           djo_rel_entrada,
           djo_diurno_fin djo_rel_salida,
           datediff(mi, djo_rel_entrada, djo_diurno_fin) djo_min_extras
      from #hex
     where datediff(mi, djo_rel_entrada, djo_diurno_fin) >= @tolerancia_min_extra
       and djo_rel_entrada between djo_diurno_ini and djo_diurno_fin
       and djo_rel_salida between djo_diurno_fin and djo_nocturnidad_fin_dia_siguiente
    union all
    -- Obtiene el número de minutos extras cuando ambas las marcaciones estan dentro del periodo de nocturnidad
    select djo_codemp,
           djo_fecha,
           @codthe_nocturna_d djo_codthe, 
           @factor_nocturno_d djo_factor,
           djo_salario_hora,
           djo_rel_entrada,
           djo_rel_salida,
           datediff(mi, djo_rel_entrada, djo_rel_salida) djo_min_extras
      from #hex
     where datediff(mi, djo_rel_entrada, djo_rel_salida) >= @tolerancia_min_extra
       and ((djo_rel_entrada between djo_nocturnidad_ini_dia_anterior and djo_diurno_ini and 
             djo_rel_salida between djo_nocturnidad_ini_dia_anterior and djo_diurno_ini) 
         or (djo_rel_entrada between djo_diurno_fin and djo_nocturnidad_fin_dia_siguiente and
             djo_rel_salida between djo_diurno_fin and djo_nocturnidad_fin_dia_siguiente))
    union all
    -- Obtiene el número de minutos extras cuando la marca de entrada es menor que el inicio del periodo
    -- diurno y la marca de salida es mayor que el periodo diurno (periodo nocturno de la marca de entrada)
    select djo_codemp,
           djo_fecha,
           @codthe_nocturna_d djo_codthe, 
           @factor_nocturno_d djo_factor,
           djo_salario_hora,
           djo_rel_entrada,
           djo_diurno_ini djo_rel_salida,
           datediff(mi, djo_rel_entrada, djo_diurno_ini) djo_min_extras
      from #hex
     where datediff(mi, djo_rel_entrada, djo_diurno_ini) >= @tolerancia_min_extra
       and djo_rel_entrada between djo_nocturnidad_ini_dia_anterior and djo_diurno_ini
       and djo_rel_salida between djo_diurno_fin and djo_nocturnidad_fin_dia_siguiente
    union all
    -- Obtiene el número de minutos extras cuando la marca de entrada es menor que el inicio del periodo
    -- diurno y la marca de salida es mayor que el periodo diurno (periodo nocturno de la marca de salida)
    select djo_codemp,
           djo_fecha,
           @codthe_nocturna_d djo_codthe, 
           @factor_nocturno_d djo_factor,
           djo_salario_hora,
           djo_diurno_fin djo_rel_entrada,
           djo_rel_salida,
           datediff(mi, djo_diurno_fin, djo_rel_salida) djo_min_extras
      from #hex
     where datediff(mi, djo_diurno_fin, djo_rel_salida) >= @tolerancia_min_extra
       and djo_rel_entrada between djo_nocturnidad_ini_dia_anterior and djo_diurno_ini
       and djo_rel_salida between djo_diurno_fin and djo_nocturnidad_fin_dia_siguiente
    union all
    -- Obtiene el número de minutos extras cuando la marca de entrada es menor que el inicio del periodo
    -- diurno y la marca de salida es mayor que el periodo diurno (periodo diurno)
    select djo_codemp,
           djo_fecha,
           @codthe_diurna_d djo_codthe, 
           @factor_diurno_d djo_factor,
           djo_salario_hora,
           djo_diurno_ini djo_rel_entrada,
           djo_diurno_fin djo_rel_salida,
           datediff(mi, djo_diurno_ini, djo_diurno_fin) djo_min_extras
      from #hex
     where datediff(mi, djo_diurno_ini, djo_diurno_fin) >= @tolerancia_min_extra
       and djo_rel_entrada between djo_nocturnidad_ini_dia_anterior and djo_diurno_ini
       and djo_rel_salida between djo_diurno_fin and djo_nocturnidad_fin_dia_siguiente
    union all
    -- Obtiene el número de minutos extras cuando la marca de entrada es menor que el inicio del periodo
    -- diurno y la marca de salida es mayor que el periodo diurno (periodo nocturno)
    select djo_codemp,
           djo_fecha,
           @codthe_nocturna_d djo_codthe, 
           @factor_nocturno_d djo_factor,
           djo_salario_hora,
           djo_rel_entrada,
           djo_rel_salida,
           datediff(mi, djo_rel_entrada, djo_diurno_ini) + datediff(mi, djo_diurno_fin, djo_rel_salida) djo_min_extras
      from #hex
     where (datediff(mi, djo_rel_entrada, djo_diurno_ini) + datediff(mi, djo_diurno_fin, djo_rel_salida)) >= @tolerancia_min_extra
       and djo_rel_entrada between djo_nocturnidad_ini_dia_anterior and djo_diurno_ini
       and djo_rel_salida between djo_diurno_fin and djo_nocturnidad_fin_dia_siguiente
       ) h1
  join #empFiltro on emp_codigo = djo_codemp
 group by djo_codemp, djo_fecha, djo_codthe, djo_factor, djo_salario_hora, emp_codcco
having sum(djo_min_extras) > 0

--*
--* Elimina los registros de la tabla temporal de horas extras
--* e inserta los registros para días hábiles, ya que el procedimiento de cálculo es diferente
--*
truncate table #hex

-- Crea la tabla temporal de nuevo, pero para dias hábiles
insert into #hex
select djo_codemp,
       djo_fecha,
       djo_salario_hora,
       djo_hora_del,
       djo_hora_al,
       djo_min_jornada,
       djo_min_comida,
       djo_rel_entrada,
       djo_rel_salida, 
       djo_dia, 
       djo_codjor,
       djo_min_laborados,
       djo_min_extras,
       djo_min_extras_entrada,
       djo_min_extras_salida,
       0 djo_min_entre_marca_2y3,
       convert(datetime, substring(convert(varchar, djo_fecha - 1, 120), 1, 10) + ' ' + @hora_nocturnidad_ini, 120) djo_nocturnidad_ini_dia_anterior,
       convert(datetime, substring(convert(varchar, djo_fecha, 120), 1, 10) + ' ' + @hora_nocturnidad_fin, 120) djo_diurno_ini,
       convert(datetime, substring(convert(varchar, djo_fecha, 120), 1, 10) + ' ' + @hora_nocturnidad_ini, 120) djo_diurno_fin,
       convert(datetime, substring(convert(varchar, djo_fecha + 1, 120), 1, 10) + ' ' + @hora_nocturnidad_fin, 120) djo_nocturnidad_fin_dia_siguiente
  from (
    select *,
           djo_min_extras_entrada + djo_min_extras_salida djo_min_extras
      from (
        select *,
               datediff(mi, djo_rel_entrada, djo_rel_salida) djo_min_laborados,
               -- Minutos laborados antes de la hora de entrada (aplican si el parametro así lo dice)
               case when datediff(mi, djo_rel_entrada, djo_hora_del) >= @tolerancia_min_extra and @genera_extras_previas_hora_entrada = 1 
                    then datediff(mi, djo_rel_entrada, djo_hora_del) 
                    else 0 
               end djo_min_extras_entrada,
               -- Minutos laborados despues de la hora de salida
               case when datediff(mi, djo_hora_al, djo_rel_salida) >= @tolerancia_min_extra 
                    then datediff(mi, djo_hora_al, djo_rel_salida) 
                    else 0 
               end djo_min_extras_salida
          from (
            select djo_codemp,
                   djo_fecha,
                   djo_dia, 
                   djo_codjor,
                   djo_salario_hora,
                   djo_hora_del,
                   isnull(djo_hora_al_ves, djo_hora_al) djo_hora_al,
                   datediff(mi, djo_hora_del, isnull(djo_hora_al_ves, djo_hora_al)) djo_min_jornada,
                   isnull(datediff(mi, djo_hora_al, isnull(djo_hora_del_ves, djo_hora_al)), 0) djo_min_comida,
                   djo_rel_entrada1 djo_rel_entrada,
                   -- Usa como hora de salida la última que encuentra en el conjunto de marcas
                   case when djo_rel_salida4 is null
                       then case when djo_rel_salida3 is null 
                                   then case when djo_rel_salida2 is null 
                                           then djo_rel_salida1 
                                           else djo_rel_salida2 
                                       end
                                   else djo_rel_salida3
                               end
                       else djo_rel_salida4
                   end djo_rel_salida
              from #djo 
             where djo_es_dia_habil = 1
               and djo_esta_incapacitado = 0
               and djo_num_marcas >= 2
               and djo_rel_entrada1 is not null
               -- and djo_num_marcas in (2, 3) -- si más de 2 marcas usa la ultima salida para generar extras al final de la jornada
               ) djo1
           ) djo2
       ) djo3
 where -- Excluye registros con minutos de trabajo extra menor o igual que cero
       djo_min_extras > 0 
       -- Solo incluye registros donde el total de minutos laborados reales es mayor que el total de minutos programados en la jornada
   and djo_min_laborados > djo_min_jornada    

--*
--* Para los registros en donde la diferencia entre la segunda y la tercera marca es diferente de cero
--* (registros con cuatro marcas) debe restar el tiempo no laborado entre esas marcas de las extras
--* de entrada o de salida
--*
update #hex
   set djo_min_extras_entrada = case when djo_min_extras_entrada + (djo_min_entre_marca_2y3 + djo_min_comida) < 0
                                     then 0
                                     else djo_min_extras_entrada + (djo_min_entre_marca_2y3 + djo_min_comida)
                                end,
       djo_min_entre_marca_2y3 = case when djo_min_extras_entrada + (djo_min_entre_marca_2y3 + djo_min_comida) < 0
                                      then djo_min_extras_entrada + (djo_min_entre_marca_2y3 + djo_min_comida)
                                      else 0
                                 end
 where djo_min_entre_marca_2y3 <> 0

-- Corrige la salida cuando aun queda tiempo por descontar del tiempo entre la segunda y tercera marca
update #hex
   set djo_min_extras_salida = djo_min_extras_salida + djo_min_entre_marca_2y3,
       djo_min_entre_marca_2y3 = 0
 where djo_min_entre_marca_2y3 <> 0

-- Corrige los minutos extras de salida cuando los minutos extras a la entrada son negativos
update #hex
   set djo_min_extras_salida = djo_min_extras_salida + djo_min_extras_entrada,
       djo_min_extras_entrada = 0
 where djo_min_entre_marca_2y3 = 0
   and djo_min_extras_entrada < 0

-- Corrige los minutos extras de entrada cuando los minutos extras a la salida son negativos
update #hex
   set djo_min_extras_entrada = djo_min_extras_entrada + djo_min_extras_salida,
       djo_min_extras_salida = 0
 where djo_min_entre_marca_2y3 = 0
   and djo_min_extras_salida < 0

-- Corrige la hora de entrada y salida, de acuerdo a los minutos extras laborados, luego de los ajustes
update #hex
   set djo_rel_entrada = dateadd(mi, -1 * djo_min_extras_entrada, djo_hora_del),
       djo_rel_salida = dateadd(mi, djo_min_extras_salida, djo_hora_al)

--*
--* En esta parte del proceso se generan horas extras por las marcas encontradas
--* en días hábiles para el empleado de acuerdo a su jornada.  El proceso busca asistencia
--* que genera tiempo extra, respecto de la asistencia teórica del empleado.
--*
--* Basicamente se tienen tres casos de generacion:
--*   1) Cuando el tiempo extra se dan en el período diurno (de 6:00 a 19:00)
--*   2) Cuando el tiempo extra se dan en el período nocturno
--*   3) Cuando el tiempo extra se traslapa respecto del periodo diurno
--*
--* Se hace esta diferenciacion para generar nocturnidad!
--*
insert into sal.ext_horas_extras
    (ext_codemp, ext_codthe, ext_fecha, ext_num_horas, ext_num_mins, 
     ext_factor, ext_salario_hora, ext_valor_a_pagar, ext_codmon, ext_generado_reloj, ext_generado_solicitud, 
     ext_codcco, ext_codppl, ext_aplicado_planilla, ext_planilla_autorizada, ext_ignorar_en_planilla, 
     ext_estado, ext_fecha_cambio_estado, ext_estado_workflow, ext_ingresado_portal, ext_usuario_grabacion, ext_fecha_grabacion)
select djo_codemp, djo_codthe, djo_fecha,
       case when sum(djo_min_extras) > 60 then floor(sum(djo_min_extras) / 60.0) else 0 end djo_hrs_extras,
       case when sum(djo_min_extras) > 60 then sum(djo_min_extras) - floor(sum(djo_min_extras) / 60.0) * 60.0 else sum(djo_min_extras) end djo_min_extras,
       djo_factor, djo_salario_hora,
       round(djo_salario_hora / 60.0 * djo_factor * sum(djo_min_extras), 2), 
       @codmon, 1, 0, emp_codcco, @codppl, 0, 0, 0, 
       @estado_hex_gen, getdate(), @estado_workflow_hex_gen, 0, @usuario, getdate()
  from (
    -- Procesa horas extras por entrada anterior a la fecha de entrada de la jornada (para extras DIURNAS)
    select *,
           @codthe_diurna djo_codthe, 
           @factor_diurno djo_factor,
           djo_min_extras_entrada djo_extras
      from #hex
     where djo_min_extras_entrada > 0
       and djo_rel_entrada >= djo_diurno_ini
    union all
    -- Procesa horas extras por entrada anterior a la fecha de entrada de la jornada (para extras DIURNAS)
    -- cuando la entrada es anterior al fin de la nocturnidad
    select *,
           @codthe_diurna djo_codthe, 
           @factor_diurno djo_factor,
           datediff(mi, djo_diurno_ini, djo_hora_del) djo_extras
      from #hex
     where djo_min_extras_entrada > 0
       and djo_rel_entrada < djo_diurno_ini
    union all
    -- Procesa horas extras por entrada anterior a la fecha de entrada de la jornada (para extras NOCTURNAS)
    -- cuando la entrada es anterior al fin de la nocturnidad
    select *,
           @codthe_nocturna djo_codthe, 
           @factor_nocturno djo_factor,
           datediff(mi, djo_rel_entrada, djo_diurno_ini) djo_extras
      from #hex
     where djo_min_extras_entrada > 0
       and djo_rel_entrada < djo_diurno_ini
    union all
    -- Procesa horas extras por salida posterior a la fecha de salida de la jornada (para extras DIURNAS)
    select *,
           @codthe_diurna djo_codthe, 
           @factor_diurno djo_factor,
           djo_min_extras_salida djo_extras
      from #hex
     where djo_min_extras_salida > 0
       and djo_rel_salida <= djo_diurno_fin
    union all
    -- Procesa horas extras por salida posterior a la fecha de salida de la jornada (para extras DIURNAS)
    -- cuando la salida es posterior al inicio de la nocturnidad (hay mixtas diurnas y nocturnas)
    select *,
           @codthe_diurna djo_codthe, 
           @factor_diurno djo_factor,
           datediff(mi, djo_hora_al, djo_diurno_fin) djo_extras
      from #hex
     where djo_min_extras_salida > 0
       and djo_rel_salida > djo_diurno_fin
       and djo_hora_al <= djo_diurno_fin 
    union all
    -- Procesa horas extras por salida posterior a la fecha de salida de la jornada (para extras NOCTURNAS)
    -- cuando la salida es posterior al inicio de la nocturnidad (hay mixtas diurnas y nocturnas)
    select *,
           @codthe_nocturna djo_codthe, 
           @factor_nocturno djo_factor,
           datediff(mi, djo_diurno_fin, djo_rel_salida) djo_extras
      from #hex
     where djo_min_extras_salida > 0
       and djo_rel_salida > djo_diurno_fin
       and djo_hora_al <= djo_diurno_fin 
    union all
    -- Procesa horas extras por salida posterior a la fecha de salida de la jornada (para extras NOCTURNAS)
    -- cuando la salida es posterior al inicio de la nocturnidad (todas las que se dan en la noche)
    select *,
           @codthe_nocturna djo_codthe, 
           @factor_nocturno djo_factor,
           datediff(mi, djo_hora_al, djo_rel_salida) djo_extras
      from #hex
     where djo_min_extras_salida > 0
       and djo_rel_salida > djo_diurno_fin
       and djo_hora_al > djo_diurno_fin 
       ) h1
  join #empFiltro on emp_codigo = djo_codemp
 group by djo_codemp, djo_fecha, djo_codthe, djo_factor, djo_salario_hora, djo_codjor, djo_dia, emp_codcco
having sum(djo_extras) > 0

--*
--* Ahora regresa el estado de las EXTRAS al que tenia, antes de hacer
--* el delete de la tabla (de acuerdo a la tabla temporal)
--*
update sal.ext_horas_extras
   set ext_estado = e2.ext_estado,
       ext_num_horas = e2.ext_num_horas,
       ext_num_mins = e2.ext_num_mins,
       ext_valor_a_pagar = e2.ext_valor_a_pagar,
       ext_codmon = e2.ext_codmon,
       ext_codcco = e2.ext_codcco
  from sal.ext_horas_extras e1
  join #vEXT e2
         on e1.ext_codemp = e2.ext_codemp
        and e1.ext_codthe = e2.ext_codthe
        and e1.ext_fecha = e2.ext_fecha
        and e1.ext_codppl = e2.ext_codppl
        and e1.ext_generado_reloj = e2.ext_generado_reloj
 where e1.ext_codppl = @codppl
   and exists(select 1 from #empFiltro where emp_codigo = e1.ext_codemp)
   and e1.ext_generado_reloj = 1

/*
select *
  from sal.ext_horas_extras
 where ext_codppl = @codppl
   and exists(select 1 from #empFiltro where emp_codigo = ext_codemp)
   and ext_generado_reloj = 1
*/

-- Finaliza
commit transaction
--rollback transaction

IF OBJECT_ID('tempdb..#empFiltro') IS NOT NULL drop table #empFiltro
IF OBJECT_ID('tempdb..#hex') IS NOT NULL drop table #hex
IF OBJECT_ID('tempdb..#djo') IS NOT NULL drop table #djo
return
GO
