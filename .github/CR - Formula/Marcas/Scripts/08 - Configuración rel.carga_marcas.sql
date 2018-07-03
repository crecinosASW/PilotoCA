/*
IMPORTANTE: La plantilla de importación de carga de marcas debe ser el código 1, este procedimiento sobreescribe la plantilla que se encuentre
			con el código 1, si la plantilla no es la de marcas, se debe copiar la configuración de esa plantilla y crearla nuevamente antes de
			ejecutar este script.

SELECT * FROM cfg.tim_tabla_importacion WHERE tim_codigo = 1
*/

begin transaction

declare @targetID int,
	@maxid int

select @targetID = tim_codigo
from cfg.tim_tabla_importacion
where tim_nombre = 'Importación de marcas de asistencia'

delete from cfg.cim_columna_importacion where cim_codtim = @targetID
delete from cfg.eim_ejecucion_importacion where eim_codtim = @targetID
delete from cfg.rim_role_importacion where rim_codtim = @targetID
delete from cfg.tim_tabla_importacion where tim_codigo = @targetID

set @targetID = 1

set identity_insert cfg.tim_tabla_importacion on
insert into cfg.tim_tabla_importacion (tim_codigo, tim_nombre, tim_tipo_objeto, tim_nombre_objeto, tim_tipo_archivo, tim_nombre_archivo, tim_nombre_archivo_log, tim_folder_archivo_log, tim_delimitador, tim_separador, tim_tiene_encabezados, tim_nombre_hoja, tim_formato_fecha_input, tim_formato_fecha_sql, tim_transaccion) 
values (@targetID, 'Importación de marcas de asistencia', 'Procedimiento', '[rel].[carga_marcas]', 'CSV', '', '', '', 0, 44, 0, '', '{0:dd/MM/yyyy}', '{0:yyyy-MM-dd hh:mm:ss}', 0)
set identity_insert cfg.tim_tabla_importacion off

insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) 
values(@targetID, '@codexp_alternativo', 'varchar', 0, 1, 'Columna4', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) 
values(@targetID, '@codrel', 'varchar', 0, 1, 'Columna3', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) 
values(@targetID, '@fecha_txt', 'varchar', 0, 1, 'Columna1', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) 
values(@targetID, '@hora_txt', 'varchar', 0, 1, 'Columna2', 0, 0)

insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('Administrador', @targetID)
insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('Planilla', @targetID)
insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('RRHH asist', @targetID)
insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('RRHH Jefe', @targetID)

PRINT 'El codigo de la nueva plantilla es: ' + cast(@targetID as varchar)

commit transaction