BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'cr_rep_desgloce_concepto.rdl')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'cr_rep_desgloce_concepto.rdl'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'68c130ca-0ad0-436d-9c1c-947efb59fea4', N'LocalReportingServices', N'LocalReportingServices', N'cr_rep_desgloce_concepto.rdl', N'application/octet-stream', NULL, N'~/Reports/cr_rep_desgloce_concepto.rdl', NULL, NULL, NULL, NULL, CAST(0x0000A44800EFB50A AS DateTime), N'admin')

COMMIT
