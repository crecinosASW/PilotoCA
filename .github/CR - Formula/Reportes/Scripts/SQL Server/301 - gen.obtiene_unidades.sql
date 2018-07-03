/************************************************************************************************************************************************************
gen.fn_crufl_regresa_unidades
*************************************************************************************************************************************************************/

IF OBJECT_ID('gen.obtiene_unidades') IS NOT NULL
BEGIN
	DROP FUNCTION gen.obtiene_unidades
END

GO

--SELECT gen.obtiene_unidades(5)
CREATE FUNCTION gen.obtiene_unidades
         (@unidad int)
returns varchar(50) as
begin
  declare @valor varchar(50)
  
  if @unidad = 1
      set @valor = 'uno'
  if @unidad = 2
      set @valor = 'dos'
  if @unidad = 3
      set @valor = 'tres'
  if @unidad = 4
      set @valor = 'cuatro'
  if @unidad = 5
      set @valor = 'cinco'
  if @unidad = 6
      set @valor = 'seis'
  if @unidad = 7
      set @valor = 'siete'
  if @unidad = 8
      set @valor = 'ocho'
  if @unidad = 9
      set @valor = 'nueve'
  if @unidad = 10
      set @valor = 'diez'
  if @unidad = 11
      set @valor = 'once'
  if @unidad = 12
      set @valor = 'doce'
  if @unidad = 13
      set @valor = 'trece'
  if @unidad = 14
      set @valor = 'catorce'
  if @unidad = 15
      set @valor = 'quince'

  return @valor
end