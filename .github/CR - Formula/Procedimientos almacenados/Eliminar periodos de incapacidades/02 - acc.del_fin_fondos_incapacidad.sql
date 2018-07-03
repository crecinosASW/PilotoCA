IF EXISTS (SELECT NULL 
		   FROM sys.procedures p
			  JOIN sys.schemas s ON p.schema_id = s.schema_id 
		   WHERE p.name = 'del_fin_fondos_incapacidad'
			   AND s.name = 'acc')
	DROP PROCEDURE acc.del_fin_fondos_incapacidad
	
GO	

CREATE PROCEDURE acc.del_fin_fondos_incapacidad (
	@codemp_alternativo VARCHAR(36) = NULL,
	@fecha_txt VARCHAR(10) = NULL
)

AS	

SET NOCOUNT ON
SET DATEFORMAT dmy

DECLARE @codemp INT,
	@fecha DATETIME,
	@codfin INT,
	@mensaje VARCHAR(1000)
	
SET @mensaje = ''

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)	

SELECT @codfin = fin_codigo
FROM acc.fin_fondos_incapacidad
WHERE fin_codemp = @codemp
	AND fin_periodo = @fecha_txt

IF @codemp_alternativo IS NOT NULL AND @codemp IS NULL
	SET @mensaje = @mensaje + 'No el empleado con el código alternativo : ' + ISNULL(@codemp_alternativo, 'Vacío') + ';' + CHAR(13)

IF @fecha_txt IS NOT NULL AND ISDATE(@fecha_txt) = 0
	SET @mensaje = @mensaje + 'La fecha: ' + ISNULL(@fecha_txt, 'Vacío') + ', no está en el formato correcto, el formato debe ser DD/MM/YYYY' + '; ' + CHAR(13)	

IF @codfin IS NULL
	SET @mensaje = @mensaje + 'No existe un período de incapacidades, para el empleado: ' + ISNULL(@codemp_alternativo, 'Vacío') + ', en la fecha: ' + ISNULL(@fecha_txt, 'Vacío') + '; ' + CHAR(13)	

IF EXISTS (SELECT NULL FROM acc.pie_periodos_incapacidad WHERE pie_codfin = @codfin AND pie_planilla_autorizada = 1)
	SET @mensaje = @mensaje + 'Ya existen días de incapacidades que pertenecen a planillas autorizadas' + '; ' + CHAR(13)	

IF EXISTS (SELECT NULL FROM cr.din_detalle_incapacidad WHERE din_codfin = @codfin AND din_planilla_autorizada = 1)
	SET @mensaje = @mensaje + 'Ya existe detalle de incapacidades que pertenece a planillas autorizadas' + '; ' + CHAR(13)	

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END

SET @fecha = CONVERT(DATETIME, @fecha_txt)	

BEGIN TRANSACTION

DELETE acc.pie_periodos_incapacidad
WHERE pie_codfin = @codfin
	AND pie_planilla_autorizada = 0

DELETE cr.din_detalle_incapacidad
WHERE din_codfin = @codfin
	AND din_planilla_autorizada = 0

DELETE acc.fin_fondos_incapacidad
WHERE fin_codigo = @codfin

COMMIT