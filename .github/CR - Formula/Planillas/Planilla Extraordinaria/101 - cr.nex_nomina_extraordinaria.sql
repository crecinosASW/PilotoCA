IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.nex_nomina_extraordinaria'))
BEGIN
	DROP TABLE cr.nex_nomina_extraordinaria
END

GO

CREATE TABLE cr.nex_nomina_extraordinaria (
   nex_codigo bigint identity(1,1) not null,
   nex_codppl int not null,
   nex_codemp int not null,
   nex_ExtraordinarioExtraordinaria money not null,
   nex_IngresoEventualExtraordinaria money not null,
   nex_TotalIngresosExtraordinaria money not null,
   nex_SeguroSocialExtraordinaria money not null,
   nex_BancoPopularExtraordinaria money not null,
   nex_ISRExtraordinaria money not null,
   nex_DescuentoEventualExtraordinaria money not null,
   nex_TotalDescuentosExtraordinaria money not null,
   nex_NetoExtraordinaria money not null
);
alter table cr.nex_nomina_extraordinaria add constraint pk_cr_nex_ primary key (nex_codigo);
alter table cr.nex_nomina_extraordinaria add constraint fk_salppl_cr_nex_ foreign key (nex_codppl) references sal.ppl_periodos_planilla (ppl_codigo);
alter table cr.nex_nomina_extraordinaria add constraint fk_expemp_cr_nex_ foreign key (nex_codemp) references exp.emp_empleos (emp_codigo);

GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto devengado el empleado por Horas Extras Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nex_nomina_extraordinaria', @level2type = N'COLUMN', @level2name = N'nex_ExtraordinarioExtraordinaria';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago de Ingresos Eventuales Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nex_nomina_extraordinaria', @level2type = N'COLUMN', @level2name = N'nex_IngresoEventualExtraordinaria';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Suma de Todos los Ingresos Devengados por el Empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nex_nomina_extraordinaria', @level2type = N'COLUMN', @level2name = N'nex_TotalIngresosExtraordinaria';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar por concepto de IGSS al empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nex_nomina_extraordinaria', @level2type = N'COLUMN', @level2name = N'nex_SeguroSocialExtraordinaria';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor del descuento de banco popular', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nex_nomina_extraordinaria', @level2type = N'COLUMN', @level2name = N'nex_BancoPopularExtraordinaria';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al Empleado por concepto de ISR Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nex_nomina_extraordinaria', @level2type = N'COLUMN', @level2name = N'nex_ISRExtraordinaria';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar por Otros Descuentos al Empelado Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nex_nomina_extraordinaria', @level2type = N'COLUMN', @level2name = N'nex_DescuentoEventualExtraordinaria';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total de descuentos del empleado', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nex_nomina_extraordinaria', @level2type = N'COLUMN', @level2name = N'nex_TotalDescuentosExtraordinaria';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Liquido a Percibir por el Empleado en el Periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nex_nomina_extraordinaria', @level2type = N'COLUMN', @level2name = N'nex_NetoExtraordinaria';