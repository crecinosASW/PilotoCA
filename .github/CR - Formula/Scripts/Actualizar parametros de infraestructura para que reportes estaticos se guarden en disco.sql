UPDATE cfg.par_parametros
SET par_valor = 'True'
WHERE par_id = 'ReporteEstaticoSeGuardaEnDisco'

UPDATE cfg.par_parametros
SET par_valor = '~/Reports'
WHERE par_id = 'RutaCrystalReports'

UPDATE cfg.par_parametros
SET par_valor = '~/Reports'
WHERE par_id = 'RutaLocalReportingServices'