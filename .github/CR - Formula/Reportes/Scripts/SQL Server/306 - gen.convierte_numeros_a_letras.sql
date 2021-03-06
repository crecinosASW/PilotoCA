IF OBJECT_ID('gen.convierte_numeros_a_letras') IS NOT NULL
BEGIN
	DROP FUNCTION gen.convierte_numeros_a_letras
END

GO

--SELECT gen.convierte_numeros_a_letras(2510, 'gt')
CREATE FUNCTION gen.convierte_numeros_a_letras
                (@nValor 	   money,
                 @Pais     	VARCHAR(2))
returns varchar(500) as
begin
 --declare @nValor money, @Pais VARCHAR
 --select @nValor = 0.58, @Pais = 'GT'

    declare @cLetras varchar(500),
            @cociente int,
            @resto    money,
            @vMonedaPlural varchar(50),
            @vMonedaSingular varchar(50)
    
    If Len(lTrim(rtrim(@Pais))) > 0 
       begin
            Select @vMonedaPlural = mon_descripcion,
                   @vMonedaSingular = mon_singular
             from gen.pai_paises 				INNER JOIN  gen.mon_monedas ON pai_codmon = mon_codigo				where pai_codigo = @Pais                               
            if (@vMonedaPlural is null) or (@vMonedaPlural = '') or (@vMonedaSingular is null) or (@vMonedaSingular = '')
               begin
                set @vMonedaPlural = 'D�lares'
                set @vMonedaSingular = 'Dolar'
               end
       end
    Else
       begin
            set @vMonedaPlural = 'D�lares'
            set @vMonedaSingular = 'Dolar'
       end


--     ? nos se why        
--        set @vMonedaPlural = ''
--        set @vMonedaSingular = ''

    If @nValor > 999999999.99 
       set @cLetras= 'OVERFLOW:  Valor > 9e8'
    
    If @nValor < 0 
       begin
          set @nValor = Abs(@nValor)
          set @cLetras = '(-) '
       end
    Else
        set @cLetras = ''
    
    If @nValor = 0
        set @cLetras= 'cero ' + @vMonedaPlural
        
    Else If Round(@nValor, 2) = 1
        set @cLetras= 'un ' + @vMonedaSingular + ' con 00/100'        

        Else
            begin
              --* millares
   	        set @cociente = floor(@nValor / 1000000.00)
   	        set @resto = @nValor - @cociente * 1000000.00
--print 'Cociente = ' + cast(@cociente as varchar) + '  Resto = ' + cast(@resto as varchar)
   	        
   	        If @cociente > 0 
                 begin      	
      	            If @cociente > 1 
                         begin
                            set @cLetras = gen.obtiene_cientos(@cociente)            
                            if right(@cociente,1) = 1
                               set @cLetras = left(@cLetras,len(@cLetras) - 1)
     
         	                set @cLetras = @cLetras + ' millones,'
                         end
      	            Else
      	                set @cLetras = 'un mill�n,'
   	           End 

              --*miles   	        
   	        set @cociente = floor(@resto / 1000.00)
   	        set @resto = @resto - (@cociente * 1000.00)
--print 'Cociente = ' + cast(@cociente as varchar) + '  Resto = ' + cast(@resto as varchar)
   	        
   	        If @cociente > 0 
                 begin
      	            If Len(@cLetras) > 0 
      	               set @cLetras = @cLetras + ' '

      	            If @cociente > 1 
                        begin
         	               set @cLetras = @cLetras + gen.obtiene_cientos(@cociente) 
                           if right(@cociente,1) = 1
                              set @cLetras = left(@cLetras,len(@cLetras) - 1)
                         
                           set @cLetras =  @cLetras + ' mil,'
                        end
                     else
                        set @cLetras = @cLetras + 'un mil,'
   	           End
 
              --*cientos
   	        set @cociente = floor(@resto)
   	        set @resto = @resto - @cociente
--print 'Cociente = ' + cast(@cociente as varchar) + '  Resto = ' + cast(@resto as varchar)
   	        
   	        If @cociente > 0 
                 begin
      	            If Len(@cLetras) > 0 
      	                set @cLetras = @cLetras + ' '

      	            If @cociente > 1                
                        begin
         	               set @cLetras = @cLetras + gen.obtiene_cientos(@cociente)
                           if right(@cociente, 1) = 1
                                 set @cLetras = left(@cLetras,len(@cLetras))-- - 1)
                        end
                     else
      	               set @cLetras = @cLetras + 'un'
   	            End
              else 
                  begin
                     If Len(@cLetras) = 0 
                         set @cLetras = 'cero'
                  end

--print @cLetras
   	        If Len(@cLetras) > 0 
                 begin
      	            If (@nValor - cast(@nValor / 1000000 as int) * 1000000.00) = 0 
                        begin
         	               set @cLetras = Left(@cLetras, Len(@cLetras) - 1)
         	               set @cLetras = @cLetras + ' de ' + @vMonedaPlural
                        end
      	            Else
                        begin
         	                If @cLetras = 'cero' or @nValor >= 2
         	                   set @cLetras = @cLetras + ' ' + @vMonedaPlural
         	                Else
         	                   set @cLetras = @cLetras + ' ' + @vMonedaSingular
      	               End
   	           End 
   	        
   	        If @resto > 0 
                 set @cLetras = @cLetras + ' con ' +
                                replace(RTrim(LTrim(cast(floor(@resto * 100) as varchar))), '.', '/1')
   	        Else
   	            set @cLetras = @cLetras + ' con 00/100'

            End

--print @cLetras
  return @cLetras
End