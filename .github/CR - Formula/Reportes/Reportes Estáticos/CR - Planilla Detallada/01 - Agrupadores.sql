BEGIN TRANSACTION

DECLARE @codpai VARCHAR(2),
	@codagr_ingresos INT,
	@codagr_descuentos INT

SELECT @codpai = 'cr'

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaDetalladaIngresos'
	AND agr_codpai = @codpai

SELECT @codagr_descuentos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaDetalladaDescuentos'
	AND agr_codpai = @codpai
	
IF @codagr_ingresos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Detallada - Ingresos', 'CRPlanillaDetalladaIngresos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

IF @codagr_descuentos IS NULL
BEGIN
	INSERT INTO sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion) 
	VALUES(@codpai, 'CR - Planilla Detallada - Descuentos', 'CRPlanillaDetalladaDescuentos', 0, 'TodosExcluyendo', 'admin', GETDATE())
END

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaDetalladaIngresos'
	AND agr_codpai = @codpai

SELECT @codagr_descuentos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'CRPlanillaDetalladaDescuentos'
	AND agr_codpai = @codpai

INSERT INTO sal.iag_ingresos_agrupador (iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion)
SELECT @codagr_ingresos iag_codagr,
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
					WHERE iag_codagr = @codagr_ingresos
						AND iag_codtig = tig_codigo)
	AND EXISTS (SELECT NULL
				FROM eor.cia_companias
				WHERE cia_codpai = @codpai
					AND cia_codigo = tig_codcia)
ORDER BY tig_descripcion

INSERT INTO sal.dag_descuentos_agrupador(dag_codagr, dag_codtdc, dag_signo, dag_aplicacion, dag_valor, dag_usa_salario_minimo, dag_usuario_grabacion, dag_fecha_grabacion)
SELECT @codagr_descuentos dag_codagr,
	tdc_codigo dag_codtdc, 
	1 dag_signo, 
	'Porcentaje' dag_aplicacion, 
	100.00 dag_valor, 
	0 dag_usa_salario_minimo, 
	'admin' dag_usuario_grabacion, 
	GETDATE() dag_fecha_grabacion
FROM sal.tdc_tipos_descuento
WHERE NOT EXISTS (SELECT NULL
					FROM sal.dag_descuentos_agrupador
					WHERE dag_codagr = @codagr_descuentos
						AND dag_codtdc = tdc_codigo)
	AND EXISTS (SELECT NULL
				FROM eor.cia_companias
				WHERE cia_codpai = @codpai
					AND cia_codigo = tdc_codcia)
ORDER BY tdc_descripcion

COMMIT