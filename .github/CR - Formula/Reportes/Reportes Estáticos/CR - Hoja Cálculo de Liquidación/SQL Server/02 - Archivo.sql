BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'cr_rep_hoja_calculo_liq.rpt')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'cr_rep_hoja_calculo_liq.rpt'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'996c582e-ef5b-4a34-81bf-ee9b14c6c7ad', N'CrystalReports', N'CrystalReports', N'cr_rep_hoja_calculo_liq.rpt', N'application/octet-stream', NULL, N'~/Reports/cr_rep_hoja_calculo_liq.rpt', NULL, NULL, NULL, NULL, CAST(0x0000A3A100F627BA AS DateTime), N'admin')

COMMIT