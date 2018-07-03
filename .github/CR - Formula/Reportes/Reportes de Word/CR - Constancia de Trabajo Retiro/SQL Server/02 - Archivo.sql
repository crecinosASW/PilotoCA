BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'CR - Constancia de Retiro.docx')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'CR - Constancia de Retiro.docx'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'7e7c1480-e610-47c2-8a2c-9815be2a3265', N'WordTemplate', N'WordTemplate', N'CR - Constancia de Retiro.docx', N'application/vnd.ms-word', NULL, N'~/UploadFile/WordTemplate/CR - Constancia de Retiro.docx', NULL, NULL, CAST(0x0000A3AF00CBFA75 AS DateTime), N'admin', NULL, NULL)

COMMIT