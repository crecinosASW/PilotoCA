IF EXISTS (SELECT 1 
		   FROM sys.objects p
		   WHERE object_id = object_id('cr.ide_ident_emp_v'))
BEGIN
	DROP VIEW cr.ide_ident_emp_v
END

GO

--SELECT * FROM cr.ide_ident_emp_v 
CREATE VIEW cr.ide_ident_emp_v

AS

SELECT ide_codexp, 
	MIN(ide_cip) ide_cip, 
	MIN(ide_cip_fecha) ide_cip_fecha,
	MIN(ide_cip_fecha_vencimiento) ide_cip_fecha_vencimiento,
	MIN(ide_cip_codpai) ide_cip_codpai,
	MIN(ide_cip_coddep) ide_cip_coddep,
	MIN(ide_cip_codmun) ide_cip_codmun,
	MIN(ide_isss) ide_isss,
	MIN(ide_nit) ide_nit,
	MIN(ide_nup) ide_nup,
	MIN(ide_codafp) ide_codafp,
	MIN(ide_pasaporte) ide_pasaporte,
	MIN(ide_vencimiento_pasaporte) ide_vencimiento_pasaporte,
	MIN(ide_residente) ide_residente,
	MIN(ide_residente_vence) ide_residente_vence,
	MIN(ide_permiso) ide_permiso,
	MIN(ide_nombre_cip) ide_nombre_cip,
	MIN(ide_nombre_afp) ide_nombre_afp,
	MIN(ide_nombre_isss) ide_nombre_isss,
	MIN(ide_nombre_nit) ide_nombre_nit
FROM (  
	SELECT ide_codexp,
		ide_cip,
		ide_cip_fecha,
		ide_cip_fecha_vencimiento,
		ide_cip_codpai,
		ide_cip_coddep,
		ide_cip_codmun,    
		ide_isss,
		ide_nit,
		ide_nup,
		ide_codafp,
		ide_pasaporte,
		ide_vencimiento_pasaporte,
		ide_residente,
		ide_residente_vence,
		CONVERT(VARCHAR, NULL) ide_permiso,
		ide_nombre_cip,
		ide_nombre_afp,
		ide_nombre_isss,
		ide_nombre_nit
	FROM exp.ide_ident_emp_v 
	
	UNION ALL

	SELECT exp_codigo ide_codexp,
		NULL ide_cip,
		NULL ide_cip_fecha,
		NULL ide_cip_fecha_vencimiento,
		NULL ide_cip_codpai,
		NULL ide_cip_coddep,
		NULL ide_cip_codmun,
		NULL ide_isss,
		NULL ide_nit,
		NULL ide_nup,
		gen.get_pb_field_data_INT(emp_property_bag_data, 'CodAfp') ide_codafp,
		NULL ide_pasaporte,
		NULL ide_vencimiento_pasaporte,
		NULL ide_residente,
		NULL ide_residente_vence,
		NULL ide_nombre_cip,
		ide_numero ide_permiso,
		NULL ide_nombre_afp,
		NULL ide_nombre_isss,
		NULL ide_nombre_nit
	FROM exp.emp_empleos 
		JOIN eor.plz_plazas ON plz_codigo = emp_codplz
		JOIN eor.cia_companias ON cia_codigo = plz_codcia
		JOIN exp.exp_expedientes ON exp_codigo = emp_codexp
		JOIN exp.ide_documentos_identificacion ON ide_codexp = exp_codigo
	WHERE ide_codtdo = gen.get_valor_parametro_INT('CodigoDoc_PermisoTrabajo', cia_codpai, NULL, NULL, NULL)) v1
GROUP BY ide_codexp


GO


