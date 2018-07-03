BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'cr_rep_planilla_bac_rev.rpt')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'cr_rep_planilla_bac_rev.rpt'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'a34773db-84cf-4814-9da7-335f1deec298', N'CrystalReports', N'CrystalReports', N'cr_rep_planilla_bac_rev.rpt', N'application/octet-stream', NULL, N'~/Reports/cr_rep_planilla_bac_rev.rpt', NULL, NULL, CAST(0x0000A3DC00BEC2F1 AS DateTime), N'admin', NULL, NULL)

COMMIT