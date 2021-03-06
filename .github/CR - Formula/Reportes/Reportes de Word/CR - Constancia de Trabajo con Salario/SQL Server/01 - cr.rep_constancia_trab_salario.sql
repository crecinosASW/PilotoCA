IF EXISTS (SELECT NULL 
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_constancia_trab_salario'))
BEGIN
	DROP PROCEDURE cr.rep_constancia_trab_salario
END

GO	

--EXEC cr.rep_constancia_trab_salario 2, '60', '56', 'Guatemala', '22/09/2014', 'jcsoria'
CREATE PROCEDURE cr.rep_constancia_trab_salario (
	@codcia INT = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@codemp_alternativo_firma VARCHAR(36) = NULL,
	@ciudad VARCHAR(30) = NULL,
	@fecha_txt VARCHAR(10) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY

DECLARE @codemp INT,
	@codemp_firma INT,
	@fecha DATETIME,
	@codrsa_salario INT,
	@exp_nombres_apellidos_firma VARCHAR(80),
	@plz_nombre_firma VARCHAR(80)	

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)
SET @codemp_firma = gen.obtiene_codigo_empleo(@codemp_alternativo_firma)
SET @fecha = CONVERT(DATETIME, @fecha_txt)
SET @codrsa_salario = gen.get_valor_parametro_int('CodigoRSA_Salario', NULL, NULL, @codcia, NULL)

SELECT @exp_nombres_apellidos_firma = exp_nombres_apellidos,
	@plz_nombre_firma = plz_nombre
FROM exp.exp_expedientes
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
WHERE emp_codigo = @codemp_firma
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

SELECT ISNULL(@ciudad, pai_descripcion) cts_pais,
	gen.convierte_fecha_a_letras(@fecha, 0, 2) cts_fecha_reporte,
	cia_descripcion cts_cia,
	exp_nombres_apellidos cts_empleado,
	plz_nombre cts_plaza,
	gen.convierte_fecha_a_letras(emp_fecha_ingreso, 0, 1) cts_fecha_ingreso,
	uni_descripcion cts_unidad,
	CONVERT(VARCHAR, CONVERT(MONEY, ese_valor))  cts_salario,
	gen.convierte_numeros_a_letras(ese_valor, cia_codpai) cts_salario_letras,
	mon_simbolo cts_simbolo_moneda,
	mon_descripcion cts_moneda,
	@exp_nombres_apellidos_firma cts_empleado_firma,
	@plz_nombre_firma cts_plaza_firma
FROM exp.exp_expedientes
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp
	JOIN exp.ese_estructura_sal_empleos ON emp_codigo = ese_codemp AND ese_estado = 'V' AND ese_codrsa = @codrsa_salario
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.uni_unidades ON plz_codcia = uni_codcia AND plz_coduni = uni_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN gen.pai_paises ON cia_codpai = pai_codigo
	JOIN gen.mon_monedas ON ese_codmon = mon_codigo
WHERE plz_codcia = @codcia
	AND emp_codigo = ISNULL(@codemp, emp_codigo)
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1