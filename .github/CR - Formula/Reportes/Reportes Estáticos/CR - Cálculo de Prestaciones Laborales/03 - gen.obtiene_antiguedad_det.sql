IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gen.obtiene_antiguedad_det'))
BEGIN
	DROP FUNCTION gen.obtiene_antiguedad_det
END

GO

---------------------------------------------------------------------------------------
-- Evolution STANDARD                                                                --
-- Funcion que calcula la diferencia en años entre una fecha y otra                  --
-- Para calculo de liquidaciones                                                     --
---------------------------------------------------------------------------------------
--SELECT gen.obtiene_antiguedad_det('20051005', '20051010')
CREATE FUNCTION gen.obtiene_antiguedad_det (	
	@fecha_ini DATETIME, 
	@fecha_fin DATETIME
) RETURNS VARCHAR(50)

AS

BEGIN

DECLARE @anios INT,	
	@meses INT,
	@dias INT,
	@fecha_actual DATETIME,
	@antiguedad_texto VARCHAR(50)

SET @fecha_actual = @fecha_ini
SET @antiguedad_texto = ''
SET @anios = 0
SET @meses = 0
SET @dias = 0

--PRINT 'Fecha Inicial: ' + ISNULL(CONVERT(VARCHAR, @fecha_ini, 103), '')
--PRINT 'Fecha Final: ' + ISNULL(CONVERT(VARCHAR, @fecha_fin, 103), '')

IF @fecha_fin >= @fecha_ini
BEGIN
	SET @anios = FLOOR(gen.fn_antiguedad(@fecha_actual, @fecha_fin))

	--PRINT 'Años: ' + ISNULL(CONVERT(VARCHAR, @anios), '')

	SET @fecha_actual = DATEADD(YY, @anios, @fecha_actual)

	--PRINT 'Fecha Actual: ' + ISNULL(CONVERT(VARCHAR, @fecha_actual, 103), '')

	SET @meses = gen.fn_antiguedad_meses(@fecha_actual, @fecha_fin)

	--PRINT 'Meses: ' + ISNULL(CONVERT(VARCHAR, @meses), '')

	SET @fecha_actual = DATEADD(MM, @meses, @fecha_actual)

	--PRINT 'Fecha Actual: ' + ISNULL(CONVERT(VARCHAR, @fecha_actual, 103), '')

	SET @dias = DATEDIFF(DD, @fecha_actual, @fecha_fin)

	--PRINT 'Días: ' + ISNULL(CONVERT(VARCHAR, @dias), '')

	IF @anios = 1
		SET @antiguedad_texto = @antiguedad_texto + CONVERT(VARCHAR, @anios) + ' año'

	IF @anios > 1
		SET @antiguedad_texto = @antiguedad_texto + CONVERT(VARCHAR, @anios) + ' años'

	IF @meses > 0 
	BEGIN
		IF @anios > 0 AND @dias > 0
			SET @antiguedad_texto = @antiguedad_texto + ', '
		
		IF @anios > 0 AND @dias = 0
			SET @antiguedad_texto = @antiguedad_texto + ' y '

		IF @meses = 1
			SET @antiguedad_texto = @antiguedad_texto + CONVERT(VARCHAR, @meses) + ' mes'
		ELSE
			SET @antiguedad_texto = @antiguedad_texto + CONVERT(VARCHAR, @meses) + ' meses'
	END

	IF @dias > 0 
	BEGIN
		IF @anios > 0 OR @meses > 0
			SET @antiguedad_texto = @antiguedad_texto + ' y '

		IF @dias = 1
			SET @antiguedad_texto = @antiguedad_texto + CONVERT(VARCHAR, @dias) + ' día'
		ELSE
			SET @antiguedad_texto = @antiguedad_texto + CONVERT(VARCHAR, @dias) + ' días'
	END
END

--PRINT 'Antigüedad Texto: ' + ISNULL(CONVERT(VARCHAR, @antiguedad_texto), '')

RETURN  @antiguedad_texto

END