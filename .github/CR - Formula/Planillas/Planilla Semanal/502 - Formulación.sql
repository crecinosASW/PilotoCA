DECLARE @codcia INT,
	@codtpl INT,
	@codfcu_principal INT,
	@codtig_salario INT,
	@codtig_vacaciones INT,
	@codtdc_bp INT,
	@codtdc_isr INT

SELECT @codfcu_principal = fcu_codigo
FROM sal.fcu_formulacion_cursores
WHERE fcu_codpai = 'cr'
	AND fcu_nombre = 'Empleados'

BEGIN TRANSACTION

DELETE sal.fat_factores_tipo_planilla WHERE EXISTS (SELECT NULL FROM sal.tpl_tipo_planilla WHERE tpl_codigo = fat_codtpl AND tpl_codigo_visual IN ('4'))
DELETE sal.ftp_formulacion_tipos_planilla WHERE EXISTS (SELECT NULL FROM sal.tpl_tipo_planilla WHERE tpl_codigo = ftp_codtpl AND tpl_codigo_visual IN ('4'))

DECLARE tipos_planillas CURSOR FOR
SELECT tpl_codcia, tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codigo_visual IN ('4')

OPEN tipos_planillas

FETCH NEXT FROM tipos_planillas INTO @codcia, @codtpl

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @codtig_salario = NULL
	SET @codtig_vacaciones = NULL
	SET @codtdc_bp = NULL
	SET @codtdc_isr = NULL
	
	SELECT @codtig_salario = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '1'

	SELECT @codtig_vacaciones = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '10'

	SELECT @codtdc_bp = tdc_codigo
	FROM sal.tdc_tipos_descuento
	WHERE tdc_codcia = @codcia
		AND tdc_abreviatura = '2'

	SELECT @codtdc_isr = tdc_codigo
	FROM sal.tdc_tipos_descuento
	WHERE tdc_codcia = @codcia
		AND tdc_abreviatura = '4'

	INSERT sal.ftp_formulacion_tipos_planilla (ftp_codtpl, ftp_prefijo, ftp_table_name, ftp_codfac_filtro, ftp_codfcu_loop, ftp_sp_inicializacion, ftp_sp_finalizacion, ftp_sp_autorizacion, ftp_lenguaje_factores, ftp_usuario_grabacion, ftp_fecha_grabacion, ftp_usuario_modificacion, ftp_fecha_modificacion) 
	VALUES (@codtpl, 'nse', 'cr.nse_nomina_semanal', 'f2c43129-55ca-4e41-8ba0-76cdcd196ac0', @codfcu_principal, 'cr.Genpla_Inicializacion', 'cr.Genpla_Finalizacion', 'cr.Genpla_Autorizacion', 'VBScript', 'admin', '2015-02-15 20:44:57', 'ASEINFOGUATEMAL\csoria', '2015-02-19 11:23:02')

	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'f2c43129-55ca-4e41-8ba0-76cdcd196ac0', 1, NULL, NULL, NULL, 0, 'admin', '2014-08-14 17:07:39', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '5452fadc-329b-4ec4-8222-ae3e1555941e', 2, NULL, NULL, NULL, 1, 'admin', '2014-08-14 13:51:44', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '4f10b2c1-eee5-4a98-b336-2a16db7c4bdd', 3, NULL, NULL, NULL, 1, 'admin', '2014-08-14 17:07:39', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'b529a4c9-9d70-49d3-a55b-3f019926fa23', 4, @codtig_salario, NULL, NULL, 1, 'ASEINFOGUATEMAL\csoria', '2015-02-15 23:19:02', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '0777d6c9-32bc-480e-abd2-a4b063cfb3c7', 5, NULL, NULL, NULL, 1, 'admin', '2014-08-14 17:07:39', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '2672e41e-a714-46d6-b3a9-fa55d384d652', 6, @codtig_vacaciones, NULL, NULL, 1, 'admin', '2014-08-14 17:07:39', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '93e3833e-4acb-4e30-9952-dc14b82b001c', 7, 9, NULL, NULL, 1, 'admin', '2014-08-18 13:34:29', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '50107445-fb44-467f-b4fc-d7e7c2ad9431', 8, NULL, NULL, NULL, 1, 'admin', '2014-08-18 13:43:35', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '734664ab-96db-40ed-84ce-2e8d01ce1681', 9, NULL, NULL, NULL, 1, 'admin', '2014-08-18 13:43:35', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'db75622a-f2d4-4254-acfb-b6c8cca3cff9', 10, NULL, NULL, NULL, 1, 'admin', '2014-08-18 14:12:37', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '076530dc-4f80-4881-aa81-2dc10a11534d', 11, NULL, NULL, NULL, 1, 'admin', '2014-08-18 14:12:37', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '504d1f26-ec7c-483d-a729-7a373bce8d0d', 12, NULL, @codtdc_bp, NULL, 1, 'ASEINFOGUATEMAL\csoria', '2015-02-18 12:09:51', 'ASEINFOGUATEMAL\csoria', '2015-02-19 11:21:17')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '41be1aef-7cab-4178-b5df-2949a94c19fa', 13, NULL, NULL, NULL, 1, 'admin', '2014-08-18 14:19:46', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'af2e81c7-e63b-4dab-b7b9-a58d53e5d902', 14, NULL, NULL, NULL, 1, 'admin', '2014-08-18 14:19:46', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '75933c24-8f2a-41fb-8428-2cd9005d23f3', 15, NULL, @codtdc_isr, NULL, 1, 'admin', '2014-08-18 15:32:23', 'ASEINFOGUATEMAL\csoria', '2015-02-19 11:21:17')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'acb41acd-d1bc-4eb5-8f0a-ec25d31450a2', 16, NULL, NULL, NULL, 1, 'admin', '2014-08-19 09:26:40', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '87962b99-2a2f-4a42-9255-23efcc803a77', 17, NULL, NULL, NULL, 1, 'admin', '2014-08-19 09:26:40', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'b9ce70b9-3c49-43f3-a139-791b62f0796a', 18, NULL, NULL, NULL, 1, 'admin', '2014-08-19 09:26:40', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '04b38a2a-3acb-4dc5-9e2b-ffb018a6eb81', 19, NULL, NULL, NULL, 1, 'admin', '2014-08-19 09:26:40', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '1e69acb9-0ccf-4da5-856f-a323de293656', 20, NULL, NULL, NULL, 1, 'ASEINFOGUATEMAL\csoria', '2015-02-18 12:58:38', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '866f1d72-ccd9-492a-be6b-a99d2a2a99fb', 21, NULL, NULL, NULL, 1, 'admin', '2014-08-19 09:29:31', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '586d541e-886d-4afc-8cfc-69088e626338', 22, NULL, NULL, NULL, 1, 'admin', '2014-08-19 09:30:48', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'ab6d8b70-f914-40d6-aad7-b3286b33e30f', 23, NULL, NULL, NULL, 1, 'admin', '2014-08-19 09:34:55', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'df202fb6-966a-4cdc-af8f-01c53f3ed018', 24, NULL, NULL, NULL, 1, 'admin', '2014-08-19 09:34:55', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'd85c798f-4788-4ba3-b9e9-e19932efa854', 25, NULL, NULL, NULL, 1, 'admin', '2014-08-19 09:34:55', 'ASEINFOGUATEMAL\csoria', '2015-02-19 10:55:59')

	FETCH NEXT FROM tipos_planillas INTO @codcia, @codtpl
END

CLOSE tipos_planillas
DEALLOCATE tipos_planillas

COMMIT