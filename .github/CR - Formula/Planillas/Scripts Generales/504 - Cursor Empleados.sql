/* Script generated by Evolution - FormulaEditor. 19/02/2015 11:24 a.m. */

begin transaction

DECLARE @codpai VARCHAR(2),
	@codfcu_principal INT

SET @codpai = 'cr'

SELECT @codfcu_principal = fcu_codigo
FROM sal.fcu_formulacion_cursores
WHERE fcu_codpai = @codpai
	AND fcu_nombre = 'Empleados'

UPDATE sal.ftp_formulacion_tipos_planilla
SET ftp_codfcu_loop = NULL
WHERE ftp_codfcu_loop = @codfcu_principal

delete from sal.fcu_formulacion_cursores where fcu_codpai = 'cr' and fcu_nombre = 'Empleados';

insert into sal.fcu_formulacion_cursores (fcu_codpai,fcu_proceso,fcu_nombre,fcu_descripcion,fcu_select_edit,fcu_select_run,fcu_field_codemp,fcu_field_codcia,fcu_field_codtpl,fcu_modo_asociacion_tpl,fcu_loop_calculo,fcu_updatable) values ('cr','Planilla','Empleados','Empleados','SELECT emp_codigo,
     emp_fecha_ingreso,
     emp_fecha_retiro,
     emp_codtpl,
     emp_codplz,
     plz_es_temporal,
     plz_fecha_fin,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaSeguroSocial''), CAST(1 AS bit)) aplica_seguro_social,
	 ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaBancoPopular''), CAST(1 AS bit)) aplica_banco_popular,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaRenta''), CAST(1 AS bit)) aplica_renta,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaISRConyugue''), CAST(1 AS bit)) aplica_isr_conyugue,
     ISNULL(gen.get_pb_field_data_float(emp_property_bag_data, ''NumeroHijos''), 0.00) emp_numero_hijos,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''EsJubilado''), CAST(0 AS bit)) emp_es_jubilado
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = 0','DECLARE @codcia INT,
	@codtpl INT,
	@codppl INT,
	@ppl_fecha_ini DATETIME,
	@ppl_fecha_fin DATETIME,
	@session_id UNIQUEIDENTIFIER

SET @codcia = $$CODCIA$$
SET @codtpl = $$CODTPL$$
SET @codppl = $$CODPPL$$
SET @session_id = ''$$SESSIONID$$''

SELECT @ppl_fecha_ini = ppl_fecha_ini,
	@ppl_fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codigo = @codppl

SELECT emp_codigo,
     emp_fecha_ingreso,
     emp_fecha_retiro,
     emp_codtpl,
     emp_codplz,
     plz_es_temporal,
     plz_fecha_fin,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaSeguroSocial''), CAST(1 AS bit)) aplica_seguro_social,
	 ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaBancoPopular''), CAST(1 AS bit)) aplica_banco_popular,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''descuentaRenta''), CAST(1 AS bit)) aplica_renta,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''AplicaISRConyugue''), CAST(1 AS bit)) aplica_isr_conyugue,
     ISNULL(gen.get_pb_field_data_float(emp_property_bag_data, ''NumeroHijos''), 0.00) emp_numero_hijos,
     ISNULL(gen.get_pb_field_data_bit(emp_property_bag_data, ''EsJubilado''), CAST(0 AS bit)) emp_es_jubilado
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = @codcia
	AND (emp_estado = ''A''
		OR (emp_estado = ''R'' AND emp_fecha_retiro BETWEEN @ppl_fecha_ini AND @ppl_fecha_fin))
	AND emp_codtpl = @codtpl
	AND sal.empleado_en_gen_planilla(@session_id, emp_codigo) = 1','emp_codigo','','','TodosExcluyendo',1,0);

SELECT @codfcu_principal = fcu_codigo
FROM sal.fcu_formulacion_cursores
WHERE fcu_codpai = @codpai
	AND fcu_nombre = 'Empleados'

UPDATE sal.ftp_formulacion_tipos_planilla
SET ftp_codfcu_loop = @codfcu_principal
WHERE EXISTS (SELECT NULL 
			  FROM sal.tpl_tipo_planilla 
				  JOIN eor.cia_companias ON tpl_codcia = cia_codigo
			  WHERE tpl_codigo = ftp_codtpl
				  AND cia_codpai = @codpai
				  AND tpl_codigo_visual IN ('1', '2', '3', '4'))

commit transaction;