--EXECUTE gt.rep_planilla_aguinaldo 2, '22C', 2011, NULL, NULL
CREATE PROCEDURE gt.rep_planilla_aguinaldo
   @pcodcia SMALLINT = NULL,
   @pcodtpl_visual VARCHAR(7) = NULL,
   @pcodpla VARCHAR(14) = NULL,
   @codarf SMALLINT = NULL,
   @coduni INT = NULL,
   @usuario VARCHAR(50) = NULL
AS

--DECLARE
--@pcodcia SMALLINT,
--@pcodtpl SMALLINT,
--@pcodpla INT,
--@codarf SMALLINT,  
--@coduni INT
--
--SET @pcodcia = 1
--SET @pcodtpl = 3
--SET @pcodpla = 2010
--SET @codarf = NULL
--SET @coduni = NULL

SET NOCOUNT ON

DECLARE @pcodtpl INT

SELECT @pcodtpl = tpl_codigo
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @pcodcia
	AND tpl_codigo_visual = @pcodtpl_visual

DECLARE  empleados CURSOR FOR
SELECT DISTINCT emp_codigo, 
        NULL emp_codigo_anterior, 
        exp_nombres_apellidos, 
        arf_nombre,
        uni_descripcion, 
        ISNULL(ese_salario.ese_valor, 0), --+ ISNULL(emp_bonificacion,0),
        cco_descripcion,
        emp_fecha_ingreso
FROM exp.emp_empleos
	JOIN exp.exp_expedientes ON emp_codexp = exp_codigo
	JOIN eor.plz_plazas ON emp_codplz = plz_codigo
	LEFT JOIN eor.uni_unidades ON plz_coduni = uni_codigo AND plz_codcia = uni_codcia
	LEFT JOIN eor.arf_areas_funcionales ON uni_codarf = arf_codigo
	LEFT JOIN eor.cpp_centros_costo_plaza ON plz_codigo = cpp_codplz
	LEFT JOIN eor.cco_centros_de_costo ON cpp_codcco = cco_codigo
	JOIN sal.inn_ingresos ON emp_codigo = inn_codemp
	JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
	LEFT JOIN (exp.ese_estructura_sal_empleos ese_salario
		JOIN exp.rsa_rubros_salariales rsa_salario ON ese_salario.ese_codrsa = rsa_salario.rsa_codigo AND rsa_salario.rsa_es_salario_base = 1) ON ese_salario.ese_codemp = emp_codigo
WHERE plz_codcia = @pcodcia
	AND ppl_codtpl = @pcodtpl
	AND ppl_codigo_planilla = @pcodpla
	AND inn_valor > 0
    AND arf_codigo = ISNULL(@codarf,arf_codigo)
    AND plz_coduni = ISNULL(@coduni,plz_coduni)
    AND sco.permiso_empleo(emp_codigo, @usuario) = 1
  ORDER BY arf_nombre, uni_descripcion, cco_descripcion, emp_codigo
  

--creamos la temporal tabla a utilizar
--DROP TABLE #planilla
CREATE TABLE #planilla( 
   empresa VARCHAR(100) NULL,
   planilla VARCHAR(100) NULL,
   codpla INT NULL,
   periodo_ini DATETIME NULL,
   periodo_fin DATETIME NULL,
   codemp INT NULL,
   codigoanterior VARCHAR(20) NULL,
   areafun VARCHAR(100) NULL, 
   unidad VARCHAR(100) NULL, 
   centro VARCHAR(100) NULL,
   nombre VARCHAR(150) NULL,
   salario MONEY NULL,
   fecha_ingreso DATETIME NULL,
   dias INT NULL,
   aguinaldo MONEY NULL,
   contador INT NULL)

DECLARE 
   @pcodemp INT,
   @pcodigoanterior VARCHAR(20),
   @pplanilla VARCHAR(100),
   @pperiodo_ini DATETIME,
   @pperiodo_fin DATETIME,
   @pperiodo_ini_real DATETIME,
   @pfrecuencia INT,
   @pnombre VARCHAR(100),
   @pempresa VARCHAR(100),
   @pareafun VARCHAR(100),
   @punidad VARCHAR(100),
   @pcentro VARCHAR(100),
   @psalario MONEY,
   @pfecha_ingreso DATETIME,
   @pdias INT,
   @paguinaldo MONEY,
   @contador INT,
   @centro_ant VARCHAR(100),
   @agrupador_aguinaldo INT

SELECT @agrupador_aguinaldo = agr_codigo
FROM sal.agr_agrupadores
WHERE agr_abreviatura = 'GTPlanillaAguinaldo'
	AND agr_codpai = 'gt'

SELECT @pplanilla = tpl_descripcion 
FROM sal.tpl_tipo_planilla
WHERE tpl_codcia = @pcodcia
	AND tpl_codigo = @pcodtpl

SELECT @pperiodo_ini = ppl_fecha_ini, @pperiodo_fin = ppl_fecha_fin, @pfrecuencia = ppl_frecuencia 
FROM sal.ppl_periodos_planilla
	JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
WHERE tpl_codcia = @pcodcia
	AND ppl_codtpl = @pcodtpl
	AND ppl_codigo_planilla = @pcodpla

SELECT @contador = 1

OPEN empleados
FETCH NEXT FROM empleados INTO @pcodemp, 
                                @pcodigoanterior, 
                                @pnombre, 
                                --@pempresa, 
                                @pareafun, 
                                @punidad, 
                                @psalario, 
                                @pcentro,
                                @pfecha_ingreso
WHILE @@FETCH_status = 0 BEGIN
   IF @punidad = @centro_ant 
      SELECT @contador = @contador + 1
   ELSE
      SELECT @contador = 1

	SELECT @pempresa = upper(cia_descripcion)
		FROM eor.cia_companias
	WHERE cia_codigo = @pcodcia


   SELECT @paguinaldo = SUM(ROUND(ISNULL(inn_valor, 0), 2)),
          @pdias = SUM(ISNULL(inn_tiempo, 0))
	FROM sal.inn_ingresos
		JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
		JOIN sal.tpl_tipo_planilla ON ppl_codtpl = tpl_codigo
    WHERE tpl_codcia = @pcodcia AND
          ppl_codtpl = @pcodtpl AND
          ppl_codigo_planilla = @pcodpla AND
          inn_codemp = @pcodemp AND
		  inn_codtig IN (SELECT iag_codtig 
							FROM sal.agr_agrupadores
								JOIN sal.iag_ingresos_agrupador ON agr_codigo = iag_codagr
							WHERE agr_codpai = 'GT'
								AND agr_codigo = @agrupador_aguinaldo)
   
   IF @pdias < 0
      SET @pdias = 0
   
   INSERT INTO #planilla 
     (empresa,
      planilla,
      codpla,
      periodo_ini,
      periodo_fin,
      codemp,
      codigoanterior,
      areafun, 
      unidad,
      centro,
      nombre,
      salario,
      fecha_ingreso,
      dias,
      aguinaldo,
      contador)
   VALUES 
     (@pempresa, 
      @pplanilla, 
      @pcodpla, 
      @pperiodo_ini,
      @pperiodo_fin,
      @pcodemp, 
      @pcodigoanterior,
      @pareafun, 
      @punidad,
      @pcentro,
      @pnombre,
      @psalario,
      @pfecha_ingreso,
      @pdias,
      ISNULL(@paguinaldo, 0), 
      ISNULL(@contador, 0))
   
   SELECT @centro_ant = @punidad
   
   FETCH NEXT FROM  empleados INTO @pcodemp, 
                                   @pcodigoanterior, 
                                   @pnombre, 
                                   --@pempresa, 
                                   @pareafun, 
                                   @punidad, 
                                   @psalario, 
                                   @pcentro,
                                   @pfecha_ingreso
END

CLOSE empleados
DEALLOCATE empleados

SELECT * FROM #planilla
DROP TABLE #planilla
RETURN
