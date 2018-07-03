/*obtiene las acciones que se han realizado en determinado período de planilla. realiza las siguientes comparaciones para determinar las acciones a mostrar:
altas -> fecha de inicio entre periodo de planilla
bajas -> fecha de retiro entre periodo de planilla
incapacidades -> el período de incapacidad se intercepte con el período de planilla se pueden dar en 4 casos:
	- fecha inicio incapacidad <= fecha inicio planilla y fecha fin incapacidad entre fecha inicio planilla y fecha fin planilla
	- fecha inicio incapacidad <= fecha inicio planilla y fecha fin incapacidad >= fecha fin planilla
	- fecha inicio incapacidad entre fecha inicio planilla y fecha fin planilla y fecha fin incapacidad entre fecha inicio planilla y fecha fin planilla
	- fecha inicio incapacidad entre fecha inicio planilla y fecha fin planilla y fecha fin incapacidad >= fecha fin planilla
vacaciones -> el período de vacaciones se intercepte con el período de planilla, se comporta de la misma manera que el de incapacidades
tiempo no trabajado -> fecha de registro entre período de la planilla
incrementos salariales-> fecha de registro entre período de la planilla
incrementos bonificación decreto -> fecha de registro entre período de la planilla
incrementos bonificación -> fecha de registro entre período de la planilla (para deteriminar si es decreto o bonificación incentivo se válida que se encuentre en 0 el incremento de una de las dos)
amonestaciones -> fecha de registro entre período de la planilla*/                         
create or replace procedure rep_novedades_planilla
(
	v_codcia in number default null,
	v_codtpl_visual in varchar2 default null,
	v_codppl_visual in varchar2 default null,
	v_mes in number default null,
	v_anio in number default null,
	v_usuario in varchar2 default null,
	cv_1 out sys_refcursor
)
as
	v_ppl_fecha_inicio date;
	v_ppl_fecha_fin date;
	v_tipo_planilla varchar2(50);
	v_codtpl number(10,0);
	v_codppl number(10,0);

begin
	begin
    select tpl_codigo,
      tpl_descripcion 
    into v_codtpl,
      v_tipo_planilla
    from sal_tpl_tipo_planilla 
    where tpl_codcia = v_codcia
      and tpl_codigo_visual = v_codtpl_visual;
  exception
    when no_data_found then
      v_codtpl := null;
      v_tipo_planilla := null;
  end;       

	begin
    select ppl_codigo 
    into v_codppl
    from sal_ppl_periodos_planilla 
    where ppl_codigo_planilla = v_codppl_visual
      and ppl_codtpl = v_codtpl;
  exception
    when no_data_found then
      v_codppl := null;
  end;   

  begin
    select min(ppl_fecha_ini),
      max(ppl_fecha_fin) 
    into v_ppl_fecha_inicio,
      v_ppl_fecha_fin
    from sal_ppl_periodos_planilla 
    where ppl_codtpl = v_codtpl
      and ppl_codigo = nvl(v_codppl, ppl_codigo)
      and ppl_anio = nvl(v_anio, ppl_anio)
      and ppl_mes = nvl(v_mes, ppl_mes);
  exception
    when no_data_found then
      v_ppl_fecha_inicio := null;
      v_ppl_fecha_fin := null;
  end;         
		
	open cv_1 for
	select cia_descripcion,
		v_tipo_planilla tpl_descripcion,
		v_ppl_fecha_inicio ppl_fecha_inicio,
		v_ppl_fecha_fin ppl_fecha_fin,
		exp_codigo_alternativo,
		exp_apellidos_nombres,
		nov_fecha_inicio,
		nov_fecha_fin,
		nov_rubro,
		nov_valor,
		nov_tipo 
	from exp_emp_empleos e
		join exp_exp_expedientes on emp_codexp = exp_codigo
		join eor_plz_plazas on emp_codplz = plz_codigo
		join eor_cia_companias on plz_codcia = cia_codigo
		join (
			select emp_codigo nov_codemp,
				emp_fecha_ingreso nov_fecha_inicio,
				null nov_fecha_fin,
				null nov_rubro,
				null nov_valor,
				'Altas' nov_tipo  
			from exp_emp_empleos 
				join eor_plz_plazas on emp_codplz = plz_codigo
			where plz_codcia = v_codcia
				and emp_codtpl = v_codtpl
				and emp_fecha_ingreso between v_ppl_fecha_inicio and v_ppl_fecha_fin			
			union all 	
			select emp_codigo nov_codemp,
				emp_fecha_ingreso nov_fecha_inicio,
				null nov_fecha_fin,
				null nov_rubro,
				null nov_valor,
				'Bajas' nov_tipo  
			from exp_emp_empleos 
				join eor_plz_plazas on emp_codplz = plz_codigo
			where plz_codcia = v_codcia
				and emp_codtpl = v_codtpl
				and emp_fecha_retiro between v_ppl_fecha_inicio and v_ppl_fecha_fin	
			union all 			
			select emp_codigo nov_codemp,
				inc_fecha_solicitud nov_fecha_inicio,
				null nov_fecha_fin,
				rsa_descripcion nov_rubro,
				ese_valor - nvl(ese_valor_anterior, 0.00) nov_valor,
				'Incrementos Salariales' nov_tipo  
			from acc_inc_incrementos 
				join exp_emp_empleos on inc_codemp = emp_codigo
				join eor_plz_plazas on emp_codplz = plz_codigo
				join acc_idr_incremento_det_rubros on inc_codigo = idr_codinc
				join exp_rsa_rubros_salariales on idr_codrsa = rsa_codigo
				join exp_ese_estructura_sal_empleos on idr_codese = ese_codigo
			where plz_codcia = v_codcia
				and emp_codtpl = v_codtpl
				and inc_fecha_solicitud between v_ppl_fecha_inicio and v_ppl_fecha_fin
				and idr_valor > 0
			union all 	
			select emp_codigo nov_codemp,
				tnn_fecha_del nov_fecha_inicio,
				tnn_fecha_al nov_fecha_fin,
				null nov_rubro,
				null nov_valor,
				'Tiempo No Trabajado' nov_tipo  
			from sal_tnn_tiempos_no_trabajados 
				join exp_emp_empleos on tnn_codemp = emp_codigo
				join eor_plz_plazas on emp_codplz = plz_codigo
			where plz_codcia = v_codcia
				and emp_codtpl = v_codtpl
				and (((tnn_fecha_del between v_ppl_fecha_inicio and v_ppl_fecha_fin) and (tnn_fecha_al between v_ppl_fecha_inicio and v_ppl_fecha_fin))
					or ((tnn_fecha_del between v_ppl_fecha_inicio and v_ppl_fecha_fin) and (tnn_fecha_al >= v_ppl_fecha_fin))
					or ((tnn_fecha_del <= v_ppl_fecha_inicio) and (tnn_fecha_al between v_ppl_fecha_inicio and v_ppl_fecha_fin))
					or ((tnn_fecha_del <= v_ppl_fecha_inicio) and (tnn_fecha_al >= v_ppl_fecha_fin)))					
			union all 			
			select ixe_codemp nov_codemp,
				ixe_inicio nov_fecha_inicio,
				ixe_final nov_fecha_fin,
				null nov_rubro,
				null nov_valor,
				'Incapacidades' nov_tipo  
			from acc_ixe_incapacidades 
				join exp_emp_empleos on ixe_codemp = emp_codigo
				join eor_plz_plazas on emp_codplz = plz_codigo
			where plz_codcia = v_codcia
				and emp_codtpl = v_codtpl
				and (((ixe_inicio between v_ppl_fecha_inicio and v_ppl_fecha_fin) and (ixe_final between v_ppl_fecha_inicio and v_ppl_fecha_fin))
					or ((ixe_inicio between v_ppl_fecha_inicio and v_ppl_fecha_fin) and (ixe_final >= v_ppl_fecha_fin))
					or ((ixe_inicio <= v_ppl_fecha_inicio) and (ixe_final between v_ppl_fecha_inicio and v_ppl_fecha_fin))
					or ((ixe_inicio <= v_ppl_fecha_inicio) and (ixe_final >= v_ppl_fecha_fin)))			
			union all 			
			select vac_codemp nov_codemp,
				dva_desde nov_fecha_inicio,
				dva_hasta nov_fecha_fin,
				null nov_rubro,
				null nov_valor,
				'Vacaciones' nov_tipo  
			from acc_vac_vacaciones 
				join acc_dva_dias_vacacion on vac_codigo = dva_codvac
				join exp_emp_empleos on vac_codemp = emp_codigo
				join eor_plz_plazas on emp_codplz = plz_codigo
			where plz_codcia = v_codcia
				and emp_codtpl = v_codtpl
				and (((dva_desde between v_ppl_fecha_inicio and v_ppl_fecha_fin) and (dva_hasta between v_ppl_fecha_inicio and v_ppl_fecha_fin))
					or ((dva_desde between v_ppl_fecha_inicio and v_ppl_fecha_fin) and (dva_hasta >= v_ppl_fecha_fin))
					or ((dva_desde <= v_ppl_fecha_inicio) and (dva_hasta between v_ppl_fecha_inicio and v_ppl_fecha_fin))
					or ((dva_desde <= v_ppl_fecha_inicio) and (dva_hasta >= v_ppl_fecha_fin)))				
			union all 
			select amo_codemp nov_codemp,
				amo_inicio_suspension nov_fecha_inicio,
				amo_final_suspension nov_fecha_fin,
				null nov_rubro,
				null nov_valor,
				'Amonestaciones' nov_tipo  
			from acc_amo_amonestaciones 
				join exp_emp_empleos on amo_codemp = emp_codigo
				join eor_plz_plazas on emp_codplz = plz_codigo
			where plz_codcia = v_codcia
				and amo_codppl_suspension = v_codppl) novedades on emp_codigo = novedades.nov_codemp
	where sco.permiso_empleo(emp_codigo, v_usuario) = 1;
end rep_novedades_planilla;