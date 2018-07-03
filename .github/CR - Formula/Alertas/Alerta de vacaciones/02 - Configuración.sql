-- Script generado por Procedimiento 'cfg.generar_script_alertas' el Mar 11 2015 12:53PM
BEGIN TRANSACTION

DELETE cfg.ale_alertas WHERE ale_codigo = '18e85de9-7721-4139-baf6-86756cff4812';

INSERT INTO cfg.ale_alertas(ALE_CODIGO, ALE_TITULO, ALE_DESCRIPCION, ALE_MENSAJE, ALE_FECHA_INI, ALE_FECHA_FIN, ALE_ESTADO, ALE_ASOC_DESTINATARIOS, ALE_NOMBRE_PROCEDIMIENTO, ALE_DATA_DESTINATARIO, ALE_TEXTO_RESUMEN, ALE_ES_AUTOMATICA, ALE_EJECUTA_UNA_VEZ, ALE_CRON_EXPRESSION, ALE_DESC_PROGRAMACION, ALE_FRECUENCIA, ALE_MES_OCURRE_DIA_DEL_MES, ALE_OCURRE_CADA, ALE_DIA_DEL_MES, ALE_DIA_DE_LA_SEMANA, ALE_SEMANA_DEL_MES, ALE_DIAS_SEMANA_FLAG, ALE_OCURRE_UNA_VEZ_AL_DIA, ALE_OCURRE_A_ESTA_HORA, ALE_OCURRE_CADA_HORAS_MINS, ALE_SON_HORAS, ALE_OCURRE_HORA_INCIO, ALE_OCURRE_HORA_FINAL, ALE_MESES_ANIO_FLAG, ALE_USUARIO_GRABACION, ALE_FECHA_GRABACION, ALE_USUARIO_MODIFICACION, ALE_FECHA_MODIFICACION) 
VALUES ('18e85de9-7721-4139-baf6-86756cff4812','Actualización de saldos de vacaciones','Muestra los empleados que se les actualizó el saldo de las vacaciones','',convert(datetime,'01/01/2015',103),convert(datetime, '',103),'Pendiente', 'NingunoIncluyendo', 'acc.alerta_act_vacaciones',0,'Se actualizó el saldo de vacaciones a {0} empleados',1,1,'0 0 1 * * ?','Ocurre todos los días, a las 1:00 a.m. Vigente a partir del 01/01/2015','Diaria',0,1,NULL,NULL,1,'0000000',1,convert(datetime, '11 Mar 2015 01:00:00:000',113),NULL,NULL,convert(datetime, '11 Mar 2015 08:00:00:000',113),convert(datetime, '11 Mar 2015 17:59:00:000',113),'000000000000','admin',convert(datetime, '11/03/2015',103),'',convert(datetime, '',103));

INSERT INTO cfg.RAL_ROLES_ALERTA(RAL_CODALE, RAL_CODROL) VALUES ('18e85de9-7721-4139-baf6-86756cff4812','Administrador');

COMMIT