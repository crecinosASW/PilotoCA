IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gt.lis_log_interfase_sap'))
BEGIN
	DROP TABLE gt.lis_log_interfase_sap
END

GO

CREATE TABLE gt.lis_log_interfase_sap (
	[lis_codigo] [bigint] IDENTITY(1,1) NOT NULL,
	[lis_codppl] [bigint] NOT NULL,
	[lis_fecha_traslado] [varchar](30) NOT NULL,
	[lis_codigo_error] [varchar](20) NULL,
	[lis_mensaje_error] [varchar](250) NULL,
	CONSTRAINT [PK_gt.lis_log_interfase_sap] PRIMARY KEY CLUSTERED 
(
	[lis_codigo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO


