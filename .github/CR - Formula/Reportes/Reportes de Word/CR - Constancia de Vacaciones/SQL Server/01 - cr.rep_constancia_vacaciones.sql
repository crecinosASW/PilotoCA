IF EXISTS (SELECT NULL 
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_constancia_vacaciones'))
BEGIN
	DROP PROCEDURE cr.rep_constancia_vacaciones
END

GO	

--EXEC cr.rep_constancia_vacaciones 2, '57', '60', '18/06/2014', 'jcsoria'
CREATE PROCEDURE cr.rep_constancia_vacaciones (
	@codcia INT = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@codemp_alternativo_firma VARCHAR(36) = NULL,
	@fecha_ini_txt VARCHAR(10) = NULL,
	@usuario VARCHAR(50) = NULL
)

AS

SET NOCOUNT ON
SET DATEFORMAT DMY

DECLARE @codemp INT,
	@codemp_firma INT,
	@fecha_ini DATETIME,
	@exp_nombres_apellidos_firma VARCHAR(80)

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)
SET @codemp_firma = gen.obtiene_codigo_empleo(@codemp_alternativo_firma)
SET @fecha_ini = CONVERT(DATETIME, @fecha_ini_txt)

SELECT @exp_nombres_apellidos_firma = exp_nombres_apellidos
FROM exp.exp_expedientes
	JOIN exp.emp_empleos ON exp_codigo = emp_codexp
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
WHERE emp_codigo = @codemp_firma
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1

SELECT UPPER(cia_descripcion) cia_descripcion,
	UPPER(uni_descripcion) uni_descripcion,
	UPPER(plz_nombre) plz_nombre,
	UPPER(exp_nombres_apellidos) exp_nombres_apellidos,
	UPPER(@exp_nombres_apellidos_firma) exp_nombres_apellidos_firma,
	vac_periodo,
	CONVERT(DECIMAL(14, 2), ROUND(vac_saldo + (ISNULL(vac_horas_saldo, 0.00) / 8.00), 2)) vac_saldo,
	CONVERT(VARCHAR, MIN(dva_desde), 103) dva_desde,
	CONVERT(VARCHAR, MAX(dva_hasta), 103) dva_hasta,
	CONVERT(DECIMAL(14, 2), ROUND(SUM(dva_dias), 2)) dva_dias,
	gen.convierte_fecha_a_letras(GETDATE(), 0, 0) fecha_actual_letras
FROM acc.vac_vacaciones
	JOIN acc.dva_dias_vacacion ON vac_codigo = dva_codvac
	JOIN acc.sdv_solicitud_dias_vacacion ON dva_codsdv = sdv_codigo
	JOIN exp.emp_empleos ON vac_codemp = emp_codigo 
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	JOIN eor.cia_companias ON plz_codcia = cia_codigo
	JOIN eor.uni_unidades ON plz_coduni = uni_codigo
WHERE plz_codcia = @codcia
	AND emp_codigo = ISNULL(@codemp, emp_codigo)
	AND sdv_desde = ISNULL(@fecha_ini, sdv_desde)
	AND sco.permiso_empleo(emp_codigo, @usuario) = 1
GROUP BY cia_descripcion, uni_descripcion, plz_nombre, exp_nombres_apellidos, vac_periodo, sdv_codigo, vac_saldo, vac_horas_saldo