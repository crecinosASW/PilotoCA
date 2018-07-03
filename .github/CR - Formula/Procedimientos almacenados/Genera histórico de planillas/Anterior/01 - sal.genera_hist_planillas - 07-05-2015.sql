IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('sal.genera_hist_planillas')
			  AND type = 'P')
BEGIN
	DROP PROCEDURE sal.genera_hist_planillas
END

GO

--EXEC sal.genera_hist_planillas 1, '1', '20140101', 'admin'
CREATE PROCEDURE sal.genera_hist_planillas (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(20) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@username VARCHAR(50) = NULL
)

AS

DECLARE @codtpl INT,
	@codppl INT,
	@codmon VARCHAR(3),
	@ppl_fecha_fin DATETIME,
	@ppl_fecha_ini DATETIME,
	@tpl_descripcion VARCHAR(250)

SET @username = ISNULL(@username, SYSTEM_USER)

SELECT @codtpl = tpl_codigo,
	@codmon = tpl_codmon,
	@tpl_descripcion = tpl_descripcion
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @codcia
	AND tpl_codigo_visual = @codtpl_visual

SELECT @codppl = ppl_codigo,
	@ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codtpl = @codtpl
	AND ppl_codigo_planilla = @codppl_visual

insert into sal.hpa_hist_periodos_planilla(hpa_codppl, hpa_codemp, hpa_nombres_apellidos, hpa_apellidos_nombres, hpa_fecha_ingreso, 
				hpa_codafp, hpa_nombre_afp, hpa_codmon, hpa_tasa_cambio, hpa_salario, hpa_salario_hora, 
				hpa_codtco, hpa_codplz, hpa_nombre_plaza, hpa_coduni, hpa_nombre_unidad, hpa_codarf, hpa_nombre_areafun, 
				hpa_codcdt, hpa_nombre_centro_trabajo, hpa_codpue, hpa_nombre_puesto, hpa_nombre_tipo_planilla, hpa_nombre_periodo_planilla, 
				--hpa_session_id, 
				hpa_usuario_grabacion, hpa_fecha_grabacion)
			select @codppl, emp_codigo, 
				   exp_nombres_apellidos, 
				   exp_apellidos_nombres, 
				   emp_fecha_ingreso, 
				   afp_codigo, afp_nombre, 
				   ISNULL(inn_codmon, tpl_codmon) inn_codmon, 
				   gen.get_tasa_cambio('CRC', ppl_fecha_fin), 
				   esa_valor, esa_valor_hora,
				   tco_codigo, 
				   plz_codigo, plz_nombre, 
				   uni_codigo, uni_descripcion, 
				   arf_codigo, arf_nombre,
				   cdt_codigo, cdt_descripcion,
				   pue_codigo, pue_nombre,
				   tpl_descripcion, left(convert(varchar, ppl_fecha_ini, 100), 11) + ' - ' + left(convert(varchar, ppl_fecha_fin, 100), 11),
				   --@sessionId, 
				   @userName, GETDATE()
			  from exp.emp_empleos
			  left join (select inn_codemp, max(inn_codmon) inn_codmon
					  from sal.inn_ingresos 
					 where inn_codppl = @codppl 
					   and sal.empleado_en_gen_planilla(NULL, inn_codemp) = 1
					 group by inn_codemp) inn on inn_codemp = emp_codigo
			  join sal.ppl_periodos_planilla on ppl_codigo = @codppl
			  join sal.tpl_tipo_planilla on tpl_codigo = ppl_codtpl
			  left join exp.esa_est_sal_actual_empleos_v on esa_codemp = emp_codigo and esa_es_salario_base = 1
			  join exp.tco_tipos_de_contrato on tco_codigo = emp_codtco
			  join eor.plz_plazas on plz_codigo = emp_codplz
			  join eor.uni_unidades on uni_codigo = plz_coduni
			  join eor.arf_areas_funcionales on arf_codigo = uni_codarf
			  join eor.cdt_centros_de_trabajo on cdt_codigo = plz_codcdt
			  join eor.pue_puestos on pue_codigo = plz_codpue
			  join exp.exp_expedientes on exp_codigo = emp_codexp
			  left join exp.afp_afp on afp_codigo = gen.get_pb_field_data_int(emp_property_bag_data, 'codAFP')
where plz_codcia = @codcia
	AND EXISTS (SELECT 1
				FROM sal.inn_ingresos
				WHERE inn_codppl = @codppl
					AND inn_codemp = emp_codigo)
	AND NOT EXISTS (SELECT 1
				    FROM sal.hpa_hist_periodos_planilla
					WHERE hpa_codppl = @codppl
						AND hpa_codemp = emp_codigo)