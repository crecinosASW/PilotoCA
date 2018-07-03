IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('acc.validacion_contratacion'))
BEGIN
	DROP PROCEDURE acc.validacion_contratacion
END

GO

CREATE PROCEDURE acc.validacion_contratacion (
	@codigo INT = NULL,
	@entitysetname VARCHAR(50) = NULL,
	@accion VARCHAR(10) = NULL,
	@mensaje_validacion VARCHAR(500) OUT
)

AS

DECLARE @regimen_vacacion REAL

SELECT @regimen_vacacion = gen.get_pb_field_data_float(con_property_bag_data, 'RegimenVacacion')
FROM acc.con_contrataciones
WHERE con_codigo = @codigo

--IF @accion = 'Insert' OR @accion = 'Update'
--BEGIN
--	IF @regimen_vacacion IS NULL
--	BEGIN
--		SET @mensaje_validacion = 'El régimen de vacación es requerido, revisar los campos adicionales'
--	END
--END

RETURN