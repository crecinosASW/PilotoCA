IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('gt.GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL'))
BEGIN
	DROP TABLE gt.GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL
END

GO

CREATE TABLE gt.GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL (
   MAQ_codigo bigint identity(1,1) not null,
   MAQ_codppl int not null,
   MAQ_codemp int not null,
   MAQ_GT_SalarioActual money not null,
   MAQ_GT_BonoPactadoActual money not null,
   MAQ_GT_BonoLeyActual money not null,
   MAQ_GT_DiasDelMes money not null,
   MAQ_GT_RetroactivoSalario money not null,
   MAQ_GT_RetroBoniPactada money not null,
   MAQ_GT_RetroBoniLey money not null,
   MAQ_GT_SueldoMensual money not null,
   MAQ_GT_BonoPactadoMensual money not null,
   MAQ_GT_BonoLeyMensual money not null,
   MAQ_GT_PrestacionesEmpleado money not null,
   MAQ_GT_PrestacionesPuesto money not null,
   MAQ_GT_DiasVacaciones money not null,
   MAQ_GT_DiasIncapacidad money not null,
   MAQ_GT_DiasAmonestacion money not null,
   MAQ_GT_DiasNoTrabajados money not null,
   MAQ_GT_DiasTrabajados money not null,
   MAQ_GT_AnticipoQuincenal money not null,
   MAQ_GT_Salario money not null,
   MAQ_GT_BonoPactado money not null,
   MAQ_GT_BonoLey money not null,
   MAQ_GT_Extraordinario money not null,
   MAQ_GT_ComplNuevosSalario money not null,
   MAQ_GT_ComplNuevosBonoPacta money not null,
   MAQ_GT_ComplNuevosBonoLey money not null,
   MAQ_GT_CompSuspensionIGSS money not null,
   MAQ_GT_MontoVacaciones money not null,
   MAQ_GT_MontoVacacionesBono money not null,
   MAQ_GT_Sustitucion money not null,
   MAQ_GT_Ingresos_Ciclicos money not null,
   MAQ_GT_OtrosIngresos float not null,
   MAQ_GT_SalarioBruto money not null,
   MAQ_GT_DescuentoAnticipo money not null,
   MAQ_GT_SeguroSocialPatrono money not null,
   MAQ_GT_SeguroSocial money not null,
   MAQ_GT_DescBoletoOrnato money not null,
   MAQ_GT_DescuentoISR money not null,
   MAQ_GT_SeguroMedico money not null,
   MAQ_GT_CiclicosPorcentaje money not null,
   MAQ_GT_ValorDescCiclicos money not null,
   MAQ_GT_OtrosDescuentos money not null,
   MAQ_GT_SalarioNeto money not null
);
alter table gt.GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL add constraint pk_gt_GT_M primary key (MAQ_codigo);
alter table gt.GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL add constraint fk_salppl_gt_GT_M foreign key (MAQ_codppl) references sal.ppl_periodos_planilla (ppl_codigo);
alter table gt.GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL add constraint fk_expemp_gt_GT_M foreign key (MAQ_codemp) references exp.emp_empleos (emp_codigo);

GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina la parte del Salario Nominal del Empleado Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_SalarioActual';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Calcula el valor de la Bonificacion Pactada Actual Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_BonoPactadoActual';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Obtiene el valor de la bonificacion de Ley actual Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_BonoLeyActual';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dias del Mes sera 30 o los dias desde la fecha de ingreso en el mes hasta 30 Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_DiasDelMes';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el valor del Retroactivo de Incremento sobre Salario Otorgado al Empleado Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_RetroactivoSalario';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto por Retroactivo a pagar al empleado por Bonificacion Pactada Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_RetroBoniPactada';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el monto a pagar al empleado por Retroactivo por Incremento de Bono Ley Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_RetroBoniLey';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sueldo Mensual ajustado por si hubo incrementos o si el ingreso fue en el mes Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_SueldoMensual';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bono Pactado Mensual ajustado por si hubo incrementos o si el ingreso fue en el mes Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_BonoPactadoMensual';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bono de Ley Mensual ajustado por si hubo incrementos o si el ingreso fue en el mes Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_BonoLeyMensual';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Prestaciones del Empleado Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_PrestacionesEmpleado';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Prestaciones del Puesto Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_PrestacionesPuesto';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina la cantidad de Dias a pagar al empleado por encontrarse de vacaciones Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_DiasVacaciones';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina la Cantidad de Dias a Descontar producto de una Accion de Incapacidad (suspension del IGSS Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_DiasIncapacidad';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dias Amonestacion para este periodo Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_DiasAmonestacion';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Obtiene el Tiempo No Trabajado por el Empleado Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_DiasNoTrabajados';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina la Cantidad de Dias Efectivamente trabajados por el empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_DiasTrabajados';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor del Anticipo a pagar en la quincena', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_AnticipoQuincenal';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Salario Correspondiente a esta quincena Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_Salario';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor de la Bonificacion Pactada Correspondiente al Periodo Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_BonoPactado';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor del Bono de Ley correspondiente al Periodo Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_BonoLey';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto devengado el empleado por Horas Extras Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_Extraordinario';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Complemento de Salario a Empleados nuevos en el periodo Anterior y que no tienen pago efectuado Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_ComplNuevosSalario';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Complemento de Bonificacion pactada a Empleados nuevos en el periodo Anterior y sin pago efectuado Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_ComplNuevosBonoPacta';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Complemento de Bonificacion de Ley a Empleados nuevos en el periodo Anterior y sin pago efectuado Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_ComplNuevosBonoLey';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Complemento por suspension del seguro social Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_CompSuspensionIGSS';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el monto a pagar al empleado por los días que está de vacaciones durante la planilla Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_MontoVacaciones';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de Bono por vacaciones gozadas Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_MontoVacacionesBono';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de la sustitucions o coberturas', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_Sustitucion';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pagos Fijos realizados al empleado mensualmente Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_Ingresos_Ciclicos';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago de Ingresos Eventuales Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_OtrosIngresos';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Suma de Todos los Ingresos Devengados por el Empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_SalarioBruto';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descuento por anticipo de Salario', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_DescuentoAnticipo';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto que deberá pagar el Patrono por Concepto de IGSS del Empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_SeguroSocialPatrono';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar por concepto de IGSS al empleado en el periodo Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_SeguroSocial';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al empleado por concepto de Boleto de Ornato Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_DescBoletoOrnato';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al Empleado por concepto de ISR Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_DescuentoISR';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el monto de Descuento por el Seguro Medico. Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_SeguroMedico';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al empleado por Prestamos Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_CiclicosPorcentaje';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar al empleado por Prestamos Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_ValorDescCiclicos';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Monto a Descontar por Otros Descuentos al Empelado Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_OtrosDescuentos';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determina el Liquido a Percibir por el Empleado en el Periodo Mensual', @level0type = N'SCHEMA', @level0name = N'gt', @level1type = N'TABLE', @level1name = N'GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL', @level2type = N'COLUMN', @level2name = N'MAQ_GT_SalarioNeto';

