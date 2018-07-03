DECLARE
   v_codcia NUMBER(10,0);
   --Declaración de Variables
   v_agrupador_aguinaldo NUMBER(10,0);
   v_temp NUMBER(1, 0) := 0;

BEGIN
   v_codcia := 1 ;
   begin
   SELECT agr_codigo 

     INTO v_agrupador_aguinaldo
     FROM sal_agr_agrupadores 
    WHERE agr_abreviatura = 'GTPlanillaAguinaldo'
            AND agr_codpai = 'gt'
            AND agr_para_calculo = 0;
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
      NULL; 
    END;

   --Agregan los Tipos de Familias de Ingresos y Descuentos si no existen
   /*Insertar el tipo de familia GT - Planilla de Aguinaldo*/
   IF v_agrupador_aguinaldo IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla de Aguinaldo', 'GTPlanillaAguinaldo', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      begin
      SELECT MAX(agr_codigo) 

        INTO v_agrupador_aguinaldo
        FROM sal_agr_agrupadores ;
      EXCEPTION 
      WHEN NO_DATA_FOUND THEN 
      NULL; 
      END;
        
   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE v_codcia IS NOT NULL
     AND EXISTS ( SELECT * 
                  FROM eor_cia_companias 
                   WHERE cia_codigo = v_codcia );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;
      
   IF v_temp = 1 THEN
   DECLARE
      v_temp NUMBER(1, 0) := 0;
   
   BEGIN
      /*Se agregan los ingresos correspondientes a la familia, sino existe ningún registro de ingresos en la familia.*/
      --Ordinario
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT * 
                             FROM sal_iag_ingresos_agrupador 
                              WHERE iag_codagr = v_agrupador_aguinaldo );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
         
      IF v_temp = 1 THEN
      DECLARE
         v_temp NUMBER(1, 0) := 0;
      
      BEGIN
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT * 
                            FROM sal_tig_tipos_ingreso 
                             WHERE tig_codcia = v_codcia
                                     AND ( tig_abreviatura = 'AGUI' ) );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_iag_ingresos_agrupador
              ( iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion )
              ( SELECT v_agrupador_aguinaldo ,
                       tig_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tig_tipos_ingreso 
                 WHERE tig_codcia = v_codcia
                         AND ( tig_abreviatura = 'AGUI' ) );
         END;
         END IF;
      END;
      END IF;
   END;
   END IF;
END;

