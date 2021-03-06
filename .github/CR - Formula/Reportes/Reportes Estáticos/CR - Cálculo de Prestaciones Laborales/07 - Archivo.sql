BEGIN TRANSACTION

SET DATEFORMAT DMY

IF NOT EXISTS (SELECT NULL
			   FROM cfg.upf_upload_files
			   WHERE upf_nombre_archivo = 'cr_rep_calculo_liquidacion.rdl')
BEGIN
	INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
	VALUES (N'6bfdfce3-7f72-4f9f-89d5-d5d746a5cffa', N'LocalReportingServices', N'LocalReportingServices', N'cr_rep_calculo_liquidacion.rdl', N'application/octet-stream', NULL, N'~/Reports/cr_rep_calculo_liquidacion.rdl', NULL, NULL, CAST(0x0000A48100E8614C AS DateTime), N'admin', NULL, NULL)
END

COMMIT