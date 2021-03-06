IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gen.fn_antiguedad'))
BEGIN
	DROP FUNCTION gen.fn_antiguedad
END

GO

---------------------------------------------------------------------------------------
-- Evolution STANDARD                                                                --
-- Funcion que calcula la diferencia en años entre una fecha y otra                  --
-- Para calculo de liquidaciones                                                     --
---------------------------------------------------------------------------------------
CREATE FUNCTION gen.fn_antiguedad
(	@fecha_ini DATETIME, 
	@fecha_fin DATETIME
) returns REAL

AS

BEGIN

declare 
    @fecha_ini_date    	    datetime,
	@fecha_fin_date  	    datetime,
	@ultimo_aniversario     datetime,
	@anio_ini        	    varchar(4),
	@anio_fin        	    varchar(4),       
	@mes_ini         	    varchar(2),
	@mes_fin         	    varchar(2),       
	@dia_ini         	    varchar(2),
	@dia_fin         	    varchar(2),        
	@Antiguedad        	    real,
	@Antiguedad_return      real,
	@Antiguedad_fraccion   	real

        -------------------------------------
        --  divide los datos por partes    --
        -------------------------------------
	set @anio_ini = cast(year(@fecha_ini) as varchar)
	set @anio_fin = cast(year(@fecha_fin) as varchar)       
	set @mes_ini  = right('00' + cast(month(@fecha_ini) as varchar),2)
	set @mes_fin  = right('00' + cast(month(@fecha_fin) as varchar),2)       
	set @dia_ini  = right('00' + cast(day(@fecha_ini) as varchar),2)
	set @dia_fin  = right('00' + cast(day(@fecha_fin) as varchar),2)
        ---------------------------------------
        -- Busca el ultimo cumpleaños valido --
        ---------------------------------------
    if @dia_ini = '29' and @mes_ini = '02'
        set @ultimo_aniversario = gen.fn_last_day(convert(datetime,'28/02/' + @anio_fin,103))
    else
        set @ultimo_aniversario = convert(datetime,@dia_ini + '/' + @mes_ini + '/' + @anio_fin,103)  
        ---------------------------------------
        -- veririfica si el aniversario no   --
        --* esta despues de la fecha fin     --
        ---------------------------------------
    if @fecha_fin < @ultimo_aniversario
		set @ultimo_aniversario = dateadd(yyyy,-1,@ultimo_aniversario)

        ---------------------------------------
        -- Busca los años en base al ultimo  --
        -- Aniversario y la fracción         --
        ---------------------------------------
	set @Antiguedad = datediff(yyyy,@fecha_ini,@ultimo_aniversario)
	SET @Antiguedad_fraccion = datediff(dd,@ultimo_aniversario,@fecha_fin)/365.00

        --------------------------------------------
        -- Forma la edad en base a todo los datos --
        --------------------------------------------
	set @Antiguedad_return = ROUND(cast(@Antiguedad as real) + @Antiguedad_fraccion,5)
 
RETURN  @Antiguedad_return

end