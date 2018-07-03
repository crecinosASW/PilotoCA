IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('rel.procesa_marcas'))
BEGIN
	DROP PROCEDURE rel.procesa_marcas
END

GO

/*
   Proceso de interpretación de marcas de reloj
   --------------------------------------------

   Creado por: Fernando Paz
               3-Abr-2014

   La forma de importación de marcas de reloj en el módulo de Control de Asistencia de Evolution
   o la ejecución de la plantilla de importación con EvoImport.Exe, permite que las marcaciones
   existentes en un archivo texto se carguen a la tabla de marcas rel.mar_marcas.
   
   Una vez están allí, este proceso las interpreta de acuerdo a las políticas implementadas y a 
   la asistencia teórica de los empleados a través de su asociación a jornadas laborales.

   Al terminar la ejecución el proceso marca los registros como Procesados o no Procesados
   y llena la tabla rel.asi_asistencias con la interpretacion realizada para que el proceso
   de generación de tiempos no trabajados y horas extras pueda ser ejecutado.

   Si el parametro codigo de empleado no es nulo, entonces ejecuta para el empleado seleccionado
   Si el paraemtro codigo de grupo no es nulo, entonces ejecuta para los empleados del grupo seleccionado
   Si el parametro codigo de unidad no es nulo, entonces ejecuta para los empleados de la unidad seleccionada

   Ejemplo de ejecución:  *****  Los parametros cambiaron ya que se solicita los codigos visuales  Ferdy *****

      exec rel.procesa_marcas @codcia = 1, @codtpl = 1, @f_Ini = '31/01/2011', @f_Fin = '01/02/2011', @codemp = 29
      exec rel.procesa_marcas @codppl = 201102, @codemp = 28
*/
--exec rel.procesa_marcas 1, '4', '20150603', '2933', null, null, 'admin'
CREATE PROCEDURE rel.procesa_marcas (
    @codcia INT = NULL,
	@codtpl_visual VARCHAR(3) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@codexp_alternativo VARCHAR(36) = null,
	@codgra int = null,
	@coduni int = null,
	@usuario varchar(100) = null
)

as

--declare @f_Ini VARCHAR(10), @f_Fin VARCHAR(10),  @codemp int, @codgra int, @coduni INT, @codtpl INT, @codppl INT
--select @codtpl = 1, @f_Ini = '28/02/2011', @f_Fin = '01/03/2011',  @codemp = NULL, @codgra = null, @coduni = null
--select @codppl = 4--,  @codemp = 28

set nocount on
set datefirst 7
SET DATEFORMAT DMY
DECLARE	@fIni DATETIME, 
		@fFin DATETIME, 
		@msg varchar(max),
		@codtpl INT,
		@codppl INT,
		@codemp INT
		
set @usuario = isnull(@usuario, SYSTEM_USER)
select @codtpl = tpl_codigo
  from sal.tpl_tipo_planilla
 where tpl_codcia = @codcia 
   and tpl_codigo_visual = @codtpl_visual

select @codppl = ppl_codigo 
  from sal.ppl_periodos_planilla
 where ppl_codtpl = @codtpl 
   and ppl_codigo_planilla = @codppl_visual

--*
--* Valida los parámetros recibidos
--*
if @codppl is not null begin
    if not exists (select null from sal.ppl_periodos_planilla where ppl_codigo = @codppl) begin
		set @msg = 'El código del período de planilla ('+cast(@codppl as varchar)+') especificado no existe en la base de datos.'
        RAISERROR (@msg, 16, 1)
        return
    end

    --*
    --* Obtiene las fechas de inicio y finalizacion del periodo de la planilla
    --* y el codigo de empresa y tipo de planilla del periodo que fue especificado
    --*
    select @codcia = tpl_codcia, 
           @codtpl = tpl_codigo,
           @fIni = ppl_fecha_ini, 
           @fFin = ppl_fecha_fin
      from sal.ppl_periodos_planilla
      join sal.tpl_tipo_planilla on tpl_codigo = ppl_codtpl
     where ppl_codigo = @codppl
     
     
end
else begin
    if @codtpl is null begin
		set @msg = 'Si no se especifica el código del período de planilla, entonces es requerido el código de tipo de planilla'
        RAISERROR (@msg, 16, 1)
        return
    end

    select @codcia = tpl_codcia,
           @codppl = ppl_codigo 
      from sal.ppl_periodos_planilla 
      join sal.tpl_tipo_planilla on tpl_codigo = ppl_codtpl
     where tpl_codigo = @codtpl
       and (@fIni between ppl_fecha_ini and ppl_fecha_fin 
            or @fFin between ppl_fecha_ini and ppl_fecha_fin)
end

if @codexp_alternativo is not null
begin
	set @codemp = gen.obtiene_codigo_empleo(@codexp_alternativo)

	if @codemp is null
	begin
		set @msg = 'El código del empleado enviado no existe'
        RAISERROR (@msg, 16, 1)
        return		
	end
end

--*
--* Parametros del Reloj
--*
declare @MarcaOk varchar(20),
        @MarcaFailed varchar(20),
        @MarcaNotProcessed varchar(20),
        @MinutosEntreMarcasIguales real,
        @dias_offset int, 
        @estado_asi_gen varchar(20),
        @estado_workflow_asi_gen varchar(20),
        @saveError int,
        @ts datetime, 
        @ts_total DATETIME

set @saveError = 0
set @ts = getdate()
set @ts_total = @ts

set @MinutosEntreMarcasIguales = gen.get_valor_parametro_int('RelojMinutosEntreMarcasIguales', null, null, @codcia, null)
set @MarcaOk = gen.get_valor_parametro_varchar('RelojTipoMarcaProcesada', null, null, @codcia, null)
set @MarcaFailed = gen.get_valor_parametro_varchar('RelojTipoMarcaFallida', null, null, @codcia, null)
set @MarcaNotProcessed = gen.get_valor_parametro_varchar('RelojTipoMarcaNoProcesada', null, null, @codcia, null)
set @dias_offset = gen.get_valor_parametro_int('RelojDiasDesplazamientoCortePlanilla', null, null, @codcia, null)
set @estado_asi_gen = gen.get_valor_parametro_varchar('RelojEstadoAsistenciaGenerada', null, null, @codcia, null)
set @estado_workflow_asi_gen = gen.get_valor_parametro_varchar('RelojEstadoWorkflowAsistenciaGenerada', null, null, @codcia, null)

-- Inicializa los parametros que retornan NULL con valores por defecto
set @MinutosEntreMarcasIguales = isnull(@MinutosEntreMarcasIguales, 30)
set @MarcaOk = isnull(@MarcaOk, 'Procesada')
set @MarcaFailed = isnull(@MarcaFailed, 'Fallida')
set @MarcaNotProcessed = isnull(@MarcaNotProcessed, 'No Procesada')
set @dias_offset = abs(isnull(@dias_offset, 0))
set @estado_asi_gen = isnull(@estado_asi_gen, 'Pendiente')
set @estado_workflow_asi_gen = isnull(@estado_workflow_asi_gen, 'Pendiente')

--*
--* Incrementa en uno la fecha fin, para que el proceso tome marcas del dia siguiente
--* de la fecha de finalizacion del proceso.
--* De esta manera se resuelve el problema de la interpretación de la marca de salida
--* para turnos nocturnos o para extras que se pasan al siguiente dia
--*

IF isnull((select tpl_asi_rango_fechas_ingreso
      from sal.tpl_tipo_planilla where tpl_codigo = @codtpl),' ') = 'PeriodoAnterior'
BEGIN
SELECT 
  @FINI = ppl_fecha_ini,
  @FFIN = ppl_fecha_fin
  from sal.ppl_periodos_planilla
 where ppl_codtpl=@codtpl 
   and ppl_fecha_fin = (select dateadd(dd,-1,ppl_fecha_ini)
                          from sal.ppl_periodos_planilla
                         where ppl_codigo = @codppl)

END

SET @fIni = @fIni - 1
set @fFin = @fFin + 1

--*
--* Actualiza las marcas cen el rango especificado como PROCESADAS
--*
update rel.mar_marcas set mar_estado = @MarcaOk
 where mar_fecha between @fIni and @fFin
   and mar_codemp = isnull(@codemp,mar_codemp)

set @ts = getdate()
---------------------------------------------------------------------------------------
-- CREA UNA TABLA temporal con los empleados que participan del procesamiento ---------
---------------------------------------------------------------------------------------
select plz_codcia emp_codcia, 
       emp_codigo, 
       emp_codjor, 
        --CASE WHEN emp_fecha_ultimo_cotrato IS NULL THEN EMP_FECHA_INGRESO ELSE emp_fecha_ultimo_cotrato END emp_fecha_ingreso, 
       emp_fecha_ingreso, 
       plz_coduni
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
                       and (@fIni between gre_fecha_inicio and isnull(gre_fecha_fin, @fFin) or @fFin between gre_fecha_inicio and isnull(gre_fecha_fin, @fFin)))
                      then 1
                      else 0
                 end
       end = 1

--select * from #empFiltro

--print 'Creo Tabla Temporal Empleados que participan (' + cast(datediff(ms, @ts, getdate()) as varchar) + ' ms)'

---------------------------------------------------------------------------------------
-- CREA UNA TABLA con las marcaciones teóricas de los empleados basado en su jornada --
---------------------------------------------------------------------------------------
set @ts = getdate()

--*
--* Tabla temporal con la asistencia teórica de los empleados
--* en el periodo especificado
--*
create table #djo (
   djo_fecha datetime,
   djo_dia int,
   djo_codemp int,
   djo_codjor int,
   djo_tipo_dia char(1),
   djo_horas real,
   djo_hora_del datetime,
   djo_hora_al datetime, 
   djo_hora_del_ves datetime,
   djo_hora_al_ves datetime,
   djo_rel_entrada datetime,
   djo_rel_salida datetime,
   djo_rel_marca1 datetime,
   djo_rel_marca2 datetime,
   djo_rel_marca3 datetime,
   djo_rel_marca4 datetime)

--*
--* Inserta una tabla con las jornadas vigentes para el periodo de cada empleado
/*
Proceso:
	- Recorre cada uno de los empleados
	- Para cada empleado recorre los días de la fecha de inicio hasta la fecha de final
	- Para cada día obtiene la jornada asignada para ese día y la fecha de inicio y fin de jornada
*/
--* Corrige las fechas para determinar las marcas de salida del siguiente dia (para turnos nocturnos)
--*
insert into #djo
select djo_fecha,
       djo_dia,
       djo_codemp,
       djo_codjor,
       case when djo_hora_del is null or djo_total_horas = 0 then 'D' else 'H' end,
       djo_total_horas,
       djo_hora_del,
       case when djo_hora_al < djo_hora_del
            then dateadd(day, 1, djo_hora_al)
            else djo_hora_al
       end djo_hora_al,
       case when djo_hora_del_ves < djo_hora_del
            then dateadd(day, 1, djo_hora_del_ves)
            else djo_hora_del_ves
       end djo_hora_del_ves,
       case when djo_hora_al_ves < djo_hora_del
            then dateadd(day, 1, djo_hora_al_ves)
            else djo_hora_al_ves
       end djo_hora_al_ves,
       null, null, null, null, null, null
  from (
        select fecha djo_fecha,
               isnull(djo_dia, datepart(dw, fecha)-1) + 1 djo_dia,
               codemp djo_codemp,
               isnull(jpe_codjor, isnull(jpg_codjor, isnull(jpu_codjor, emp_codjor))) djo_codjor,
               isnull(djo_total_horas, 8) djo_total_horas,
               convert(datetime, substring(convert(varchar, fecha, 120), 1, 10) + ' ' + convert(varchar, djo_hora_ini, 108), 120) DJO_HORA_DEL, 
               convert(datetime, substring(convert(varchar, fecha, 120), 1, 10) + ' ' + convert(varchar, djo_hora_comida_ini, 108), 120) DJO_HORA_AL, 
               convert(datetime, substring(convert(varchar, fecha, 120), 1, 10) + ' ' + convert(varchar, djo_hora_comida_fin, 108), 120) DJO_HORA_DEL_VES, 
               convert(datetime, substring(convert(varchar, fecha, 120), 1, 10) + ' ' + convert(varchar, djo_hora_fin, 108), 120) DJO_HORA_AL_VES
          from (
                select fecha,
                       emp_codigo codemp,
                       gre_codgra codgra,
                       emp_codjor,
                       jpe_codjor,
                       case when gre_codgra is null then null else jpg_codjor end jpg_codjor,
                       jpu_codjor
                  from (
                    select (@fIni + colorder) fecha, emp_codigo, emp_codjor, plz_coduni, colorder
                      from #empFiltro
                      join (select number colorder from master..spt_values where type = 'P') c
                           on (@fIni + colorder) <= @fFin and (@fIni  + colorder) between emp_fecha_ingreso and @fFin
                       ) x
                  left join rel.jpe_jornadas_empleos on jpe_codemp = emp_codigo and (@fIni + colorder) = jpe_fecha
                  left join rel.jpu_jornadas_unidades on jpu_coduni = plz_coduni and (@fIni + colorder) = jpu_fecha
                  left join rel.gre_grupos_empleos on gre_codemp = emp_codigo and (@fIni + colorder) between gre_fecha_inicio and isnull(gre_fecha_fin, (@fIni + colorder))
                  left join rel.jpg_jornadas_grupos on jpg_codgra = gre_codgra and jpg_fecha = (@fIni + colorder)
               ) djo1
          left join sal.djo_dias_jornada on 
                            (djo_codjor = isnull(jpe_codjor, isnull(jpg_codjor, isnull(jpu_codjor, emp_codjor))) and (djo_dia between 0 and 6 and datepart(dw, fecha)-1 = djo_dia))
                            or (djo_codjor = isnull(jpe_codjor, isnull(jpg_codjor, jpu_codjor)) and (djo_dia = 8 and djo_total_horas > 0))
                            or (djo_codjor = isnull(jpe_codjor, isnull(jpg_codjor, jpu_codjor)) and (djo_dia = 9 and djo_total_horas = 0))
       ) djo2


--select * from #djo

--print 'Creo Tabla Temporal de Asistencia Teórica (' + cast(datediff(ms, @ts, getdate()) as varchar) + ' ms)'
--*
--* Inicializa un horario teórico para los dias de descanso
--* utilizando la máxima jornada del período
--*
update #djo
   set djo_hora_del = convert(datetime, substring(convert(varchar, djo_fecha, 120), 1, 10) + ' ' + convert(varchar, hora_del, 108), 120),
       djo_hora_al = case when convert(varchar, hora_al, 103) <> convert(varchar, hora_del, 103)
                          then 
                              convert(datetime, substring(convert(varchar, djo_fecha + 1, 120), 1, 10) + ' ' + convert(varchar, hora_al, 108), 120)
                          else
                              convert(datetime, substring(convert(varchar, djo_fecha, 120), 1, 10) + ' ' + convert(varchar, hora_al, 108), 120)
                     end,
       djo_hora_del_ves = case when convert(varchar, hora_del_ves, 103) <> convert(varchar, hora_del, 103)
                               then 
                                   convert(datetime, substring(convert(varchar, djo_fecha + 1, 120), 1, 10) + ' ' + convert(varchar, hora_del_ves, 108), 120)
                               else
                                   convert(datetime, substring(convert(varchar, djo_fecha, 120), 1, 10) + ' ' + convert(varchar, hora_del_ves, 108), 120)
                          end,
       djo_hora_al_ves = case when convert(varchar, hora_al_ves, 103) <> convert(varchar, hora_del, 103)
                              then 
                                  convert(datetime, substring(convert(varchar, djo_fecha + 1, 120), 1, 10) + ' ' + convert(varchar, hora_al_ves, 108), 120)
                              else
                                  convert(datetime, substring(convert(varchar, djo_fecha, 120), 1, 10) + ' ' + convert(varchar, hora_al_ves, 108), 120)
                         end,
       djo_horas = horas
  from #djo
  join (
      select distinct codemp,
             djo_hora_del hora_del,
             djo_hora_al hora_al,
             djo_hora_del_ves hora_del_ves,
             djo_hora_al_ves hora_al_ves,
             horas
        from (
            select djo_codemp codemp, max(djo_horas) horas
              from #djo
             where djo_tipo_dia = 'H'
             group by djo_codemp
             ) j1
        join #djo on djo_codemp = codemp and djo_horas = horas
       ) j2 on djo_codemp = codemp
 where djo_tipo_dia = 'D'


--print 'Actualiza horario de jornadas de dias de descanso en Asistencia Teórica (' + cast(datediff(ms, @ts, getdate()) as varchar) + ' ms)'

---------------------------------------------------------------------------------
-- Preparación de los registros de marcas a ser procesados ----------------------
---------------------------------------------------------------------------------
--*
--* Prepara la tabla de marcas para ser procesada
--*
declare @mar_codemp int, 
        @mar_fecha_hora datetime,
        @mar_prev_codemp int,
        @mar_prev_fecha_hora datetime

set @mar_prev_codemp = 0

-- Marca con tipo = 0 las marcas que va a ignorar
-- basado en la politica sobre la minima diferencia entre dos marcas (en minutos)
declare curMarcas cursor read_only forward_only for
 select mar_codemp, mar_fecha_hora from rel.mar_marcas
  where mar_fecha between @fIni and @fFin 
    and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
  order by mar_codemp, mar_fecha_hora
open curMarcas
while 1 = 1
begin
   fetch next from curMarcas into @mar_codemp, @mar_fecha_hora
   if @@fetch_status <> 0 break

   if @mar_prev_codemp <> @mar_codemp begin
      set @mar_prev_codemp = @mar_codemp 
      set @mar_prev_fecha_hora = dateadd(day, -1, @fIni)
   end
   
   --print '   ' + cast(@mar_codemp as varchar) + ' - ' + cast(@mar_prev_codemp as varchar) + ' : ' + cast(@mar_fecha_hora as varchar)

   if datediff(mi, @mar_prev_fecha_hora, @mar_fecha_hora) < @MinutosEntreMarcasIguales
   begin
      update rel.mar_marcas
         set mar_estado = @MarcaFailed
       where mar_codemp = @mar_codemp and mar_fecha_hora = @mar_fecha_hora

     --print '   ' + cast(@mar_codemp as varchar) + ' - ' + ' - ' + cast(@mar_prev_fecha_hora as varchar) + ' - ' + cast(@mar_fecha_hora as varchar)
   end

   set @mar_prev_fecha_hora = @mar_fecha_hora
end
close curMarcas
deallocate curMarcas

--select * from rel.mar_marcas
-- where mar_codemp = @codemp and mar_fecha between @fini and @ffin 
-- order by 3

/*
Marca como no procesadas las marcas incompletas
*/
update rel.mar_marcas
   set mar_estado = @MarcaNotProcessed
 where mar_fecha between @fIni and @fFin
   and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
   and exists (select 1 from #djo
               where mar_codemp = djo_codemp 
				and (djo_rel_entrada = mar_fecha_hora or djo_rel_salida = mar_fecha_hora)
                and (djo_rel_entrada is null or djo_rel_salida is null))

-----------------------------------------------------------------------------------
-- INICIA el proceso de interpretacion de marcas --------------------------------
---------------------------------------------------------------------------------

--*
--* Actualiza la menor marca de cada día para ponerla como fecha de entrada
--* en la tabla temporal de asistencia teórica
--*

update #djo
   set djo_rel_entrada = mar_fecha_hora
  from #djo
  join (
      select mar_codemp,
             mar_fecha,
             mar_fecha_hora
        from rel.mar_marcas
        join (
             select djo_codemp,
                    djo_fecha,
                    djo_hora_del,
                    min(djo_delta_e) djo_delta_e
               from (
                    select djo_codemp,
                           djo_fecha,
                           djo_hora_del,
                           mar_fecha_hora,
                           (abs(datediff(ss, mar_fecha_hora, djo_hora_del)) / 60.0 / 60.0) djo_delta_e
                      from #djo j1
                      join rel.mar_marcas on djo_codemp = mar_codemp
                                 and convert(varchar, mar_fecha, 103) = convert(varchar, djo_hora_del, 103)
                     where mar_estado = @MarcaOk
                       and mar_fecha between @fIni and @fFin
                       and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
                       and djo_tipo_dia = 'H'                       
                       --and (abs(datediff(ss, mar_fecha_hora, djo_hora_del)) / 60.0 / 60.0) < 
                       --     case when convert(varchar, mar_fecha, 103) <> convert(varchar, isnull(djo_hora_al_ves, djo_hora_al), 103)
                       --             then
                       --                 (abs(datediff(ss, mar_fecha_hora + 1, isnull(djo_hora_al_ves, djo_hora_al))) / 60.0 / 60.0)
                       --             else
                       --                 (abs(datediff(ss, mar_fecha_hora, isnull(djo_hora_al_ves, djo_hora_al))) / 60.0 / 60.0)
                       --     end  Ferdy
                    ) m1
              group by djo_codemp,
                       djo_fecha,
                       djo_hora_del
             ) m2 on mar_codemp = djo_codemp and mar_fecha = djo_fecha
                 and (abs(datediff(ss, mar_fecha_hora, djo_hora_del)) / 60.0 / 60.0) = djo_delta_e
       ) m3 on djo_codemp = mar_codemp and djo_fecha = mar_fecha

--select * from #djo
--where convert(varchar,djo_fecha,103) = '20/05/2014'

--*
--* Actualiza la mayor marca de cada día para ponerla como fecha de salida
--* en a la tabla temporal de asistencia teórica
--*
update #djo
   set djo_rel_salida = mar_fecha_hora
  from #djo
  join (
      select mar_codemp,
             mar_fecha,
             mar_fecha_hora
        from rel.mar_marcas
        join (
             select djo_codemp,
                    djo_fecha,
                    djo_hora_al,
                    min(delta_s) djo_delta_s
               from (
                    select djo_codemp,
                           djo_fecha,
                           isnull(djo_hora_al_ves, djo_hora_al) djo_hora_al,
                           mar_fecha_hora,
                           (abs(datediff(ss, mar_fecha_hora, isnull(djo_hora_al_ves, djo_hora_al))) / 60.0 / 60.0) delta_s
                      from #djo j1
                      join rel.mar_marcas on djo_codemp = mar_codemp
                                 and convert(varchar, mar_fecha, 103) = convert(varchar, isnull(isnull(djo_hora_al_ves, djo_hora_al), getdate()), 103)
                     where mar_estado = @MarcaOk
                       and mar_fecha between @fIni and @fFin
                       and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
                       and djo_tipo_dia = 'H'
                       and (abs(datediff(ss, mar_fecha_hora, isnull(djo_hora_al_ves, djo_hora_al))) / 60.0 / 60.0) <
                            case when convert(varchar, djo_hora_del, 103) <> convert(varchar, mar_fecha, 103)
                                    then
                                        (abs(datediff(ss, mar_fecha_hora-1, djo_hora_del)) / 60.0 / 60.0)
                                    else
                                        (abs(datediff(ss, mar_fecha_hora, djo_hora_del)) / 60.0 / 60.0)
                            end
                       and not exists (select 1 from #djo j2
                                        where j1.djo_codemp = j2.djo_codemp
                                          and mar_fecha_hora = isnull(j2.djo_rel_entrada, getdate()))
                    ) m1
              group by djo_codemp,
                       djo_fecha,
                       djo_hora_al
             ) m2 on mar_codemp = djo_codemp and mar_fecha = djo_fecha
                 and  (abs(datediff(ss, mar_fecha_hora, djo_hora_al)) / 60.0 / 60.0) = djo_delta_s         
       ) m3 on djo_codemp = mar_codemp and djo_fecha = mar_fecha
--select * from #djo
--where convert(varchar,djo_fecha,103) = '20/05/2014'
--*
--* Encuentra marcas que no coinciden con la hora de entrada pero que son menores que la fecha de
--* salida y la hora de entrada es nula
--* 
update #djo
   set djo_rel_entrada = mar_fecha_hora
  from #djo
  join (
        select mar_codemp, mar_fecha, mar_fecha_hora
        from rel.mar_marcas
        join #djo on djo_codemp = mar_codemp and djo_fecha = mar_fecha
                 and djo_rel_entrada is null
                 and not djo_rel_salida is null
                 and mar_fecha_hora < djo_rel_salida
       where mar_estado = @MarcaOk
         and mar_fecha between @fIni and @fFin
         and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
         and djo_tipo_dia = 'H'
       ) m3 on djo_codemp = mar_codemp and djo_fecha = mar_fecha


--* Actualiza marcas como fechas de salida, cuando la marca es del dia siguiente
--* y el dia siguiente es un dia inhabil
--* y la hora de la marca es menor que la fecha de entrada teórica en el día de descanso
--*
update #djo
   set djo_rel_salida = mar_fecha_hora
  from #djo
  join (
        select mar_codemp,
               dateadd(day, -1, mar_fecha) mar_fecha,
               MAX(mar_fecha_hora) mar_fecha_hora
          from rel.mar_marcas
          join #djo on mar_codemp = djo_codemp
                   and mar_fecha = djo_fecha
                   and mar_fecha_hora < djo_hora_del
       where mar_estado = @MarcaOk
         and mar_fecha between @fIni and @fFin
         and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
         and not exists (select 1 from #djo j2
                          where mar_codemp = j2.djo_codemp
                            and (mar_fecha_hora = isnull(j2.djo_rel_entrada, getdate()) or
                                 mar_fecha_hora = isnull(j2.djo_rel_salida, getdate())))
          AND MAR_FECHA_HORA < DATEADD(hh, -1, djo_hora_del)
       GROUP BY MAR_CODEMP, MAR_FECHA
       ) m1 on djo_codemp = mar_codemp and djo_fecha = mar_fecha
 where not djo_rel_entrada is null
   and djo_rel_salida is null
--select * from #djo
--where convert(varchar,djo_fecha,103) = '20/05/2014'


--*
--* Actualiza la menor marca de cada día para ponerla como fecha de entrada
--* en DIAS INHABILES de acuerdo a la tabla temporal de asistencia teórica
--*
update #djo
   set djo_rel_entrada = mar_fecha_hora
  from #djo
  join (
      select mar_codemp,
             mar_fecha,
             mar_fecha_hora
        from rel.mar_marcas
        join (
             select djo_codemp,
                    djo_fecha,
                    djo_hora_del,
                    min(djo_delta_e) djo_delta_e
               from (
                    select djo_codemp,
                           djo_fecha,
                           djo_hora_del,
                           mar_fecha_hora,
                           (abs(datediff(ss, mar_fecha_hora, djo_hora_del)) / 60.0 / 60.0) djo_delta_e
                      from #djo j1
                      join rel.mar_marcas on djo_codemp = mar_codemp
                                 and convert(varchar, mar_fecha, 103) = convert(varchar, djo_hora_del, 103)
                     where mar_estado = @MarcaOk
                       and mar_fecha between @fIni and @fFin
                       and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
                       and djo_tipo_dia = 'D'
                       and (abs(datediff(ss, mar_fecha_hora, djo_hora_del)) / 60.0 / 60.0) < 
                            case when convert(varchar, mar_fecha, 103) <> convert(varchar, isnull(djo_hora_al_ves, djo_hora_al), 103)
                                    then
                                        (abs(datediff(ss, mar_fecha_hora + 1, isnull(djo_hora_al_ves, djo_hora_al))) / 60.0 / 60.0)
                                    else
                                        (abs(datediff(ss, mar_fecha_hora, isnull(djo_hora_al_ves, djo_hora_al))) / 60.0 / 60.0)
                            end
                       --and not exists (select 1 from #djo j2
                       --                 where mar_codemp = j2.djo_codemp
                       --                   and (mar_fecha_hora = isnull(j2.djo_rel_entrada, getdate()) or
                       --                        mar_fecha_hora = isnull(j2.djo_rel_salida, getdate())))
                    ) m1
              group by djo_codemp,
                       djo_fecha,
                       djo_hora_del
             ) m2 on mar_codemp = djo_codemp and mar_fecha = djo_fecha
                 and (abs(datediff(ss, mar_fecha_hora, djo_hora_del)) / 60.0 / 60.0) = djo_delta_e
       ) m3 on djo_codemp = mar_codemp and djo_fecha = mar_fecha


--*
--* Actualiza la mayor marca de cada día para ponerla como fecha de salida
--* en DIAS INHABILES de acuerdo a la tabla temporal de asistencia teórica
--*
update #djo
   set djo_rel_salida = mar_fecha_hora
  from #djo
  join (
      select mar_codemp,
             mar_fecha,
             mar_fecha_hora
        from rel.mar_marcas
        join (
             select djo_codemp,
                    djo_fecha,
                    djo_hora_al,
                    min(delta_s) djo_delta_s
               from (
                    select djo_codemp,
                           djo_fecha,
                           isnull(djo_hora_al_ves, djo_hora_al) djo_hora_al,
                           mar_fecha_hora,
                           (abs(datediff(ss, mar_fecha_hora, isnull(djo_hora_al_ves, djo_hora_al))) / 60.0 / 60.0) delta_s
                      from #djo j1
                      join rel.mar_marcas on djo_codemp = mar_codemp
                                 and convert(varchar, mar_fecha, 103) = convert(varchar, isnull(isnull(djo_hora_al_ves, djo_hora_al), getdate()), 103)
                     where mar_estado = @MarcaOk
                       and mar_fecha between @fIni and @fFin
                       and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
                       and djo_tipo_dia = 'D'
                       and (abs(datediff(ss, mar_fecha_hora, isnull(djo_hora_al_ves, djo_hora_al))) / 60.0 / 60.0) <
                            case when convert(varchar, djo_hora_del, 103) <> convert(varchar, mar_fecha, 103)
                                    then
                                        (abs(datediff(ss, mar_fecha_hora-1, djo_hora_del)) / 60.0 / 60.0)
                                    else
                                        (abs(datediff(ss, mar_fecha_hora, djo_hora_del)) / 60.0 / 60.0)
                            end
                       and not exists (select 1 from #djo j2
                                        where mar_codemp = j2.djo_codemp
                                          and (mar_fecha_hora = isnull(j2.djo_rel_entrada, getdate()) or
                                               mar_fecha_hora = isnull(j2.djo_rel_salida, getdate())))
                    ) m1
              group by djo_codemp,
                       djo_fecha,
                       djo_hora_al
             ) m2 on mar_codemp = djo_codemp and mar_fecha = djo_fecha
                 and  (abs(datediff(ss, mar_fecha_hora, djo_hora_al)) / 60.0 / 60.0) = djo_delta_s         
       ) m3 on djo_codemp = mar_codemp and djo_fecha = mar_fecha


--*
--* Encuentra marcas que no coinciden con la hora de entrada pero que son menores que la fecha de
--* salida y la hora de entrada es nula para un día inhabil
--* 
update #djo
   set djo_rel_entrada = mar_fecha_hora
  from #djo
  join (
        select mar_codemp, mar_fecha, mar_fecha_hora
        from rel.mar_marcas
        join #djo on djo_codemp = mar_codemp and djo_fecha = mar_fecha
                 and djo_rel_entrada is null
                 and not djo_rel_salida is null
                 and mar_fecha_hora < djo_rel_salida
       where mar_estado = @MarcaOk
         and mar_fecha between @fIni and @fFin
         and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
         and djo_tipo_dia = 'D'
       ) m3 on djo_codemp = mar_codemp and djo_fecha = mar_fecha

--*
--* Procesa registros de marcas que existen en dias con hora de salida nula
--*
update #djo
   set djo_rel_salida = mar_fecha_hora
  from #djo
  join (
      select mar_codemp,
             djo_fecha mar_fecha,
             MAX(mar_fecha_hora) mar_fecha_hora
        from rel.mar_marcas
        join #djo on mar_codemp = djo_codemp
                 and djo_rel_salida is null
                 and convert(varchar, mar_fecha_hora, 103) = convert(varchar, isnull(djo_hora_al_ves, djo_hora_al), 103)
                 and mar_fecha_hora > djo_rel_entrada
       where mar_estado = @MarcaOk
         and mar_fecha between @fIni and @fFin
         and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
         and not exists (select 1 from #djo
                          where mar_codemp = djo_codemp 
                            and (mar_fecha_hora = djo_rel_entrada or
                                 mar_fecha_hora = djo_rel_salida or
                                 mar_fecha_hora = djo_rel_marca1 or
                                 mar_fecha_hora = djo_rel_marca2 or
                                 mar_fecha_hora = djo_rel_marca3 or
                                 mar_fecha_hora = djo_rel_marca4))
        GROUP BY mar_codemp, djo_fecha 
       ) m1 on djo_codemp = mar_codemp and djo_fecha = mar_fecha


--*
--* Procesa registros de marcas que existen en dias con hora de salida nula y que la marca de salida esta
--* en la misma fecha que la entrada (cuando alguien sale antes de terminar su turno y
--* su turno termina en el proximo dia (el query anterior no toma en cuenta estos registros)
--*
update #djo
   set djo_rel_salida = mar_fecha_hora
  from #djo
  join (
      select mar_codemp,
             djo_fecha mar_fecha,
             mar_fecha_hora
        from rel.mar_marcas
        join #djo on mar_codemp = djo_codemp
                 and djo_rel_salida is null
                 and convert(varchar, mar_fecha_hora, 103) = convert(varchar, djo_hora_del, 103)
                 and mar_fecha_hora > djo_rel_entrada
       where mar_estado = @MarcaOk
         and mar_fecha between @fIni and @fFin
         and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
         and not exists (select 1 from #djo
                          where mar_codemp = djo_codemp 
                            and (mar_fecha_hora = djo_rel_entrada or
                                 mar_fecha_hora = djo_rel_salida or
                                 mar_fecha_hora = djo_rel_marca1 or
                                 mar_fecha_hora = djo_rel_marca2 or
                                 mar_fecha_hora = djo_rel_marca3 or
                                 mar_fecha_hora = djo_rel_marca4))
       ) m1 on djo_codemp = mar_codemp and djo_fecha = mar_fecha
--select * from #djo
-- where convert(varchar,djo_fecha,103) = '20/05/2014' -- ferdy

--*
--* Para registros donde hay una marca, verifica que la hora de entrada no sea en realidad una hora de salida
--*
update #djo
   set djo_rel_salida = djo_rel_entrada,
       djo_rel_entrada = null
 where not djo_rel_entrada is null
   and djo_rel_salida is null
   and (abs(datediff(ss, djo_rel_entrada, djo_hora_del)) / 60.0 / 60.0) >
       case when convert(varchar, djo_hora_del, 103) <> convert(varchar, isnull(djo_hora_al_ves, djo_hora_al), 103)
            then
                (abs(datediff(ss, djo_rel_entrada+1, isnull(djo_hora_al_ves, djo_hora_al))) / 60.0 / 60.0)
            else
                (abs(datediff(ss, djo_rel_entrada, isnull(djo_hora_al_ves, djo_hora_al))) / 60.0 / 60.0)
       end

--*
--* Encuentra marcas menores que la hora de entrada y que la hora de salida es nula
--* para actualizarlos como marca de entrada y mover la marca de entrada a salida
--*
update #djo
   set djo_rel_salida = djo_rel_entrada,
       djo_rel_entrada = mar_fecha_hora
  from #djo
  join (
        select mar_codemp,
               djo_fecha mar_fecha,
               mar_fecha_hora
        from rel.mar_marcas
        join #djo on djo_codemp = mar_codemp
                and convert(varchar, mar_fecha, 103) = convert(varchar, djo_rel_entrada, 103)
                and mar_fecha_hora < djo_rel_entrada
                and djo_rel_salida is null
        where mar_estado = @MarcaOk
        and mar_fecha between @fIni and @fFin
        and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
        and not exists (select 1 from #djo
                            where mar_codemp = djo_codemp 
                            and (mar_fecha_hora = djo_rel_entrada or
                                mar_fecha_hora = djo_rel_salida or
                                mar_fecha_hora = djo_rel_marca1 or
                                mar_fecha_hora = djo_rel_marca2 or
                                mar_fecha_hora = djo_rel_marca3 or
                                mar_fecha_hora = djo_rel_marca4))
       ) m1 on mar_codemp = djo_codemp and mar_fecha = djo_fecha
 where abs(datediff(mi, djo_rel_entrada, djo_hora_del)) >
       abs(datediff(mi, mar_fecha_hora, djo_hora_del))


--*
--* Cambia entrada por salida cuando salida es menor que entrada
--*
update #djo
   set djo_rel_marca1 = djo_rel_entrada,
       djo_rel_entrada = djo_rel_salida,
       djo_rel_salida = null
 where djo_rel_entrada > djo_rel_salida

update #djo
   set djo_rel_salida = djo_rel_marca1,
       djo_rel_marca1 = null
 where not djo_rel_marca1 is null and djo_rel_salida is null


--*
--* Encuentra las marcas que son menores que la fecha de entrada de un dia
--* y que la fecha de salida del dia anterior es nula (la asume como salida del dia anterior)
--*
update #djo
   set djo_rel_salida = mar_fecha_hora
  from #djo
  join (
        select mar_codemp codemp, mar_fecha - 1 fecha, MAX(mar_fecha_hora) mar_fecha_hora
          from rel.mar_marcas
          join #djo on djo_codemp = mar_codemp and djo_fecha = mar_fecha
                   and mar_fecha_hora < djo_rel_entrada
        where mar_estado = @MarcaOk
          and mar_fecha between @fIni and @fFin
          and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
          and not exists (select 1 from #djo
                           where mar_codemp = djo_codemp 
                             and (mar_fecha_hora = djo_rel_entrada or
                                  mar_fecha_hora = djo_rel_salida or
                                  mar_fecha_hora = djo_rel_marca1 or
                                  mar_fecha_hora = djo_rel_marca2 or
                                  mar_fecha_hora = djo_rel_marca3 or
                                  mar_fecha_hora = djo_rel_marca4))
        GROUP BY mar_codemp , mar_fecha
       ) m1 on djo_codemp = codemp and djo_fecha = fecha
 where djo_rel_salida is null


---------- AJUSTES A INTERPERTACIONES INCORRECTAS ------------------
--*
--* Busca para un día un registro que:  tenga hora de entrada u hora de slaida nula y la otra no
--*   y que el día siguiente sea INHABIL y tenga hora de entrada no nula y hora de salida no nula
--*
update #djo
   set djo_rel_entrada = rel_entrada,
       djo_rel_salida = rel_salida
  from #djo
  join (
      select d1.djo_codemp codemp,
             d1.djo_fecha fecha,
             case when (d1.djo_rel_entrada is null and not d1.djo_rel_salida is null)
                  then d1.djo_rel_salida 
                  else d1.djo_rel_entrada
             end rel_entrada,
             case when (not d2.djo_rel_entrada is null and d2.djo_rel_salida is null)
                  then d2.djo_rel_entrada 
                  else d2.djo_rel_salida
             end rel_salida
        from #djo d1
        join #djo d2 on d1.djo_codemp = d2.djo_codemp
                    and dateadd(day, 1, d1.djo_fecha) = d2.djo_fecha
                    and d2.djo_tipo_dia = 'D'
                    and ((not d2.djo_rel_entrada is null and d2.djo_rel_salida is null) OR
                         (d2.djo_rel_entrada is null and not d2.djo_rel_salida is null))
       where ((d1.djo_rel_entrada is null and not d1.djo_rel_salida is null) OR
              (not d1.djo_rel_entrada is null and d1.djo_rel_salida is null))
       ) v1 on djo_codemp = codemp and djo_fecha = fecha

-- Elimina la hora de salida del dia siguiente para el query anterior
update #djo
   set djo_rel_entrada = null
  from #djo
  join (
      select d2.djo_codemp codemp,
             d2.djo_fecha fecha
        from #djo d1
        join #djo d2 on d1.djo_codemp  = d2.djo_codemp and dateadd(day, 1, d1.djo_fecha) = d2.djo_fecha
                    and ((d1.djo_rel_salida = d2.djo_rel_entrada) OR
                         (d1.djo_rel_entrada = d2.djo_rel_entrada))
                    and d2.djo_rel_salida is null
       ) v1 on djo_codemp = codemp and djo_fecha = fecha

-- Elimina la hora de entrada del dia siguiente para el query anterior
update #djo
   set djo_rel_entrada = null
  from #djo
  join (
      select d2.djo_codemp codemp,
             d2.djo_fecha fecha
        from #djo d1
        join #djo d2 on d1.djo_codemp  = d2.djo_codemp and dateadd(day, 1, d1.djo_fecha) = d2.djo_fecha
                    and ((d1.djo_rel_salida = d2.djo_rel_entrada) OR
                         (d1.djo_rel_entrada = d2.djo_rel_entrada))
                    and d2.djo_rel_entrada is null
       ) v1 on djo_codemp = codemp and djo_fecha = fecha

--*
--* Encuentra las marcas que son menores que la hora de entrada de un dia y mayores que la hora de salida del dia anterior
--* y el día siguiente no tiene hora de salida especificada.  
--* Mueve la hora de entrada existente a hora de salida y la marca a hora de entrada
--*
update #djo
   set djo_rel_salida = djo_rel_entrada,
       djo_rel_entrada = mar_fecha_hora
  from #djo
  join (
       select mar_codemp,
              mar_fecha,
              mar_fecha_hora
         from rel.mar_marcas
        where mar_estado = @MarcaOk
          and mar_fecha between @fIni and @fFin
          and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
          and exists (select 1 from #djo
                       where djo_codemp = mar_codemp
                         and convert(varchar, mar_fecha, 103) = convert(varchar, isnull(djo_hora_al_ves, djo_hora_al), 103)
                         and mar_fecha_hora > djo_rel_salida)
          and exists (select 1 from #djo
                       where djo_codemp = mar_codemp
                         and convert(varchar, mar_fecha, 103) = convert(varchar, djo_hora_del, 103)
                         and mar_fecha_hora < djo_rel_entrada)
          and not exists (select 1 from #djo
                           where mar_codemp = djo_codemp 
                             and (mar_fecha_hora = djo_rel_entrada or
                                  mar_fecha_hora = djo_rel_salida or
                                  mar_fecha_hora = djo_rel_marca1 or
                                  mar_fecha_hora = djo_rel_marca2 or
                                  mar_fecha_hora = djo_rel_marca3 or
                                  mar_fecha_hora = djo_rel_marca4))
       ) v1 on djo_codemp = mar_codemp and djo_fecha = mar_fecha


--*
--* Encuentra las marcas que son mayores que la fecha de salida de un dia
--* pero que son menores que la fecha de entrada del dia siguiente
--* para mover la fecha de salida a marca1
--*
update #djo
   set djo_rel_marca1 = mar_fecha_hora,
       djo_rel_salida = djo_rel_salida
  from #djo
  join (
        select mar_codemp codemp, djo_fecha fecha, mar_fecha_hora
          from rel.mar_marcas
          join #djo j1 on djo_codemp = mar_codemp 
                      and convert(varchar, mar_fecha, 103) = convert(varchar, djo_rel_salida, 103)
                      and mar_fecha_hora > djo_rel_salida
        where mar_estado = @MarcaOk
          and mar_fecha between @fIni and @fFin
          and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
          and not exists (select 1 from #djo
                           where mar_codemp = djo_codemp 
                             and (mar_fecha_hora = djo_rel_entrada or
                                  mar_fecha_hora = djo_rel_salida or
                                  mar_fecha_hora = djo_rel_marca1 or
                                  mar_fecha_hora = djo_rel_marca2 or
                                  mar_fecha_hora = djo_rel_marca3 or
                                  mar_fecha_hora = djo_rel_marca4))
          and (select djo_rel_entrada 
                 from #djo j2
                where j2.djo_codemp = j1.djo_codemp
                  and j2.djo_fecha = j1.djo_fecha + 1
                  and not j2.djo_rel_entrada is null
                  /*and not j2.djo_rel_salida is null*/) > mar_fecha_hora
       ) m1 on djo_codemp = codemp and djo_fecha = fecha


--*
--* Encuentra marcas no procesadas que están contenidas en el rango de entrada
--* y salida ya interpretado 
--*
--* MARCA1 ES NULA
update #djo
   set djo_rel_marca1 = djo_rel_salida,
       djo_rel_salida = mar_fecha_hora
  from #djo
  join (
        select mar_codemp,
               mar_fecha,
               mar_fecha_hora
          from rel.mar_marcas
         where mar_estado = @MarcaOk
           and mar_fecha between @fIni and @fFin
           and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
           and not exists (select 1 from #djo
                            where mar_codemp = djo_codemp 
                              and (mar_fecha_hora = djo_rel_entrada or
                                   mar_fecha_hora = djo_rel_salida or
                                   mar_fecha_hora = djo_rel_marca1 or
                                   mar_fecha_hora = djo_rel_marca2 or
                                   mar_fecha_hora = djo_rel_marca3 or
                                   mar_fecha_hora = djo_rel_marca4))
       ) m1 on mar_codemp = djo_codemp
           and mar_fecha_hora between djo_rel_entrada and djo_rel_salida
 where djo_rel_marca1 is null


--* MARCA2 ES NULA
update #djo
   set djo_rel_marca2 = djo_rel_marca1,
       djo_rel_marca1 = case when mar_fecha_hora <= djo_rel_salida
                             then djo_rel_salida
                             else mar_fecha_hora
                        end,
       djo_rel_salida = case when mar_fecha_hora <= djo_rel_salida
                             then mar_fecha_hora
                             else djo_rel_salida
                        end
  from #djo
  join (
        select mar_codemp,
               mar_fecha,
               mar_fecha_hora
          from rel.mar_marcas
         where mar_estado = @MarcaOk
           and mar_fecha between @fIni and @fFin
           and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
           and not exists (select 1 from #djo
                            where mar_codemp = djo_codemp 
                              and (mar_fecha_hora = djo_rel_entrada or
                                   mar_fecha_hora = djo_rel_salida or
                                   mar_fecha_hora = djo_rel_marca1 or
                                   mar_fecha_hora = djo_rel_marca2 or
                                   mar_fecha_hora = djo_rel_marca3 or
                                   mar_fecha_hora = djo_rel_marca4))
       ) m1 on mar_codemp = djo_codemp
           and mar_fecha_hora between djo_rel_entrada and djo_rel_marca1
 where not djo_rel_marca1 is null
   and djo_rel_marca2 is null


--* MARCA3 ES NULA
update #djo
   set djo_rel_marca3 = djo_rel_marca2,
       djo_rel_marca2 = case when mar_fecha_hora <= djo_rel_salida
                             then djo_rel_marca1
                             else case when mar_fecha_hora <= djo_rel_marca1
                                       then djo_rel_marca1
                                       else mar_fecha_hora
                                  end
                        end,
       djo_rel_marca1 = case when mar_fecha_hora <= djo_rel_salida
                             then djo_rel_salida
                             else case when mar_fecha_hora <= djo_rel_marca1
                                       then mar_fecha_hora
                                       else djo_rel_marca1
                                  end
                        end,
       djo_rel_salida = case when mar_fecha_hora <= djo_rel_salida
                             then mar_fecha_hora
                             else djo_rel_salida
                        end
  from #djo
  join (
        select mar_codemp,
               mar_fecha,
               mar_fecha_hora
          from rel.mar_marcas
         where mar_estado = @MarcaOk
           and mar_fecha between @fIni and @fFin
           and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
           and not exists (select 1 from #djo
                            where mar_codemp = djo_codemp 
                              and (mar_fecha_hora = djo_rel_entrada or
                                   mar_fecha_hora = djo_rel_salida or
                                   mar_fecha_hora = djo_rel_marca1 or
                                   mar_fecha_hora = djo_rel_marca2 or
                                   mar_fecha_hora = djo_rel_marca3 or
                                   mar_fecha_hora = djo_rel_marca4))
       ) m1 on mar_codemp = djo_codemp
           and mar_fecha_hora between djo_rel_entrada and djo_rel_marca2
 where not djo_rel_marca1 is null
   and not djo_rel_marca2 is null
   and djo_rel_marca3 is null

--* MARCA4 ES NULA
update #djo
   set djo_rel_marca4 = djo_rel_marca3,
       djo_rel_marca3 = case when mar_fecha_hora <= djo_rel_salida
                             then djo_rel_marca2
                             else case when mar_fecha_hora <= djo_rel_marca1
                                       then djo_rel_marca2
                                       else case when mar_fecha_hora <= djo_rel_marca2
                                                 then djo_rel_marca2
                                                 else mar_fecha_hora
                                            end
                                  end
                        end,
       djo_rel_marca2 = case when mar_fecha_hora <= djo_rel_salida
                             then djo_rel_marca1
                             else case when mar_fecha_hora <= djo_rel_marca1
                                       then djo_rel_marca1
                                       else case when mar_fecha_hora <= djo_rel_marca2
                                                 then mar_fecha_hora
                                                 else djo_rel_marca2
                                            end 
                                  end
                        end,
       djo_rel_marca1 = case when mar_fecha_hora <= djo_rel_salida
                             then djo_rel_salida
                             else case when mar_fecha_hora <= djo_rel_marca1
                                       then mar_fecha_hora
                                       else djo_rel_marca1
                                  end
                        end,
       djo_rel_salida = case when mar_fecha_hora <= djo_rel_salida
                             then mar_fecha_hora
                             else djo_rel_salida
                        end
  from #djo
  join (
        select mar_codemp,
               mar_fecha,
               mar_fecha_hora
          from rel.mar_marcas
         where mar_estado = @MarcaOk
           and mar_fecha between @fIni and @fFin
           and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
           and not exists (select 1 from #djo
                            where mar_codemp = djo_codemp 
                              and (mar_fecha_hora = djo_rel_entrada or
                                   mar_fecha_hora = djo_rel_salida or
                                   mar_fecha_hora = djo_rel_marca1 or
                                   mar_fecha_hora = djo_rel_marca2 or
                                   mar_fecha_hora = djo_rel_marca3 or
                                   mar_fecha_hora = djo_rel_marca4))
       ) m1 on mar_codemp = djo_codemp
           and mar_fecha_hora between djo_rel_entrada and djo_rel_marca3
 where not djo_rel_marca1 is null
   and not djo_rel_marca2 is null
   and not djo_rel_marca3 is null
   and djo_rel_marca4 is null

UPDATE #djo
	SET djo_rel_marca2 = djo_rel_salida,
		djo_rel_marca1 = mar_fecha_hora_max,
		djo_rel_salida = mar_fecha_hora_min
  from #djo
  join (
        select mar_codemp,
               mar_fecha,
               MIN(mar_fecha_hora) mar_fecha_hora_min,
               MAX(mar_fecha_hora) mar_fecha_hora_max
          from rel.mar_marcas
         where mar_estado = @MarcaOk
           and mar_fecha between @fIni and @fFin
           and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
           and not exists (select 1 from #djo
                            where mar_codemp = djo_codemp 
                              and (mar_fecha_hora = djo_rel_entrada or
                                   mar_fecha_hora = djo_rel_salida ))
        GROUP by mar_codemp, mar_fecha
       ) m1 on mar_codemp = djo_codemp
           AND mar_fecha_hora_min BETWEEN djo_hora_del AND djo_rel_salida 
 where djo_rel_entrada is NULL
   AND djo_rel_salida IS NOT NULL


--select * from #djo

---------------------------------------------------------------------------------
-- FINALIZA Marcando las marcas no procesadas e insertando en la rel.3encias --
---------------------------------------------------------------------------------
--*
--* Marca las MARCAS AUN NO PROCESADAS como NotProcessed
--*
update rel.mar_marcas
   set mar_estado = @MarcaNotProcessed
 where mar_estado = @MarcaOk
   and mar_fecha between @fIni and @fFin
   and exists (select 1 from #empFiltro where emp_codigo = mar_codemp)
   and not exists (select 1 from #djo
                    where mar_codemp = djo_codemp 
                      and (mar_fecha_hora = djo_rel_entrada or
                           mar_fecha_hora = djo_rel_salida  or
						   mar_fecha_hora = djo_rel_marca1 or
                           mar_fecha_hora = djo_rel_marca2 ))

--*
--* Inserta el resultado del procesamiento en la tabla rel.asi_asistencias
--*
FinProceso:
set @fIni = @fIni + 1
set @fFin = @fFin - 1

begin transaction

delete 
  from rel.asi_asistencias
 where asi_fecha between @fIni and @fFin 
   and asi_estado = @estado_asi_gen
   and asi_codppl = @codppl
   and exists (select 1 from #empFiltro where emp_codigo = asi_codemp)

insert into rel.asi_asistencias
      (asi_codemp, asi_codppl, asi_codjor, asi_estado, asi_fecha, 
       asi_hora_entrada_1, asi_hora_salida_1, asi_hora_entrada_2, asi_hora_salida_2, asi_hora_entrada_3, asi_hora_salida_3, asi_hora_entrada_4, asi_hora_salida_4, 
       asi_accion, asi_aplicado_planilla, asi_planilla_autorizada, asi_ignorar_en_planilla, asi_estado_workflow, asi_ingresado_portal, 
       asi_fecha_cambio_estado, asi_usuario_grabacion, asi_fecha_grabacion)
select djo_codemp, @codppl, djo_codjor, @estado_asi_gen, djo_fecha, 
       djo_rel_entrada, djo_rel_salida, djo_rel_marca1, djo_rel_marca2, djo_rel_marca3, djo_rel_marca4, null, null, 
       'Generada', 0, 0, 0, @estado_workflow_asi_gen, 0, getdate(), @usuario, getdate()
  from #djo
 where djo_fecha between @fIni and @fFin 
   and exists (select 1 from #empFiltro where emp_codigo = djo_codemp)
   and (not djo_rel_entrada is null or not djo_rel_salida is null)
   and not exists (
           select 1 
             from rel.asi_asistencias
            where asi_codemp = djo_codemp
              and asi_fecha = djo_fecha
              and asi_codppl = @codppl
              and asi_estado = @estado_asi_gen)

--select *
--  from rel.asi_asistencias
-- where asi_fecha between @fIni and @fFin 
--   and asi_estado = @estado_asi_gen
--   and asi_codppl = @codppl
--   and exists (select 1 from #empFiltro where emp_codigo = asi_codemp)

--select *
--  from #djo
-- where djo_fecha between @fIni and @fFin 
--   and exists (select 1 from #empFiltro where emp_codigo = djo_codemp)
--   and (not djo_rel_entrada is null or not djo_rel_salida is null)
--   and not exists (
--           select 1 
--             from rel.asi_asistencias
--            where asi_codemp = djo_codemp
--              and asi_fecha = djo_fecha
--              and asi_codppl = @codppl
--              and asi_estado = @estado_asi_gen)

--rollback transaction

commit transaction
--select * from #djo order by djo_codemp
drop table #djo
drop table #empFiltro

--print 'TIEMPO TOTAL utilizado en la generación (' + cast(datediff(ms, @ts_total, getdate()) / 1000.0 as varchar) + ' seg)'