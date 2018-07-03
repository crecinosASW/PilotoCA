IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('sal.vca_vacaciones_calculadas'))
BEGIN
	DROP TABLE sal.vca_vacaciones_calculadas
END

GO

CREATE TABLE sal.vca_vacaciones_calculadas (
	vca_codigo                  int IDENTITY(1,1) NOT NULL,
	vca_codcia                  int NOT NULL,
	vca_codtpl                  int NOT NULL,
    vca_codppl                  int NOT NULL,
	vca_codemp                  int NOT NULL,
    vca_coddva                  int NOT NULL,
	vca_fecha_del_gozados       datetime NOT NULL,
	vca_fecha_al_gozados        datetime NULL,
	vca_tipo                    varchar(1), -- O=Operativo A=Administrativo
	vca_dias_gozados            int default 0 NULL,
	vca_dias_calendario         int default 0 NULL,
	vca_codplz                  int NULL,
	vca_codcco                  int NULL,
	vca_fecha_del_promedio      datetime NULL,
	vca_fecha_al_promedio       datetime NULL,
	vca_salario_actual          real default 0 NULL,
	vca_promedio                real default 0 NULL,
	vca_promedio_extras         real default 0 NULL,
	vca_antiguedad              real default 0 NULL,
	vca_valor_bono              real default 0 NULL,
	vca_valor_vacaciones        real default 0 NULL,
        vca_valor_vacaciones_extras real default 0 NULL,
	vca_usuario_crea            varchar(50) NULL,
	vca_fecha_crea              datetime NULL,
 CONSTRAINT PK_sal_vca_vacaciones_c PRIMARY KEY CLUSTERED 
(
	vca_codigo ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_vca_codpla_codemp] UNIQUE NONCLUSTERED 
(
	vca_codppl,
	vca_codemp,
        vca_coddva
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE sal.vca_vacaciones_calculadas ADD  DEFAULT (user_name()) FOR vca_usuario_crea
GO

ALTER TABLE sal.vca_vacaciones_calculadas ADD  DEFAULT (getdate()) FOR vca_fecha_crea
GO

ALTER TABLE sal.vca_vacaciones_calculadas  WITH CHECK ADD  CONSTRAINT fk_expemp_salvca FOREIGN KEY(vca_codemp)
REFERENCES [exp].[emp_empleos] ([emp_codigo])
GO

ALTER TABLE sal.vca_vacaciones_calculadas CHECK CONSTRAINT [fk_expemp_salvca]
GO

ALTER TABLE sal.vca_vacaciones_calculadas  WITH CHECK ADD  CONSTRAINT fk_salppl_salvca_1 FOREIGN KEY(vca_codppl)
REFERENCES [sal].[ppl_periodos_planilla] ([ppl_codigo])

GO

ALTER TABLE sal.vca_vacaciones_calculadas CHECK CONSTRAINT [fk_salppl_salvca_1]


GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Detalle de calculo de vacaciones' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código del detalle' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_codigo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de Compañia' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_codcia'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de Planilla' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_codtpl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de la planilla de salarios en la cual se pagan las vacaciones' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_codppl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código del Empleo' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_codemp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código del detalle de vacaciones tomadas' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_coddva'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de inicio de la toma de vacaciones' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_fecha_del_gozados'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha final de la toma de vacaciones' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_fecha_al_gozados'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de Empleado O-perativo A-dministrativo' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_tipo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de dias gozados' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_dias_gozados'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de dias calendario' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_dias_calendario'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de plaza' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_codplz'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de Centro de Costo' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_codcco'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de Inicio del Promedio' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_fecha_del_promedio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha Final del Promedio' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_fecha_al_promedio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Salario Actual' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_salario_actual'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Promedio Mensual de otros ingresos' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_promedio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Promedio Mensual de Extraordinario' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_promedio_extras'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Antiguedad del Empleado para calculo de Bono' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_antiguedad'
GO 
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor del Bono vacacional' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_valor_bono'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor de las vacaciones basadas en otros ingresos' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_valor_vacaciones'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor de las vacaciones basadas en Extraordinario' , @level0type=N'SCHEMA',@level0name=N'sal', @level1type=N'TABLE',@level1name=N'vca_vacaciones_calculadas', @level2type=N'COLUMN',@level2name=N'vca_valor_vacaciones_extras'
GO




