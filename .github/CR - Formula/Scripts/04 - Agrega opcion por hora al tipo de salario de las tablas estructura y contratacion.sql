ALTER TABLE [acc].[esc_estructura_sal_contratos] DROP CONSTRAINT [ck_accesc_exp_valor]
GO
ALTER TABLE [acc].[esc_estructura_sal_contratos]  WITH CHECK ADD  CONSTRAINT [ck_accesc_exp_valor] CHECK  (([esc_exp_valor]='Hora' OR [esc_exp_valor]='Diario' OR [esc_exp_valor]='Mensual'))
GO
ALTER TABLE [acc].[esc_estructura_sal_contratos] CHECK CONSTRAINT [ck_accesc_exp_valor]
GO
ALTER TABLE [exp].[ese_estructura_sal_empleos] DROP CONSTRAINT [CK_ese_estructura_sal_empleos]
GO
ALTER TABLE [exp].[ese_estructura_sal_empleos]  WITH CHECK ADD  CONSTRAINT [CK_ese_estructura_sal_empleos] CHECK  (([ese_exp_valor]='Hora' OR [ese_exp_valor]='Diario' OR [ese_exp_valor]='Mensual'))
GO
ALTER TABLE [exp].[ese_estructura_sal_empleos] CHECK CONSTRAINT [CK_ese_estructura_sal_empleos]
GO
ALTER TABLE [acc].[idr_incremento_detalle_rubros] DROP CONSTRAINT [ck_idr_incremento_detalle_rubros_exp_valor]
GO
ALTER TABLE [acc].[idr_incremento_detalle_rubros]  WITH CHECK ADD  CONSTRAINT [ck_idr_incremento_detalle_rubros_exp_valor] CHECK  (([idr_exp_valor]='Hora' OR [idr_exp_valor]='Diario' OR [idr_exp_valor]='Mensual'))
GO
ALTER TABLE [acc].[idr_incremento_detalle_rubros] CHECK CONSTRAINT [ck_idr_incremento_detalle_rubros_exp_valor]
GO