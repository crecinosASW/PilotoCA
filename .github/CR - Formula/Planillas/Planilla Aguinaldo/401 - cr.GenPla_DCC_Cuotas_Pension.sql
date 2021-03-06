IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_DCC_Cuotas_Pension'))
BEGIN
	DROP PROCEDURE cr.GenPla_DCC_Cuotas_Pension
END

GO

CREATE procedure cr.GenPla_DCC_Cuotas_Pension (	
	@sessionId uniqueidentifier = null,
    @codppl int,
    @userName varchar(100) = null
) 

AS

-- declaracion de variables locales 
declare @codcia int, 
	@codtpl int, 
	@codEMP int, 
	@codigo int, 
	@monto_indefinido varchar(1), 
	@proxima_cuota int, 
	@num_cuota int, 
	@cuota REAL, 
	@fecha_pago datetime, 
	@frecuencia varchar(1),
	@codtdc int,
	@frecPRE varchar(1),
	@saldo MONEY

-- Obtiene la fecha de finalizacion y la frecuencia del periodo de planilla que va a utilizar 
select @codcia = tpl_codcia,
     @codtpl = tpl_codigo,
     @fecha_pago = ppl_fecha_fin, 
     @frecuencia = ppl_frecuencia
from sal.ppl_periodos_planilla join sal.tpl_tipo_planilla on 
     ppl_codtpl = tpl_codigo
where ppl_codigo = @codppl
 

begin transaction 

declare cPRE cursor for
select dcc_codemp,
	dcc_codigo,
	dcc_codtdc,
	dcc_frecuencia_periodo_pla,
	dcc_monto_indefinido,
	pre_proxima_cuota,
	dcc_numero_cuotas,
	cuota = (case when dcc_saldo < pre_valor_cuota then 
					dcc_saldo 
				else 
					pre_valor_cuota
				end) 
from sal.pla_pre_prestamo_v
where dcc_estado = 'Autorizado' 
	and dcc_activo = 1
	and isnull(dcc_saldo, 9999999999) > 0
	and pre_valor_cuota <> 0
	and dcc_es_pension = 1
	and dcc_fecha_inicio_descuento <= @fecha_pago
	and sal.empleado_en_gen_planilla(@sessionId, dcc_codemp) = 1

open cPRE
WHILE 1 = 1 -- TRUE
BEGIN 
   FETCH NEXT FROM cPRE INTO @codEMP, @codigo, @codtdc, @frecPRE, @monto_indefinido, @proxima_cuota, @num_cuota, @cuota
   if @@FETCH_STATUS <> 0 break

	-- Inserta un nuevo registro en pla_cdc_cuotas_desc 
	If @monto_indefinido = 1 Or @proxima_cuota <= @num_cuota 
	begin 
		if not exists(SELECT cdc_codigo
					from sal.cdc_cuotas_descuento_ciclico JOIN sal.dcc_descuentos_ciclicos ON
						cdc_coddcc = dcc_codigo
					where dcc_codemp = @codEMP 
						and dcc_codigo = @codigo 
						and cdc_numero_cuota = @proxima_cuota)
						
			insert into sal.cdc_cuotas_descuento_ciclico(cdc_coddcc, cdc_numero_cuota, cdc_codppl, 
											cdc_fecha_descuento, cdc_valor_cobrado, cdc_aplicado_planilla) 
			values (@codigo, @proxima_cuota, @codPpL, 
					@fecha_pago, Round(@cuota, 2), 0)
	end 
END 
CLOSE cPRE 
DEALLOCATE cPRE 

COMMIT TRANSACTION 

return


