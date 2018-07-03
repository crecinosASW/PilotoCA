

                         
CREATE OR REPLACE PROCEDURE rep_planilla_aguinaldo
(
  v_pcodcia IN NUMBER DEFAULT NULL ,
  iv_pcodtpl_visual IN VARCHAR2 DEFAULT NULL ,
  iv_pcodpla IN VARCHAR2 DEFAULT NULL ,
  v_codarf IN NUMBER DEFAULT NULL ,
  v_coduni IN NUMBER DEFAULT NULL ,
  cv_1  OUT SYS_REFCURSOR
)
AS
   v_pcodtpl_visual VARCHAR2(7) := iv_pcodtpl_visual;
   v_pcodpla VARCHAR2(14) := iv_pcodpla;
   v_pcodtpl NUMBER(10,0);
   v_pcodemp NUMBER(10,0);
   v_pcodigoanterior VARCHAR2(20);
   v_pplanilla VARCHAR2(100);
   v_pperiodo_ini DATE;
   v_pperiodo_fin DATE;
   v_pperiodo_ini_real DATE;
   v_pfrecuencia NUMBER(10,0);
   v_pnombre VARCHAR2(100);
   v_pempresa VARCHAR2(100);
   v_pareafun VARCHAR2(100);
   v_punidad VARCHAR2(100);
   v_pcentro VARCHAR2(100);
   v_psalario NUMBER(19,2);
   v_pfecha_ingreso DATE;
   v_pdias NUMBER(10,0);
   v_paguinaldo NUMBER(19,2);
   v_contador NUMBER(10,0);
   v_centro_ant VARCHAR2(100);
   v_agrupador_aguinaldo NUMBER(10,0);
   CURSOR empleados
     IS SELECT DISTINCT emp_codigo ,
   NULL emp_codigo_anterior  ,
   exp_nombres_apellidos ,
   arf_nombre ,
   uni_descripcion ,
   NVL(ese_salario.ese_valor, 0) ,
   cco_descripcion ,
   emp_fecha_ingreso 
     FROM exp_emp_empleos 
     JOIN exp_exp_expedientes 
      ON emp_codexp = exp_codigo
     JOIN eor_plz_plazas 
      ON emp_codplz = plz_codigo
     LEFT JOIN eor_uni_unidades 
      ON plz_coduni = uni_codigo
     AND plz_codcia = uni_codcia
     LEFT JOIN eor_arf_areas_funcionales 
      ON uni_codarf = arf_codigo
     LEFT JOIN eor_cpp_centros_costo_plaza 
      ON plz_codigo = cpp_codplz
     LEFT JOIN eor_cco_centros_de_costo 
      ON cpp_codcco = cco_codigo
     JOIN sal_inn_ingresos 
      ON emp_codigo = inn_codemp
     JOIN sal_ppl_periodos_planilla 
      ON inn_codppl = ppl_codigo
     LEFT JOIN ( exp_ese_estructura_sal_empleos ese_salario
                 JOIN exp_rsa_rubros_salariales rsa_salario
                  ON ese_salario.ese_codrsa = rsa_salario.rsa_codigo
                 AND rsa_salario.rsa_es_salario_base = 1
                  ) 
      ON ese_salario.ese_codemp = emp_codigo
    WHERE plz_codcia = v_pcodcia
     AND ppl_codtpl = v_pcodtpl
     AND ppl_codigo_planilla = v_pcodpla
     AND inn_valor > 0
     AND arf_codigo = NVL(v_codarf, arf_codigo)
     AND plz_coduni = NVL(v_coduni, plz_coduni)
     ORDER BY arf_nombre,
   uni_descripcion,
   cco_descripcion,
   emp_codigo;

BEGIN
   v_pcodtpl_visual := REPLACE(v_pcodtpl_visual, '''', '') ;
   v_pcodpla := REPLACE(v_pcodpla, '''', '') ;
    begin
    SELECT tpl_codigo 

     INTO v_pcodtpl
     FROM sal_tpl_tipo_planilla 
    WHERE tpl_codcia = v_pcodcia
            AND tpl_codigo_visual = v_pcodtpl_visual;
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    NULL; 
    END;

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
    begin
    SELECT tpl_descripcion 

     INTO v_pplanilla
     FROM sal_tpl_tipo_planilla 
    WHERE tpl_codcia = v_pcodcia
            AND tpl_codigo = v_pcodtpl;
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    NULL; 
    END;
    begin
    SELECT ppl_fecha_ini ,
          ppl_fecha_fin ,
          ppl_frecuencia 

     INTO v_pperiodo_ini,
          v_pperiodo_fin,
          v_pfrecuencia
     FROM sal_ppl_periodos_planilla 
            JOIN sal_tpl_tipo_planilla 
             ON ppl_codtpl = tpl_codigo
    WHERE tpl_codcia = v_pcodcia
            AND ppl_codtpl = v_pcodtpl
            AND ppl_codigo_planilla = v_pcodpla;
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    NULL; 
    END;
   
   v_contador := 1 ;
   OPEN empleados;
   FETCH empleados INTO v_pcodemp,v_pcodigoanterior,v_pnombre,
   v_pareafun,v_punidad,v_psalario,v_pcentro,v_pfecha_ingreso;
   WHILE empleados%FOUND 
   LOOP 
      
      BEGIN
         IF v_punidad = v_centro_ant THEN
            v_contador := v_contador + 1 ;
         ELSE
            v_contador := 1 ;
         END IF;
         begin
         SELECT UPPER(cia_descripcion) 

           INTO v_pempresa
           FROM eor_cia_companias 
          WHERE cia_codigo = v_pcodcia;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        NULL; 
        END;
         begin 
         SELECT SUM(round(NVL(inn_valor, 0), 2)) ,
                SUM(NVL(inn_tiempo, 0)) 

           INTO v_paguinaldo,
                v_pdias
           FROM sal_inn_ingresos 
                  JOIN sal_ppl_periodos_planilla 
                   ON inn_codppl = ppl_codigo
                  JOIN sal_tpl_tipo_planilla 
                   ON ppl_codtpl = tpl_codigo
          WHERE tpl_codcia = v_pcodcia
                  AND ppl_codtpl = v_pcodtpl
                  AND ppl_codigo_planilla = v_pcodpla
                  AND inn_codemp = v_pcodemp
                  AND inn_codtig IN ( SELECT iag_codtig 
                                      FROM sal_agr_agrupadores 
                                             JOIN sal_iag_ingresos_agrupador 
                                              ON agr_codigo = iag_codagr
                                       WHERE agr_codpai = 'GT'
                                               AND agr_codigo = v_agrupador_aguinaldo );
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        NULL; 
        END;
                                               
         IF v_pdias < 0 THEN
            v_pdias := 0 ;
         END IF;

         INSERT INTO tt_planilla_aguinaldo
           ( empresa, planilla, codpla, periodo_ini, periodo_fin, codemp, codigoanterior, areafun, unidad, centro, nombre, salario, fecha_ingreso, dias, aguinaldo, contador )
           VALUES ( v_pempresa, v_pplanilla, v_pcodpla, TO_DATE(v_pperiodo_ini,'dd/mm/rrrr'), TO_DATE(v_pperiodo_fin,'dd/mm/rrrr'), v_pcodemp, v_pcodigoanterior, v_pareafun, v_punidad, v_pcentro, v_pnombre, v_psalario, TO_DATE(v_pfecha_ingreso,'dd/mm/rrrr'), v_pdias, NVL(v_paguinaldo, 0), NVL(v_contador, 0) );
         v_centro_ant := v_punidad ;
         FETCH empleados INTO v_pcodemp,v_pcodigoanterior,v_pnombre,
         --@pempresa, 
         v_pareafun,v_punidad,v_psalario,v_pcentro,v_pfecha_ingreso;
      END;
   END LOOP;
   CLOSE empleados;
   OPEN cv_1 FOR
      SELECT * 
        FROM tt_planilla_aguinaldo ;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_planilla ';
   RETURN;
END;

