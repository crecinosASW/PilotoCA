IF OBJECT_ID('gen.convierte_entero_a_letras') IS NOT NULL
BEGIN
	DROP FUNCTION gen.convierte_entero_a_letras
END	

GO

--SELECT gen.convierte_entero_a_letras(2511)
CREATE FUNCTION gen.convierte_entero_a_letras
                (@nValor int)
returns varchar(255) as
begin
    declare @cLetras 	varchar(255),
            @cociente 	int,
            @resto 	real,
            @t		varchar(255)         
    
    If @nValor > 999999999.99 
       set @t = 'OVERFLOW:  Valor > 9e8'

    
    If @nValor < 0 
	begin
	        set @nValor = Abs(@nValor)
	        set @cLetras = '(-) '
	end
    Else
        set @cLetras = ''

    
    If @nValor = 0 
       set @t= 'cero'        

    If @nValor = 1          
       set @t= 'uno'        

    If @nValor <> 1 and @nValor <> 0
        begin
	        set @cociente = cast(@nValor / 1000000 as int)
	        set @resto = @nValor - (@cociente * 1000000.00)
	        
	        If @cociente > 0 
	           begin
                        if @cociente = 1 
                           set @cLetras = 'un'
                        else
			   set @cLetras = gen.obtiene_cientos(@cociente)

			If @cociente > 1 
				set @cLetras = @cLetras + ' millones,'
			Else
				set @cLetras = @cLetras + ' millón,'            
	           End 
	        
	        set @cociente = cast(@resto / 1000 as int)
	        set @resto = @resto - (@cociente * 1000.00)
	        
	        If @cociente > 0 
	           begin
	            If Len(@cLetras) > 0 
	               set @cLetras = @cLetras + ' '

                    if right(cast(@cociente as varchar),1) = '1' 
	                set @cLetras = @cLetras + left(gen.obtiene_cientos(@cociente),len(gen.obtiene_cientos(@cociente))-1) + ' mil,'
                    else
	                set @cLetras = @cLetras + gen.obtiene_cientos(@cociente) + ' mil,'
	   	  End
	        
	        set @cociente = cast(@resto as int)
	        set @resto = @resto - @cociente
	        
	        If @cociente > 0 
	           begin
	            If Len(@cLetras) > 0 
	               set @cLetras = @cLetras + ' '
	
	            set @cLetras = @cLetras + gen.obtiene_cientos(@cociente)
	           End
	        
	        If Len(@cLetras) > 0 
	           begin
	            If (@nValor - (cast(@nValor / 1000000 as int) * 1000000)) = 0 
	                set @cLetras = Left(@cLetras, Len(@cLetras) - 1)	
	            else If (@nValor - (cast(@nValor / 1000 as int) * 1000)) = 0 
	                    set @cLetras = Left(@cLetras, Len(@cLetras) - 1)	
	           End 
	        
	        set @t= @cLetras 
          end

        return @t
End 
