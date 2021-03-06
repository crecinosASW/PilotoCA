IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_finiquito_liquidacion'))
BEGIN
	DROP PROCEDURE cr.rep_finiquito_liquidacion
END

GO

--EXEC cr.rep_finiquito_liquidacion 5, '85', '10/08/2014', 'jcsoria'
CREATE PROCEDURE cr.rep_finiquito_liquidacion ( 
	@codcia INT = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,          
	@fecha_retiro_txt VARCHAR(10) = NULL,
	@usuario VARCHAR(50) = Null       
)         
 
AS          
          
SET NOCOUNT ON   
SET DATEFORMAT DMY

DECLARE @codemp INT,
	@fecha_retiro DATETIME

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)

SET @fecha_retiro = CONVERT(DATETIME, @fecha_retiro_txt)

SELECT cia_descripcion,
	mun_descripcion,
	dep_descripcion,
	exp_codigo_alternativo,
	exp_nombres_apellidos,
	ide_cip,
	gen.convierte_fecha_a_letras(CONVERT(DATETIME, emp_fecha_ingreso, 103), 0, 0) emp_fecha_ingreso_letras,
	gen.convierte_fecha_a_letras(CONVERT(DATETIME, emp_fecha_retiro, 103), 0, 0) emp_fecha_retiro_letras,
	gen.convierte_numeros_a_letras(
		ISNULL((SELECT SUM(dli_valor)
				FROM acc.dli_detliq_ingresos
					JOIN acc.lie_liquidaciones ON dli_codlie = lie_codigo
				WHERE lie_codemp = emp_codigo
					AND lie_fecha_retiro = emp_fecha_retiro), 0.00) - 
		ISNULL((SELECT SUM(dld_valor)
				FROM acc.dld_detliq_descuentos
					JOIN acc.lie_liquidaciones ON dld_codlie = lie_codigo
				WHERE lie_codemp = emp_codigo
					AND lie_fecha_retiro = emp_fecha_retiro), 0.00), cia_codpai) total_letras
FROM exp.emp_empleos
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.cdt_centros_de_trabajo ON plz_codcdt = cdt_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN gen.mun_municipios ON cdt_codmun = mun_codigo
	JOIN gen.dep_departamentos ON mun_coddep = dep_codigo
	LEFT JOIN cr.ide_ident_emp_v ON exp_codigo = ide_codexp
WHERE plz_codcia = @codcia
	AND emp_estado = 'R'
	AND emp_codigo = ISNULL(@codemp, emp_codigo)
	AND emp_fecha_retiro = ISNULL(@fecha_retiro, emp_fecha_retiro)
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1