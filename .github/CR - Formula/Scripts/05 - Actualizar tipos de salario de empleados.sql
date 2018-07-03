BEGIN TRANSACTION

UPDATE exp.ese_estructura_sal_empleos
SET ese_exp_valor = 'Hora'
WHERE ese_exp_valor = 'HORA'

UPDATE exp.ese_estructura_sal_empleos
SET ese_exp_valor = 'Diario'
WHERE ese_exp_valor = 'DIARIO'

UPDATE exp.ese_estructura_sal_empleos
SET ese_exp_valor = 'Mensual'
WHERE ese_exp_valor = 'MENSUAL'

UPDATE exp.ese_estructura_sal_empleos
SET ese_exp_valor = 'Hora'
WHERE ese_exp_valor = 'Diario'

SELECT ese_exp_valor, COUNT(*) numero
FROM exp.ese_estructura_sal_empleos
GROUP BY ese_exp_valor

COMMIT
--ROLLBACK