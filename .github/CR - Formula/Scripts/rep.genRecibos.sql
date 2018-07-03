CREATE Procedure rep.genRecibos
    @codppl   int      = null,
    @coduni   int      = null,
    @codemp   int      = null,
    @codcdt   int      = null,
    @codcia   int      = null,
    @codfpa   smallint = null
as                    

--declare @codppl   int,
--        @coduni   int,
--        @codemp   int,
--        @codcdt   int,
--        @codcia   int,
--        @codfpa   smallint

select rpe_codcia,
       cia_descripcion rpe_nombre_empresa,
       rpe_codppl,
       ppl_codtpl rpe_codtpl,
       ppl_fecha_ini rpe_fecha_ini,
       ppl_fecha_fin rpe_fecha_fin,
       ppl_fecha_pago rpe_fecha_pago,
       rpe_codemp,
       rpe_codigo_visual,
       rpe_nombre_empleado,
       rpe_codpue,
       rpe_puesto,
       rpe_unidad,
       ide_nit rpe_nit,
       ide_isss rpe_isss,
       hpa_salario_hora rpe_salario_hora,
       hpa_salario rpe_salario,
       rpe_no_recibo,
       rpe_tipo_rubro,
       rpe_codtipo,
       rpe_nombre_tipo,
       rpe_tiempo,
       rpe_percepcion,
       NULL /*cco_nomenclatura_contable + ' ' + cco_descripcion*/ rpe_centro_nombre,
       afp,
       rpe_codarf rpe_area,
       rpe_ubicacion,
       rpe_orden,
       hpa_fecha_ingreso emp_fecha_ingreso
  from (
        select hpa_codemp rpe_codemp,
               emp_codexp rpe_codexp,
               exp_codigo_alternativo rpe_codigo_visual,
               hpa_apellidos_nombres rpe_nombre_empleado,
               @codppl rpe_codppl,
               hpa_codplz rpe_codplz,
               tpl_codcia rpe_codcia,
               hpa_codpue rpe_codpue,
               hpa_nombre_puesto rpe_puesto,
               hpa_nombre_unidad rpe_unidad,
               hpa_nombre_areafun rpe_codarf,
               null rpe_no_recibo,
               'Ingreso' rpe_tipo_rubro,
               tig_abreviatura rpe_codtipo,
               tig_descripcion rpe_nombre_tipo,
               inn_tiempo rpe_tiempo,
               round(inn_valor, 2) rpe_percepcion,
               hpa_nombre_centro_trabajo rpe_ubicacion,
               isnull(tig_orden, 990) rpe_orden,
               emp_fecha_ingreso,
               hpa_nombre_afp afp,
               hpa_salario_hora,
               hpa_salario,
               hpa_fecha_ingreso
          from sal.hpa_hist_periodos_planilla
          join exp.emp_empleos on emp_codigo = hpa_codemp
          join exp.exp_expedientes on exp_codigo = emp_codexp 
          join sal.inn_ingresos on inn_codemp = emp_codigo and inn_codppl = hpa_codppl
          join sal.ppl_periodos_planilla on ppl_codigo = hpa_codppl
          join sal.tpl_tipo_planilla on tpl_codigo = ppl_codtpl
          join sal.tig_tipos_ingreso on tig_codigo = inn_codtig
         where inn_codppl = @codppl
               and (exists(select 1 from exp.fpe_formas_pago_empleo
                           where fpe_codemp = emp_codigo and fpe_codfpa = @codfpa) or @codfpa is null)
               and tpl_codcia = isnull(@codcia, tpl_codcia)
               and hpa_codemp = isnull(@codemp, hpa_codemp)
               and hpa_coduni = isnull(@coduni, hpa_coduni)
               and hpa_codcdt = isnull(@codcdt, hpa_codcdt)
        union all
        select hpa_codemp rpe_codemp,
               emp_codexp rpe_codexp,
               exp_codigo_alternativo rpe_codigo_visual,
               hpa_apellidos_nombres rpe_nombre_empleado,
               @codppl rpe_codppl,
               hpa_codplz rpe_codplz,
               tpl_codcia rpe_codcia,
               hpa_codpue rpe_codpue,
               hpa_nombre_puesto rpe_puesto,
               hpa_nombre_unidad rpe_unidad,
               hpa_nombre_areafun rpe_codarf,
               null rpe_no_recibo,
               'Descuento' rpe_tipo_rubro,
               tdc_abreviatura rpe_codtipo,
               tdc_descripcion rpe_nombre_tipo,
               dss_tiempo rpe_tiempo,
               round(dss_valor, 2) rpe_percepcion,
               hpa_nombre_centro_trabajo rpe_ubicacion,
               isnull(tdc_orden, 990) rpe_orden,
               emp_fecha_ingreso,
               hpa_nombre_afp afp,
               hpa_salario_hora,
               hpa_salario,
               hpa_fecha_ingreso
          from sal.hpa_hist_periodos_planilla
          join exp.emp_empleos on emp_codigo = hpa_codemp
          join exp.exp_expedientes on exp_codigo = emp_codexp
          join sal.dss_descuentos on dss_codemp = emp_codigo and hpa_codppl = dss_codppl
          join sal.ppl_periodos_planilla on ppl_codigo = hpa_codppl
          join sal.tpl_tipo_planilla on tpl_codigo = ppl_codtpl
          join sal.tdc_tipos_descuento on tdc_codigo = dss_codtdc
         where dss_codppl = @codppl
               and (exists(select 1 from exp.fpe_formas_pago_empleo
                           where fpe_codemp = emp_codigo and fpe_codfpa = @codfpa) or @codfpa is null)
               and hpa_codplz = isnull(@codcia, hpa_codplz)
               and hpa_codemp = isnull(@codemp, hpa_codemp)
               and hpa_coduni = isnull(@coduni, hpa_coduni)
               and hpa_codcdt = isnull(@codcdt, hpa_codcdt)
        ) v1
  join eor.cia_companias on cia_codigo = rpe_codcia
  join sal.ppl_periodos_planilla on ppl_codigo = rpe_codppl
  join exp.esa_est_sal_actual_empleos_v on esa_codemp = rpe_codemp and esa_es_salario_base = 1
  --left join eor.cpp_centros_costo_plaza on cpp_codplz = rpe_codplz
  --left join eor.cco_centros_de_costo on cpp_codcco = cco_codigo
  left join exp.ide_ident_emp_v on ide_codexp = rpe_codexp
 order by rpe_codemp, rpe_tipo_rubro desc, rpe_orden