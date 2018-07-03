DECLARE 
  TYPE MyRec IS RECORD (
    cia_descripcion VARCHAR2(50),
    tpl_descripcion VARCHAR2(50),
    ppl_fecha_inicio DATE,
    ppl_fecha_fin DATE,
    exp_codigo_alternativo VARCHAR2(36),
    exp_apellidos_nombres VARCHAR2(80),
    nov_fecha_inicio DATE,
    nov_fecha_fin DATE,
    nov_rubro VARCHAR2(50),
    nov_valor NUMBER,
    nov_tipo VARCHAR2(50));
--TYPE MyRec IS RECORD (v_a INT);  --define the record        
  c_cursor SYS_REFCURSOR;
  rec MyRec;        -- instantiate the record
BEGIN
  acc.rep_novedades_planilla(1, '1', NULL, 7, 2011, 'admin', c_cursor);

  LOOP
    FETCH c_cursor INTO rec;
    EXIT WHEN c_cursor%NOTFOUND;
    dbms_output.put_line('Compañía: '||rec.cia_descripcion||', Tipo Planilla: '||rec.tpl_descripcion||', Fecha Inicio Planilla: '||rec.ppl_fecha_inicio||', Fecha Fin Planilla: '||rec.ppl_fecha_fin||', Código: '||rec.exp_codigo_alternativo||', Nombres: '||rec.exp_apellidos_nombres||', Fecha Inicio: '||rec.nov_fecha_inicio||', Fecha Fin: '||rec.nov_fecha_fin||', Rubro: '||rec.nov_rubro||', Valor: '||rec.nov_valor||', Tipo: '||rec.nov_tipo);
--      dbms_output.put_line('Compañía: '||rec.cia_descripcion);
  END LOOP;
END;