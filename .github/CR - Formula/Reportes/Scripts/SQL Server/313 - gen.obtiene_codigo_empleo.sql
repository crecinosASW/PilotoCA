IF EXISTS (SELECT 1 
		   FROM sys.objects p
		   WHERE object_id = object_id('gen.obtiene_codigo_empleo'))
BEGIN
	DROP FUNCTION gen.obtiene_codigo_empleo
END
	
GO	
--SELECT gen.obtiene_codigo_empleo('940')
CREATE FUNCTION gen.obtiene_codigo_empleo (
	@codigo VARCHAR(30)
)

RETURNS INT

--DECLARE @codigo VARCHAR(30)
	
--SET @codigo = '940'

BEGIN
	DECLARE @codigo_empleo VARCHAR(20),
		@codigo_alternativo VARCHAR(20),
		@codemp INT
	
	SET @codigo_alternativo = @codigo
	
	IF CHARINDEX(CHAR(25), @codigo) > 0
	BEGIN
		SET @codigo_empleo = SUBSTRING(@codigo, CHARINDEX(CHAR(25), @codigo) + 1, LEN(@codigo))
		SET @codigo_alternativo = SUBSTRING(@codigo, 0, CHARINDEX(CHAR(25), @codigo))
	END

	SET @codemp = CONVERT(INT, @codigo_empleo)

	IF @codemp IS NULL
	BEGIN
		SELECT @codemp = emp_codigo
		FROM exp.emp_empleos
			JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
		WHERE exp_codigo_alternativo = @codigo_alternativo
			AND emp_fecha_ingreso = (SELECT MAX(emp_fecha_ingreso)
									 FROM exp.emp_empleos
										 JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
									 WHERE exp_codigo_alternativo = @codigo_alternativo)
	END

	RETURN @codemp
END