BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'cr_rep_renta_anual.rpt')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'cr_rep_renta_anual.rpt'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'a4abb99f-5d5e-4bc3-a338-6d249a0987fc', N'CrystalReports', N'CrystalReports', N'cr_rep_renta_anual.rpt', N'application/octet-stream', NULL, N'~/Reports/cr_rep_renta_anual.rpt', NULL, NULL, CAST(0x0000A3A000BE3DBB AS DateTime), N'admin', NULL, NULL)

COMMIT