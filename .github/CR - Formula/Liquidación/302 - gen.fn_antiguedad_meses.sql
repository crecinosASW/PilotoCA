IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gen.fn_antiguedad_meses'))
BEGIN
	DROP FUNCTION gen.fn_antiguedad_meses
END

GO

--SELECT gen.fn_antiguedad_meses(GETDATE(), DATEADD(MM, 10, GETDATE()))
--SELECT gen.fn_antiguedad_meses('20120229', '20130227')
CREATE FUNCTION gen.fn_antiguedad_meses (
	@fecha_ini datetime, 
	@fecha_fin datetime
)
returns int as
begin

   -- declare @fecha_ini datetime, @fecha_fin datetime
   -- set @fecha_ini = '04/13/2003'
   -- set @fecha_fin = getdate()
   
   declare @meses int, @dias int, @signo int
   set @signo = 1

   -- Trunca las fechas para eliminar horas, minutos y segundos
   set @fecha_ini = convert(datetime, convert(varchar, @fecha_ini, 103), 103)
   set @fecha_fin = convert(datetime, convert(varchar, @fecha_fin, 103), 103)

   -- Determina si la fecha_fin es mayor que la @fecha_ini
   if @fecha_ini > @fecha_fin begin
      declare @d datetime
      set @d = @fecha_ini
      set @fecha_ini = @fecha_fin
      set @fecha_fin = @d
      set @signo = -1
   end

   set @meses = datediff(mm, @fecha_ini, @fecha_fin)
   
   if @meses > 0 begin
      if dateadd(mm, @meses, @fecha_ini) > @fecha_fin set @meses = @meses - 1
      set @dias = datediff(dd, dateadd(mm, @meses, @fecha_ini), @fecha_fin)
   end
   else
      set @dias = datediff(dd, @fecha_ini, @fecha_fin)

   RETURN @meses * @signo
end