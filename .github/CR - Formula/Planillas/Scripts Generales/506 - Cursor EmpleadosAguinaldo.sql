/* Script generated by Evolution - FormulaEditor. 19/02/2015 11:24 a.m. */

begin transaction

DECLARE @codpai VARCHAR(2),
	@codfcu_principal INT

SET @codpai = 'cr'

SELECT @codfcu_principal = fcu_codigo
FROM sal.fcu_formulacion_cursores
WHERE fcu_codpai = @codpai
	AND fcu_nombre = 'EmpleadosAguinaldo'

UPDATE sal.ftp_formulacion_tipos_planilla
SET ftp_codfcu_loop = NULL
WHERE ftp_codfcu_loop = @codfcu_principal

delete from sal.fcu_formulacion_cursores where fcu_codpai = 'cr' and fcu_nombre = 'EmpleadosAguinaldo';

insert into sal.fcu_formulacion_cursores (fcu_codpai,fcu_proceso,fcu_nombre,fcu_descripcion,fcu_select_edit,fcu_select_run,fcu_field_codemp,fcu_modo_asociacion_tpl,fcu_loop_calculo,fcu_updatable) 
values ('cr','Planilla','EmpleadosAguinaldo','Empleados para el c�lculo del aguinaldo','SELECT emp_codigo,
     emp_fecha_ingreso
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = 0','DECLARE @codcia INT,
	@codtpl INT,
	@codtpl_normal INT
	
SET @codcia = $$CODCIA$$
SET @codtpl = $$CODTPL$$

SELECT 	@codtpl_normal = tpl_codtpl_normal
FROM sal.tpl_tipo_planilla
WHERE tpl_codigo = @codtpl

SELECT emp_codigo,
     emp_fecha_ingreso
FROM exp.emp_empleos 
	JOIN eor.plz_plazas ON plz_codigo = emp_codplz
WHERE plz_codcia = @codcia
	AND emp_estado = ''A''
	AND emp_codtpl = @codtpl_normal
	AND sal.empleado_en_gen_planilla(''$$SESSIONID$$'', emp_codigo) = 1','emp_codigo','TodosExcluyendo',1,0);

SELECT @codfcu_principal = fcu_codigo
FROM sal.fcu_formulacion_cursores
WHERE fcu_codpai = @codpai
	AND fcu_nombre = 'EmpleadosAguinaldo'

UPDATE sal.ftp_formulacion_tipos_planilla
SET ftp_codfcu_loop = @codfcu_principal
WHERE EXISTS (SELECT NULL 
			  FROM sal.tpl_tipo_planilla 
				  JOIN eor.cia_companias ON tpl_codcia = cia_codigo
			  WHERE tpl_codigo = ftp_codtpl
				  AND cia_codpai = @codpai
				  AND tpl_codigo_visual IN ('5', '6', '7', '8'))

commit transaction;