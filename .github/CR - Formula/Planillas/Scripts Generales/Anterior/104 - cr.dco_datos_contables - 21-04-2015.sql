IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.dco_datos_contables'))
BEGIN
	DROP TABLE cr.dco_datos_contables
END

GO

CREATE TABLE cr.dco_datos_contables (
	dco_codigo bigint IDENTITY(1,1) NOT NULL,
	dco_codppl int NULL,
	dco_codemp int NULL,
	dco_tipo_partida varchar(1) NULL,
	dco_grupo char(20) NULL,
	dco_centro_costo varchar(50) NULL,
	dco_linea int NULL,
	dco_mes int NULL,
	dco_anio int NULL,
	dco_cta_contable varchar(40) NULL,
	dco_descripcion varchar(300) NULL,
	dco_debitos money NULL,
	dco_creditos money NULL
 CONSTRAINT pk_crdco PRIMARY KEY CLUSTERED 
(
	dco_codigo ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de planilla al que pertenece el dato contable' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_codppl'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de partida: G:Partida de Gastos, L: Partida de Liquidación, R:Partida de Reservas Legales' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_tipo_partida'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Forma de agrupar la información contable' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_grupo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Centro de costo ' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_centro_costo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Línea de la póliza contable' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_linea'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mes a que pertenece la información contable' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_mes'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Año al que pertenece la información contable' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_anio'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cuenta contable que afecta' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_cta_contable'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la partida' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_descripcion'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto en que se debiita la cuenta' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_debitos'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto en que se acredita la cuenta' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'dco_datos_contables', @level2type=N'COLUMN',@level2name=N'dco_creditos'
GO

ALTER TABLE cr.dco_datos_contables  WITH CHECK ADD  CONSTRAINT fk_expemp_crdco FOREIGN KEY(dco_codemp)
REFERENCES exp.emp_empleos (emp_codigo)
GO

ALTER TABLE cr.dco_datos_contables CHECK CONSTRAINT fk_expemp_crdco
GO

ALTER TABLE cr.dco_datos_contables  WITH CHECK ADD  CONSTRAINT fk_salppl_crdco FOREIGN KEY(dco_codppl)
REFERENCES sal.ppl_periodos_planilla (ppl_codigo)
GO

ALTER TABLE cr.dco_datos_contables CHECK CONSTRAINT fk_salppl_crdco
GO