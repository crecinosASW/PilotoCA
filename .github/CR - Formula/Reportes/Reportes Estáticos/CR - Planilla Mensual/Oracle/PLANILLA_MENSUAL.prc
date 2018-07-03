CREATE OR REPLACE
PROCEDURE planilla_mensual
--planilla_mensual 2, '01', '20110101', null, null
(
  v_CODCIA IN NUMBER DEFAULT NULL ,
  iv_CODTPLVISUAL IN VARCHAR2 DEFAULT NULL ,
  iv_CODPLAVISUAL IN VARCHAR2 DEFAULT NULL ,
  v_CODARF IN NUMBER DEFAULT NULL ,
  v_CODUNI IN NUMBER DEFAULT NULL ,
  cv_1 OUT SYS_REFCURSOR
)
AS
   v_CODTPLVISUAL VARCHAR2(50) := iv_CODTPLVISUAL;
   v_CODPLAVISUAL VARCHAR2(10) := iv_CODPLAVISUAL;
   --****VARIBLES DE AMBIENTE
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
   v_CODTPL NUMBER(10,0);
   v_CODPLA NUMBER(10,0);
   v_PPLANILLA VARCHAR2(100);
   v_PPERIODO_INI DATE;
   v_PPERIODO_FIN DATE;
   v_PPERIODO_INI_REAL DATE;
   v_PFRECUENCIA NUMBER(10,0);
   v_TIPO VARCHAR2(50);
   v_CODPAI VARCHAR2(2);
   --join eor_cco_centros_de_costo on cco_codarf=hpa_codarf    
   --CREAMOS LA TEMPORAL TABLA A UTILIZAR
   v_PCODEMP NUMBER(10,0);
   v_PCODIGOANTERIOR VARCHAR2(20);
   v_PNOMBRE VARCHAR2(100);
   v_PEMPRESA VARCHAR2(100);
   v_PAREAFUN VARCHAR2(100);
   v_PUNIDAD VARCHAR2(100);
   v_PCENTRO VARCHAR2(100);
   v_PPORCENTAJE FLOAT(24);
   v_PSALARIO NUMBER(19,2);
   v_PDIAS NUMBER(10,0);
   v_PORDINARIO NUMBER(19,2);
   v_PCOMPORD NUMBER(19,2);
   v_PBONI372001 NUMBER(19,2);
   v_POTRASBONIFICACIONES NUMBER(19,2);
   v_PANTICIPOQUINCENAL NUMBER(19,2);
   v_PEXTRAS NUMBER(19,2);
   v_PVARIOS NUMBER(19,2);
   v_PDEVENGADO NUMBER(19,2);
   v_PIGSS NUMBER(19,2);
   v_PRESTAMO NUMBER(19,2);
   v_SEGUROS NUMBER(19,2);
   v_PRENTA NUMBER(19,2);
   v_POTROSDESCUENTOS NUMBER(19,2);
   v_PTOTALDEDUCCIONES NUMBER(19,2);
   v_PSALARIONETO NUMBER(19,2);
   v_CONTADOR NUMBER(10,0);
   v_CENTRO_ANT VARCHAR2(100);
   v_DIASNOTRABING NUMBER(10,0);

   CURSOR EMPLEADOS IS 
     SELECT EMP_CODIGO ,
            NULL EMP_CODIGO_ANTERIOR  ,
            hpa_nombres_apellidos ,
            cia_descripcion ,
            hpa_nombre_areafun arf_nombre  ,
            hpa_nombre_unidad uni_nombre  ,
            hpa_salario emp_salario  ,
            NULL cco_descripcion ,
            100 cpp_porcentaje  
     FROM exp_emp_empleos 
        JOIN eor_plz_plazas       ON emp_codplz = plz_codigo
        JOIN eor_cia_companias    ON cia_codigo = plz_codcia
        JOIN sal_hpa_hist_periodos_planilla   ON hpa_codemp = emp_codigo
        JOIN (  SELECT DISTINCT INN_CODEMP 
                FROM sal_inn_ingresos 
                WHERE inn_codppl = v_CODPLA AND INN_VALOR > 0 ) F1
          ON hpa_codemp = F1.INN_CODEMP
     WHERE plz_codcia = v_CODCIA
         AND hpa_codarf = NVL(v_CODARF, HPA_CODARF)
         AND hpa_codcdt = NVL(v_CODUNI, hpa_codcdt)
         AND hpa_codppl = v_CODPLA
     ORDER BY hpa_codarf,
                 hpa_codcdt,
                 hpa_nombre_unidad,
                 hpa_nombre_centro_trabajo,
                 emp_codigo;

BEGIN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PLANILLA_MENSUAL ';
   v_CODTPLVISUAL := REPLACE(v_CODTPLVISUAL, '''', '') ;
   v_CODPLAVISUAL := REPLACE(v_CODPLAVISUAL, '''', '') ;
   
   BEGIN
       SELECT agr_codigo 
         INTO v_codagr_ordinario
         FROM sal_agr_agrupadores 
        WHERE agr_abreviatura = 'GTPlanillaMensualOrdinario'
                AND agr_codpai = 'gt'
                AND agr_para_calculo = 0;
   EXCEPTION
    WHEN OTHERS THEN
      v_codagr_ordinario := NULL;
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
      v_codagr_complemento_ordinario := NULL;
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
      v_codagr_extraordinario := NULL;
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
      v_codagr_bono_ley := NULL;
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
      v_codagr_bonificaciones := NULL;
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
      v_codagr_anticipo_ingreso := NULL;
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
      v_codagr_igss := NULL;
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
      v_codagr_prestamos := NULL;
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
      v_codagr_seguros := NULL;
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
      v_codagr_isr := NULL;
   END; 
   
   BEGIN
       SELECT CIA_CODPAI 
         INTO v_CODPAI
         FROM eor_cia_companias 
        WHERE cia_codigo = v_CODCIA;
   EXCEPTION
    WHEN OTHERS THEN
      v_CODPAI := NULL;
   END; 
   
   BEGIN
       SELECT TPL_DESCRIPCION ,
              TPL_FRECUENCIA ,
              tpl_codigo ,
              ppl_codigo ,
              PPL_FECHA_INI ,
              PPL_FECHA_FIN ,
              PPL_FRECUENCIA 

         INTO v_PPLANILLA,
              v_TIPO,
              v_CODTPL,
              v_CODPLA,
              v_PPERIODO_INI,
              v_PPERIODO_FIN,
              v_PFRECUENCIA
         FROM sal_tpl_tipo_planilla 
                JOIN sal_ppl_periodos_planilla 
                 ON ppl_codtpl = tpl_codigo
        WHERE tpl_codcia = v_CODCIA
                AND tpl_codigo_visual = v_CODTPLVISUAL
                AND ppl_codigo_planilla = v_CODPLAVISUAL;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   
   IF v_PFRECUENCIA = 1 AND v_TIPO <> 'Mensual' THEN
     BEGIN
        v_PPERIODO_INI_REAL := to_date(v_PPERIODO_INI, 'dd/mm/yyyy') ;
        v_PPLANILLA := 'PLANILLA DE ANTICIPO QUINCENAL' ;
     END;
     ELSE
     BEGIN
      
        IF v_PPERIODO_INI IS NOT NULL THEN
          v_PPERIODO_INI_REAL := to_date('01/' || to_char(month(v_PPERIODO_INI)) || '/' || to_char(year(v_PPERIODO_INI)), 'dd/mm/yyyy');
        END IF;
        v_PPLANILLA := 'PLANILLA MENSUAL' ;
        
     END;
   END IF;
   
   v_CONTADOR := 1 ;
   OPEN EMPLEADOS;
   FETCH EMPLEADOS INTO v_PCODEMP,v_PCODIGOANTERIOR,v_PNOMBRE,v_PEMPRESA,v_PAREAFUN,v_PUNIDAD,v_PSALARIO,v_PCENTRO,v_PPORCENTAJE;
   WHILE EMPLEADOS%FOUND 
   LOOP 
      
      BEGIN
         IF v_PUNIDAD = v_CENTRO_ANT THEN
            v_CONTADOR := v_CONTADOR + 1 ;
         ELSE
            v_CONTADOR := 1 ;
         END IF;
         
         BEGIN
             SELECT SUM(round(NVL(INN_VALOR, 0), 2)) ,
                    SUM(INN_TIEMPO) 
               INTO v_PORDINARIO,
                    v_PDIAS
               FROM sal_inn_ingresos 
              WHERE inn_codppl = v_CODPLA
                      AND INN_CODEMP = v_PCODEMP
                      AND INN_CODTIG IN ( SELECT iag_codtig 
                                          FROM sal_agr_agrupadores 
                                                 JOIN sal_iag_ingresos_agrupador 
                                                  ON iag_codagr = agr_codigo
                                           WHERE agr_codpai = v_CODPAI
                                                   AND agr_codigo = v_codagr_ordinario );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN                                             
             SELECT SUM(round(NVL(INN_VALOR, 0), 2)) 
               INTO v_PCOMPORD
               FROM sal_INN_INGRESOS 
              WHERE INN_CODPPL = v_CODPLA
                      AND INN_CODEMP = v_PCODEMP
                      AND INN_CODTIG IN ( SELECT iag_codtig 
                                          FROM sal_agr_agrupadores 
                                                 JOIN sal_iag_ingresos_agrupador 
                                                  ON iag_codagr = agr_codigo
                                           WHERE agr_codpai = v_CODPAI
                                                   AND IAG_CODAGR = v_codagr_complemento_ordinario );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN                                      
             SELECT SUM(round(NVL(INN_VALOR, 0), 2)) 
               INTO v_PEXTRAS
               FROM sal_INN_INGRESOS 
              WHERE INN_CODPPL = v_CODPLA
                      AND INN_CODEMP = v_PCODEMP
                      AND INN_CODTIG IN ( SELECT iag_codtig 
                                          FROM sal_agr_agrupadores 
                                                 JOIN sal_iag_ingresos_agrupador 
                                                  ON iag_codagr = agr_codigo
                                           WHERE agr_codpai = v_CODPAI
                                                   AND IAG_CODAGR = v_codagr_extraordinario );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN                                      
             SELECT SUM(round(NVL(INN_VALOR, 0), 2)) 
               INTO v_PBONI372001
               FROM sal_INN_INGRESOS 
              WHERE INN_CODPPL = v_CODPLA
                      AND INN_CODEMP = v_PCODEMP
                      AND INN_CODTIG IN ( SELECT iag_codtig 
                                          FROM sal_agr_agrupadores 
                                                 JOIN sal_iag_ingresos_agrupador 
                                                  ON iag_codagr = agr_codigo
                                           WHERE agr_codpai = v_CODPAI
                                                   AND IAG_CODAGR = v_codagr_bono_ley );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN                                      
             SELECT SUM(round(NVL(INN_VALOR, 0), 2)) 
               INTO v_POTRASBONIFICACIONES
               FROM sal_INN_INGRESOS 
              WHERE INN_CODPPL = v_CODPLA
                      AND INN_CODEMP = v_PCODEMP
                      AND INN_CODTIG IN ( SELECT iag_codtig 
                                          FROM sal_agr_agrupadores 
                                                 JOIN sal_iag_ingresos_agrupador 
                                                  ON iag_codagr = agr_codigo
                                           WHERE agr_codpai = v_CODPAI
                                                   AND IAG_CODAGR = v_codagr_bonificaciones );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN                                      
             SELECT SUM(round(NVL(INN_VALOR, 0), 2)) 
               INTO v_PANTICIPOQUINCENAL
               FROM sal_INN_INGRESOS 
              WHERE INN_CODPPL = v_CODPLA
                      AND INN_CODEMP = v_PCODEMP
                      AND INN_CODTIG IN ( SELECT iag_codtig 
                                          FROM sal_agr_agrupadores 
                                                 JOIN sal_iag_ingresos_agrupador 
                                                  ON iag_codagr = agr_codigo
                                           WHERE agr_codpai = v_CODPAI
                                                   AND IAG_CODAGR = v_codagr_anticipo_ingreso );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN                                      
             SELECT SUM(round(NVL(INN_VALOR, 0), 2)) 
               INTO v_PVARIOS
               FROM sal_INN_INGRESOS 
              WHERE INN_CODPPL = v_CODPLA
                      AND INN_CODEMP = v_PCODEMP
                      AND INN_CODTIG NOT IN ( SELECT iag_codtig 
                                              FROM sal_agr_agrupadores 
                                                     JOIN sal_iag_ingresos_agrupador 
                                                      ON iag_codagr = agr_codigo
                                               WHERE agr_codpai = v_CODPAI
                                                       AND IAG_CODAGR IN ( v_codagr_ordinario,v_codagr_extraordinario,v_codagr_bono_ley,v_codagr_bonificaciones,v_codagr_anticipo_ingreso,v_codagr_complemento_ordinario )
                                            );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN        
             SELECT SUM(round(NVL(INN_VALOR, 0), 2)) 
               INTO v_PDEVENGADO
               FROM sal_INN_INGRESOS 
              WHERE INN_CODPPL = v_CODPLA AND INN_CODEMP = v_PCODEMP;
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN
             SELECT SUM(round(NVL(DSS_VALOR, 0), 2)) 
               INTO v_PIGSS
               FROM sal_dss_descuentos 
              WHERE dss_codppl = v_CODPLA
                      AND DSS_CODEMP = v_PCODEMP
                      AND DSS_CODTDC IN ( SELECT dag_codtdc 
                                          FROM sal_agr_agrupadores 
                                                 JOIN sal_dag_descuentos_agrupador 
                                                  ON agr_codigo = dag_codagr
                                           WHERE agr_codpai = v_CODPAI
                                                   AND dag_codagr = v_codagr_igss );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN                                      
             SELECT SUM(round(NVL(DSS_VALOR, 0), 2)) 
               INTO v_PRESTAMO
               FROM sal_dss_descuentos 
              WHERE dss_codppl = v_CODPLA
                      AND DSS_CODEMP = v_PCODEMP
                      AND DSS_CODTDC IN ( SELECT dag_codtdc 
                                          FROM sal_agr_agrupadores 
                                                 JOIN sal_dag_descuentos_agrupador 
                                                  ON agr_codigo = dag_codagr
                                           WHERE agr_codpai = v_CODPAI
                                                   AND dag_codagr = v_codagr_prestamos );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN                                      
             SELECT SUM(round(NVL(DSS_VALOR, 0), 2)) 
               INTO v_SEGUROS
               FROM sal_dss_descuentos 
              WHERE dss_codppl = v_CODPLA
                      AND DSS_CODEMP = v_PCODEMP
                      AND DSS_CODTDC IN ( SELECT dag_codtdc 
                                          FROM sal_agr_agrupadores 
                                                 JOIN sal_dag_descuentos_agrupador 
                                                  ON agr_codigo = dag_codagr
                                           WHERE agr_codpai = v_CODPAI
                                                   AND dag_codagr = v_codagr_seguros );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN                                      
             SELECT SUM(round(NVL(DSS_VALOR, 0), 2)) 
               INTO v_PRENTA
               FROM sal_dss_descuentos 
              WHERE dss_codppl = v_CODPLA
                      AND DSS_CODEMP = v_PCODEMP
                      AND DSS_CODTDC IN ( SELECT dag_codtdc 
                                          FROM sal_agr_agrupadores 
                                                 JOIN sal_dag_descuentos_agrupador 
                                                  ON agr_codigo = dag_codagr
                                           WHERE agr_codpai = v_CODPAI
                                                   AND dag_codagr = v_codagr_isr );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN                                      
             SELECT SUM(round(NVL(DSS_VALOR, 0), 2)) 
               INTO v_POTROSDESCUENTOS
               FROM sal_dss_descuentos 
              WHERE dss_codppl = v_CODPLA
                      AND DSS_CODEMP = v_PCODEMP
                      AND DSS_CODTDC NOT IN ( SELECT dag_codtdc 
                                              FROM sal_agr_agrupadores 
                                                     JOIN sal_dag_descuentos_agrupador 
                                                      ON agr_codigo = dag_codagr
                                               WHERE agr_codpai = v_CODPAI
                                                       AND dag_codagr IN ( v_codagr_isr,v_codagr_igss )
                                            );
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         
         BEGIN        
             SELECT SUM(round(NVL(DSS_VALOR, 0), 2)) 
               INTO v_PTOTALDEDUCCIONES
               FROM sal_DSS_DESCUENTOS 
              WHERE DSS_CODPPL = v_CODPLA AND DSS_CODEMP = v_PCODEMP;
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
                  
         v_PSALARIONETO := NVL(v_PDEVENGADO, 0) - NVL(v_PTOTALDEDUCCIONES, 0) ;
         
         IF v_PDIAS < 0 THEN
            v_PDIAS := 0 ;
         END IF;
         INSERT INTO tt_PLANILLA_MENSUAL
           ( EMPRESA, PLANILLA, CODPLA, PERIODO_INI, PERIODO_FIN, CODEMP, CODIGOANTERIOR, AREAFUN, UNIDAD, CENTRO, PORCENTAJE, NOMBRE, SALARIO, DIAS, ORDINARIO, COMPLEMENTO, EXTRAS, BONI372001, OTRASBONI, ANTICIPOQUINCENAL, VARIOS, DEVENGADO, IGSS, PRESTAMO, RENTA, SEGUROS, OTROSDESCUENTOS, TOTALDEDUCCIONES, SALARIONETO, CONTADOR, CODIGO_PLANILLA )
           VALUES ( v_PEMPRESA, v_PPLANILLA, v_CODPLA, v_PPERIODO_INI_REAL, v_PPERIODO_FIN, v_PCODEMP, v_PCODIGOANTERIOR, v_PAREAFUN, v_PUNIDAD, v_PCENTRO, v_PPORCENTAJE, v_PNOMBRE, NVL(v_PSALARIO, 0), NVL(v_PDIAS, 0), NVL(v_PORDINARIO, 0), NVL(v_PCOMPORD, 0), NVL(v_PEXTRAS, 0), NVL(v_PBONI372001, 0), NVL(v_POTRASBONIFICACIONES, 0), NVL(v_PANTICIPOQUINCENAL, 0), NVL(v_PVARIOS, 0), NVL(v_PDEVENGADO, 0), NVL(v_PIGSS, 0), NVL(v_PRESTAMO, 0), NVL(v_PRENTA, 0), NVL(v_SEGUROS, 0), NVL(v_POTROSDESCUENTOS, 0), NVL(v_PTOTALDEDUCCIONES, 0), NVL(v_PSALARIONETO, 0), NVL(v_CONTADOR, 0), v_CODPLAVISUAL );
         v_CENTRO_ANT := v_PUNIDAD ;
         FETCH EMPLEADOS INTO v_PCODEMP,v_PCODIGOANTERIOR,v_PNOMBRE,v_PEMPRESA,v_PAREAFUN,v_PUNIDAD,v_PSALARIO,v_PCENTRO,v_PPORCENTAJE;
      END;
   END LOOP;
   CLOSE EMPLEADOS;
   OPEN cv_1 FOR
      SELECT * 
        FROM tt_PLANILLA_MENSUAL ;
        
   RETURN;

END planilla_mensual;