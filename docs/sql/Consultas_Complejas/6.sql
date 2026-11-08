/*
Objetivo: Obtener el identificador de la secuencia, el código de muestra y su longitud para aquellas 
secuencias de ADN cuya cantidad de mutaciones asociadas supere estrictamente el promedio general de 
mutaciones por secuencia.
*/
SELECT s.id_secuencia, s.codigo_muestra, s.longitud, COUNT(sm.id_mutacion) AS cant_mutaciones
FROM secuenciaADN s
JOIN secuenciaMutacion sm ON s.id_secuencia = sm.id_secuencia
GROUP BY s.id_secuencia, s.codigo_muestra, s.longitud
HAVING COUNT(sm.id_mutacion) > (
    SELECT AVG(conteo)
    FROM (
        SELECT COUNT(sm_sub.id_mutacion) AS conteo
        FROM secuenciaADN s_sub
        LEFT JOIN secuenciaMutacion sm_sub ON s_sub.id_secuencia = sm_sub.id_secuencia
        GROUP BY s_sub.id_secuencia
    ) AS subquery
);
