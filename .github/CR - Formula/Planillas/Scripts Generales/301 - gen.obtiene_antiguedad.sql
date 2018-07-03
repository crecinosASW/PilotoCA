IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gen.obtiene_antiguedad'))
BEGIN
	DROP FUNCTION gen.obtiene_antiguedad
END

GO

CREATE FUNCTION gen.obtiene_antiguedad
           (@fecha_ingreso datetime, 
	        @fecha_actual  datetime)
returns real as
--------------------------------------------------------
-- Evolution                                          --
-- Obtiene la antiguedad entre la fecha de ingreso    --
-- y la fecha actual, ambas recibidas como parametros --
--------------------------------------------------------
begin

declare @ultimo_aniversario  datetime,

        @anio_ing        	varchar(4),
        @anio_act        	varchar(4),       
        @mes_ing         	varchar(2),
        @mes_act         	varchar(2),       
        @dia_ing         	varchar(2),
        @dia_act         	varchar(2),        
        @antiguedad        	real,--varchar(2),

        @antiguedad_return     	real,
        @antiguedad_fraccion   	real

        -------------------------------------
        --  Divide los datos por partes    --
        -------------------------------------
        set @anio_ing = cast(year(@fecha_ingreso) as varchar)
        set @anio_act = cast(year(@fecha_actual) as varchar)       
        set @mes_ing  = right('00' + cast(month(@fecha_ingreso) as varchar),2)
        set @mes_act  = right('00' + cast(month(@fecha_actual) as varchar),2)       
        set @dia_ing  = right('00' + cast(day(@fecha_ingreso) as varchar),2)
        set @dia_act  = right('00' + cast(day(@fecha_actual) as varchar),2)
        -----------------------------------------
        --  Busca el ultimo cumpleaños valido  --
        -----------------------------------------
        if @dia_ing = '29' and @mes_ing = '02'
            set @ultimo_aniversario = convert(datetime,'28/02/' + @anio_act,103)  
        else
            set @ultimo_aniversario = convert(datetime,@dia_ing + '/' + @mes_ing + '/' + @anio_act,103)  
        -----------------------------------------
        --  veririfica si el cumpleaños no     --
        --  esta despues de la fecha fin       --
        -----------------------------------------
        if @fecha_actual < @ultimo_aniversario
           begin
              set @ultimo_aniversario = dateadd(yyyy,-1,@ultimo_aniversario)
           end
        set @ultimo_aniversario = dateadd(dd,-1,@ultimo_aniversario)
        -----------------------------------------
        --  Busca los años en base al ultimo   --
        --  cumpleaños y la fracción           --
        -----------------------------------------
        select @antiguedad = datediff(yyyy,@fecha_ingreso,@ultimo_aniversario),
               @antiguedad_fraccion = datediff(dd,@ultimo_aniversario,@fecha_actual)/365.00

        --------------------------------------------
        -- Forma la edad en base a todo los datos --
        --------------------------------------------
         select @antiguedad_return = cast(@antiguedad as real) + @antiguedad_fraccion
 
RETURN  @antiguedad_return
end
