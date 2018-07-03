	INSERT INTO cr.din_detalle_incapacidad (
		din_codfin,
		din_fecha_inicial,
		din_fecha_final,
		din_dias,
		din_planilla_autorizada)
	VALUES (268,
		'20150505',
		'20150507',
		3,
		1)

SELECT *
FROM acc.fin_fondos_incapacidad
WHERE fin_codigo = 268

SELECT *
FROM cr.din_detalle_incapacidad
WHERE din_codfin = 268

--SELECT (SELECT SUM(din_dias)
--	FROM cr.din_detalle_incapacidad
--	WHERE din_codfin = fin_codigo) din_dias,
--	exp_codigo_alternativo, exp_nombres_apellidos,
--	*
--FROM acc.fin_fondos_incapacidad
--	JOIN exp.emp_empleos ON fin_codemp = emp_codigo
--	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
--WHERE fin_dias_incapacitado > (SELECT SUM(din_dias)
--							   FROM cr.din_detalle_incapacidad
--							   WHERE din_codfin = fin_codigo)
--ORDER BY fin_hasta DESC