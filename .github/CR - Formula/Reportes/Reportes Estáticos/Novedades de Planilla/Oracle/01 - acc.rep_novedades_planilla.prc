create or replace
PROCEDURE rep_novedades_planilla (
	codcia IN NUMBER DEFAULT NULL,
	codtpl_visual IN VARCHAR2 DEFAULT NULL,
	codppl_visual IN VARCHAR2 DEFAULT NULL,
	mes IN NUMBER DEFAULT NULL,
	anio IN NUMBER DEFAULT NULL,
	usuario IN VARCHAR2 DEFAULT NULL,
	cv OUT SYS_REFCURSOR
) 
AS
	ppl_fecha_inicio DATE;
	ppl_fecha_fin DATE;
	tipo_planilla VARCHAR2(50);
	codtpl NUMBER(10,0);
	codppl NUMBER(10,0);

BEGIN
	BEGIN
		SELECT tpl_codigo,
			tpl_descripcion 
		INTO codtpl,
			tipo_planilla
		FROM sal_tpl_tipo_planilla 
		WHERE tpl_codcia = codcia
			AND tpl_codigo_visual = codtpl_visual;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	        NULL;
	END; 

	BEGIN
		SELECT ppl_codigo 
		INTO codppl
		FROM sal_ppl_periodos_planilla 
		WHERE ppl_codigo_planilla = codppl_visual
			AND ppl_codtpl = codtpl;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	        NULL;
	END; 

	BEGIN
		SELECT MIN(ppl_fecha_ini),
			MAX(ppl_fecha_fin) 
		INTO ppl_fecha_inicio,
			ppl_fecha_fin
		FROM sal_ppl_periodos_planilla 
		WHERE ppl_codtpl = codtpl
			AND ppl_codigo = NVL(codppl, ppl_codigo)
			AND ppl_anio = NVL(anio, ppl_anio)
			AND ppl_mes = NVL(mes, ppl_mes);
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	        NULL;
	END; 			
		
	OPEN cv FOR
	SELECT cia_descripcion,
		tipo_planilla tpl_descripcion,
		ppl_fecha_inicio ppl_fecha_inicio,
		ppl_fecha_fin ppl_fecha_fin,
		exp_codigo_alternativo,
		exp_apellidos_nombres,
		nov_fecha_inicio,
		nov_fecha_fin,
		nov_rubro,
		nov_valor,
		nov_tipo 
	FROM exp_emp_empleos e
		JOIN exp_exp_expedientes ON emp_codexp = exp_codigo
		JOIN eor_plz_plazas ON emp_codplz = plz_codigo
		JOIN eor_cia_companias ON plz_codcia = cia_codigo
		JOIN (
			SELECT emp_codigo nov_codemp,
				emp_fecha_ingreso nov_fecha_inicio,
				NULL nov_fecha_fin,
				NULL nov_rubro,
				NULL nov_valor,
				'Altas' nov_tipo  
			FROM exp_emp_empleos 
				JOIN eor_plz_plazas ON emp_codplz = plz_codigo
			WHERE plz_codcia = codcia
				AND emp_codtpl = codtpl
				AND emp_fecha_ingreso BETWEEN ppl_fecha_inicio AND ppl_fecha_fin
			UNION ALL 
			SELECT emp_codigo nov_codemp,
				emp_fecha_ingreso nov_fecha_inicio,
				NULL nov_fecha_fin,
				NULL nov_rubro,
				NULL nov_valor,
				'Bajas' nov_tipo  
			FROM exp_emp_empleos 
				JOIN eor_plz_plazas ON emp_codplz = plz_codigo
			WHERE plz_codcia = codcia
				AND emp_codtpl = codtpl
				AND emp_fecha_retiro BETWEEN ppl_fecha_inicio AND ppl_fecha_fin
			UNION ALL 
			SELECT emp_codigo nov_codemp,
				inc_fecha_solicitud nov_fecha_inicio,
				NULL nov_fecha_fin,
				rsa_descripcion nov_rubro,
				ese_valor - NVL(ese_valor_anterior, 0.00) nov_valor,
				'Incrementos salariales' nov_tipo  
			FROM acc_inc_incrementos 
				JOIN exp_emp_empleos ON inc_codemp = emp_codigo
				JOIN eor_plz_plazas ON emp_codplz = plz_codigo
				JOIN acc_idr_incremento_det_rubros ON inc_codigo = idr_codinc
				JOIN exp_rsa_rubros_salariales ON idr_codrsa = rsa_codigo
				JOIN exp_ese_estructura_sal_empleos ON idr_codese = ese_codigo
			WHERE plz_codcia = codcia
				AND emp_codtpl = codtpl
				AND inc_fecha_solicitud BETWEEN ppl_fecha_inicio AND ppl_fecha_fin
				AND idr_valor > 0
			UNION ALL 
			SELECT emp_codigo nov_codemp,
				tnn_fecha_del nov_fecha_inicio,
				tnn_fecha_al nov_fecha_fin,
				NULL nov_rubro,
				NULL nov_valor,
				'Tiempo no trabajado' nov_tipo  
			FROM sal_tnn_tiempos_no_trabajados 
				JOIN exp_emp_empleos ON tnn_codemp = emp_codigo
				JOIN eor_plz_plazas ON emp_codplz = plz_codigo
			WHERE plz_codcia = codcia
				AND emp_codtpl = codtpl
				AND (((tnn_fecha_del BETWEEN ppl_fecha_inicio AND ppl_fecha_fin) AND (tnn_fecha_al BETWEEN ppl_fecha_inicio AND ppl_fecha_fin))
					OR ((tnn_fecha_del BETWEEN ppl_fecha_inicio AND ppl_fecha_fin) AND (tnn_fecha_al >= ppl_fecha_fin))
					OR ((tnn_fecha_del <= ppl_fecha_inicio) AND (tnn_fecha_al BETWEEN ppl_fecha_inicio AND ppl_fecha_fin))
					OR ((tnn_fecha_del <= ppl_fecha_inicio) AND (tnn_fecha_al >= ppl_fecha_fin)))
			UNION ALL 
			SELECT ixe_codemp nov_codemp,
				ixe_inicio nov_fecha_inicio,
				ixe_final nov_fecha_fin,
				NULL nov_rubro,
				NULL nov_valor,
				'Incapacidades' nov_tipo  
			FROM acc_ixe_incapacidades 
				JOIN exp_emp_empleos ON ixe_codemp = emp_codigo
				JOIN eor_plz_plazas ON emp_codplz = plz_codigo
			WHERE plz_codcia = codcia
				AND emp_codtpl = codtpl 
				AND (((ixe_inicio BETWEEN ppl_fecha_inicio AND ppl_fecha_fin) AND (ixe_final BETWEEN ppl_fecha_inicio AND ppl_fecha_fin))
				OR ((ixe_inicio BETWEEN ppl_fecha_inicio AND ppl_fecha_fin) AND (ixe_final >= ppl_fecha_fin))
				OR ((ixe_inicio <= ppl_fecha_inicio) AND (ixe_final BETWEEN ppl_fecha_inicio AND ppl_fecha_fin))
				OR ((ixe_inicio <= ppl_fecha_inicio) AND (ixe_final >= ppl_fecha_fin)))
			UNION ALL 
			SELECT vac_codemp nov_codemp,
				dva_desde nov_fecha_inicio,
				dva_hasta nov_fecha_fin,
				NULL nov_rubro,
				NULL nov_valor,
				'Vacaciones' nov_tipo  
			FROM acc_vac_vacaciones 
				JOIN acc_dva_dias_vacacion ON vac_codigo = dva_codvac
				JOIN exp_emp_empleos ON vac_codemp = emp_codigo
				JOIN eor_plz_plazas ON emp_codplz = plz_codigo
			WHERE plz_codcia = codcia
				AND emp_codtpl = codtpl
				AND (((dva_desde BETWEEN ppl_fecha_inicio AND ppl_fecha_fin) AND (dva_hasta BETWEEN ppl_fecha_inicio AND ppl_fecha_fin))
					OR ((dva_desde BETWEEN ppl_fecha_inicio AND ppl_fecha_fin) AND (dva_hasta >= ppl_fecha_fin))
					OR ((dva_desde <= ppl_fecha_inicio) AND (dva_hasta BETWEEN ppl_fecha_inicio AND ppl_fecha_fin))
					OR ((dva_desde <= ppl_fecha_inicio) AND (dva_hasta >= ppl_fecha_fin)))
			UNION ALL 
			SELECT amo_codemp nov_codemp,
				amo_inicio_suspension nov_fecha_inicio,
				amo_final_suspension nov_fecha_fin,
				NULL nov_rubro,
				NULL nov_valor,
				'Amonestaciones' nov_tipo  
			FROM acc_amo_amonestaciones 
				JOIN exp_emp_empleos ON amo_codemp = emp_codigo
				JOIN eor_plz_plazas ON emp_codplz = plz_codigo
			WHERE plz_codcia = codcia
				AND amo_codppl_suspension = codppl) novedades ON emp_codigo = novedades.nov_codemp
	WHERE sco.permiso_empleo(emp_codigo, usuario) = 1;
END;