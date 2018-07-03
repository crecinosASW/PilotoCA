IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.din_detalle_incapacidad'))
BEGIN
	DROP TABLE cr.din_detalle_incapacidad
END

GO

CREATE TABLE cr.din_detalle_incapacidad (
	din_codigo int IDENTITY(1,1) NOT NULL,
	din_codixe int NULL,
	din_codfin int NOT NULL,
	din_fecha_inicial datetime NOT NULL,
	din_fecha_final datetime NOT NULL,
	din_dias real NOT NULL,
	din_planilla_autorizada bit NOT NULL
 CONSTRAINT PK_din_detalle_incapacidad PRIMARY KEY CLUSTERED 
(
	din_codigo ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE cr.din_detalle_incapacidad  WITH CHECK ADD  CONSTRAINT FK_accixe_crdin FOREIGN KEY(din_codixe)
REFERENCES acc.ixe_incapacidades (ixe_codigo)
GO

ALTER TABLE cr.din_detalle_incapacidad CHECK CONSTRAINT FK_accixe_crdin
GO

ALTER TABLE cr.din_detalle_incapacidad  WITH CHECK ADD  CONSTRAINT FK_accfin_crdin FOREIGN KEY(din_codfin)
REFERENCES acc.fin_fondos_incapacidad (fin_codigo)
GO

ALTER TABLE cr.din_detalle_incapacidad CHECK CONSTRAINT FK_accfin_crdin
GO