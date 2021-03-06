BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'cr_rep_salarios_por_periodo.rdl')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'cr_rep_salarios_por_periodo.rdl'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'30bcdea7-a4ec-4156-b870-7d2fb99d8989', N'LocalReportingServices', N'LocalReportingServices', N'cr_rep_salarios_por_periodo.rdl', N'application/octet-stream', NULL, N'~/Reports/cr_rep_salarios_por_periodo.rdl', NULL, NULL, CAST(0x0000A44800B364BA AS DateTime), N'admin', NULL, NULL)

COMMIT
