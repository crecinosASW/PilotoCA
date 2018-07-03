/************************************************************************************************************************************************************
                                                        Configuración reporte: PlanillaAguinaldo    
************************************************************************************************************************************************************/
--ARCHIVO
DECLARE
   v_upf_codigo VARCHAR2(36);

BEGIN
    begin
    SELECT upf_codigo 

      INTO v_upf_codigo
      FROM cfg_upf_upload_files 
     WHERE upf_nombre_archivo = 'GT_RPE_PLANILLA_AGUINALDO.rpt';
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    NULL; 
    END;

   --ELIMINACION DE DATOS
   DELETE rep_dpr_det_parametros_reporte

    WHERE dpr_codrep = 'PlanillaAguinaldo';
   DELETE rep_rpr_reportes_roles

    WHERE rpr_codrep = 'PlanillaAguinaldo';
   DELETE rep_ddr_det_datasources_report

    WHERE ddr_codrep = 'PlanillaAguinaldo';
   DELETE rep_rpm_reportes_modulos

    WHERE rpm_codrep = 'PlanillaAguinaldo';
   DELETE rep_rep_reportes

    WHERE rep_codigo = 'PlanillaAguinaldo';
   --INSERCION DE DATOS
   --REPORTE
   INSERT INTO rep_rep_reportes
     ( rep_codigo, rep_nombre_loc_key, rep_descripcion_loc_key, rep_reporte, rep_codupf, rep_tipo, rep_orden, rep_destino, rep_codpai, rep_tipo_origen_datos, rep_usuario_grabacion, rep_fecha_grabacion, rep_usuario_modificacion, rep_fecha_modificacion )
     VALUES ( 'PlanillaAguinaldo', 'GT - Planilla de Aguinaldo', 'GT - Planilla de Aguinaldo', NULL, NVL(v_upf_codigo, NULL), 1, 0, 'Viewer', 'gt', 1, 'ojuarez', SYSDATE, 'ojuarez', SYSDATE );
   --MODULOS
   INSERT INTO rep_rpm_reportes_modulos
     ( rpm_codrep, rpm_codmod )
     VALUES ( 'PlanillaAguinaldo', 'Salarios' );
   --DATASOURCES
   INSERT INTO rep_ddr_det_datasources_report
     ( ddr_nombre, ddr_codrep, ddr_origen_datos, ddr_orden, ddr_usuario_grabacion, ddr_fecha_grabacion, ddr_usuario_modificacion, ddr_fecha_modificacion )
     VALUES ( 'PlanillaAguinaldo', 'PlanillaAguinaldo', 'gt.rep_planilla_aguinaldo', 0, 'ojuarez', SYSDATE, 'ojuarez', SYSDATE );
   --ROLES
   INSERT INTO rep_rpr_reportes_roles
     ( rpr_codrep, rpr_codrol )
     VALUES ( 'PlanillaAguinaldo', 'rol1' );
   --PARAMETROS
   INSERT INTO rep_dpr_det_parametros_reporte
     ( dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion )
     VALUES ( 'PlanillaAguinaldo', '@pcodcia', NULL, 'small', NULL, 'Empresa', 0, 0, '$$CODCIA$$', 'ojuarez', SYSDATE, 'ojuarez', SYSDATE );
   INSERT INTO rep_dpr_det_parametros_reporte
     ( dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion )
     VALUES ( 'PlanillaAguinaldo', '@pcodtpl_visual', NULL, 'string', 'TiposPlanillasPorCompania', 'Tipo Planilla', 1, 5, NULL, 'ojuarez', SYSDATE, 'ojuarez', SYSDATE );
   INSERT INTO rep_dpr_det_parametros_reporte
     ( dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion )
     VALUES ( 'PlanillaAguinaldo', '@pcodpla', NULL, 'string', NULL, 'Planilla', 1, 10, NULL, 'ojuarez', SYSDATE, 'ojuarez', SYSDATE );
   INSERT INTO rep_dpr_det_parametros_reporte
     ( dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion )
     VALUES ( 'PlanillaAguinaldo', '@codarf', NULL, 'small', 'AreasFuncionalesDeGrupoCorporativo', 'Área Funcional', 1, 15, NULL, 'ojuarez', SYSDATE, 'ojuarez', SYSDATE );
   INSERT INTO rep_dpr_det_parametros_reporte
     ( dpr_codrep, dpr_parametro, dpr_descripcion_loc_key, dpr_codfld, dpr_codvli, dpr_prompt_loc_key, dpr_visible, dpr_orden, dpr_valor, dpr_usuario_grabacion, dpr_fecha_grabacion, dpr_usuario_modificacion, dpr_fecha_modificacion )
     VALUES ( 'PlanillaAguinaldo', '@coduni', NULL, 'int', 'UnidadesDelGrupoCorporativo', 'Unidad', 1, 20, NULL, 'ojuarez', SYSDATE, 'ojuarez', SYSDATE );
END;

