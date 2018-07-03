BEGIN TRANSACTION

SET DATEFORMAT YMD

IF NOT EXISTS (SELECT NULL FROM cfg.vli_value_lists WHERE vli_id = 'EmpleosActivosConCodigoAlternativoyEmpleo')
BEGIN
	INSERT cfg.vli_value_lists (vli_id, vli_description, vli_prompt, vli_value_source, vli_codfld, vli_enable_caching, vli_caching_expiration, vli_caching_expiration_mins, vli_definition, vli_fecha_grabacion, vli_usuario_grabacion, vli_fecha_modificacion, vli_usuario_modificacion) 
	VALUES ('EmpleosActivosConCodigoAlternativoyEmpleo', 'Lista de empleos activos con código alternativo y código de empleo (si tuviera más de uno)', 'Seleccionar', 'UseSqlExpressionInItemData', 'string', 0, 0, 0, '<List><Bound>
	SELECT 
		CASE 
			WHEN(SELECT COUNT(*) 
				 FROM exp.emp_empleos
				 WHERE emp_estado = ''A''
					 AND emp_codexp = exp_codigo 
				 GROUP BY emp_codexp) = 1  
			THEN exp_codigo_alternativo 
			ELSE exp_codigo_alternativo + CHAR(25) + CONVERT(VARCHAR, emp_codigo) 
		END Codigo_Empleado, 
		exp_apellidos_nombres + '' - '' + plz_nombre Empleado 
	FROM exp.emp_empleos 
		JOIN eor.plz_plazas ON plz_codigo = emp_codplz 
		JOIN exp.exp_expedientes ON exp_codigo = emp_codexp 
	WHERE emp_estado = ''A''
		AND plz_codcia = $$CODCIA$$
		AND sco.permiso_empleo(emp_codigo, ''$$USER$$'') = 1 
	ORDER BY 2
	</Bound></List>', NULL, NULL, '2014-05-12 12:05:44', 'admin')
END

IF NOT EXISTS (SELECT NULL FROM cfg.vli_value_lists WHERE vli_id = 'EmpleosRetirosConCodigoAlternativoyEmpleo')
BEGIN
	INSERT cfg.vli_value_lists (vli_id, vli_description, vli_prompt, vli_value_source, vli_codfld, vli_enable_caching, vli_caching_expiration, vli_caching_expiration_mins, vli_definition, vli_fecha_grabacion, vli_usuario_grabacion, vli_fecha_modificacion, vli_usuario_modificacion) 
	VALUES ('EmpleosRetirosConCodigoAlternativoyEmpleo', 'Lista de empleos retirados con código alternativo y código de empleo (si tuviera más de uno)', 'Seleccionar', 'UseSqlExpressionInItemData', 'string', 0, 0, 0, '<List><Bound>
	SELECT 
		CASE 
			WHEN(SELECT COUNT(*) 
				 FROM exp.emp_empleos
				 WHERE emp_estado = ''R''
					 AND emp_codexp = exp_codigo 
				 GROUP BY emp_codexp) = 1  
			THEN exp_codigo_alternativo 
			ELSE exp_codigo_alternativo + CHAR(25) + CONVERT(VARCHAR, emp_codigo) 
		END Codigo_Empleado, 
		exp_apellidos_nombres + '' - '' + plz_nombre + ISNULL('' ('' + CONVERT(VARCHAR, emp_fecha_retiro, 103) + '')'', '''') Empleado
	FROM exp.emp_empleos 
		JOIN eor.plz_plazas ON plz_codigo = emp_codplz 
		JOIN exp.exp_expedientes ON exp_codigo = emp_codexp 
	WHERE emp_estado = ''R''
		AND plz_codcia = $$CODCIA$$
		AND sco.permiso_empleo(emp_codigo, ''$$USER$$'') = 1 
	ORDER BY 2
	</Bound></List>', NULL, NULL, '2014-05-12 12:05:29', 'admin')
END

IF NOT EXISTS (SELECT NULL FROM cfg.vli_value_lists WHERE vli_id = 'EmpleosConCodigoAlternativoyEmpleo')
BEGIN
	INSERT cfg.vli_value_lists (vli_id, vli_description, vli_prompt, vli_value_source, vli_codfld, vli_enable_caching, vli_caching_expiration, vli_caching_expiration_mins, vli_definition, vli_fecha_grabacion, vli_usuario_grabacion, vli_fecha_modificacion, vli_usuario_modificacion) 
	VALUES ('EmpleosConCodigoAlternativoyEmpleo', 'Lista de empleos con código alternativo y código de empleo (si tuviera más de uno) de la compañía', 'Empleado', 'UseSqlExpressionInItemData', 'string', 0, 0, 0, '<List><Bound>
	SELECT 
		CASE 
			WHEN(SELECT COUNT(*) 
				 FROM exp.emp_empleos
				 WHERE emp_codexp = exp_codigo 
				 GROUP BY emp_codexp) = 1  
			THEN exp_codigo_alternativo 
			ELSE exp_codigo_alternativo + CHAR(25) + CONVERT(VARCHAR, emp_codigo) 
		END Codigo_Empleado, 
		exp_apellidos_nombres + '' - '' + plz_nombre + ISNULL('' ('' + CONVERT(VARCHAR, emp_fecha_retiro, 103) + '')'', '''') Empleado
	FROM exp.emp_empleos 
		JOIN eor.plz_plazas ON plz_codigo = emp_codplz 
		JOIN exp.exp_expedientes ON exp_codigo = emp_codexp 
	WHERE plz_codcia = $$CODCIA$$
		AND sco.permiso_empleo(emp_codigo, ''$$USER$$'') = 1 
	ORDER BY exp_apellidos_nombres ASC, emp_fecha_retiro DESC
	</Bound></List>', '2012-10-23 15:49:36', 'admin', '2014-05-12 12:08:10', 'admin')
END

IF NOT EXISTS (SELECT NULL FROM cfg.vli_value_lists WHERE vli_id = 'TiposJornadaLaboralINS')
BEGIN
	INSERT cfg.vli_value_lists (vli_id, vli_description, vli_prompt, vli_value_source, vli_codfld, vli_enable_caching, vli_caching_expiration, vli_caching_expiration_mins, vli_definition, vli_fecha_grabacion, vli_usuario_grabacion, vli_fecha_modificacion, vli_usuario_modificacion) 
	VALUES ('TiposJornadaLaboralINS', 'Tipos de jornada laboral para la planilla del I.N.S', 'Tipo', 'UseItemData', 'string', 0, 0, 0, '<List><Unbound><Item><ID>01</ID><Description>Tiempo Completo</Description></Item><Item><ID>02</ID><Description>Medio Tiempo</Description></Item><Item><ID>03</ID><Description>Ocasional</Description></Item><Item><ID>04</ID><Description>Por Jornales</Description></Item></Unbound></List>', '2014-09-05 14:11:16', 'admin', NULL, NULL)
END

IF NOT EXISTS (SELECT NULL FROM cfg.vli_value_lists WHERE vli_id = 'TiposJornadaLaboralCCSS')
BEGIN
	INSERT cfg.vli_value_lists (vli_id, vli_description, vli_prompt, vli_value_source, vli_codfld, vli_enable_caching, vli_caching_expiration, vli_caching_expiration_mins, vli_definition, vli_fecha_grabacion, vli_usuario_grabacion, vli_fecha_modificacion, vli_usuario_modificacion) 
	VALUES ('TiposJornadaLaboralCCSS', 'Tipos de jornada laboral para la planilla C.C.S.S', 'Tipo', 'UseItemData', 'string', 0, 0, 0, '<List><Unbound><Item><ID>DIU</ID><Description>Diurna</Description></Item><Item><ID>MIX</ID><Description>Mixta</Description></Item><Item><ID>NOC</ID><Description>Nocturna</Description></Item><Item><ID>PAR</ID><Description>Parcial</Description></Item><Item><ID>VES</ID><Description>Vespertina</Description></Item></Unbound></List>', '2014-09-08 15:48:45', 'jcsoria', NULL, NULL)
END

COMMIT

