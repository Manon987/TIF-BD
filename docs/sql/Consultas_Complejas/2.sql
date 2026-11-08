/*
Objetivo: Obtener el nombre y el país de los laboratorios que tengan investigadores
 registrados participando en proyectos de investigación cuya fecha de inicio sea anterior 
 al 1 de enero de 2025.  
*/
SELECT DISTINCT l.nombre, l.pais
FROM laboratorio l
JOIN investigador i ON l.id_laboratorio = i.id_laboratorio
WHERE i.id_investigador IN (
    SELECT p_inv.id_investigador
    FROM participacion p_inv
    JOIN proyecto pr ON p_inv.id_proyecto = pr.id_proyecto
    WHERE pr.fecha_inicio < '2025-01-01'
);
