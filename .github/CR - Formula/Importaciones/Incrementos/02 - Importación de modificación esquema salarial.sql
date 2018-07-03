begin transaction
declare @targetID int

select @targetID = tim_codigo
from cfg.tim_tabla_importacion
where tim_nombre = 'Importación modificación esquema salarial'

delete from cfg.cim_columna_importacion where cim_codtim = @targetID
delete from cfg.eim_ejecucion_importacion where eim_codtim = @targetID
delete from cfg.rim_role_importacion where rim_codtim = @targetID
delete from cfg.tim_tabla_importacion where tim_codigo = @targetID

insert into cfg.tim_tabla_importacion (tim_nombre, tim_tipo_objeto, tim_nombre_objeto, tim_tipo_archivo, tim_nombre_archivo, tim_nombre_archivo_log, tim_folder_archivo_log, tim_delimitador, tim_separador, tim_tiene_encabezados, tim_nombre_hoja, tim_formato_fecha_input, tim_formato_fecha_sql, tim_transaccion) values ('Importación modificación esquema salarial', 'Procedimiento', '[dbo].[migra_modif_esquema_sal]', 'CSV', 'C:\Users\Administrator\Desktop\plantilla modif esquema salarial.csv', '', '', 0, 44, 1, '', '{0:dd/MM/yyyy}', '{0:yyyy-MM-dd hh:mm:ss}', 1)
set @targetID = @@IDENTITY

insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) values(@targetID, '@codemp_', 'varchar', 0, 1, 'codigoAlternativoEmpleado', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) values(@targetID, '@codemp_solicita_', 'varchar', 0, 1, 'codigoAlternativoSolicitante', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) values(@targetID, '@codrsa', 'int', 0, 1, 'codigoRubroSalarial', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) values(@targetID, '@codtin', 'int', 0, 1, 'codigoTipoIncremento', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) values(@targetID, '@es_retroactivo', 'varchar', 0, 1, 'esRetroactivo', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) values(@targetID, '@fecha_vigencia', 'datetime', 0, 1, 'fechaVigencia', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) values(@targetID, '@Motivo', 'varchar', 0, 1, 'Motivo', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) values(@targetID, '@valor', 'money', 0, 1, 'Valor', 0, 0)

insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('Administrador', @targetID)
insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('Jefe', @targetID)
insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('Planilla', @targetID)
insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('Planilla RRHH', @targetID)
insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('RRHH asist', @targetID)
insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('RRHH Jefe', @targetID)
insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('Usuario', @targetID)

PRINT 'El codigo de la nueva plantilla es: ' + cast(@targetID as varchar)

commit transaction
