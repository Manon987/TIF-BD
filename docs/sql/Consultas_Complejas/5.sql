/*
Objetivo: Consultar el código de muestra, la cadena de nucleótidos, el porcentaje de contenido GC 
y el nombre del proyecto de aquellas muestras pertenecientes a organismos de tipo 'virus' o 'bacteria' 
que presenten un nivel de riesgo 'medio' o 'alto'. 
*/
SELECT m.codigo_muestra, s.cadena_nucleotidos, s.contenido_gc, pr.nombre AS proyecto, o.nombre_clase, nr.descripcion AS riesgo
FROM muestra m
JOIN secuenciaADN s ON m.codigo_muestra = s.codigo_muestra
JOIN proyecto pr ON m.id_proyecto = pr.id_proyecto
JOIN organismo o ON m.id_clase = o.id_clase
JOIN nivelRiesgo nr ON m.id_riesgo = nr.id_riesgo
WHERE o.nombre_clase IN ('virus', 'bacteria')
  AND nr.descripcion IN ('medio', 'alto');



