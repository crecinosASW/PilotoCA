BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'CR - Constancia de Trabajo con Salario Promedio.docx')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'CR - Constancia de Trabajo con Salario Promedio.docx'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'86d6d745-f5cd-4672-9802-8133beb86ba2', N'WordTemplate', N'WordTemplate', N'CR - Constancia de Trabajo con Salario Promedio.docx', N'application/vnd.ms-word', NULL, N'~/UploadFile/WordTemplate/CR - Constancia de Trabajo con Salario Promedio.docx', NULL, NULL, NULL, NULL, CAST(0x0000A479010197D7 AS DateTime), N'admin')

COMMIT