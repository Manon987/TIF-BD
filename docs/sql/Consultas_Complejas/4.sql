/*
Objetivo: Identificar los genes que presentan más de una mutación registrada en secuencias 
de ADN asociadas a muestras con nivel de riesgo 'medio' o 'alto'. Para estos genes, obtener 
el nombre del gen, la cantidad total de mutaciones registradas y la longitud promedio de las 
secuencias donde se presentan.  
*/
SELECT 
    m.gen,
    COUNT(DISTINCT sm.id_mutacion) AS total_mutaciones,
    ROUND(AVG(s.longitud), 2) AS longitud_promedio_secuencia
FROM mutacion m
JOIN secuenciaMutacion sm ON m.id_mutacion = sm.id_mutacion
JOIN secuenciaADN s ON sm.id_secuencia = s.id_secuencia
JOIN muestra mu ON s.codigo_muestra = mu.codigo_muestra
JOIN nivelRiesgo nr ON mu.id_riesgo = nr.id_riesgo
WHERE nr.descripcion IN ('medio', 'alto')
GROUP BY m.gen
HAVING COUNT(DISTINCT sm.id_mutacion) > 1
ORDER BY total_mutaciones DESC;

