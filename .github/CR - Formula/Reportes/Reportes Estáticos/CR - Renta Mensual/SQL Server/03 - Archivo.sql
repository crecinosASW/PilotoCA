BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'cr_rep_renta_mensual.rpt')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'cr_rep_renta_mensual.rpt'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'0cea0e3e-08c8-4471-b3eb-7fab8c8d410d', N'CrystalReports', N'CrystalReports', N'cr_rep_renta_mensual.rpt', N'application/octet-stream', NULL, N'~/Reports/cr_rep_renta_mensual.rpt', NULL, NULL, NULL, NULL, CAST(0x0000A3A0009C3989 AS DateTime), N'admin')

COMMIT
