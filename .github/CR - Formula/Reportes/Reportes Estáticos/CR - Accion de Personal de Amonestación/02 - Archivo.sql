BEGIN TRANSACTION

SET DATEFORMAT DMY

IF NOT EXISTS (SELECT NULL
			   FROM cfg.upf_upload_files
			   WHERE upf_nombre_archivo = 'cr_rep_accion_amonestacion.rdl')
BEGIN
	INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
	VALUES (N'6f18083b-4c87-4b96-b4fa-21babd2f6050', N'LocalReportingServices', N'LocalReportingServices', N'cr_rep_accion_amonestacion.rdl', N'application/octet-stream', NULL, N'~/Reports/cr_rep_accion_amonestacion.rdl', NULL, NULL, CAST(0x0000A46500A695F4 AS DateTime), N'admin', NULL, NULL)
END

COMMIT