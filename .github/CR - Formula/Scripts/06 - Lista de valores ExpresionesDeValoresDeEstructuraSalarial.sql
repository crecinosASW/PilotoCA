BEGIN TRANSACTION

IF EXISTS (SELECT NULL FROM cfg.vli_value_lists WHERE vli_id = 'ExpresionesDeValoresDeEstructuraSalarial')
	DELETE cfg.vli_value_lists WHERE vli_id = 'ExpresionesDeValoresDeEstructuraSalarial'

INSERT cfg.vli_value_lists (vli_id, vli_description, vli_prompt, vli_value_source, vli_codfld, vli_enable_caching, vli_caching_expiration, vli_caching_expiration_mins, vli_definition, vli_fecha_grabacion, vli_usuario_grabacion, vli_fecha_modificacion, vli_usuario_modificacion) 
VALUES ('ExpresionesDeValoresDeEstructuraSalarial', 'Lista las expresiones de los valores para las estructuras salariales de la contratación', 'expresion', 'UseItemData', 'string', 0, 0, 0, '<List><Unbound><Item><ID>Hora</ID><Description>Por Hora</Description></Item><Item><ID>Mensual</ID><Description>{ExpValorEstructuraSalarialMensual, Contratacion}</Description></Item><Item><ID>Diario</ID><Description>{ExpValorEstructuraSalarialDiario, Contratacion}</Description></Item></Unbound></List>', NULL, NULL, '2015-02-15 19:54:04', 'admin')

INSERT cfg.vlc_value_list_controllers (vlc_codvli, vlc_area, vlc_controller) 
VALUES ('ExpresionesDeValoresDeEstructuraSalarial', 'Reclutamiento', 'ConcursoSeleccion')
INSERT cfg.vlc_value_list_controllers (vlc_codvli, vlc_area, vlc_controller) 
VALUES ('ExpresionesDeValoresDeEstructuraSalarial', 'Acciones', 'Contratacion')
INSERT cfg.vlc_value_list_controllers (vlc_codvli, vlc_area, vlc_controller) 
VALUES ('ExpresionesDeValoresDeEstructuraSalarial', 'Acciones', 'RubroIncremento')
INSERT cfg.vlc_value_list_controllers (vlc_codvli, vlc_area, vlc_controller) 
VALUES ('ExpresionesDeValoresDeEstructuraSalarial', 'Solicitudes', 'RubroSolicitudIncremento')

--ROLLBACK
COMMIT