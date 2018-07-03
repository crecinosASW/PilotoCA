IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.nag_nomina_aguinaldo'))
BEGIN
	DROP TABLE cr.nag_nomina_aguinaldo
END

GO

CREATE TABLE cr.nag_nomina_aguinaldo (
   nag_codigo bigint identity(1,1) not null,
   nag_codppl int not null,
   nag_codemp int not null,
   nag_Aguinaldo money not null,
   nag_IngresoEventualAguinaldo money not null,
   nag_TotalIngresosAguinaldo money not null,
   nag_PensionAlimenticiaAguinaldo money not null,
   nag_PensionAlimenticiaPorcentajeAguinaldo money not null,
   nag_DescuentoEventualAguinaldo money not null,
   nag_TotalDescuentosAguinaldo money not null,
   nag_NetoAguinaldo money not null
);
alter table cr.nag_nomina_aguinaldo add constraint pk_cr_nag_ primary key (nag_codigo);
alter table cr.nag_nomina_aguinaldo add constraint fk_salppl_cr_nag_ foreign key (nag_codppl) references sal.ppl_periodos_planilla (ppl_codigo);
alter table cr.nag_nomina_aguinaldo add constraint fk_expemp_cr_nag_ foreign key (nag_codemp) references exp.emp_empleos (emp_codigo);

GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor Calculado de Aguinaldo', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nag_nomina_aguinaldo', @level2type = N'COLUMN', @level2name = N'nag_Aguinaldo';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago de Ingresos Eventuales Aguinaldo', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nag_nomina_aguinaldo', @level2type = N'COLUMN', @level2name = N'nag_IngresoEventualAguinaldo';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Suma de Todos los Ingresos Devengados por el Empleado en el periodo Aguinaldo', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nag_nomina_aguinaldo', @level2type = N'COLUMN', @level2name = N'nag_TotalIngresosAguinaldo';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de descuentos cíclicos para la pensión alimenticia', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nag_nomina_aguinaldo', @level2type = N'COLUMN', @level2name = N'nag_PensionAlimenticiaAguinaldo';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de descuentos cíclicos por porcentaje para la pensión alimenticia', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nag_nomina_aguinaldo', @level2type = N'COLUMN', @level2name = N'nag_PensionAlimenticiaPorcentajeAguinaldo';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar por Otros Descuentos al Empelado Aguinaldo', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nag_nomina_aguinaldo', @level2type = N'COLUMN', @level2name = N'nag_DescuentoEventualAguinaldo';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total de descuentos en el aguinaldo', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nag_nomina_aguinaldo', @level2type = N'COLUMN', @level2name = N'nag_TotalDescuentosAguinaldo';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Liquido a Percibir por el Empleado en el Periodo Aguinaldo', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nag_nomina_aguinaldo', @level2type = N'COLUMN', @level2name = N'nag_NetoAguinaldo';

