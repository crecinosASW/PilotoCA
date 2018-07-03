IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.hli_historico_liquidaciones'))
BEGIN
	DROP TABLE cr.hli_historico_liquidaciones
END

GO

------------------------------------------------------------
-- Evolution Costa Rica STANDARD                           --
-- Crea tabla donde se guarda el detalle de los calculos  --
-- de la liquidacion                                      --                            
------------------------------------------------------------

CREATE TABLE cr.hli_historico_liquidaciones(
    hli_codigo int IDENTITY(1,1) NOT NULL,
	hli_codemp int NOT NULL,
	hli_fecha_retiro datetime NOT NULL,
	hli_codtig smallint NOT NULL,
	hli_numero smallint NOT NULL,
	hli_fecha_ingreso datetime NULL,
	hli_codmon varchar(3) NULL,
	hli_base_calculo real NULL,
	hli_dias_totales real NULL,
	hli_dias_pago real NULL,
	hli_meses_promedio real NULL,
	hli_promedio_mensual money NULL,
	hli_promedio_diario money NULL,
	hli_salario_minimo money NULL,
	hli_salario_minimo_diario money NULL,
	hli_tasa_cambio real NULL,
	hli_fecha_ini datetime NULL,
	hli_fecha_fin datetime NULL,
	hli_salario real NULL,
	hli_variable real NULL,
	hli_periodo int NULL,
	hli_usuario_grabacion varchar(50),
	hli_fecha_grabacion datetime
 CONSTRAINT PK_cr_hli_historico_liq PRIMARY KEY CLUSTERED 
(
	hli_codigo ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_hli_codemp_retiro] UNIQUE NONCLUSTERED 
(
	hli_codemp ASC,
    hli_fecha_retiro ASC,
	hli_codtig ASC,
	hli_numero ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON
GO

ALTER TABLE cr.hli_historico_liquidaciones ADD CONSTRAINT DF_cr_hli_base_calculo DEFAULT ((0)) FOR hli_base_calculo
GO

ALTER TABLE cr.hli_historico_liquidaciones ADD CONSTRAINT DF_cr_hli_dias_totales DEFAULT ((0)) FOR hli_dias_totales
GO

ALTER TABLE cr.hli_historico_liquidaciones ADD CONSTRAINT DF_cr_hli_dias_pago DEFAULT ((0)) FOR hli_dias_pago
GO

ALTER TABLE cr.hli_historico_liquidaciones ADD CONSTRAINT DF_cr_hli_salario DEFAULT ((0)) FOR hli_salario
GO

ALTER TABLE cr.hli_historico_liquidaciones ADD CONSTRAINT DF_cr_hli_variable DEFAULT ((0)) FOR hli_variable
GO

ALTER TABLE cr.hli_historico_liquidaciones ADD CONSTRAINT DF_cr_hli_periodo DEFAULT ((0)) FOR hli_periodo
GO

ALTER TABLE cr.hli_historico_liquidaciones ADD CONSTRAINT DF_cr_hli_usuario_grabacion DEFAULT ((USER)) FOR hli_usuario_grabacion
GO

ALTER TABLE cr.hli_historico_liquidaciones ADD CONSTRAINT DF_cr_hli_fecha_grabacion DEFAULT ((GETDATE())) FOR hli_fecha_grabacion
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de registro del historico' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_codigo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código del empleado' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_codemp'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de Retiro' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_fecha_retiro'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de Ingreso, Indemnizacion, Aguinaldo, Bono 14, Vacaciones' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_codtig'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero correlativo del registro dentro del tipo de ingreso' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_numero'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de la moneda asociada al ingreso' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_codmon'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de Ingreso del Empleado' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_fecha_ingreso'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Base de Calculo del Ingreso' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_base_calculo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dias totales' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_dias_totales'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dias del Pago' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_dias_pago'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de Inicio del Periodo' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_fecha_ini'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha Final de Periodo' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_fecha_fin'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Salario del Periodo' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_salario'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor Variable del Periodo' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_variable'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Periodo' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_periodo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de grabación del registro' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_fecha_grabacion'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de grabación del registro' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones', @level2type=N'COLUMN',@level2name=N'hli_usuario_grabacion'
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla que almacena el detalle del calculo de la liquidacion' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'hli_historico_liquidaciones'
GO

ALTER TABLE [cr].[hli_historico_liquidaciones]  WITH CHECK ADD  CONSTRAINT [fk_exp_emp_cr_hli] FOREIGN KEY([hli_codemp])
REFERENCES [exp].[emp_empleos] ([emp_codigo])
GO

ALTER TABLE [cr].[hli_historico_liquidaciones] CHECK CONSTRAINT [fk_exp_emp_cr_hli]
GO

ALTER TABLE [cr].[hli_historico_liquidaciones]  WITH CHECK ADD  CONSTRAINT [fk_gen_mon_cr_hli] FOREIGN KEY([hli_codmon])
REFERENCES [gen].[mon_monedas] ([mon_codigo])
GO

ALTER TABLE [cr].[hli_historico_liquidaciones] CHECK CONSTRAINT [fk_gen_mon_cr_hli]
GO

ALTER TABLE [cr].[hli_historico_liquidaciones]  WITH CHECK ADD  CONSTRAINT [fk_sal_tig_cr_hli] FOREIGN KEY([hli_codtig])
REFERENCES [sal].[tig_tipos_ingreso] ([tig_codigo])
GO

ALTER TABLE [cr].[hli_historico_liquidaciones] CHECK CONSTRAINT [fk_sal_tig_cr_hli]
GO

