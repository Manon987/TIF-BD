/*
Objetivo: Listar el nombre y el país de cada laboratorio junto con la cantidad total de muestras 
con nivel de riesgo “alto” gestionadas por sus investigadores, ordenadas de mayor a menor cantidad.  
*/
SELECT l.nombre AS laboratorio, l.pais, COUNT(m.codigo_muestra) AS total_muestras_alto_riesgo
FROM laboratorio l
JOIN investigador i ON l.id_laboratorio = i.id_laboratorio
JOIN muestra m ON i.id_investigador = m.id_investigador
JOIN nivelRiesgo nr ON m.id_riesgo = nr.id_riesgo
WHERE nr.descripcion = 'alto'
GROUP BY l.id_laboratorio, l.nombre, l.pais
ORDER BY total_muestras_alto_riesgo DESC;
