BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'CR - Constancia de Vacaciones.docx')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'CR - Constancia de Vacaciones.docx'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'23d88b41-9bde-49f9-a2bd-c3af5997839a', N'WordTemplate', N'WordTemplate', N'CR - Constancia de Vacaciones.docx', N'application/vnd.ms-word', NULL, N'~/UploadFile/WordTemplate/CR - Constancia de Retiro.docx', NULL, NULL, CAST(0x0000A3AF00CC1220 AS DateTime), N'admin', NULL, NULL)

COMMIT