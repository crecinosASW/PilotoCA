IF EXISTS (SELECT NULL
		   FROM sys.objects 
		   WHERE object_id = object_id('cr.rep_cheques_planilla'))
BEGIN
	DROP PROCEDURE cr.rep_cheques_planilla
END

GO

--EXEC cr.rep_cheques_planilla 1, '1', '20130702', null, 'admin'
CREATE PROCEDURE cr.rep_cheques_planilla (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(7) = NULL,
	@codppl_visual VARCHAR(14) = NULL,
	@codcdt INT = NULL,
	@usuario VARCHAR(50) = NULL
) 

AS

SET NOCOUNT ON
SET DATEFORMAT DMY

DECLARE @codpai VARCHAR(2),
	@codtpl INT,
	@codppl INT,
	@codfpa_cheque INT
	
SELECT @codpai	= cia_codpai
FROM eor.cia_companias
WHERE cia_codigo = @codcia	
	
SELECT @codtpl = tpl_codigo
FROM sal.tpl_tipo_planilla 
WHERE tpl_codigo_visual = @codtpl_visual
	AND tpl_codcia = @codcia

SELECT @codppl = ppl_codigo	
FROM sal.ppl_periodos_planilla
WHERE ppl_codigo_planilla = @codppl_visual	
	AND ppl_codtpl = @codtpl
	
SET @codfpa_cheque = gen.get_valor_parametro_int('CodigoFPA_Cheque', @codpai, NULL, NULL, NULL)

SELECT cia_descripcion,
	exp_codigo_alternativo, 
	@codppl_visual ppl_codigo_planilla,
	hpa_nombres_apellidos,
	ISNULL((
		SELECT SUM(ISNULL(inn_valor, 0.00))
		FROM sal.inn_ingresos
		WHERE inn_codppl = hpa_codppl
			AND inn_codemp = hpa_codemp), 0.00) - 
	ISNULL((
		SELECT SUM(ISNULL(dss_valor, 0.00))
		FROM sal.dss_descuentos
		WHERE dss_codppl = hpa_codppl
			AND dss_codemp = hpa_codemp), 0.00) valor,
	cdt_codigo,
	cdt_descripcion
FROM sal.hpa_hist_periodos_planilla
	JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.cdt_centros_de_trabajo ON plz_codcdt = cdt_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN exp.fpe_formas_pago_empleo ON emp_codigo = fpe_codemp
WHERE fpe_codfpa = @codfpa_cheque
 	AND plz_codcdt = ISNULL(@codcdt, plz_codcdt)
 	AND hpa_codppl = @codppl
 	AND EXISTS (SELECT NULL
 				FROM sal.inn_ingresos
 				WHERE inn_codppl = hpa_codppl
 					AND inn_codemp = hpa_codemp)
	AND sco.permiso_empleo(hpa_codemp, @usuario) = 1
ORDER BY cdt_codigo, exp_codigo_alternativo