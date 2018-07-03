/************************************************************************************************************************************************************
 gen.fn_crufl_sin_tildes
*************************************************************************************************************************************************************/

IF OBJECT_ID('gen.remueve_tildes') IS NOT NULL
BEGIN
	DROP FUNCTION gen.remueve_tildes
END

GO

--SELECT gen.remueve_tildes('S� remueve las tildes')
CREATE FUNCTION gen.remueve_tildes (@cadena VARCHAR(1000))
RETURNS VARCHAR(1000) AS  
BEGIN 

--DECLARE @cadena VARCHAR(1000)
--SET @cadena = '�rea, ren�, preferir�a, l�pez, �maga'

SET @cadena = lower(@cadena)
DECLARE @cad VARCHAR(1000)
SET @cad = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@cadena, '�', 'a'), '�', 'e'), '�', 'i'), '�', 'o'), '�', 'u'), '�', 'n')


--PRINT '@cad, ' + CONVERT(VARCHAR(1000), @cad)

RETURN @cad

END