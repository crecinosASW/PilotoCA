IF OBJECT_ID('gen.obtiene_centenas') IS NOT NULL
BEGIN
	DROP FUNCTION gen.obtiene_centenas
END

GO

/************************************************************************************************************************************************************
gen.regresa_centenas
*************************************************************************************************************************************************************/

--SELECT gen.obtiene_centenas(6)
CREATE FUNCTION gen.obtiene_centenas
         (@centenas int)
returns varchar(50) as
begin
  declare @valor varchar(50)
  
  if @centenas = 1
      set @valor = 'cien'
  if @centenas = 2
      set @valor = 'dos'
  if @centenas = 3
      set @valor = 'tres'
  if @centenas = 4
      set @valor = 'cuatro'
  if @centenas = 5
      set @valor = 'quinientos'
  if @centenas = 6
      set @valor = 'seis'
  if @centenas = 7
      set @valor = 'setecientos'
  if @centenas = 8
      set @valor = 'ocho'
  if @centenas = 9
      set @valor = 'novecientos'

  return @valor
end

GO