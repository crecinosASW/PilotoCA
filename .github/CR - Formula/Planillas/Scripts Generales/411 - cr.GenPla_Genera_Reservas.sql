IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('cr.GenPla_Genera_Reservas'))
BEGIN
	DROP PROCEDURE cr.GenPla_Genera_Reservas
END

GO

--EXEC cr.GenPla_Genera_Reservas 1119, NULL
CREATE PROCEDURE cr.GenPla_Genera_Reservas
    @codppl int,
    @sessionId uniqueidentifier = null

AS
DECLARE @codpai VARCHAR(2),
	@codcia int,
    @trs_codigo int,
    @trs_codagr int,
    @trs_porcentaje float,
	@codaso_asociacion INT,
	@codtrs_asociacion INT,
	@codtrs_aguinaldo INT,
	@codrin_maternidad INT

BEGIN
    -- Eliminación de datos de reserva
    DELETE  FROM sal.res_reservas
            WHERE res_codppl = @codppl 
                    and sal.empleado_en_gen_planilla(@sessionId, res_codemp) = 1;
      
    -- Obtiene codigo de compañía
    SELECT @codpai = cia_codpai,
		@codcia = tpl_codcia
    FROM sal.ppl_periodos_planilla
        join sal.tpl_tipo_planilla on tpl_codigo = ppl_codtpl
		join eor.cia_companias on tpl_codcia = cia_codigo
    WHERE ppl_codigo = @codppl;

	SET @codaso_asociacion = gen.get_valor_parametro_inT('CodigoASO_Ahorro', @codpai, NULL, NULL, NULL)
	SET @codrin_maternidad = gen.get_valor_parametro_int('CodigoRIN_Maternidad', @codpai, NULL, NULL, NULL)
	SET @codtrs_asociacion = gen.get_valor_parametro_int('CodigoTRS_Asociacion', NULL, NULL, @codcia, NULL)
	SET @codtrs_aguinaldo = gen.get_valor_parametro_int('CodigoTRS_Aguinaldo', NULL, NULL, @codcia, NULL)

    -- Cursor de reservas
    DECLARE c_reservas cursor for
    SELECT 
            trs_codigo,
            gen.get_pb_field_data(trs_property_bag_data,'trs_codagr') trs_codagr,
            isnull(gen.get_pb_field_data_float(trs_property_bag_data,'trs_porcentaje'),0) / 100 trs_porc_provision
    FROM sal.trs_tipos_reserva
    WHERE trs_tipo = 'Legal'
        and trs_codcia = @codcia
        
    
    -- Creación de la reserva
    OPEN c_reservas
    FETCH NEXT FROM c_reservas INTO @trs_codigo, @trs_codagr, @trs_porcentaje
    WHILE @@FETCH_STATUS = 0
    BEGIN

		IF @trs_codigo = @codtrs_asociacion
		BEGIN		
			INSERT INTO sal.res_reservas ( 
				res_codppl, 
				res_codemp, 
				res_codtrs, 
				res_valor, 
				res_codmon, 
				res_tiempo,
				res_unidad_tiempo)
			SELECT inn_codppl, 
				inn_codemp, 
				@trs_codigo,
				ROUND(SUM(inn_valor) * @trs_porcentaje, 2) valor, 
				inn_codmon, 
				AVG(inn_tiempo) tiempo, 
				inn_unidad_tiempo
			FROM sal.inn_ingresos
				JOIN exp.emp_empleos ON inn_codemp = emp_codigo
				JOIN sal.ppl_periodos_planilla ON inn_codppl = ppl_codigo
			WHERE inn_codppl = @codppl
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @trs_codagr)
				AND EXISTS (SELECT NULL
							FROM exp.ase_asociaciones_expedientes
							WHERE ase_codexp = emp_codexp
								AND ase_codaso = @codaso_asociacion
								AND ISNULL(ase_fecha_ingreso, ppl_fecha_ini) <= ppl_fecha_fin
								AND ISNULL(ase_fecha_retiro, ppl_fecha_fin) >= ppl_fecha_ini)
				AND sal.empleado_en_gen_planilla(@sessionId, inn_codemp) = 1    
			GROUP BY inn_codppl, inn_codemp,  inn_codmon, inn_unidad_tiempo
		END
		ELSE IF @trs_codigo = @codtrs_aguinaldo
		BEGIN
			INSERT INTO sal.res_reservas ( 
				res_codppl, 
				res_codemp, 
				res_codtrs, 
				res_valor, 
				res_codmon, 
				res_tiempo,
				res_unidad_tiempo)
			SELECT hpa_codppl codppl, 
				hpa_codemp codemp, 
				@trs_codigo codtrs,
				ROUND(SUM(d.valor), 2) valor, 
				d.codmon codmon, 
				0.00 tiempo, 
				NULL unidad_tiempo
			FROM sal.hpa_hist_periodos_planilla
				JOIN (
					SELECT inn_codppl codppl,
						inn_codemp codemp,
						ROUND(SUM(inn_valor) * @trs_porcentaje, 2) valor,
						inn_codmon codmon
					FROM sal.inn_ingresos
					WHERE inn_codppl = @codppl
						AND inn_codtig IN (SELECT iag_codtig
										   FROM sal.iag_ingresos_agrupador
										   WHERE iag_codagr = @trs_codagr)
					GROUP BY inn_codppl, inn_codemp, inn_codmon

					UNION

					SELECT pie_codppl codppl,
						ixe_codemp codemp,
						ROUND(SUM(pie_valor_a_pagar + pie_valor_a_descontar) * @trs_porcentaje, 2) valor,
						pie_codmon comdon
					FROM acc.pie_periodos_incapacidad 
						JOIN acc.ixe_incapacidades ON pie_codixe = ixe_codigo
					WHERE pie_codppl = @codppl
						AND ixe_codrin = @codrin_maternidad	
					GROUP BY pie_codppl, ixe_codemp, pie_codmon) d ON hpa_codppl = d.codppl AND hpa_codemp = d.codemp
			WHERE hpa_codppl = @codppl
				AND sal.empleado_en_gen_planilla(@sessionId, hpa_codemp) = 1    
			GROUP BY hpa_codppl, hpa_codemp, d.codmon
		END
		ELSE
		BEGIN
			INSERT INTO sal.res_reservas ( 
				res_codppl, 
				res_codemp, 
				res_codtrs, 
				res_valor, 
				res_codmon, 
				res_tiempo,
				res_unidad_tiempo)
			SELECT inn_codppl, 
				inn_codemp, 
				@trs_codigo res_codtrs,
				ROUND(SUM(inn_valor) * @trs_porcentaje, 2) valor, 
				inn_codmon, 
				AVG(inn_tiempo) tiempo, 
				inn_unidad_tiempo
			FROM sal.inn_ingresos
			WHERE inn_codppl = @codppl
				AND inn_codtig IN (SELECT iag_codtig
								   FROM sal.iag_ingresos_agrupador
								   WHERE iag_codagr = @trs_codagr)
				AND sal.empleado_en_gen_planilla(@sessionId, inn_codemp) = 1
			GROUP BY inn_codppl, inn_codemp, inn_codmon, inn_unidad_tiempo
		END
        
        FETCH NEXT FROM c_reservas INTO @trs_codigo, @trs_codagr, @trs_porcentaje
    END
END