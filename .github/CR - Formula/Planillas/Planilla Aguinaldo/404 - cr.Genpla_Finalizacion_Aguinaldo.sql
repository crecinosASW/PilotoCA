IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.Genpla_Finalizacion_Aguinaldo'))
BEGIN
	DROP PROCEDURE cr.Genpla_Finalizacion_Aguinaldo
END

GO

--EXEC cr.Genpla_Finalizacion_Aguinaldo NULL, 80, 'admin'
CREATE procedure cr.Genpla_Finalizacion_Aguinaldo
	@sessionId uniqueidentifier = null,
	@codppl int,
	@userName varchar(100) = null
AS

BEGIN

	set nocount on

	DECLARE @codpai VARCHAR(2),
		@codcia INT,
		@codtpl INT,
		@codtpl_normal INT,
		@tpl_aplicacion VARCHAR(15),
		@ppl_frecuencia INT,
		@codtpl_visual VARCHAR(3),
		@codagr_no_aplican INT
	
	SELECT @codpai = cia_codpai,
		@codcia = cia_codigo,
		@codtpl = tpl_codigo,
		@codtpl_normal = tpl_codtpl_normal,
		@tpl_aplicacion = tpl_aplicacion,
		@ppl_frecuencia = ppl_frecuencia,
		@codtpl_visual = tpl_codigo_visual
	FROM sal.tpl_tipo_planilla
		JOIN sal.ppl_periodos_planilla ON tpl_codigo = ppl_codtpl
		JOIN eor.cia_companias ON tpl_codcia = cia_codigo
	WHERE ppl_codigo = @codppl

	declare @now datetime, 
		@maxId bigint

	set @now = getdate()

	--* Verifica los parámetros
	set @userName = isnull(@userName, system_user)

	begin transaction

		--* Inserta en las tablas reales los ingresos y descuentos calculados

			-- INGRESOS
			select @maxId = max(inn_codigo) 
			from sal.inn_ingresos
			
			set @maxId = isnull(@maxId, 0)
			
--			dbcc checkident('sal.inn_ingresos', reseed, @maxId)

			insert into sal.inn_ingresos(inn_codppl, inn_codemp, inn_codtig, inn_valor, inn_codmon, inn_tiempo, inn_unidad_tiempo, inn_usuario_grabacion, inn_fecha_grabacion)
			select inn_codppl, inn_codemp, inn_codtig, SUM(inn_valor), inn_codmon, SUM(inn_tiempo), inn_unidad_tiempo, @userName, @now
			from tmp.inn_ingresos
			where inn_codppl = @codppl
				and sal.empleado_en_gen_planilla(@sessionId, inn_codemp) = 1
				and exists (select null from sal.tig_tipos_ingreso where tig_codigo = inn_codtig)
			group by inn_codppl, inn_codemp, inn_codtig, inn_codmon, inn_unidad_tiempo	
			
					--- BORRADO DE TABLAS TEMPORALES
			-- INGRESOS
			delete 
			from tmp.inn_ingresos
			where inn_codppl = @codppl
				and sal.empleado_en_gen_planilla(@sessionId, inn_codemp) = 1

			-- DESCUENTOS
			select @maxId = max(dss_codigo) 
			from sal.dss_descuentos
			
			set @maxId = isnull(@maxId, 0)
			
--			dbcc checkident('sal.dss_descuentos', reseed, @maxId)

			insert into sal.dss_descuentos(dss_codppl, dss_codemp, dss_codtdc, dss_valor, dss_valor_patronal, dss_ingreso_afecto, dss_codmon, dss_tiempo, dss_unidad_tiempo, dss_usuario_grabacion, dss_fecha_grabacion)
			select dss_codppl, dss_codemp, dss_codtdc, SUM(dss_valor), SUM(dss_valor_patronal), SUM(dss_ingreso_afecto), dss_codmon, SUM(dss_tiempo), dss_unidad_tiempo, @userName, @now
			from tmp.dss_descuentos
			where dss_codppl = @codppl
				and sal.empleado_en_gen_planilla(@sessionId, dss_codemp) = 1
				and exists (select null from sal.tdc_tipos_descuento where tdc_codigo = dss_codtdc)
			group by dss_codppl, dss_codemp, dss_codtdc, dss_codmon, dss_unidad_tiempo	
			
			---- DESCUENTOS
			delete 
			from tmp.dss_descuentos
			where dss_codppl = @codppl
				and sal.empleado_en_gen_planilla(@sessionId, dss_codemp) = 1
	
			-- RESERVAS
			select @maxId = max(res_codigo) 
			from sal.res_reservas
		
			set @maxId = isnull(@maxId, 0)
		
			--			dbcc checkident('sal.res_reservas', reseed, @maxId)

			insert into sal.res_reservas(res_codppl, res_codemp, res_codtrs, res_valor, res_codmon, res_tiempo, res_unidad_tiempo, res_usuario_grabacion, res_fecha_grabacion)
			select res_codppl, res_codemp, res_codtrs, SUM(res_valor), res_codmon, SUM(res_tiempo), res_unidad_tiempo, @userName, @now
			from tmp.res_reservas
			where res_codppl = @codppl
				and sal.empleado_en_gen_planilla(@sessionId, res_codemp) = 1
				and exists (select null from sal.trs_tipos_reserva where trs_codigo = res_codtrs)
			group by res_codppl, res_codemp, res_codtrs, res_codmon, res_unidad_tiempo
			
		
			-- RESERVAS
			delete 
			from tmp.res_reservas
			where res_codppl = @codppl
				and sal.empleado_en_gen_planilla(@sessionId, res_codemp) = 1


			-- HISTORICO DE PLANILLAS CALCULADAS
			select @maxId = max(hpa_codigo) 
			from sal.hpa_hist_periodos_planilla
			
			set @maxId = isnull(@maxId, 0)
			
--			dbcc checkident('sal.hpa_hist_periodos_planilla', reseed, @maxId)

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
				   gen.get_tasa_cambio('CRC', ppl_fecha_pago), 
				   esa_valor, esa_valor_hora,
				   tco_codigo, 
				   plz_codigo, plz_nombre, 
				   uni_codigo, uni_descripcion, 
				   arf_codigo, arf_nombre,
				   cdt_codigo, cdt_descripcion,
				   pue_codigo, pue_nombre,
				   tpl_descripcion, left(convert(varchar, ppl_fecha_ini, 100), 11) + ' - ' + left(convert(varchar, ppl_fecha_fin, 100), 11),
				   --@sessionId, 
				   @userName, @now
			  from exp.emp_empleos
			  left join (select inn_codemp, max(inn_codmon) inn_codmon
					  from sal.inn_ingresos 
					 where inn_codppl = @codppl 
					   and sal.empleado_en_gen_planilla(@sessionId, inn_codemp) = 1
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
			WHERE plz_codcia = @codcia
				AND emp_estado = 'A'
				AND emp_codtpl = @codtpl_normal
				AND sal.empleado_en_gen_planilla(@sessionId, emp_codigo) = 1
		
		-- HISTÓRICO DE CENTROS DE COSTO
        
        INSERT INTO sal.hco_hist_cco_periodos_planilla
                    (hco_codhpa, 
                     hco_codcco, 
                     hco_nombre_centro_costo, 
                     hco_porcentaje)
              SELECT hpa_codigo, 
                     cco_codigo, 
                     cco_descripcion, 
                     cpp_porcentaje
                FROM eor.cpp_centros_costo_plaza
               inner join eor.cco_centros_de_costo on cco_codigo = cpp_codcco
               inner join sal.hpa_hist_periodos_planilla on hpa_codplz = cpp_codplz
               WHERE hpa_codppl = @codppl
                 and sal.empleado_en_gen_planilla(@sessionId, hpa_codemp) = 1

		EXEC cr.GenPla_Poliza_Contable @codppl, @sessionId

		--rollback transaction
	commit transaction
end
