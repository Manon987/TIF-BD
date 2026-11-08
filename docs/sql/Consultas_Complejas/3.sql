/*
Objetivo: Listar el código de las muestras de organismos clasificados como 'humano' 
para las cuales se haya registrado al menos una mutación genética en su secuencia de ADN. 
*/
SELECT m.codigo_muestra, o.nombre_clase
FROM muestra m
JOIN organismo o ON m.id_clase = o.id_clase
JOIN secuenciaADN s ON m.codigo_muestra = s.codigo_muestra
WHERE o.nombre_clase = 'humano'
  AND EXISTS (
      SELECT 1 
      FROM secuenciaMutacion sm 
      WHERE sm.id_secuencia = s.id_secuencia
  );
