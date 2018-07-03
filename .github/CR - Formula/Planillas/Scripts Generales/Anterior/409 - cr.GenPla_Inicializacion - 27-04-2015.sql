IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_Inicializacion'))
BEGIN
	DROP PROCEDURE cr.GenPla_Inicializacion
END

GO

--EXEC cr.GenPla_Inicializacion null, 80, 'admin'
CREATE PROCEDURE cr.GenPla_Inicializacion (
	@sessionId uniqueidentifier = null,
    @codppl int,
    @userName varchar(100) = null
)

as

SET DATEFORMAT DMY

-------------------------------------------------------------------
-- Evolution                                                     --
-- Inicializacion de planilla GUATEMALA                          --
-- Realiza la limpieza de tablas auxiliares, de ingresos y       --
-- descuentos, calcula valores de vacaciones e incapacidades     --
-- Revaloriza Extras, otros ingresos, Otros descuentos sin valor 
-- fijo                                                          --
-- Calcula ISR si este esta activado                             --
-------------------------------------------------------------------
DECLARE @codpai VARCHAR(2),
	@codcia INT,
	@codtpl            int,
	@codagr_Extraordinario int,
	@codrsa_salario INT,
	@es_acumulativa BIT,
	@anio INT,
	@anio_siguiente INT,
	@horas_por_mes REAL,
	@codtpl_visual VARCHAR(3)

--declare @sessionId uniqueidentifier = null,
--    @codppl int,
--    @userName varchar(100) = null
--
--set @PCodcia = 2
--set @PCodTpl = 3
--set @PCodPla = 2007

set @userName = isnull(@userName, system_user)
------------------------------------------------------------------
--                     Parametros Planilla                      --
------------------------------------------------------------------
select @codpai = cia_codpai,
	@codcia = tpl_codcia,
	@codtpl = ppl_codtpl,
	@anio = YEAR(ppl_fecha_fin),
	@codtpl_visual = tpl_codigo_visual
  from sal.ppl_periodos_planilla
	join sal.tpl_tipo_planilla on ppl_codtpl = tpl_codigo
	join eor.cia_companias on tpl_codcia = cia_codigo
 where ppl_codigo = @codppl    

 SET @anio_siguiente = @anio + 1

Select @codagr_Extraordinario = agr_codigo
  from sal.agr_agrupadores
 where agr_codpai = @codpai
   and agr_abreviatura = 'CRBaseCalculoExtraordinario'

SET @codrsa_salario = gen.get_valor_parametro_int('CodigoRSA_Salario', NULL, NULL, @codcia, NULL)

SET @codagr_Extraordinario = ISNULL(@codagr_Extraordinario,0)

SET @es_acumulativa = ISNULL(gen.get_valor_parametro_bit('VacacionEsAcumulativa', @codpai, NULL, NULL, NULL), 1)

SET @horas_por_mes = ISNULL(gen.get_valor_parametro_float('HorasLaboradasPorMes', @codpai, NULL, NULL, NULL), 240.00)

set nocount on
begin transaction
	
	-- INGRESOS
	delete 
	from sal.inn_ingresos
	where inn_codppl = @codppl
	  and (sal.empleado_en_gen_planilla(@sessionId, inn_codemp) = 1 
		   OR inn_codemp in(select emp_codigo 
		                      from exp.emp_empleos
		                     where emp_estado = 'R' 
		                        or emp_codtpl <> @codtpl))

	-- DESCUENTOS
	delete 
	  from sal.dss_descuentos
	 where dss_codppl = @codppl
	  and (sal.empleado_en_gen_planilla(@sessionId, dss_codemp) = 1 
		   OR dss_codemp in(select emp_codigo 
		                      from exp.emp_empleos
		                     where emp_estado = 'R' 
		                        or emp_codtpl <> @codtpl))

	-- RESERVAS
	delete 
	  from sal.res_reservas
	 where res_codppl = @codppl
	   and (sal.empleado_en_gen_planilla(@sessionId, res_codemp) = 1
				   OR res_codemp in(select emp_codigo 
		                      from exp.emp_empleos
		                     where emp_estado = 'R' 
		                        or emp_codtpl <> @codtpl))

    -- HISTÓRICO DE CENTROS DE COSTO
      delete
      from sal.hco_hist_cco_periodos_planilla
      where hco_codhpa in (select hpa_codigo
                             from sal.hpa_hist_periodos_planilla 
                             where sal.empleado_en_gen_planilla(@sessionId, hpa_codemp) = 1 
                               and hpa_codppl = @codppl)

	-- HISTORICO DE PLANILLAS CALCULADAS
	delete 
	  from sal.hpa_hist_periodos_planilla
	 where hpa_codppl = @codppl
	   and (sal.empleado_en_gen_planilla(@sessionId, hpa_codemp) = 1
	   		   OR hpa_codemp in(select emp_codigo 
		                      from exp.emp_empleos
		                     where emp_estado = 'R' 
		                        or emp_codtpl <> @codtpl))

	-- Detalle de incapacidad
	delete 
	from cr.din_detalle_incapacidad 
	where exists (select null 
				  from acc.ixe_incapacidades
					  join acc.pie_periodos_incapacidad on ixe_codigo = pie_codixe
				  where din_codixe = ixe_codigo
					  and pie_codppl = @codppl
					  and (sal.empleado_en_gen_planilla(@sessionId, ixe_codemp) = 1
						  OR ixe_codemp in(select emp_codigo 
										   from exp.emp_empleos
										   where emp_estado = 'R' 
											   or emp_codtpl <> @codtpl)))

	-- Períodos de incapacidad
	delete 
	from acc.pie_periodos_incapacidad
	where pie_codppl = @codppl
		and exists (select null 
					from acc.ixe_incapacidades
					where ixe_codigo = pie_codixe 
						and (sal.empleado_en_gen_planilla(@sessionId, ixe_codemp) = 1
								   OR ixe_codemp in(select emp_codigo 
		                      from exp.emp_empleos
		                     where emp_estado = 'R' 
		                        or emp_codtpl <> @codtpl)) )

	-- Detalle de embargos
	delete 
	from sal.emb_embargos
	where exists (select null 
				  from sal.dcc_descuentos_ciclicos 
					  join sal.cdc_cuotas_descuento_ciclico on dcc_codigo = cdc_coddcc
				  where emb_codcdc = cdc_codigo
					  and cdc_codppl = @codppl
					  and (sal.empleado_en_gen_planilla(@sessionId, dcc_codemp) = 1
						  OR dcc_codemp in(select emp_codigo 
										   from exp.emp_empleos
										   where emp_estado = 'R' 
											   or emp_codtpl <> @codtpl)) )
                
	-- Cuotas de descuentos cíclicos
	delete 
	from sal.cdc_cuotas_descuento_ciclico
	where cdc_codppl = @codppl
		and exists (select null 
					from sal.dcc_descuentos_ciclicos 
					where dcc_codigo = cdc_coddcc 
						and (sal.empleado_en_gen_planilla(@sessionId, dcc_codemp) = 1
								   OR dcc_codemp in(select emp_codigo 
		                      from exp.emp_empleos
		                     where emp_estado = 'R' 
		                        or emp_codtpl <> @codtpl)) )

	-- Cuotas de ingresos cíclicos
	delete 
	from sal.cic_cuotas_ingreso_ciclico
	where cic_codppl = @codppl
		and exists (select null 
					from sal.igc_ingresos_ciclicos 
					where igc_codigo = cic_codigc 
						and (sal.empleado_en_gen_planilla(@sessionId, igc_codemp) = 1
								   OR igc_codemp in(select emp_codigo 
		                                              from exp.emp_empleos
		                                             where emp_estado = 'R' 
		                                                or emp_codtpl <> @codtpl)) )
	--Coloca las transacciones como no procesadas
    UPDATE sal.ext_horas_extras
       set ext_aplicado_planilla = 0
     where ext_estado = 'Autorizado'
       and ext_ignorar_en_planilla = 0
       and ext_codppl = @codppl
       and sal.empleado_en_gen_planilla(@sessionId, ext_codemp) = 1

      
    UPDATE sal.oin_otros_ingresos
       set oin_aplicado_planilla=0
     where oin_estado = 'Autorizado'
       and oin_ignorar_en_planilla = 0
       and sal.empleado_en_gen_planilla(@sessionId, oin_codemp) = 1
      
    UPDATE sal.ods_otros_descuentos
       set ods_aplicado_planilla=0
     where ods_estado = 'Autorizado' 
       and ods_ignorar_en_planilla = 0
       and ods_codppl = @codppl
       and sal.empleado_en_gen_planilla(@sessionId, ods_codemp) = 1

    UPDATE sal.tnn_tiempos_no_trabajados
       set tnn_aplicado_planilla=0
     WHERE tnn_estado = 'Autorizado' 
       and tnn_ignorar_en_planilla = 0
       and tnn_codppl = @codppl
       and sal.empleado_en_gen_planilla(@sessionId, tnn_codemp) = 1

	UPDATE p
	SET p.pie_aplicado_planilla = 0
	FROM acc.pie_periodos_incapacidad p
		JOIN acc.ixe_incapacidades ON pie_codixe = ixe_codigo
	WHERE ixe_estado = 'Autorizado'
		AND pie_codppl = @codppl
		AND sal.empleado_en_gen_planilla(@sessionId, ixe_codemp) = 1

    UPDATE sal.cdc_cuotas_descuento_ciclico
       SET cdc_aplicado_planilla = 0
     WHERE cdc_codppl = @codppl
       AND cdc_planilla_autorizada = 0
       and exists (select null 
                     from sal.dcc_descuentos_ciclicos 
                    where cdc_coddcc = dcc_codigo
                      and sal.empleado_en_gen_planilla(@sessionId, dcc_codemp) = 1)
                      
   UPDATE sal.cec_cuotas_extras_desc_ciclico
      SET cec_aplicado_planilla = 0
    WHERE cec_codppl = @codppl
      and cec_planilla_autorizada = 0
      and exists  (select null
                    from sal.dcc_descuentos_ciclicos
                   where dcc_codigo = cec_coddcc
                     and sal.empleado_en_gen_planilla(@sessionId, dcc_codemp) = 1)

   UPDATE sal.cic_cuotas_ingreso_ciclico
      SET cic_aplicado_planilla = 0
    WHERE cic_codppl = @codppl
      AND cic_planilla_autorizada = 0
      and exists (select null 
                   from sal.igc_ingresos_ciclicos 
                  where cic_codigc = igc_codigo
                    and igc_activo = 1
                    and igc_estado = 'Autorizado'
                    and sal.empleado_en_gen_planilla(@sessionId, igc_codemp) = 1)       
                                   
-- Delete de temporales por cancelaciones de generacion de planillas

	-- INGRESOS
	delete 
	  from tmp.inn_ingresos
	 where inn_codppl = @codppl
	   and sal.empleado_en_gen_planilla(@sessionId, inn_codemp) = 1
			
	---- DESCUENTOS
	delete 
	  from tmp.dss_descuentos
	 where dss_codppl = @codppl
	   and sal.empleado_en_gen_planilla(@sessionId, dss_codemp) = 1	

	--IF @es_acumulativa = 1
	--	EXEC cr.vac_genera_periodo_vacacion @codcia, @anio, @anio_siguiente, NULL, 0, 1, NULL, 1, NULL, @userName  

    EXEC cr.GenPla_ICC_GeneraCuotas @sessionId, @codppl	
    				
	EXEC cr.GenPla_DCC_GeneraCuotas @sessionId, @codppl, @userName
	
	EXEC cr.GenPla_INC_GeneraPeriodosIncapacidad @sessionId, @codppl, @userName

	IF @codtpl_visual = '4'
		EXEC cr.GenPla_Calcula_Vac_Semanal @sessionId, @codppl, @userName
	ELSE
		EXEC cr.GenPla_Calcula_Vacaciones @sessionId, @codppl, @userName

	EXEC cr.GenPla_Calcula_Embargos @sessionId, @codppl, @userName
	

-------------------------------------------------
--              Revalorizacion                 --
-------------------------------------------------
  
  -- Revalorizacionn de Horas Extras
    update sal.ext_horas_extras
         set ext_valor_a_pagar = ISNULL(ext_num_horas * ext_factor * 
                                     -- Calcula el valor de la hora
                                      (SELECT sum(ese_Valor) / (CASE WHEN ese_exp_valor = 'Mensual' THEN @horas_por_mes WHEN ese_exp_valor = 'Diario' THEN 8.00 ELSE 1.00 END) 
                                         FROM exp.emp_empleos
                                         join EXP.ESE_ESTRUCTURA_SAL_EMPLEOS  e on ese_Codemp = emp_Codigo and ese_estado = 'V' AND ese_codrsa = @codrsa_salario
                                        WHERE emp_Codigo = ext_codemp 
                                          AND ese_Codmon = ext_codmon
                                          group by emp_codjor, ese_exp_valor), 0.00)
       where ext_codppl = @codppl
       
  -- Revalorizacionn de Otros Ingresos
   update sal.oin_otros_ingresos
   set oin_Valor_a_pagar = round(oin_num_horas * oin_factor * 
                                     -- Calcula el valor de la hora
                                      (SELECT sum(ese_Valor/30 ) /isnull((select max(djo_total_horas) from sal.djo_dias_jornada where djo_codjor = emp_codjor),8)
                                         FROM exp.emp_empleos
                                         join EXP.ESE_ESTRUCTURA_SAL_EMPLEOS  e on ese_Codemp = emp_Codigo and ese_estado = 'V' AND ese_codrsa = @codrsa_salario
                                        WHERE emp_Codigo = oin_codemp 
                                          AND ese_Codmon = oin_codmon
                                           group by emp_codjor)
                                    , 2),
          oin_salario_hora = (SELECT sum(ese_Valor/30 ) /isnull((select max(djo_total_horas) from sal.djo_dias_jornada where djo_codjor = emp_codjor),8)
                                         FROM exp.emp_empleos
                                         join EXP.ESE_ESTRUCTURA_SAL_EMPLEOS  e on ese_Codemp = emp_Codigo and ese_estado = 'V' AND ese_codrsa = @codrsa_salario
                                        WHERE emp_Codigo = oin_codemp 
                                          AND ese_Codmon = oin_codmon
                                           group by emp_codjor)
    where oin_codppl = @codppl
      and oin_es_valor_fijo = 0;
   
-- Revalorizacion de Otros Descuentos
   update sal.ods_otros_descuentos
   set ods_Valor_a_descontar = round(ods_num_horas * ods_factor * 
                                     -- Calcula el valor de la hora
                                      (SELECT sum(ese_Valor/30 ) /isnull((select max(djo_total_horas) from sal.djo_dias_jornada where djo_codjor = emp_codjor),8)
                                         FROM exp.emp_empleos
                                         join EXP.ESE_ESTRUCTURA_SAL_EMPLEOS  e on ese_Codemp = emp_Codigo and ese_estado = 'V' AND ese_codrsa = @codrsa_salario
                                        WHERE emp_Codigo = ods_codemp 
                                          AND ese_Codmon = ods_codmon
                                           group by emp_codjor)
                                    , 2),
          ods_salario_hora = (SELECT sum(ese_Valor/30 ) /isnull((select max(djo_total_horas) from sal.djo_dias_jornada where djo_codjor = emp_codjor),8)
                                         FROM exp.emp_empleos
                                         join EXP.ESE_ESTRUCTURA_SAL_EMPLEOS  e on ese_Codemp = emp_Codigo and ese_estado = 'V' AND ese_codrsa = @codrsa_salario
                                        WHERE emp_Codigo = ods_codemp 
                                          AND ese_Codmon = ods_codmon
                                           group by emp_codjor)
    where ods_codppl = @codppl
      and ods_es_valor_fijo = 0;
  
   -- Actualizacion del periodo a Generado  
      UPDATE sal.ppl_periodos_planilla
         SET ppl_estado = 'Generado'
       WHERE ppl_codigo = @codppl
            
commit transaction

return
