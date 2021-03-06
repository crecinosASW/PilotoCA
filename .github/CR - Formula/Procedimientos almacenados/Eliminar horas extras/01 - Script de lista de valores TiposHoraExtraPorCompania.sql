IF NOT EXISTS (SELECT 1
			   FROM cfg.vli_value_lists
			   WHERE vli_id = 'TiposHoraExtraPorCompania')
BEGIN			   
	INSERT [cfg].[vli_value_lists] ([vli_id], [vli_description], [vli_prompt], [vli_value_source], [vli_codfld], [vli_enable_caching], [vli_caching_expiration], [vli_caching_expiration_mins], [vli_definition], [vli_fecha_grabacion], [vli_usuario_grabacion], [vli_fecha_modificacion], [vli_usuario_modificacion]) 
	VALUES ('TiposHoraExtraPorCompania', 'Lista de todos los tipos de hora extra por compa��a', 'Tipo', 'UseSqlExpressionInItemData', 'int', 0, 0, 0, '<List><Bound>
	SELECT the_codigo, the_nombre
	FROM sal.the_tipos_hora_extra
	WHERE the_codcia = $$CODCIA$$
		AND sco.permiso_compania(the_codcia, ''$$USER$$'') = 1
	  </Bound></List>', '2013-04-12 14:18:17', 'csoria', NULL, NULL)
END
