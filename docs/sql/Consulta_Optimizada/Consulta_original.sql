/*
El objetivo es obtener la cadena de nucleótidos y la longitud de las secuencias de ADN 
correspondientes a muestras que presentan un nivel de riesgo "alto" y cuya longitud de 
cadena sea mayor a 40 nucleótidos. 
*/
SELECT s.cadena_nucleotidos, s.longitud
FROM muestra m
JOIN secuenciaADN s ON m.codigo_muestra = s.codigo_muestra
JOIN nivelRiesgo nr ON m.id_riesgo = nr.id_riesgo
WHERE nr.descripcion = 'alto' AND s.longitud > 40;
