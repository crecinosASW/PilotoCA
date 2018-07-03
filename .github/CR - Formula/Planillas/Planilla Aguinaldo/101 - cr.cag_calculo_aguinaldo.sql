IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.cag_calculo_aguinaldo'))
BEGIN
	DROP TABLE cr.cag_calculo_aguinaldo 
END

GO

CREATE TABLE cr.cag_calculo_aguinaldo (cag_codppl INT NOT NULL,
	cag_codemp INT NOT NULL,
	cag_total_ingresos MONEY NULL,
	cag_valor_maternidad MONEY NULL,
	cag_valor_total MONEY NULL,
	cag_valor MONEY NULL,
	cag_dias REAL NULL,
CONSTRAINT pk_cag_calculo_aguinaldo PRIMARY KEY CLUSTERED 
(
	cag_codppl ASC,
	cag_codemp ASC
)WITH (pad_INDEX  = OFF, STATISTICS_norecompute  = OFF, ignore_dup_KEY = OFF, allow_row_locks  = ON, allow_page_locks  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de planilla que se calcula para el aguinaldo' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'cag_calculo_aguinaldo', @level2type=N'COLUMN',@level2name=N'cag_codppl'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de empleo que participa en la planilla de aguinaldo' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'cag_calculo_aguinaldo', @level2type=N'COLUMN',@level2name=N'cag_codemp'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto a total en el período del aguinaldo' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'cag_calculo_aguinaldo', @level2type=N'COLUMN',@level2name=N'cag_valor_total'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto a pagar de aguinaldo' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'cag_calculo_aguinaldo', @level2type=N'COLUMN',@level2name=N'cag_valor'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Días trabajados que se computan para el cálculo deaguinaldo' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'cag_calculo_aguinaldo', @level2type=N'COLUMN',@level2name=N'cag_dias'
GO