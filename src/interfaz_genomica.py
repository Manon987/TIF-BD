"""
Interfaz de acceso a datos - Laboratorio de genómica (TIF Bases de Datos)

Se conecta a PostgreSQL con psycopg2, trae las secuencias de ADN 
y grafica la composición promedio de nucleótidos
(A, T, C, G) por clase de organismo, algo que SQL solo no puede dibujar.

Uso:
    python src/interfaz_genomica.py                # todas las secuencias
    python src/interfaz_genomica.py --min-long 30  # solo secuencias de >= 30 nt

Al ejecutarlo pide por teclado el nombre de la base y la contraseña (la contraseña
no se muestra al escribir ni se guarda en ningún archivo).
Variables de entorno opcionales: PGHOST, PGPORT, PGUSER (por defecto localhost,
5432, postgres) y PGDATABASE (nombre sugerido por defecto).
Salida: carpeta ./salida con el gráfico (.png) y la tabla (.csv)
"""
import argparse
import getpass
import os

import matplotlib
matplotlib.use("Agg") 
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import psycopg2

SALIDA = "salida"
ORDEN_CLASES = ["bacteria", "virus", "planta", "humano"]


def pedir_datos():
    """Pide por teclado el nombre de la base y la contraseña (sin mostrarla)."""
    defecto = os.environ.get("PGDATABASE", "genomica")
    base = input(f"Nombre de la base de datos [{defecto}]: ").strip() or defecto
    clave = getpass.getpass("Contraseña de PostgreSQL (no se ve al escribir): ")
    return base, clave


def conectar(dbname, password):
    return psycopg2.connect(
        host=os.environ.get("PGHOST", "localhost"),
        port=int(os.environ.get("PGPORT", "5432")),
        dbname=dbname,
        user=os.environ.get("PGUSER", "postgres"),
        password=password,
    )


def conectar_interactivo(intentos=3):
    for i in range(1, intentos + 1):
        base, clave = pedir_datos()
        try:
            return conectar(base, clave)
        except (psycopg2.OperationalError, UnicodeDecodeError) as e:
            # UnicodeDecodeError: en Windows en español, el mensaje de error del
            # servidor a veces no se puede decodificar; se muestra un texto genérico.
            detalle = str(e).strip() if isinstance(e, psycopg2.OperationalError) else \
                "contraseña incorrecta o base inexistente"
            print(f"\nNo se pudo conectar: {detalle}")
            if i < intentos:
                print(f"Intento {i} de {intentos}. Probá de nuevo.\n")
    raise SystemExit("Demasiados intentos fallidos. Verificá que PostgreSQL esté "
                     "encendido, el nombre de la base y la contraseña.")


def consulta_df(con, sql, params=()):
    cur = con.cursor()
    cur.execute(sql, params)
    filas = cur.fetchall()
    columnas = [d[0].lower() for d in cur.description]
    cur.close()
    return pd.DataFrame(filas, columns=columnas)


SQL_SECUENCIAS = """
SELECT m.codigo_muestra,
       o.nombre_clase AS clase,
       s.longitud, s.cant_a, s.cant_t, s.cant_c, s.cant_g
FROM secuenciaADN s
JOIN muestra m   ON m.codigo_muestra = s.codigo_muestra
JOIN organismo o ON o.id_clase = m.id_clase
WHERE s.longitud >= %s
ORDER BY m.codigo_muestra
"""
def composicion_nucleotidos(df):
    """% promedio de A, T, C, G por clase de organismo."""
    d = df.copy()
    for n in ["a", "t", "c", "g"]:
        d[f"pct_{n}"] = d[f"cant_{n}"] / d["longitud"] * 100
    clases = [c for c in ORDEN_CLASES if c in set(d["clase"])]
    medias = d.groupby("clase")[["pct_a", "pct_t", "pct_c", "pct_g"]].mean().loc[clases]
    medias.columns = ["A", "T", "C", "G"]
    return medias


def graficar(medias, ruta):
    """Barras agrupadas: un grupo por clase, una barra por nucleótido."""
    fig, ax = plt.subplots(figsize=(7.5, 4.5))
    x = np.arange(len(medias))
    ancho = 0.2
    for i, nuc in enumerate(medias.columns):
        ax.bar(x + (i - 1.5) * ancho, medias[nuc], ancho, label=nuc)
    ax.set_xticks(x)
    ax.set_xticklabels(medias.index)
    ax.set_ylabel("Composición promedio (%)")
    ax.set_title("Composición de nucleótidos por clase de organismo")
    ax.legend(title="Nucleótido", loc="center left", bbox_to_anchor=(1.02, 0.5))
    fig.tight_layout()
    fig.savefig(ruta, dpi=150)
    plt.close(fig)

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--min-long", type=int, default=0,
                    help="longitud mínima de secuencia a incluir (parámetro SQL)")
    args = ap.parse_args()

    os.makedirs(SALIDA, exist_ok=True)
    con = conectar_interactivo()
    try:
        df = consulta_df(con, SQL_SECUENCIAS, (args.min_long,))
    finally:
        con.close()

    for col in ["longitud", "cant_a", "cant_t", "cant_c", "cant_g"]:
        df[col] = df[col].astype(int)

    medias = composicion_nucleotidos(df)
    n_por_clase = df.groupby("clase").size().reindex(medias.index)

    print(f"Secuencias analizadas: {len(df)} (longitud >= {args.min_long})\n")
    print("Composición promedio de nucleótidos (%) por clase de organismo")
    resumen = medias.round(1).copy()
    resumen["n"] = n_por_clase
    print(resumen.to_string())

    graficar(medias, os.path.join(SALIDA, "composicion_nucleotidos.png"))
    resumen.to_csv(os.path.join(SALIDA, "composicion_nucleotidos.csv"))
    print(f"\nArchivos generados en ./{SALIDA}/")


if __name__ == "__main__":
    main()