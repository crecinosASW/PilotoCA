SET DATEFORMAT YMD

/*Módulos a Eliminar*/
/*
Capacitacion
EvaluacionDesempenio
ReclutamientoPublico
ReclutamientoYSeleccion
Auditoria
ISRGT
EncuestasSalariales
ValuacionPuestoPuntos
ValuacionPuestosHay
PanoramaRiesgosYAnalisisTrabajoSeguro
SeguimientoYControl
SeguridadCorporativa
*/

BEGIN TRANSACTION

--SELECT *
--FROM rep.rep_reportes
--WHERE EXISTS (SELECT 1
--			  FROM rep.rpm_reportes_modulos
--			  WHERE rep_codigo = rpm_codrep
--				AND rpm_codmod IN ('AccionesPortal',
--						'Capacitacion',
--						'Consultas',
--						'ControlAsistencia',
--						'EncuestasSalariales',
--						'EvaluacionDesempenio',
--						'PanoramaRiesgosYAnalisisTrabajoSeguro',
--						'ReclutamientoYSeleccion',
--						'SeguimientoYControl',
--						'SeguridadCorporativa',
--						'Solicitudes',
--						'ValuacionPuestoPuntos',
--						'ValuacionPuestosHay'))

--SELECT *
--FROM wrp.rep_reportes
--WHERE EXISTS (SELECT 1
--			  FROM wrp.set_sets
--				JOIN wrp.sdm_set_modules ON set_setkey = sdm_setkey
--			  WHERE rep_setkey = set_setkey
--				AND sdm_codmod IN ('AccionesPortal',
--						'Capacitacion',
--						'Consultas',
--						'ControlAsistencia',
--						'EncuestasSalariales',
--						'EvaluacionDesempenio',
--						'PanoramaRiesgosYAnalisisTrabajoSeguro',
--						'ReclutamientoYSeleccion',
--						'SeguimientoYControl',
--						'SeguridadCorporativa',
--						'Solicitudes',
--						'ValuacionPuestoPuntos',
--						'ValuacionPuestosHay'))

--SELECT *
--FROM wrp.set_sets
--WHERE EXISTS (SELECT 1
--			  FROM wrp.sdm_set_modules
--			  WHERE set_setkey = sdm_setkey
--				AND sdm_codmod IN ('AccionesPortal',
--						'Capacitacion',
--						'Consultas',
--						'ControlAsistencia',
--						'EncuestasSalariales',
--						'EvaluacionDesempenio',
--						'PanoramaRiesgosYAnalisisTrabajoSeguro',
--						'ReclutamientoYSeleccion',
--						'SeguimientoYControl',
--						'SeguridadCorporativa',
--						'Solicitudes',
--						'ValuacionPuestoPuntos',
--						'ValuacionPuestosHay'))

--SELECT *
--FROM wrp.wrd_word_templates
--WHERE EXISTS (SELECT 1
--			  FROM wrp.wrm_word_modulos
--			  WHERE wrm_codwrd = wrd_codigo
--				  AND wrm_codmod IN ('AccionesPortal',
--						'Capacitacion',
--						'Consultas',
--						'ControlAsistencia',
--						'EncuestasSalariales',
--						'EvaluacionDesempenio',
--						'PanoramaRiesgosYAnalisisTrabajoSeguro',
--						'ReclutamientoYSeleccion',
--						'SeguimientoYControl',
--						'SeguridadCorporativa',
--						'Solicitudes',
--						'ValuacionPuestoPuntos',
--						'ValuacionPuestosHay'))

--SELECT *
--FROM spx.stp_store_procedures
--WHERE EXISTS (SELECT 1
--			  FROM spx.spm_store_procedure_modulo
--			  WHERE stp_codigo = spm_codstp
--				AND spm_codmod IN ('AccionesPortal',
--						'Capacitacion',
--						'Consultas',
--						'ControlAsistencia',
--						'EncuestasSalariales',
--						'EvaluacionDesempenio',
--						'PanoramaRiesgosYAnalisisTrabajoSeguro',
--						'ReclutamientoYSeleccion',
--						'SeguimientoYControl',
--						'SeguridadCorporativa',
--						'Solicitudes',
--						'ValuacionPuestoPuntos',
--						'ValuacionPuestosHay'))
	
--SELECT *
--FROM cfg.cen_cfg_entidades
--WHERE EXISTS (SELECT 1
--			  FROM sec.opc_opciones
--			  WHERE cen_opcion_edit = opc_codigo
--				AND opc_codmod IN ('AccionesPortal',
--					'Capacitacion',
--					'Consultas',
--					'ControlAsistencia',
--					'EncuestasSalariales',
--					'EvaluacionDesempenio',
--					'PanoramaRiesgosYAnalisisTrabajoSeguro',
--					'ReclutamientoYSeleccion',
--					'SeguimientoYControl',
--					'SeguridadCorporativa',
--					'Solicitudes',
--					'ValuacionPuestoPuntos',
--					'ValuacionPuestosHay'))	
						
--SELECT *
--FROM sec.axo_acciones_opcion
--WHERE EXISTS (SELECT 1
--			  FROM sec.opc_opciones
--			  WHERE axo_codopc = opc_codigo
--				  AND opc_codmod IN ('AccionesPortal',
--						'Capacitacion',
--						'Consultas',
--						'ControlAsistencia',
--						'EncuestasSalariales',
--						'EvaluacionDesempenio',
--						'PanoramaRiesgosYAnalisisTrabajoSeguro',
--						'ReclutamientoYSeleccion',
--						'SeguimientoYControl',
--						'SeguridadCorporativa',
--						'Solicitudes',
--						'ValuacionPuestoPuntos',
--						'ValuacionPuestosHay'))		
						
--SELECT *
--FROM sec.opc_opciones
--WHERE opc_codmod IN ('AccionesPortal',
--	'Capacitacion',
--	'Consultas',
--	'ControlAsistencia',
--	'EncuestasSalariales',
--	'EvaluacionDesempenio',
--	'PanoramaRiesgosYAnalisisTrabajoSeguro',
--	'ReclutamientoYSeleccion',
--	'SeguimientoYControl',
--	'SeguridadCorporativa',
--	'Solicitudes',
--	'ValuacionPuestoPuntos',
--	'ValuacionPuestosHay')	
	
--SELECT *
--FROM sec.mod_modulos
--WHERE mod_codigo IN ('AccionesPortal',
--	'Capacitacion',
--	'Consultas',
--	'ControlAsistencia',
--	'EncuestasSalariales',
--	'EvaluacionDesempenio',
--	'PanoramaRiesgosYAnalisisTrabajoSeguro',
--	'ReclutamientoYSeleccion',
--	'SeguimientoYControl',
--	'SeguridadCorporativa',
--	'Solicitudes',
--	'ValuacionPuestoPuntos',
--	'ValuacionPuestosHay')
	
--SELECT *
--FROM sec.app_aplicaciones
--WHERE NOT EXISTS (SELECT 1
-- 				  FROM sec.mod_modulos
-- 				  WHERE mod_codapp = app_id)
--	AND app_id <> 'Home'

DELETE
FROM rep.rep_reportes
WHERE EXISTS (SELECT 1
			  FROM rep.rpm_reportes_modulos
			  WHERE rep_codigo = rpm_codrep
				AND rpm_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))

DELETE
FROM wrp.rep_reportes
WHERE EXISTS (SELECT 1
			  FROM wrp.set_sets
				JOIN wrp.sdm_set_modules ON set_setkey = sdm_setkey
			  WHERE rep_setkey = set_setkey
				AND sdm_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))

DELETE
FROM wrp.set_sets
WHERE EXISTS (SELECT 1
			  FROM wrp.sdm_set_modules
			  WHERE set_setkey = sdm_setkey
				AND sdm_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))

DELETE
FROM wrp.wrd_word_templates
WHERE EXISTS (SELECT 1
			  FROM wrp.wrm_word_modulos
			  WHERE wrm_codwrd = wrd_codigo
				  AND wrm_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))

DELETE
FROM spx.stp_store_procedures
WHERE EXISTS (SELECT 1
			  FROM spx.spm_store_procedure_modulo
			  WHERE stp_codigo = spm_codstp
				AND spm_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))

UPDATE cfg.cen_cfg_entidades
SET cen_opcion_edit = NULL,
	cen_accion_edit = NULL
WHERE EXISTS (SELECT 1
			  FROM sec.opc_opciones
			  WHERE cen_opcion_edit = opc_codigo
				AND opc_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))
					
UPDATE cfg.cen_cfg_entidades
SET cen_opcion_detail = NULL,
	cen_accion_detail = NULL
WHERE EXISTS (SELECT 1
			  FROM sec.opc_opciones
			  WHERE cen_opcion_detail = opc_codigo
				AND opc_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))	
					
UPDATE cfg.cen_cfg_entidades
SET cen_opcion_reintentar_fin = NULL,
	cen_accion_reintentar_fin = NULL
WHERE EXISTS (SELECT 1
			  FROM sec.opc_opciones
			  WHERE cen_opcion_reintentar_fin = opc_codigo
				AND opc_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))		
					
UPDATE cfg.cen_cfg_entidades
SET cen_opcion_init_flujo = NULL,
	cen_accion_init_flujo = NULL
WHERE EXISTS (SELECT 1
			  FROM sec.opc_opciones
			  WHERE cen_opcion_init_flujo = opc_codigo
				AND opc_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))			
					
UPDATE cfg.cen_cfg_entidades
SET cen_opcion_descartar_flujo = NULL,
	cen_accion_descartar_flujo = NULL
WHERE EXISTS (SELECT 1
			  FROM sec.opc_opciones
			  WHERE cen_opcion_descartar_flujo = opc_codigo
				AND opc_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))	
					
UPDATE cfg.cen_cfg_entidades
SET cen_opcion_reintentar_flujo = NULL,
	cen_accion_reintentar_flujo = NULL
WHERE EXISTS (SELECT 1
			  FROM sec.opc_opciones
			  WHERE cen_opcion_reintentar_flujo = opc_codigo
				AND opc_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))																		
						
DELETE
FROM sec.axo_acciones_opcion
WHERE EXISTS (SELECT 1
			  FROM sec.opc_opciones
			  WHERE axo_codopc = opc_codigo
				  AND opc_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa'))		
						
DELETE
FROM sec.opc_opciones
WHERE opc_codmod IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa')	
	
DELETE
FROM sec.mod_modulos
WHERE mod_codigo IN ('Capacitacion',
					'EvaluacionDesempenio',
					'ReclutamientoPublico',
					'ReclutamientoYSeleccion',
					'Auditoria',
					'ISRGT',
					'EncuestasSalariales',
					'ValuacionPuestoPuntos',
					'ValuacionPuestosHay',
					'PanoramaRiesgosYAnalisisTrabajoSeguro',
					'SeguimientoYControl',
					'SeguridadCorporativa')
	
DELETE
FROM sec.app_aplicaciones
WHERE NOT EXISTS (SELECT 1
 				  FROM sec.mod_modulos
 				  WHERE mod_codapp = app_id)
	AND app_id <> 'Home'
										
COMMIT

--SELECT * FROM sec.mod_modulos