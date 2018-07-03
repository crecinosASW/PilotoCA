BEGIN TRANSACTION

SET DATEFORMAT DMY

IF EXISTS (SELECT NULL
		   FROM cfg.upf_upload_files
		   WHERE upf_nombre_archivo = 'cr_rep_recibo_pago.rpt')
BEGIN
	DELETE FROM cfg.upf_upload_files WHERE upf_nombre_archivo = 'cr_rep_recibo_pago.rpt'
END

INSERT cfg.upf_upload_files (upf_codigo, upf_descripcion, upf_tipo, upf_nombre_archivo, upf_content_type, upf_contenido, upf_ruta, upf_nombre_corto, upf_descripcion_contenido, upf_fecha_grabacion, upf_usuario_grabacion, upf_fecha_modificacion, upf_usuario_modificacion) 
VALUES (N'6f140dca-05f6-46a0-876f-98b2c6c6e12d', N'CrystalReports', N'CrystalReports', N'cr_rep_recibo_pago.rpt', N'application/octet-stream', NULL, N'~/Reports/cr_rep_recibo_pago.rpt', NULL, NULL, NULL, NULL, CAST(0x0000A39D01108980 AS DateTime), N'admin')

COMMIT
