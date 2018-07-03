IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('exp.imp_exp_expedientes'))
BEGIN
	DROP PROCEDURE exp.imp_exp_expedientes
END

GO

--------------------------------------------------------------------
-- evolution                                                      -- 
-- procedimiento para importar expedientes utilizando evo import --
--------------------------------------------------------------------

CREATE PROCEDURE exp.imp_exp_expedientes (	
	@exp_codpai_digita VARCHAR(2) = NULL,
	@exp_codigo_alternativo VARCHAR(36) = NULL,
	@exp_primer_nom VARCHAR(50) = NULL,
	@exp_segundo_nom VARCHAR(50) = NULL,
	@exp_primer_ape VARCHAR(50) = NULL,
	@exp_segundo_ape VARCHAR(50) = NULL,
	@exp_apellido_cas VARCHAR(50) = NULL,
	@exp_otros_nom VARCHAR(100) = NULL,
	@exp_nombre_usual VARCHAR(250) = NULL,
	@exp_sexo VARCHAR(1) = NULL,
	@exp_estado_civil VARCHAR(1) = NULL,
	@exp_profesion VARCHAR(100) = NULL,
	@exp_codpai_nacionalidad VARCHAR(2) = NULL,
	@exp_fecha_nac_txt VARCHAR(10) = NULL,
	@exp_email VARCHAR(100) = NULL,
	@exp_email_interno VARCHAR(100) = NULL,
	@exp_telefono_movil VARCHAR(20) = NULL,
	@exp_telefono_interno VARCHAR(20) = NULL,
	@exp_codpai_nacimiento VARCHAR(2) = NULL,
	@exp_coddep_nac INT = NULL,
	@exp_codmun_nac INT = NULL,
	@exp_lugar_nac INT = NULL,
	@dex_direccion VARCHAR(150) = NULL,
	@dex_codmun INT = NULL,
	@cbe_codbca INT = NULL,
	@cbe_codmon VARCHAR(3) = NULL,
	@cbe_numero_cuenta VARCHAR(20) = NULL,
	@cbe_tipo_cuenta VARCHAR(1) = NULL
)

AS

SET DATEFORMAT dmy

SET @exp_codigo_alternativo = REPLACE(@exp_codigo_alternativo, ';', ',')
SET @exp_profesion = REPLACE(@exp_profesion, ';', ',')
SET @exp_email = REPLACE(@exp_email, ';', ',')
SET @exp_email_interno  = REPLACE(@exp_email_interno , ';', ',')
SET @exp_telefono_movil  = REPLACE(@exp_telefono_movil , ';', ',')
SET @exp_telefono_interno  = REPLACE(@exp_telefono_interno , ';', ',')
SET @dex_direccion = REPLACE(@dex_direccion, ';', ',')

DECLARE @codtid_domicilio INT,  
	@exp_fecha_nac DATETIME,
	@codexp INT,
	@mensaje VARCHAR(1000)

SET @mensaje = ''

---------------------------------------
--           validaciones            --
---------------------------------------

IF @exp_codpai_digita IS NULL
	SET @mensaje = @mensaje + 'El c�digo del pa�s donde se digita el expediente es requerido' + '; ' + CHAR(13)

IF NOT EXISTS (SELECT NULL FROM gen.pai_paises WHERE pai_codigo = @exp_codpai_digita)
	SET @mensaje = @mensaje + 'No existe el pa�s donde se digita el expediente con el c�digo: ' + ISNULL(@exp_codpai_digita, 'Vac�o') + ' para el empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', revisar el cat�logo de pa�ses' + '; ' + CHAR(13)

IF @exp_codigo_alternativo IS NULL
	SET @mensaje = @mensaje + 'El c�digo del empleado es requerido' + '; ' + CHAR(13)

IF EXISTS (SELECT NULL FROM exp.exp_expedientes WHERE exp_codigo_alternativo = @exp_codigo_alternativo)
	SET @mensaje = @mensaje + 'El c�digo ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ' del empleado ya est� asignado a otro empleado' + '; ' + CHAR(13)

IF @exp_primer_nom IS NULL
	SET @mensaje = @mensaje + 'El primer nombre del empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ' es requerido' + '; ' + CHAR(13)

IF @exp_primer_ape IS NULL
	SET @mensaje = @mensaje + 'El primer apellido del empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ' es requerido' + '; ' + CHAR(13)

IF @exp_sexo IS NULL
	SET @mensaje = @mensaje + 'El sexo del empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ' es requerido' + '; ' + CHAR(13)

IF @exp_sexo NOT IN ('M', 'F')
	SET @mensaje = @mensaje + 'Valor no v�lido para el sexo del empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', el sexo solo puede ser M o F' + '; ' + CHAR(13)

IF @exp_estado_civil IS NULL
	SET @mensaje = @mensaje + 'El estado civil del empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ' es requerido' + '; ' + CHAR(13)

IF @exp_estado_civil NOT IN ('C', 'D', 'S', 'A', 'V')
	SET @mensaje = @mensaje + 'Valor no v�lido para el estado civil del empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', el estado civil debe ser C, D, S, A o V' + '; ' + CHAR(13)

IF @exp_profesion IS NULL
	SET @mensaje = @mensaje + 'La profesi�n del empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ' es requerida' + '; ' + CHAR(13)

IF @exp_codpai_nacionalidad IS NOT NULL AND LTRIM(RTRIM(@exp_codpai_nacionalidad)) <> '' AND NOT EXISTS (SELECT NULL FROM gen.pai_paises WHERE pai_codigo = @exp_codpai_nacionalidad)
	SET @mensaje = @mensaje + 'No existe el pa�s de nacionalidad con el c�digo: ' + ISNULL(@exp_codpai_nacionalidad, 'Vac�o') + ' para el empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', revisar el cat�logo de pa�ses' + '; ' + CHAR(13)

IF @exp_fecha_nac_txt IS NULL OR LTRIM(RTRIM(@exp_fecha_nac_txt)) = ''
	SET @mensaje = @mensaje + 'La fecha de nacimiento del empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ' es requerida' + '; ' + CHAR(13)

IF ISDATE(@exp_fecha_nac_txt) = 0
	SET @mensaje = @mensaje + 'La fecha de nacimiento: ' + ISNULL(@exp_fecha_nac_txt, 'Vac�o') + ' del empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ' est� en un formato inv�lido, el formato debe ser DD/MM/YYYY' + '; ' + CHAR(13)

IF @exp_codpai_nacimiento IS NOT NULL AND LTRIM(RTRIM(@exp_codpai_nacimiento)) <> '' AND NOT EXISTS (SELECT NULL FROM gen.pai_paises WHERE pai_codigo = @exp_codpai_nacimiento)
	SET @mensaje = @mensaje + 'No existe el pa�s de nacimiento con el c�digo: ' + ISNULL(@exp_codpai_nacimiento, 'Vac�o') + ' para el empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', revisar el cat�logo de pa�ses' + '; ' + CHAR(13)

IF @exp_coddep_nac IS NOT NULL AND NOT EXISTS (SELECT NULL FROM gen.dep_departamentos WHERE dep_codigo = @exp_coddep_nac)
	SET @mensaje = @mensaje + 'No existe el departamento de nacimiento con el c�digo: ' + ISNULL(CONVERT(VARCHAR, @exp_coddep_nac), 'Vac�o') + ' para el empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', revisar el cat�logo de departamentos' + '; ' + CHAR(13)

IF @exp_codmun_nac IS NOT NULL AND NOT EXISTS (SELECT NULL FROM gen.mun_municipios WHERE mun_codigo = @exp_codmun_nac)
	SET @mensaje = @mensaje + 'No existe el municipio de nacimiento con el c�digo: ' + ISNULL(CONVERT(VARCHAR, @exp_codmun_nac), 'Vac�o') + ' para el empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', revisar el cat�logo de municipios' + '; ' + CHAR(13)

IF @exp_lugar_nac IS NOT NULL AND NOT EXISTS (SELECT NULL FROM gen.lug_lugares WHERE lug_codigo = @exp_lugar_nac)
	SET @mensaje = @mensaje + 'No existe el lugar de nacimiento con el c�digo: ' + ISNULL(CONVERT(VARCHAR, @exp_lugar_nac), 'Vac�o') + ' para el empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', revisar el cat�logo de lugares' + '; ' + CHAR(13)

SET @codtid_domicilio = gen.get_valor_parametro_int('CodigoTid_Domicilio', @exp_codpai_digita, NULL, NULL, NULL)

IF @dex_direccion IS NOT NULL AND LTRIM(RTRIM(@dex_direccion)) <> ''
BEGIN
	IF NOT EXISTS (SELECT NULL FROM exp.tid_tipos_direcciones WHERE tid_codigo = @codtid_domicilio)
		SET @mensaje = @mensaje + 'No existe el tipo de direcci�n de domicilio con el c�digo: ' + ISNULL(CONVERT(VARCHAR, @codtid_domicilio), 'Vac�o') + ', revisar el par�metro de aplicaci�n CodigoTid_Domicilio'

	--IF NOT EXISTS (SELECT NULL FROM gen.mun_municipios WHERE mun_codigo = @dex_codmun)
	--	SET @mensaje = @mensaje + 'No existe el municipio de residencia con el c�digo: ' + ISNULL(CONVERT(VARCHAR, @dex_codmun), 'Vac�o') + ' para el empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', revisar el cat�logo de municipios' + '; ' + CHAR(13)
END

IF @cbe_numero_cuenta IS NOT NULL AND LTRIM(RTRIM(@cbe_numero_cuenta)) <> ''
BEGIN
	IF NOT EXISTS (SELECT NULL FROM gen.bca_bancos_y_acreedores WHERE bca_codigo = @cbe_codbca)
		SET @mensaje = @mensaje + 'No existe el banco de la cuenta con el c�digo: ' + ISNULL(CONVERT(VARCHAR, @cbe_codbca), 'Vac�o') + ' para el empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', revisar el cat�logo de bancos' + '; ' + CHAR(13)

	IF NOT EXISTS (SELECT NULL FROM gen.mon_monedas WHERE mon_codigo = @cbe_codmon)
		SET @mensaje = @mensaje + 'No existe la moneda de la cuenta con el c�digo: ' + ISNULL(@cbe_codmon, 'Vac�o') + ' para el empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', revisar el cat�logo de monedas' + '; ' + CHAR(13)

	IF @cbe_tipo_cuenta NOT IN ('A', 'C')
		SET @mensaje = @mensaje + 'El tipo de cuenta: ' + ISNULL(@cbe_tipo_cuenta, 'Vac�o') + ' para el empleado: ' + ISNULL(@exp_codigo_alternativo, 'Vac�o') + ', tiene un valor inv�lido, el valor debe ser A o C' + '; ' + CHAR(13)
END

----------------------------------------------------------------
--           ajustes de tama�os de varchar m�ximos            --
----------------------------------------------------------------

IF LEN(@exp_codigo_alternativo) > 36
	SET @exp_codigo_alternativo = SUBSTRING(@exp_codigo_alternativo, 1, 36)

IF LEN(@exp_primer_nom) > 50
	SET @exp_primer_nom = SUBSTRING(@exp_primer_nom, 1, 50)

IF LEN(@exp_segundo_nom) > 50
	SET @exp_segundo_nom = SUBSTRING(@exp_segundo_nom, 1, 50)

IF LEN(@exp_primer_ape) > 50
	SET @exp_primer_ape = SUBSTRING(@exp_primer_ape, 1, 50)

IF LEN(@exp_segundo_ape) > 50
	SET @exp_segundo_ape = SUBSTRING(@exp_segundo_ape, 1, 50)

IF LEN(@exp_apellido_cas) > 50
	SET @exp_apellido_cas = SUBSTRING(@exp_apellido_cas, 1, 50)

IF LEN(@exp_otros_nom) > 50
	SET @exp_otros_nom = SUBSTRING(@exp_otros_nom, 1, 50)

IF LEN(@exp_nombre_usual) > 50
	SET @exp_nombre_usual = SUBSTRING(@exp_nombre_usual, 1, 50)

IF LEN(@exp_profesion) > 100
	SET @exp_profesion = SUBSTRING(@exp_profesion, 1, 100)

IF LEN(@exp_email) > 100
	SET @exp_email = SUBSTRING(@exp_email, 1, 100)

IF LEN(@exp_email_interno) > 100
	SET @exp_email_interno = SUBSTRING(@exp_email_interno, 1, 100)

IF LEN(@exp_telefono_movil) > 100
	SET @exp_telefono_movil = SUBSTRING(@exp_telefono_movil, 1, 100)

IF LEN(@exp_telefono_interno) > 100
	SET @exp_telefono_interno = SUBSTRING(@exp_telefono_interno, 1, 100)

IF LEN(@dex_direccion) > 150
	SET @dex_direccion = SUBSTRING(@dex_direccion, 1, 150)

IF LEN(@cbe_numero_cuenta) > 20
	SET @cbe_numero_cuenta = SUBSTRING(@cbe_numero_cuenta, 1, 20)

IF LEN(@mensaje) > 0
BEGIN
	RAISERROR(@mensaje, 16, 1)
	RETURN
END        
                 
---------------------------------------
--               INSERT	             --
---------------------------------------

SET @exp_fecha_nac = CONVERT(DATETIME, @exp_fecha_nac_txt)

INSERT INTO exp.exp_expedientes (
	exp_codigo_alternativo,
	exp_primer_ape,
	exp_segundo_ape,
	exp_apellido_cas,
	exp_primer_nom,
	exp_segundo_nom,
	exp_otros_nom,
	exp_nombre_usual,
	exp_codpai_nacionalidad,
	exp_codpai_nacimiento,
	exp_sexo,
	exp_profesion,
	exp_estado_civil,
	exp_fecha_nac,
	exp_codmun_nac,
	exp_coddep_nac,
	exp_lugar_nac,
	exp_email,
	exp_email_interno,
	exp_telefono_movil,
	exp_telefono_interno,
	exp_codpai_digita,
	exp_usuario_grabacion,
	exp_fecha_grabacion)
VALUES (@exp_codigo_alternativo,
	@exp_primer_ape,
	@exp_segundo_ape,
	@exp_apellido_cas,
	@exp_primer_nom,
	@exp_segundo_nom,
	@exp_otros_nom,
	@exp_nombre_usual,
	LOWER(@exp_codpai_nacionalidad),
	LOWER(@exp_codpai_nacimiento),
	UPPER(@exp_sexo),
	@exp_profesion,
	UPPER(@exp_estado_civil),
	@exp_fecha_nac,
	@exp_codmun_nac,
	@exp_coddep_nac,
	@exp_lugar_nac,
	@exp_email,
	@exp_email_interno,
	@exp_telefono_movil,
	@exp_telefono_interno,
	LOWER(@exp_codpai_digita),
	USER,
	GETDATE())

SELECT @codexp = exp_codigo
FROM exp.exp_expedientes
WHERE exp_codigo_alternativo = @exp_codigo_alternativo

IF @codexp IS NOT NULL AND @dex_direccion IS NOT NULL AND LTRIM(RTRIM(@dex_direccion)) <> ''
BEGIN
	INSERT INTO exp.dex_direcciones_expediente (
		dex_codexp,
		dex_codtid,
		dex_direccion,
		dex_codmun,
		dex_usuario_grabacion,
		dex_fecha_grabacion)
	VALUES (@codexp,
		@codtid_domicilio,
		@dex_direccion,
		@dex_codmun,
		USER,
		GETDATE())
END

IF @codexp IS NOT NULL AND @cbe_numero_cuenta IS NOT NULL AND LTRIM(RTRIM(@cbe_numero_cuenta)) <> ''
BEGIN
	INSERT INTO exp.cbe_cuentas_banco_exp (
		cbe_codexp,
		cbe_codbca,
		cbe_codmon,
		cbe_numero_cuenta,
		cbe_tipo_cuenta,
		cbe_usuario_grabacion,
		cbe_fecha_grabacion)
	VALUES (@codexp,
		@cbe_codbca,
		UPPER(@cbe_codmon),
		@cbe_numero_cuenta,
		UPPER(@cbe_tipo_cuenta),
		USER,
		GETDATE())
END

RETURN