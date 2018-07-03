IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('gen.FN_MESES_ATRAS'))
BEGIN
	DROP FUNCTION gen.FN_MESES_ATRAS
END

GO

CREATE FUNCTION gen.FN_MESES_ATRAS (@p_anos int)
RETURNS @fechas table (fec_anio int, 
                       fec_mes int, 
                       fec_anio_mes int, 
                       fec_fecha_ini datetime, 
                       fec_fecha_fin datetime)
-----------------------------------------------------------------------------
--    EVOLUTION                                                            --
--    Esta funcion retorna los meses calendario en una cantidad de años    --   
--    Es utilizada en la Vista gen.fec_fechas_v                            --
-----------------------------------------------------------------------------                    
as
BEGIN
DECLARE
@fecha_final DATETIME,
@fecha_inicio_retorno DATETIME,
@fecha_final_retorno DATETIME

SET @fecha_final = gen.fn_last_day(GETDATE())
SET @fecha_inicio_retorno = DATEADD(year,@p_anos*(-1),@fecha_final)+1
SET @fecha_final_retorno = gen.fn_LAST_DAY(@fecha_inicio_retorno)

WHILE @fecha_final_retorno <= @fecha_final
BEGIN
INSERT INTO @fechas VALUES( datepart(year, @fecha_inicio_retorno),
                            datepart(month, @fecha_inicio_retorno),
                            CONVERT(int,convert(varchar(4),datepart(year,@fecha_inicio_retorno))+
                                        RIGHT('00'+convert(varchar(2),datepart(month,@fecha_inicio_retorno)),2) ),
                            @fecha_inicio_retorno, 
                            @fecha_final_retorno)
                            
SET @fecha_inicio_retorno = DATEADD(d,1,@fecha_final_retorno)
SET @fecha_final_retorno = gen.fn_LAST_DAY(@fecha_inicio_retorno)

END

RETURN
END
GO

