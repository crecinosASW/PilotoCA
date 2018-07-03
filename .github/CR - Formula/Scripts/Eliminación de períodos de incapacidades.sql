BEGIN TRANSACTION

SELECT *
FROM acc.ixe_incapacidades
WHERE ixe_codemp = 2251

SELECT *
FROM acc.fin_fondos_incapacidad
WHERE fin_codemp = 2251

SELECT *
FROM acc.pie_periodos_incapacidad
WHERE pie_codixe = 39

SELECT *
FROM cr.din_detalle_incapacidad
WHERE din_codfin = 130

DELETE cr.din_detalle_incapacidad
WHERE din_codfin = 130

DELETE acc.pie_periodos_incapacidad
WHERE pie_codixe = 39

DELETE acc.fin_fondos_incapacidad
WHERE fin_codemp = 2251

SELECT *
FROM acc.ixe_incapacidades
WHERE ixe_codemp = 2251

SELECT *
FROM acc.fin_fondos_incapacidad
WHERE fin_codemp = 2251

SELECT *
FROM acc.pie_periodos_incapacidad
WHERE pie_codixe = 39

SELECT *
FROM cr.din_detalle_incapacidad
WHERE din_codfin = 130

--ROLLBACK
COMMIT