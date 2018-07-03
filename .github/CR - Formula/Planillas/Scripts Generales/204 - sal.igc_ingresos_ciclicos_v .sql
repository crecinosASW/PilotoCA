IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('sal.igc_ingresos_ciclicos_v'))
BEGIN
	DROP VIEW sal.igc_ingresos_ciclicos_v
END

GO

CREATE VIEW sal.igc_ingresos_ciclicos_v  AS 
SELECT  IGC_CODEMP, IGC_CODIGO, IGC_REFERENCIA, IGC_FECHA, IGC_fecha_INIcio_PAGO, 
       IGC_monto_indefinido, IGC_MONTO, IGC_NUMero_CUOTAs, IGC_total_PAGADO, IGC_OBSERVACION, IGC_CODTIG, IGC_CODTPL, 
       IGC_FRECUENCIA_periodo_pla, IGC_ACCION_LIQUIDACION, IGC_USUARIO_GRABACION, IGC_FECHA_GRABACION, IGC_USUARIO_MODIFICACION, IGC_FECHA_MODIFICACION, IGC_ESTADO, 
       CASE WHEN isnull(IGC_monto_indefinido, 1) <> 1 THEN isnull(IGC_monto,0) - isnull(IGC_total_pagado,0) ELSE NULL END AS IGC_saldo, 
       isnull(c1.cic_ultima_cuota, 0) IGC_ultima_cuota_pagada, 
       isnull(c1.cic_ultima_cuota, 0) + 1 IGC_proxima_cuota, 
       isnull(pic_valor_cuota, IGC_valor_cuota) IGC_valor_cuota
       ,0 IGC_monto_total
       ,0 IGC_anios
       ,0 IGC_periodos_anio
       ,0 IGC_cuota_nominal
       , igc_activo
  FROM sal.igc_ingresos_ciclicos 
  left join ( 
        select igc_codemp cic_codemp, cic_codigc, isnull(max(cic_numero_cuota), 0) cic_ultima_cuota 
         from sal.cic_cuotas_ingreso_ciclico
         join sal.igc_ingresos_ciclicos on igc_codigo = cic_codigc
         where cic_aplicado_planilla = 1
         group by igc_codemp, cic_codigc) c1 
       on igc_codemp = c1.cic_codemp and igc_codigo = c1.cic_codigc 
  left join sal.pic_plan_pagos_ing_ciclico 
       on igc_codigo = pic_codigc and 
          isnull(c1.cic_ultima_cuota, 0) + 1 >= pic_cuota_inicial and 
          isnull(c1.cic_ultima_cuota, 0) + 1 <= pic_cuota_final