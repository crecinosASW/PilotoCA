/************************************************************************************************************************************************************
gen.fn_crufl_regresa_decenas
*************************************************************************************************************************************************************/

IF OBJECT_ID('gen.obtiene_decenas') IS NOT NULL
BEGIN
	DROP FUNCTION gen.obtiene_decenas
END

GO

CREATE FUNCTION gen.obtiene_decenas
         (@decenas int)
returns varchar(50) as
begin
  declare @valor varchar(50)
  
  if @decenas = 1
      set @valor = 'dieci'
  if @decenas = 2
      set @valor = 'veinti'
  if @decenas = 3
      set @valor = 'treinta'
  if @decenas = 4
      set @valor = 'cuarenta'
  if @decenas = 5
      set @valor = 'cincuenta'
  if @decenas = 6
      set @valor = 'sesenta'
  if @decenas = 7
      set @valor = 'setenta'
  if @decenas = 8
      set @valor = 'ochenta'
  if @decenas = 9
      set @valor = 'noventa'

  return @valor
end