IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.get_promedio_ingresos'))
BEGIN
	DROP PROCEDURE cr.get_promedio_ingresos
END

GO

/*
DECLARE
@fecha_desde datetime,
@promedio real
set @fecha_desde = convert(datetime,'15/08/2014',103)
set @promedio = 0
  exec cr.get_promedio_ingresos  89,2184,@fecha_desde,6,0,@promedio output
  print @promedio
*/
CREATE PROCEDURE cr.get_promedio_ingresos 
   (@p_codemp            int,
    @p_agrupador         int = 0,     -- Agrupador para los ingresos variables
    @p_fecha             datetime,    -- Fecha a partir de la cual se desea el promedio
    @p_meses_promedio    int,         -- Meses atras del promedio
    @p_tipo_salario      int = 2,     -- 0 = No incluirlo, 1 = Actual, 2 = Devengado, 3 = Percibido
    @p_promedio          real output  -- Resultado
    )
-------------------------------------------------------------------------------
--  EVOLUTION                                                                --
--  Obtiene el promedio de los X meses completos atras de la fecha recibida  --
--  Si la fecha recibida no es fin de mes la ajusta al fin de mes anterior   --
--  Se ajusta a la fecha de ingreso si esta fuera mayor a la fecha de inicio --
--  del promedio, y realiza el promedio entre estos meses                    --
-------------------------------------------------------------------------------
AS
DECLARE
@CODCIA           INT,
@FECHA_DESDE      DATETIME,
@FECHA_HASTA      DATETIME,
@FECHA_INGRESO    DATETIME,
@Total_Ingresos   REAL = 0,
@SALARIO          REAL = 0,
@BONO_DECRETO     REAL = 0,
@BONO_PACTADO     REAL = 0,
@codrsa_salario int = 0,
@codtig_salario int = 0,
@dias_trabajados int = 0,
@dias_promedio int = 0,
@salario_actual real = 0

BEGIN
-----------------------------------------
-- Obtiene Compania y Fecha de Ingreso --
-----------------------------------------  
SELECT @CODCIA = PLZ_CODCIA,
       @FECHA_INGRESO = EMP_FECHA_INGRESO
  FROM exp.emp_empleos
  JOIN eor.plz_plazas on plz_codigo = emp_codplz
 WHERE emp_codigo = @p_codemp      
--------------------------------------
--      Obtiene tipos de ingreso    --
--------------------------------------  
SET @codrsa_salario = isnull(gen.get_valor_parametro_int ('CodigoRSA_Salario',null,null,@codcia,null),0)

-----------------------------------------
--     Obtiene Salarios Actuales       --
-----------------------------------------    
SELECT  @SALARIO =  ( SELECT ISNULL(sum(ese_valor),0)
	        FROM exp.ese_estructura_sal_empleos
	       WHERE ese_codemp = emp_codigo
	         and ese_estado = 'V'
	         and ese_codrsa = @codrsa_salario )
   FROM exp.emp_empleos
  WHERE emp_codigo = @p_codemp 

SET @salario_actual = @Salario
----------------------------------------------
--          Ajusta a meses completos        --
--           tanto inicio como fin          --
----------------------------------------------
Set @FECHA_HASTA = @p_fecha
IF  @FECHA_HASTA <> gen.fn_last_day( @FECHA_HASTA )
   SET  @FECHA_HASTA = gen.fn_last_day(DATEADD(mm,-1,  @FECHA_HASTA))

Set @FECHA_DESDE = DATEADD(mm,((@p_meses_promedio - 1) * -1), @FECHA_HASTA)

IF @FECHA_DESDE < @FECHA_INGRESO
   SET @FECHA_DESDE = @FECHA_INGRESO

IF DATEPART(dd,@FECHA_DESDE) <> 1
   SET @FECHA_DESDE = gen.fn_last_day(DATEADD(mm,-1,  @FECHA_DESDE )) + 1
   
-- Calcula nuevamente los meses promedio por el ajuste a meses completos

SET @p_meses_promedio = DATEDIFF(mm,@FECHA_DESDE,@FECHA_HASTA) + 1

SET @dias_promedio = gen.fn_diff_two_dates_30(@FECHA_DESDE, @FECHA_HASTA)
---------------------------------------------------
--        Obtiene Ingresos del Agrupador         --
---------------------------------------------------
--PRINT 'Que agrupador: '+convert(varchar, @p_agrupador)
SELECT @Total_Ingresos = round(sum(ISNULL(inn_valor,0)), 2) 
  FROM sal.inn_ingresos 
  JOIN sal.ppl_periodos_planilla  ON INN_CODPPL = ppl_codigo
  JOIN sal.tpl_tipo_planilla      ON tpl_codcia = @codcia and tpl_codigo = ppl_codtpl
  JOIN sal.iag_ingresos_agrupador ON INN_CODTIG = iag_codtig
  JOIN sal.tig_tipos_ingreso      ON tig_codcia = tpl_codcia and tig_codigo = iag_codtig
 WHERE inn_codemp = @P_Codemp
   and ppl_estado = 'Autorizado'
   and ppl_fecha_pago >= @fecha_desde
   and ppl_fecha_pago <= @fecha_hasta
   and iag_codagr = @p_agrupador

---------------------------------------------------
--           Busca Salario Ordinario             --
---------------------------------------------------
IF @p_tipo_salario = 1
BEGIN
  SET @SALARIO = @SALARIO * @p_meses_promedio
END
ELSE
IF @p_tipo_salario = 0
BEGIN
  SET @SALARIO = 0
END
ELSE
IF @p_tipo_salario = 2
BEGIN 
 SELECT @SALARIO = isnull(sum(hes_valor),0)
   FROM sal.hes_historico_estructura_salarial_v
  WHERE hes_codemp = @p_codemp
    AND hes_fecha_ini between @FECHA_DESDE and @FECHA_HASTA
    AND hes_fecha_fin between @FECHA_DESDE and @FECHA_HASTA
    AND hes_codrsa = @codrsa_salario
END 
ELSE
-- Calcula el promedio real de salario percibido por los dias reales trabajados de salario
BEGIN 

select @codtig_salario =  ese_codtig 
from exp.rsa_rubros_salariales 
join exp.ese_estructura_sal_empleos on ese_codrsa = rsa_codigo 
where rsa_codcia = @codcia 
  and ese_codemp = @p_codemp 
  and rsa_es_salario_base = 1

SELECT @SALARIO = round(sum(ISNULL(inn_valor,0)), 2) , 
       @dias_trabajados =  SUM(isnull(inn_tiempo,0))
  FROM sal.inn_ingresos 
  JOIN sal.ppl_periodos_planilla  ON INN_CODPPL = ppl_codigo
  JOIN sal.tpl_tipo_planilla      ON tpl_codcia = @codcia and tpl_codigo = ppl_codtpl
 WHERE inn_codemp = @P_Codemp
   and ppl_estado = 'Autorizado'
   and ppl_fecha_pago >= @fecha_desde
   and ppl_fecha_pago <= @fecha_hasta
   and inn_codtig = @codtig_salario
   
IF ISNULL(@SALARIO,0) = 0
   SET @SALARIO = @salario_actual * @p_meses_promedio  -- No encontro nada percibido, toma el salario actual
   
IF @dias_trabajados > 0
   SET @SALARIO = (@SALARIO / @dias_trabajados) * 30 * @p_meses_promedio
ELSE
IF @dias_promedio > 0
   SET @SALARIO = (@SALARIO / @dias_promedio) * 30 * @p_meses_promedio
ELSE
   SET @SALARIO = 0
END 

---------------------------------------------------
--                Calcula Promedio               --
---------------------------------------------------
SET @p_promedio = ISNULL(ROUND((@Total_Ingresos + @SALARIO) / @p_meses_promedio,2),0)

--print 'Meses promedio: '+convert(varchar,@p_meses_promedio)  
--print 'Desde:          '+convert(varchar,@fecha_desde,103)
--print 'Hasta:          '+convert(varchar,@fecha_hasta,103)
--print 'Total Ingresos: '+convert(varchar, convert(money, @Total_Ingresos))
--print 'Total Salario:  '+convert(varchar,@SALARIO)
--print 'Total Pactado:  '+convert(varchar,@BONO_PACTADO)
--print '---------------------------'
--print 'Promedio:       '+convert(varchar,@p_promedio)

END



