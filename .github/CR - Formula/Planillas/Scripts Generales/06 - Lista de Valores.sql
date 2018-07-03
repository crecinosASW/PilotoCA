BEGIN TRANSACTION

IF NOT EXISTS (SELECT NULL FROM cfg.vli_value_lists WHERE vli_id = 'RegimenesVacacion')
BEGIN

INSERT cfg.vli_value_lists (vli_id, vli_description, vli_prompt, vli_value_source, vli_codfld, vli_enable_caching, vli_caching_expiration, vli_caching_expiration_mins, vli_definition, vli_fecha_grabacion, vli_usuario_grabacion, vli_fecha_modificacion, vli_usuario_modificacion) 
VALUES ('RegimenesVacacion', 'Reg�menes de vacaciones', 'R�gimen', 'UseItemData', 'double', 0, 0, 0, '<List><Unbound><Item><ID>12</ID><Description>12 d�as</Description></Item><Item><ID>14</ID><Description>14 d�as</Description></Item><Item><ID>15</ID><Description>15 d�as</Description></Item><Item><ID>16</ID><Description>16 d�as</Description></Item><Item><ID>20</ID><Description>20 d�as</Description></Item><Item><ID>30</ID><Description>30 d�as</Description></Item></Unbound></List>', '2015-02-13 15:04:08', 'admin', NULL, NULL)

END

COMMIT