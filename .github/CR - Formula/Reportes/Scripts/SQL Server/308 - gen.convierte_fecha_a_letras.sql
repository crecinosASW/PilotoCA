IF OBJECT_ID('gen.convierte_fecha_a_letras') IS NOT NULL
BEGIN
	DROP FUNCTION gen.convierte_fecha_a_letras
END

GO

--SELECT gen.convierte_fecha_a_letras(GETDATE(), 1, 0)
--SELECT gen.convierte_fecha_a_letras(GETDATE(), 1, 1)
--SELECT gen.convierte_fecha_a_letras(GETDATE(), 0, 0)
--SELECT gen.convierte_fecha_a_letras(GETDATE(), 0, 1)
--SELECT gen.convierte_fecha_a_letras(GETDATE(), 0, 2)
CREATE function gen.convierte_fecha_a_letras
                (@fch           datetime,
                 @ConPronombre  int,
                 @formato       int)
returns varchar(255) as
begin
    --*********************************************************--
    --* Guia de pronombre y formatos                          *--
    --*                                                       *--
    --* formato = 1 (todo en letras)                          *--
    --* pronombre <> 1                                        *--
    --*   ej. dos de enero de dos mil uno                     *--
    --* pronombre = 1                                         *--
    --*   ej. a los dos dias del mes de enero de dos mil uno  *--
    --*                                                       *--
    --* formato <> 1 (numeros y letras)                       *--
    --* pronombre <> (1,2)                                    *--
    --*   ej. 2 de enero de 2001                              *--
    --* pronombre = 1                                         *--
    --*   ej. a los 2 dias del mes de enero de 2001           *--
    --* pronombre = 2                                         *--
    --*   ej. del 2 de enero de 2001                          *--
    --*********************************************************--

    declare @t   varchar(255)
    
    set @t= ''
    

 if @formato = 1 
    begin
    --**************************************--
    --* verfica si va poner pronombre y el *--
    --* correcto formato para el dia uno   *--
    --**************************************--
    If @ConPronombre = 1 
       begin
	   If Day(@fch) = 1 
	      set @t = 'el '
	   Else
	      set @t = 'a los '
       End 
    
    If Day(@fch) = 1 
       set @t= @t + 'primero de '
    Else
       begin
	    --*******************************************--
	    --* si usa pronombre verfica si el dia      *--
	    --* termina en uno para poner veintiun dias *--
            --* en lugar de veintinuno dias             *--
	    --*******************************************--
           if @ConPronombre = 1 
              begin 
                 if right(Day(@fch),1) = '1'              
       	            set @t= @t + left(gen.obtiene_cientos(cast(Day(@fch) as int)),len(gen.obtiene_cientos(cast(Day(@fch) as int))) - 1) 
                 else
       	            set @t= @t + gen.obtiene_cientos(cast(Day(@fch) as int))

                 set @t= @t + ' dias del mes de '
              end
           else
              set @t= @t + gen.obtiene_cientos(cast(Day(@fch) as int)) + ' de '
       end

    set @t= @t + gen.nombre_mes(cast(Month(@fch) as int)) + ' de '

    --**********************************************--
    --* Esto es para que ponga mil en ves uno mil  *--
    --* o un mil y de una vez dos mill             *--
    --**********************************************--    
    If Year(@fch) < 2000 
       set @t = @t + 'mil novecientos ' + gen.obtiene_cientos(cast(Year(@fch) - 1900 as int))
    Else
       set @t = @t+ 'dos mil ' + gen.obtiene_cientos(cast(Year(@fch) - 2000 as int))
    end
  else
    begin
    --**********************************************--
    --* el formato no es de tipo 1 es que debe     *--
    --* salir en modo ej.  del 2 de Enero de 2003  *--
    --**********************************************--
    If @ConPronombre = 1 
            begin
	        If Day(@fch) = 1 
	           set @t = 'el '
	        Else
                   set @t = ' a los ' 
           end
    else if @ConPronombre = 2
	  set @t = ' del '

    set @t = @t + cast(Day(@fch)as varchar)

    If @ConPronombre = 1        
       begin
          If Day(@fch) <> 1 
             set @t = @t + ' dias del mes de ' 
          else
             set @t = @t + ' de '
       end
    else
      set @t = @t + ' de ' 

    set @t = @t + gen.nombre_mes(cast(Month(@fch)as int)) +  ' de ' + cast(Year(@fch) as varchar)

    end
    
    set @t= LTrim(RTrim(@t))
    
    return @t

End 
