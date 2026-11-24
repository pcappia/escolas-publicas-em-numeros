#!/usr/bin/env python3
"""Integrantes: Pâmela Cappia Torres; [inserir nome completo dos demais integrantes do grupo]

ETL - Censo Escolar 2025 (INEP) - Escolas públicas em atividade.

Uso:
    python etl_escolas_2025.py Tabela_Escola_2025_V2.csv saida.csv [--encoding latin-1]

Etapas: 1) extração  2) seleção de colunas  3) filtro  4) padronização
        5) tratamento de inconsistências  6) validações  7) exportação
"""
import argparse, sys
import pandas as pd

COLUNAS = [
    "NU_ANO_CENSO", "NO_REGIAO", "CO_REGIAO", "NO_UF", "SG_UF", "CO_UF",
    "NO_MUNICIPIO", "CO_MUNICIPIO", "NO_ENTIDADE", "CO_ENTIDADE", "CO_REDE",
    "TP_DEPENDENCIA", "TP_LOCALIZACAO", "TP_LOCALIZACAO_DIFERENCIADA",
    "TP_SITUACAO_FUNCIONAMENTO", "IN_AGUA_POTAVEL", "IN_AGUA_REDE_PUBLICA",
    "IN_AGUA_INEXISTENTE", "IN_ENERGIA_REDE_PUBLICA", "IN_ENERGIA_INEXISTENTE",
    "IN_ESGOTO_REDE_PUBLICA", "IN_ESGOTO_FOSSA_SEPTICA", "IN_ESGOTO_INEXISTENTE",
    "IN_BANHEIRO", "IN_BANHEIRO_PNE", "IN_BIBLIOTECA", "IN_BIBLIOTECA_SALA_LEITURA",
    "IN_LABORATORIO_INFORMATICA", "IN_QUADRA_ESPORTES", "IN_ACESSIBILIDADE_ELEVADOR",
    "IN_ACESSIBILIDADE_RAMPAS", "IN_ACESSIBILIDADE_INEXISTENTE", "IN_COMPUTADOR",
    "IN_INTERNET", "IN_INTERNET_ALUNOS", "IN_INTERNET_APRENDIZAGEM", "IN_BANDA_LARGA",
]
CAMPOS_GEO = ["CO_REGIAO", "NO_REGIAO", "CO_UF", "NO_UF", "SG_UF"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("entrada"); ap.add_argument("saida")
    ap.add_argument("--encoding", default="latin-1")
    a = ap.parse_args()

    # 1) Extração: tudo como texto e sem converter "NA"/vazio, para preservar os códigos originais
    df = pd.read_csv(a.entrada, sep=";", encoding=a.encoding, dtype=str, keep_default_na=False)
    n_origem = len(df)
    faltando = [c for c in COLUNAS if c not in df.columns]
    if faltando:
        sys.exit(f"Colunas ausentes na origem: {faltando}")

    # 2) Seleção de variáveis
    df = df[COLUNAS].copy()

    # 3) Filtro: rede pública (1) e em atividade (1)
    df = df[(df.CO_REDE == "1") & (df.TP_SITUACAO_FUNCIONAMENTO == "1")].copy()

    # 4) Padronização: remove espaços nas pontas e espaços duplicados nos textos
    for c in df.columns:
        df[c] = df[c].str.strip().str.replace(r"\s+", " ", regex=True)

    # 5) Tratamento de inconsistências
    # 5a) Campos geográficos vazios são recuperados de outras escolas do MESMO município
    #     (CO_MUNICIPIO), sem usar fontes externas.
    corrigidos = 0
    ref = df[(df[CAMPOS_GEO + ["NO_MUNICIPIO"]] != "").all(axis=1)] \
            .drop_duplicates("CO_MUNICIPIO").set_index("CO_MUNICIPIO")
    for c in CAMPOS_GEO + ["NO_MUNICIPIO"]:
        vazio = (df[c] == "") & df.CO_MUNICIPIO.isin(ref.index)
        corrigidos += int(vazio.sum())
        df.loc[vazio, c] = df.loc[vazio, "CO_MUNICIPIO"].map(ref[c])
    # 5b) Ausentes em indicadores NÃO são convertidos em 0 nem removidos (ver relatório)

    # 6) Validações
    assert df.CO_ENTIDADE.is_unique, "CO_ENTIDADE duplicado"
    assert (df.CO_ENTIDADE != "").all(), "CO_ENTIDADE vazio"
    for c in [c for c in COLUNAS if c.startswith("IN_")]:
        assert set(df[c]) <= {"0", "1", ""}, f"{c} com valor fora de 0/1"
    for c in CAMPOS_GEO + ["NO_MUNICIPIO"]:
        assert (df[c] != "").all(), f"{c} ainda possui vazios"

    # 7) Exportação: CSV ";" UTF-8 com BOM
    df.to_csv(a.saida, sep=";", index=False, encoding="utf-8-sig")
    print(f"Registros na origem: {n_origem}\nRegistros após filtro: {len(df)}")
    print(f"Colunas: {df.shape[1]}\nCampos geográficos recuperados: {corrigidos}")
    print(f"Células ausentes: {int((df == '').sum().sum())}")

if __name__ == "__main__":
    main()
