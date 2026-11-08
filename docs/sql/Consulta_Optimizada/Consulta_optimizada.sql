SELECT s.cadena_nucleotidos, s.longitud
FROM (
    SELECT codigo_muestra, cadena_nucleotidos, longitud 
    FROM secuenciaADN 
    WHERE longitud > 40
) s
JOIN (
	SELECT codigo_muestra, id_riesgo
	FROM muestra
)m ON s.codigo_muestra = m.codigo_muestra
JOIN (
    SELECT id_riesgo 
    FROM nivelRiesgo 
    WHERE descripcion = 'alto'
) nr ON m.id_riesgo = nr.id_riesgo;
