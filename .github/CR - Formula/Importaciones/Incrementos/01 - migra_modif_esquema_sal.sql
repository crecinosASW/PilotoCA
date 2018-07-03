create procedure migra_modif_esquema_sal
    @codemp_ varchar(36),
    @codtin int,                    --código del tipo de incremento
    @motivo varchar(200),
    @codemp_solicita_ varchar(36),  --código alternativo del solicitante
    @fecha_vigencia datetime,
    @es_retroactivo varchar(2),
    --@codtig int,                    --código del tipo de ingreso
    @valor money,
    @codrsa int                     --código del rubro salarial
as
begin
    
    declare
    @codemp int,
    @codemp_solicita int,
    @codcia int,
    @bit_retroactivo bit,
    @monto_anterior money = 0.00,
    @fecha_ini_anterior datetime,
    @codinc int = 0,
    @msg varchar(1000),
    @lote int = 1
    
    select top(1) @codemp=emp_codigo
    from exp.emp_empleos join exp.exp_expedientes on exp_codigo=emp_codexp
    where exp_codigo_alternativo=@codemp_ and emp_estado = 'A'
    
    select top(1) @codemp_solicita=emp_codigo
    from exp.emp_empleos join exp.exp_expedientes on exp_codigo=emp_codexp
    where exp_codigo_alternativo=@codemp_solicita_ and emp_estado = 'A'
    
    select @codcia=plz_codcia
    from exp.emp_empleos join eor.plz_plazas on plz_codigo=emp_codplz
    where emp_codigo=@codemp
    
    select @monto_anterior = ese_valor
    from exp.ese_estructura_sal_empleos
    where ese_codemp = @codemp 
        and ese_codrsa = @codrsa 
        and ese_estado = 'V'
    
    select @fecha_ini_anterior=ese_fecha_inicio
    from exp.ese_estructura_sal_empleos
    where ese_codemp = @codemp
        and ese_codrsa = @codrsa
        and ese_estado = 'V'
    
    if(upper(@es_retroactivo) = 'SI')        
        set @bit_retroactivo = 1
    else                        
        set @bit_retroactivo = 0
        
    if not exists(select 1 from exp.emp_empleos where emp_codigo=@codemp)
    begin
        set @msg = 'empleado: ''' + @codemp_ + ''' no existe'
        raiserror (@msg, 16, 1)
        return
    end
    
    if not exists(select 1 from exp.emp_empleos where emp_codigo=@codemp_solicita)
    begin
        set @msg = 'empleado solicitante: ''' + @codemp_solicita_ + ''' no existe'
        raiserror (@msg, 16, 1)
        return
    end
    
    if not exists(select 1 from acc.tin_tipos_incremento where tin_codcia=@codcia and tin_codigo=@codtin)
    begin
        set @msg = 'tipo de incremento: ''' + CONVERT(varchar, @codtin) + ''' no existe o no pertenece a la compañía ' + CONVERT(varchar, @codcia)
        raiserror (@msg, 16, 1)
        return
    end
    /*
    if not exists(select 1 from sal.tig_tipos_ingreso where tig_codcia=@codcia and tig_codigo=@codtig)
    begin
        set @msg = 'tipo de ingreso: ''' + CONVERT(varchar, @codtig) + ''' no existe o no pertenece a la compañía ' + CONVERT(varchar, @codcia)
        raiserror (@msg, 16, 1)
        return
    end
    */
    if @valor <= 0
    begin
        raiserror('el valor debe ser mayor a cero', 16, 1)
        return
    end
    
    if(@monto_anterior >= @valor)
    begin
        set @msg = 'el nuevo monto debe ser mayor al monto anterior (' + CONVERT(varchar, @monto_anterior) + ')'
        raiserror (@msg, 16, 1)
        return
    end
    
    if(@fecha_ini_anterior >= @fecha_vigencia)
    begin
        set @msg = 'fecha de vigencia no puede ser menor o igual a la fecha del registro vigente actual(' + CONVERT(varchar, @fecha_ini_anterior, 103) + ')'
        raiserror (@msg, 16, 1)
        return
    end
    
    if not exists(select 1 from exp.ese_estructura_sal_empleos
                        where ese_codemp = @codemp
                            and ese_codrsa = @codrsa
                            and ese_estado = 'V')
    begin
        raiserror ('no es posible modificar el rubro salarial, el empleado no cuenta con uno', 16, 1)
        return
    end
    
    select @lote=isnull(MAX(inc_lote_masivo), 0) + 1 
    from acc.inc_incrementos
    
    --INSERTANDO INCREMENTO--
    insert into acc.inc_incrementos (
                                        inc_lote_masivo, 
                                        inc_codtin, 
                                        inc_codemp, 
                                        inc_fecha_solicitud, 
                                        inc_motivo, 
                                        inc_estado, 
                                        inc_codemp_solicita,
                                        inc_codexp_digita, 
                                        inc_estado_workflow,
                                        inc_usuario_grabacion, 
                                        inc_fecha_grabacion
                                     )
                              values (
                                        @lote,
                                        @codtin,
                                        @codemp,
                                        GETDATE(),
                                        @motivo,
                                        'Autorizado',
                                        @codemp_solicita,
                                        NULL,
                                        'Autorizado',
                                        SYSTEM_USER,
                                        GETDATE()
                                     )
    
	--INSERTANDO DETALLE DEL INCREMENTO --
	select @codinc = isnull(max(inc_codigo), 0)
	from acc.inc_incrementos
	where inc_codemp = @codemp
    
    
    if(@codinc = 0)
    begin
        set @msg = 'el código del incremento esperado no fue encontrado, intentelo de nuevo'
        raiserror (@msg, 16, 1)
        return
    end
    
	insert into acc.idr_incremento_detalle_rubros(
	                                                idr_codinc, 
	                                                idr_codese, 
	                                                idr_accion, 
	                                                idr_fecha_vigencia, 
	                                                idr_fecha_fin, 
		                                            idr_es_retroactivo,
		                                            idr_codrsa,
		                                            idr_valor, 
		                                            idr_codmon, 
		                                            idr_valor_hora, 
		                                            idr_num_horas_x_mes, 
		                                            idr_exp_valor,
		                                            idr_codtig, 
		                                            idr_usuario_grabacion, 
		                                            idr_fecha_grabacion)
	                                select top(1) 
	                                                @codinc, 
		                                            ese_codigo, 
		                                            'Modificar', 
		                                            @fecha_vigencia, 
		                                            NULL,
		                                            @bit_retroactivo, 
		                                            ese_codrsa, 
		                                            @valor, 
		                                            ese_codmon, 
		                                            @valor / ese_num_horas_x_mes * (CASE ese_exp_valor WHEN 'Diario' THEN 30.00 WHEN 'Mensual' THEN 1.00 WHEN 'Hora' THEN ese_num_horas_x_mes END), 
		                                            ese_num_horas_x_mes, 
		                                            ese_exp_valor,
		                                            ese_codtig, 
		                                            SYSTEM_USER, 
		                                            GETDATE()
	                                from exp.ese_estructura_sal_empleos
	                                where ese_codemp = @codemp
		                                and ese_codrsa = @codrsa
		                                and ese_estado = 'V'
                                		
    --INSERTANDO ESTRUCTURA DE SALARIOS DEL EMPLEADO--
    insert into exp.ese_estructura_sal_empleos (
                                                ese_codemp,
                                                ese_codrsa,
                                                ese_valor,
                                                ese_codmon,
                                                ese_valor_hora,
                                                ese_num_horas_x_mes,
                                                ese_exp_valor,
                                                ese_valor_anterior,
                                                ese_fecha_inicio,
                                                ese_fecha_fin,
                                                ese_estado,
                                                ese_codtig,
                                                ese_usuario_grabacion,
                                                ese_fecha_grabacion
                                               )
                                        select 
                                                @codemp,
                                                @codrsa,
                                                @valor,
                                                ese_codmon,
                                                @valor / ese_num_horas_x_mes * (CASE ese_exp_valor WHEN 'Diario' THEN 30.00 WHEN 'Mensual' THEN 1.00 WHEN 'Hora' THEN ese_num_horas_x_mes END),
		                                        ese_num_horas_x_mes, 
		                                        ese_exp_valor,
		                                        ese_valor, 
		                                        @fecha_vigencia, 
		                                        NULL, 
		                                        'V', 
		                                        ese_codtig, 
		                                        SYSTEM_USER, 
		                                        GETDATE()
                                        from exp.ese_estructura_sal_empleos
                                        where ese_codemp = @codemp
                                            and ese_codrsa = @codrsa
                                            and ese_estado = 'V'
                                            
    --ACTUALIZAR EL ESQUEMA SALARIAL EXISTENTE DEL EMPLEADO SEGUN EL RUBRO QUE SE VA A MODIFICAR--
	update exp.ese_estructura_sal_empleos
	set ese_fecha_fin = @fecha_vigencia - 1,
		ese_estado = 'N',
		ese_usuario_modificacion = SYSTEM_USER,
		ese_fecha_modificacion = GETDATE()
	where ese_codemp = @codemp
		and ese_codrsa = @codrsa
		and ese_estado = 'V'
		and ese_fecha_inicio < @fecha_vigencia
		
end