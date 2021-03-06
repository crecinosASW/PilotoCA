BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'cr_rep_cheques_planilla.rpt')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'cr_rep_cheques_planilla.rpt'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'53e6138f-f9ac-4950-b092-21d1b3a36056', N'CrystalReports', N'CrystalReports', N'cr_rep_cheques_planilla.rpt', N'application/octet-stream', NULL, N'~/Reports/cr_rep_cheques_planilla.rpt', NULL, NULL, CAST(0x0000A39D00B05D07 AS DateTime), N'admin', NULL, NULL)

COMMIT
