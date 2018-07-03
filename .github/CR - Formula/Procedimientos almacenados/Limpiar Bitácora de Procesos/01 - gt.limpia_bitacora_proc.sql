IF EXISTS (SELECT NULL 
		   FROM sys.procedures p
			  JOIN sys.schemas s ON p.schema_id = s.schema_id 
		   WHERE p.name = 'limpia_bitacora_proc'
			   AND s.name = 'gt')
	DROP PROCEDURE gt.limpia_bitacora_proc
	
GO	

--EXEC gt.limpia_bitacora_proc
CREATE PROCEDURE gt.limpia_bitacora_proc

AS

BEGIN TRANSACTION

UPDATE n
SET nbp_ya_fue_leido = 0,
	nbp_fecha_leido = NULL
FROM cfg.nbp_notif_bitacora_procesos n
	JOIN cfg.bpr_bitacora_procesos b ON n.nbp_codbpr = b.bpr_codigo
	JOIN cfg.pro_procesos ON b.bpr_codpro = pro_codigo
WHERE NOT EXISTS (SELECT 1
				  FROM cfg.bpr_bitacora_procesos p
				  WHERE p.bpr_codpro = b.bpr_codpro
					  AND p.bpr_resultado = 'E')
					  
UPDATE n
SET nbp_ya_fue_leido = 1,
	nbp_fecha_leido = ISNULL(nbp_fecha_leido, GETDATE())
FROM cfg.nbp_notif_bitacora_procesos n
	JOIN cfg.bpr_bitacora_procesos b ON n.nbp_codbpr = b.bpr_codigo
	JOIN cfg.pro_procesos ON b.bpr_codpro = pro_codigo
WHERE EXISTS (SELECT 1
			  FROM cfg.bpr_bitacora_procesos p
			  WHERE p.bpr_codpro = b.bpr_codpro
				  AND p.bpr_resultado = 'S')					  	  
				  
COMMIT				  