IF OBJECT_ID('gen.obtiene_cientos') IS NOT NULL
BEGIN
	DROP FUNCTION gen.obtiene_cientos
END

GO

--SELECT gen.obtiene_cientos(805)
CREATE function gen.obtiene_cientos
                (@xValor real)
returns varchar(255) as
begin
    declare @xLetras 	varchar(255),
            @xCociente 	int,
            @xResto 	real
    
    set @xLetras = ''
    
    --* centenas
    set @xCociente = cast(@xValor / 100 as int)
    set @xResto = @xValor - (@xCociente * 100.00)
    
    If @xCociente > 0 
       begin
        If @xCociente = 1 And @xResto = 0 
            set @xLetras = gen.obtiene_centenas(1)
        Else
            begin
            If @xCociente = 1 And @xResto > 0 
                set @xLetras = gen.obtiene_centenas(1) + 'to'
            Else
                begin
                If @xCociente = 5 Or @xCociente = 7 Or @xCociente = 9 
                    set @xLetras = gen.obtiene_centenas(@xCociente) --*+ ' '
                Else
                    set @xLetras = gen.obtiene_centenas(@xCociente) + 'cientos'
                End
            End
       End
    
    --* decenas
    set @xCociente = cast(@xResto / 10 as int)
    set @xResto = @xResto - @xCociente * 10.00
    
    If @xCociente > 0 
       begin
        If @xCociente = 1 And @xResto = 0 
            begin
            If Len(@xLetras) > 0 
                set @xLetras = @xLetras + ' '

            set @xLetras = @xLetras + 'diez'
            end
        Else
            begin
            If @xCociente = 1 And @xResto <= 5
               begin
                If Len(@xLetras) > 0 
                    set @xLetras = @xLetras + ' '

                set @xLetras = @xLetras + gen.obtiene_unidades(@xCociente * 10 + @xResto)
                set @xResto = 0
                end
            Else
                begin
                If @xCociente = 2 And @xResto = 0 
                    begin
                    If Len(@xLetras) > 0 
                        set @xLetras = @xLetras + ' '

                    set @xLetras = @xLetras + 'veinte'
                    end
                Else
                    begin
                    If @xCociente < 3 
                       begin
                        If Len(@xLetras) > 0 
                           set @xLetras = @xLetras + ' '

                        set @xLetras = @xLetras + gen.obtiene_decenas(@xCociente)
                       end
                    Else
                        begin
                        If @xCociente >= 3 And @xResto > 0 
                            begin
                            If Len(@xLetras) > 0 
                               set @xLetras = @xLetras + ' '

                            set @xLetras = @xLetras + gen.obtiene_decenas(@xCociente)
                            set @xLetras = @xLetras + ' y '
                            end
                        Else
                            begin
                            If Len(@xLetras) > 0 
                                set @xLetras = @xLetras + ' '

                            set @xLetras = @xLetras + gen.obtiene_decenas(@xCociente)
                            end                        
                        End 
                    End
                End
            End
       End
    
    --* unidades
    If @xResto > 0 
       begin
        If Len(@xLetras) = 0 
            set @xLetras = gen.obtiene_unidades(@xResto)
        Else
            begin
            If Right(@xLetras, 1) = 'i' 
                set @xLetras = @xLetras + gen.obtiene_unidades(@xResto)
            Else
                begin
                set @xLetras = @xLetras 
                if Right(@xLetras, 1) <> ' '
                     set @xLetras = @xLetras + ' '
                else
                     set @xLetras = @xLetras + ''

                set @xLetras = @xLetras + gen.obtiene_unidades(@xResto)
                end
            End
       End
    
    return @xLetras


End