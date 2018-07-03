BEGIN TRANSACTION

DECLARE @codpai VARCHAR(2)

SET @codpai = 'gt'

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'BaseCalculoSS')
	INSERT INTO sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	VALUES ('BaseCalculoSS', 'Base para el cálculo del seguro social', 'TodosExcluyendo', @codpai, 1)

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'BaseCalculoISR')
	INSERT INTO sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	VALUES ('BaseCalculoISR', 'Base para el cálculo del Impuesto Sobre la Renta', 'TodosExcluyendo', @codpai, 1)
	
IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'BaseCalculoVacacion')
	INSERT INTO sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	VALUES ('BaseCalculoVacacion', 'Base para el cálculo de la vacación sin tomar en cuenta el extraordinario', 'TodosExcluyendo', @codpai, 1);	

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'BaseCalculoVacacionExtras')
	INSERT INTO sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	VALUES ('BaseCalculoVacacionExtras', 'Base para el cálculo de la vacación solo extraordinario', 'TodosExcluyendo', @codpai, 1);	

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GTCalculoExtraordinario')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES ('gt', 'Ingresos a tomar en cuenta para calculo de tiempo extraordinario', 'GTCalculoExtraordinario', 1, 'TodosExcluyendo', '', 'admin', '2013-09-09 16:31:22', 'admin', '2013-09-09 16:32:03')

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GT_ISR13Aguinaldo')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('GT_ISR13Aguinaldo','GT - ISR 2013 - AGUINALDO','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GT_ISR13BoniLey')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('GT_ISR13BoniLey','GT - ISR 2013 - BONIFICACION LEY','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GT_ISR13BoniPactada')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('GT_ISR13BoniPactada','GT - ISR 2013 - BONIFICACION PACTADA','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GT_ISR13Bono14')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('GT_ISR13Bono14','GT - ISR 2013 - BONO 14','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GT_ISR13ISRDesc')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('GT_ISR13ISRDesc','GT - ISR 2013 - ISR DESCONTADO','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GT_ISR13Ordinario')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('GT_ISR13Ordinario','GT - ISR 2013 - ORDINARIO','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GT_ISR13OtrosNoProy')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('GT_ISR13OtrosNoProy','GT - ISR 2013 - OTROS - NO PROYECTABLES','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GT_ISR13OtrosProyNI')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('GT_ISR13OtrosProyNI','GT - ISR 2013 - OTROS - PROYECTABLES NO IGSS','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GT_ISR13OtrosProySI')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('GT_ISR13OtrosProySI','GT - ISR 2013 - OTROS - PROYECTABLES IGSS','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'GT_ISR13SSDesc')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('GT_ISR13SSDesc','GT - ISR 2013 - SEGURO SOCIAL DESCONTADO','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13Comisiones')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13Comisiones','REP - ISR 2013 - COMISIONES','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13Dietas')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13Dietas','REP - ISR 2013 - DIETAS','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13GastoRepresentacion')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13GastoRepresentacion','REP - ISR 2013 - GASTO REPRESENTACION','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13Gratificaciones')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13Gratificaciones','REP - ISR 2013 - GRATIFICACIONES','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13HorasExtras')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13HorasExtras','REP - ISR 2013 - HORAS EXTRAS','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13Indemnizacion')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13Indemnizacion','REP - ISR 2013 - INDEMNIZACION','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13IndemnizacionesMuerte')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13IndemnizacionesMuerte','REP - ISR 2013 - INDEMNIZACIONES POR MUERTE','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13Otros')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13Otros','REP - ISR 2013 - OTROS','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13Pensiones')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13Pensiones','REP - ISR 2013 - PENSIONES','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13PrestacionesIGSS')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13PrestacionesIGSS','REP - ISR 2013 - PRESTACIONES IGSS','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13Propinas')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13Propinas','REP - ISR 2013 - PROPINAS','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13Remuneraciones')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13Remuneraciones','REP - ISR 2013 - REMUNERACIONES','TodosExcluyendo','gt',1);

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'REP_ISR13Viaticos')
	insert into sal.agr_agrupadores (agr_abreviatura,agr_descripcion,agr_modo_asociacion_tpl,agr_codpai,agr_para_calculo) 
	values ('REP_ISR13Viaticos','REP - ISR 2013 - VIATICOS','TodosExcluyendo','gt',1);

COMMIT TRANSACTION;