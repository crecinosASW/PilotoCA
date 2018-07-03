BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'CR - Constancia de Trabajo con Salario.docx')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'CR - Constancia de Trabajo con Salario.docx'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'e177ff5d-c818-4b89-9ec2-2754344fd8c7', N'WordTemplate', N'WordTemplate', N'CR - Constancia de Trabajo con Salario.docx', N'application/vnd.ms-word', NULL, N'~/UploadFile/WordTemplate/CR - Constancia de Trabajo con Salario.docx', NULL, NULL, CAST(0x0000A3AF00CBDB37 AS DateTime), N'admin', NULL, NULL)

COMMIT