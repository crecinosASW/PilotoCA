IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('sal.emb_embargos'))
BEGIN
	DROP TABLE sal.emb_embargos
END

GO

CREATE TABLE sal.emb_embargos(
	emb_codigo int IDENTITY(1,1) NOT NULL,
	emb_codcdc int NOT NULL,
	emb_porcentaje_menor real NULL,
	emb_porcentaje_mayor real NULL,
	emb_salarios_minimos real NULL,
	emb_salario_inembargable money NULL,
	emb_salario_nominal money NULL,
	emb_cargas_sociales money NULL,
	emb_salario_embargable money NULL,
	emb_valor money NOT NULL,
	emb_aplicado_planilla bit NULL
 CONSTRAINT PK_emb_embargos PRIMARY KEY CLUSTERED 
(
	emb_codigo ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

--ALTER TABLE sal.emb_embargos ADD  CONSTRAINT DF_sal_emp_valor  DEFAULT ((0)) FOR emb_valor
--GO

ALTER TABLE sal.emb_embargos  WITH CHECK ADD  CONSTRAINT FK_salemb_salcdc FOREIGN KEY(emb_codcdc)
REFERENCES sal.cdc_cuotas_descuento_ciclico (cdc_codigo)
GO

ALTER TABLE sal.emb_embargos CHECK CONSTRAINT FK_salemb_salcdc
GO