DECLARE @codcia INT,
	@codtpl INT,
	@codfcu_principal INT,
	@codtig_salario INT,
	@codtig_retroactivo INT,
	@codtig_vacaciones INT,
	@codtdc_banco_popular INT,
	@codtdc_isr INT

SELECT @codfcu_principal = fcu_codigo
FROM sal.fcu_formulacion_cursores
WHERE fcu_codpai = 'cr'
	AND fcu_nombre = 'Empleados'

BEGIN TRANSACTION

DELETE sal.fat_factores_tipo_planilla WHERE EXISTS (SELECT NULL FROM sal.tpl_tipo_planilla WHERE tpl_codigo = fat_codtpl AND tpl_codigo_visual IN ('1', '2', '3'))
DELETE sal.ftp_formulacion_tipos_planilla WHERE EXISTS (SELECT NULL FROM sal.tpl_tipo_planilla WHERE tpl_codigo = ftp_codtpl AND tpl_codigo_visual IN ('1', '2', '3'))

DECLARE tipos_planillas CURSOR FOR
SELECT tpl_codcia, tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codigo_visual IN ('1', '2', '3')

OPEN tipos_planillas

FETCH NEXT FROM tipos_planillas INTO @codcia, @codtpl

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @codtig_salario = NULL
	SET @codtig_retroactivo = NULL
	SET @codtig_vacaciones = NULL
	SET @codtdc_banco_popular = NULL
	SET @codtdc_isr = NULL

	SELECT @codtig_salario = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '1'

	SELECT @codtig_retroactivo = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '12'

	SELECT @codtig_vacaciones = tig_codigo
	FROM sal.tig_tipos_ingreso
	WHERE tig_codcia = @codcia
		AND tig_abreviatura = '10'

	SELECT @codtdc_banco_popular = tdc_codigo
	FROM sal.tdc_tipos_descuento	
	WHERE tdc_codcia = @codcia
		AND tdc_abreviatura = '2'

	SELECT @codtdc_isr = tdc_codigo
	FROM sal.tdc_tipos_descuento	
	WHERE tdc_codcia = @codcia
		AND tdc_abreviatura = '4'

	INSERT sal.ftp_formulacion_tipos_planilla (ftp_codtpl, ftp_prefijo, ftp_table_name, ftp_codfac_filtro, ftp_codfcu_loop, ftp_sp_inicializacion, ftp_sp_finalizacion, ftp_sp_autorizacion, ftp_lenguaje_factores, ftp_usuario_grabacion, ftp_fecha_grabacion, ftp_usuario_modificacion, ftp_fecha_modificacion) 
	VALUES (@codtpl, 'nqu', 'cr.nqu_nomina_quincenal', '138584C5-182B-407A-834E-1CACD3726900', 31, 'cr.Genpla_Inicializacion', 'cr.Genpla_Finalizacion', 'cr.Genpla_Autorizacion', 'VBScript', 'admin', '2014-09-01 09:50:47', 'ASEINFOGUATEMAL\csoria', '2015-02-26 17:39:54')

	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '138584C5-182B-407A-834E-1CACD3726900', 1, NULL, NULL, NULL, 0, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-25 19:51:27')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '24B03A26-2304-404D-8AB0-E05B66944507', 2, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-25 19:51:27')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '8be13de3-d771-48b6-8104-c4ed0fb3f346', 3, NULL, NULL, NULL, 1, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37', NULL, NULL)
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '26322A5C-2E2C-4E43-B245-9795A8EC2B24', 4, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'BA92629E-E0FD-439C-BAA9-74415954B58F', 5, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'D2091928-4505-43C4-ACA4-022CCFE1E5FB', 6, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'A17F3A43-305C-4CDB-AA15-A1790D6B483D', 7, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '6682FB47-7243-45E7-9C35-23F4F5CCFF53', 8, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '97DF903D-46A1-477D-921F-8E325484FF3C', 9, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'AEF1DE9A-77AC-4B4A-B977-5EB3195C01CF', 10, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'EE32616B-288B-4D37-A1BC-9F3BB4A28C33', 11, @codtig_salario, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '10521867-ECDF-4116-92CB-D7A2C8958A0E', 12, @codtig_salario, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '38BF0B7A-152F-4798-BD8A-099939CB84B8', 13, @codtig_retroactivo, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'FAE2287C-FF22-4466-927E-AAE805E36ECA', 14, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'BEFA07C4-F284-4DF6-8B76-57417CD8A65A', 15, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '8B1822AA-600A-4BF7-BA79-2C727613F8C5', 16, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'E4DF7856-77BE-49B8-BD75-65E5E13BD14C', 17, @codtig_vacaciones, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'a1f666e2-3cb0-4df9-85d4-2d6c40cbdcc6', 18, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '5938B934-34DA-4A2C-BD98-88C56B09FA8C', 19, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'A5161DEB-42C0-4E0E-8175-84ACDC79C626', 20, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '814219DD-1ED1-415F-BCAD-2ACFC7B3AB6B', 21, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'C032648D-F89E-4361-9722-AC9748783521', 22, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'd5a7e9b3-72b6-4af0-bc42-0a3d4707d6e1', 23, NULL, @codtdc_banco_popular, NULL, 1, 'ASEINFOGUATEMAL\csoria', '2015-02-14 18:07:00', 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '179c928d-42ce-4807-8e9d-187136471953', 24, NULL, NULL, NULL, 1, 'admin', '2014-06-27 14:41:38', 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'b83b0ff0-b3a6-45eb-a7c0-907f411ee4c2', 25, NULL, NULL, NULL, 1, 'admin', '2014-06-27 15:05:03', 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '4D6352C0-4CDF-4D5C-8035-7BE6B279F6B3', 26, NULL, @codtdc_isr, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '4D268117-9C6B-46BC-9146-60CCFD686DE3', 27, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'b9655754-cd27-4980-8749-94ad58c4d52f', 28, NULL, NULL, NULL, 1, 'ASEINFOGUATEMAL\csoria', '2015-02-14 18:52:23', 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '61281C0E-9C67-440B-9C1B-DC0BAE7397BD', 29, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '3BD0298B-4CD9-47FB-A492-E1A626A61E28', 30, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, 'A8FCD9E4-04EF-4DFD-B0E5-B9BB26C32BB7', 31, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '6c75d732-8e35-4906-a9d7-ee750473ba29', 32, NULL, NULL, NULL, 1, 'admin', '2014-07-10 09:49:21', 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')
	INSERT sal.fat_factores_tipo_planilla (fat_codtpl, fat_codfac, fat_precedencia, fat_codtig, fat_codtdc, fat_codtrs, fat_salva_en_tabla, fat_usuario_grabacion, fat_fecha_grabacion, fat_usuario_modificacion, fat_fecha_modificacion) 
	VALUES (@codtpl, '892C71C1-98ED-45A2-B0B9-9FBCA7F0974C', 33, NULL, NULL, NULL, 1, NULL, NULL, 'ASEINFOGUATEMAL\csoria', '2015-02-26 16:11:37')

	FETCH NEXT FROM tipos_planillas INTO @codcia, @codtpl
END

CLOSE tipos_planillas
DEALLOCATE tipos_planillas

COMMIT