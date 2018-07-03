IF EXISTS (SELECT NULL
		   FROM sys.objects
		   WHERE object_id = object_id('sal.hes_historico_estructura_salarial_v'))
BEGIN
	DROP VIEW sal.hes_historico_estructura_salarial_v
END

GO

CREATE VIEW sal.hes_historico_estructura_salarial_v
--------------------------------------------------------
--  EVOLUTION                                         --
--  Obtiene en detalle mensual los rubros salariales  --
--  Si desea obtener una historia atras mayor cambiar --
--  la vista gen.fec_fechas_v                     --
--------------------------------------------------------
AS
SELECT	HES_CODCIA,
        HES_CODEXP,
		HES_CODEMP,
		HES_ESTADO,
		ese_codrsa HES_CODRSA, 
		rsa_descripcion HES_RSA_DESCRIPCION,
		rsa_es_salario_base HES_ES_SALARIO_BASE,
		ese_codtig HES_CODTIG,
		tig_descripcion HES_TIG_DESCRIPCION,
		tig_abreviatura HES_TIG_ABREVIATURA,
		ese_codmon HES_CODMON,
		HES_ANIO,
		HES_MES,
		HES_FECHA_INGRESO,
		HES_FECHA_RETIRO,
		MIN(HES_FECHA_INI) HES_FECHA_INI,
		MAX(HES_FECHA_FIN) HES_FECHA_FIN,
		SUM(HSA_DIAS_MES) HES_DIAS_MES,
		SUM(HSA_DIAS) HES_DIAS,
		SUM(HSA_valor) HES_VALOR
FROM (
		SELECT  PLZ_CODCIA HES_CODCIA,
		        emp_codexp HES_CODEXP,
				EMP_CODIGO HES_CODEMP,
				EMP_ESTADO HES_ESTADO,
				ese_codrsa, 
				rsa_descripcion,
				rsa_es_salario_base,
				ese_codtig,
				tig_descripcion,
				tig_abreviatura,
				ese_codmon,
				FEC_ANIO HES_ANIO,
				FEC_MES HES_MES,
				EMP_FECHA_INGRESO HES_FECHA_INGRESO,
				EMP_FECHA_RETIRO HES_FECHA_RETIRO,
				case when FEC_FECHA_INI < EMP_FECHA_INGRESO
				          THEN  EMP_FECHA_INGRESO
				          ELSE FEC_FECHA_INI
				END HES_FECHA_INI, 
				FEC_FECHA_FIN HES_FECHA_FIN,
				HSA_DIAS_MES,		
				HSA_DIAS,
				CAST(ROUND((ese_valor/HSA_DIAS_MES) * HSA_DIAS,2) AS DECIMAL(18,5)) HSA_VALOR
		FROM (
				SELECT  PLZ_CODCIA,
				        emp_codexp,
						EMP_CODIGO,
						EMP_ESTADO,
						ese_codrsa, 
						rsa_descripcion,
					    rsa_es_salario_base,
					    ese_codtig,
					    tig_descripcion,
					    tig_abreviatura,
						ese_codmon,
						FEC_ANIO,
						FEC_MES,
						EMP_FECHA_INGRESO,
						EMP_FECHA_RETIRO,
						FEC_FECHA_INI,
						FEC_FECHA_FIN,
						ISNULL(datediff(d,(CASE WHEN (CASE WHEN FEC_FECHA_INI <= ese_fecha_inicio THEN ese_fecha_inicio ELSE FEC_FECHA_INI END) <= EMP_FECHA_INGRESO 
																THEN EMP_FECHA_INGRESO 
																ELSE (CASE WHEN FEC_FECHA_INI <= ese_fecha_inicio THEN ese_fecha_inicio ELSE FEC_FECHA_INI END)
																END),
												(CASE WHEN (CASE WHEN FEC_FECHA_FIN >= ese_fecha_fin THEN ese_fecha_fin ELSE FEC_FECHA_FIN END) >= EMP_FECHA_RETIRO 
														THEN EMP_FECHA_RETIRO 
														ELSE (CASE WHEN FEC_FECHA_FIN >= ese_fecha_fin THEN ese_fecha_fin ELSE FEC_FECHA_FIN END) 
														END)), 1) +1 HSA_DIAS,
						DATEDIFF(D,FEC_FECHA_INI, FEC_FECHA_FIN) +1 HSA_DIAS_MES,														
						ese_valor
	                 FROM gen.FEC_FECHAS_v INNER JOIN
					(
						SELECT PLZ_CODCIA, 
						EMP_CODIGO, EMP_ESTADO,
								EMP_FECHA_INGRESO, 
							ISNULL(EMP_FECHA_RETIRO, '30001231') EMP_FECHA_RETIRO
						FROM exp.emp_empleos
						     JOIN eor.plz_plazas on plz_codigo = emp_codplz
					) EMP
					ON((EMP_FECHA_INGRESO BETWEEN FEC_FECHA_INI AND FEC_FECHA_FIN) 
						OR (EMP_FECHA_INGRESO <= FEC_FECHA_INI AND EMP_FECHA_RETIRO >= FEC_FECHA_FIN) 
						OR (EMP_FECHA_RETIRO BETWEEN FEC_FECHA_INI AND FEC_FECHA_FIN))

					INNER JOIN ( SELECT emp_codexp,
					                    ese_codemp, 
					                    ese_codrsa,
					                    rsa_descripcion,
					                    rsa_es_salario_base,
					                    ese_codtig,
					                    tig_descripcion,
					                    tig_abreviatura,
					                    ese_codmon, 
					                    ese_fecha_inicio, 
					                    ISNULL(ese_fecha_fin,'30001231') ese_fecha_fin, 
					                    ese_valor
	                               FROM exp.ese_estructura_sal_empleos
	                               JOIN exp.emp_empleos on emp_codigo = ese_codemp
	                               JOIN eor.plz_plazas on plz_codigo = emp_codplz
	                               JOIN exp.rsa_rubros_salariales on rsa_codcia = plz_codcia 
	                                                              and rsa_codigo = ese_codrsa
	                               JOIN sal.tig_tipos_ingreso on tig_codigo = ese_codtig 
	                            ) E
						ON ese_codemp = EMP_CODIGO

				WHERE 
				((ese_fecha_inicio BETWEEN FEC_FECHA_INI AND FEC_FECHA_FIN)
					OR (ese_fecha_inicio <= FEC_FECHA_INI AND (ese_fecha_fin BETWEEN FEC_FECHA_INI AND FEC_FECHA_FIN))
					OR (ese_fecha_inicio <= FEC_FECHA_INI AND ese_fecha_fin >= FEC_FECHA_FIN)
					OR (ese_fecha_fin BETWEEN FEC_FECHA_INI AND FEC_FECHA_FIN))
			) HPA

	) H

GROUP BY HES_CODCIA,
         HES_CODEXP,
		 HES_CODEMP,
		 HES_ESTADO,
		 ese_codrsa, 
		 rsa_descripcion,
		 rsa_es_salario_base,
		 ese_codtig,
		 tig_descripcion,
		 tig_abreviatura,
		 ese_codmon,
		 HES_ANIO,
		 HES_MES,
		 HES_FECHA_INGRESO,
		 HES_FECHA_RETIRO






GO

