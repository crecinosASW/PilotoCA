IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.din_detalle_incapacidad'))
BEGIN
	DROP TABLE cr.din_detalle_incapacidad
END

GO

IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.fin_fecha_incapacidad'))
BEGIN
	DROP TABLE cr.fin_fecha_incapacidad
END

GO

CREATE TABLE cr.fin_fecha_incapacidad (
	fin_codigo int IDENTITY(1,1) NOT NULL,
	fin_codemp int NOT NULL,
	fin_fecha_inicial datetime NOT NULL,
	fin_fecha_final datetime NOT NULL,
	fin_dias real NOT NULL,
	fin_codppl_genero int NOT NULL,
 CONSTRAINT PK_fin_fecha_incapacidad PRIMARY KEY CLUSTERED 
(
	fin_codigo ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE cr.fin_fecha_incapacidad  WITH CHECK ADD  CONSTRAINT FK_expemp_crfin FOREIGN KEY(fin_codemp)
REFERENCES exp.emp_empleos (emp_codigo)
GO

ALTER TABLE cr.fin_fecha_incapacidad CHECK CONSTRAINT FK_expemp_crfin
GO

ALTER TABLE cr.fin_fecha_incapacidad  WITH CHECK ADD  CONSTRAINT FK_salppl_crfin FOREIGN KEY(fin_codppl_genero)
REFERENCES sal.ppl_periodos_planilla (ppl_codigo)
GO

ALTER TABLE cr.fin_fecha_incapacidad CHECK CONSTRAINT FK_salppl_crfin
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Informacion de los días disponibles por incapacidad según las fechas' , @level0type=N'SCHEMA',@level0name=N'cr', @level1type=N'TABLE',@level1name=N'fin_fecha_incapacidad'