BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'cr_rep_finiquito_liquidacion.rdl')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'cr_rep_finiquito_liquidacion.rdl'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'3bb007d0-ed0f-4b01-9c2f-7c792b1c474c', N'LocalReportingServices', N'LocalReportingServices', N'cr_rep_finiquito_liquidacion.rdl', N'application/octet-stream', NULL, N'~/Reports/cr_rep_finiquito_liquidacion.rdl', NULL, NULL, NULL, NULL, CAST(0x0000A3AE00E54A88 AS DateTime), N'jcsoria')

COMMIT
