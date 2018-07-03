IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('acc.finaliza_contratacion'))
BEGIN
	DROP PROCEDURE acc.finaliza_contratacion
END

GO

CREATE PROCEDURE acc.finaliza_contratacion
    @codigo int
AS
DECLARE
    @codExp int,
	@codemp INT,
    @username varchar(50), --La logitud es de 50 igual que el usr_username
    @codUsuario int,
    @idRol varchar(50),
    @pais varchar(2),
	@regimen_vacacion REAL,
	@periodo VARCHAR(10),
	@emp_fecha_ingreso DATETIME,
    @mensaje varchar(255)
BEGIN
    ------------------------------------------------------------------------------
    --Validaciones
    ------------------------------------------------------------------------------
    --select @codExp = con_codexp
    --  from acc.con_contrataciones 
    -- where con_codigo = @codigo
    
    ----validando que no exista un usuario asociado al expediente
    --if exists (select 1 from sec.eus_expediente_usuario where eus_codexp = @codExp)
    --BEGIN
    --    --RAISERROR ('El usuario no fue creado, ya tiene uno.', 16, 1)
    --    RETURN
    --END;
                        
    ----validando si el nuevo empleado tiene un correo interno
    --if not exists(select 1  
    --                from exp.exp_expedientes
    --               where exp_codigo = @codExp 
    --                 and len(ltrim(rtrim(isnull(exp_email_interno, ''))) ) > 0)
    --BEGIN
    --    RAISERROR ('El usuario no fue creado, el empleado no tiene un correo interno.', 16, 1)
    --    RETURN
    --END

    --select @username = ltrim(rtrim(substring( substring(exp_email_interno, 0, charindex('@', exp_email_interno)), 0, 50)))
    --  from exp.exp_expedientes 
    -- where exp_codigo = @codExp
    
    --select @pais = cia_codpai
    --  from acc.con_contrataciones
    --  join eor.plz_plazas on plz_codigo = con_codplz
    --  join eor.cia_companias on cia_codigo = plz_codcia
    -- where con_codigo = @codigo

    ---- verificando si el usuario tiene subalternos para asignarle un rol jefe de lo contrario se le asigna un rol básico
    --if exists(select 1
    --            from eor.pjf_plaza_jefes 
    --            join eor.plz_plazas on pjf_codplz_jefe = plz_codigo 
    --            join exp.emp_empleos on emp_codplz = plz_codigo 
    --            join exp.exp_expedientes on exp_codigo = emp_codexp
    --           where exp_codigo = @codExp 
    --             and exists (select plz_codigo from eor.plz_plazas where plz_codigo = pjf_codplz and plz_estado != 'S'))
    --    select @idRol = gen.get_valor_parametro_varchar('RolJefe', @pais, null, null, null)
    --else
    --    select @idRol = gen.get_valor_parametro_varchar('RolUsuario', @pais, null, null, null)
    
    ----validando que el rol este configurado y que exista
    --if @idRol is null or not exists (select 1 from sec.rol_roles where rol_id = @idRol)
    --BEGIN
    --    RAISERROR ('El usuario no fue creado, el rol no esta configurado o el que se encuentra configurado no existe (Verificar parámetros de aplicación y los roles).', 16, 1)
    --    RETURN
    --END;
    
    ----Validando que el username no exista
    --if exists(select 1 from sec.usr_users where usr_username = @username)
    --BEGIN
    --    set @mensaje = 'El usuario no fue creado, username: ' + @username + ' ya existe. Modifique el usuario existente o el correo interno del nuevo empleado'
    --    RAISERROR (@mensaje, 16, 1)
    --    RETURN
    --END;
        
    --------------------------------------------------------------------------------
    ----Creando el usuario
    --------------------------------------------------------------------------------
    --begin transaction

    --insert into sec.usr_users
    --   (usr_username, usr_nombre_usuario, usr_activo, usr_modo_autenticacion, 
    --    usr_email, usr_password, 
    --    usr_pass_vence, usr_pass_cambiar_prox_acceso, usr_ver_mismo, usr_ver_subalternos, usr_ver_solo_subalt_inmediat,
    --    usr_estado_workflow, usr_codigo_workflow, usr_ingresado_portal)
    --select @username, substring(exp_apellidos_nombres, 0, 100), 1, 'A',
    --       substring(exp_email_interno, 0, 50), 'gNNUG5GTVoPucd/PTSHF41UCLi+wfxXTgcbhGlRFjJ0=', --UFM2012
    --       0, 1, 1, 1, 0,
    --       'Autorizado', null, 0
    --  from exp.exp_expedientes where exp_codigo = @codExp
    
    --insert into sec.eus_expediente_usuario (eus_codusr, eus_codexp)
    --select usr_codigo, @codExp from sec.usr_users where usr_username = @username
      
    ----asociando el rol al usuario creado
    --insert sec.rus_roles_users (rus_rol_id, rus_codusr) 
    --select @idRol, usr_codigo from sec.usr_users where usr_username = @username

    --commit transaction

	-- Actualiza el campo de RegimenVacacion del empleado
	SELECT @codemp = emp_codigo,
		@regimen_vacacion = gen.get_pb_field_data_float(con_property_bag_data, 'RegimenVacacion'),
		@emp_fecha_ingreso = emp_fecha_ingreso
	FROM acc.con_contrataciones
		JOIN exp.emp_empleos ON con_codexp = emp_codexp
	WHERE con_codigo = @codigo
		AND emp_estado = 'A'

	SET @periodo = CONVERT(VARCHAR, YEAR(@emp_fecha_ingreso)) + '-' + CONVERT(VARCHAR, YEAR(@emp_fecha_ingreso) + 1)

	IF ISNULL(@regimen_vacacion, 0.00) > 0.00
	BEGIN
		UPDATE exp.emp_empleos
		SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'RegimenVacacion', CONVERT(VARCHAR, @regimen_vacacion))
		WHERE emp_codigo = @codemp
	END

	UPDATE exp.emp_empleos
	SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'descuentaSeguroSocial', 'true')
	WHERE emp_codigo = @codemp
	
	UPDATE exp.emp_empleos
	SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'AplicaBancoPopular', 'true')
	WHERE emp_codigo = @codemp

	UPDATE exp.emp_empleos
	SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'descuentaRenta', 'true')
	WHERE emp_codigo = @codemp

	-- Crea el período de vacación inicial del empleado
	INSERT INTO acc.vac_vacaciones (
		vac_codemp,
		vac_periodo,
		vac_desde,
		vac_hasta,
		vac_periodo_anterior,
		vac_horas_periodo_anterior,
		vac_dias,
		vac_gozados,
		vac_horas_gozadas,
		vac_saldo,
		vac_horas_saldo)
	SELECT emp_codigo vac_codemp,
		@periodo vac_periodo,
		emp_fecha_ingreso vac_desde,
		emp_fecha_ingreso vac_hasta,
		0.00 vac_periodo_anterior,
		0.00 vac_horas_periodo_anterior,
		0.00 vac_dias,
		0.00 vac_gozados,
		0.00 vac_horas_gozadas,
		0.00 vac_saldo,
		0.00 vac_horas_saldo
	FROM exp.emp_empleos
	WHERE emp_codigo = @codemp
		AND NOT EXISTS (SELECT NULL
						FROM acc.vac_vacaciones
						WHERE emp_codigo = vac_codemp
							AND vac_periodo = @periodo)


END
