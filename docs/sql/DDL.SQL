CREATE TABLE laboratorio (
    id_laboratorio SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL
);

CREATE TABLE proyecto (
    id_proyecto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_inicio DATE NOT NULL
);

CREATE TABLE investigador (
    id_investigador SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    id_laboratorio INT NOT NULL,
    CONSTRAINT fk_investigador_laboratorio FOREIGN KEY (id_laboratorio) REFERENCES laboratorio(id_laboratorio)
);

CREATE TABLE participacion (
    id_proyecto INT NOT NULL,
    id_investigador INT NOT NULL,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE,
    PRIMARY KEY(id_proyecto,  id_investigador, fecha_desde),
    CONSTRAINT fk_participacion_proyecto FOREIGN KEY (id_proyecto) REFERENCES proyecto(id_proyecto),
    CONSTRAINT fk_participacion_investigador FOREIGN KEY(id_investigador) REFERENCES investigador(id_investigador),
    CONSTRAINT ck_participacion_fechas CHECK (fecha_hasta IS NULL OR fecha_hasta >= fecha_desde)
);

CREATE TABLE organismo (
    id_clase SERIAL PRIMARY KEY,
    nombre_clase VARCHAR(20) NOT NULL CHECK (nombre_clase IN ('bacteria', 'virus', 'planta', 'humano'))
);

CREATE TABLE nivelRiesgo (
    id_riesgo SERIAL PRIMARY KEY,
    descripcion VARCHAR(20) NOT NULL CHECK (descripcion IN ('bajo', 'medio', 'alto'))
);

CREATE TABLE muestra (
    codigo_muestra VARCHAR(50) PRIMARY KEY,
    id_investigador INT NOT NULL,
    id_proyecto INT NOT NULL,
    id_clase INT NOT NULL,
    id_riesgo INT NOT NULL,
    CONSTRAINT fk_muestra_investigador FOREIGN KEY (id_investigador) REFERENCES investigador(id_investigador),
    CONSTRAINT fk_muestra_organismo FOREIGN KEY (id_clase) REFERENCES organismo(id_clase),
    CONSTRAINT fk_muestra_proyecto FOREIGN KEY (id_proyecto) REFERENCES proyecto(id_proyecto),
    CONSTRAINT fk_muestra_nivelRiesgo FOREIGN KEY (id_riesgo) REFERENCES nivelRiesgo(id_riesgo)
);

CREATE TABLE secuenciaADN (
    id_secuencia SERIAL PRIMARY KEY,
    cadena_nucleotidos TEXT NOT NULL CHECK (cadena_nucleotidos ~ '^[ACGT]+$'),
    longitud INT GENERATED ALWAYS AS (length(cadena_nucleotidos)) STORED,
    cant_A INT GENERATED ALWAYS AS
        (length(cadena_nucleotidos) - length(replace(cadena_nucleotidos, 'A', ''))) STORED,
    cant_T INT GENERATED ALWAYS AS
        (length(cadena_nucleotidos) - length(replace(cadena_nucleotidos, 'T', ''))) STORED,
    cant_C INT GENERATED ALWAYS AS
        (length(cadena_nucleotidos) - length(replace(cadena_nucleotidos, 'C', ''))) STORED,
    cant_G INT GENERATED ALWAYS AS
        (length(cadena_nucleotidos) - length(replace(cadena_nucleotidos, 'G', ''))) STORED,
    contenido_gc NUMERIC(5,2) GENERATED ALWAYS AS (
        ROUND(100.0 * (
            (length(cadena_nucleotidos) - length(replace(cadena_nucleotidos, 'G', ''))) +
            (length(cadena_nucleotidos) - length(replace(cadena_nucleotidos, 'C', '')))
        ) / length(cadena_nucleotidos), 2)
    ) STORED,
    contenido_at NUMERIC(5,2) GENERATED ALWAYS AS (
        100 - ROUND(100.0 * (
            (length(cadena_nucleotidos) - length(replace(cadena_nucleotidos, 'G', ''))) +
            (length(cadena_nucleotidos) - length(replace(cadena_nucleotidos, 'C', '')))
        ) / length(cadena_nucleotidos), 2)
    ) STORED,
    codigo_muestra VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT fk_secuencia_muestra FOREIGN KEY (codigo_muestra) REFERENCES muestra(codigo_muestra)
);


CREATE TABLE mutacion(
    id_mutacion SERIAL PRIMARY KEY,
    gen VARCHAR(100) NOT NULL,
    posicion INT NOT NULL CHECK(posicion >0),
    tipo VARCHAR(50) NOT NULL
);

CREATE TABLE secuenciaMutacion(
    id_secuencia INT NOT NULL,
    id_mutacion INT NOT NULL,
    PRIMARY KEY(id_secuencia, id_mutacion),
    CONSTRAINT fk_sm_secuencia FOREIGN KEY (id_secuencia) REFERENCES secuenciaADN(id_secuencia),
    CONSTRAINT fk_sm_mutacion FOREIGN KEY (id_mutacion) REFERENCES mutacion(id_mutacion)
);
