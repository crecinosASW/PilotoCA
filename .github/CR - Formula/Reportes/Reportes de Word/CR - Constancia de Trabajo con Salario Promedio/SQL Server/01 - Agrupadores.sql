-- Agrupadores

BEGIN TRANSACTION

SET DATEFORMAT YMD

DECLARE @codpai VARCHAR(2),
	@codagr_ingresos INT

SET @codpai = 'cr'

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRConstanciaTrabajoSalarioPromedioIngresos')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Constancia de Trabajo con Salario - Ingresos', 'CRConstanciaTrabajoSalarioPromedioIngresos', 0, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

IF NOT EXISTS(SELECT NULL FROM sal.agr_agrupadores WHERE agr_codpai = @codpai AND agr_abreviatura = 'CRConstanciaTrabajoSalarioPromedioEmbargo')
	INSERT sal.agr_agrupadores (agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_property_bag_data, agr_usuario_grabacion, agr_fecha_grabacion, agr_usuario_modificacion, agr_fecha_modificacion) 
	VALUES (@codpai, 'CR - Constancia de Trabajo con Salario - Embargo', 'CRConstanciaTrabajoSalarioPromedioEmbargo', 0, 'TodosExcluyendo', NULL, 'admin', GETDATE(), NULL, NULL)

SELECT @codagr_ingresos = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_codpai = @codpai
	AND agr_abreviatura = 'CRConstanciaTrabajoSalarioPromedioIngresos'

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

COMMIT