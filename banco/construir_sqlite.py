#!/usr/bin/env python3
"""Integrantes: Pâmela Cappia Torres; Rafaela Ariana

Constrói a cópia SQLite do banco (arquivo único, abre no DB Browser for SQLite).

Usa os MESMOS scripts SQL do PostgreSQL (01, 02, 04, 05) e roda os testes da Parte A.
Uso (na pasta raiz do projeto):   python banco/construir_sqlite.py
"""
import csv, os, sqlite3, sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SQL = os.path.join(RAIZ, "banco", "sql")
CSV = os.path.join(RAIZ, "dados", "escolas_publicas_ativas_2025_tratada.csv")
DB = os.path.join(RAIZ, "banco", "escolas2025.db")


def ler(nome):
    with open(os.path.join(SQL, nome), encoding="utf-8") as f:
        return f.read()


if os.path.exists(DB):
    os.remove(DB)
con = sqlite3.connect(DB)
con.execute("PRAGMA foreign_keys = ON")
con.executescript(ler("01_criar_estrutura.sql"))
con.executescript(ler("02_carga_dominios.sql"))

# área de transição (equivalente ao \copy do PostgreSQL)
with open(CSV, encoding="utf-8-sig", newline="") as f:
    leitor = csv.reader(f, delimiter=";")
    cab = [c.lower() for c in next(leitor)]
    con.execute("CREATE TABLE stg_escola (%s)" % ", ".join(f"{c} TEXT" for c in cab))
    con.executemany("INSERT INTO stg_escola VALUES (%s)" % ",".join("?" * len(cab)), leitor)

con.executescript(ler("04_carga_escolas.sql"))
con.executescript(ler("05_indices_e_views.sql"))
con.commit()

# testes da Parte A (portáveis)
teste = ler("06_testes_integridade.sql").split("-- ===================== PARTE B")[0]
linhas = con.execute(teste[teste.index("SELECT 'A01"):].rstrip().rstrip(";")).fetchall()
falhas = [l for l in linhas if l[3] != "OK"]
for l in linhas:
    print(f"{l[0]:<48} esperado={l[1]!s:<8} obtido={l[2]!s:<8} {l[3]}")
print(f"\n{len(linhas) - len(falhas)}/{len(linhas)} testes OK")
con.execute("VACUUM")
con.close()
print("Banco gerado:", DB, f"({os.path.getsize(DB) / 1e6:.1f} MB)")
sys.exit(1 if falhas else 0)
