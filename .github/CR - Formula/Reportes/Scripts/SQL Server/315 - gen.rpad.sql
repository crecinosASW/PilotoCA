IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gen.rpad'))
BEGIN
	DROP FUNCTION gen.rpad
END

GO

CREATE FUNCTION gen.rpad (
	@texto VARCHAR (8000),			-- campo
	@numero INT,					-- largo  
	@fillchar VARCHAR(8000) = ' '	-- caracter
 )

RETURNS VARCHAR(200)

AS

BEGIN
	RETURN
		CASE
			WHEN LEN(@texto) >= @numero THEN SUBSTRING(@texto, 1, @numero)
			ELSE SUBSTRING(REPLICATE(@fillchar,@numero), 1, @numero - LEN(@texto)) + @texto
		END
END
