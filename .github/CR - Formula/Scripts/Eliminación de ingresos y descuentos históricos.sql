BEGIN TRANSACTION

DELETE sal.inn_ingresos
WHERE EXISTS (SELECT NULL
			  FROM sal.ppl_periodos_planilla
			  WHERE inn_codppl = ppl_codigo
				--AND ppl_codtpl = 4
				AND ppl_mes = 2
				AND ppl_anio = 2015)

DELETE sal.dss_descuentos
WHERE EXISTS (SELECT NULL
			  FROM sal.ppl_periodos_planilla
			  WHERE dss_codppl = ppl_codigo
				--AND ppl_codtpl = 4
				AND ppl_mes = 2
				AND ppl_anio = 2015)

--ROLLBACK
COMMIT


--UPDATE sal.ppl_periodos_planilla
--SET ppl_estado = 'Generado'
--WHERE ppl_anio = 2015
--	AND ppl_mes = 2