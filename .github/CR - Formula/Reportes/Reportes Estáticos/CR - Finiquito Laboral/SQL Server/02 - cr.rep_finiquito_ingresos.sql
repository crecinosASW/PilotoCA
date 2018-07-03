IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_finiquito_ingresos'))
BEGIN
	DROP PROCEDURE cr.rep_finiquito_ingresos
END

GO

--EXEC cr.rep_finiquito_ingresos 5, '85', '10/08/2014', 'jcsoria'
CREATE PROCEDURE cr.rep_finiquito_ingresos ( 
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

SELECT tig_descripcion,
	dli_valor
FROM acc.lie_liquidaciones
	JOIN exp.emp_empleos ON lie_codemp = emp_codigo
	JOIN acc.dli_detliq_ingresos ON lie_codigo = dli_codlie
	JOIN sal.tig_tipos_ingreso ON dli_codtig = tig_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
WHERE plz_codcia = @codcia
	AND emp_estado = 'R'
	AND emp_codigo = ISNULL(@codemp, emp_codigo)
	AND emp_fecha_retiro = ISNULL(@fecha_retiro, emp_fecha_retiro)
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1