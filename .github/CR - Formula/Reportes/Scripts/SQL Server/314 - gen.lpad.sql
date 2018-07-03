IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gen.lpad'))
BEGIN
	DROP FUNCTION gen.lpad
END

GO

CREATE FUNCTION gen.lpad (
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
			ELSE @texto + SUBSTRING(REPLICATE(@fillchar,@numero), 1, @numero - LEN(@texto))
		END
END
