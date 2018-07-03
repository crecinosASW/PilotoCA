begin transaction

declare @targetID int,
	@maxid int

select @targetID = tim_codigo
from cfg.tim_tabla_importacion
where tim_nombre = 'Períodos de incapacidades'

delete from cfg.cim_columna_importacion where cim_codtim = @targetID
delete from cfg.eim_ejecucion_importacion where eim_codtim = @targetID
delete from cfg.rim_role_importacion where rim_codtim = @targetID
delete from cfg.tim_tabla_importacion where tim_codigo = @targetID

SELECT @maxid = ISNULL(MAX(tim_codigo), 0)
FROM cfg.tim_tabla_importacion

DBCC CHECKIDENT ('cfg.tim_tabla_importacion', RESEED, @maxid)

insert into cfg.tim_tabla_importacion (tim_nombre, tim_tipo_objeto, tim_nombre_objeto, tim_tipo_archivo, tim_nombre_archivo, tim_nombre_archivo_log, tim_folder_archivo_log, tim_delimitador, tim_separador, tim_tiene_encabezados, tim_nombre_hoja, tim_formato_fecha_input, tim_formato_fecha_sql, tim_transaccion) 
values ('Períodos de incapacidades', 'Procedimiento', '[acc].[imp_fin_fondos_incapacidad]', 'CSV', NULL, '', '', 0, 44, 1, '', '{0:dd/MM/yyyy}', '{0:yyyy-MM-dd hh:mm:ss}', 1)
set @targetID = @@IDENTITY

insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) 
values(@targetID, '@codemp_alternativo', 'varchar', 0, 1, 'Codigo de empleado', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) 
values(@targetID, '@desde_txt', 'varchar', 0, 1, 'Fecha inicial', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) 
values(@targetID, '@hasta_txt', 'varchar', 0, 1, 'Fecha final', 0, 0)
insert into cfg.cim_columna_importacion (cim_codtim, cim_nombre_columna, cim_tipo_dato, cim_es_llave, cim_permite_null, cim_nombre_celda, cim_posicion, cim_longitud) 
values(@targetID, '@dias', 'numeric', 0, 1, 'Dias', 0, 0)

insert into cfg.rim_role_importacion (rim_codrol, rim_codtim) values('Administrador', @targetID)

PRINT 'El codigo de la nueva plantilla es: ' + cast(@targetID as varchar)

commit transaction
