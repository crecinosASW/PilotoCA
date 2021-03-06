BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'rep_novedades_planilla.rpt')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'rep_novedades_planilla.rpt'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'96e6105c-c69f-4ca8-9e2f-68ab4eea76cc', N'CrystalReports', N'CrystalReports', N'rep_novedades_planilla.rpt', N'application/octet-stream', NULL, N'~/Reports/rep_novedades_planilla.rpt', NULL, NULL, '07/03/2014', N'admin', NULL, NULL)

COMMIT