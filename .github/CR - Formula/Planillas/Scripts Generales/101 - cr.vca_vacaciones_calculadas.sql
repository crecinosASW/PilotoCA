IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.vca_vacaciones_calculadas'))
BEGIN
	DROP TABLE cr.vca_vacaciones_calculadas
END

GO

CREATE TABLE cr.vca_vacaciones_calculadas (
	vca_codigo                  INT IDENTITY(1,1) NOT NULL,
	vca_codppl                  INT NOT NULL,
	vca_codemp                  INT NOT NULL,
	vca_coddva                  INT NOT NULL,
	vca_fecha_inicial			DATETIME NULL,
	vca_fecha_final				DATETIME NULL,
	vca_total_ingresos          MONEY NULL,
	vca_promedio_mensual        MONEY NULL,
	vca_promedio_diario			MONEY NULL,
	vca_valor					MONEY NULL,
	vca_tiempo			        REAL NULL,
	vca_unidad_tiempo			VARCHAR(10) NULL,					
	vca_usuario_grabacion       VARCHAR(50) NULL,
	vca_fecha_grabacion         DATETIME NULL,
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
