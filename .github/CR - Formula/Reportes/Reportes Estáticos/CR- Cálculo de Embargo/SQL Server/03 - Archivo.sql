BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'cr_rep_calculo_embargo.rpt')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'cr_rep_calculo_embargo.rpt'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'f49b1e3d-11c9-432e-a3f0-1528de2436fc', N'CrystalReports', N'CrystalReports', N'cr_rep_calculo_embargo.rpt', N'application/octet-stream', NULL, N'~/Reports/cr_rep_calculo_embargo.rpt', NULL, NULL, NULL, NULL, CAST(0x0000A39C00D2B501 AS DateTime), N'admin')

COMMIT
