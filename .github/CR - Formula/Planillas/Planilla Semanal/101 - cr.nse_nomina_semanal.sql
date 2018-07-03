IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.nse_nomina_semanal'))
BEGIN
	DROP TABLE cr.nse_nomina_semanal
END

GO

CREATE TABLE cr.nse_nomina_semanal (
   nse_codigo bigint identity(1,1) not null,
   nse_codppl int not null,
   nse_codemp int not null,
   nse_SalarioPorHoraSemanal money not null,
   nse_ExtraordinarioSemanal money not null,
   nse_TiempoNoTrabajadoSemanal money not null,
   nse_PrestacionEmpleadoSemanal money not null,
   nse_VacacionesSemanal money not null,
   nse_PrestacionIncapacidadSemanal money not null,
   nse_IngresoCiclicoSemanal money not null,
   nse_IngresoEventualSemanal money not null,
   nse_TotalIngresosSemanal money not null,
   nse_SeguroSocialSemanal money not null,
   nse_BancoPopularSemanal money not null,
   nse_CreditoISRConyugeSemanal money not null,
   nse_CreditoISRHijosSemanal money not null,
   nse_ISRSemanal money not null,
   nse_PensionAlimenticiaSemanal money not null,
   nse_PensionAlimenticiaPorcentajeSemanal money not null,
   nse_EmbargoSemanal money not null,
   nse_SeguroMedicoSemanal money not null,
   nse_AsociacionSemanal money not null,
   nse_DescuentoCiclicoSemanal money not null,
   nse_DescuentoCiclicoPorcentajeSemanal money not null,
   nse_DescuentoEventualSemanal money not null,
   nse_TotalDescuentosSemanal money not null,
   nse_NetoSemanal money not null
);
alter table cr.nse_nomina_semanal add constraint pk_cr_nse_ primary key (nse_codigo);
alter table cr.nse_nomina_semanal add constraint fk_salppl_cr_nse_ foreign key (nse_codppl) references sal.ppl_periodos_planilla (ppl_codigo);
alter table cr.nse_nomina_semanal add constraint fk_expemp_cr_nse_ foreign key (nse_codemp) references exp.emp_empleos (emp_codigo);

GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Salario por Hora del Empleado', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_SalarioPorHoraSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto devengado el empleado por Horas Extras Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_ExtraordinarioSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor por tiempo no trabajado con goce de sueldo', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_TiempoNoTrabajadoSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Prestaciones del Empleado Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_PrestacionEmpleadoSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el monto a pagar al empleado por los días que está de vacaciones durante la planilla Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_VacacionesSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Complemento por suspension del seguro social Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_PrestacionIncapacidadSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pagos Fijos realizados al empleado mensualmente Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_IngresoCiclicoSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago de Ingresos Eventuales Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_IngresoEventualSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Suma de Todos los Ingresos Devengados por el Empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_TotalIngresosSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar por concepto de CCSS al empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_SeguroSocialSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor del descuento de banco popular', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_BancoPopularSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'El monto que se descuenta al ISR del empleado si tiene conyugüe', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_CreditoISRConyugeSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'El monto que se descuenta al ISR del empleado por el número de hijos que tiene', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_CreditoISRHijosSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al Empleado por concepto de ISR Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_ISRSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de descuentos cíclicos para la pensión alimenticia', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_PensionAlimenticiaSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de descuentos cíclicos por porcentaje para la pensión alimenticia', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_PensionAlimenticiaPorcentajeSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de descuentos cíclicos para el embargo', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_EmbargoSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el monto de Descuento por el Seguro Medico. Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_SeguroMedicoSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor por descuento de asociación', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_AsociacionSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al empleado por Prestamos Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_DescuentoCiclicoSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al empleado por Prestamos Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_DescuentoCiclicoPorcentajeSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar por Otros Descuentos al Empelado Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_DescuentoEventualSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total de descuentos del empleado', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_TotalDescuentosSemanal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Liquido a Percibir por el Empleado en el Periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nse_nomina_semanal', @level2type = N'COLUMN', @level2name = N'nse_NetoSemanal';

