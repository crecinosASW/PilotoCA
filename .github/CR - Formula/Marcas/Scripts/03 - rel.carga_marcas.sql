IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('rel.carga_marcas'))
BEGIN
	DROP PROCEDURE rel.carga_marcas
END

GO

CREATE PROCEDURE rel.carga_marcas (
	@codexp_alternativo VARCHAR(36) = NULL,
	@fecha_txt VARCHAR(8) = NULL,
	@hora_txt VARCHAR(6) = NULL,
	@codrel VARCHAR(50) = NULL
)

AS

SET DATEFORMAT DMY
SET NOCOUNT ON

DECLARE @codcia INT,
	@codemp INT,
	@fecha_hora VARCHAR(20),
	@fecha DATETIME,
	@estado_marca_indefinido VARCHAR(20),
	@mensaje VARCHAR(1000)

SET @mensaje = ''

SET @fecha_hora = SUBSTRING(@fecha_txt, 7, 2) + '/' + SUBSTRING(@fecha_txt, 5, 2) + '/' + SUBSTRING(@fecha_txt, 1, 4) + ' ' + SUBSTRING(RIGHT('0' + @hora_txt, 6), 1, 2) + ':' + SUBSTRING(RIGHT('0' + @hora_txt, 6), 3, 2) + ':' +  SUBSTRING(RIGHT('0' + @hora_txt, 6), 5, 2)

SELECT TOP(1) @codcia = plz_codcia,
	@codemp = emp_codigo
FROM exp.exp_expedientes
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
WHERE exp_codigo_alternativo = @codexp_alternativo
  AND emp_estado = 'A'

SET @estado_marca_indefinido = gen.get_valor_parametro_VARCHAR('RelojTipoMarcaIndefinido', NULL, NULL, @codcia, NULL)
SET @estado_marca_indefinido = ISNULL(@estado_marca_indefinido, 'I')

IF @codemp IS NULL
	SET @mensaje = @mensaje + 'No existe o no esta activo el empleado con el código: ' + ISNULL(@codexp_alternativo, 'Vacío') + '; ' + CHAR(13)

IF ISDATE(@fecha_hora) = 0
	SET @mensaje = @mensaje + 'La fecha y hora: ' + @fecha_hora + ', para el empleado con el código: ' + ISNULL(@codexp_alternativo, 'Vacío') + ', no está en un formato correcto, Ejemplo; ' + CHAR(13)

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END 

SET @fecha = CONVERT(DATETIME, @fecha_hora)

IF NOT EXISTS (SELECT NULL
			   FROM rel.mar_marcas 
			   WHERE mar_codemp = @codemp AND mar_fecha_hora = @fecha)
BEGIN
	INSERT INTO rel.mar_marcas (mar_codemp, 
		mar_codrel, 
		mar_tipo_marca,
		mar_fecha, 
		mar_fecha_hora, 
		mar_estado, 
		mar_usuario_grabacion, 
		mar_fecha_grabacion)
	VALUES (@codemp, 
		@codrel, 
		@estado_marca_indefinido, --Indefinido
		CONVERT(DATETIME, CONVERT(VARCHAR, @fecha, 103), 103), 
		@fecha, 
		'Registrada', 
		SYSTEM_USER, 
		GETDATE())
END