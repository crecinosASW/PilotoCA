DECLARE
   --IMPORTANTE: Colocar el código de la empresa para la configuración.
   v_codcia NUMBER(10,0);
   v_codagr_ordinario NUMBER(10,0);
   v_codagr_complemento_ordinario NUMBER(10,0);
   v_codagr_extraordinario NUMBER(10,0);
   v_codagr_bono_ley NUMBER(10,0);
   v_codagr_bonificaciones NUMBER(10,0);
   v_codagr_anticipo_ingreso NUMBER(10,0);
   v_codagr_igss NUMBER(10,0);
   v_codagr_prestamos NUMBER(10,0);
   v_codagr_seguros NUMBER(10,0);
   v_codagr_isr NUMBER(10,0);
   v_temp NUMBER(1, 0) := 0;

BEGIN
   v_codcia := 2 ;
   
   BEGIN
       SELECT agr_codigo 
         INTO v_codagr_ordinario
         FROM sal_agr_agrupadores 
        WHERE agr_abreviatura = 'GTPlanillaMensualOrdinario'
                AND agr_codpai = 'gt'
                AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   BEGIN         
       SELECT agr_codigo 
         INTO v_codagr_complemento_ordinario
         FROM sal_agr_agrupadores 
        WHERE agr_abreviatura = 'GTPlanillaMensualComplementoOrdinario'
                AND agr_codpai = 'gt'
                AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   BEGIN         
       SELECT agr_codigo 
         INTO v_codagr_extraordinario
         FROM sal_agr_agrupadores 
        WHERE agr_abreviatura = 'GTPlanillaMensualExtraordinario'
                AND agr_codpai = 'gt'
                AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   BEGIN
       SELECT agr_codigo 
         INTO v_codagr_bono_ley
         FROM sal_agr_agrupadores 
        WHERE agr_abreviatura = 'GTPlanillaMensualBonoLey'
                AND agr_codpai = 'gt'
                AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   BEGIN
       SELECT agr_codigo 
         INTO v_codagr_bonificaciones
         FROM sal_agr_agrupadores 
        WHERE agr_abreviatura = 'GTPlanillaMensualBonificaciones'
                AND agr_codpai = 'gt'
                AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   BEGIN
       SELECT agr_codigo 
         INTO v_codagr_anticipo_ingreso
         FROM sal_agr_agrupadores 
        WHERE agr_abreviatura = 'GTPlanillaMensualAnticipoIngreso'
                AND agr_codpai = 'gt'
                AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   BEGIN
       SELECT agr_codigo 
         INTO v_codagr_igss
         FROM sal_agr_agrupadores 
        WHERE agr_abreviatura = 'GTPlanillaMensualIGSS'
                AND agr_codpai = 'gt'
                AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   BEGIN
   SELECT agr_codigo 
     INTO v_codagr_prestamos
     FROM sal_agr_agrupadores 
    WHERE agr_abreviatura = 'GTPlanillaMensualPrestamos'
            AND agr_codpai = 'gt'
            AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   BEGIN
       SELECT agr_codigo 
         INTO v_codagr_seguros
         FROM sal_agr_agrupadores 
        WHERE agr_abreviatura = 'GTPlanillaMensualSeguros'
                AND agr_codpai = 'gt'
                AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   BEGIN
       SELECT agr_codigo 
         INTO v_codagr_isr
         FROM sal_agr_agrupadores 
        WHERE agr_abreviatura = 'GTPlanillaMensualISR'
                AND agr_codpai = 'gt'
                AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   --Agregan los Tipos de Familias de Ingresos y Descuentos si no existen
   /*Insertar el tipo de familia GT - Planilla Mensual - Ordinario*/
   IF v_codagr_ordinario IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla Mensual - Ordinario', 'GTPlanillaMensualOrdinario', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      SELECT MAX(agr_codigo) 

        INTO v_codagr_ordinario
        FROM sal_agr_agrupadores ;
   END;
   END IF;
   /*Insertar el tipo de familia GT - Planilla Mensual - Complemento Ordinario*/
   IF v_codagr_complemento_ordinario IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla Mensual - Complemento Ordinario', 'GTPlanillaMensualComplementoOrdinario', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      SELECT MAX(agr_codigo) 

        INTO v_codagr_complemento_ordinario
        FROM sal_agr_agrupadores ;
   END;
   END IF;
   /*Insertar el tipo de familia GT - Planilla Mensual - Extraordinario*/
   IF v_codagr_extraordinario IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla Mensual - Extraordinario', 'GTPlanillaMensualExtraordinario', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      SELECT MAX(agr_codigo) 

        INTO v_codagr_extraordinario
        FROM sal_agr_agrupadores ;
   END;
   END IF;
   /*Insertar el tipo de familia GT - Planilla Mensual - Bono Ley*/
   IF v_codagr_bono_ley IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla Mensual - Bono Ley', 'GTPlanillaMensualBonoLey', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      SELECT MAX(agr_codigo) 

        INTO v_codagr_bono_ley
        FROM sal_agr_agrupadores ;
   END;
   END IF;
   /*Insertar el tipo de familia GT - Planilla Mensual - Bonificaciones*/
   IF v_codagr_bonificaciones IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla Mensual - Bonificaciones', 'GTPlanillaMensualBonificaciones', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      SELECT MAX(agr_codigo) 

        INTO v_codagr_bonificaciones
        FROM sal_agr_agrupadores ;
   END;
   END IF;
   /*Insertar el tipo de familia GT - Planilla Mensual - Anticipo*/
   IF v_codagr_anticipo_ingreso IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla Mensual - Anticipo', 'GTPlanillaMensualAnticipoIngreso', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      SELECT MAX(agr_codigo) 

        INTO v_codagr_anticipo_ingreso
        FROM sal_agr_agrupadores ;
   END;
   END IF;
   /*Insertar el tipo de familia GT - Planilla Mensual - IGSS*/
   IF v_codagr_igss IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla Mensual - IGSS', 'GTPlanillaMensualIGSS', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      SELECT MAX(agr_codigo) 

        INTO v_codagr_igss
        FROM sal_agr_agrupadores ;
   END;
   END IF;
   /*Insertar el tipo de familia GT - Planilla Mensual - Prestamos*/
   IF v_codagr_prestamos IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla Mensual - Prestamos', 'GTPlanillaMensualPrestamos', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      SELECT MAX(agr_codigo) 

        INTO v_codagr_prestamos
        FROM sal_agr_agrupadores ;
   END;
   END IF;
   /*Insertar el tipo de familia GT - Planilla Mensual - Seguros*/
   IF v_codagr_seguros IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla Mensual - Seguros', 'GTPlanillaMensualSeguros', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      SELECT MAX(agr_codigo) 

        INTO v_codagr_seguros
        FROM sal_agr_agrupadores ;
   END;
   END IF;
   /*Insertar el tipo de familia GT - Planilla Mensual - ISR*/
   IF v_codagr_isr IS NULL THEN
   
   BEGIN
      INSERT INTO sal_agr_agrupadores
        ( agr_codpai, agr_descripcion, agr_abreviatura, agr_para_calculo, agr_modo_asociacion_tpl, agr_usuario_grabacion, agr_fecha_grabacion )
        VALUES ( 'gt', 'GT - Planilla Mensual - ISR', 'GTPlanillaMensualISR', 0, 'TodosExcluyendo', 'admin', SYSDATE );
      SELECT MAX(agr_codigo) 

        INTO v_codagr_isr
        FROM sal_agr_agrupadores ;
   END;
   END IF;
   -----------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------
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
                              WHERE iag_codagr = v_codagr_ordinario );
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
                                     AND ( tig_abreviatura = 'ORD'
                                     OR tig_abreviatura = 'VAC' ) );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_iag_ingresos_agrupador
              ( iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion )
              ( SELECT v_codagr_ordinario ,
                       tig_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tig_tipos_ingreso 
                 WHERE tig_codcia = v_codcia
                         AND ( tig_abreviatura = 'ORD'
                         OR tig_abreviatura = 'VAC' ) );
         END;
         END IF;
      END;
      END IF;
      --Complemento Ordinario
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT * 
                             FROM sal_iag_ingresos_agrupador 
                              WHERE iag_codagr = v_codagr_complemento_ordinario );
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
                                     AND ( tig_abreviatura = 'COMPORD' ) );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_iag_ingresos_agrupador
              ( iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion )
              ( SELECT v_codagr_complemento_ordinario ,
                       tig_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tig_tipos_ingreso 
                 WHERE tig_codcia = v_codcia
                         AND ( tig_abreviatura = 'COMPORD' ) );
         END;
         END IF;
      END;
      END IF;
      --Extraordinario
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT * 
                             FROM sal_iag_ingresos_agrupador 
                              WHERE iag_codagr = v_codagr_extraordinario );
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
                                     AND ( tig_abreviatura = 'HES'
                                     OR tig_abreviatura = 'HED' ) );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_iag_ingresos_agrupador
              ( iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion )
              ( SELECT v_codagr_extraordinario ,
                       tig_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tig_tipos_ingreso 
                 WHERE tig_codcia = v_codcia
                         AND ( tig_abreviatura = 'HES'
                         OR tig_abreviatura = 'HED' ) );
         END;
         END IF;
      END;
      END IF;
      --Bono Ley
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT * 
                             FROM sal_iag_ingresos_agrupador 
                              WHERE iag_codagr = v_codagr_bono_ley );
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
                                     AND tig_abreviatura = 'BLEY' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_iag_ingresos_agrupador
              ( iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion )
              ( SELECT v_codagr_bono_ley ,
                       tig_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tig_tipos_ingreso 
                 WHERE tig_codcia = v_codcia
                         AND tig_abreviatura = 'BLEY' );
         END;
         END IF;
      END;
      END IF;
      --Bonificaciones
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT * 
                             FROM sal_iag_ingresos_agrupador 
                              WHERE iag_codagr = v_codagr_bonificaciones );
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
                                     AND tig_abreviatura = 'BPAC' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_iag_ingresos_agrupador
              ( iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion )
              ( SELECT v_codagr_bonificaciones ,
                       tig_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tig_tipos_ingreso 
                 WHERE tig_codcia = v_codcia
                         AND tig_abreviatura = 'BPAC' );
         END;
         END IF;
      END;
      END IF;
      --Anticipo Quincenal Ingreso
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT * 
                             FROM sal_iag_ingresos_agrupador 
                              WHERE iag_codagr = v_codagr_anticipo_ingreso );
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
                                     AND tig_abreviatura = 'AQUI' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_iag_ingresos_agrupador
              ( iag_codagr, iag_codtig, iag_signo, iag_aplicacion, iag_valor, iag_usa_salario_minimo, iag_usuario_grabacion, iag_fecha_grabacion )
              ( SELECT v_codagr_anticipo_ingreso ,
                       tig_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tig_tipos_ingreso 
                 WHERE tig_codcia = v_codcia
                         AND tig_abreviatura = 'AQUI' );
         END;
         END IF;
      END;
      END IF;
      --Seguro Social
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT * 
                             FROM sal_dag_descuentos_agrupador 
                              WHERE dag_codagr = v_codagr_igss );
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
                            FROM sal_tdc_tipos_descuento 
                             WHERE tdc_codcia = v_codcia
                                     AND tdc_abreviatura = 'IGSS' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_dag_descuentos_agrupador
              ( dag_codagr, dag_codtdc, dag_signo, dag_aplicacion, dag_valor, dag_usa_salario_minimo, dag_usuario_grabacion, dag_fecha_grabacion )
              ( SELECT v_codagr_igss ,
                       tdc_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tdc_tipos_descuento 
                 WHERE tdc_codcia = v_codcia
                         AND tdc_abreviatura = 'IGSS' );
         END;
         END IF;
      END;
      END IF;
      --Prestamos
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT * 
                             FROM sal_dag_descuentos_agrupador 
                              WHERE dag_codagr = v_codagr_prestamos );
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
                            FROM sal_tdc_tipos_descuento 
                             WHERE tdc_codcia = v_codcia
                                     AND tdc_abreviatura = 'PPerso' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_dag_descuentos_agrupador
              ( dag_codagr, dag_codtdc, dag_signo, dag_aplicacion, dag_valor, dag_usa_salario_minimo, dag_usuario_grabacion, dag_fecha_grabacion )
              ( SELECT v_codagr_prestamos ,
                       tdc_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tdc_tipos_descuento 
                 WHERE tdc_codcia = v_codcia
                         AND tdc_abreviatura = 'PPerso' );
         END;
         END IF;
      END;
      END IF;
      --Seguros
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT * 
                             FROM sal_dag_descuentos_agrupador 
                              WHERE dag_codagr = v_codagr_seguros );
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
                            FROM sal_tdc_tipos_descuento 
                             WHERE tdc_codcia = v_codcia
                                     AND tdc_abreviatura = 'Seg Med' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_dag_descuentos_agrupador
              ( dag_codagr, dag_codtdc, dag_signo, dag_aplicacion, dag_valor, dag_usa_salario_minimo, dag_usuario_grabacion, dag_fecha_grabacion )
              ( SELECT v_codagr_seguros ,
                       tdc_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tdc_tipos_descuento 
                 WHERE tdc_codcia = v_codcia
                         AND tdc_abreviatura = 'Seg Med' );
         END;
         END IF;
      END;
      END IF;
      --ISR
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT * 
                             FROM sal_dag_descuentos_agrupador 
                              WHERE dag_codagr = v_codagr_isr );
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
                            FROM sal_tdc_tipos_descuento 
                             WHERE tdc_codcia = v_codcia
                                     AND tdc_abreviatura = 'ISR' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
            
         IF v_temp = 1 THEN
         
         BEGIN
            INSERT INTO sal_dag_descuentos_agrupador
              ( dag_codagr, dag_codtdc, dag_signo, dag_aplicacion, dag_valor, dag_usa_salario_minimo, dag_usuario_grabacion, dag_fecha_grabacion )
              ( SELECT v_codagr_isr ,
                       tdc_codigo ,
                       1 ,
                       'Porcentaje' ,
                       100.00 ,
                       0 ,
                       'admin' ,
                       SYSDATE 
                FROM sal_tdc_tipos_descuento 
                 WHERE tdc_codcia = v_codcia
                         AND tdc_abreviatura = 'ISR' );
         END;
         END IF;
      END;
      END IF;
   END;
   END IF;
END;

