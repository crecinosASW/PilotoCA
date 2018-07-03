-- Agrupadores

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codagr_ccss INT,
	@codagr_bp INT,
	@codagr_isr INT,
	@codagr_aguinaldo INT,
	@codagr_vacaciones INT,
	@codagr_incapacidades INT,
	@codagr_asociaciones INT,
	@codagr_embargo INT

SET @codpai = 'cr'

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoCCSS')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Calculo Seguro Social', 'CRBaseCalculoCCSS', 1, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoBP')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Calculo Banco Popular', 'CRBaseCalculoBP', 1, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoRenta')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Calculo Renta', 'CRBaseCalculoRenta', 1, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoAguinaldo') 
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Calculo de Aguinaldo', 'CRBaseCalculoAguinaldo', 1, 'TodosExcluyendo', '', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoVacaciones') 
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Calculo de Vacaciones', 'CRBaseCalculoVacaciones', 1, 'TodosExcluyendo', '', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoIncapacidades') 
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Calculo de Incapacidades', 'CRBaseCalculoIncapacidades', 1, 'TodosExcluyendo', '', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoAsociaciones') 
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Calculo de Asociaciones', 'CRBaseCalculoAsociaciones', 1, 'TodosExcluyendo', '', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRBaseCalculoEmbargo') 
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Base Calculo de Embargo', 'CRBaseCalculoEmbargo', 1, 'TodosExcluyendo', '', 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS (SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRDescuentosNoAplican') 
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Descuentos No Aplican', 'CRDescuentosNoAplican', 1, 'TodosExcluyendo', '', 'admin', GETDATE(), NULL, NULL)

SELECT @codagr_ccss = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoCCSS'

SELECT @codagr_bp = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoBP'

SELECT @codagr_isr = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoRenta'

SELECT @codagr_aguinaldo = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoAguinaldo'

SELECT @codagr_vacaciones = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoVacaciones'

SELECT @codagr_incapacidades = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoIncapacidades'

SELECT @codagr_asociaciones = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoAsociaciones'

SELECT @codagr_embargo = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRBaseCalculoEmbargo'

INSERT INTO sal.iag_ingresos_agrupador (iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion)
SELECT @codagr_ccss iag_codagr,
	tig_codigo iag_codtig, 
	1 iag_signo, 
	'Porcentaje' iag_aplicacion, 
	100.00 iag_valor, 
	0 iag_usa_salario_minimo, 
	'admin' iag_usuario_grabacion, 
	GETDATE() iag_fecha_grabacion
FROM sal.tig_tipos_ingreso
WHERE NOT EXISTS (SELECT NULL
					FROM sal.iag_ingresos_agrupador
					WHERE iag_codagr = @codagr_ccss
						AND iag_codtig = tig_codigo)
	AND EXISTS (SELECT NULL
				FROM eor.cia_companias
				WHERE cia_codpai = @codpai
					AND cia_codigo = tig_codcia)
ORDER BY tig_descripcion

INSERT INTO sal.iag_ingresos_agrupador (iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion)
SELECT @codagr_bp iag_codagr,
	tig_codigo iag_codtig, 
	1 iag_signo, 
	'Porcentaje' iag_aplicacion, 
	100.00 iag_valor, 
	0 iag_usa_salario_minimo, 
	'admin' iag_usuario_grabacion, 
	GETDATE() iag_fecha_grabacion
FROM sal.tig_tipos_ingreso
WHERE NOT EXISTS (SELECT NULL
					FROM sal.iag_ingresos_agrupador
					WHERE iag_codagr = @codagr_bp
						AND iag_codtig = tig_codigo)
	AND EXISTS (SELECT NULL
				FROM eor.cia_companias
				WHERE cia_codpai = @codpai
					AND cia_codigo = tig_codcia)
ORDER BY tig_descripcion

INSERT INTO sal.iag_ingresos_agrupador (iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion)
SELECT @codagr_isr iag_codagr,
	tig_codigo iag_codtig, 
	1 iag_signo, 
	'Porcentaje' iag_aplicacion, 
	100.00 iag_valor, 
	0 iag_usa_salario_minimo, 
	'admin' iag_usuario_grabacion, 
	GETDATE() iag_fecha_grabacion
FROM sal.tig_tipos_ingreso
WHERE NOT EXISTS (SELECT NULL
					FROM sal.iag_ingresos_agrupador
					WHERE iag_codagr = @codagr_isr
						AND iag_codtig = tig_codigo)
	AND EXISTS (SELECT NULL
				FROM eor.cia_companias
				WHERE cia_codpai = @codpai
					AND cia_codigo = tig_codcia)
ORDER BY tig_descripcion

INSERT INTO sal.iag_ingresos_agrupador (iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion)
SELECT @codagr_aguinaldo iag_codagr,
	tig_codigo iag_codtig, 
	1 iag_signo, 
	'Porcentaje' iag_aplicacion, 
	100.00 iag_valor, 
	0 iag_usa_salario_minimo, 
	'admin' iag_usuario_grabacion, 
	GETDATE() iag_fecha_grabacion
FROM sal.tig_tipos_ingreso
WHERE NOT EXISTS (SELECT NULL
					FROM sal.iag_ingresos_agrupador
					WHERE iag_codagr = @codagr_aguinaldo
						AND iag_codtig = tig_codigo)
	AND EXISTS (SELECT NULL
				FROM eor.cia_companias
				WHERE cia_codpai = @codpai
					AND cia_codigo = tig_codcia)
ORDER BY tig_descripcion

INSERT INTO sal.iag_ingresos_agrupador (iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion)
SELECT @codagr_vacaciones iag_codagr,
	tig_codigo iag_codtig, 
	1 iag_signo, 
	'Porcentaje' iag_aplicacion, 
	100.00 iag_valor, 
	0 iag_usa_salario_minimo, 
	'admin' iag_usuario_grabacion, 
	GETDATE() iag_fecha_grabacion
FROM sal.tig_tipos_ingreso
WHERE NOT EXISTS (SELECT NULL
					FROM sal.iag_ingresos_agrupador
					WHERE iag_codagr = @codagr_vacaciones
						AND iag_codtig = tig_codigo)
	AND EXISTS (SELECT NULL
				FROM eor.cia_companias
				WHERE cia_codpai = @codpai
					AND cia_codigo = tig_codcia)
ORDER BY tig_descripcion

INSERT INTO sal.iag_ingresos_agrupador (iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion)
SELECT @codagr_incapacidades iag_codagr,
	tig_codigo iag_codtig, 
	1 iag_signo, 
	'Porcentaje' iag_aplicacion, 
	100.00 iag_valor, 
	0 iag_usa_salario_minimo, 
	'admin' iag_usuario_grabacion, 
	GETDATE() iag_fecha_grabacion
FROM sal.tig_tipos_ingreso
WHERE NOT EXISTS (SELECT NULL
					FROM sal.iag_ingresos_agrupador
					WHERE iag_codagr = @codagr_incapacidades
						AND iag_codtig = tig_codigo)
	AND EXISTS (SELECT NULL
				FROM eor.cia_companias
				WHERE cia_codpai = @codpai
					AND cia_codigo = tig_codcia)
ORDER BY tig_descripcion

INSERT INTO sal.iag_ingresos_agrupador (iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion)
SELECT @codagr_asociaciones iag_codagr,
	tig_codigo iag_codtig, 
	1 iag_signo, 
	'Porcentaje' iag_aplicacion, 
	100.00 iag_valor, 
	0 iag_usa_salario_minimo, 
	'admin' iag_usuario_grabacion, 
	GETDATE() iag_fecha_grabacion
FROM sal.tig_tipos_ingreso
WHERE NOT EXISTS (SELECT NULL
					FROM sal.iag_ingresos_agrupador
					WHERE iag_codagr = @codagr_asociaciones
						AND iag_codtig = tig_codigo)
	AND EXISTS (SELECT NULL
				FROM eor.cia_companias
				WHERE cia_codpai = @codpai
					AND cia_codigo = tig_codcia)
ORDER BY tig_descripcion

INSERT INTO sal.iag_ingresos_agrupador (iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion)
SELECT @codagr_embargo iag_codagr,
	tig_codigo iag_codtig, 
	1 iag_signo, 
	'Porcentaje' iag_aplicacion, 
	100.00 iag_valor, 
	0 iag_usa_salario_minimo, 
	'admin' iag_usuario_grabacion, 
	GETDATE() iag_fecha_grabacion
FROM sal.tig_tipos_ingreso
WHERE NOT EXISTS (SELECT NULL
					FROM sal.iag_ingresos_agrupador
					WHERE iag_codagr = @codagr_embargo
						AND iag_codtig = tig_codigo)
	AND EXISTS (SELECT NULL
				FROM eor.cia_companias
				WHERE cia_codpai = @codpai
					AND cia_codigo = tig_codcia)
ORDER BY tig_descripcion

COMMIT