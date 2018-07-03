IF EXISTS (SELECT NULL 
		   FROM sys.objects
		   WHERE object_id = object_id('gen.obtiene_estado_civil'))
BEGIN
	DROP FUNCTION gen.obtiene_estado_civil
END

GO	

CREATE FUNCTION gen.obtiene_estado_civil (
	@sexo VARCHAR(1),
	@estado_civil VARCHAR(1)
)

RETURNS VARCHAR(10) 

AS

BEGIN
  DECLARE @valor VARCHAR(50)
  
SET @valor = 
	CASE WHEN @sexo = 'F' THEN
		CASE WHEN @estado_civil = 'S' THEN 'soltera'
			 WHEN @estado_civil = 'C' THEN 'casada'
			 WHEN @estado_civil = 'D' THEN 'divorciada'
			 WHEN @estado_civil = 'V' THEN 'viuda'
			 WHEN @estado_civil = 'U' THEN 'unida'
		END
		WHEN @sexo = 'M' THEN
		CASE WHEN @estado_civil = 'S' THEN 'soltero'
			 WHEN @estado_civil = 'C' THEN 'casado'
			 WHEN @estado_civil = 'D' THEN 'divorciado'
			 WHEN @estado_civil = 'V' THEN 'viudo'
			 WHEN @estado_civil = 'U' THEN 'unido'
		END
	END

  RETURN @valor
END