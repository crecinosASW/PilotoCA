DECLARE @codcia INT,
	@codtpl INT,
	@codfcu_principal INT,
	@codtdc_banco_popular INT,
	@codtdc_isr INT

SELECT @codfcu_principal = fcu_codigo
FROM sal.fcu_formulacion_cursores
WHERE fcu_codpai = 'cr'
	AND fcu_nombre = 'EmpleadosExtraordinaria'

BEGIN TRANSACTION

DELETE sal.fat_factores_tipo_planilla WHERE EXISTS (SELECT NULL FROM sal.tpl_tipo_planilla WHERE tpl_codigo = fat_codtpl AND tpl_codigo_visual IN ('9', '10'))
DELETE sal.ftp_formulacion_tipos_planilla WHERE EXISTS (SELECT NULL FROM sal.tpl_tipo_planilla WHERE tpl_codigo = ftp_codtpl AND tpl_codigo_visual IN ('9', '10'))

DECLARE tipos_planillas CURSOR FOR
SELECT tpl_codcia, tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codigo_visual IN ('9', '10')

OPEN tipos_planillas

FETCH NEXT FROM tipos_planillas INTO @codcia, @codtpl

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @codtdc_banco_popular = NULL
	SET @codtdc_isr = NULL

	SELECT @codtdc_banco_popular = tdc_codigo
	FROM sal.tdc_tipos_descuento	
	WHERE tdc_codcia = @codcia
		AND tdc_abreviatura = '2'

	SELECT @codtdc_isr = tdc_codigo
	FROM sal.tdc_tipos_descuento	
	WHERE tdc_codcia = @codcia
		AND tdc_abreviatura = '4'

	INSERT sal.ftp_formulacion_tipos_planilla (ftp_codtpl, ftp_prefijo, ftp_table_name, ftp_codfac_filtro, ftp_codfcu_loop, ftp_sp_inicializacion, ftp_sp_finalizacion, ftp_sp_autorizacion, ftp_lenguaje_factores, ftp_usuario_grabacion, ftp_fecha_grabacion, ftp_usuario_modificacion, ftp_fecha_modificacion) 
	VALUES (@codtpl, 'nex', 'cr.nex_nomina_extraordinaria', '4fa04322-896f-47ad-8bf6-2ba76cc1e9f9', @codfcu_principal, 'cr.Genpla_Inicializacion', 'cr.Genpla_Finalizacion', 'cr.Genpla_Autorizacion', 'VBScript', 'admin', '2014-09-01 09:50:47', 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:30:10')

	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '4fa04322-896f-47ad-8bf6-2ba76cc1e9f9', 1, NULL, NULL, NULL, 0, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:13:46')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '76f8f467-00df-4f43-8323-b4aeccff64cd', 2, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:13:46')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '8231cb96-25eb-47c3-abc0-9cb6e3375ba5', 3, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:13:46')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '6b25667a-4cfc-4d23-8273-781dea145360', 4, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:13:46')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '02bfaff3-34c4-4839-ac0b-ff8df997f6be', 5, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:13:46')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '3f8d9381-f4c5-48f8-8d6e-fc2763890f16', 6, NULL, @codtdc_banco_popular, NULL, 1, 'ASEINFOGUATEMAL\csoria', '2015-02-14 18:07:00', 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:13:46')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '078c36ef-c1c2-4c40-9362-0d4eab869f3d', 7, NULL, @codtdc_isr, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:13:46')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'b0b05405-9be6-43cb-8a53-9e434a182f42', 8, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:13:46')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '91571d54-bb8c-4903-ada7-653bff9b7bf5', 9, NULL, NULL, NULL, 1, 'admin', '2014-07-10 09:49:21', 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:13:46')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '65cf6909-ce86-4828-82c1-04f95dd56b6f', 10, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-19 12:13:46')

	FETCH NEXT FROM tipos_planillas INTO @codcia, @codtpl
END

CLOSE tipos_planillas
DEALLOCATE tipos_planillas

COMMIT