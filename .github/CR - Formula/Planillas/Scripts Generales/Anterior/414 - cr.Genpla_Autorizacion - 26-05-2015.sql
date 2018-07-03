IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.Genpla_Autorizacion'))
BEGIN
	DROP PROCEDURE cr.Genpla_Autorizacion
END

GO

--EXEC cr.Genpla_Autorizacion 80, 'admin'
CREATE procedure cr.Genpla_Autorizacion
    @codppl int,
    @userName varchar(100) = null
as

begin

set nocount on
--*
--* Verifica los parámetros
--*
set @userName = isnull(@userName, system_user)

DECLARE @codpai VARCHAR(2),
	@codcia INT,
	@es_acumulativa BIT,
	@ppl_fecha_fin DATETIME

SELECT @codpai = cia_codpai,
	@codcia = tpl_codcia,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
	JOIN eor.cia_companias ON tpl_codcia = cia_codigo
WHERE ppl_codigo = @codppl

SET @es_acumulativa = ISNULL(gen.get_valor_parametro_bit('VacacionEsAcumulativa', @codpai, NULL, NULL, NULL), 1)

begin transaction
--*
--* Marca el período como autorizado
--*
update sal.ppl_periodos_planilla 
set ppl_estado = 'Autorizado',
	ppl_fecha_modificacion = getdate(),
	ppl_usuario_modificacion = @userName
where ppl_codigo = @codppl

--*
--* Elimina las tablas temporales de la formulación
--*
delete 
from tmp.inn_ingresos
where inn_codppl = @codppl

delete 
from tmp.dss_descuentos
where dss_codppl = @codppl

delete 
from tmp.res_reservas
where res_codppl = @codppl

--*
--* Marca las transacciones aplicadas en planilla, como procesadas
--*
update acc.amo_amonestaciones 
set amo_planilla_autorizada = 1 
where amo_codppl_suspension = @codppl
	and amo_aplicado_planilla = 1
	and amo_ignorar_en_planilla = 0
	and amo_planilla_autorizada = 0
	and amo_estado = 'Autorizado'

update sal.cdc_cuotas_descuento_ciclico 
set cdc_planilla_autorizada = 1 
where cdc_codppl = @codppl
	and cdc_aplicado_planilla = 1
	and cdc_planilla_autorizada = 0

update sal.cec_cuotas_extras_desc_ciclico 
set cec_planilla_autorizada = 1 
where cec_codppl = @codppl
	and cec_aplicado_planilla = 1
	and cec_planilla_autorizada = 0

update sal.cic_cuotas_ingreso_ciclico 
set cic_planilla_autorizada = 1 
where cic_codppl = @codppl
	and cic_aplicado_planilla = 1
	and cic_planilla_autorizada = 0

update acc.dva_dias_vacacion 
set dva_planilla_autorizada = 1 
where dva_codppl = @codppl
	and dva_aplicado_planilla = 1
	and dva_planilla_autorizada = 0

update sal.ext_horas_extras 
set ext_planilla_autorizada = 1 
where ext_codppl = @codppl
	and ext_aplicado_planilla = 1
	and ext_ignorar_en_planilla = 0
	and ext_planilla_autorizada = 0
	and ext_estado = 'Autorizado'

update sal.ods_otros_descuentos 
set ods_planilla_autorizada = 1 
where ods_codppl = @codppl
	and ods_aplicado_planilla = 1
	and ods_ignorar_en_planilla = 0
	and ods_planilla_autorizada = 0
	and ods_estado = 'Autorizado'

update sal.oin_otros_ingresos 
set oin_planilla_autorizada = 1 
where oin_codppl = @codppl
	and oin_aplicado_planilla = 1
	and oin_ignorar_en_planilla = 0
	and oin_planilla_autorizada = 0
	and oin_estado = 'Autorizado'

update acc.pie_periodos_incapacidad 
set pie_planilla_autorizada = 1 
where pie_codppl = @codppl
	and pie_aplicado_planilla = 1
	and pie_planilla_autorizada = 0

update sal.sre_servicios_realizados 
set sre_planilla_autorizada = 1 
where sre_codppl = @codppl
	and sre_aplicado_planilla = 1
	and sre_ignorar_en_planilla = 0
	and sre_planilla_autorizada = 0
	and sre_estado = 'Autorizado'

update sal.tnn_tiempos_no_trabajados 
set tnn_planilla_autorizada = 1 
where tnn_codppl = @codppl
	and tnn_aplicado_planilla = 1
	and tnn_ignorar_en_planilla = 0
	and tnn_planilla_autorizada = 0
	and tnn_estado = 'Autorizado'

update cr.din_detalle_incapacidad
set din_planilla_autorizada = 1
where exists (select null
			  from cr.fin_fecha_incapacidad
			  where din_codfin = fin_codigo
				  and fin_codppl_genero = @codppl)

--*
--* Actualiza el total pagado de los ingresos ciclicos
--* y cambia el estado cuando ya terminaron
--*
update sal.igc_ingresos_ciclicos
   set igc_total_pagado = isnull(total_pagado, 0),
       igc_activo = case when igc_monto_indefinido = 0 and 
                              (isnull(total_pagado, 0) >= igc_monto or isnull(maxima_cuota, 0) >= igc_numero_cuotas) 
                          then 0 
                          else 1 
                    end
  from sal.igc_ingresos_ciclicos
  left join (
        select cic_codigc, sum(cic_valor_cuota) total_pagado, max(cic_numero_cuota) maxima_cuota
          from sal.cic_cuotas_ingreso_ciclico
         where cic_aplicado_planilla = 1
           and cic_planilla_autorizada = 1
         group by cic_codigc) cic on cic_codigc = igc_codigo
 where igc_activo = 1
   and exists (
        select null
          from sal.cic_cuotas_ingreso_ciclico
          where cic_codppl = @codppl
            and cic_aplicado_planilla = 1
            and cic_planilla_autorizada = 1)
   
--*
--* Actualiza el total cobrado de los descuentos ciclicos
--* y cambia el estado cuando ya terminaron
--*
update sal.dcc_descuentos_ciclicos
   set dcc_total_cobrado = isnull(total_cobrado, 0) + isnull(total_extras, 0),
       dcc_total_no_cobrado = isnull(total_no_cobrado, 0),
       dcc_activo = case when dcc_monto_indefinido = 0 and 
                              ((isnull(total_cobrado, 0) + isnull(total_extras, 0)) >= dcc_monto or isnull(maxima_cuota, 0) >= dcc_numero_cuotas)
                          then 0 
                          else 1
                    end
  from sal.dcc_descuentos_ciclicos
  left join (
        select cdc_coddcc cobrado_coddcc, sum(cdc_valor_cobrado) total_cobrado, max(cdc_numero_cuota) maxima_cuota
          from sal.cdc_cuotas_descuento_ciclico
         where cdc_aplicado_planilla = 1
           and cdc_planilla_autorizada = 1
         group by cdc_coddcc) cobrado on cobrado_coddcc = dcc_codigo
  left join (
        select cdc_coddcc nocobrado_coddcc, sum(cdc_valor_no_cobrado) total_no_cobrado
          from sal.cdc_cuotas_descuento_ciclico
         where cdc_aplicado_planilla = 1
           and cdc_planilla_autorizada = 1
         group by cdc_coddcc) nocobrado on nocobrado_coddcc = dcc_codigo
  left join (
        select cec_coddcc extra_coddcc, sum(cec_valor_cuota) total_extras
          from sal.cec_cuotas_extras_desc_ciclico
         where cec_aplicado_planilla = 1
           and cec_planilla_autorizada = 1
         group by cec_coddcc) extras on extra_coddcc = dcc_codigo
 where dcc_activo = 1
   and exists (
        select null
          from sal.cdc_cuotas_descuento_ciclico
         where cdc_codppl = @codppl
           and cdc_aplicado_planilla = 1
           and cdc_planilla_autorizada = 1)
    or exists (
        select null
          from sal.cec_cuotas_extras_desc_ciclico
         where cec_codppl = @codppl
           and cec_aplicado_planilla = 1
           and cec_planilla_autorizada = 1)

-- Actualiza los días de vacaciones
IF @es_acumulativa = 1
BEGIN
	EXECUTE cr.vac_act_periodo_vacacion @codcia, NULL, @ppl_fecha_fin
END
   
--*
--* Crea el nuevo período
--* 

commit transaction
end
