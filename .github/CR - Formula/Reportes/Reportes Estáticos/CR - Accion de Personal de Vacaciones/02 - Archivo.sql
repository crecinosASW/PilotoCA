BEGIN TRANSACTION

SET DATEFORMAT DMY

IF NOT EXISTS (SELECT NULL
			   FROM cfg.upf_upload_files
			   WHERE upf_nombre_archivo = 'cr_rep_accion_vacaciones.rdl')
BEGIN
	INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
	VALUES (N'24671c26-21f5-491b-bd24-306538b4e57d', N'LocalReportingServices', N'LocalReportingServices', N'cr_rep_accion_vacaciones.rdl', N'application/octet-stream', NULL, N'~/Reports/cr_rep_accion_vacaciones.rdl', NULL, NULL, CAST(0x0000A465011EAFCF AS DateTime), N'admin', NULL, NULL)
END

COMMIT