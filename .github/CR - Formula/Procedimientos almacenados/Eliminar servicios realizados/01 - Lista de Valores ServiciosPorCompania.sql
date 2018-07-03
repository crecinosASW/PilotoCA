IF NOT EXISTS (SELECT 1 FROM cfg.vli_value_lists WHERE vli_id = 'ServiciosPorCompania')
BEGIN
	INSERT [cfg].[vli_value_lists] ([vli_id], [vli_description], [vli_prompt], [vli_value_source], [vli_codfld], [vli_enable_caching], [vli_caching_expiration], [vli_caching_expiration_mins], [vli_definition], [vli_fecha_grabacion], [vli_usuario_grabacion], [vli_fecha_modificacion], [vli_usuario_modificacion]) 
	VALUES ('ServiciosPorCompania', 'Todos los servicios de una compañía', 'Servicio', 'UseSqlExpressionInItemData', 'int', 0, 0, 0, '<List><Bound>
	SELECT srv_codigo, srv_descripcion
	FROM sal.srv_servicios
		JOIN sal.gsr_grupos_servicio ON srv_codgsr = gsr_codigo
		JOIN sal.csr_categorias_servicio ON gsr_codcsr = csr_codigo
	WHERE csr_codcia = $$CODCIA$$
		AND sco.permiso_compania(csr_codcia, ''$$USER$$'') = 1
	  </Bound></List>', '2014-02-27 09:22:18', 'admin', NULL, NULL)
END