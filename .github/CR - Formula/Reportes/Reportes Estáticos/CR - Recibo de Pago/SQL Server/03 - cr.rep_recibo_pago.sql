IF EXISTS (SELECT 1
		   FROM sys.objects
		   WHERE object_id = object_id('cr.rep_recibo_pago'))
BEGIN
	DROP PROCEDURE cr.rep_recibo_pago
END

GO

--EXEC cr.rep_recibo_pago 5, '1', '20140802', NULL, NULL, NULL, NULL, NULL, 'jcsoria'
CREATE PROCEDURE cr.rep_recibo_pago (
	@codcia INT = NULL,
	@codtpl_visual VARCHAR(20) = NULL,
	@codppl_visual VARCHAR(10) = NULL,
	@codemp_alternativo VARCHAR(36) = NULL,
	@codarf INT = NULL,
	@coduni INT = NULL,
	@codcdt INT = NULL,
	@copias INT = NULL,
	@usuario VARCHAR(50) = NULL
)

AS
--------------------------------------------------------------------------------------
-- evolution - recibo de pago                                                       --
-- utiliza las vistas siguientes                                                    --
--   sal.dpn_det_pago_numerada_v     
--   sal.dpr_det_pago_recibo_v                                                     --
--------------------------------------------------------------------------------------
SET NOCOUNT ON

-- declaraciones de variables de la tabla o del CURSOR
DECLARE @codtpl INT,
	@codppl INT,
	@codemp INT,
	@cia_descripcion  VARCHAR(250),		
	@codigo_empleado INT, 
	@exp_apellidos_nombres VARCHAR(80), 
	@plz_nombre VARCHAR(80), 
	@fecha_ini DATETIME,
	@fecha_fin DATETIME,
	@maxlineas SMALLINT,
	@contador INT,
	@contador_lineas INT,
	@copia SMALLINT,
	@maxcopias SMALLINT,
	@inn_tiempo REAL,
	@codtig INT,
	@tig_descripcion VARCHAR(50),
	@valor_ingreso MONEY,
	@codtdc INT,
	@tdc_descripcion VARCHAR(50),
	@valor_descuento MONEY
	
-------------------------------------	  	
--      inicializa variables       --
-------------------------------------
SET @maxlineas = 13
SET @maxcopias = ISNULL(@copias, 1)
SET @contador  = 1

SELECT @codtpl = tpl_codigo 
FROM sal.tpl_tipo_planilla 
WHERE tpl_codigo_visual = @codtpl_visual 
	AND tpl_codcia = @codcia

SELECT @codppl = ppl_codigo 
FROM sal.ppl_periodos_planilla 
WHERE ppl_codtpl=@codtpl 
	AND ppl_codigo_planilla=@codppl_visual

SET @codemp = gen.obtiene_codigo_empleo(@codemp_alternativo)

SELECT @cia_descripcion = cia_descripcion
FROM eor.cia_companias
WHERE cia_codigo = @codcia

SELECT @fecha_ini = ppl_fecha_ini,
       @fecha_fin = ppl_fecha_fin
FROM sal.ppl_periodos_planilla
WHERE ppl_codigo = @codppl
 
-------------------------------------	  	
-- crea tabla temporal de recibos  --
-------------------------------------
CREATE TABLE #recibo_pago(
	codcia INT NOT NULL,
	cia_descripcion VARCHAR(250)  NULL,
	codtpl INT NULL,
	codppl_visual VARCHAR(10) NULL,
	fecha_ini DATETIME NULL,
	fecha_fin DATETIME NULL,
	codemp INT NULL,
	exp_apellidos_nombres VARCHAR(80) NULL,
	plz_nombre VARCHAR(50) NULL,
	inn_tiempo REAL NULL,
	tig_descripcion VARCHAR(50) NULL,
	valor_ingreso MONEY NULL,
	tdc_descripcion VARCHAR(50) NULL,
	valor_descuento MONEY NULL,
	num_copia INT NULL,
	numeral INT IDENTITY(1,1)
)

SELECT dpr_codemp,
	dpr_rn,
	dpr_codtig,
	tig_descripcion,
	ROUND(dpr_valor_ing, 2) valor_ing,
	dpr_dias_ing inn_dias_ingreso,
	dpr_codtdc,
	tdc_descripcion,
	dpr_valor_desc valor_desc
INTO #movimientos
FROM cr.rep_recibo_detalle
WHERE dpr_codppl = @codppl 

CREATE INDEX ix_movs_in ON #movimientos (dpr_codemp, dpr_rn, dpr_codtig, dpr_codtdc)		

-------------------------------------	  	
--  CURSOR principal de empleados  --
-------------------------------------
DECLARE empleados CURSOR FOR
SELECT hpa_codemp, 
	UPPER(hpa_apellidos_nombres) hpa_apellidos_nombres,
	hpa_nombre_plaza
FROM sal.hpa_hist_periodos_planilla
	JOIN exp.emp_empleos ON hpa_codemp = emp_codigo
WHERE hpa_codppl = @codppl
	AND hpa_codemp = ISNULL(@codemp, hpa_codemp)
	AND hpa_codarf = ISNULL(@codarf, hpa_codarf)
	AND hpa_coduni = ISNULL(@coduni, hpa_coduni)
	AND hpa_codcdt = ISNULL(@codcdt, hpa_codcdt)
	AND EXISTS (SELECT NULL
				FROM sal.inn_ingresos 
				WHERE inn_codppl = hpa_codppl 
					AND inn_codemp = hpa_codemp
					AND inn_valor > 0) 
	AND sco.permiso_empleo(hpa_codemp, @usuario) = 1
ORDER BY hpa_nombre_areafun, hpa_nombre_unidad, hpa_nombre_centro_trabajo, hpa_codemp

OPEN empleados

FETCH NEXT FROM empleados INTO @codigo_empleado, @exp_apellidos_nombres, @plz_nombre

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @copia = 1
	-------------------------------------	  	
	--   loop por copias solicitadas   --
	-------------------------------------	
	WHILE @copia <= @maxcopias
	BEGIN
		SET @contador_lineas = 0
		-------------------------------------	  	
		--      CURSOR de movimientos      --
		-------------------------------------		
		DECLARE movimientos CURSOR 
		FOR SELECT dpr_codtig,
			tig_descripcion,
			valor_ing,
			inn_dias_ingreso,
			dpr_codtdc,
			tdc_descripcion,
			valor_desc
		FROM #movimientos
		WHERE dpr_codemp = @codigo_empleado
		ORDER BY dpr_rn, ISNULL(dpr_codtig, dpr_codtdc)

		OPEN movimientos

		FETCH NEXT FROM movimientos 
		INTO @codtig, 
			@tig_descripcion, 
			@valor_ingreso, 
			@inn_tiempo,
			@codtdc, 
			@tdc_descripcion, 
			@valor_descuento		
			                           
		WHILE @contador_lineas < @maxlineas
		BEGIN		
			INSERT INTO #recibo_pago(codcia,
				cia_descripcion,
				codtpl,
				codppl_visual,
				fecha_ini,
				fecha_fin,
				codemp,
				exp_apellidos_nombres,
				plz_nombre,
				inn_tiempo,
				tig_descripcion,
				valor_ingreso,
				tdc_descripcion,
				valor_descuento,
				num_copia)
			VALUES (@codcia,
				@cia_descripcion,
				@codtpl,
				@codppl_visual,
				@fecha_ini,
				@fecha_fin,
				@codigo_empleado,
				@exp_apellidos_nombres,
				@plz_nombre,
				@inn_tiempo,
				@tig_descripcion,
				@valor_ingreso,
				@tdc_descripcion,
				@valor_descuento,
				@copia)

			SET @codtig = NULL
			SET @tig_descripcion = NULL
			SET @valor_ingreso = NULL
			SET @inn_tiempo = NULL
			SET @codtdc = NULL
			SET @tdc_descripcion = NULL 
			SET @valor_descuento = NULL
								 
			SET @contador_lineas = @contador_lineas + 1
		
			FETCH NEXT FROM movimientos 
			INTO @codtig, 
				@tig_descripcion, 
				@valor_ingreso, 
				@inn_tiempo,
				@codtdc, 
				@tdc_descripcion, 
				@valor_descuento
		END

		CLOSE movimientos
		DEALLOCATE movimientos
		
		SET @copia = @copia + 1
	END

	FETCH NEXT FROM empleados INTO @codigo_empleado, @exp_apellidos_nombres, @plz_nombre

	SET @contador = @contador + 1

END

CLOSE empleados
DEALLOCATE empleados
	  
SELECT codcia,
	cia_descripcion,
	codtpl,
	codppl_visual,
	fecha_ini,
	fecha_fin,
	codemp,
	exp_apellidos_nombres,
	plz_nombre,
	inn_tiempo,
	tig_descripcion,
	valor_ingreso,
	tdc_descripcion,
	valor_descuento,
	num_copia
FROM #recibo_pago 
ORDER BY numeral

DROP TABLE #recibo_pago
DROP TABLE #movimientos