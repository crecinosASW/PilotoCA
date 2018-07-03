IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('sal.pla_pre_prestamo_v'))
BEGIN
	DROP VIEW sal.pla_pre_prestamo_v
END

GO

CREATE VIEW sal.pla_pre_prestamo_v
AS

SELECT dcc_codemp, 
     dcc_codigo, 
     dcc_codtdc,
     dcc_referencia,
     dcc_fecha, 
     dcc_fecha_inicio_descuento, 
     dcc_monto_indefinido, 
     dcc_monto, 
     dcc_numero_cuotas, 
     dcc_total_cobrado, 
     dcc_codtcc,
     dcc_frecuencia_periodo_pla, 
     dcc_codtpl,
     dcc_estado, 
     CASE WHEN ISNULL(dcc_monto_indefinido, 0) <> 1 THEN 
          isnull(dcc_monto,0) - isnull(dcc_total_cobrado, 0)
      ELSE
          NULL
     END AS DCC_saldo,
     isnull(c1.cdc_ultima_cuota, 0) pre_ultima_cuota_pagada,
     isnull(c1.cdc_ultima_cuota, 0) + 1 pre_proxima_cuota,
     isnull(pdc_valor_cuota, dcc_valor_cuota) pre_valor_cuota,
     dcc_total_no_cobrado,
     0 pre_monto_total,
     0 pre_anios,
     0 pre_periodos_anio,
     0 pre_cuota_nominal,
     0 pre_tipo_interes,
     0 pre_tasa_interes,
     0 pre_codtdc_int, 
     dcc_porcentaje,
     dcc_activo,
     dcc_codagr,
     dcc_mes_no_descuenta,
	 ISNULL(gen.get_pb_field_data_bit(dcc_property_bag_data, 'EsPension'), 0) dcc_es_pension,
	 ISNULL(gen.get_pb_field_data_bit(dcc_property_bag_data, 'EsEmbargo'), 0) dcc_es_embargo
FROM SAL.dcc_descuentos_ciclicos left join (select dcc_codemp CDC_CODEMP,
                                        cdc_coddcc,
                                        isnull(max(cdc_numero_cuota), 0) cdc_ultima_cuota 
                                 from SAL.cdc_cuotas_descuento_ciclico JOIN SAL.dcc_descuentos_ciclicos ON
                                      cdc_coddcc = dcc_codigo
                                 where cdc_aplicado_planilla = 1
                                 group by dcc_codemp, cdc_coddcc) c1 on 
          dcc_codemp = c1.cdc_codemp and dcc_codigo = c1.cdc_coddcc
     left join sal.pdc_plan_pagos_desc_ciclico on 
          dcc_codigo = pdc_coddcc and isnull(c1.cdc_ultima_cuota, 0) + 1 >= pdc_cuota_inicial and isnull(c1.cdc_ultima_cuota, 0) + 1 <= pdc_cuota_final


