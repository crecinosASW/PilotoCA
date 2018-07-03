BEGIN TRANSACTION
 
SET DATEFORMAT YMD

DECLARE @codcia INT,
	@codtpl INT,
	@codfcu_principal INT,
	@codtig_aguinaldo INT

SELECT @codfcu_principal = fcu_codigo
FROM sal.fcu_formulacion_cursores
WHERE fcu_codpai = 'cr'
	AND fcu_nombre = 'EmpleadosAguinaldo'
 
DELETE sal.fat_factores_tipo_planilla WHERE EXISTS (SELECT NULL FROM sal.tpl_tipo_planilla WHERE tpl_codigo = fat_codtpl AND tpl_codigo_visual IN ('5', '6', '7', '8'));
DELETE sal.ftp_formulacion_tipos_planilla WHERE EXISTS (SELECT NULL FROM sal.tpl_tipo_planilla WHERE tpl_codigo = ftp_codtpl AND tpl_codigo_visual IN ('5', '6', '7', '8'));

DECLARE tipos_planillas CURSOR FOR
SELECT tpl_codcia, tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codigo_visual IN ('5', '6', '7', '8')

OPEN tipos_planillas

FETCH NEXT FROM tipos_planillas INTO @codcia, @codtpl

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @codtig_aguinaldo = NULL
	
	SELECT @codtig_aguinaldo = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia 
		AND tig_abreviatura = '14'
 
	INSERT sal.ftp_formulacion_tipos_planilla (ftp_codtpl, ftp_prefijo, ftp_table_name, ftp_codfac_filtro, ftp_codfcu_loop, ftp_sp_inicializacion, ftp_sp_finalizacion, ftp_sp_autorizacion, ftp_lenguaje_factores, ftp_usuario_grabacion, ftp_fecha_grabacion, ftp_usuario_modificacion, ftp_fecha_modificacion) 
	VALUES (@codtpl, 'nag', 'cr.nag_nomina_aguinaldo', '6AA2D1E1-0245-47CE-8A9A-F624A04D8C59', @codfcu_principal, 'cr.Genpla_Inicializacion_Aguinaldo', 'cr.Genpla_Finalizacion_Aguinaldo', 'cr.Genpla_Autorizacion', 'VBScript', 'admin', GETDATE(), NULL, NULL)

	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '6AA2D1E1-0245-47CE-8A9A-F624A04D8C59', 1, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL)
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'F5DF5DA7-E114-4B1A-9620-67FF44FA2C2F', 2, @codtig_aguinaldo, NULL, NULL, 1, NULL, NULL, 'admin', '2014-08-20 12:11:54')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'E8C47224-8AE4-4280-AA2C-16031C4EBE51', 3, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL)
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'F85BCB44-0DAD-4408-848D-2D5D305234B5', 4, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL)
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'a4bcd369-48b6-40da-8926-b0bc58d87cf3', 5, NULL, NULL, NULL, 1, 'admin', '2014-08-20 12:16:43', 'admin', '2014-08-20 12:22:13')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '57c6bb8f-7577-4c38-967c-1c73f3619ec3', 6, NULL, NULL, NULL, 1, 'admin', '2014-08-20 12:22:13', 'admin', '2014-08-20 12:25:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '481C6FB9-2A0E-474F-9682-F21B23E8FA51', 7, NULL, NULL, NULL, 1, NULL, NULL, 'admin', '2014-08-20 12:25:59')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'b2c977a5-270a-4458-9b4d-30a6b000bd4b', 8, NULL, NULL, NULL, 1, 'admin', '2014-08-20 12:28:19', NULL, NULL)	
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '114C4EB5-0A98-4550-B685-E4114753ECF6', 9, NULL, NULL, NULL, 1, NULL, NULL, 'admin', '2014-08-20 12:28:19')

	FETCH NEXT FROM tipos_planillas INTO @codcia, @codtpl
END

CLOSE tipos_planillas
DEALLOCATE tipos_planillas

COMMIT