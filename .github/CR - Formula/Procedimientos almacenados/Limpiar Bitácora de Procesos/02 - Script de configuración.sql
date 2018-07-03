SET DATEFORMAT YMD

DELETE FROM spx.bep_bitacora_ejecuciones_procedimientos WHERE bep_codstp = 'gt.limpia_bitacora_proc'
DELETE FROM spx.stp_store_procedures WHERE stp_codigo = 'gt.limpia_bitacora_proc'

INSERT [spx].[stp_store_procedures] ([stp_codigo], [stp_nombre_loc_key], [stp_descripcion_loc_key], [stp_proc_almacenado], [stp_orden], [stp_codpai], [stp_usuario_grabacion], [stp_fecha_grabacion], [stp_usuario_modificacion], [stp_fecha_modificacion]) 
VALUES ('gt.limpia_bitacora_proc', 'Limpia Bitácora de Procesos', 'Procedimiento para marcar como leídos los procesos que se hayan ejecutado exitosamente, para que solo aparezcan los procesos en los que haya ocurrido un error', 'gt.limpia_bitacora_proc', 80, NULL, 'admin', '2013-04-26 08:57:51', 'admin', '2013-04-26 08:59:35')

INSERT [spx].[spm_store_procedure_modulo] ([spm_codstp], [spm_codmod]) 
VALUES ('gt.limpia_bitacora_proc', 'Configuracion')

INSERT [spx].[spr_store_procedure_roles] ([spr_codstp], [spr_codrol]) 
VALUES ('gt.limpia_bitacora_proc', 'Administrador')