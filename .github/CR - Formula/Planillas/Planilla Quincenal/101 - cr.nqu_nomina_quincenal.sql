IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.nqu_nomina_quincenal'))
BEGIN
	DROP TABLE cr.nqu_nomina_quincenal
END

GO

CREATE TABLE cr.nqu_nomina_quincenal (
   nqu_codigo bigint identity(1,1) not null,
   nqu_codppl int not null,
   nqu_codemp int not null,
   nqu_DiasDelMes float not null,
   nqu_DiasDeLaQuincena float not null,
   nqu_SalarioActual money not null,
   nqu_SalarioMensual money not null,
   nqu_DiasVacacion float not null,
   nqu_DiasIncapacidad float not null,
   nqu_DiasAmonestacion float not null,
   nqu_DiasNoTrabajados float not null,
   nqu_DiasTrabajados float not null,
   nqu_Salario money not null,
   nqu_ComplementoSalario money not null,
   nqu_RetroactivoSalario money not null,
   nqu_PrestacionEmpleado money not null,
   nqu_Extraordinario money not null,
   nqu_PrestacionIncapacidad money not null,
   nqu_Vacacion money not null,
   nqu_Sustitucion money not null,
   nqu_IngresoCiclico money not null,
   nqu_IngresoEventual money not null,
   nqu_TotalIngresos money not null,
   nqu_SeguroSocial money not null,
   nqu_BancoPopular money not null,
   nqu_CreditoISRConyuge money not null,
   nqu_CreditoISRHijos money not null,
   nqu_ISR money not null,
   nqu_SeguroMedico money not null,
   nqu_Asociacion money not null,
   nqu_DescuentoCiclico money not null,
   nqu_DescuentoCiclicoPorcentaje money not null,
   nqu_DescuentoEventual money not null,
   nqu_TotalDescuentos money not null,
   nqu_Neto money not null
);
alter table cr.nqu_nomina_quincenal add constraint pk_cr_nqu_ primary key (nqu_codigo);
alter table cr.nqu_nomina_quincenal add constraint fk_salppl_cr_nqu_ foreign key (nqu_codppl) references sal.ppl_periodos_planilla (ppl_codigo);
alter table cr.nqu_nomina_quincenal add constraint fk_expemp_cr_nqu_ foreign key (nqu_codemp) references exp.emp_empleos (emp_codigo);

GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dias del Mes sera 30 o los dias desde la fecha de ingreso en el mes hasta 30 Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_DiasDelMes';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Días de la quincena del empleado', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_DiasDeLaQuincena';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina la parte del Salario Nominal del Empleado Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_SalarioActual';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sueldo Mensual ajustado por si hubo incrementos o si el ingreso fue en el mes Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_SalarioMensual';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina la cantidad de Dias a pagar al empleado por encontrarse de vacaciones Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_DiasVacacion';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina la Cantidad de Dias a Descontar producto de una Accion de Incapacidad (suspension del IGSS Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_DiasIncapacidad';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dias Amonestacion para este periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_DiasAmonestacion';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Obtiene el Tiempo No Trabajado por el Empleado Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_DiasNoTrabajados';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina la Cantidad de Dias Efectivamente trabajados por el empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_DiasTrabajados';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Salario Correspondiente a esta quincena Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_Salario';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Complemento de Salario a Empleados nuevos en el periodo Anterior y que no tienen pago efectuado Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_ComplementoSalario';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el valor del Retroactivo de Incremento sobre Salario Otorgado al Empleado Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_RetroactivoSalario';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Prestaciones del Empleado Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_PrestacionEmpleado';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto devengado el empleado por Horas Extras Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_Extraordinario';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Complemento por suspension del seguro social Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_PrestacionIncapacidad';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el monto a pagar al empleado por los días que está de vacaciones durante la planilla Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_Vacacion';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de la sustitucions o coberturas', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_Sustitucion';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pagos Fijos realizados al empleado mensualmente Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_IngresoCiclico';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago de Ingresos Eventuales Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_IngresoEventual';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Suma de Todos los Ingresos Devengados por el Empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_TotalIngresos';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar por concepto de IGSS al empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_SeguroSocial';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor del descuento de banco popular', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_BancoPopular';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'El monto que se descuenta al ISR del empleado si tiene conyugüe', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_CreditoISRConyuge';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'El monto que se descuenta al ISR del empleado por el número de hijos que tiene', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_CreditoISRHijos';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al Empleado por concepto de ISR Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_ISR';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el monto de Descuento por el Seguro Medico. Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_SeguroMedico';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor por descuento de asociación', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_Asociacion';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al empleado por Prestamos Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_DescuentoCiclico';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al empleado por Prestamos Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_DescuentoCiclicoPorcentaje';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar por Otros Descuentos al Empelado Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_DescuentoEventual';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total de descuentos del empleado', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_TotalDescuentos';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Liquido a Percibir por el Empleado en el Periodo Mensual', @level0type = N'SCHEMA', @level0name = N'cr', @level1type = N'TABLE', @level1name = N'nqu_nomina_quincenal', @level2type = N'COLUMN', @level2name = N'nqu_Neto';

