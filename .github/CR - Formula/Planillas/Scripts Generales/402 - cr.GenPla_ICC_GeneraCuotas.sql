IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_ICC_GeneraCuotas'))
BEGIN
	DROP PROCEDURE cr.GenPla_ICC_GeneraCuotas
END

GO

CREATE PROCEDURE cr.GenPla_ICC_GeneraCuotas ( 
	@sessionId uniqueidentifier = null,
	@codppl int
)
AS
   DECLARE @fecha_pago DATE,
		   @frecuencia VARCHAR(1),
		   @temp INT,
		   @codemp int,
		   @codigo int,
		   @codtig int,
		   @monto_indefinido money,
		   @proxima_cuota int,
		   @num_cuota int,
		   @cuota money,
		   @frecIGC int,
		   @ppl_fecha_ini DATETIME,
		   @ppl_fecha_fin DATETIME
		   
   
  
 
BEGIN
begin transaction 
   -- Obtiene la fecha de finalizacion y la frecuencia del periodo de planilla que va a utilizar 
   
   SELECT @fecha_pago=ppl_fecha_fin,
          @frecuencia=ppl_frecuencia,
		  @ppl_fecha_ini = ppl_fecha_ini,
		  @ppl_fecha_fin = ppl_fecha_fin
     FROM sal.ppl_periodos_planilla
    WHERE ppl_codigo = @codppl
   -- Elimina de la tabla de cuotas las que corresponden a ese periodo de pago 
   -- para regenerarlas 
   
   DELETE sal.cic_cuotas_ingreso_ciclico
    WHERE cic_codppl = @codppl

  DECLARE cIGC CURSOR FOR 
	   SELECT igc_codemp codemp,
			  IGC_CODIGO codigo,
			  IGC_CODTIG codtig,
			  IGC_FRECUENCIA_PERIODO_PLA  frecIGC,
		      IGC_monto_indefinido   monto_indefinido,
		      IGC_proxima_cuota      proxima_cuota,
		      IGC_NUMERO_CUOTAs       num_cuota,
		      (CASE 
				 WHEN IGC_saldo < IGC_valor_cuota THEN IGC_saldo
		       ELSE IGC_valor_cuota
			   END) cuota 
			FROM sal.igc_ingresos_ciclicos_v 
			 JOIN exp.emp_empleos        ON emp_codigo = IGC_CODEMP
			 JOIN SAL.tig_tipos_ingreso  ON tig_codigo = IGC_CODTIG
			WHERE igc_codtpl = (select ppl_codTPL from sal.ppl_periodos_planilla where ppl_codigo = @codppl)
			 AND igc_estado = 'Autorizado'
			 AND igc_activo = 1
			 AND ISNULL(igc_saldo, 9999999999) > 0
			 AND igc_valor_cuota <> 0
			 AND igc_fecha_inicio_pago <= @fecha_pago
			 AND (emp_estado = 'A'
				OR (emp_estado = 'R' AND emp_fecha_retiro BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin))
			 AND ( igc_frecuencia_PERIODO_PLA = @frecuencia
			 OR IGC_FRECUENCIA_PERIODO_PLA = 0)

   OPEN cIGC 

WHILE 1 = 1 -- TRUE
BEGIN 

   FETCH NEXT FROM cIGC INTO @codEMP, @codigo, @codtig, @frecIGC, @monto_indefinido, @proxima_cuota, @num_cuota, @cuota
   if @@FETCH_STATUS <> 0 break
      BEGIN
         -- Inserta un nuevo registro en PLA_CIC_CUOTAS_ING 

         IF @monto_indefinido = 1
           OR @proxima_cuota <= @num_cuota
           
            set @temp = 0
         
               SELECT @temp=COUNT(*)
                 FROM SAL.cic_cuotas_ingreso_ciclico 
                WHERE cic_codigc = @codigo
                  and cic_numERO_cuota = @proxima_cuota
               
            IF @temp = 0 
               INSERT INTO SAL.cic_cuotas_ingreso_ciclico
                 (CIC_CODIGC,CIC_NUMERO_CUOTA,CIC_CODPPL,CIC_FECHA_PAGO,CIC_VALOR_CUOTA,CIC_APLICADO_PLANILLA,CIC_PLANILLA_AUTORIZADA)
                 VALUES (@codigo, @proxima_cuota, @codppl, @fecha_pago, round(@cuota, 2), 1, 0 )
            
        
      END
   END
   
CLOSE cIGC  
DEALLOCATE cIGC  

COMMIT TRANSACTION 
END
return
