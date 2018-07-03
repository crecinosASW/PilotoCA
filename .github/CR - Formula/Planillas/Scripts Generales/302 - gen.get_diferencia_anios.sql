IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gen.get_diferencia_anios'))
BEGIN
	DROP FUNCTION gen.get_diferencia_anios 
END

GO

CREATE FUNCTION gen.get_diferencia_anios 
    (@fecha_ini datetime, @fecha_fin datetime)
returns float as
begin
    declare @fecha_ini_date    	datetime,
            @fecha_fin_date  	datetime,
            @ultimo_cumpleaños  datetime,

            @anio_nac        	varchar(4),
            @anio_fin        	varchar(4),       
            @mes_nac         	varchar(2),
            @mes_fin         	varchar(2),       
            @dia_nac         	varchar(2),
            @dia_fin         	varchar(2),        
            @edad            	float,
            @edad_return     	float,
            @edad_fraccion   	float

    --*****************************************--
    --* Trunca las fechas para quitar la hora *--
    --*****************************************--
    set @fecha_ini_date = convert(datetime, convert(varchar, @fecha_ini, 103), 103)
    set @fecha_fin_date = convert(datetime, convert(varchar, @fecha_fin, 103), 103)
    --*********************************--
    --* divide los datos por partes   *--
    --*********************************--
    set @anio_nac = cast(year(@fecha_ini_date) as varchar)
    set @mes_nac  = right('00' + cast(month(@fecha_ini_date) as varchar), 2)
    set @dia_nac  = right('00' + cast(day(@fecha_ini_date) as varchar), 2)

    set @anio_fin = cast(year(@fecha_fin_date) as varchar)       
    set @mes_fin  = right('00' + cast(month(@fecha_fin_date) as varchar), 2)       
    set @dia_fin  = right('00' + cast(day(@fecha_fin_date) as varchar), 2)
    --*************************************--
    --* Busca el ultimo cumpleaños valido *--
    --*************************************--
    if @dia_nac = '29' and @mes_nac = '02'
        set @ultimo_cumpleaños = convert(datetime, '28/02/' + @anio_fin, 103)  
    else
        set @ultimo_cumpleaños = convert(datetime, @dia_nac + '/' + @mes_nac + '/' + @anio_fin, 103)  
    --*************************************--
    --* veririfica si el cumpleaños no    *--
    --* esta despues de la fecha fin      *--
    --*************************************--
    if @fecha_fin_date < @ultimo_cumpleaños
    begin
        set @ultimo_cumpleaños = dateadd(year, -1, @ultimo_cumpleaños)
    end
    --*************************************--
    --* Busca los años en base al ultimo  *--
    --* cumpleaños y la fracción          *--
    --*************************************--
    select @edad = datediff(year, @fecha_ini_date, @ultimo_cumpleaños),
           @edad_fraccion = round(datediff(day, @ultimo_cumpleaños, @fecha_fin_date) / 365.00, 4)

    --******************************************--
    --* Forma la edad en base a todo los datos *--
    --******************************************--
     select @edad_return = cast(@edad as real) + @edad_fraccion

    RETURN @edad_return
end
GO


