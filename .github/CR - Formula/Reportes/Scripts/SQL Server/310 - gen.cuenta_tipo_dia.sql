IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gen.cuenta_tipo_dia'))
BEGIN
	DROP FUNCTION gen.cuenta_tipo_dia
END

GO	

CREATE FUNCTION gen.cuenta_tipo_dia (
	@tipo INT = NULL,
	@fecha_inicial DATETIME = NULL,
	@fecha_final DATETIME = NULL)
RETURNS INT

AS

BEGIN	
	DECLARE @fecha_actual DATETIME,
		@conteo INT

	SET @conteo = 0
	
	SET @fecha_actual = @fecha_inicial

	IF (@fecha_inicial <= @fecha_final)
	BEGIN
		WHILE @fecha_actual <= @fecha_final
		BEGIN
			IF DATEPART(DW, @fecha_actual) = @tipo
				SET @conteo = @conteo + 1
		
			SET @fecha_actual = DATEADD(DD, 1, @fecha_actual)
		END	
	END
	
	RETURN @conteo
END

	